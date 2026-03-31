package snfyhttp

import (
	"encoding/json"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	nmodel "fastapp/plugin/ds/sysNotify/src/model"
)

func sysNotifyAdminPageList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&nmodel.MessageNotify{}).TableName()
	q := h.D.DBx(h.C).Model(&nmodel.MessageNotify{})
	if v := strings.TrimSpace(h.C.Query("notify_type")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".notify_type = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("type")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".type = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("user_id")); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			q = q.Where(tbl+".user_id = ?", n)
		}
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var rows []nmodel.MessageNotify
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type messageNotifyBody struct {
	Title      json.RawMessage `json:"title"`
	Content    json.RawMessage `json:"content"`
	Type       *int            `json:"type"`
	UserID     *int64          `json:"user_id"`
	NotifyType *int            `json:"notify_type"`
	Link       string          `json:"link"`
}

func sysNotifyAdminCreate(h *deps.HandlerCtx) {
	var body messageNotifyBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	row := nmodel.MessageNotify{
		Title:     body.Title,
		Content:   body.Content,
		Link:      body.Link,
		CreatedBy: uid,
		UpdatedBy: uid,
	}
	if body.Type != nil {
		row.Type = *body.Type
	} else {
		row.Type = 1
	}
	if body.UserID != nil {
		row.UserID = *body.UserID
	}
	if body.NotifyType != nil {
		row.NotifyType = *body.NotifyType
	} else {
		row.NotifyType = 1
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func sysNotifyAdminSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body messageNotifyBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	up := map[string]any{"updated_by": uid}
	if len(body.Title) > 0 {
		up["title"] = []byte(body.Title)
	}
	if len(body.Content) > 0 {
		up["content"] = []byte(body.Content)
	}
	if body.Type != nil {
		up["type"] = *body.Type
	}
	if body.UserID != nil {
		up["user_id"] = *body.UserID
	}
	if body.NotifyType != nil {
		up["notify_type"] = *body.NotifyType
	}
	if body.Link != "" {
		up["link"] = body.Link
	}
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&nmodel.MessageNotify{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func sysNotifyAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&nmodel.MessageNotify{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}
