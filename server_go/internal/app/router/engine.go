package router

import (
	"log/slog"
	"net/http"
	"os"

	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/middleware"

	"github.com/gin-gonic/gin"
)

// Config 路由总配置：有 Deps 时挂载核心 Endpoints + PluginEndpoints（同源 Endpoint；MenuPerm 仅 KindAdminJWT）。
type Config struct {
	Deps            *deps.Deps
	PluginEndpoints []Endpoint
}

// New 构建 Gin：全局中间件 → 静态路由 →（有 Deps 时）核心 Endpoints 与插件 HTTP。
func New(cfg Config) *gin.Engine {
	if os.Getenv("APP_ENV") == "prod" {
		gin.SetMode(gin.ReleaseMode)
	}
	e := gin.New()
	e.Use(gin.Recovery())
	e.Use(middleware.AdminOperationLog(cfg.Deps))
	e.Use(middleware.RequestRouteContext())
	e.Use(middleware.RequestHeader())
	e.Use(middleware.Translation())
	e.Use(middleware.ValidatorHook())
	e.Use(middleware.CORS())
	e.Use(middleware.AccessSlog())

	e.GET("/", func(c *gin.Context) {
		c.String(http.StatusOK, "welcome use fastapp")
	})
	e.GET("/favicon.ico", func(c *gin.Context) {
		c.Status(http.StatusOK)
	})
	e.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok"})
	})

	if cfg.Deps != nil && cfg.Deps.UploadDir != "" {
		e.Static("/uploads", cfg.Deps.UploadDir)
	}

	if cfg.Deps != nil {
		registerCoreRoutes(cfg.Deps, e, cfg.PluginEndpoints)
	}
	return e
}

func registerCoreRoutes(d *deps.Deps, e *gin.Engine, pluginEPs []Endpoint) {
	if d == nil || d.DB == nil {
		slog.Warn("core routes skipped: no database")
		return
	}
	merged := append(Endpoints(), pluginEPs...)
	for _, ep := range merged {
		if ep.Auth == KindAPIJWT && d.JWTAPI == nil {
			continue
		}
		if ep.Auth == KindAPIJWT && ep.MenuPerm != "" {
			slog.Warn("registerCoreRoutes: MenuPerm is ignored for KindAPIJWT", "method", ep.Method, "path", ep.Path, "menuPerm", ep.MenuPerm)
		}
		h := ep.Handler(d)
		switch ep.Auth {
		case KindPublic:
			e.Handle(ep.Method, ep.Path, h)
		case KindAdminJWT:
			mw := []gin.HandlerFunc{middleware.RequireAdminJWT(d)}
			if ep.MenuPerm != "" {
				mw = append(mw, middleware.RequireAdminMenuPerm(d, ep.MenuPerm))
			}
			mw = append(mw, h)
			e.Handle(ep.Method, ep.Path, mw...)
		case KindAPIJWT:
			e.Handle(ep.Method, ep.Path, middleware.RequireAPIJWT(d), h)
		}
	}
}
