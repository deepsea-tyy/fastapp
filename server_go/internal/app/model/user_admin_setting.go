package model

import "gorm.io/datatypes"

// UserAdminSetting 对应 user_admin_setting
type UserAdminSetting struct {
	ID             int64          `gorm:"primaryKey"`
	UserID         int64          `gorm:"column:user_id"`
	Phone          string         `gorm:"size:255"`
	DeptID         datatypes.JSON `gorm:"column:dept_id;type:json"`
	BackendSetting datatypes.JSON `gorm:"column:backend_setting;type:json"`
}

func (UserAdminSetting) TableName() string {
	return P + "user_admin_setting"
}
