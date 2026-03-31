package store

import (
	"fmt"
	"log/slog"

	"fastapp/internal/config"

	gmysql "gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func OpenMySQL(cfg config.Config) (*gorm.DB, error) {
	dsn := cfg.DSN()
	if dsn == "" {
		return nil, nil
	}
	db, err := gorm.Open(gmysql.Open(dsn), &gorm.Config{
		Logger: newRouteAwareLogger(logger.Default.LogMode(GormLogLevel(cfg.DBLogLevel))),
	})
	if err != nil {
		return nil, fmt.Errorf("gorm open: %w", err)
	}
	sqlDB, err := db.DB()
	if err != nil {
		return nil, err
	}
	sqlDB.SetMaxIdleConns(5)
	sqlDB.SetMaxOpenConns(20)
	slog.Info("mysql connected", "db", cfg.DBDatabase)
	return db, nil
}
