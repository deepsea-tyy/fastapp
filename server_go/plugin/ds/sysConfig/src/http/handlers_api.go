package scfghttp

import (
	"encoding/json"
	"strings"
	"time"

	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	cfgmodel "fastapp/plugin/ds/sysConfig/src/model"
)

func apiSystemConfigByGroup(h *deps.HandlerCtx) {
	code := strings.TrimSpace(h.C.Query("code"))
	if code == "" {
		response.JSON(h.C, 200, response.Fail("code required"))
		return
	}
	cacheKey := "syscfg:group_" + code
	if h.D.RDB != nil {
		if s, err := h.D.RDB.Get(h.C.Request.Context(), cacheKey).Result(); err == nil && s != "" {
			var cached []map[string]any
			if json.Unmarshal([]byte(s), &cached) == nil {
				response.JSON(h.C, 200, response.OK(cached))
				return
			}
		}
	}
	tbl := (&cfgmodel.SystemConfig{}).TableName()
	var rows []cfgmodel.SystemConfig
	if err := h.D.DBx(h.C).Where(tbl+".group_code = ?", code).
		Select("name", "key", "value", "remark", "input_type", "config_select_data").
		Order(tbl + ".sort ASC, " + tbl + ".id ASC").
		Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	out := make([]map[string]any, 0, len(rows))
	for _, r := range rows {
		out = append(out, map[string]any{
			"name":               r.Name,
			"key":                r.Key,
			"value":              jsonRaw(r.Value),
			"remark":             r.Remark,
			"input_type":         r.InputType,
			"config_select_data": jsonRaw(r.ConfigSelectData),
		})
	}
	if h.D.RDB != nil {
		b, _ := json.Marshal(out)
		_ = h.D.RDB.Set(h.C.Request.Context(), cacheKey, string(b), 5*time.Minute).Err()
	}
	response.JSON(h.C, 200, response.OK(out))
}

func jsonRaw(b []byte) any {
	if len(b) == 0 {
		return map[string]any{}
	}
	var v any
	if err := json.Unmarshal(b, &v); err != nil {
		return string(b)
	}
	return v
}
