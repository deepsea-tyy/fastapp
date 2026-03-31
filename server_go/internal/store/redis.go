package store

import (
	"context"
	"fmt"
	"log/slog"

	"fastapp/internal/config"

	"github.com/redis/go-redis/v9"
)

func OpenRedis(cfg config.Config) (*redis.Client, error) {
	addr := fmt.Sprintf("%s:%d", cfg.RedisHost, cfg.RedisPort)
	rdb := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: cfg.RedisPass,
		DB:       cfg.RedisDB,
	})
	if err := rdb.Ping(context.Background()).Err(); err != nil {
		return nil, fmt.Errorf("redis ping: %w", err)
	}
	slog.Info("redis connected", "addr", addr)
	return rdb, nil
}
