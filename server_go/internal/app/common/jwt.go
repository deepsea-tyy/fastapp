package tools

import (
	"context"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"

	"fastapp/internal/config"

	"github.com/golang-jwt/jwt/v5"
	"github.com/redis/go-redis/v9"
)

const audienceRefresh = "refresh"

var (
	ErrInvalidToken = errors.New("invalid token")
	ErrExpired      = errors.New("token expired")
	ErrBlacklisted  = errors.New("token blacklisted")
)

// Scene JWT 场景（管理端 default / App api）
type Scene string

const (
	SceneAdmin Scene = "default"
	SceneAPI   Scene = "api"
)

// Service 签发/校验 HS256 JWT；黑名单键为 CACHE_PREFIX + 完整 token。
type Service struct {
	cfg         config.Config
	secret      []byte
	rdb         *redis.Client
	cachePrefix string
}

func NewService(cfg config.Config, scene Scene, rdb *redis.Client) (*Service, error) {
	sec := cfg.JWTSecret
	if scene == SceneAPI {
		sec = cfg.JWTAPIsecret
	}
	if sec == "" {
		return nil, fmt.Errorf("jwt secret empty for scene %s", scene)
	}
	key, err := parseJWTKey(sec)
	if err != nil {
		return nil, err
	}
	return &Service{cfg: cfg, secret: key, rdb: rdb, cachePrefix: cfg.CachePrefix}, nil
}

// JWT 密钥：可为 Base64 或明文。
func parseJWTKey(secret string) ([]byte, error) {
	decoded, err := base64.StdEncoding.DecodeString(secret)
	if err == nil && len(decoded) > 0 && base64.StdEncoding.EncodeToString(decoded) == secret {
		return decoded, nil
	}
	return []byte(secret), nil
}

type claims struct {
	jwt.RegisteredClaims
}

func (s *Service) IssuePair(userID int64) (access, refresh string, ttlSec int, err error) {
	now := time.Now()
	uid := fmt.Sprintf("%d", userID)
	ttl := time.Duration(s.cfg.JWTTTL) * time.Second
	rt := time.Duration(s.cfg.JWTRefreshTTL) * time.Second

	accessClaims := claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    s.cfg.APPName,
			Subject:   uid,
			ID:        uid, // jti，业务侧常作为用户 ID 读取
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(ttl)),
		},
	}
	at := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	access, err = at.SignedString(s.secret)
	if err != nil {
		return "", "", 0, err
	}

	refreshClaims := claims{
		RegisteredClaims: jwt.RegisteredClaims{
			Issuer:    s.cfg.APPName,
			Subject:   uid,
			ID:        uid,
			Audience:  jwt.ClaimStrings{audienceRefresh},
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(rt)),
		},
	}
	rtok := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refresh, err = rtok.SignedString(s.secret)
	if err != nil {
		return "", "", 0, err
	}
	return access, refresh, s.cfg.JWTTTL, nil
}

func (s *Service) ParseAccess(tokenStr string) (*jwt.Token, int64, error) {
	return s.parse(tokenStr, false)
}

func (s *Service) ParseRefresh(tokenStr string) (*jwt.Token, int64, error) {
	return s.parse(tokenStr, true)
}

func (s *Service) parse(tokenStr string, wantRefresh bool) (*jwt.Token, int64, error) {
	tokenStr = strings.TrimPrefix(strings.TrimSpace(tokenStr), "Bearer ")
	tok, err := jwt.ParseWithClaims(tokenStr, &claims{}, func(t *jwt.Token) (any, error) {
		return s.secret, nil
	})
	if err != nil || !tok.Valid {
		return nil, 0, ErrInvalidToken
	}
	c, ok := tok.Claims.(*claims)
	if !ok {
		return nil, 0, ErrInvalidToken
	}
	isRefresh := false
	for _, a := range c.Audience {
		if a == audienceRefresh {
			isRefresh = true
			break
		}
	}
	if wantRefresh && !isRefresh {
		return nil, 0, ErrInvalidToken
	}
	if !wantRefresh && isRefresh {
		return nil, 0, ErrInvalidToken
	}
	// 黑名单：Redis 键 = CACHE_PREFIX + 完整 JWT 字符串。
	if s.rdb != nil && s.cachePrefix != "" {
		key := s.cachePrefix + tokenStr
		ctx := context.Background()
		n, err := s.rdb.Exists(ctx, key).Result()
		if err == nil && n > 0 {
			return nil, 0, ErrBlacklisted
		}
	}
	uid := c.ID
	if uid == "" {
		uid = c.Subject
	}
	var id int64
	_, scanErr := fmt.Sscanf(uid, "%d", &id)
	if scanErr != nil || id == 0 {
		return nil, 0, ErrInvalidToken
	}
	return tok, id, nil
}

func (s *Service) AddBlacklist(tokenStr string) error {
	if s.rdb == nil || s.cachePrefix == "" {
		return nil
	}
	tokenStr = strings.TrimPrefix(strings.TrimSpace(tokenStr), "Bearer ")
	ttl := time.Duration(s.cfg.JWTBlacklistTTL) * time.Second
	key := s.cachePrefix + tokenStr
	return s.rdb.Set(context.Background(), key, "1", ttl).Err()
}

// CaptchaKey 管理端验证码 Redis 键前缀
func CaptchaKey(ip string) string {
	return "admin:captcha:" + ip
}

func IsProd() bool {
	return os.Getenv("APP_ENV") == "prod"
}

// HashTokenKey 用于 WS 等场景避免 Redis 键过长
func HashTokenKey(token string) string {
	h := sha256.Sum256([]byte(token))
	return base64.RawURLEncoding.EncodeToString(h[:])
}
