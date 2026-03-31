package model

import (
	"time"

	"golang.org/x/crypto/bcrypt"
)

// User 对应表 user（系统后台账号）
type User struct {
	ID        int64     `gorm:"primaryKey"`
	Username  string    `gorm:"size:255"`
	Email     string    `gorm:"size:255"`
	Code      int       `gorm:"column:code"`
	Mobile    string    `gorm:"size:255"`
	Password  string    `gorm:"size:255;column:password"`
	UserType  string    `gorm:"column:user_type;size:32"`
	Status    int       `gorm:"column:status"`
	Google2fa string    `gorm:"column:google2fa;size:255"`
	Remark    string    `gorm:"size:255"`
	CreatedBy int64     `gorm:"column:created_by"`
	UpdatedBy int64     `gorm:"column:updated_by"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (User) TableName() string {
	return P + "user"
}

func (u *User) VerifyPassword(plain string) bool {
	if u.Password == "" {
		return false
	}
	return bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(plain)) == nil
}

const UserTypeSystem = "100"
const UserTypeUser = "200"
const UserStatusNormal = 1
const UserStatusDisable = 2
