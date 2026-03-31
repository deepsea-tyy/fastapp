package apphttp

import (
	"context"
	"encoding/json"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/verifycode"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type registerBody struct {
	Type                 json.RawMessage `json:"type"`
	Username             string          `json:"username"`
	Password             string          `json:"password"`
	PasswordConfirmation string          `json:"password_confirmation"`
	Mobile               string          `json:"mobile"`
	Email                string          `json:"email"`
	Code                 json.RawMessage `json:"code"`
	Vcode                string          `json:"vcode"`
	Scene                string          `json:"scene"`
	Openid               string          `json:"openid"`
	InviteCode           string          `json:"invite_code"`
	DeviceID             string          `json:"device_id"`
}

func parseCountryCode(raw json.RawMessage) int {
	if len(raw) == 0 {
		return 86
	}
	var n int
	if err := json.Unmarshal(raw, &n); err == nil {
		return n
	}
	var s string
	if err := json.Unmarshal(raw, &s); err != nil {
		return 86
	}
	v, err := strconv.Atoi(strings.TrimSpace(s))
	if err != nil || v == 0 {
		return 86
	}
	return v
}

func UserRegister(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWTAPI == nil {
			response.JSON(h.C, 200, response.Fail("jwt api not configured"))
			return
		}
		var body registerBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		typ, ok := tools.ParseFlexInt(body.Type)
		if !ok {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "type required", nil))
			return
		}
		ctx := context.Background()
		cc := parseCountryCode(body.Code)
		dev := tools.DeviceIDOrNew(h.C, body.DeviceID)

		switch typ {
		case tools.LoginTypeUsernamePassword:
			if strings.TrimSpace(body.Username) == "" || body.Password == "" || body.Password != body.PasswordConfirmation {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "username or password invalid", nil))
				return
			}
			var exists int64
			h.D.DBx(h.C).Model(&model.User{}).Where("username = ?", body.Username).Count(&exists)
			if exists > 0 {
				response.JSON(h.C, 200, response.Fail("user.username_exist"))
				return
			}
			hashed, err := tools.HashPassword(body.Password)
			if err != nil {
				response.JSON(h.C, 200, response.Fail("hash failed"))
				return
			}
			u := model.User{Username: body.Username, Password: hashed, UserType: model.UserTypeUser, Status: model.UserStatusNormal, Code: cc}
			if err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
				if err := tx.Create(&u).Error; err != nil {
					return err
				}
				if err := tools.AssignAppUsername(tx, &u); err != nil {
					return err
				}
				prof := model.UserProfile{UserID: u.ID, Nickname: fmtNick(u.ID), Setting: "{}"}
				return tx.Create(&prof).Error
			}); err != nil {
				response.JSON(h.C, 200, response.Fail("register failed"))
				return
			}
			data, err := tools.IssueAPIToken(h.D, u.ID, h.C, dev, 2)
			if err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
			response.JSON(h.C, 200, response.OK(data))
		case tools.LoginTypeMobileCode:
			scene := body.Scene
			if scene == "" {
				scene = verifycode.SceneRegister
			}
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeSMS, body.Mobile, body.Vcode, scene, true, cc) {
				response.JSON(h.C, 200, response.Fail("验证码错误或已过期"))
				return
			}
			u := model.User{Mobile: body.Mobile, Code: cc, UserType: model.UserTypeUser, Status: model.UserStatusNormal}
			if err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
				if err := tx.Create(&u).Error; err != nil {
					return err
				}
				if err := tools.AssignAppUsername(tx, &u); err != nil {
					return err
				}
				prof := model.UserProfile{UserID: u.ID, Nickname: fmtNick(u.ID), Setting: "{}"}
				return tx.Create(&prof).Error
			}); err != nil {
				response.JSON(h.C, 200, response.Fail("register failed"))
				return
			}
			data, err := tools.IssueAPIToken(h.D, u.ID, h.C, dev, 2)
			if err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
			response.JSON(h.C, 200, response.OK(data))
		case 3:
			scene := body.Scene
			if scene == "" {
				scene = verifycode.SceneRegister
			}
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeEmail, body.Email, body.Vcode, scene, true, 0) {
				response.JSON(h.C, 200, response.Fail("验证码错误或已过期"))
				return
			}
			u := model.User{Email: body.Email, UserType: model.UserTypeUser, Status: model.UserStatusNormal, Code: cc}
			if err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
				if err := tx.Create(&u).Error; err != nil {
					return err
				}
				if err := tools.AssignAppUsername(tx, &u); err != nil {
					return err
				}
				prof := model.UserProfile{UserID: u.ID, Nickname: fmtNick(u.ID), Setting: "{}"}
				return tx.Create(&prof).Error
			}); err != nil {
				response.JSON(h.C, 200, response.Fail("register failed"))
				return
			}
			data, err := tools.IssueAPIToken(h.D, u.ID, h.C, dev, 2)
			if err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
			response.JSON(h.C, 200, response.OK(data))
		case 11, 12:
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "wechat register not supported in server_go", nil))
		default:
			response.JSON(h.C, 200, response.Fail("user.register_fail"))
		}
	})
}

func fmtNick(id int64) string {
	return "u" + strconv.FormatInt(tools.UserNo(id), 10)
}

func UserIsRegister(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		q := h.D.DBx(h.C).Model(&model.User{})
		if u := strings.TrimSpace(h.C.Query("username")); u != "" {
			q = q.Where("username = ?", u)
		}
		if m := strings.TrimSpace(h.C.Query("mobile")); m != "" {
			cc := 86
			if cq := h.C.Query("code"); cq != "" {
				if v, err := strconv.Atoi(cq); err == nil {
					cc = v
				}
			}
			q = q.Where("mobile = ? AND code = ?", m, cc)
		}
		if e := strings.TrimSpace(h.C.Query("email")); e != "" {
			q = q.Where("email = ?", e)
		}
		var n int64
		if err := q.Count(&n).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		has := n > 0
		response.JSON(h.C, 200, response.OK(map[string]any{"status": map[bool]int{true: 1, false: 0}[has]}))
	})
}

func UserSms(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		typ := h.C.Query("type")
		to := h.C.Query("to")
		scene := h.C.DefaultQuery("scene", verifycode.SceneDefault)
		cc := 86
		if v, err := strconv.Atoi(h.C.DefaultQuery("code", "86")); err == nil && v != 0 {
			cc = v
		}
		if typ != verifycode.TypeSMS && typ != verifycode.TypeEmail {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "type invalid", nil))
			return
		}
		if strings.TrimSpace(to) == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "to required", nil))
			return
		}
		ok, msg := verifycode.Send(context.Background(), h.D.RDB, typ, to, scene, cc)
		if !ok {
			response.JSON(h.C, 200, response.Fail(msg))
			return
		}
		response.JSON(h.C, 200, response.OKWithMessage(msg, map[string]any{}))
	})
}

func UserSmsCheck(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body struct {
			Type  string `json:"type"`
			To    string `json:"to"`
			Vcode string `json:"vcode"`
			Scene string `json:"scene"`
			Code  string `json:"code"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Scene == "" {
			body.Scene = verifycode.SceneDefault
		}
		cc := 86
		if v, err := strconv.Atoi(body.Code); err == nil && v != 0 {
			cc = v
		}
		typ := verifycode.TypeSMS
		if body.Type == verifycode.TypeEmail {
			typ = verifycode.TypeEmail
			cc = 0
		}
		if verifycode.Verify(context.Background(), h.D.RDB, typ, body.To, body.Vcode, body.Scene, false, cc) {
			response.JSON(h.C, 200, response.OK(nil))
			return
		}
		response.JSON(h.C, 200, response.Fail("auth.mobile_code_invalid"))
	})
}

type loginBody struct {
	Type          json.RawMessage `json:"type"`
	Username      string          `json:"username"`
	Password      string          `json:"password"`
	Mobile        string          `json:"mobile"`
	Email         string          `json:"email"`
	Code          json.RawMessage `json:"code"`
	Vcode         string          `json:"vcode"`
	Scene         string          `json:"scene"`
	Google2faCode string          `json:"google2fa_code"`
	DeviceID      string          `json:"device_id"`
}

func UserLogin(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWTAPI == nil {
			response.JSON(h.C, 200, response.Fail("jwt api not configured"))
			return
		}
		var body loginBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		typ, ok := tools.ParseFlexInt(body.Type)
		if !ok {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "type required", nil))
			return
		}
		ctx := context.Background()
		cc := parseCountryCode(body.Code)
		dev := tools.DeviceIDOrNew(h.C, body.DeviceID)

		var u model.User
		switch typ {
		case tools.LoginTypeUsernamePassword:
			q := h.D.DBx(h.C).Where("user_type = ?", model.UserTypeUser)
			switch {
			case strings.TrimSpace(body.Username) != "":
				q = q.Where("username = ?", body.Username)
			case strings.TrimSpace(body.Mobile) != "":
				q = q.Where("mobile = ? AND code = ?", body.Mobile, cc)
			case strings.TrimSpace(body.Email) != "":
				q = q.Where("email = ?", body.Email)
			default:
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "username or mobile or email required", nil))
				return
			}
			if err := q.First(&u).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("auth.user_not_register"))
				return
			}
			if u.Status == model.UserStatusDisable {
				response.JSON(h.C, 200, response.WithCode(500, "result.disabled", nil))
				return
			}
			if !u.VerifyPassword(body.Password) {
				response.JSON(h.C, 200, response.Fail("user.password_error"))
				return
			}
			info := tools.DetectVerifyMethod(&u)
			if tools.NeedsSecondStep(info, body.Google2faCode, body.Vcode) {
				info["device_id"] = dev
				response.JSON(h.C, 200, response.OK(info))
				return
			}
			sc := body.Scene
			if sc == "" {
				sc = verifycode.SceneLogin
			}
			if err := tools.VerifySecondFactor(ctx, h.D, &u, body.Google2faCode, body.Vcode, body.Email, body.Mobile, strconv.Itoa(cc), sc); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
		case tools.LoginTypeMobileCode:
			if err := h.D.DBx(h.C).Where("user_type = ? AND mobile = ?", model.UserTypeUser, body.Mobile).First(&u).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("auth.user_not_register"))
				return
			}
			if u.Status == model.UserStatusDisable {
				response.JSON(h.C, 200, response.WithCode(500, "result.disabled", nil))
				return
			}
			sc := body.Scene
			if sc == "" {
				sc = verifycode.SceneLogin
			}
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeSMS, body.Mobile, body.Vcode, sc, true, cc) {
				response.JSON(h.C, 200, response.Fail("auth.mobile_code_invalid"))
				return
			}
		case tools.LoginTypeEmailCode:
			emailKey := body.Email
			if emailKey == "" {
				emailKey = body.Mobile
			}
			if err := h.D.DBx(h.C).Where("user_type = ? AND email = ?", model.UserTypeUser, emailKey).First(&u).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("auth.user_not_register"))
				return
			}
			if u.Status == model.UserStatusDisable {
				response.JSON(h.C, 200, response.WithCode(500, "result.disabled", nil))
				return
			}
			sc := body.Scene
			if sc == "" {
				sc = verifycode.SceneLogin
			}
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeEmail, u.Email, body.Vcode, sc, true, 0) {
				response.JSON(h.C, 200, response.Fail("auth.email_code_invalid"))
				return
			}
		default:
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "unsupported login type", nil))
			return
		}

		data, err := tools.IssueAPIToken(h.D, u.ID, h.C, dev, 1)
		if err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		response.JSON(h.C, 200, response.OK(data))
	})
}

func UserRefreshToken(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D.JWTAPI == nil {
			response.JSON(h.C, 200, response.Fail("jwt api not configured"))
			return
		}
		var body struct {
			RefreshToken string `json:"refresh_token"`
		}
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		rt := strings.TrimSpace(body.RefreshToken)
		if rt == "" {
			response.JSON(h.C, 200, response.Fail("jwt.token_required"))
			return
		}
		_, uid, err := h.D.JWTAPI.ParseRefresh(rt)
		if err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnauthorized, "invalid refresh", nil))
			return
		}
		if err := h.D.JWTAPI.AddBlacklist(rt); err != nil {
			// best-effort
		}
		access, refresh, ttl, err := h.D.JWTAPI.IssuePair(uid)
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

type resetPwdBody struct {
	Step          json.RawMessage `json:"step"`
	Type          json.RawMessage `json:"type"`
	Mobile        string          `json:"mobile"`
	Email         string          `json:"email"`
	Code          json.RawMessage `json:"code"`
	Vcode         string          `json:"vcode"`
	Google2faCode string          `json:"google2fa_code"`
	Password      string          `json:"password"`
	PasswordConf  string          `json:"password_confirmation"`
}

func UserResetPassword(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body resetPwdBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var step int
		if s, ok := tools.ParseFlexInt(body.Step); ok {
			step = s
		}
		typ, ok := tools.ParseFlexInt(body.Type)
		if !ok || (typ != tools.LoginTypeMobileCode && typ != tools.LoginTypeEmailCode) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "type invalid", nil))
			return
		}
		ctx := context.Background()
		cc := parseCountryCode(body.Code)

		var u model.User
		if typ == tools.LoginTypeMobileCode {
			if err := h.D.DBx(h.C).Where("user_type = ? AND mobile = ? AND code = ?", model.UserTypeUser, body.Mobile, cc).First(&u).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("auth.user_not_register"))
				return
			}
		} else {
			if err := h.D.DBx(h.C).Where("user_type = ? AND email = ?", model.UserTypeUser, body.Email).First(&u).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("auth.user_not_register"))
				return
			}
		}

		verifyAgain := ""
		if u.Google2fa != "" {
			verifyAgain = tools.VerifyGoogle
		}
		if step == 1 && verifyAgain != "" && strings.TrimSpace(body.Google2faCode) == "" {
			response.JSON(h.C, 200, response.OK(map[string]any{"verify_again": verifyAgain}))
			return
		}
		if step == 2 && u.Google2fa != "" {
			if err := tools.VerifyGoogle2FA(u.Google2fa, body.Google2faCode); err != nil {
				response.JSON(h.C, 200, response.Fail(err.Error()))
				return
			}
			response.JSON(h.C, 200, response.OK(nil))
			return
		}

		scene := verifycode.SceneResetPassword
		if typ == tools.LoginTypeEmailCode {
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeEmail, u.Email, body.Vcode, scene, true, 0) {
				response.JSON(h.C, 200, response.Fail("auth.email_code_invalid"))
				return
			}
		} else {
			if !verifycode.Verify(ctx, h.D.RDB, verifycode.TypeSMS, u.Mobile, body.Vcode, scene, true, cc) {
				response.JSON(h.C, 200, response.Fail("auth.mobile_code_invalid"))
				return
			}
		}
		if body.Password != "" {
			if body.Password != body.PasswordConf {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "password mismatch", nil))
				return
			}
			if len(body.Password) < 6 {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "password too short", nil))
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
		}
		tools.InsertAccountLog(h.D, u.ID, 3, h.C, "")
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func UserBaseInfo(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, err := strconv.ParseInt(h.C.Query("user_id"), 10, 64)
		if err != nil || id <= 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "user_id required", nil))
			return
		}
		var prof model.UserProfile
		if err := h.D.DBx(h.C).Where("user_id = ?", id).First(&prof).Error; err != nil {
			response.JSON(h.C, 200, response.OK(map[string]any{
				"user_id": id, "nickname": "", "avatar": "", "signed": "", "lang": "",
			}))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{
			"user_id": prof.UserID, "nickname": prof.Nickname, "avatar": prof.Avatar,
			"signed": prof.Signed, "lang": prof.Lang,
		}))
	})
}
