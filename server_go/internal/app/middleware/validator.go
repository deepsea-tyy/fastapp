package middleware

import (
	"github.com/gin-gonic/gin"
)

// ValidatorHook 保留占位。校验失败。
func ValidatorHook() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Next()
	}
}
