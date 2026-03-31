package admin

import (
	"context"
	"encoding/json"
	"strconv"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type permissionUpdateBody struct {
	NewPassword        string         `json:"new_password"`
	NewPasswordConfirm string         `json:"new_password_confirm"`
	OldPassword        string         `json:"old_password"`
	Nickname           string         `json:"nickname"`
	Avatar             string         `json:"avatar"`
	Signed             string         `json:"signed"`
	BackendSetting     map[string]any `json:"backend_setting"`
}

func PermissionSelfUpdate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body permissionUpdateBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var u model.User
		if err := h.D.DBx(h.C).First(&u, uid).Error; err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "user not found", nil))
			return
		}
		if body.NewPassword != "" {
			if body.NewPassword != body.NewPasswordConfirm {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "password confirmation mismatch", nil))
				return
			}
			if len(body.NewPassword) < 8 {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "new_password invalid", nil))
				return
			}
			if !u.VerifyPassword(body.OldPassword) {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "old_password invalid", nil))
				return
			}
			hashedPwd, err := tools.HashPassword(body.NewPassword)
			if err != nil {
				response.JSON(h.C, 200, response.Fail("hash failed"))
				return
			}
			if err := h.D.DBx(h.C).Model(&model.User{}).Where("id = ?", uid).Update("password", hashedPwd).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("update failed"))
				return
			}
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			uu := map[string]any{}
			if body.Nickname != "" {
				uu["nickname"] = body.Nickname
			}
			if body.Avatar != "" {
				uu["avatar"] = body.Avatar
			}
			if body.Signed != "" {
				uu["signed"] = body.Signed
			}
			if len(uu) > 0 {
				if err := tx.Model(&model.UserProfile{}).Where("user_id = ?", uid).Updates(uu).Error; err != nil {
					return err
				}
				var pc int64
				_ = tx.Model(&model.UserProfile{}).Where("user_id = ?", uid).Count(&pc).Error
				if pc == 0 {
					if err := tx.Create(&model.UserProfile{UserID: uid, Nickname: body.Nickname, Avatar: body.Avatar, Signed: body.Signed}).Error; err != nil {
						return err
					}
				}
			}
			if body.BackendSetting != nil {
				b, _ := json.Marshal(body.BackendSetting)
				su := map[string]any{"backend_setting": datatypes.JSON(b)}
				if err := tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", uid).Updates(su).Error; err != nil {
					return err
				}
				var sc int64
				_ = tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", uid).Count(&sc).Error
				if sc == 0 {
					if err := tx.Create(&model.UserAdminSetting{UserID: uid, BackendSetting: datatypes.JSON(b)}).Error; err != nil {
						return err
					}
				}
			}
			return nil
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("update failed"))
			return
		}
		if h.D.RDB != nil {
			_ = h.D.RDB.Del(context.Background(), strconv.FormatInt(uid, 10)).Err()
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}
