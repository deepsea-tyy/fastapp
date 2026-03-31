package model

import (
	"encoding/json"
	"time"

	basemodel "fastapp/internal/app/model"
)

// Kefu 表 kefu。
type Kefu struct {
	ID                int64     `gorm:"primaryKey;autoIncrement"`
	Nickname          string    `gorm:"size:50"`
	Avatar            string    `gorm:"size:255"`
	Status            int       `gorm:"default:1"`
	MaxConcurrent     int       `gorm:"column:max_concurrent;default:0"`
	CurrentConcurrent int       `gorm:"column:current_concurrent;default:0"`
	CreatedBy         *int64    `gorm:"column:created_by"`
	UpdatedBy         *int64    `gorm:"column:updated_by"`
	CreatedAt         time.Time `gorm:"column:created_at"`
	UpdatedAt         time.Time `gorm:"column:updated_at"`
}

func (Kefu) TableName() string {
	return basemodel.P + "kefu"
}

// KefuConversation 表 kefu_conversation。
type KefuConversation struct {
	ID              int64                  `gorm:"primaryKey;autoIncrement"`
	KefuID          int64                  `gorm:"column:kefu_id;index"`
	UserID          int64                  `gorm:"column:user_id;index"`
	Status          int                    `gorm:"default:1"`
	LastMessageAt   *time.Time             `gorm:"column:last_message_at"`
	UnreadCount     int                    `gorm:"column:unread_count;default:0"`
	KefuUnreadCount int                    `gorm:"column:kefu_unread_count;default:0"`
	CreatedAt       time.Time              `gorm:"column:created_at"`
	UpdatedAt       time.Time              `gorm:"column:updated_at"`
	Kefu            *Kefu                  `gorm:"foreignKey:KefuID"`
	Profile         *basemodel.UserProfile `gorm:"foreignKey:UserID;references:UserID"`
}

func (KefuConversation) TableName() string {
	return basemodel.P + "kefu_conversation"
}

// KefuMessage 表 kefu_message。
type KefuMessage struct {
	ID              int64      `gorm:"primaryKey;autoIncrement"`
	ConversationID  int64      `gorm:"column:conversation_id;index"`
	SenderID        int64      `gorm:"column:sender_id;index"`
	SenderType      int        `gorm:"column:sender_type"`
	Content         string     `gorm:"type:text"`
	MessageType     int        `gorm:"column:message_type;default:1"`
	FileURL         *string    `gorm:"column:file_url"`
	IsRead          int        `gorm:"column:is_read;default:0"`
	ReadAt          *time.Time `gorm:"column:read_at"`
	IsAutoReply     int        `gorm:"column:is_auto_reply;default:0"`
	AutoReplyRuleID *int64     `gorm:"column:auto_reply_rule_id"`
	CreatedAt       time.Time  `gorm:"column:created_at"`
	UpdatedAt       time.Time  `gorm:"column:updated_at"`
}

func (KefuMessage) TableName() string {
	return basemodel.P + "kefu_message"
}

// KefuVisitor 表 kefu_visitor。
type KefuVisitor struct {
	ID         int64     `gorm:"primaryKey;autoIncrement"`
	VisitorID  string    `gorm:"column:visitor_id;size:64;index"`
	KefuID     string    `gorm:"column:kefu_id;size:32;index"`
	SenderType int       `gorm:"column:sender_type;default:1"`
	Content    string    `gorm:"type:text"`
	CreatedAt  time.Time `gorm:"column:created_at"`
	UpdatedAt  time.Time `gorm:"column:updated_at"`
}

func (KefuVisitor) TableName() string {
	return basemodel.P + "kefu_visitor"
}

// AutoReplyStatusEnabled 。
const AutoReplyStatusEnabled = 1

// KefuAutoReply 表 kefu_auto_reply。
type KefuAutoReply struct {
	ID           int64           `gorm:"primaryKey;autoIncrement"`
	Title        string          `gorm:"size:100"`
	TriggerType  int             `gorm:"column:trigger_type;default:1"`
	Keywords     json.RawMessage `gorm:"column:keywords;type:json"`
	ReplyType    int             `gorm:"column:reply_type;default:1"`
	ReplyContent json.RawMessage `gorm:"column:reply_content;type:json"`
	Lang         string          `gorm:"size:10;default:zh_CN"`
	Priority     int             `gorm:"default:0"`
	Status       int             `gorm:"default:1"`
	HitCount     int             `gorm:"column:hit_count;default:0"`
	CreatedBy    *int64          `gorm:"column:created_by"`
	UpdatedBy    *int64          `gorm:"column:updated_by"`
	CreatedAt    time.Time       `gorm:"column:created_at"`
	UpdatedAt    time.Time       `gorm:"column:updated_at"`
}

func (KefuAutoReply) TableName() string {
	return basemodel.P + "kefu_auto_reply"
}

// KefuAutoReplyLog 表 kefu_auto_reply_log。
type KefuAutoReplyLog struct {
	ID             int64           `gorm:"primaryKey;autoIncrement"`
	ConversationID int64           `gorm:"column:conversation_id;index"`
	UserID         int64           `gorm:"column:user_id"`
	KefuID         *int64          `gorm:"column:kefu_id"`
	RuleID         int64           `gorm:"column:rule_id;index"`
	UserMessage    string          `gorm:"column:user_message;size:500"`
	ReplyContent   json.RawMessage `gorm:"column:reply_content;type:json"`
	Lang           string          `gorm:"size:10;default:zh_CN"`
	CreatedAt      time.Time       `gorm:"column:created_at"`
	UpdatedAt      time.Time       `gorm:"column:updated_at"`
}

func (KefuAutoReplyLog) TableName() string {
	return basemodel.P + "kefu_auto_reply_log"
}

// AutoReplyTriggerRegex 。
const AutoReplyTriggerRegex = 3
