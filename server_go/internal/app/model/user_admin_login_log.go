package model

import "time"

// UserAdminLoginLog 对应表 user_admin_login_log（无 GORM 时间戳列）。
type UserAdminLoginLog struct {
	ID        int64     `gorm:"primaryKey;autoIncrement"`
	Username  string    `gorm:"size:20;column:username"`
	IP        *string   `gorm:"size:64;column:ip"`
	OS        *string   `gorm:"size:255;column:os"`
	Browser   *string   `gorm:"size:255;column:browser"`
	Status    int16     `gorm:"column:status;default:1"`
	Message   *string   `gorm:"size:50;column:message"`
	LoginTime time.Time `gorm:"column:login_time"`
	Remark    *string   `gorm:"size:255;column:remark"`
}

func (UserAdminLoginLog) TableName() string {
	return P + "user_admin_login_log"
}
