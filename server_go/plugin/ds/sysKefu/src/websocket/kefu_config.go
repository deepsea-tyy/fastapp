package ws

import (
	"context"
	"encoding/json"
	"strconv"
	"strings"
	"time"

	cfgmodel "fastapp/plugin/ds/sysConfig/src/model"

	"gorm.io/gorm"
)

// KefuSysConfig 对应 。
type KefuSysConfig struct {
	AutoReplyEnabled     bool
	WorkTimeStart        string
	WorkTimeEnd          string
	AutoReplyDelaySec    int
	AutoReplyThrottleSec int
	OfflineMessageByLang map[string]string
}

// LoadKefuSysConfig 读取 group_code = kefu_config 的 system_config 行。
func LoadKefuSysConfig(ctx context.Context, db *gorm.DB) (KefuSysConfig, error) {
	out := KefuSysConfig{
		WorkTimeStart:        "09:00",
		WorkTimeEnd:          "22:00",
		AutoReplyDelaySec:    0,
		AutoReplyThrottleSec: 30,
		OfflineMessageByLang: map[string]string{},
	}
	if db == nil {
		return out, nil
	}
	var rows []cfgmodel.SystemConfig
	if err := db.WithContext(ctx).Where("group_code = ?", "kefu_config").Find(&rows).Error; err != nil {
		return out, err
	}
	for _, r := range rows {
		switch r.Key {
		case "auto_reply_enabled":
			out.AutoReplyEnabled = jsonValueTruthy(r.Value)
		case "work_time_start":
			out.WorkTimeStart = strings.TrimSpace(jsonStringOrRaw(r.Value))
			if out.WorkTimeStart == "" {
				out.WorkTimeStart = "09:00"
			}
		case "work_time_end":
			out.WorkTimeEnd = strings.TrimSpace(jsonStringOrRaw(r.Value))
			if out.WorkTimeEnd == "" {
				out.WorkTimeEnd = "22:00"
			}
		case "auto_reply_delay":
			out.AutoReplyDelaySec = jsonInt(r.Value, 0)
		case "auto_reply_throttle":
			out.AutoReplyThrottleSec = jsonInt(r.Value, 30)
		case "offline_message":
			if strings.EqualFold(r.InputType, "keyValuePair") || strings.EqualFold(r.InputType, "select") {
				out.OfflineMessageByLang = mapFromSelectData(r.ConfigSelectData)
			}
		}
	}
	return out, nil
}

func jsonValueTruthy(raw json.RawMessage) bool {
	if len(raw) == 0 {
		return false
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		s = strings.TrimSpace(s)
		if s == "" || s == "0" || strings.EqualFold(s, "false") {
			return false
		}
		return true
	}
	var n float64
	if json.Unmarshal(raw, &n) == nil {
		return n != 0
	}
	var b bool
	if json.Unmarshal(raw, &b) == nil {
		return b
	}
	return false
}

func jsonStringOrRaw(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		return s
	}
	return strings.Trim(string(raw), `"`)
}

func jsonInt(raw json.RawMessage, def int) int {
	if len(raw) == 0 {
		return def
	}
	var n int
	if json.Unmarshal(raw, &n) == nil {
		return n
	}
	var f float64
	if json.Unmarshal(raw, &f) == nil {
		return int(f)
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		if v, err := strconv.Atoi(strings.TrimSpace(s)); err == nil {
			return v
		}
	}
	return def
}

func mapFromSelectData(raw json.RawMessage) map[string]string {
	m := map[string]string{}
	var items []struct {
		Label string `json:"label"`
		Value string `json:"value"`
	}
	if json.Unmarshal(raw, &items) != nil {
		return m
	}
	for _, it := range items {
		m[strings.TrimSpace(it.Value)] = it.Label
	}
	return m
}

// IsKefuWorkTime 。
func (c KefuSysConfig) IsKefuWorkTime(now time.Time) bool {
	cur := now.Format("15:04")
	start := c.WorkTimeStart
	end := c.WorkTimeEnd
	if len(start) < 5 || len(end) < 5 {
		return true
	}
	return cur >= start && cur <= end
}

func (c KefuSysConfig) offlineText(lang string) string {
	if t := strings.TrimSpace(c.OfflineMessageByLang[lang]); t != "" {
		return t
	}
	if t := c.OfflineMessageByLang["zh_CN"]; strings.TrimSpace(t) != "" {
		return t
	}
	for _, t := range c.OfflineMessageByLang {
		if strings.TrimSpace(t) != "" {
			return t
		}
	}
	return ""
}
