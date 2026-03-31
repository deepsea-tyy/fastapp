package scmhttp

import (
	"encoding/json"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	cmsmodel "fastapp/plugin/ds/sysCms/src/model"
)

func placementPositionList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.PlacementPosition{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.PlacementPosition{})
	if v := strings.TrimSpace(h.C.Query("name")); v != "" {
		q = q.Where(tbl+".name LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("code")); v != "" {
		q = q.Where(tbl+".code = ?", v)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.PlacementPosition
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

func placementPositionSelect(h *deps.HandlerCtx) {
	var rows []cmsmodel.PlacementPosition
	if err := h.D.DBx(h.C).Where("status = 1").Order("id ASC").Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	out := make([]map[string]any, 0, len(rows))
	for _, r := range rows {
		out = append(out, map[string]any{"label": r.Name, "value": r.ID})
	}
	response.JSON(h.C, 200, response.OK(out))
}

type placementPositionBody struct {
	Code   *string `json:"code"`
	Name   string  `json:"name"`
	Status *int    `json:"status"`
}

func placementPositionCreate(h *deps.HandlerCtx) {
	var body placementPositionBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	row := cmsmodel.PlacementPosition{Name: body.Name, Code: body.Code, CreatedBy: &uid, UpdatedBy: &uid}
	if body.Status != nil {
		row.Status = *body.Status
	} else {
		row.Status = 1
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func placementPositionSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body placementPositionBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	up := map[string]any{"updated_by": uid, "name": body.Name}
	if body.Code != nil {
		up["code"] = *body.Code
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if err := h.D.DBx(h.C).Model(&cmsmodel.PlacementPosition{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func placementPositionDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.PlacementPosition{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func placementContentList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.PlacementContent{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.PlacementContent{})
	if v := strings.TrimSpace(h.C.Query("name")); v != "" {
		q = q.Where(tbl+".name LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.PlacementContent
	if err := q.Order(tbl + ".sort ASC, " + tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type placementContentBody struct {
	Code       *string         `json:"code"`
	Name       string          `json:"name"`
	ObjectType *int            `json:"object_type"`
	ObjectID   *int64          `json:"object_id"`
	URL        string          `json:"url"`
	Target     *int            `json:"target"`
	Title      json.RawMessage `json:"title"`
	Cover      string          `json:"cover"`
	Desc       json.RawMessage `json:"desc"`
	Content    json.RawMessage `json:"content"`
	StartAt    *int            `json:"start_at"`
	EndAt      *int            `json:"end_at"`
	Fixed      *int            `json:"fixed"`
	Status     *int            `json:"status"`
	Sort       *int            `json:"sort"`
	Remark     string          `json:"remark"`
}

func placementContentCreate(h *deps.HandlerCtx) {
	var body placementContentBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	row := cmsmodel.PlacementContent{Name: body.Name, Code: body.Code, URL: body.URL, Title: body.Title, Cover: body.Cover, Desc: body.Desc, Content: body.Content, Remark: body.Remark, CreatedBy: &uid, UpdatedBy: &uid}
	if body.ObjectType != nil {
		row.ObjectType = *body.ObjectType
	}
	if body.ObjectID != nil {
		row.ObjectID = *body.ObjectID
	}
	if body.Target != nil {
		row.Target = *body.Target
	}
	if body.StartAt != nil {
		row.StartAt = body.StartAt
	}
	if body.EndAt != nil {
		row.EndAt = body.EndAt
	}
	if body.Fixed != nil {
		row.Fixed = *body.Fixed
	}
	if body.Status != nil {
		row.Status = *body.Status
	}
	if body.Sort != nil {
		row.Sort = *body.Sort
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func placementContentSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body placementContentBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	up := map[string]any{"updated_by": uid}
	if body.Name != "" {
		up["name"] = body.Name
	}
	if body.Code != nil {
		up["code"] = *body.Code
	}
	if body.ObjectType != nil {
		up["object_type"] = *body.ObjectType
	}
	if body.ObjectID != nil {
		up["object_id"] = *body.ObjectID
	}
	if body.URL != "" {
		up["url"] = body.URL
	}
	if body.Target != nil {
		up["target"] = *body.Target
	}
	if len(body.Title) > 0 {
		up["title"] = body.Title
	}
	if body.Cover != "" {
		up["cover"] = body.Cover
	}
	if len(body.Desc) > 0 {
		up["desc"] = body.Desc
	}
	if len(body.Content) > 0 {
		up["content"] = body.Content
	}
	if body.StartAt != nil {
		up["start_at"] = *body.StartAt
	}
	if body.EndAt != nil {
		up["end_at"] = *body.EndAt
	}
	if body.Fixed != nil {
		up["fixed"] = *body.Fixed
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if body.Sort != nil {
		up["sort"] = *body.Sort
	}
	if body.Remark != "" {
		up["remark"] = body.Remark
	}
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&cmsmodel.PlacementContent{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func placementContentDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.PlacementContent{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func appPageContentList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.AppPageContent{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.AppPageContent{})
	if v := strings.TrimSpace(h.C.Query("page_code")); v != "" {
		q = q.Where(tbl+".page_code = ?", v)
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("code")); v != "" {
		q = q.Where(tbl+".code = ?", v)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.AppPageContent
	if err := q.Order(tbl + ".sort ASC, " + tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type appPageContentBody struct {
	Code          *string         `json:"code"`
	PageCode      string          `json:"page_code"`
	ComponentCode *string         `json:"component_code"`
	ContentType   *int            `json:"content_type"`
	Data          json.RawMessage `json:"data"`
	Platform      *int            `json:"platform"`
	StartAt       *int            `json:"start_at"`
	EndAt         *int            `json:"end_at"`
	Fixed         *int            `json:"fixed"`
	Status        *int            `json:"status"`
	Sort          *int            `json:"sort"`
	Remark        string          `json:"remark"`
}

func appPageContentCreate(h *deps.HandlerCtx) {
	var body appPageContentBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	row := cmsmodel.AppPageContent{PageCode: body.PageCode, Code: body.Code, ComponentCode: body.ComponentCode, Data: body.Data, Remark: body.Remark, CreatedBy: &uid, UpdatedBy: &uid}
	if body.ContentType != nil {
		row.ContentType = *body.ContentType
	}
	if body.Platform != nil {
		row.Platform = *body.Platform
	}
	if body.StartAt != nil {
		row.StartAt = body.StartAt
	}
	if body.EndAt != nil {
		row.EndAt = body.EndAt
	}
	if body.Fixed != nil {
		row.Fixed = *body.Fixed
	}
	if body.Status != nil {
		row.Status = *body.Status
	}
	if body.Sort != nil {
		row.Sort = *body.Sort
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func appPageContentSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body appPageContentBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := int64(middleware.UserID(h.C))
	up := map[string]any{"updated_by": uid}
	if body.PageCode != "" {
		up["page_code"] = body.PageCode
	}
	if body.Code != nil {
		up["code"] = *body.Code
	}
	if body.ComponentCode != nil {
		up["component_code"] = *body.ComponentCode
	}
	if body.ContentType != nil {
		up["content_type"] = *body.ContentType
	}
	if len(body.Data) > 0 {
		up["data"] = body.Data
	}
	if body.Platform != nil {
		up["platform"] = *body.Platform
	}
	if body.StartAt != nil {
		up["start_at"] = *body.StartAt
	}
	if body.EndAt != nil {
		up["end_at"] = *body.EndAt
	}
	if body.Fixed != nil {
		up["fixed"] = *body.Fixed
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if body.Sort != nil {
		up["sort"] = *body.Sort
	}
	if body.Remark != "" {
		up["remark"] = body.Remark
	}
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&cmsmodel.AppPageContent{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func appPageContentDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.AppPageContent{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func appPageContentSyncList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.AppPageContentSync{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.AppPageContentSync{})
	if v := strings.TrimSpace(h.C.Query("platform")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".platform = ?", n)
		}
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.AppPageContentSync
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

func appPageContentSyncDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.AppPageContentSync{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}
