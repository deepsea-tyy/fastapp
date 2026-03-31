package model

type UserProfile struct {
	UserID        int64  `gorm:"column:user_id;primaryKey"`
	Nickname      string `gorm:"size:255"`
	Avatar        string `gorm:"size:512"`
	Signed        string `gorm:"size:512"`
	Lang          string `gorm:"size:32"`
	TransPassword string `gorm:"column:trans_password;size:255"`
	Setting       string `gorm:"column:setting;type:json"` // JSON 对象，合并更新时自行解析
}

func (UserProfile) TableName() string {
	return P + "user_profile"
}
