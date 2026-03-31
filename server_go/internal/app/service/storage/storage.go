package storage

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net/url"
	"strings"

	"gorm.io/gorm"
)

// FileStorage 上传/分片/删除抽象（对象键使用正斜杠，如 20250329/uuid.png；分片 tmp/{hash}/{i}.tmp）。
type FileStorage interface {
	StorageMode() string
	Put(ctx context.Context, objectKey string, r io.Reader, size int64) error
	PublicURL(objectKey string) string
	Delete(ctx context.Context, objectKey string) error
	ChunkWrite(ctx context.Context, hash string, chunkIndex int, r io.Reader) error
	ChunkOpen(ctx context.Context, hash string, chunkIndex int) (io.ReadCloser, error)
	ChunkDeleteAll(ctx context.Context, hash string, totalChunks int)
}

// New 按 DB 中 sys_storage 构建实现；local 模式要求 uploadRoot 非空。
func New(ctx context.Context, db *gorm.DB, uploadRoot string) (FileStorage, error) {
	cfg, err := LoadConfig(ctx, db)
	if err != nil {
		return nil, err
	}
	switch cfg.Mode {
	case ModeLocal:
		if uploadRoot == "" {
			return nil, errors.New("upload storage not configured")
		}
		return newLocalStorage(uploadRoot), nil
	case ModeOSS:
		return newOSSStorage(cfg)
	case ModeQiniu:
		return newQiniuStorage(cfg)
	case ModeCOS:
		return newCOSStorage(cfg)
	default:
		return nil, errors.New("unknown storage_mode")
	}
}

func chunkObjectKey(hash string, chunkIndex int) string {
	return fmt.Sprintf("tmp/%s/%d.tmp", hash, chunkIndex)
}

// ObjectKeyFromPublicURL 从入库的 url 还原对象键（local: /uploads/a/b；云: http(s)://host/a/b）。
func ObjectKeyFromPublicURL(fileURL string, mode string) (string, error) {
	fileURL = strings.TrimSpace(fileURL)
	if fileURL == "" {
		return "", errors.New("empty url")
	}
	switch Mode(mode) {
	case ModeLocal:
		const pfx = "/uploads/"
		if !strings.HasPrefix(fileURL, pfx) {
			return "", errors.New("local url must start with /uploads/")
		}
		return strings.TrimPrefix(fileURL, pfx), nil
	default:
		u, err := url.Parse(fileURL)
		if err != nil {
			return "", err
		}
		k := strings.Trim(u.Path, "/")
		if k == "" {
			return "", errors.New("no path in url")
		}
		return k, nil
	}
}
