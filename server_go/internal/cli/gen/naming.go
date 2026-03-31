package gen

import (
	"strings"

	"github.com/jinzhu/inflection"
)

// ExportedField 蛇形列名 -> 导出 Go 字段名（id -> ID, user_id -> UserID）。
func ExportedField(col string) string {
	col = strings.TrimSpace(col)
	if col == "" {
		return ""
	}
	parts := strings.Split(col, "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		switch strings.ToLower(p) {
		case "id":
			parts[i] = "ID"
		case "url":
			parts[i] = "URL"
		case "api":
			parts[i] = "API"
		default:
			parts[i] = strings.ToUpper(p[:1]) + strings.ToLower(p[1:])
		}
	}
	return strings.Join(parts, "")
}

// StructNameFromTable 表名（无前缀）-> 结构体名单数形式 + PascalCase，如 user_roles -> UserRole。
func StructNameFromTable(table string) string {
	t := strings.TrimSpace(table)
	if t == "" {
		return "Model"
	}
	sing := inflection.Singular(t)
	parts := strings.Split(sing, "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		parts[i] = strings.ToUpper(p[:1]) + strings.ToLower(p[1:])
	}
	return strings.Join(parts, "")
}
