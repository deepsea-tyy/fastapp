package gen

import (
	"database/sql"
	"fmt"
	"strings"

	"fastapp/internal/app/model"
	"fastapp/internal/config"

	"gorm.io/gorm"
)

// ColumnMeta information_schema 列元数据（供模板生成 GORM 模型）。
type ColumnMeta struct {
	Ordinal    int     `gorm:"column:ORDINAL_POSITION"`
	Name       string  `gorm:"column:COLUMN_NAME"`
	DataType   string  `gorm:"column:DATA_TYPE"`
	ColumnType string  `gorm:"column:COLUMN_TYPE"`
	Nullable   string  `gorm:"column:IS_NULLABLE"`
	Key        string  `gorm:"column:COLUMN_KEY"`
	Extra      string  `gorm:"column:EXTRA"`
	Comment    string  `gorm:"column:COLUMN_COMMENT"`
	ColDefault *string `gorm:"column:COLUMN_DEFAULT"`
}

// ListColumnMeta 读取表全部列。
func ListColumnMeta(db *gorm.DB, cfg config.Config, table string) ([]ColumnMeta, error) {
	if db == nil {
		return nil, fmt.Errorf("no database")
	}
	full := model.P + table
	var rows []ColumnMeta
	sql := `SELECT ORDINAL_POSITION, COLUMN_NAME, DATA_TYPE, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, EXTRA, COLUMN_COMMENT, COLUMN_DEFAULT
		FROM information_schema.COLUMNS
		WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
		ORDER BY ORDINAL_POSITION`
	if err := db.Raw(sql, cfg.DBDatabase, full).Scan(&rows).Error; err != nil {
		return nil, err
	}
	return rows, nil
}

// TableComment 表注释。
func TableComment(db *gorm.DB, cfg config.Config, table string) (string, error) {
	full := model.P + table
	var ns sql.NullString
	err := db.Raw(`SELECT TABLE_COMMENT FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?`,
		cfg.DBDatabase, full).Scan(&ns).Error
	if err != nil {
		return "", err
	}
	s := strings.TrimSpace(ns.String)
	if s == "" {
		return table, nil
	}
	return s, nil
}
