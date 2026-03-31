package middleware

import (
	"context"

	"github.com/gin-gonic/gin"
)

type httpRouteCtxKey struct{}

// WithHTTPRoute 将「METHOD 路径」写入 context（与 RequestRouteContext 中间件使用同一键）。
func WithHTTPRoute(ctx context.Context, method, path string) context.Context {
	if ctx == nil {
		ctx = context.Background()
	}
	return context.WithValue(ctx, httpRouteCtxKey{}, method+" "+path)
}

// HTTPRouteFromContext 返回当前请求的路由描述；未经过 RequestRouteContext / WithHTTPRoute 时为空。
func HTTPRouteFromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	s, _ := ctx.Value(httpRouteCtxKey{}).(string)
	return s
}

// RequestRouteContext 把当前 HTTP 方法 + 路由模板写入 Request.Context()，供 GORM 日志等读取。
func RequestRouteContext() gin.HandlerFunc {
	return func(c *gin.Context) {
		path := c.FullPath()
		if path == "" {
			path = c.Request.URL.Path
		}
		c.Request = c.Request.WithContext(WithHTTPRoute(c.Request.Context(), c.Request.Method, path))
		c.Next()
	}
}
