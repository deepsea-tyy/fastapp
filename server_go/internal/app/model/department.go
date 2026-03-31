package model

import "time"

// Department 对应 department 表
type Department struct {
	ID        int64     `gorm:"primaryKey"`
	Name      string    `gorm:"size:50"`
	Code      string    `gorm:"size:50"`
	ParentID  int64     `gorm:"column:parent_id"`
	Sort      int       `gorm:"column:sort"`
	Status    int       `gorm:"column:status"`
	Remark    string    `gorm:"size:255"`
	CreatedBy int64     `gorm:"column:created_by"`
	UpdatedBy int64     `gorm:"column:updated_by"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (Department) TableName() string {
	return P + "department"
}

// RoleBelongsDepartment 对应 role_belongs_department（角色自定义数据权限部门）
type RoleBelongsDepartment struct {
	ID     int64 `gorm:"primaryKey"`
	RoleID int64 `gorm:"column:role_id"`
	DeptID int64 `gorm:"column:dept_id"`
}

func (RoleBelongsDepartment) TableName() string {
	return P + "role_belongs_department"
}
