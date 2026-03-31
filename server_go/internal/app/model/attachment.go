package model

import (
	"time"
)

// Attachment 对应表 attachment。
type Attachment struct {
	ID          int64     `json:"id" gorm:"primaryKey;autoIncrement"`
	StorageMode string    `json:"storage_mode" gorm:"size:20;column:storage_mode;default:local"`
	OriginName  string    `json:"origin_name" gorm:"size:255;column:origin_name"`
	ObjectName  string    `json:"object_name" gorm:"size:50;column:object_name"`
	Hash        string    `json:"hash" gorm:"size:64;column:hash;uniqueIndex"`
	MimeType    string    `json:"mime_type" gorm:"size:255;column:mime_type"`
	Suffix      string    `json:"suffix" gorm:"size:20;column:suffix"`
	SizeByte    int64     `json:"size_byte" gorm:"column:size_byte"`
	SizeInfo    string    `json:"size_info" gorm:"size:50;column:size_info"`
	URL         string    `json:"url" gorm:"size:255;column:url"`
	CreatedBy   *int64    `json:"created_by" gorm:"column:created_by"`
	UpdatedBy   *int64    `json:"updated_by" gorm:"column:updated_by"`
	CreatedAt   time.Time `json:"created_at" gorm:"column:created_at;autoCreateTime"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"column:updated_at;autoUpdateTime"`
	Remark      string    `json:"remark" gorm:"column:remark"`
}

func (Attachment) TableName() string {
	return P + "attachment"
}
