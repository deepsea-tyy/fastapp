package model

import "time"

// SearchKeyword 对应表 search_keyword（无 created_at / updated_at 列）。
type SearchKeyword struct {
	ID             int64      `json:"id" gorm:"primaryKey;autoIncrement"`
	Keyword        string     `json:"keyword" gorm:"size:32;column:keyword;uniqueIndex"`
	HitCount       int        `json:"hit_count" gorm:"column:hit_count;default:1"`
	Icon           *string    `json:"icon,omitempty" gorm:"size:64"`
	Color          *string    `json:"color,omitempty" gorm:"size:20"`
	Source         int        `json:"source" gorm:"default:1"`
	Sort           int        `json:"sort" gorm:"default:0"`
	LastSearchedAt *time.Time `json:"last_searched_at,omitempty" gorm:"column:last_searched_at"`
}

func (SearchKeyword) TableName() string {
	return P + "search_keyword"
}
