package gen

import (
	"path/filepath"
	"strings"
)

// SingularizeTableName 。
func SingularizeTableName(tableName string) string {
	parts := strings.Split(strings.TrimSpace(tableName), "_")
	if len(parts) == 0 {
		return tableName
	}
	last := parts[len(parts)-1]
	switch {
	case strings.HasSuffix(last, "ies") && len(last) > 3:
		last = strings.TrimSuffix(last, "ies") + "y"
	case strings.HasSuffix(last, "es") && !strings.HasSuffix(last, "ies") && last != "status":
		last = strings.TrimSuffix(last, "es")
	case strings.HasSuffix(last, "s") && !strings.HasSuffix(last, "ss") && !strings.HasSuffix(last, "us") && len(last) > 1:
		last = strings.TrimSuffix(last, "s")
	}
	parts[len(parts)-1] = last
	return strings.Join(parts, "_")
}

// CamelFromSnake 小驼峰：search_keyword -> searchKeyword。
func CamelFromSnake(s string) string {
	parts := strings.Split(strings.TrimSpace(s), "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		if i == 0 {
			parts[i] = strings.ToLower(p[:1]) + p[1:]
		} else {
			parts[i] = strings.ToUpper(p[:1]) + strings.ToLower(p[1:])
		}
	}
	return strings.Join(parts, "")
}

// SnakeFromPascal SearchKeyword -> search_keyword。
func SnakeFromPascal(s string) string {
	if s == "" {
		return ""
	}
	var b strings.Builder
	for i, r := range s {
		if i > 0 && r >= 'A' && r <= 'Z' {
			b.WriteByte('_')
		}
		if r >= 'A' && r <= 'Z' {
			b.WriteRune(r - 'A' + 'a')
		} else {
			b.WriteRune(r)
		}
	}
	return b.String()
}

// LowerFirst SearchKeyword -> searchKeyword（仅首字母小写，用于插件 handler 前缀合成时可组合）。
func LowerFirst(s string) string {
	if s == "" {
		return ""
	}
	return strings.ToLower(s[:1]) + s[1:]
}

// studlyFromSnakeSegment foo_bar -> FooBar（对齐 Laravel Str::studly）。
func studlyFromSnakeSegment(s string) string {
	parts := strings.Split(strings.TrimSpace(s), "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		parts[i] = strings.ToUpper(p[:1]) + strings.ToLower(p[1:])
	}
	return strings.Join(parts, "")
}

// ModuleURLSegment 。
func ModuleURLSegment(module string) string {
	module = strings.TrimSpace(module)
	if module == "" {
		return ""
	}
	if !strings.Contains(module, "/") {
		return strings.ToLower(module)
	}
	parts := strings.Split(strings.ToLower(module), "/")
	last := strings.TrimSpace(parts[len(parts)-1])
	if last == "" {
		return strings.ToLower(module)
	}
	return SnakeFromPascal(studlyFromSnakeSegment(last))
}

// ResourceURLSegment 与 moduleSeg 组合为 /admin/{mod}/{res}。
func ResourceURLSeg(moduleSeg, table string, structName string) string {
	tl := strings.ToLower(strings.TrimSpace(table))
	ms := strings.ToLower(strings.TrimSpace(moduleSeg))
	if ms != "" && strings.HasPrefix(tl, ms+"_") {
		return strings.TrimPrefix(tl, ms+"_")
	}
	return SnakeFromPascal(structName)
}

// APITSFileBase api 文件名（不含 .ts）：keyword / placementPosition。
func APITSFileBase(resourceSeg string) string {
	return ToLowerCamelFromSnake(resourceSeg)
}

// TSVoNameFromResource KeywordVo。
func TSVoNameFromResource(resourceSeg string) string {
	p := CamelFromSnake(resourceSeg)
	if p == "" {
		return "Vo"
	}
	return strings.ToUpper(p[:1]) + p[1:] + "Vo"
}

// ToLowerCamelFromSnake placement_position -> placementPosition；keyword -> keyword。
func ToLowerCamelFromSnake(s string) string {
	parts := strings.Split(strings.TrimSpace(s), "_")
	if len(parts) == 0 {
		return ""
	}
	for i := range parts {
		if parts[i] == "" {
			continue
		}
		if i == 0 {
			parts[i] = strings.ToLower(parts[i][:1]) + parts[i][1:]
		} else {
			parts[i] = strings.ToUpper(parts[i][:1]) + strings.ToLower(parts[i][1:])
		}
	}
	return strings.Join(parts, "")
}

// NormalizePluginPath ds/sysCms。
func NormalizePluginPath(plugin string) string {
	return filepath.ToSlash(strings.Trim(strings.TrimSpace(plugin), "/"))
}

// PluginPermColonBase ds:sysCms。
func PluginPermColonBase(pluginPath string) string {
	p := strings.Split(pluginPath, "/")
	return strings.Join(p, ":")
}
