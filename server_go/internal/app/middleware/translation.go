package middleware

import (
	"fastapp/internal/app/i18n"

	"github.com/gin-gonic/gin"
)

// Translation 解析 Accept-Language，仅保留 en / zh_CN。
func Translation() gin.HandlerFunc {
	return func(c *gin.Context) {
		loc := i18n.NormalizeLocale(c.GetHeader("Accept-Language"))
		c.Set(i18n.ContextLocaleKey, loc)
		c.Next()
	}
}

func Locale(c *gin.Context) string {
	return i18n.FromGin(c)
}
