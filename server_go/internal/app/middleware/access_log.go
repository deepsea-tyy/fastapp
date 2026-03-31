package middleware

import (
	"log/slog"
	"time"

	"github.com/gin-gonic/gin"
)

// AccessSlog 请求结束后打一条结构化访问日志（request_id、user_id、耗时），对齐阶段 0「可观测」基线。管理端与 /api/* 均记录。
func AccessSlog() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		c.Next()
		slog.Info("http",
			"method", c.Request.Method,
			"path", c.Request.URL.Path,
			"status", c.Writer.Status(),
			"duration_ms", time.Since(start).Milliseconds(),
			"request_id", RequestID(c),
			"user_id", UserID(c),
		)
	}
}
