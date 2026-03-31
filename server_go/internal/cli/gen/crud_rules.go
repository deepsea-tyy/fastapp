package gen

import "strings"

// 。

var CrudSkipFormFields = []string{"id", "created_at", "updated_at", "deleted_at", "created_by", "updated_by"}

var CrudSkipTableFields = []string{"created_at", "updated_at", "created_by", "updated_by", "remark"}

var CrudTransFields = []string{"status", "remark", "sort", "createdBy", "updatedBy", "createdAt", "updatedAt"}

var CrudLargeTextTypes = []string{"text", "mediumtext", "longtext", "blob", "mediumblob", "longblob", "json", "jsonb"}

var CrudSortableTypes = []string{"int", "tinyint", "smallint", "bigint", "decimal", "float", "double", "datetime", "date", "timestamp"}

func fieldSuffixMap() []struct {
	Suf, Comp string
} {
	return []struct{ Suf, Comp string }{
		{"_enabled", "el-switch"},
		{"_disabled", "el-switch"},
		{"_is_", "el-switch"},
		{"_image", "ma-upload-image"},
		{"_cover", "ma-upload-image"},
		{"_img", "ma-upload-image"},
		{"_photo", "ma-upload-image"},
		{"_avatar", "ma-upload-image"},
		{"_logo", "ma-upload-image"},
		{"_file", "ma-upload-file"},
		{"_attachment", "ma-upload-file"},
		{"_time", "el-date-picker"},
		{"_date", "el-date-picker"},
		{"_datetime", "el-date-picker"},
		{"_at", "el-date-picker"},
		{"_content", "el-editor"},
		{"_body", "el-editor"},
		{"_text", "el-editor"},
		{"_html", "el-editor"},
		{"_price", "el-input-number"},
		{"_amount", "el-input-number"},
		{"_qty", "el-input-number"},
		{"_count", "el-input-number"},
		{"_number", "el-input-number"},
		{"_num", "el-input-number"},
		{"_type", "el-select"},
		{"_category", "el-select"},
		{"_level", "el-select"},
		{"_role", "el-select"},
		{"_permission", "el-select"},
		{"_status", "el-select"},
		{"_state", "el-select"},
		{"_flag", "el-select"},
		{"_color", "el-color-picker"},
		{"_rate", "el-rate"},
		{"_rating", "el-rate"},
		{"_id", "el-select"},
	}
}

func fieldPrefixMap() map[string]string {
	return map[string]string{
		"is_":  "el-switch",
		"has_": "el-switch",
		"can_": "el-switch",
	}
}

func fieldContainsMap() map[string]string {
	return map[string]string{
		"password":   "el-input",
		"email":      "el-input",
		"phone":      "el-input",
		"mobile":     "el-input",
		"url":        "el-input",
		"color":      "el-color-picker",
		"attr":       "el-select",
		"type":       "el-select",
		"category":   "el-select",
		"level":      "el-select",
		"role":       "el-select",
		"permission": "el-select",
		"status":     "el-select",
		"state":      "el-select",
		"flag":       "el-select",
		"logo":       "ma-upload-image",
		"avatar":     "ma-upload-image",
		"image":      "ma-upload-image",
		"img":        "ma-upload-image",
		"cover":      "ma-upload-image",
		"icon":       "ma-upload-image",
		"photo":      "ma-upload-image",
		"file":       "ma-upload-file",
		"attachment": "ma-upload-file",
		"content":    "el-editor",
		"body":       "el-editor",
		"text":       "el-editor",
		"html":       "el-editor",
	}
}

func stringInSlice(s string, list []string) bool {
	for _, x := range list {
		if x == s {
			return true
		}
	}
	return false
}

func containsAnySub(s string, subs []string) bool {
	for _, sub := range subs {
		if sub != "" && containsFold(s, sub) {
			return true
		}
	}
	return false
}

func containsFold(hay, sub string) bool {
	return strings.Contains(strings.ToLower(hay), strings.ToLower(sub))
}
