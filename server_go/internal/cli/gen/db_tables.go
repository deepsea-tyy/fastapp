package gen

import (
	"fmt"
	"strings"

	"fastapp/internal/config"

	"gorm.io/gorm"
)

// ListBaseTableNames 列出当前库中 BASE TABLE，可选按前缀过滤（prefix 非空时 TABLE_NAME LIKE prefix%）。
func ListBaseTableNames(db *gorm.DB, cfg config.Config, prefix string) ([]string, error) {
	if db == nil {
		return nil, fmt.Errorf("no database")
	}
	q := `SELECT TABLE_NAME FROM information_schema.TABLES
		WHERE TABLE_SCHEMA = ? AND TABLE_TYPE = 'BASE TABLE'`
	args := []interface{}{cfg.DBDatabase}
	if prefix != "" {
		q += ` AND TABLE_NAME LIKE ?`
		args = append(args, prefix+"%")
	}
	q += ` ORDER BY TABLE_NAME`
	var names []string
	if err := db.Raw(q, args...).Pluck("TABLE_NAME", &names).Error; err != nil {
		return nil, err
	}
	return names, nil
}

// CoreTableNames 过滤掉插件表后的业务表全名列表。shortName 为去掉 DB_PREFIX 后的名称。
func CoreTableNames(all []string, dbPrefix string, pluginSet map[string]struct{}) []string {
	var out []string
	for _, full := range all {
		short := full
		if dbPrefix != "" && strings.HasPrefix(full, dbPrefix) {
			short = strings.TrimPrefix(full, dbPrefix)
		}
		if IsPluginTable(full, short, pluginSet) {
			continue
		}
		out = append(out, full)
	}
	return out
}
