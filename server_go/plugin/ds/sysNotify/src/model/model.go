package model

import (
	"encoding/json"
	"time"

	basemodel "fastapp/internal/app/model"
)

// MessageNotify 表 message_notify。
type MessageNotify struct {
	ID         int64           `gorm:"primaryKey"`
	Title      json.RawMessage `gorm:"type:json"`
	Content    json.RawMessage `gorm:"type:json"`
	Type       int             `gorm:"column:type"`
	UserID     int64           `gorm:"column:user_id"`
	NotifyType int             `gorm:"column:notify_type"`
	Link       string          `gorm:"size:512"`
	CreatedBy  int64           `gorm:"column:created_by"`
	UpdatedBy  int64           `gorm:"column:updated_by"`
	CreatedAt  time.Time
	UpdatedAt  time.Time
}

func (MessageNotify) TableName() string {
	return basemodel.P + "message_notify"
}

// MessageNotifyRead 表 message_notify_read。
type MessageNotifyRead struct {
	ID         int64 `gorm:"primaryKey;autoIncrement"`
	NotifyType int64 `gorm:"column:notify_type"`
	NotifyID   int64 `gorm:"column:notify_id"`
	UserID     int64 `gorm:"column:user_id"`
}

func (MessageNotifyRead) TableName() string {
	return basemodel.P + "message_notify_read"
}
