package admin

import (
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
)

func UserAdminLoginLogList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		tbl := model.P + "user_admin_login_log"
		q := h.D.DBx(h.C).Model(&model.UserAdminLoginLog{})
		if v := strings.TrimSpace(h.C.Query("username")); v != "" {
			q = q.Where(tbl+".username LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("ip")); v != "" {
			q = q.Where(tbl+".ip LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("status")); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				q = q.Where(tbl+".status = ?", n)
			}
		}
		if v := strings.TrimSpace(h.C.Query("message")); v != "" {
			q = q.Where(tbl+".message LIKE ?", "%"+v+"%")
		}
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var rows []model.UserAdminLoginLog
		if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
	})
}

type idsBody struct {
	IDs []int64 `json:"ids"`
}

func UserAdminLoginLogDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body idsBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if len(body.IDs) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		if err := h.D.DBx(h.C).Where("id IN ?", body.IDs).Delete(&model.UserAdminLoginLog{}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func UserAdminOperationLogList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		tbl := model.P + "user_admin_operation_log"
		q := h.D.DBx(h.C).Model(&model.UserAdminOperationLog{})
		if v := strings.TrimSpace(h.C.Query("username")); v != "" {
			q = q.Where(tbl+".username LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("method")); v != "" {
			q = q.Where(tbl+".method = ?", v)
		}
		if v := strings.TrimSpace(h.C.Query("router")); v != "" {
			q = q.Where(tbl+".router LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("service_name")); v != "" {
			q = q.Where(tbl+".service_name LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("ip")); v != "" {
			q = q.Where(tbl+".ip LIKE ?", "%"+v+"%")
		}
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var rows []model.UserAdminOperationLog
		if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
	})
}

func UserAdminOperationLogDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body idsBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if len(body.IDs) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		if err := h.D.DBx(h.C).Where("id IN ?", body.IDs).Delete(&model.UserAdminOperationLog{}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}
