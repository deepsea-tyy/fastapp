package model

import "time"

type Role struct {
	ID        int64     `gorm:"primaryKey"`
	Name      string    `gorm:"size:255"`
	Code      string    `gorm:"size:255"`
	DataScope int       `gorm:"column:data_scope"`
	Status    int       `gorm:"column:status"`
	Sort      int       `gorm:"column:sort"`
	Remark    string    `gorm:"size:255"`
	CreatedBy int64     `gorm:"column:created_by"`
	UpdatedBy int64     `gorm:"column:updated_by"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (Role) TableName() string {
	return P + "role"
}

type UserBelongsRole struct {
	ID     int64 `gorm:"primaryKey;autoIncrement"`
	UserID int64 `gorm:"column:user_id;uniqueIndex:uk_user_role,priority:1"`
	RoleID int64 `gorm:"column:role_id;uniqueIndex:uk_user_role,priority:2"`
}

func (UserBelongsRole) TableName() string {
	return P + "user_belongs_role"
}

type RoleBelongsMenu struct {
	ID     int64 `gorm:"primaryKey;autoIncrement"`
	RoleID int64 `gorm:"column:role_id;uniqueIndex:uk_role_menu,priority:1"`
	MenuID int64 `gorm:"column:menu_id;uniqueIndex:uk_role_menu,priority:2"`
}

func (RoleBelongsMenu) TableName() string {
	return P + "role_belongs_menu"
}
