package model

import (
	"encoding/json"
	"time"
)

// Menu 对应 menu 表；meta 为 JSON，此处用 json.RawMessage 透传
type Menu struct {
	ID        int64           `gorm:"primaryKey"`
	ParentID  int64           `gorm:"column:parent_id"`
	Name      string          `gorm:"size:255"`
	Component string          `gorm:"size:512"`
	Redirect  string          `gorm:"size:512"`
	Path      string          `gorm:"size:512"`
	Status    int             `gorm:"column:status"`
	Meta      json.RawMessage `gorm:"type:json"`
	Sort      int             `gorm:"column:sort"`
	Remark    string          `gorm:"size:255"`
	CreatedBy int64           `gorm:"column:created_by"`
	UpdatedBy int64           `gorm:"column:updated_by"`
	CreatedAt time.Time       `gorm:"column:created_at"`
	UpdatedAt time.Time       `gorm:"column:updated_at"`
}

func (Menu) TableName() string {
	return P + "menu"
}
