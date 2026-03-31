package admin

import (
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

var deptCodeRe = regexp.MustCompile(`^[a-zA-Z0-9_]+$`)

func PermissionDepartmentList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		q := h.D.DBx(h.C).Model(&model.Department{}).Where("parent_id = ?", 0)
		q = applyDepartmentFilters(h.C, q)
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var roots []model.Department
		if err := q.Order(model.P + "department.sort ASC, " + model.P + "department.id ASC").Limit(pageSize).Offset(offset).Find(&roots).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		rootIDs := make([]int64, len(roots))
		for i := range roots {
			rootIDs[i] = roots[i].ID
		}
		var children []model.Department
		if len(rootIDs) > 0 {
			_ = h.D.DBx(h.C).Where("parent_id IN ?", rootIDs).Order(model.P + "department.sort DESC").Find(&children).Error
		}
		byParent := map[int64][]model.Department{}
		for _, ch := range children {
			byParent[ch.ParentID] = append(byParent[ch.ParentID], ch)
		}
		list := make([]map[string]any, 0, len(roots))
		for _, r := range roots {
			row := deptToMap(&r)
			chs := byParent[r.ID]
			chRows := make([]map[string]any, 0, len(chs))
			for i := range chs {
				chRows = append(chRows, deptToMap(&chs[i]))
			}
			row["children"] = chRows
			list = append(list, row)
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": list, "total": total}))
	})
}

func PermissionDepartmentSelect(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var roots []model.Department
		if err := h.D.DBx(h.C).Where("parent_id = ? AND status = ?", 0, 1).Order("sort ASC").Find(&roots).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		rootIDs := make([]int64, len(roots))
		for i := range roots {
			rootIDs[i] = roots[i].ID
		}
		var children []model.Department
		if len(rootIDs) > 0 {
			_ = h.D.DBx(h.C).Where("parent_id IN ? AND status = ?", rootIDs, 1).Order("sort DESC").Find(&children).Error
		}
		byParent := map[int64][]model.Department{}
		for _, ch := range children {
			byParent[ch.ParentID] = append(byParent[ch.ParentID], ch)
		}
		out := make([]map[string]any, 0, len(roots)*2)
		for _, r := range roots {
			out = append(out, map[string]any{"label": r.Name, "value": r.ID})
			for _, ch := range byParent[r.ID] {
				out = append(out, map[string]any{"label": r.Name + "/" + ch.Name, "value": ch.ID})
			}
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

func PermissionDepartmentCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body departmentWriteBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Code != "" && !deptCodeRe.MatchString(body.Code) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code invalid", nil))
			return
		}
		if body.Code != "" {
			var n int64
			if err := h.D.DBx(h.C).Model(&model.Department{}).Where("code = ?", body.Code).Count(&n).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("check failed"))
				return
			}
			if n > 0 {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code taken", nil))
				return
			}
		}
		st := 1
		if body.Status != nil {
			st = *body.Status
		}
		op := middleware.UserID(h.C)
		dpt := model.Department{
			Name: body.Name, Code: body.Code, ParentID: body.ParentID, Sort: body.Sort,
			Status: st, Remark: body.Remark, CreatedBy: op,
		}
		if err := h.D.DBx(h.C).Create(&dpt).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("create failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionDepartmentSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var body departmentWriteBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Code != "" && !deptCodeRe.MatchString(body.Code) {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code invalid", nil))
			return
		}
		if body.Code != "" {
			var n int64
			if err := h.D.DBx(h.C).Model(&model.Department{}).Where("code = ? AND id <> ?", body.Code, id).Count(&n).Error; err != nil {
				response.JSON(h.C, 200, response.Fail("check failed"))
				return
			}
			if n > 0 {
				response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code taken", nil))
				return
			}
		}
		st := 1
		if body.Status != nil {
			st = *body.Status
		}
		op := middleware.UserID(h.C)
		uu := map[string]any{
			"name": body.Name, "code": body.Code, "parent_id": body.ParentID,
			"sort": body.Sort, "status": st, "remark": body.Remark, "updated_by": op,
		}
		if err := h.D.DBx(h.C).Model(&model.Department{}).Where("id = ?", id).Updates(uu).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func PermissionDepartmentDelete(d *deps.Deps) gin.HandlerFunc {
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
			if err := tx.Where("dept_id IN ?", ids).Delete(&model.RoleBelongsDepartment{}).Error; err != nil {
				return err
			}
			return tx.Where("id IN ?", ids).Delete(&model.Department{}).Error
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func deptToMap(d *model.Department) map[string]any {
	return map[string]any{
		"id": d.ID, "name": d.Name, "code": d.Code, "parent_id": d.ParentID,
		"sort": d.Sort, "status": d.Status, "remark": d.Remark,
		"created_by": d.CreatedBy, "updated_by": d.UpdatedBy,
		"created_at": d.CreatedAt, "updated_at": d.UpdatedAt,
	}
}

func applyDepartmentFilters(c *gin.Context, q *gorm.DB) *gorm.DB {
	tbl := model.P + "department"
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
	return q
}

type departmentWriteBody struct {
	Name     string `json:"name" binding:"required,max=50"`
	Code     string `json:"code" binding:"max=50"`
	ParentID int64  `json:"parent_id"`
	Sort     int    `json:"sort" binding:"required"`
	Status   *int   `json:"status" binding:"omitempty,oneof=1 2"`
	Remark   string `json:"remark"`
}
