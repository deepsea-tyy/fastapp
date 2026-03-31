package middleware

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log/slog"
	"net/http"
	"strings"

	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
)

var opSensitiveKeys = []string{
	"password", "pwd", "passwd", "token", "secret", "api_key", "api_secret",
}

// AdminOperationLog 管理端写操作审计（user_admin_operation_log）。App 接口均在 /api/*：不写操作日志、不 peek body。
func AdminOperationLog(d *deps.Deps) gin.HandlerFunc {
	return func(c *gin.Context) {
		if strings.HasPrefix(c.Request.URL.Path, "/api/") {
			c.Next()
			return
		}
		var bodyMap map[string]any
		if d != nil && d.DB != nil && shouldPeekAdminJSONBody(c) {
			bodyMap = peekJSONBody(c)
		}
		c.Next()
		if d == nil || d.DB == nil {
			return
		}
		uid := UserID(c)
		if uid == 0 {
			return
		}
		st := c.Writer.Status()
		if st < http.StatusOK || st >= http.StatusMultipleChoices {
			return
		}
		if !shouldRecordAdminOp(c) {
			return
		}
		path := c.FullPath()
		if path == "" {
			path = c.Request.URL.Path
		}
		serviceName := c.GetString(CtxMenuPerm)
		if serviceName == "" {
			parts := strings.Split(strings.Trim(path, "/"), "/")
			tail := ""
			if len(parts) > 0 {
				tail = parts[len(parts)-1]
			}
			serviceName = c.Request.Method + " " + tail
		}
		params := mergeOpParams(c, bodyMap)
		sanitizeOpParams(params)

		go saveAdminOperationLog(context.Background(), d, uid, c.Request.Method, path, c.ClientIP(), serviceName, params)
	}
}

func shouldPeekAdminJSONBody(c *gin.Context) bool {
	p := c.Request.URL.Path
	if !strings.HasPrefix(p, "/admin/") && !strings.HasPrefix(p, "/attachment/") && !strings.HasPrefix(p, "/system/") {
		return false
	}
	if strings.HasPrefix(p, "/admin/passport/") {
		return false
	}
	ct := strings.ToLower(c.GetHeader("Content-Type"))
	if !strings.Contains(ct, "application/json") {
		return false
	}
	switch c.Request.Method {
	case http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete:
		return true
	default:
		return false
	}
}

func shouldRecordAdminOp(c *gin.Context) bool {
	p := c.Request.URL.Path
	if !strings.HasPrefix(p, "/admin/") && !strings.HasPrefix(p, "/attachment/") && !strings.HasPrefix(p, "/system/") {
		return false
	}
	switch c.Request.Method {
	case http.MethodPost, http.MethodPut, http.MethodPatch, http.MethodDelete:
	default:
		return false
	}
	if strings.HasPrefix(p, "/admin/passport/") {
		return false
	}
	return true
}

func peekJSONBody(c *gin.Context) map[string]any {
	if c.Request.Body == nil {
		return nil
	}
	b, err := io.ReadAll(c.Request.Body)
	if err != nil {
		return nil
	}
	c.Request.Body = io.NopCloser(bytes.NewReader(b))
	var m map[string]any
	if json.Unmarshal(b, &m) != nil {
		return nil
	}
	return m
}

func mergeOpParams(c *gin.Context, body map[string]any) map[string]any {
	out := make(map[string]any)
	for k, v := range c.Request.URL.Query() {
		if len(v) == 1 {
			out[k] = v[0]
		} else {
			out[k] = v
		}
	}
	for k, v := range body {
		out[k] = v
	}
	return out
}

func sanitizeOpParams(m map[string]any) {
	if m == nil {
		return
	}
	for _, key := range opSensitiveKeys {
		if _, ok := m[key]; ok {
			m[key] = "***"
		}
	}
}

func saveAdminOperationLog(ctx context.Context, d *deps.Deps, userID int64, method, router, ip, serviceName string, params map[string]any) {
	defer func() {
		if r := recover(); r != nil {
			slog.Error("admin_operation_log panic", "recover", r)
		}
	}()
	var u model.User
	if err := d.DB.WithContext(ctx).Select("username").Where("id = ?", userID).First(&u).Error; err != nil || u.Username == "" {
		return
	}
	raw, err := json.Marshal(params)
	if err != nil {
		raw = []byte("{}")
	}
	row := model.UserAdminOperationLog{
		Username:      u.Username,
		Method:        method,
		Router:        router,
		ServiceName:   serviceName,
		IP:            ip,
		RequestParams: datatypes.JSON(raw),
	}
	if err := d.DB.WithContext(ctx).Create(&row).Error; err != nil {
		slog.Error("admin_operation_log insert", "err", err)
	}
}
