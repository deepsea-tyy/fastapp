package storage

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/qiniu/go-sdk/v7/auth/qbox"
	"github.com/qiniu/go-sdk/v7/storage"
)

type qiniuStorage struct {
	mac    *qbox.Mac
	bucket string
	cfg    storage.Config
	pubCfg Config
}

func newQiniuStorage(c Config) (*qiniuStorage, error) {
	mac := qbox.NewMac(c.QiniuAccessKey, c.QiniuSecretKey)
	return &qiniuStorage{
		mac:    mac,
		bucket: c.QiniuBucket,
		cfg:    storage.Config{},
		pubCfg: c,
	}, nil
}

func (s *qiniuStorage) StorageMode() string { return string(ModeQiniu) }

func (s *qiniuStorage) Put(ctx context.Context, objectKey string, r io.Reader, size int64) error {
	putPolicy := storage.PutPolicy{Scope: s.bucket}
	upToken := putPolicy.UploadToken(s.mac)
	uploader := storage.NewFormUploader(&s.cfg)
	var ret storage.PutRet
	extra := storage.PutExtra{}
	if size < 0 {
		b, err := io.ReadAll(r)
		if err != nil {
			return err
		}
		return uploader.Put(ctx, &ret, upToken, objectKey, bytes.NewReader(b), int64(len(b)), &extra)
	}
	return uploader.Put(ctx, &ret, upToken, objectKey, r, size, &extra)
}

func (s *qiniuStorage) PublicURL(objectKey string) string {
	return publicJoin(s.pubCfg.QiniuSchema, s.pubCfg.QiniuDomain, objectKey)
}

func (s *qiniuStorage) Delete(ctx context.Context, objectKey string) error {
	_ = ctx
	bm := storage.NewBucketManager(s.mac, &s.cfg)
	return bm.Delete(s.bucket, objectKey)
}

func (s *qiniuStorage) ChunkWrite(ctx context.Context, hash string, chunkIndex int, r io.Reader) error {
	b, err := io.ReadAll(r)
	if err != nil {
		return err
	}
	putPolicy := storage.PutPolicy{Scope: s.bucket}
	upToken := putPolicy.UploadToken(s.mac)
	uploader := storage.NewFormUploader(&s.cfg)
	var ret storage.PutRet
	return uploader.Put(ctx, &ret, upToken, chunkObjectKey(hash, chunkIndex), bytes.NewReader(b), int64(len(b)), &storage.PutExtra{})
}

func (s *qiniuStorage) ChunkOpen(ctx context.Context, hash string, chunkIndex int) (io.ReadCloser, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, s.PublicURL(chunkObjectKey(hash, chunkIndex)), nil)
	if err != nil {
		return nil, err
	}
	client := &http.Client{Timeout: 120 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		_ = resp.Body.Close()
		return nil, &httpError{code: resp.StatusCode}
	}
	return resp.Body, nil
}

func (s *qiniuStorage) ChunkDeleteAll(ctx context.Context, hash string, totalChunks int) {
	for i := 0; i < totalChunks; i++ {
		_ = s.Delete(ctx, chunkObjectKey(hash, i))
	}
}

type httpError struct {
	code int
}

func (e *httpError) Error() string { return fmt.Sprintf("http %d", e.code) }
