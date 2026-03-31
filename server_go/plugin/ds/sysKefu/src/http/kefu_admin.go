package skfuhttp

import (
	"context"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	kefumodel "fastapp/plugin/ds/sysKefu/src/model"

	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

const autoReplyRulesCachePrefix = "kefu:auto_reply:rules:"

func kefuAdminPageList(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&kefumodel.Kefu{}).TableName()
	q := h.D.DBx(h.C).Model(&kefumodel.Kefu{}).Where(tbl+".created_by = ?", uid)
	if v := strings.TrimSpace(h.C.Query("nickname")); v != "" {
		q = q.Where(tbl+".nickname LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var rows []kefumodel.Kefu
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type kefuWriteBody struct {
	Nickname      string `json:"nickname"`
	Avatar        string `json:"avatar"`
	Status        *int   `json:"status"`
	MaxConcurrent *int   `json:"max_concurrent"`
}

func kefuAdminCreate(h *deps.HandlerCtx) {
	var body kefuWriteBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	u := int64(uid)
	row := kefumodel.Kefu{Nickname: body.Nickname, Avatar: body.Avatar, CreatedBy: &u, UpdatedBy: &u}
	if body.Status != nil {
		row.Status = *body.Status
	} else {
		row.Status = 1
	}
	if body.MaxConcurrent != nil {
		row.MaxConcurrent = *body.MaxConcurrent
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuAdminSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body kefuWriteBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	u := int64(uid)
	up := map[string]any{"updated_by": u}
	if body.Nickname != "" {
		up["nickname"] = body.Nickname
	}
	if body.Avatar != "" {
		up["avatar"] = body.Avatar
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if body.MaxConcurrent != nil {
		up["max_concurrent"] = *body.MaxConcurrent
	}
	if err := h.D.DBx(h.C).Model(&kefumodel.Kefu{}).Where("id = ? AND created_by = ?", id, uid).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	uid := middleware.UserID(h.C)
	if err := h.D.DBx(h.C).Where("id IN ? AND created_by = ?", ids, uid).Delete(&kefumodel.Kefu{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuConversationAdminPage(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	page, pageSize := tools.ParsePage(h.C)
	ct := (&kefumodel.KefuConversation{}).TableName()
	kt := (&kefumodel.Kefu{}).TableName()
	q := h.D.DBx(h.C).Model(&kefumodel.KefuConversation{}).
		Joins("JOIN "+kt+" ON "+kt+".id = "+ct+".kefu_id AND "+kt+".created_by = ?", uid).
		Preload("Kefu", func(db *gorm.DB) *gorm.DB { return db.Select("id", "avatar", "nickname") }).
		Preload("Profile", func(db *gorm.DB) *gorm.DB { return db.Select("user_id", "avatar", "nickname") })

	if v := strings.TrimSpace(h.C.Query("user_id")); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			q = q.Where(ct+".user_id = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("kefu_id")); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			q = q.Where(ct+".kefu_id = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(ct+".status = ?", n)
		}
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []kefumodel.KefuConversation
	offset := (page - 1) * pageSize
	if err := q.Order(ct + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

func kefuConversationAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	uid := middleware.UserID(h.C)
	sub := h.D.DBx(h.C).Model(&kefumodel.Kefu{}).Select("id").Where("created_by = ?", uid)
	if err := h.D.DBx(h.C).Where("id IN ? AND kefu_id IN (?)", ids, sub).Delete(&kefumodel.KefuConversation{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuConversationAdminMessage(h *deps.HandlerCtx) {
	cidStr := h.C.Query("conversation_id")
	if cidStr == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "conversation_id required", nil))
		return
	}
	cid, err := strconv.ParseInt(cidStr, 10, 64)
	if err != nil || cid <= 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "conversation_id invalid", nil))
		return
	}
	page, pageSize := tools.ParsePage(h.C)
	uid := middleware.UserID(h.C)
	kt := (&kefumodel.Kefu{}).TableName()
	ct := (&kefumodel.KefuConversation{}).TableName()
	var accessCnt int64
	if err := h.D.DBx(h.C).Model(&kefumodel.KefuConversation{}).
		Joins("JOIN "+kt+" ON "+kt+".id = "+ct+".kefu_id AND "+kt+".created_by = ?", uid).
		Where(ct+".id = ?", cid).Count(&accessCnt).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	if accessCnt == 0 {
		response.JSON(h.C, 200, response.Fail("not found"))
		return
	}
	mt := (&kefumodel.KefuMessage{}).TableName()
	var total int64
	if err := h.D.DBx(h.C).Model(&kefumodel.KefuMessage{}).Where(mt+".conversation_id = ?", cid).Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var list []kefumodel.KefuMessage
	if err := h.D.DBx(h.C).Where("conversation_id = ?", cid).Order("id DESC").Limit(pageSize).Offset(offset).Find(&list).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	//
	for i, j := 0, len(list)-1; i < j; i, j = i+1, j-1 {
		list[i], list[j] = list[j], list[i]
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list, "total": total}))
}

func kefuConversationAdminMessageVisitor(h *deps.HandlerCtx) {
	vid := strings.TrimSpace(h.C.Query("visitor_id"))
	kid := strings.TrimSpace(h.C.Query("kefu_id"))
	if vid == "" || kid == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "visitor_id and kefu_id required", nil))
		return
	}
	page, pageSize := tools.ParsePage(h.C)
	var q *gorm.DB = h.D.DBx(h.C).Model(&kefumodel.KefuVisitor{}).Where("visitor_id = ? AND kefu_id = ?", vid, kid)
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var list []kefumodel.KefuVisitor
	if err := h.D.DBx(h.C).Where("visitor_id = ? AND kefu_id = ?", vid, kid).Order("id DESC").Limit(pageSize).Offset(offset).Find(&list).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	for i, j := 0, len(list)-1; i < j; i, j = i+1, j-1 {
		list[i], list[j] = list[j], list[i]
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

// chatTree / chatVisitorTree 与 PHP KefuConversationService 对齐；profile 仅含 user_id、nickname，避免整表 UserProfile 序列化泄露 trans_password 等字段。

type kefuChatTreeProfile struct {
	UserID   int64  `json:"user_id"`
	Nickname string `json:"nickname"`
}

type kefuChatTreeConversation struct {
	ID              int64                `json:"id"`
	KefuID          int64                `json:"kefu_id"`
	UserID          int64                `json:"user_id"`
	Status          int                  `json:"status"`
	LastMessageAt   *time.Time           `json:"last_message_at"`
	UnreadCount     int                  `json:"unread_count"`
	KefuUnreadCount int                  `json:"kefu_unread_count"`
	CreatedAt       time.Time            `json:"created_at"`
	UpdatedAt       time.Time            `json:"updated_at"`
	Profile         *kefuChatTreeProfile `json:"profile,omitempty"`
}

type kefuChatTreeKefu struct {
	ID                int64                    `json:"id"`
	Nickname          string                   `json:"nickname"`
	Avatar            string                   `json:"avatar,omitempty"`
	Status            int                      `json:"status"`
	MaxConcurrent     int                      `json:"max_concurrent"`
	CurrentConcurrent int                      `json:"current_concurrent"`
	CreatedBy         *int64                   `json:"created_by,omitempty"`
	UpdatedBy         *int64                   `json:"updated_by,omitempty"`
	CreatedAt         time.Time                `json:"created_at"`
	UpdatedAt         time.Time                `json:"updated_at"`
	Conversation      []kefuChatTreeConversation `json:"conversation"`
}

func kefuChatTreeKefuBase(k kefumodel.Kefu) kefuChatTreeKefu {
	return kefuChatTreeKefu{
		ID:                k.ID,
		Nickname:          k.Nickname,
		Avatar:            k.Avatar,
		Status:            k.Status,
		MaxConcurrent:     k.MaxConcurrent,
		CurrentConcurrent: k.CurrentConcurrent,
		CreatedBy:         k.CreatedBy,
		UpdatedBy:         k.UpdatedBy,
		CreatedAt:         k.CreatedAt,
		UpdatedAt:         k.UpdatedAt,
	}
}

func kefuAdminChatTree(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	var kefus []kefumodel.Kefu
	if err := h.D.DBx(h.C).Where("created_by = ?", uid).Order("id ASC").Find(&kefus).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	out := make([]kefuChatTreeKefu, 0, len(kefus))
	for _, k := range kefus {
		var convs []kefumodel.KefuConversation
		if err := h.D.DBx(h.C).Where("kefu_id = ? AND status = ?", k.ID, 1).
			Preload("Profile", func(db *gorm.DB) *gorm.DB {
				return db.Select("user_id", "nickname")
			}).Order("last_message_at DESC").Find(&convs).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		convOut := make([]kefuChatTreeConversation, 0, len(convs))
		for _, c := range convs {
			row := kefuChatTreeConversation{
				ID:              c.ID,
				KefuID:          c.KefuID,
				UserID:          c.UserID,
				Status:          c.Status,
				LastMessageAt:   c.LastMessageAt,
				UnreadCount:     c.UnreadCount,
				KefuUnreadCount: c.KefuUnreadCount,
				CreatedAt:       c.CreatedAt,
				UpdatedAt:       c.UpdatedAt,
			}
			if c.Profile != nil {
				row.Profile = &kefuChatTreeProfile{
					UserID:   c.Profile.UserID,
					Nickname: c.Profile.Nickname,
				}
			}
			convOut = append(convOut, row)
		}
		item := kefuChatTreeKefuBase(k)
		item.Conversation = convOut
		out = append(out, item)
	}
	response.JSON(h.C, 200, response.OK(out))
}

type kefuChatVisitorStub struct {
	KefuID    string `json:"kefu_id"`
	VisitorID string `json:"visitor_id"`
}

type kefuChatVisitorTreeItem struct {
	ID                int64                 `json:"id"`
	Nickname          string                `json:"nickname"`
	Avatar            string                `json:"avatar,omitempty"`
	Status            int                   `json:"status"`
	MaxConcurrent     int                   `json:"max_concurrent"`
	CurrentConcurrent int                   `json:"current_concurrent"`
	CreatedBy         *int64                `json:"created_by,omitempty"`
	UpdatedBy         *int64                `json:"updated_by,omitempty"`
	CreatedAt         time.Time             `json:"created_at"`
	UpdatedAt         time.Time             `json:"updated_at"`
	Visitor           []kefuChatVisitorStub `json:"visitor"`
}

func kefuAdminChatVisitorTree(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	var kefus []kefumodel.Kefu
	if err := h.D.DBx(h.C).Where("created_by = ?", uid).Order("id ASC").Find(&kefus).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	res := make([]kefuChatVisitorTreeItem, 0, len(kefus))
	for _, k := range kefus {
		var stubs []kefuChatVisitorStub
		if err := h.D.DBx(h.C).Model(&kefumodel.KefuVisitor{}).
			Select("kefu_id", "visitor_id").
			Where("kefu_id = ?", fmt.Sprintf("%d", k.ID)).
			Group("visitor_id, kefu_id").
			Find(&stubs).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		base := kefuChatTreeKefuBase(k)
		res = append(res, kefuChatVisitorTreeItem{
			ID:                base.ID,
			Nickname:          base.Nickname,
			Avatar:            base.Avatar,
			Status:            base.Status,
			MaxConcurrent:     base.MaxConcurrent,
			CurrentConcurrent: base.CurrentConcurrent,
			CreatedBy:         base.CreatedBy,
			UpdatedBy:         base.UpdatedBy,
			CreatedAt:         base.CreatedAt,
			UpdatedAt:         base.UpdatedAt,
			Visitor:           stubs,
		})
	}
	response.JSON(h.C, 200, response.OK(res))
}

func kefuAutoReplyAdminList(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&kefumodel.KefuAutoReply{}).TableName()
	q := h.D.DBx(h.C).Model(&kefumodel.KefuAutoReply{}).Where(tbl+".created_by = ?", uid)
	if v := strings.TrimSpace(h.C.Query("title")); v != "" {
		q = q.Where(tbl+".title LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("lang")); v != "" {
		q = q.Where(tbl+".lang = ?", v)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []kefumodel.KefuAutoReply
	offset := (page - 1) * pageSize
	if err := q.Order(tbl + ".priority DESC, " + tbl + ".id ASC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type kefuAutoReplyBody struct {
	Title        string          `json:"title"`
	TriggerType  *int            `json:"trigger_type"`
	Keywords     json.RawMessage `json:"keywords"`
	ReplyType    *int            `json:"reply_type"`
	ReplyContent json.RawMessage `json:"reply_content"`
	Lang         string          `json:"lang"`
	Priority     *int            `json:"priority"`
	Status       *int            `json:"status"`
}

func kefuAutoReplyAdminCreate(h *deps.HandlerCtx) {
	var body kefuAutoReplyBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	u := int64(uid)
	row := kefumodel.KefuAutoReply{
		Title:        body.Title,
		Keywords:     body.Keywords,
		ReplyContent: body.ReplyContent,
		Lang:         body.Lang,
		CreatedBy:    &u,
		UpdatedBy:    &u,
	}
	if body.Lang == "" {
		row.Lang = "zh_CN"
	}
	if body.TriggerType != nil {
		row.TriggerType = *body.TriggerType
	}
	if body.ReplyType != nil {
		row.ReplyType = *body.ReplyType
	}
	if body.Priority != nil {
		row.Priority = *body.Priority
	}
	if body.Status != nil {
		row.Status = *body.Status
	} else {
		row.Status = 1
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	kefuClearAutoReplyCache(h.D.RDB, []string{row.Lang})
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuAutoReplyAdminSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body kefuAutoReplyBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	u := int64(uid)
	var prev kefumodel.KefuAutoReply
	if err := h.D.DBx(h.C).Where("id = ? AND created_by = ?", id, uid).First(&prev).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("not found"))
		return
	}
	up := map[string]any{"updated_by": u}
	if body.Title != "" {
		up["title"] = body.Title
	}
	if body.TriggerType != nil {
		up["trigger_type"] = *body.TriggerType
	}
	if len(body.Keywords) > 0 {
		up["keywords"] = body.Keywords
	}
	if body.ReplyType != nil {
		up["reply_type"] = *body.ReplyType
	}
	if len(body.ReplyContent) > 0 {
		up["reply_content"] = body.ReplyContent
	}
	if body.Lang != "" {
		up["lang"] = body.Lang
	}
	if body.Priority != nil {
		up["priority"] = *body.Priority
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if err := h.D.DBx(h.C).Model(&kefumodel.KefuAutoReply{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	toClear := []string{prev.Lang}
	if body.Lang != "" && body.Lang != prev.Lang {
		toClear = append(toClear, body.Lang)
	}
	kefuClearAutoReplyCache(h.D.RDB, toClear)
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuAutoReplyAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	uid := middleware.UserID(h.C)
	var langs []string
	_ = h.D.DBx(h.C).Model(&kefumodel.KefuAutoReply{}).Where("id IN ? AND created_by = ?", ids, uid).Pluck("lang", &langs).Error
	if err := h.D.DBx(h.C).Where("id IN ? AND created_by = ?", ids, uid).Delete(&kefumodel.KefuAutoReply{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	kefuClearAutoReplyCache(h.D.RDB, langs)
	response.JSON(h.C, 200, response.OK(nil))
}

func kefuClearAutoReplyCache(rdb *redis.Client, langs []string) {
	if rdb == nil {
		return
	}
	ctx := context.Background()
	seen := map[string]struct{}{}
	for _, l := range langs {
		l = strings.TrimSpace(l)
		if l == "" {
			continue
		}
		if _, ok := seen[l]; ok {
			continue
		}
		seen[l] = struct{}{}
		_ = rdb.Del(ctx, autoReplyRulesCachePrefix+l).Err()
	}
}
