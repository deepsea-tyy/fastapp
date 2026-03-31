package admin

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"regexp"
	"strconv"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

var roleCodeRe = regexp.MustCompile(`^[a-zA-Z0-9_]+$`)

func PermissionRoleList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		q := h.D.DBx(h.C).Model(&model.Role{})
		q = applyRoleFilters(h.C, q)
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var roles []model.Role
		if err := q.Order(model.P + "role.id DESC").Limit(pageSize).Offset(offset).Find(&roles).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		ids := make([]int64, len(roles))
		for i := range roles {
			ids[i] = roles[i].ID
		}
		var pivots []model.RoleBelongsDepartment
		if len(ids) > 0 {
			if err := h.D.DBx(h.C).Where("role_id IN ?", ids).Find(&pivots).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("query pivots failed"))
				return
			}
		}
		deptByRole := map[int64][]int64{}
		for _, p := range pivots {
			deptByRole[p.RoleID] = append(deptByRole[p.RoleID], p.DeptID)
		}
		list := make([]map[string]any, 0, len(roles))
		for _, r := range roles {
			row := map[string]any{
				"id": r.ID, "name": r.Name, "code": r.Code, "data_scope": r.DataScope,
				"status": r.Status, "sort": r.Sort, "remark": r.Remark,
				"created_by": r.CreatedBy, "updated_by": r.UpdatedBy,
				"created_at": r.CreatedAt, "updated_at": r.UpdatedAt,
				"dept_id": deptByRole[r.ID],
			}
			list = append(list, row)
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": list, "total": total}))
	})
}

func PermissionRoleCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body roleWriteBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if !roleCodeRe.MatchString(body.Code) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code invalid", nil))
			return
		}
		var n int64
		if err := h.D.DBx(h.C).Model(&model.Role{}).Where("code = ?", body.Code).Count(&n).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("check failed"))
			return
		}
		if n > 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code taken", nil))
			return
		}
		ds := 5
		if body.DataScope != nil {
			ds = *body.DataScope
		}
		st := 1
		if body.Status != nil {
			st = *body.Status
		}
		op := middleware.UserID(h.C)
		r := model.Role{Name: body.Name, Code: body.Code, DataScope: ds, Status: st, Sort: body.Sort, Remark: body.Remark, CreatedBy: op}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Create(&r).Error; err != nil {
				return err
			}
			if body.DeptID != nil {
				return syncRoleDepartments(tx, r.ID, *body.DeptID)
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

func PermissionRoleSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		raw, rerr := io.ReadAll(h.C.Request.Body)
		if rerr != nil {
			response.JSON(h.C, 200, response.Fail("read body failed"))
			return
		}
		h.C.Request.Body = io.NopCloser(bytes.NewReader(raw))
		var rawMap map[string]json.RawMessage
		if json.Unmarshal(raw, &rawMap) != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "invalid json", nil))
			return
		}
		_, hasDeptID := rawMap["dept_id"]
		var body roleWriteBody
		if err := json.Unmarshal(raw, &body); err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "invalid json", nil))
			return
		}
		if body.Name == "" || body.Code == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "name is required", nil))
			return
		}
		if !roleCodeRe.MatchString(body.Code) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code invalid", nil))
			return
		}
		var n int64
		if err := h.D.DBx(h.C).Model(&model.Role{}).Where("code = ? AND id <> ?", body.Code, id).Count(&n).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("check failed"))
			return
		}
		if n > 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code taken", nil))
			return
		}
		ds := 5
		if body.DataScope != nil {
			ds = *body.DataScope
		}
		st := 1
		if body.Status != nil {
			st = *body.Status
		}
		op := middleware.UserID(h.C)
		uu := map[string]any{
			"name": body.Name, "code": body.Code, "data_scope": ds, "status": st,
			"sort": body.Sort, "remark": body.Remark, "updated_by": op,
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Model(&model.Role{}).Where("id = ?", id).Updates(uu).Error; err != nil {
				return err
			}
			if !hasDeptID {
				return nil
			}
			if body.DeptID != nil {
				return syncRoleDepartments(tx, id, *body.DeptID)
			}
			return syncRoleDepartments(tx, id, nil)
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionRoleDelete(d *deps.Deps) gin.HandlerFunc {
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
			if err := tx.Where("role_id IN ?", ids).Delete(&model.UserBelongsRole{}).Error; err != nil {
				return err
			}
			if err := tx.Where("role_id IN ?", ids).Delete(&model.RoleBelongsMenu{}).Error; err != nil {
				return err
			}
			if err := tx.Where("role_id IN ?", ids).Delete(&model.RoleBelongsDepartment{}).Error; err != nil {
				return err
			}
			return tx.Where("id IN ?", ids).Delete(&model.Role{}).Error
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionRoleMenusGet(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var menus []model.Menu
		err := h.D.DBx(h.C).Model(&model.Menu{}).
			Joins("JOIN "+model.P+"role_belongs_menu rm ON rm.menu_id = "+model.P+"menu.id").
			Where("rm.role_id = ? AND "+model.P+"menu.status = ?", id, 1).
			Select(model.P+"menu.id", model.P+"menu.name").
			Order(model.P + "menu.sort ASC").
			Find(&menus).Error
		if err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		out := make([]map[string]any, 0, len(menus))
		for _, m := range menus {
			out = append(out, map[string]any{"id": m.ID, "name": m.Name})
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

func PermissionRoleMenusPut(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var body roleMenusBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		var n int64
		if err := h.D.DBx(h.C).Model(&model.Role{}).Where("id = ?", id).Count(&n).Error; err != nil || n == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeNotFound, "not found", nil))
			return
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Where("role_id = ?", id).Delete(&model.RoleBelongsMenu{}).Error; err != nil {
				return err
			}
			if len(body.Permissions) == 0 {
				return nil
			}
			uniq := uniqueStrings(body.Permissions)
			var menuIDs []int64
			if err := tx.Model(&model.Menu{}).Where("name IN ? AND status = ?", uniq, 1).Pluck("id", &menuIDs).Error; err != nil {
				return err
			}
			if len(menuIDs) != len(uniq) {
				return errInvalidMenuNames
			}
			for _, mid := range menuIDs {
				if err := tx.Create(&model.RoleBelongsMenu{RoleID: id, MenuID: mid}).Error; err != nil {
					return err
				}
			}
			return nil
		})
		if err == errInvalidMenuNames {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "permissions invalid", nil))
			return
		}
		if err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionRoleDeptsGet(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var depts []model.Department
		err := h.D.DBx(h.C).Model(&model.Department{}).
			Joins("JOIN "+model.P+"role_belongs_department rd ON rd.dept_id = "+model.P+"department.id").
			Where("rd.role_id = ?", id).
			Select(model.P+"department.id", model.P+"department.name").
			Find(&depts).Error
		if err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		out := make([]map[string]any, 0, len(depts))
		for _, dpt := range depts {
			out = append(out, map[string]any{"id": dpt.ID, "name": dpt.Name})
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

func applyRoleFilters(c *gin.Context, q *gorm.DB) *gorm.DB {
	tbl := model.P + "role"
	if v := c.Query("name"); v != "" {
		q = q.Where(tbl+".name LIKE ?", "%"+v+"%")
	}
	if v := c.Query("code"); v != "" {
		q = q.Where(tbl+".code LIKE ?", "%"+v+"%")
	}
	if v := c.Query("status"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := c.Query("data_scope"); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".data_scope = ?", n)
		}
	}
	return q
}

type roleWriteBody struct {
	Name      string   `json:"name" binding:"required,max=60"`
	Code      string   `json:"code" binding:"required,max=60"`
	DataScope *int     `json:"data_scope" binding:"omitempty,oneof=1 2 3 4 5"`
	Status    *int     `json:"status" binding:"omitempty,oneof=1 2"`
	Sort      int      `json:"sort" binding:"required"`
	Remark    string   `json:"remark"`
	DeptID    *[]int64 `json:"dept_id"`
}

func syncRoleDepartments(tx *gorm.DB, roleID int64, deptIDs []int64) error {
	if err := tx.Where("role_id = ?", roleID).Delete(&model.RoleBelongsDepartment{}).Error; err != nil {
		return err
	}
	for _, did := range deptIDs {
		if err := tx.Create(&model.RoleBelongsDepartment{RoleID: roleID, DeptID: did}).Error; err != nil {
			return err
		}
	}
	return nil
}

type roleMenusBody struct {
	Permissions []string `json:"permissions"`
}

var errInvalidMenuNames = errors.New("invalid menu names")

func uniqueStrings(in []string) []string {
	seen := map[string]struct{}{}
	out := make([]string, 0, len(in))
	for _, s := range in {
		if _, ok := seen[s]; ok {
			continue
		}
		seen[s] = struct{}{}
		out = append(out, s)
	}
	return out
}
