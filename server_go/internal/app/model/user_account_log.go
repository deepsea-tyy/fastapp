package model

import "time"

// UserAccountLog 对应 user_account_log
type UserAccountLog struct {
	ID          int64     `gorm:"primaryKey"`
	UserID      int64     `gorm:"column:user_id"`
	Type        int       `gorm:"column:type"`
	IP          string    `gorm:"size:64"`
	OS          string    `gorm:"size:64"`
	DeviceID    string    `gorm:"column:device_id;size:128"`
	CountryCode string    `gorm:"column:country_code;size:16"`
	Country     string    `gorm:"size:64"`
	Region      string    `gorm:"size:64"`
	City        string    `gorm:"size:64"`
	CreatedAt   time.Time `gorm:"column:created_at"`
}

func (UserAccountLog) TableName() string {
	return P + "user_account_log"
}
