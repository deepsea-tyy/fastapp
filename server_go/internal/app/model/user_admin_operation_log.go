package model

import (
	"time"

	"gorm.io/datatypes"
)

// UserAdminOperationLog 对应表 user_admin_operation_log。
type UserAdminOperationLog struct {
	ID            int64          `gorm:"primaryKey;autoIncrement"`
	Username      string         `gorm:"size:255;column:username"`
	Method        string         `gorm:"size:32;column:method"`
	Router        string         `gorm:"size:512;column:router"`
	ServiceName   string         `gorm:"size:255;column:service_name"`
	IP            string         `gorm:"size:64;column:ip"`
	RequestParams datatypes.JSON `gorm:"column:request_params;type:json"`
	CreatedAt     time.Time      `gorm:"column:created_at;autoCreateTime"`
	UpdatedAt     time.Time      `gorm:"column:updated_at;autoUpdateTime"`
}

func (UserAdminOperationLog) TableName() string {
	return P + "user_admin_operation_log"
}
