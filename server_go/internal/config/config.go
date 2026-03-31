package config

import (
	"fmt"
	"os"
	"strconv"
)

// Config 运行时配置（环境变量 / .env）
type Config struct {
	Env      string
	HTTPPort int
	WSPort   int

	// MySQL
	DBDriver   string
	DBHost     string
	DBPort     int
	DBDatabase string
	DBUsername string
	DBPassword string
	DBCharset  string
	DBPrefix   string
	// DBLogLevel：GORM SQL 日志级别，见 .env.example（silent / error / warn / info）
	DBLogLevel string

	// Redis（cache 前缀配合 JWT 黑名单）
	RedisHost string
	RedisPort int
	RedisPass string
	RedisDB   int

	CachePrefix string // 如 fastapp:

	// JWT
	JWTSecret       string
	JWTAPIsecret    string
	JWTTTL          int
	JWTRefreshTTL   int
	JWTBlacklistTTL int
	APPName         string
}

func getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func getenvInt(key string, def int) int {
	v := os.Getenv(key)
	if v == "" {
		return def
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return def
	}
	return n
}

// RedisAuth 优先 REDIS_AUTH，否则 REDIS_PASSWORD
func redisAuth() string {
	if v := os.Getenv("REDIS_AUTH"); v != "" {
		return v
	}
	return getenv("REDIS_PASSWORD", "")
}

func Load() Config {
	return Config{
		Env:      getenv("APP_ENV", "dev"),
		HTTPPort: getenvInt("APP_PORT", 9501),
		WSPort:   getenvInt("APP_WS_PORT", 9502),

		DBDriver:   getenv("DB_DRIVER", "mysql"),
		DBHost:     getenv("DB_HOST", "127.0.0.1"),
		DBPort:     getenvInt("DB_PORT", 3306),
		DBDatabase: getenv("DB_DATABASE", "fastapp"),
		DBUsername: getenv("DB_USERNAME", "root"),
		DBPassword: getenv("DB_PASSWORD", ""),
		DBCharset:  getenv("DB_CHARSET", "utf8mb4"),
		DBPrefix:   getenv("DB_PREFIX", ""),
		DBLogLevel: getenv("DB_LOG_LEVEL", "warn"),

		RedisHost: getenv("REDIS_HOST", "127.0.0.1"),
		RedisPort: getenvInt("REDIS_PORT", 6379),
		RedisPass: redisAuth(),
		RedisDB:   getenvInt("REDIS_DB", 0),

		CachePrefix: getenv("CACHE_PREFIX", "fastapp:"),

		JWTSecret:       getenv("JWT_SECRET", ""),
		JWTAPIsecret:    getenv("JWT_API_SECRET", ""),
		JWTTTL:          getenvInt("JWT_TTL", 3600),
		JWTRefreshTTL:   getenvInt("JWT_REFRESH_TTL", 7200),
		JWTBlacklistTTL: getenvInt("JWT_BLACKLIST_TTL", 7201),
		APPName:         getenv("APP_NAME", "fastapp"),
	}
}

// DSN 构建 MySQL DSN（未设置 DB_DATABASE 时返回空表示跳过 DB）
func (c Config) DSN() string {
	if c.DBDatabase == "" {
		return ""
	}
	return fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?charset=%s&parseTime=True&loc=Local",
		c.DBUsername, c.DBPassword, c.DBHost, c.DBPort, c.DBDatabase, c.DBCharset)
}
