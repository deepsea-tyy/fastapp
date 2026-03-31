package middleware

import (
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"

	"github.com/gin-gonic/gin"
)

const CtxUserID = "jwt_user_id"

// RequireAdminJWT 解析 admin（default）场景 access token
func RequireAdminJWT(d *deps.Deps) gin.HandlerFunc {
	return func(c *gin.Context) {
		if d == nil || d.JWT == nil {
			response.JSON(c, 200, response.Fail("jwt not configured"))
			c.Abort()
			return
		}
		raw := strings.TrimPrefix(c.GetHeader("Authorization"), "Bearer ")
		raw = strings.TrimSpace(raw)
		if raw == "" {
			response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "", nil))
			c.Abort()
			return
		}
		_, uid, err := d.JWT.ParseAccess(raw)
		if err != nil {
			if err == tools.ErrBlacklisted {
				response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "token revoked", nil))
			} else {
				response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "invalid token", nil))
			}
			c.Abort()
			return
		}
		c.Set(CtxUserID, uid)
		c.Next()
	}
}

func UserID(c *gin.Context) int64 {
	v, ok := c.Get(CtxUserID)
	if !ok {
		return 0
	}
	id, _ := v.(int64)
	return id
}

// RequireAPIJWT 解析 api 场景 access token
func RequireAPIJWT(d *deps.Deps) gin.HandlerFunc {
	return func(c *gin.Context) {
		if d == nil || d.JWTAPI == nil {
			response.JSON(c, 200, response.Fail("jwt api not configured"))
			c.Abort()
			return
		}
		raw := strings.TrimPrefix(c.GetHeader("Authorization"), "Bearer ")
		raw = strings.TrimSpace(raw)
		if raw == "" {
			response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "", nil))
			c.Abort()
			return
		}
		_, uid, err := d.JWTAPI.ParseAccess(raw)
		if err != nil {
			if err == tools.ErrBlacklisted {
				response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "token revoked", nil))
			} else {
				response.JSON(c, 200, response.WithCode(response.CodeUnauthorized, "invalid token", nil))
			}
			c.Abort()
			return
		}
		c.Set(CtxUserID, uid)
		c.Next()
	}
}
