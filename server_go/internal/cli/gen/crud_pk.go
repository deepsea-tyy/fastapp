package gen

import (
	"fastapp/internal/app/model"
	"fastapp/internal/config"

	"gorm.io/gorm"
)

// PrimaryKeyColumn 返回主键列名（默认 id）。
func PrimaryKeyColumn(db *gorm.DB, cfg config.Config, table string) (string, error) {
	if db == nil {
		return "id", nil
	}
	full := model.P + table
	var col string
	err := db.Raw(`SELECT COLUMN_NAME FROM information_schema.STATISTICS
		WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND INDEX_NAME = 'PRI'
		ORDER BY SEQ_IN_INDEX LIMIT 1`, cfg.DBDatabase, full).Scan(&col).Error
	if err != nil || col == "" {
		return "id", err
	}
	return col, nil
}
