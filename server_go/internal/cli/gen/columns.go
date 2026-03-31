package gen

import (
	"fmt"

	"fastapp/internal/app/model"
	"fastapp/internal/config"

	"gorm.io/gorm"
)

// ColumnRow information_schema 列信息（用于后续模板生成）
type ColumnRow struct {
	ColumnName string `gorm:"column:COLUMN_NAME"`
	DataType   string `gorm:"column:DATA_TYPE"`
}

// ListColumns 列出表字段（不含生成文件，供 CLI 展示）
func ListColumns(db *gorm.DB, cfg config.Config, table string) ([]ColumnRow, error) {
	if db == nil {
		return nil, fmt.Errorf("no database")
	}
	full := model.P + table
	var rows []ColumnRow
	sql := `SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.COLUMNS 
		WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION`
	if err := db.Raw(sql, cfg.DBDatabase, full).Scan(&rows).Error; err != nil {
		return nil, err
	}
	return rows, nil
}
