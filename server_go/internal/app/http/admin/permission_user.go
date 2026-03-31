package admin

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/datascope"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
	"gorm.io/gorm"
)

type adminUserSelfUpdateBody struct {
	Nickname       string         `json:"nickname"`
	Phone          string         `json:"phone"`
	Email          string         `json:"email"`
	Mobile         string         `json:"mobile"`
	Avatar         string         `json:"avatar"`
	Signed         string         `json:"signed"`
	BackendSetting map[string]any `json:"backend_setting"`
	DeptID         []int64        `json:"dept_id"`
}

type resetPwdBody struct {
	ID *int64 `json:"id"`
}

type adminUserWriteBody struct {
	Username       string         `json:"username" binding:"required,max=20"`
	UserType       int            `json:"user_type" binding:"required"`
	Nickname       string         `json:"nickname" binding:"required,max=60"`
	Phone          string         `json:"phone"`
	Email          string         `json:"email"`
	Mobile         string         `json:"mobile"`
	Avatar         string         `json:"avatar"`
	Signed         string         `json:"signed"`
	Status         *int           `json:"status"`
	BackendSetting map[string]any `json:"backend_setting"`
	Remark         string         `json:"remark"`
	Password       string         `json:"password" binding:"omitempty,min=6,max=20"`
	DeptID         []int64        `json:"dept_id"`
}

type adminUserSaveBody struct {
	Username       string         `json:"username" binding:"required,max=20"`
	UserType       int            `json:"user_type" binding:"required"`
	Nickname       string         `json:"nickname" binding:"required,max=60"`
	Phone          string         `json:"phone"`
	Email          string         `json:"email"`
	Mobile         string         `json:"mobile"`
	Avatar         string         `json:"avatar"`
	Signed         string         `json:"signed"`
	Status         *int           `json:"status"`
	BackendSetting map[string]any `json:"backend_setting"`
	Remark         string         `json:"remark"`
	Password       string         `json:"password" binding:"omitempty,min=6,max=20"`
	DeptID         []int64        `json:"dept_id"`
}

type batchRoleCodesBody struct {
	RoleCodes []string `json:"role_codes" binding:"required"`
}

func PermissionUserList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		page, pageSize := tools.ParsePage(h.C)
		q := h.D.DBx(h.C).Model(&model.User{})
		var err error
		q, err = datascope.ApplyUserListScope(h.D.DBx(h.C), uid, q)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("scope failed"))
			return
		}
		q = applyAdminUserFilters(h.C, q)

		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var users []model.User
		if err := q.Order(model.P + "user.id DESC").Limit(pageSize).Offset(offset).Find(&users).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		list, err := buildAdminUserRows(h.D.DBx(h.C), users)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("load related failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": list, "total": total}))
	})
}

func PermissionUserSelect(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		kw := strings.TrimSpace(h.C.Query("keyword"))
		q := h.D.DBx(h.C).Model(&model.User{}).Select("id", "username", "email", "mobile").Order("id DESC").Limit(10)
		if kw != "" {
			like := kw + "%"
			q = q.Where("username LIKE ? OR email LIKE ? OR mobile LIKE ?", like, like, like)
		}
		var rows []model.User
		if err := q.Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		out := make([]map[string]any, 0, len(rows))
		for _, u := range rows {
			label := strings.Join(filterEmpty([]string{
				fmt.Sprintf("%d", u.ID), u.Username, u.Email, u.Mobile,
			}), "|")
			out = append(out, map[string]any{"label": label, "value": u.ID})
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

func PermissionUserClearCache(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		datascope.ClearUserScopeCache(h.D.DBx(h.C), uid)
		if h.D.RDB != nil {
			_ = h.D.RDB.Del(h.C.Request.Context(), fmt.Sprintf("%d", uid)).Err()
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserUpdateSelf(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		var body adminUserSelfUpdateBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			updates := map[string]any{}
			if body.Email != "" {
				updates["email"] = body.Email
			}
			if body.Mobile != "" {
				updates["mobile"] = body.Mobile
			}
			if len(updates) > 0 {
				if err := tx.Model(&model.User{}).Where("id = ?", uid).Updates(updates).Error; err != nil {
					return err
				}
			}
			pu := map[string]any{}
			if body.Nickname != "" {
				pu["nickname"] = body.Nickname
			}
			if body.Avatar != "" {
				pu["avatar"] = body.Avatar
			}
			if body.Signed != "" {
				pu["signed"] = body.Signed
			}
			if len(pu) > 0 {
				if err := tx.Model(&model.UserProfile{}).Where("user_id = ?", uid).Updates(pu).Error; err != nil {
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
			su := map[string]any{}
			if body.Phone != "" {
				su["phone"] = body.Phone
			}
			if body.BackendSetting != nil {
				b, _ := json.Marshal(body.BackendSetting)
				su["backend_setting"] = datatypes.JSON(b)
			}
			if body.DeptID != nil {
				b, _ := json.Marshal(body.DeptID)
				su["dept_id"] = datatypes.JSON(b)
			}
			if len(su) > 0 {
				if err := tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", uid).Updates(su).Error; err != nil {
					return err
				}
				var sc int64
				_ = tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", uid).Count(&sc).Error
				if sc == 0 {
					deptB, _ := json.Marshal(body.DeptID)
					backB, _ := json.Marshal(body.BackendSetting)
					if err := tx.Create(&model.UserAdminSetting{UserID: uid, Phone: body.Phone, DeptID: datatypes.JSON(deptB), BackendSetting: datatypes.JSON(backB)}).Error; err != nil {
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
		datascope.ClearUserScopeCache(h.D.DBx(h.C), uid)
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserResetPassword(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body resetPwdBody
		_ = h.C.ShouldBindJSON(&body)
		var target int64
		if body.ID != nil {
			target = *body.ID
		}
		if target == 0 {
			if q := strings.TrimSpace(h.C.Query("id")); q != "" {
				if n, err := strconv.ParseInt(q, 10, 64); err == nil {
					target = n
				}
			}
		}
		if target == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "id required", nil))
			return
		}
		hash, err := tools.HashPassword("123456")
		if err != nil {
			response.JSON(h.C, 200, response.Fail("hash failed"))
			return
		}
		if err := h.D.DBx(h.C).Model(&model.User{}).Where("id = ?", target).Update("password", hash).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("update failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body adminUserWriteBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if strings.Contains(strings.TrimSpace(body.Nickname), " ") {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "nickname invalid", nil))
			return
		}
		uid := middleware.UserID(h.C)
		pwd := body.Password
		if pwd == "" {
			pwd = "123456"
		}
		hash, err := tools.HashPassword(pwd)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("hash failed"))
			return
		}
		st := 1
		if body.Status != nil {
			st = *body.Status
		}
		u := model.User{
			Username:  body.Username,
			UserType:  strconv.Itoa(body.UserType),
			Email:     body.Email,
			Mobile:    body.Mobile,
			Status:    st,
			Remark:    body.Remark,
			Password:  hash,
			CreatedBy: uid,
		}
		err = h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Create(&u).Error; err != nil {
				return err
			}
			prof := model.UserProfile{UserID: u.ID, Nickname: body.Nickname, Avatar: body.Avatar, Signed: body.Signed}
			if err := tx.Create(&prof).Error; err != nil {
				return err
			}
			var deptJSON datatypes.JSON
			if body.DeptID != nil {
				b, _ := json.Marshal(body.DeptID)
				deptJSON = b
			}
			var backJSON datatypes.JSON
			if body.BackendSetting != nil {
				b, _ := json.Marshal(body.BackendSetting)
				backJSON = b
			}
			set := model.UserAdminSetting{UserID: u.ID, Phone: body.Phone, DeptID: deptJSON, BackendSetting: backJSON}
			if err := tx.Create(&set).Error; err != nil {
				return err
			}
			return nil
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("create failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var ids []int64
		if !tools.BindJSONOr422(h.C, &ids) {
			return
		}
		if len(ids) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Where("user_id IN ?", ids).Delete(&model.UserBelongsRole{}).Error; err != nil {
				return err
			}
			if err := tx.Where("user_id IN ?", ids).Delete(&model.UserAdminSetting{}).Error; err != nil {
				return err
			}
			if err := tx.Where("user_id IN ?", ids).Delete(&model.UserProfile{}).Error; err != nil {
				return err
			}
			return tx.Where("id IN ?", ids).Delete(&model.User{}).Error
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		for _, id := range ids {
			datascope.ClearUserScopeCache(h.D.DBx(h.C), id)
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		userID, ok := tools.ParseIDParam(h.C, "userId")
		if !ok {
			return
		}
		var body adminUserSaveBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if strings.Contains(strings.TrimSpace(body.Nickname), " ") {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "nickname invalid", nil))
			return
		}
		op := middleware.UserID(h.C)
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			return permissionUserSaveTx(tx, userID, body, op)
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		datascope.ClearUserScopeCache(h.D.DBx(h.C), userID)
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionUserRolesGet(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		userID, ok := tools.ParseIDParam(h.C, "userId")
		if !ok {
			return
		}
		var rows []model.Role
		err := h.D.DBx(h.C).Model(&model.Role{}).
			Joins("JOIN "+model.P+"user_belongs_role ur ON ur.role_id = "+model.P+"role.id").
			Where("ur.user_id = ?", userID).
			Select(model.P+"role.id", model.P+"role.code", model.P+"role.name").
			Find(&rows).Error
		if err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		out := make([]map[string]any, 0, len(rows))
		for _, r := range rows {
			out = append(out, map[string]any{"id": r.ID, "code": r.Code, "name": r.Name})
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

func PermissionUserRolesPut(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		userID, ok := tools.ParseIDParam(h.C, "userId")
		if !ok {
			return
		}
		var body batchRoleCodesBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var roleIDs []int64
		if err := h.D.DBx(h.C).Model(&model.Role{}).Where("code IN ? AND status = ?", body.RoleCodes, 1).Pluck("id", &roleIDs).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("role query failed"))
			return
		}
		if len(roleIDs) != len(body.RoleCodes) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "role_codes invalid", nil))
			return
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Where("user_id = ?", userID).Delete(&model.UserBelongsRole{}).Error; err != nil {
				return err
			}
			for _, rid := range roleIDs {
				if err := tx.Create(&model.UserBelongsRole{UserID: userID, RoleID: rid}).Error; err != nil {
					return err
				}
			}
			return nil
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("sync failed"))
			return
		}
		datascope.ClearUserScopeCache(h.D.DBx(h.C), userID)
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func applyAdminUserFilters(c *gin.Context, q *gorm.DB) *gorm.DB {
	tbl := model.P + "user"
	if v := strings.TrimSpace(c.Query("username")); v != "" {
		q = q.Where(tbl+".username LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(c.Query("email")); v != "" {
		q = q.Where(tbl+".email LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(c.Query("mobile")); v != "" {
		q = q.Where(tbl+".mobile LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(c.Query("remark")); v != "" {
		q = q.Where(tbl+".remark LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(c.Query("user_type")); v != "" {
		q = q.Where(tbl+".user_type = ?", v)
	}
	if v := strings.TrimSpace(c.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(c.Query("phone")); v != "" {
		sub := model.P + "user_admin_setting.phone LIKE ? AND " + model.P + "user_admin_setting.user_id = " + tbl + ".id"
		q = q.Where("EXISTS (SELECT 1 FROM "+model.P+"user_admin_setting WHERE "+sub+")", v+"%")
	}
	if v := strings.TrimSpace(c.Query("nickname")); v != "" {
		sub := model.P + "user_profile.nickname LIKE ? AND " + model.P + "user_profile.user_id = " + tbl + ".id"
		q = q.Where("EXISTS (SELECT 1 FROM "+model.P+"user_profile WHERE "+sub+")", "%"+v+"%")
	}
	return q
}

func buildAdminUserRows(db *gorm.DB, users []model.User) ([]map[string]any, error) {
	if len(users) == 0 {
		return []map[string]any{}, nil
	}
	ids := make([]int64, len(users))
	for i := range users {
		ids[i] = users[i].ID
	}
	var profs []model.UserProfile
	if err := db.Where("user_id IN ?", ids).Find(&profs).Error; err != nil {
		return nil, err
	}
	pmap := map[int64]*model.UserProfile{}
	for i := range profs {
		p := profs[i]
		pmap[p.UserID] = &p
	}
	var sets []model.UserAdminSetting
	if err := db.Where("user_id IN ?", ids).Find(&sets).Error; err != nil {
		return nil, err
	}
	smap := map[int64]*model.UserAdminSetting{}
	for i := range sets {
		s := sets[i]
		smap[s.UserID] = &s
	}
	out := make([]map[string]any, 0, len(users))
	for i := range users {
		u := users[i]
		row := adminUserBaseMap(&u)
		if p := pmap[u.ID]; p != nil {
			mergeNonID(row, profileToMap(p))
		}
		if s := smap[u.ID]; s != nil {
			mergeNonID(row, adminSettingToMap(s))
		}
		out = append(out, row)
	}
	return out, nil
}

func adminUserBaseMap(u *model.User) map[string]any {
	return map[string]any{
		"id":         u.ID,
		"username":   u.Username,
		"email":      u.Email,
		"code":       u.Code,
		"mobile":     u.Mobile,
		"user_type":  u.UserType,
		"status":     u.Status,
		"remark":     u.Remark,
		"created_by": u.CreatedBy,
		"updated_by": u.UpdatedBy,
		"created_at": u.CreatedAt,
		"updated_at": u.UpdatedAt,
	}
}

func profileToMap(p *model.UserProfile) map[string]any {
	return map[string]any{
		"nickname": p.Nickname,
		"avatar":   p.Avatar,
		"signed":   p.Signed,
		"lang":     p.Lang,
	}
}

func adminSettingToMap(s *model.UserAdminSetting) map[string]any {
	m := map[string]any{"phone": s.Phone}
	if len(s.DeptID) > 0 {
		var arr []int64
		if json.Unmarshal(s.DeptID, &arr) == nil {
			m["dept_id"] = arr
		}
	}
	if len(s.BackendSetting) > 0 {
		var raw any
		if json.Unmarshal(s.BackendSetting, &raw) == nil {
			m["backend_setting"] = raw
		}
	}
	return m
}

func mergeNonID(dst map[string]any, src map[string]any) {
	for k, v := range src {
		if k == "id" {
			continue
		}
		dst[k] = v
	}
}

func filterEmpty(ss []string) []string {
	var r []string
	for _, s := range ss {
		if strings.TrimSpace(s) != "" {
			r = append(r, s)
		}
	}
	return r
}

func permissionUserSaveTx(tx *gorm.DB, userID int64, body adminUserSaveBody, op int64) error {
	uu := map[string]any{
		"username":   body.Username,
		"user_type":  strconv.Itoa(body.UserType),
		"email":      body.Email,
		"mobile":     body.Mobile,
		"remark":     body.Remark,
		"updated_by": op,
	}
	if body.Status != nil {
		uu["status"] = *body.Status
	}
	if body.Password != "" {
		pwHash, err := tools.HashPassword(body.Password)
		if err != nil {
			return err
		}
		uu["password"] = pwHash
	}
	if err := tx.Model(&model.User{}).Where("id = ?", userID).Updates(uu).Error; err != nil {
		return err
	}
	pu := map[string]any{"nickname": body.Nickname, "avatar": body.Avatar, "signed": body.Signed}
	if err := tx.Model(&model.UserProfile{}).Where("user_id = ?", userID).Updates(pu).Error; err != nil {
		return err
	}
	var pc int64
	if err := tx.Model(&model.UserProfile{}).Where("user_id = ?", userID).Count(&pc).Error; err != nil {
		return err
	}
	if pc == 0 {
		if err := tx.Create(&model.UserProfile{UserID: userID, Nickname: body.Nickname, Avatar: body.Avatar, Signed: body.Signed}).Error; err != nil {
			return err
		}
	}
	su := map[string]any{"phone": body.Phone}
	if body.BackendSetting != nil {
		b, _ := json.Marshal(body.BackendSetting)
		su["backend_setting"] = datatypes.JSON(b)
	}
	if body.DeptID != nil {
		b, _ := json.Marshal(body.DeptID)
		su["dept_id"] = datatypes.JSON(b)
	}
	if err := tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", userID).Updates(su).Error; err != nil {
		return err
	}
	var sc int64
	if err := tx.Model(&model.UserAdminSetting{}).Where("user_id = ?", userID).Count(&sc).Error; err != nil {
		return err
	}
	if sc == 0 {
		deptB, _ := json.Marshal(body.DeptID)
		backB, _ := json.Marshal(body.BackendSetting)
		return tx.Create(&model.UserAdminSetting{
			UserID: userID, Phone: body.Phone,
			DeptID: datatypes.JSON(deptB), BackendSetting: datatypes.JSON(backB),
		}).Error
	}
	return nil
}
