package scfghttp

import (
	"bytes"
	"encoding/json"
	"io"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	cfgmodel "fastapp/plugin/ds/sysConfig/src/model"
)

func sysConfigPageList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cfgmodel.SystemConfig{}).TableName()
	q := h.D.DBx(h.C).Model(&cfgmodel.SystemConfig{})
	if v := strings.TrimSpace(h.C.Query("group_code")); v != "" {
		q = q.Where(tbl+".group_code = ?", v)
	}
	if v := strings.TrimSpace(h.C.Query("key")); v != "" {
		q = q.Where(tbl+".`key` LIKE ?", "%"+v+"%")
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var rows []cfgmodel.SystemConfig
	if err := q.Order(tbl + ".sort ASC, " + tbl + ".id ASC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

func sysConfigDetails(h *deps.HandlerCtx) {
	code := strings.TrimSpace(h.C.Param("code"))
	if code == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "code required", nil))
		return
	}
	tbl := (&cfgmodel.SystemConfig{}).TableName()
	var rows []cfgmodel.SystemConfig
	if err := h.D.DBx(h.C).Where(tbl+".group_code = ?", code).Order(tbl + ".sort DESC").Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(rows))
}

type sysConfigWriteBody struct {
	GroupCode        string          `json:"group_code"`
	Key              string          `json:"key"`
	Value            json.RawMessage `json:"value"`
	Name             json.RawMessage `json:"name"`
	InputType        string          `json:"input_type"`
	ConfigSelectData json.RawMessage `json:"config_select_data"`
	Sort             *int            `json:"sort"`
	Remark           string          `json:"remark"`
}

func sysConfigCreate(h *deps.HandlerCtx) {
	var body sysConfigWriteBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	if strings.TrimSpace(body.GroupCode) == "" || strings.TrimSpace(body.Key) == "" || len(body.Name) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "group_code, key, name required", nil))
		return
	}
	uid := middleware.UserID(h.C)
	row := cfgmodel.SystemConfig{
		GroupCode:        strings.TrimSpace(body.GroupCode),
		Key:              strings.TrimSpace(body.Key),
		Value:            body.Value,
		Name:             body.Name,
		InputType:        body.InputType,
		ConfigSelectData: body.ConfigSelectData,
		Remark:           body.Remark,
		CreatedBy:        uid,
		UpdatedBy:        uid,
	}
	if body.Sort != nil {
		row.Sort = *body.Sort
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	sysConfigEvictCache(h)
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigSave(h *deps.HandlerCtx) {
	idStr := h.C.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil || id <= 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "id invalid", nil))
		return
	}
	var body sysConfigWriteBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	updates := map[string]any{"updated_by": uid}
	if body.GroupCode != "" {
		updates["group_code"] = strings.TrimSpace(body.GroupCode)
	}
	if body.Key != "" {
		updates["key"] = strings.TrimSpace(body.Key)
	}
	if len(body.Value) > 0 {
		updates["value"] = body.Value
	}
	if len(body.Name) > 0 {
		updates["name"] = body.Name
	}
	if body.InputType != "" {
		updates["input_type"] = body.InputType
	}
	if len(body.ConfigSelectData) > 0 {
		updates["config_select_data"] = body.ConfigSelectData
	}
	if body.Sort != nil {
		updates["sort"] = *body.Sort
	}
	if body.Remark != "" {
		updates["remark"] = body.Remark
	}
	res := h.D.DBx(h.C).Model(&cfgmodel.SystemConfig{}).Where("id = ?", id).Updates(updates)
	if res.Error != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	sysConfigEvictCache(h)
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigDelete(h *deps.HandlerCtx) {
	var body struct {
		Key string `json:"key"`
	}
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	key := strings.TrimSpace(body.Key)
	if key == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "key required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("`key` = ?", key).Delete(&cfgmodel.SystemConfig{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	sysConfigEvictCache(h)
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigBatchUpdate(h *deps.HandlerCtx) {
	raw, err := io.ReadAll(h.C.Request.Body)
	if err != nil {
		response.JSON(h.C, 200, response.Fail("read body failed"))
		return
	}
	h.C.Request.Body = io.NopCloser(bytes.NewReader(raw))
	var items []sysConfigWriteBody
	if json.Unmarshal(raw, &items) != nil || len(items) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "body must be a JSON array of config rows", nil))
		return
	}
	uid := middleware.UserID(h.C)
	for _, body := range items {
		gc := strings.TrimSpace(body.GroupCode)
		k := strings.TrimSpace(body.Key)
		if gc == "" || k == "" {
			continue
		}
		var row cfgmodel.SystemConfig
		if err := h.D.DBx(h.C).Where("group_code = ? AND `key` = ?", gc, k).First(&row).Error; err != nil {
			continue
		}
		up := map[string]any{"updated_by": uid}
		if len(body.Value) > 0 {
			up["value"] = body.Value
		}
		if len(body.Name) > 0 {
			up["name"] = body.Name
		}
		if body.InputType != "" {
			up["input_type"] = body.InputType
		}
		if len(body.ConfigSelectData) > 0 {
			up["config_select_data"] = body.ConfigSelectData
		}
		if body.Sort != nil {
			up["sort"] = *body.Sort
		}
		if body.Remark != "" {
			up["remark"] = body.Remark
		}
		_ = h.D.DBx(h.C).Model(&row).Updates(up).Error
	}
	sysConfigEvictCache(h)
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigGroupListWithInfo(h *deps.HandlerCtx) {
	var groups []cfgmodel.SystemConfigGroup
	if err := h.D.DBx(h.C).Order("id asc").Find(&groups).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	tbl := (&cfgmodel.SystemConfig{}).TableName()
	out := make([]map[string]any, 0, len(groups))
	for _, g := range groups {
		var infos []cfgmodel.SystemConfig
		_ = h.D.DBx(h.C).Where(tbl+".group_code = ?", g.Code).Order(tbl + ".sort asc, " + tbl + ".id asc").Find(&infos).Error
		out = append(out, map[string]any{
			"id":         g.ID,
			"name":       g.Name,
			"code":       g.Code,
			"icon":       g.Icon,
			"remark":     g.Remark,
			"created_by": g.CreatedBy,
			"updated_by": g.UpdatedBy,
			"created_at": g.CreatedAt,
			"updated_at": g.UpdatedAt,
			"info":       infos,
		})
	}
	response.JSON(h.C, 200, response.OK(out))
}

type sysConfigGroupBody struct {
	Name   json.RawMessage `json:"name"`
	Code   string          `json:"code"`
	Icon   string          `json:"icon"`
	Remark string          `json:"remark"`
}

func sysConfigGroupCreate(h *deps.HandlerCtx) {
	var body sysConfigGroupBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	if len(body.Name) == 0 || strings.TrimSpace(body.Code) == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "name, code required", nil))
		return
	}
	uid := middleware.UserID(h.C)
	row := cfgmodel.SystemConfigGroup{
		Name:      body.Name,
		Code:      strings.TrimSpace(body.Code),
		Icon:      body.Icon,
		Remark:    body.Remark,
		CreatedBy: uid,
		UpdatedBy: uid,
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigGroupSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body sysConfigGroupBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	up := map[string]any{"updated_by": uid}
	if len(body.Name) > 0 {
		up["name"] = body.Name
	}
	if body.Code != "" {
		up["code"] = strings.TrimSpace(body.Code)
	}
	if body.Icon != "" {
		up["icon"] = body.Icon
	}
	up["remark"] = body.Remark
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&cfgmodel.SystemConfigGroup{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigGroupDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cfgmodel.SystemConfigGroup{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func sysConfigEvictCache(h *deps.HandlerCtx) {
	if h.D == nil || h.D.RDB == nil {
		return
	}
	ctx := h.C.Request.Context()
	var cur uint64
	for {
		keys, next, err := h.D.RDB.Scan(ctx, cur, "syscfg:*", 80).Result()
		if err != nil {
			return
		}
		if len(keys) > 0 {
			_ = h.D.RDB.Del(ctx, keys...).Err()
		}
		cur = next
		if cur == 0 {
			return
		}
	}
}
