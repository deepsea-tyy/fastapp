package storage

import (
	"context"
	"encoding/json"
	"errors"
	"strings"

	cfgmodel "fastapp/plugin/ds/sysConfig/src/model"

	"gorm.io/gorm"
)

// Mode 。
type Mode string

const (
	ModeLocal Mode = "local"
	ModeOSS   Mode = "oss"
	ModeQiniu Mode = "qiniu"
	ModeCOS   Mode = "cos"
)

// Config 后台「存储设置」解析结果（group_code = sys_storage）。
type Config struct {
	Mode Mode

	OSSAccessID     string
	OSSAccessSecret string
	OSSBucket       string
	OSSEndpoint     string
	OSSDomain       string
	OSSSchema       string

	QiniuAccessKey string
	QiniuSecretKey string
	QiniuBucket    string
	QiniuDomain    string
	QiniuSchema    string

	COSSecretID  string
	COSSecretKey string
	COSBucket    string
	COSDomain    string
	COSRegion    string
	COSSchema    string
}

func jsonConfigString(raw json.RawMessage) string {
	if len(raw) == 0 {
		return ""
	}
	var s string
	if json.Unmarshal(raw, &s) == nil {
		return strings.TrimSpace(s)
	}
	return strings.Trim(strings.TrimSpace(string(raw)), `"`)
}

// LoadConfig 从 system_config 读取 sys_storage。
func LoadConfig(ctx context.Context, db *gorm.DB) (Config, error) {
	var c Config
	if db == nil {
		return c, errors.New("db unavailable")
	}
	var rows []cfgmodel.SystemConfig
	if err := db.WithContext(ctx).Where("group_code = ?", "sys_storage").Find(&rows).Error; err != nil {
		return c, err
	}
	m := make(map[string]string, len(rows))
	for _, r := range rows {
		m[r.Key] = jsonConfigString(r.Value)
	}
	mode := Mode(strings.TrimSpace(m["storage_mode"]))
	if mode == "" {
		mode = ModeLocal
	}
	c = Config{
		Mode: mode,

		OSSAccessID:     m["oss_access_id"],
		OSSAccessSecret: m["oss_access_secret"],
		OSSBucket:       m["oss_bucket"],
		OSSEndpoint:     m["oss_endpoint"],
		OSSDomain:       strings.TrimSpace(m["oss_domain"]),
		OSSSchema:       "http://",

		QiniuAccessKey: m["qiniu_access_key"],
		QiniuSecretKey: m["qiniu_secret_key"],
		QiniuBucket:    m["qiniu_bucket"],
		QiniuDomain:    strings.TrimSpace(m["qiniu_domain"]),
		QiniuSchema:    "http://",

		COSSecretID:  m["cos_secret_id"],
		COSSecretKey: m["cos_secret_key"],
		COSBucket:    m["cos_bucket"],
		COSDomain:    strings.TrimSpace(m["cos_domain"]),
		COSRegion:    strings.TrimSpace(m["cos_region"]),
		COSSchema:    "http://",
	}
	return c, validateConfig(c)
}

func validateConfig(c Config) error {
	switch c.Mode {
	case ModeLocal:
		return nil
	case ModeOSS:
		if c.OSSAccessID == "" || c.OSSAccessSecret == "" || c.OSSBucket == "" || c.OSSEndpoint == "" || c.OSSDomain == "" {
			return errors.New("oss storage: missing access_id, access_secret, bucket, endpoint or domain")
		}
	case ModeQiniu:
		if c.QiniuAccessKey == "" || c.QiniuSecretKey == "" || c.QiniuBucket == "" || c.QiniuDomain == "" {
			return errors.New("qiniu storage: missing access_key, secret_key, bucket or domain")
		}
	case ModeCOS:
		if c.COSSecretID == "" || c.COSSecretKey == "" || c.COSBucket == "" || c.COSRegion == "" || c.COSDomain == "" {
			return errors.New("cos storage: missing secret_id, secret_key, bucket, region or domain")
		}
	default:
		return errors.New("unknown storage_mode")
	}
	return nil
}
