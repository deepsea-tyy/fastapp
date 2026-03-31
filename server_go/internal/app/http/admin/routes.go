package admin

import (
	"context"
	"encoding/base64"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/captcha"
	"fastapp/internal/app/service/menu"

	"github.com/gin-gonic/gin"
)

// 以下为 router.Endpoints 引用的 Controller 工厂（路由表见 internal/app/router/endpoints.go）。

type passportLoginBody struct {
	Username      string `json:"username" binding:"required"`
	Password      string `json:"password" binding:"required"`
	Code          string `json:"code"`
	Google2faCode string `json:"google2fa_code"`
}

func PassportLogin(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWT == nil {
			response.JSON(h.C, 200, response.Fail("jwt not configured"))
			return
		}
		var body passportLoginBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if tools.IsProd() {
			if h.D.RDB == nil {
				response.JSON(h.C, 200, response.Fail("redis unavailable"))
				return
			}
			ip := h.C.ClientIP()
			key := tools.CaptchaKey(ip)
			stored, err := h.D.RDB.Get(context.Background(), key).Result()
			if err != nil || stored == "" || strings.ToLower(stored) != strings.ToLower(body.Code) {
				response.JSON(h.C, 200, response.Fail("captcha invalid"))
				return
			}
			_ = h.D.RDB.Del(context.Background(), key).Err()
		}

		var u model.User
		err := h.D.DBx(h.C).Where("username = ? AND user_type IN ?", body.Username, []any{model.UserTypeSystem, 100}).First(&u).Error
		if err != nil || !u.VerifyPassword(body.Password) {
			response.JSON(h.C, 200, response.Fail("password error"))
			return
		}
		if u.Status == model.UserStatusDisable {
			response.JSON(h.C, 200, response.WithCode(response.CodeDisabled, "disabled", nil))
			return
		}
		if strings.TrimSpace(u.Google2fa) != "" && strings.TrimSpace(body.Google2faCode) == "" {
			response.JSON(h.C, 200, response.OK(map[string]any{"verify_again": "google2fa_code"}))
			return
		}
		if strings.TrimSpace(u.Google2fa) != "" {
			if !tools.Validate(u.Google2fa, body.Google2faCode, 1) {
				response.JSON(h.C, 200, response.Fail("google2fa invalid"))
				return
			}
		}
		access, refresh, ttl, err := h.D.JWT.IssuePair(u.ID)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("token issue failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{
			"access_token":  access,
			"refresh_token": refresh,
			"expire_at":     ttl,
		}))
	})
}

func PassportCaptcha(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if tools.IsProd() && h.D.RDB == nil {
			response.JSON(h.C, 200, response.Fail("redis unavailable"))
			return
		}
		if !tools.IsProd() && h.D.RDB == nil {
			response.JSON(h.C, 200, response.OK(map[string]any{"image": ""}))
			return
		}
		code := captcha.RandomCode(4)
		pngBytes, err := captcha.PNG(code)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("captcha render failed"))
			return
		}
		ip := h.C.ClientIP()
		key := tools.CaptchaKey(ip)
		if err := h.D.RDB.Set(context.Background(), key, code, 300*time.Second).Err(); err != nil {
			if tools.IsProd() {
				response.JSON(h.C, 200, response.Fail("redis unavailable"))
				return
			}
		}
		data := map[string]any{"image": "data:image/png;base64," + base64.StdEncoding.EncodeToString(pngBytes)}
		if !tools.IsProd() {
			data["_code"] = code
		}
		response.JSON(h.C, 200, response.OK(data))
	})
}

func PassportRefresh(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWT == nil {
			response.JSON(h.C, 200, response.Fail("jwt not configured"))
			return
		}
		rt := h.C.Query("refresh_token")
		if rt == "" {
			response.JSON(h.C, 200, response.Fail("refresh_token required"))
			return
		}
		_, uid, err := h.D.JWT.ParseRefresh(rt)
		if err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnauthorized, "invalid refresh", nil))
			return
		}
		_ = h.D.JWT.AddBlacklist(rt)
		access, refresh, ttl, err := h.D.JWT.IssuePair(uid)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("token issue failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{
			"access_token":  access,
			"refresh_token": refresh,
			"expire_at":     ttl,
		}))
	})
}

func PassportLogout(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		raw := strings.TrimPrefix(h.C.GetHeader("Authorization"), "Bearer ")
		raw = strings.TrimSpace(raw)
		if raw != "" {
			_ = h.D.JWT.AddBlacklist(raw)
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PassportGetInfo(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var u2 model.User
		if err := h.D.DBx(h.C).Select("id", "username", "mobile", "email", "code", "google2fa").First(&u2, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		var prof model.UserProfile
		_ = h.D.DBx(h.C).Where("user_id = ?", uid).First(&prof).Error
		data := map[string]any{
			"id":           u2.ID,
			"username":     u2.Username,
			"mobile":       u2.Mobile,
			"email":        u2.Email,
			"code":         u2.Code,
			"google2fa":    u2.Google2fa,
			"is_google2fa": 0,
			"nickname":     prof.Nickname,
			"avatar":       prof.Avatar,
		}
		if u2.Google2fa != "" {
			data["is_google2fa"] = 1
		}
		response.JSON(h.C, 200, response.OK(data))
	})
}

func PermissionMenus(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		super, err := middleware.IsSuperAdmin(h.D.DBx(h.C), uid)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("db error"))
			return
		}
		var flat []model.Menu
		q := h.D.DBx(h.C).Model(&model.Menu{}).Where("status = ?", 1).Order("sort asc")
		if !super {
			sql := `SELECT DISTINCT m.name AS name FROM ` + model.P + `menu m
			INNER JOIN ` + model.P + `role_belongs_menu rm ON rm.menu_id = m.id
			INNER JOIN ` + model.P + `role r ON r.id = rm.role_id AND r.status = ?
			INNER JOIN ` + model.P + `user_belongs_role ur ON ur.role_id = r.id AND ur.user_id = ?
			WHERE m.status = ?`
			var nrows []struct{ Name string }
			if err := h.D.DBx(h.C).Raw(sql, 1, uid, 1).Scan(&nrows).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("menu permission query failed"))
				return
			}
			if len(nrows) == 0 {
				response.JSON(h.C, 200, response.OK([]any{}))
				return
			}
			names := make([]string, 0, len(nrows))
			for _, r := range nrows {
				names = append(names, r.Name)
			}
			q = q.Where("name IN ?", names)
		}
		if err := q.Find(&flat).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("menu query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(menu.BuildTree(flat)))
	})
}

func PermissionRoles(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		super, _ := middleware.IsSuperAdmin(h.D.DBx(h.C), uid)
		var roles []model.Role
		q := h.D.DBx(h.C).Model(&model.Role{}).Where("status = ?", 1).Order("sort asc")
		if !super {
			q = q.Joins("JOIN "+model.P+"user_belongs_role ON "+model.P+"user_belongs_role.role_id = "+model.P+"role.id").
				Where(model.P+"user_belongs_role.user_id = ?", uid)
		}
		if err := q.Find(&roles).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("role query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(roles))
	})
}
