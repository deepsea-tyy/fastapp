package ws

import (
	"context"
	"encoding/json"
	"regexp"
	"strconv"
	"strings"
	"time"

	"fastapp/internal/app/common/deps"
	appws "fastapp/internal/websocket"
	kefumodel "fastapp/plugin/ds/sysKefu/src/model"

	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

// 。
const autoReplyRulesRedisPrefix = "kefu:auto_reply:rules:"

const autoReplyThrottleRedisPrefix = "kefu:auto_reply:throttle:"

const autoReplyRulesCacheTTL = 300 * time.Second

// FetchEnabledAutoReplyRules 。
func FetchEnabledAutoReplyRules(ctx context.Context, db *gorm.DB, rdb *redis.Client, lang string) ([]kefumodel.KefuAutoReply, error) {
	lang = strings.TrimSpace(lang)
	if lang == "" {
		lang = "zh_CN"
	}
	if db == nil {
		return nil, nil
	}
	key := autoReplyRulesRedisPrefix + lang
	if rdb != nil {
		if s, err := rdb.Get(ctx, key).Result(); err == nil && s != "" {
			var rules []kefumodel.KefuAutoReply
			if json.Unmarshal([]byte(s), &rules) == nil {
				return rules, nil
			}
		}
	}
	var rules []kefumodel.KefuAutoReply
	if err := db.WithContext(ctx).Where("status = ? AND lang = ?", kefumodel.AutoReplyStatusEnabled, lang).
		Order("priority DESC, id ASC").Find(&rules).Error; err != nil {
		return nil, err
	}
	if rdb != nil && len(rules) > 0 {
		if b, err := json.Marshal(rules); err == nil {
			_ = rdb.Set(ctx, key, string(b), autoReplyRulesCacheTTL).Err()
		}
	}
	return rules, nil
}

func tryKefuAutoReply(ctx context.Context, d *deps.Deps, hub *appws.Hub, conversationID, userID int64, userMessage, lang string) {
	if d == nil || d.DB == nil || hub == nil || d.RDB == nil {
		return
	}
	msg := strings.TrimSpace(userMessage)
	if msg == "" {
		return
	}
	lang = strings.TrimSpace(lang)
	if lang == "" {
		lang = "zh_CN"
	}

	cfg, err := LoadKefuSysConfig(ctx, d.DB)
	if err != nil {
		return
	}
	if !cfg.AutoReplyEnabled {
		return
	}

	var conv kefumodel.KefuConversation
	if err := d.DB.WithContext(ctx).Where("id = ?", conversationID).First(&conv).Error; err != nil {
		return
	}

	if !cfg.IsKefuWorkTime(time.Now()) {
		text := strings.TrimSpace(cfg.offlineText(lang))
		if text == "" {
			return
		}
		sendKefuAutoReplyOffline(ctx, d, hub, &conv, userID, text, lang)
		return
	}

	rules, err := FetchEnabledAutoReplyRules(ctx, d.DB, d.RDB, lang)
	if err != nil || len(rules) == 0 {
		return
	}
	var matched *kefumodel.KefuAutoReply
	for i := range rules {
		if kefuRuleMatches(&rules[i], msg) {
			matched = &rules[i]
			break
		}
	}
	if matched == nil {
		return
	}

	ruleID := matched.ID
	throttleKey := autoReplyThrottleRedisPrefix + strconv.FormatInt(conversationID, 10) + ":" + strconv.FormatInt(ruleID, 10)
	throttleSec := cfg.AutoReplyThrottleSec
	if throttleSec <= 0 {
		throttleSec = 30
	}
	if ok, _ := d.RDB.SetNX(ctx, throttleKey, "1", time.Duration(throttleSec)*time.Second).Result(); !ok {
		return
	}

	delay := cfg.AutoReplyDelaySec
	if delay > 0 {
		select {
		case <-ctx.Done():
			return
		case <-time.After(time.Duration(delay) * time.Second):
		}
	}

	sendKefuAutoReplyMatched(ctx, d, hub, &conv, userID, matched, msg, lang)
}

func sendKefuAutoReplyOffline(ctx context.Context, d *deps.Deps, hub *appws.Hub, conv *kefumodel.KefuConversation, userID int64, content, lang string) {
	msgRow := kefumodel.KefuMessage{
		ConversationID:  conv.ID,
		SenderID:        conv.KefuID,
		SenderType:      2,
		Content:         content,
		MessageType:     1,
		IsRead:          0,
		IsAutoReply:     1,
		AutoReplyRuleID: nil,
	}
	if err := d.DB.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		now := time.Now()
		if err := tx.Create(&msgRow).Error; err != nil {
			return err
		}
		return tx.Model(&kefumodel.KefuConversation{}).Where("id = ?", conv.ID).Updates(map[string]any{
			"last_message_at": now,
			"unread_count":    gorm.Expr("unread_count + ?", 1),
			"updated_at":      now,
		}).Error
	}); err != nil {
		return
	}
	pushKefuAutoReplyWS(d, hub, conv, userID, &msgRow)
}

func sendKefuAutoReplyMatched(ctx context.Context, d *deps.Deps, hub *appws.Hub, conv *kefumodel.KefuConversation, userID int64, rule *kefumodel.KefuAutoReply, userMessage, lang string) {
	var replyObj map[string]any
	_ = json.Unmarshal(rule.ReplyContent, &replyObj)
	replyText, _ := replyObj["text"].(string)
	replyText = strings.TrimSpace(replyText)
	if replyText == "" {
		return
	}
	ruleID := rule.ID
	msgRow := kefumodel.KefuMessage{
		ConversationID:  conv.ID,
		SenderID:        conv.KefuID,
		SenderType:      2,
		Content:         replyText,
		MessageType:     1,
		IsRead:          0,
		IsAutoReply:     1,
		AutoReplyRuleID: &ruleID,
	}
	err := d.DB.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		now := time.Now()
		if err := tx.Create(&msgRow).Error; err != nil {
			return err
		}
		if err := tx.Model(&kefumodel.KefuConversation{}).Where("id = ?", conv.ID).Updates(map[string]any{
			"last_message_at": now,
			"unread_count":    gorm.Expr("unread_count + ?", 1),
			"updated_at":      now,
		}).Error; err != nil {
			return err
		}
		um := userMessage
		if len(um) > 500 {
			um = um[:500]
		}
		log := kefumodel.KefuAutoReplyLog{
			ConversationID: conv.ID,
			UserID:         userID,
			KefuID:         &conv.KefuID,
			RuleID:         ruleID,
			UserMessage:    um,
			ReplyContent:   rule.ReplyContent,
			Lang:           lang,
		}
		if err := tx.Create(&log).Error; err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return
	}
	_ = d.DB.WithContext(ctx).Model(&kefumodel.KefuAutoReply{}).Where("id = ?", rule.ID).
		UpdateColumn("hit_count", gorm.Expr("hit_count + ?", 1)).Error
	pushKefuAutoReplyWS(d, hub, conv, userID, &msgRow)
}

func pushKefuAutoReplyWS(d *deps.Deps, hub *appws.Hub, conv *kefumodel.KefuConversation, userID int64, msgRow *kefumodel.KefuMessage) {
	payload := kefuMessageToMap(msgRow)
	payload["form_uid"] = int64(0)
	payload["to_uid"] = userID
	payload["kefu_id"] = conv.KefuID
	payload["message_id"] = msgRow.ID
	pushHub(d, hub, []string{strconv.FormatInt(userID, 10)}, "kefu_message", payload)
}

func kefuRuleMatches(rule *kefumodel.KefuAutoReply, userMessage string) bool {
	var keywords []string
	_ = json.Unmarshal(rule.Keywords, &keywords)
	switch rule.TriggerType {
	case 1:
		for _, k := range keywords {
			if k == userMessage {
				return true
			}
		}
	case 2:
		low := strings.ToLower(userMessage)
		for _, k := range keywords {
			k = strings.TrimSpace(k)
			if k != "" && strings.Contains(low, strings.ToLower(k)) {
				return true
			}
		}
	case kefumodel.AutoReplyTriggerRegex:
		for _, pattern := range keywords {
			pattern = strings.TrimSpace(pattern)
			if pattern == "" {
				continue
			}
			re, err := regexp.Compile(pattern)
			if err != nil {
				continue
			}
			if re.MatchString(userMessage) {
				return true
			}
		}
	}
	return false
}
