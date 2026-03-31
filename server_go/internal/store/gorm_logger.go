package store

import (
	"context"
	"errors"
	"log/slog"
	"strings"
	"time"

	"fastapp/internal/app/middleware"

	"gorm.io/gorm"
	glogger "gorm.io/gorm/logger"
)

// GormLogLevel 将环境变量 `DB_LOG_LEVEL` 解析为 GORM 级别（大小写不敏感）。
func GormLogLevel(raw string) glogger.LogLevel {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "silent", "0":
		return glogger.Silent
	case "error", "1":
		return glogger.Error
	case "warn", "warning", "2":
		return glogger.Warn
	case "info", "debug", "3":
		return glogger.Info
	default:
		return glogger.Warn
	}
}

// routeAwareLogger 在 SQL 报错（尤其 record not found）时附带 HTTP 路由，避免只看到 GORM 源文件行号。
type routeAwareLogger struct {
	inner glogger.Interface
}

func newRouteAwareLogger(inner glogger.Interface) glogger.Interface {
	if inner == nil {
		inner = glogger.Default.LogMode(glogger.Warn)
	}
	return &routeAwareLogger{inner: inner}
}

func (l *routeAwareLogger) LogMode(level glogger.LogLevel) glogger.Interface {
	return &routeAwareLogger{inner: l.inner.LogMode(level)}
}

func (l *routeAwareLogger) Info(ctx context.Context, msg string, data ...interface{}) {
	l.inner.Info(ctx, msg, data...)
}

func (l *routeAwareLogger) Warn(ctx context.Context, msg string, data ...interface{}) {
	l.inner.Warn(ctx, msg, data...)
}

func (l *routeAwareLogger) Error(ctx context.Context, msg string, data ...interface{}) {
	l.inner.Error(ctx, msg, data...)
}

func (l *routeAwareLogger) Trace(ctx context.Context, begin time.Time, fc func() (sql string, rowsAffected int64), err error) {
	if err != nil && errors.Is(err, gorm.ErrRecordNotFound) {
		sqlStr, rows := fc()
		route := middleware.HTTPRouteFromContext(ctx)
		attrs := []any{
			"err", err,
			"rows", rows,
			"elapsed_ms", time.Since(begin).Milliseconds(),
			"sql", sqlStr,
		}
		if route != "" {
			attrs = append(attrs, "route", route)
		}
		slog.Warn("gorm", attrs...)
		return
	}
	l.inner.Trace(ctx, begin, fc, err)
}
