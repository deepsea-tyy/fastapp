package user

import (
	"context"
	"encoding/json"
	"errors"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/verifycode"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func UserLogout(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWTAPI == nil {
			response.JSON(h.C, 200, response.Fail("jwt api not configured"))
			return
		}
		raw := strings.TrimPrefix(h.C.GetHeader("Authorization"), "Bearer ")
		raw = strings.TrimSpace(raw)
		if raw != "" {
			if err := h.D.JWTAPI.AddBlacklist(raw); err != nil {
				// 登出黑名单写入失败不阻塞响应
			}
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func UserInfo(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var u model.User
		if err := h.D.DBx(h.C).Select("id", "username", "mobile", "email", "code", "user_type", "status", "google2fa", "password").
			First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		var prof model.UserProfile
		if err := h.D.DBx(h.C).Where("user_id = ?", uid).First(&prof).Error; err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
			response.JSON(h.C, 200, response.Fail("db error"))
			return
		}

		isGoogle := 0
		if u.Google2fa != "" {
			isGoogle = 1
		}
		isTrans := 0
		if prof.TransPassword != "" {
			isTrans = 1
		}
		isPwd := 0
		if u.Password != "" {
			isPwd = 1
		}

		data := map[string]any{
			"id":                u.ID,
			"username":          u.Username,
			"mobile":            u.Mobile,
			"email":             u.Email,
			"code":              u.Code,
			"user_type":         u.UserType,
			"status":            u.Status,
			"is_google2fa":      isGoogle,
			"is_trans_password": isTrans,
			"is_password":       isPwd,
			"is_kyc":            0,
			"nickname":          prof.Nickname,
			"avatar":            prof.Avatar,
			"signed":            prof.Signed,
			"lang":              prof.Lang,
			"profile":           profileToMap(prof),
		}
		response.JSON(h.C, 200, response.OK(data))
	})
}

func profileToMap(p model.UserProfile) map[string]any {
	var setting any
	s := strings.TrimSpace(p.Setting)
	if s != "" && s != "null" {
		if err := json.Unmarshal([]byte(s), &setting); err != nil {
			setting = map[string]any{}
		}
	}
	if setting == nil {
		setting = map[string]any{}
	}
	return map[string]any{
		"user_id": p.UserID, "nickname": p.Nickname, "avatar": p.Avatar,
		"signed": p.Signed, "lang": p.Lang, "setting": setting,
	}
}

func userLogoutNoJSON(h *deps.HandlerCtx) {
	if h.D.JWTAPI == nil {
		return
	}
	raw := strings.TrimPrefix(h.C.GetHeader("Authorization"), "Bearer ")
	raw = strings.TrimSpace(raw)
	if raw != "" {
		if err := h.D.JWTAPI.AddBlacklist(raw); err != nil {
			// best-effort
		}
	}
}

// syncUserInfoJSON 与 UserInfo 返回体一致；供改用户名后复用，非独立路由。
func syncUserInfoJSON(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	var u model.User
	if err := h.D.DBx(h.C).Select("id", "username", "mobile", "email", "code", "user_type", "status", "google2fa", "password").
		First(&u, uid).Error; err != nil {
		response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
		return
	}
	var prof model.UserProfile
	if err := h.D.DBx(h.C).Where("user_id = ?", uid).First(&prof).Error; err != nil && !errors.Is(err, gorm.ErrRecordNotFound) {
		response.JSON(h.C, 200, response.Fail("db error"))
		return
	}
	isGoogle := 0
	if u.Google2fa != "" {
		isGoogle = 1
	}
	isTrans := 0
	if prof.TransPassword != "" {
		isTrans = 1
	}
	isPwd := 0
	if u.Password != "" {
		isPwd = 1
	}
	data := map[string]any{
		"id": u.ID, "username": u.Username, "mobile": u.Mobile, "email": u.Email, "code": u.Code,
		"user_type": u.UserType, "status": u.Status, "is_google2fa": isGoogle, "is_trans_password": isTrans,
		"is_password": isPwd, "is_kyc": 0, "nickname": prof.Nickname, "avatar": prof.Avatar,
		"signed": prof.Signed, "lang": prof.Lang, "profile": profileToMap(prof),
	}
	response.JSON(h.C, 200, response.OK(data))
}

func UserPasswordChange(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			OldPassword   string `json:"old_password"`
			Password      string `json:"password"`
			PasswordConf  string `json:"password_confirmation"`
			Google2faCode string `json:"google2fa_code"`
			Vcode         string `json:"vcode"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Password == "" || body.Password != body.PasswordConf || len(body.Password) < 6 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "password invalid", nil))
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Password != "" {
			if body.OldPassword == "" || !u.VerifyPassword(body.OldPassword) {
				response.JSON(h.C, 200, response.Fail("user.old_password_error"))
				return
			}
		}
		ctx := context.Background()
		if err := tools.VerifySecondFactor(ctx, h.D, &u, body.Google2faCode, body.Vcode, u.Email, u.Mobile, strconv.Itoa(u.Code), verifycode.SceneChange); err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		hashedPwd, err := tools.HashPassword(body.Password)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("hash failed"))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("password", hashedPwd).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		userLogoutNoJSON(h)
		response.JSON(h.C, 200, response.OKWithMessage("user.password_change_success", map[string]any{}))
	})
}

func UserAccountDisable(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Password      string `json:"password"`
			Google2faCode string `json:"google2fa_code"`
			Vcode         string `json:"vcode"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Password != "" {
			if body.Password == "" || !u.VerifyPassword(body.Password) {
				response.JSON(h.C, 200, response.Fail("user.password_error"))
				return
			}
		}
		ctx := context.Background()
		if err := tools.VerifySecondFactor(ctx, h.D, &u, body.Google2faCode, body.Vcode, u.Email, u.Mobile, strconv.Itoa(u.Code), verifycode.SceneChange); err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("status", model.UserStatusDisable).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		dev := ""
		tools.InsertAccountLog(h.D, uid, 8, h.C, dev)
		userLogoutNoJSON(h)
		response.JSON(h.C, 200, response.OKWithMessage("auth.account_disable_success", map[string]any{}))
	})
}

func UserAccountDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Password      string `json:"password"`
			Google2faCode string `json:"google2fa_code"`
			Vcode         string `json:"vcode"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Password != "" {
			if body.Password == "" || !u.VerifyPassword(body.Password) {
				response.JSON(h.C, 200, response.Fail("user.password_error"))
				return
			}
		}
		ctx := context.Background()
		if err := tools.VerifySecondFactor(ctx, h.D, &u, body.Google2faCode, body.Vcode, u.Email, u.Mobile, strconv.Itoa(u.Code), verifycode.SceneChange); err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		parts := []string{}
		if u.Username != "" {
			parts = append(parts, u.Username)
		}
		if u.Email != "" {
			parts = append(parts, u.Email)
		}
		if u.Mobile != "" {
			parts = append(parts, u.Mobile)
		}
		newU := "del" + strings.Join(parts, "|")
		if err := h.D.DBx(h.C).Model(&u).Updates(map[string]any{
			"email":    gorm.Expr("NULL"),
			"mobile":   gorm.Expr("NULL"),
			"username": newU,
			"status":   model.UserStatusDisable,
		}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 9, h.C, "")
		userLogoutNoJSON(h)
		response.JSON(h.C, 200, response.OKWithMessage("auth.account_delete_success", map[string]any{}))
	})
}

func UserGoogle2faQrcode(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var u model.User
		if err := h.D.DBx(h.C).Select("id", "google2fa", "email", "username", "mobile").First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Google2fa != "" {
			response.JSON(h.C, 200, response.Fail("auth.google_code_bind"))
			return
		}
		sec, err := tools.GenerateSecret()
		if err != nil {
			response.JSON(h.C, 200, response.Fail("secret gen failed"))
			return
		}
		acct := u.Email
		if acct == "" {
			acct = u.Username
		}
		if acct == "" {
			acct = u.Mobile
		}
		uri := tools.ProvisioningURI(acct, "FastApp", sec)
		response.JSON(h.C, 200, response.OK(map[string]any{
			"google2fa": sec,
			"qrcode":    uri,
		}))
	})
}

func UserGoogle2faBind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Google2fa     string `json:"google2fa"`
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Google2fa != "" {
			response.JSON(h.C, 200, response.Fail("auth.google_code_bind"))
			return
		}
		if err := tools.VerifyGoogle2FA(body.Google2fa, body.Google2faCode); err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("google2fa", body.Google2fa).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 10, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.bind_success", map[string]any{}))
	})
}

func UserGoogle2faUnbind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Google2fa == "" {
			response.JSON(h.C, 200, response.Fail("auth.google_code_unbind"))
			return
		}
		if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("google2fa", "").Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 11, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.unbind_success", map[string]any{}))
	})
}

func UserEmailBind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Email         string `json:"email"`
			Vcode         string `json:"vcode"`
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Email != "" {
			response.JSON(h.C, 200, response.Fail("auth.email_bind"))
			return
		}
		var other int64
		h.D.DBx(h.C).Model(&model.User{}).Where("email = ? AND id <> ?", body.Email, uid).Count(&other)
		if other > 0 {
			response.JSON(h.C, 200, response.Fail("auth.email_used"))
			return
		}
		if u.Google2fa != "" {
			if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
		}
		ctx := context.Background()
		if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeEmail, body.Email, body.Vcode, verifycode.SceneBind, true, 0) {
			response.JSON(h.C, 200, response.Fail("auth.email_code_invalid"))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("email", body.Email).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 5, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.bind_success", map[string]any{}))
	})
}

func UserEmailUnbind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Vcode         string `json:"vcode"`
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Email == "" {
			response.JSON(h.C, 200, response.Fail("auth.email_unbind"))
			return
		}
		if u.Google2fa != "" {
			if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
		}
		ctx := context.Background()
		if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeEmail, u.Email, body.Vcode, verifycode.SceneBind, true, 0) {
			response.JSON(h.C, 200, response.Fail("auth.email_code_invalid"))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("email", gorm.Expr("NULL")).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 7, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.unbind_success", map[string]any{}))
	})
}

func UserMobileBind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Mobile        string `json:"mobile"`
			Code          string `json:"code"`
			Vcode         string `json:"vcode"`
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		cc := 86
		if v, err := strconv.Atoi(body.Code); err == nil && v != 0 {
			cc = v
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Mobile != "" {
			response.JSON(h.C, 200, response.Fail("auth.mobile_bind"))
			return
		}
		var other int64
		if err := h.D.DBx(h.C).Model(&model.User{}).Where("mobile = ? AND id <> ?", body.Mobile, uid).Count(&other).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		if other > 0 {
			response.JSON(h.C, 200, response.Fail("auth.mobile_used"))
			return
		}
		if u.Google2fa != "" {
			if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
		}
		ctx := context.Background()
		if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeSMS, body.Mobile, body.Vcode, verifycode.SceneBind, true, cc) {
			response.JSON(h.C, 200, response.Fail("auth.mobile_code_invalid"))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Updates(map[string]any{"mobile": body.Mobile, "code": cc}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 4, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.bind_success", map[string]any{}))
	})
}

func UserMobileUnbind(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body struct {
			Code          string `json:"code"`
			Vcode         string `json:"vcode"`
			Google2faCode string `json:"google2fa_code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if u.Mobile == "" {
			response.JSON(h.C, 200, response.Fail("auth.mobile_unbind"))
			return
		}
		if u.Google2fa != "" {
			if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
		}
		cc := u.Code
		if v, err := strconv.Atoi(body.Code); err == nil && v != 0 {
			cc = v
		}
		if cc == 0 {
			cc = 86
		}
		ctx := context.Background()
		if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeSMS, u.Mobile, body.Vcode, verifycode.SceneBind, true, cc) {
			response.JSON(h.C, 200, response.Fail("auth.mobile_code_invalid"))
			return
		}
		if err := h.D.DBx(h.C).Model(&u).Update("mobile", gorm.Expr("NULL")).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		tools.InsertAccountLog(h.D, uid, 6, h.C, "")
		response.JSON(h.C, 200, response.OKWithMessage("auth.unbind_success", map[string]any{}))
	})
}

func UserAccountLogs(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		page := 1
		if v, err := strconv.Atoi(h.C.DefaultQuery("page", "1")); err == nil && v >= 1 {
			page = v
		}
		ps := 10
		if v, err := strconv.Atoi(h.C.DefaultQuery("page_size", "10")); err == nil && v >= 1 && v <= 100 {
			ps = v
		}
		typ := 0
		if tq := h.C.Query("type"); tq != "" {
			if v, err := strconv.Atoi(tq); err == nil {
				typ = v
			}
		}
		q := h.D.DBx(h.C).Model(&model.UserAccountLog{}).Where("user_id = ?", uid)
		if typ != 0 {
			q = q.Where("type = ?", typ)
		} else {
			q = q.Where("type <> ?", 1)
		}
		offset := (page - 1) * ps
		var rows []model.UserAccountLog
		if err := q.Order("id DESC").Limit(ps).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		list := make([]map[string]any, 0, len(rows))
		for _, r := range rows {
			list = append(list, map[string]any{
				"id": r.ID, "type": r.Type, "ip": r.IP, "os": r.OS, "device_id": r.DeviceID,
				"country": r.Country, "region": r.Region, "city": r.City, "created_at": r.CreatedAt.Format("2006-01-02 15:04:05"),
			})
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
	})
}

func UserProfileUpdate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body map[string]any
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if len(body) == 0 {
			response.JSON(h.C, 200, response.OK(nil))
			return
		}
		if uname, ok := body["username"].(string); ok && strings.TrimSpace(uname) != "" {
			var n int64
			h.D.DBx(h.C).Model(&model.User{}).Where("username = ? AND id <> ?", uname, uid).Count(&n)
			if n > 0 {
				response.JSON(h.C, 200, response.Fail("user.username_exist"))
				return
			}
			if err := h.D.DBx(h.C).Model(&model.User{}).Where("id = ?", uid).Update("username", uname).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("save failed"))
				return
			}
			syncUserInfoJSON(h)
			return
		}
		var prof model.UserProfile
		if err := h.D.DBx(h.C).Where("user_id = ?", uid).First(&prof).Error; err != nil {
			if !errors.Is(err, gorm.ErrRecordNotFound) {
				response.JSON(h.C, 200, response.Fail("db error"))
				return
			}
			prof = model.UserProfile{UserID: uid, Setting: "{}"}
			if err := h.D.DBx(h.C).Create(&prof).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("save failed"))
				return
			}
		}
		settingMap := map[string]any{}
		if strings.TrimSpace(prof.Setting) != "" && prof.Setting != "null" {
			if err := json.Unmarshal([]byte(prof.Setting), &settingMap); err != nil {
				settingMap = map[string]any{}
			}
		}
		if raw, ok := body["setting"].(map[string]any); ok {
			for k, v := range raw {
				settingMap[k] = v
			}
			delete(body, "setting")
		}
		if len(settingMap) > 0 {
			b, err := json.Marshal(settingMap)
			if err != nil {
				response.JSON(h.C, 200, response.Fail("invalid setting"))
				return
			}
			prof.Setting = string(b)
		}
		if v, ok := body["nickname"].(string); ok {
			prof.Nickname = v
		}
		if v, ok := body["avatar"].(string); ok {
			prof.Avatar = v
		}
		if v, ok := body["signed"].(string); ok {
			prof.Signed = v
		}
		if v, ok := body["lang"].(string); ok {
			prof.Lang = v
		}
		if err := h.D.DBx(h.C).Save(&prof).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(prof))
	})
}
