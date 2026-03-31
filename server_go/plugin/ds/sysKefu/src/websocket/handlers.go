package ws

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	appws "fastapp/internal/websocket"
	kefumodel "fastapp/plugin/ds/sysKefu/src/model"

	"gorm.io/gorm"
)

const visitorIDPrefix = "visitor_"

func kefuFillBase(action string, fields map[string]any) map[string]any {
	out := map[string]any{
		"type":      "push_message",
		"action":    action,
		"timestamp": time.Now().Unix(),
	}
	for k, v := range fields {
		out[k] = v
	}
	return out
}

func kefuMessageToMap(m *kefumodel.KefuMessage) map[string]any {
	b, _ := json.Marshal(m)
	var o map[string]any
	_ = json.Unmarshal(b, &o)
	return o
}

func pushHub(d *deps.Deps, hub *appws.Hub, keys []string, action string, fields map[string]any) {
	if d == nil || d.RDB == nil || hub == nil || len(keys) == 0 {
		return
	}
	ctx := context.Background()
	data := kefuFillBase(action, fields)
	ev, _ := data["action"].(string)
	hub.PushToUsers(ctx, d.RDB, keys, data, ev)
}

func handleKefuVisitorLastDisconnected(ctx context.Context, d *deps.Deps, hub *appws.Hub, visitorID string) {
	if d == nil || d.DB == nil || !strings.HasPrefix(visitorID, visitorIDPrefix) {
		return
	}
	var row kefumodel.KefuVisitor
	if err := d.DB.WithContext(ctx).Where("visitor_id = ?", visitorID).First(&row).Error; err != nil {
		return
	}
	kefuIDStr := strings.TrimSpace(row.KefuID)
	if kefuIDStr == "" {
		return
	}
	kefuIDNum, err := strconv.ParseInt(kefuIDStr, 10, 64)
	if err != nil {
		return
	}
	var k kefumodel.Kefu
	if err := d.DB.WithContext(ctx).Where("id = ?", kefuIDNum).First(&k).Error; err != nil || k.CreatedBy == nil {
		return
	}
	target := strconv.FormatInt(*k.CreatedBy, 10)
	fields := map[string]any{
		"visitor_id":  visitorID,
		"kefu_id":     kefuIDStr,
		"sender_type": 1,
		"form_uid":    0,
		"to_uid":      target,
	}
	pushHub(d, hub, []string{target}, "kefu_visitor_conversation_end", fields)
	_ = d.DB.WithContext(ctx).Where("visitor_id = ?", visitorID).Delete(&kefumodel.KefuVisitor{}).Error
}

func wsKefuFloatInt(v any) (int64, bool) {
	switch x := v.(type) {
	case float64:
		return int64(x), true
	case int:
		return int64(x), true
	case int64:
		return x, true
	case string:
		n, err := strconv.ParseInt(strings.TrimSpace(x), 10, 64)
		return n, err == nil
	case json.Number:
		n, err := x.Int64()
		return n, err == nil
	default:
		return 0, false
	}
}

func handleKefuMessageSend(ctx context.Context, d *deps.Deps, hub *appws.Hub, opID string, data map[string]any, userID int64) appws.Response {
	if d == nil || d.DB == nil {
		return appws.ErrorResp("service unavailable", opID)
	}
	cid, ok := wsKefuFloatInt(data["conversation_id"])
	if !ok || cid <= 0 {
		return appws.ErrorResp("conversation_id is required", opID)
	}
	content, _ := data["content"].(string)
	fileURL, _ := data["file_url"].(string)
	if strings.TrimSpace(content) == "" && strings.TrimSpace(fileURL) == "" {
		return appws.ErrorResp("content or file_url is required", opID)
	}
	senderType, _ := wsKefuFloatInt(data["sender_type"])
	if senderType == 0 {
		senderType = 1
	}
	msgType, _ := wsKefuFloatInt(data["message_type"])
	if msgType == 0 {
		msgType = 1
	}

	var conv kefumodel.KefuConversation
	if err := d.DB.WithContext(ctx).Where("id = ?", cid).First(&conv).Error; err != nil {
		return appws.ErrorResp("Failed to save message", opID)
	}
	if senderType == 1 && conv.UserID != userID {
		return appws.ErrorResp("Failed to save message", opID)
	}
	if senderType == 2 {
		var k kefumodel.Kefu
		if err := d.DB.WithContext(ctx).Where("id = ?", conv.KefuID).First(&k).Error; err != nil || k.CreatedBy == nil || *k.CreatedBy != userID {
			return appws.ErrorResp("Failed to save message", opID)
		}
	}

	var filePtr *string
	if strings.TrimSpace(fileURL) != "" {
		s := strings.TrimSpace(fileURL)
		filePtr = &s
	}

	msgRow := kefumodel.KefuMessage{
		ConversationID: cid,
		Content:        content,
		MessageType:    int(msgType),
		FileURL:        filePtr,
		SenderType:     int(senderType),
	}

	var formUID int64
	var toUID int64

	err := d.DB.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		now := time.Now()
		conv.LastMessageAt = &now
		if senderType == 1 {
			msgRow.SenderID = userID
			var k kefumodel.Kefu
			if err := tx.Where("id = ?", conv.KefuID).First(&k).Error; err != nil {
				return err
			}
			if k.CreatedBy == nil {
				return errNoKefuOwner
			}
			toUID = *k.CreatedBy
			formUID = userID
			conv.KefuUnreadCount++
		} else {
			msgRow.SenderID = conv.KefuID
			toUID = conv.UserID
			formUID = 0
			conv.UnreadCount++
		}
		if err := tx.Create(&msgRow).Error; err != nil {
			return err
		}
		return tx.Model(&kefumodel.KefuConversation{}).Where("id = ?", conv.ID).Updates(map[string]any{
			"last_message_at":   conv.LastMessageAt,
			"unread_count":      conv.UnreadCount,
			"kefu_unread_count": conv.KefuUnreadCount,
			"updated_at":        now,
		}).Error
	})
	if err != nil {
		if errors.Is(err, errNoKefuOwner) {
			return appws.ErrorResp("Failed to save message", opID)
		}
		return appws.ErrorResp("Failed to save message", opID)
	}

	payload := kefuMessageToMap(&msgRow)
	payload["form_uid"] = formUID
	payload["to_uid"] = toUID
	payload["kefu_id"] = conv.KefuID
	payload["message_id"] = msgRow.ID

	pushHub(d, hub, []string{strconv.FormatInt(toUID, 10)}, "kefu_message", payload)

	if senderType == 1 && strings.TrimSpace(content) != "" {
		lang := tools.ProfileLang(d.DB.WithContext(ctx), userID)
		go tryKefuAutoReply(context.Background(), d, hub, cid, userID, strings.TrimSpace(content), lang)
	}

	return appws.SuccessResp(map[string]any{
		"message_id": msgRow.ID,
		"created_at": msgRow.CreatedAt.Format("2006-01-02 15:04:05"),
	}, "Message sent successfully", opID)
}

var errNoKefuOwner = errors.New("kefu owner missing")

func handleKefuMessageRead(ctx context.Context, d *deps.Deps, _ *appws.Hub, opID string, data map[string]any, _ int64) appws.Response {
	if d == nil || d.DB == nil {
		return appws.ErrorResp("service unavailable", opID)
	}
	cid, ok := wsKefuFloatInt(data["conversation_id"])
	if !ok || cid <= 0 {
		return appws.ErrorResp("conversation_id is required", opID)
	}
	senderType, _ := wsKefuFloatInt(data["sender_type"])
	if senderType == 0 {
		senderType = 1
	}
	var ids []int64
	if arr, ok := data["message_ids"].([]any); ok {
		for _, it := range arr {
			if n, ok := wsKefuFloatInt(it); ok && n > 0 {
				ids = append(ids, n)
			}
		}
	}

	q := d.DB.WithContext(ctx).Model(&kefumodel.KefuMessage{}).Where("conversation_id = ? AND sender_type = ?", cid, int(senderType))
	if len(ids) > 0 {
		q = q.Where("id IN ?", ids)
	}
	now := time.Now()
	res := q.Updates(map[string]any{"is_read": 1, "read_at": now})
	if res.Error != nil {
		return appws.ErrorResp("Failed to mark messages as read", opID)
	}
	up := map[string]any{"updated_at": now}
	if senderType == 1 {
		up["unread_count"] = 0
	} else {
		up["kefu_unread_count"] = 0
	}
	_ = d.DB.WithContext(ctx).Model(&kefumodel.KefuConversation{}).Where("id = ?", cid).Updates(up).Error
	return appws.SuccessResp(map[string]any{"updated_count": res.RowsAffected}, "Messages marked as read", opID)
}

func handleKefuMessageEnd(ctx context.Context, d *deps.Deps, hub *appws.Hub, opID string, data map[string]any, userID int64) appws.Response {
	if d == nil || d.DB == nil {
		return appws.ErrorResp("service unavailable", opID)
	}
	cid, ok := wsKefuFloatInt(data["conversation_id"])
	if !ok || cid <= 0 {
		return appws.ErrorResp("conversation_id is required", opID)
	}

	var conv kefumodel.KefuConversation
	if err := d.DB.WithContext(ctx).Where("id = ?", cid).First(&conv).Error; err != nil {
		return appws.ErrorResp("Failed to end conversation. Conversation not found or no permission.", opID)
	}
	if conv.Status == 2 {
		return appws.SuccessResp(map[string]any{"conversation_id": cid}, "Conversation ended successfully", opID)
	}

	var k kefumodel.Kefu
	if err := d.DB.WithContext(ctx).Where("id = ?", conv.KefuID).First(&k).Error; err != nil || k.CreatedBy == nil {
		return appws.ErrorResp("Failed to end conversation. Conversation not found or no permission.", opID)
	}
	kfUID := *k.CreatedBy

	operatorType := 1
	var fromUID int64
	var toUID int64
	if conv.UserID == userID {
		toUID = kfUID
		fromUID = userID
		conv.UnreadCount = 0
	} else if kfUID == userID {
		operatorType = 2
		fromUID = 0
		toUID = conv.UserID
		conv.KefuUnreadCount = 0
	} else {
		return appws.ErrorResp("Failed to end conversation. Conversation not found or no permission.", opID)
	}

	err := d.DB.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&kefumodel.KefuConversation{}).Where("id = ?", cid).Updates(map[string]any{
			"status":            2,
			"unread_count":      conv.UnreadCount,
			"kefu_unread_count": conv.KefuUnreadCount,
			"updated_at":        time.Now(),
		}).Error; err != nil {
			return err
		}
		return tx.Model(&kefumodel.Kefu{}).Where("id = ?", conv.KefuID).
			UpdateColumn("current_concurrent", gorm.Expr("current_concurrent - ?", 1)).Error
	})
	if err != nil {
		return appws.ErrorResp("Failed to end conversation. Conversation not found or no permission.", opID)
	}

	fields := map[string]any{
		"form_uid":        fromUID,
		"to_uid":          toUID,
		"conversation_id": conv.ID,
		"kefu_id":         conv.KefuID,
		"operator_id":     userID,
		"operator_type":   operatorType,
	}
	pushHub(d, hub, []string{strconv.FormatInt(toUID, 10)}, "kefu_message_end", fields)

	return appws.SuccessResp(map[string]any{"conversation_id": cid}, "Conversation ended successfully", opID)
}

func handleKefuVisitorMessageSend(ctx context.Context, d *deps.Deps, hub *appws.Hub, opID string, data map[string]any) appws.Response {
	if d == nil || d.DB == nil {
		return appws.ErrorResp("service unavailable", opID)
	}
	visitorID, _ := data["visitor_id"].(string)
	visitorID = strings.TrimSpace(visitorID)
	kefuStr := strings.TrimSpace(fmt.Sprint(data["kefu_id"]))
	content, _ := data["content"].(string)
	content = strings.TrimSpace(content)
	if visitorID == "" {
		return appws.ErrorResp("visitor_id is required", opID)
	}
	if kefuStr == "" {
		return appws.ErrorResp("kefu_id is required", opID)
	}
	if content == "" {
		return appws.ErrorResp("content is required", opID)
	}
	senderType, _ := wsKefuFloatInt(data["sender_type"])
	if senderType == 0 {
		senderType = 1
	}

	row := kefumodel.KefuVisitor{
		VisitorID:  visitorID,
		KefuID:     kefuStr,
		SenderType: int(senderType),
		Content:    content,
	}
	if err := d.DB.WithContext(ctx).Create(&row).Error; err != nil {
		return appws.ErrorResp("Failed to save visitor message", opID)
	}

	kefuIDNum, _ := strconv.ParseInt(kefuStr, 10, 64)
	var toKey string
	if senderType == 1 {
		var k kefumodel.Kefu
		if err := d.DB.WithContext(ctx).Where("id = ?", kefuIDNum).First(&k).Error; err == nil && k.CreatedBy != nil {
			toKey = strconv.FormatInt(*k.CreatedBy, 10)
		}
	} else {
		toKey = visitorID
	}
	if toKey != "" {
		fields := map[string]any{
			"visitor_id":  visitorID,
			"kefu_id":     kefuStr,
			"sender_type": senderType,
			"content":     content,
			"message_id":  row.ID,
			"created_at":  row.CreatedAt.Format("2006-01-02 15:04:05"),
			"form_uid":    0,
			"to_uid":      toKey,
		}
		pushHub(d, hub, []string{toKey}, "kefu_visitor_message", fields)
	}

	return appws.SuccessResp(map[string]any{
		"message_id": row.ID,
		"created_at": row.CreatedAt.Format("2006-01-02 15:04:05"),
	}, "Visitor message sent successfully", opID)
}

func handleKefuVisitorMessageEnd(ctx context.Context, d *deps.Deps, hub *appws.Hub, opID string, data map[string]any) appws.Response {
	if d == nil || d.DB == nil {
		return appws.ErrorResp("service unavailable", opID)
	}
	visitorID, _ := data["visitor_id"].(string)
	visitorID = strings.TrimSpace(visitorID)
	kefuStr := strings.TrimSpace(fmt.Sprint(data["kefu_id"]))
	if visitorID == "" {
		return appws.ErrorResp("visitor_id is required", opID)
	}
	if kefuStr == "" {
		return appws.ErrorResp("kefu_id is required", opID)
	}
	senderType, _ := wsKefuFloatInt(data["sender_type"])
	if senderType == 0 {
		senderType = 1
	}

	kefuIDNum, _ := strconv.ParseInt(kefuStr, 10, 64)
	var toKey string
	if senderType == 1 {
		var k kefumodel.Kefu
		if err := d.DB.WithContext(ctx).Where("id = ?", kefuIDNum).First(&k).Error; err == nil && k.CreatedBy != nil {
			toKey = strconv.FormatInt(*k.CreatedBy, 10)
		}
	} else {
		toKey = visitorID
	}
	if toKey != "" {
		fields := map[string]any{
			"visitor_id": visitorID, "kefu_id": kefuStr, "sender_type": senderType,
			"form_uid": 0, "to_uid": toKey,
		}
		pushHub(d, hub, []string{toKey}, "kefu_visitor_conversation_end", fields)
	}
	return appws.SuccessResp(map[string]any{}, "Visitor conversation ended successfully", opID)
}
