package model

import (
	"time"

	"gorm.io/datatypes"
)

// SearchIndex 对应表 search_index。
type SearchIndex struct {
	ID         int64          `json:"id,omitempty" gorm:"primaryKey;autoIncrement"`
	TargetType string         `json:"target_type" gorm:"size:50;column:target_type"`
	TargetID   int64          `json:"target_id" gorm:"column:target_id"`
	Title      string         `json:"title" gorm:"size:200"`
	Content    *string        `json:"content,omitempty" gorm:"size:100"`
	Keyword    datatypes.JSON `json:"keyword,omitempty" gorm:"column:keyword;type:json"`
	Tags       datatypes.JSON `json:"tags,omitempty" gorm:"column:tags;type:json"`
	Weight     int            `json:"weight" gorm:"default:0"`
	ClickCount int            `json:"click_count" gorm:"column:click_count;default:0"`
	LastAt     *time.Time     `json:"last_at,omitempty" gorm:"column:last_at"`
}

func (SearchIndex) TableName() string {
	return P + "search_index"
}
