package model

import (
	"encoding/json"
	"time"

	basemodel "fastapp/internal/app/model"
)

// SystemConfig 表 system_config（插件 ds/sysConfig）。
type SystemConfig struct {
	ID               int64           `gorm:"primaryKey"`
	GroupCode        string          `gorm:"column:group_code;size:64"`
	Key              string          `gorm:"column:key;size:32"`
	Value            json.RawMessage `gorm:"type:json"`
	Name             json.RawMessage `gorm:"type:json"`
	InputType        string          `gorm:"column:input_type;size:32"`
	ConfigSelectData json.RawMessage `gorm:"column:config_select_data;type:json"`
	Sort             int             `gorm:"column:sort"`
	Remark           string          `gorm:"size:255"`
	CreatedBy        int64           `gorm:"column:created_by"`
	UpdatedBy        int64           `gorm:"column:updated_by"`
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

func (SystemConfig) TableName() string {
	return basemodel.P + "system_config"
}

// SystemConfigGroup 表 system_config_group。
type SystemConfigGroup struct {
	ID        int64           `gorm:"primaryKey"`
	Name      json.RawMessage `gorm:"type:json"`
	Code      string          `gorm:"size:64"`
	Icon      string          `gorm:"size:128"`
	Remark    string          `gorm:"size:255"`
	CreatedBy int64           `gorm:"column:created_by"`
	UpdatedBy int64           `gorm:"column:updated_by"`
	CreatedAt time.Time
	UpdatedAt time.Time
}

func (SystemConfigGroup) TableName() string {
	return basemodel.P + "system_config_group"
}
