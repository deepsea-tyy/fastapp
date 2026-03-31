package verifycode

import (
	"context"
	"crypto/rand"
	"fmt"
	"math/big"
	"os"
	"time"

	"github.com/redis/go-redis/v9"
)

// 。
const (
	TypeSMS   = "sms"
	TypeEmail = "email"

	SceneDefault       = "default"
	SceneLogin         = "login"
	SceneRegister      = "register"
	SceneResetPassword = "reset_password"
	SceneBind          = "bind"
	SceneChange        = "change"
)

const ttlSec = 600
const intervalSec = 60
const codeLen = 6

func cacheKey(typ, target, scene string, countryCode int) string {
	if typ == TypeSMS {
		return fmt.Sprintf("sms:%s:%d:%s", scene, countryCode, target)
	}
	return fmt.Sprintf("email:%s:%s", scene, target)
}

// Send 写入 Redis 并返回是否成功；生产环境未接短信网关时仍将验证码写入 Redis，与「仅换 API 实现」场景一致。
func Send(ctx context.Context, rdb *redis.Client, typ, target, scene string, countryCode int) (ok bool, msg string) {
	if !isProd() {
		return true, "验证码发送成功（开发环境）"
	}
	if rdb == nil {
		return false, "redis unavailable"
	}
	key := cacheKey(typ, target, scene, countryCode)
	rem, err := rdb.TTL(ctx, key).Result()
	if err == nil && rem > 0 {
		elapsed := ttlSec - int(rem.Seconds())
		if elapsed < intervalSec {
			wait := intervalSec - elapsed
			return false, fmt.Sprintf("发送过于频繁，请 %d 秒后再试", wait)
		}
	}
	code, err := randomDigits(codeLen)
	if err != nil {
		return false, "生成验证码失败"
	}
	if err := rdb.Set(ctx, key, code, ttlSec*time.Second).Err(); err != nil {
		return false, "验证码缓存失败"
	}
	// 真实短信/邮件需对接网关；此处仅落库 Redis，。
	_ = code
	return true, "验证码发送成功"
}

func randomDigits(n int) (string, error) {
	const digits = "0123456789"
	b := make([]byte, n)
	for i := range b {
		v, err := rand.Int(rand.Reader, big.NewInt(int64(len(digits))))
		if err != nil {
			return "", err
		}
		b[i] = digits[v.Int64()]
	}
	return string(b), nil
}

// Verify 校验验证码；开发环境恒为 true。
func Verify(ctx context.Context, rdb *redis.Client, typ, target, vcode, scene string, clean bool, countryCode int) bool {
	if !isProd() {
		return true
	}
	if vcode == "" || rdb == nil {
		return false
	}
	key := cacheKey(typ, target, scene, countryCode)
	stored, err := rdb.Get(ctx, key).Result()
	if err != nil || stored == "" || stored != vcode {
		return false
	}
	if clean {
		_ = rdb.Del(ctx, key).Err()
	}
	return true
}

// 与 app/common tools.IsProd 一致；本包不 import common，避免与 tools→verifycode 循环依赖。
func isProd() bool {
	return os.Getenv("APP_ENV") == "prod"
}
