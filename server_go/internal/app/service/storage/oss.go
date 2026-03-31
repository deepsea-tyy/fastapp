package storage

import (
	"context"
	"io"
	"strings"

	"github.com/aliyun/aliyun-oss-go-sdk/oss"
)

type ossStorage struct {
	bucket *oss.Bucket
	cfg    Config
}

func newOSSStorage(cfg Config) (*ossStorage, error) {
	client, err := oss.New(cfg.OSSEndpoint, cfg.OSSAccessID, cfg.OSSAccessSecret)
	if err != nil {
		return nil, err
	}
	b, err := client.Bucket(cfg.OSSBucket)
	if err != nil {
		return nil, err
	}
	return &ossStorage{bucket: b, cfg: cfg}, nil
}

func (s *ossStorage) StorageMode() string { return string(ModeOSS) }

func (s *ossStorage) Put(ctx context.Context, objectKey string, r io.Reader, size int64) error {
	_ = ctx
	return s.bucket.PutObject(objectKey, r)
}

func (s *ossStorage) PublicURL(objectKey string) string {
	return publicJoin(s.cfg.OSSSchema, s.cfg.OSSDomain, objectKey)
}

func (s *ossStorage) Delete(ctx context.Context, objectKey string) error {
	_ = ctx
	return s.bucket.DeleteObject(objectKey)
}

func (s *ossStorage) ChunkWrite(ctx context.Context, hash string, chunkIndex int, r io.Reader) error {
	return s.Put(ctx, chunkObjectKey(hash, chunkIndex), r, -1)
}

func (s *ossStorage) ChunkOpen(ctx context.Context, hash string, chunkIndex int) (io.ReadCloser, error) {
	_ = ctx
	return s.bucket.GetObject(chunkObjectKey(hash, chunkIndex))
}

func (s *ossStorage) ChunkDeleteAll(ctx context.Context, hash string, totalChunks int) {
	for i := 0; i < totalChunks; i++ {
		_ = s.Delete(ctx, chunkObjectKey(hash, i))
	}
}

func publicJoin(schema, dom, objectKey string) string {
	sch := strings.TrimSpace(schema)
	if sch == "" {
		sch = "http://"
	}
	if !strings.HasSuffix(sch, "://") {
		sch = sch + "://"
	}
	d := strings.Trim(strings.TrimSpace(dom), "/")
	k := strings.Trim(strings.ReplaceAll(objectKey, "\\", "/"), "/")
	return sch + d + "/" + k
}
