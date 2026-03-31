package middleware

import (
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// IsSuperAdmin 。
func IsSuperAdmin(db *gorm.DB, userID int64) (bool, error) {
	var n int64
	err := db.Table(model.P+"user_belongs_role").
		Joins("JOIN "+model.P+"role ON "+model.P+"role.id = "+model.P+"user_belongs_role.role_id").
		Where(model.P+"user_belongs_role.user_id = ? AND "+model.P+"role.code = ?", userID, "SuperAdmin").
		Count(&n).Error
	return n > 0, err
}

// UserHasMenuByName 当前用户是否具备 menu.name 对应权限：超管直通，否则按角色-菜单关联判定。
func UserHasMenuByName(db *gorm.DB, userID int64, menuName string) (bool, error) {
	if menuName == "" {
		return true, nil
	}
	super, err := IsSuperAdmin(db, userID)
	if err != nil {
		return false, err
	}
	if super {
		return true, nil
	}
	var n int64
	err = db.Table(model.P+"menu m").
		Joins("INNER JOIN "+model.P+"role_belongs_menu rm ON rm.menu_id = m.id").
		Joins("INNER JOIN "+model.P+"role r ON r.id = rm.role_id AND r.status = ?", 1).
		Joins("INNER JOIN "+model.P+"user_belongs_role ur ON ur.role_id = r.id AND ur.user_id = ?", userID).
		Where("m.status = ? AND m.name = ?", 1, menuName).
		Count(&n).Error
	return n > 0, err
}

// CtxMenuPerm 当前路由要求的菜单权限 name，供操作日志作 service_name。
const CtxMenuPerm = "admin_menu_perm"

// RequireAdminMenuPerm 在已通过 RequireAdminJWT 后校验 menu 表 name。
func RequireAdminMenuPerm(d *deps.Deps, menuName string) gin.HandlerFunc {
	return func(c *gin.Context) {
		if menuName == "" {
			c.Next()
			return
		}
		if d == nil || d.DB == nil {
			response.JSON(c, 200, response.Fail("db not configured"))
			c.Abort()
			return
		}
		uid := UserID(c)
		ok, err := UserHasMenuByName(d.DB, uid, menuName)
		if err != nil {
			response.JSON(c, 200, response.Fail("permission check failed"))
			c.Abort()
			return
		}
		if !ok {
			response.JSON(c, 200, response.WithCode(response.CodeForbidden, "forbidden", nil))
			c.Abort()
			return
		}
		c.Set(CtxMenuPerm, menuName)
		c.Next()
	}
}
