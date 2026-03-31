package deps

import (
	"context"
	"fastapp/internal/config"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"
)

// WebSocketHub 可选依赖：HTTP 与 WS 同进程时由 main 注入，供业务侧推送（如 sysKefu）。
type WebSocketHub interface {
	PushToUsers(ctx context.Context, rdb *redis.Client, userKeys []string, data map[string]any, event string)
}

// JWTProvider admin / api 场景的 JWT 能力（由 internal/app/common 的 Service 实现）。
type JWTProvider interface {
	ParseAccess(tokenStr string) (*jwt.Token, int64, error)
	ParseRefresh(tokenStr string) (*jwt.Token, int64, error)
	IssuePair(userID int64) (access, refresh string, ttlSec int, err error)
	AddBlacklist(tokenStr string) error
}

// Deps HTTP 层依赖（DB/Redis/JWT）
type Deps struct {
	Config config.Config
	DB     *gorm.DB
	RDB    *redis.Client
	JWT    JWTProvider // admin default 场景
	JWTAPI JWTProvider // api 场景
	// UploadDir 本地附件根目录，用于上传与 /uploads 静态访问。
	UploadDir string
	WSHub     WebSocketHub
}

// DBx 使用当前请求的 context 访问 DB，便于 GORM 日志带上 HTTP 路由（需配合 middleware.RequestRouteContext）。
func (d *Deps) DBx(c *gin.Context) *gorm.DB {
	if d == nil || d.DB == nil {
		return nil
	}
	if c == nil || c.Request == nil {
		return d.DB
	}
	return d.DB.WithContext(c.Request.Context())
}

// HandlerCtx 将 Deps 与当前请求上下文一并传入业务 handler，避免重复的闭包包装。
type HandlerCtx struct {
	D *Deps
	C *gin.Context
}

// Bind 将 func(*HandlerCtx) 适配为 gin.HandlerFunc；由路由注册处传入已构造的 d。
func Bind(d *Deps, fn func(*HandlerCtx)) gin.HandlerFunc {
	return func(c *gin.Context) {
		fn(&HandlerCtx{D: d, C: c})
	}
}
