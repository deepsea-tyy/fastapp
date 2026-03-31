package gen

import (
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	tools "fastapp/internal/app/common"
)

var reSQLCreateTable = regexp.MustCompile("(?i)CREATE\\s+TABLE(?:\\s+IF\\s+NOT\\s+EXISTS)?\\s+`([^`]+)`")

// ResolvePluginMigrationsRoot 返回本仓库 plugin/ 根路径（存在且为目录时），否则空字符串。
func ResolvePluginMigrationsRoot(serverGoRoot string) string {
	p := tools.PluginRoot(serverGoRoot)
	if st, err := os.Stat(p); err == nil && st.IsDir() {
		return filepath.Clean(p)
	}
	return ""
}

func extractSchemaTables(pluginRoot string) []string {
	if pluginRoot == "" {
		return nil
	}
	seen := make(map[string]struct{})
	var out []string
	_ = filepath.WalkDir(pluginRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return nil
		}
		if !strings.Contains(strings.ToLower(filepath.ToSlash(path)), "/database/migrations/") {
			return nil
		}
		if strings.ToLower(filepath.Ext(path)) != ".sql" {
			return nil
		}
		b, err := os.ReadFile(path)
		if err != nil {
			return nil
		}
		for _, m := range reSQLCreateTable.FindAllSubmatch(b, -1) {
			if len(m) < 2 {
				continue
			}
			t := strings.TrimSpace(string(m[1]))
			t = strings.TrimPrefix(t, "{{prefix}}")
			if t == "" {
				continue
			}
			if _, ok := seen[t]; ok {
				continue
			}
			seen[t] = struct{}{}
			out = append(out, t)
		}
		return nil
	})
	return out
}

// PluginTableSet 根据插件迁移 .sql 中的 CREATE 收集表名；键为逻辑表名及去掉 DB_PREFIX 的短名（若可拆）。
func PluginTableSet(pluginRoot, dbPrefix string) map[string]struct{} {
	m := make(map[string]struct{})
	for _, t := range extractSchemaTables(pluginRoot) {
		m[t] = struct{}{}
		if dbPrefix != "" && strings.HasPrefix(t, dbPrefix) {
			m[strings.TrimPrefix(t, dbPrefix)] = struct{}{}
		}
	}
	return m
}

// IsPluginTable 判断全表名或短表名是否在插件集合中。
func IsPluginTable(fullTable, shortName string, pluginSet map[string]struct{}) bool {
	if pluginSet == nil {
		return false
	}
	if _, ok := pluginSet[fullTable]; ok {
		return true
	}
	if _, ok := pluginSet[shortName]; ok {
		return true
	}
	return false
}
