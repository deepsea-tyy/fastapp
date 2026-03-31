package middleware

import (
	"crypto/rand"
	"encoding/hex"
	"strings"

	"github.com/gin-gonic/gin"
)

// CtxRequestID Gin Context 键，与 observability / 日志一致。
const CtxRequestID = "request_id"

// RequestID 返回当前请求的 X-Request-Id（无则中间件会生成）。
func RequestID(c *gin.Context) string {
	v, ok := c.Get(CtxRequestID)
	if !ok {
		return ""
	}
	s, _ := v.(string)
	return s
}

// RequestHeader 。
func RequestHeader() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Request.Header.Del("Accept-Encoding")
		c.Writer.Header().Del("Content-Encoding")

		rid := strings.TrimSpace(c.GetHeader("X-Request-Id"))
		if rid == "" {
			b := make([]byte, 16)
			_, _ = rand.Read(b)
			rid = hex.EncodeToString(b)
		}
		c.Writer.Header().Set("X-Request-Id", rid)
		c.Set(CtxRequestID, rid)

		c.Next()
	}
}
