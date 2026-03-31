package storage

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"net/url"

	"github.com/tencentyun/cos-go-sdk-v5"
)

type cosStorage struct {
	client *cos.Client
	cfg    Config
}

func newCOSStorage(c Config) (*cosStorage, error) {
	raw := fmt.Sprintf("https://%s.cos.%s.myqcloud.com", c.COSBucket, c.COSRegion)
	u, err := url.Parse(raw)
	if err != nil {
		return nil, err
	}
	b := &cos.BaseURL{BucketURL: u}
	client := cos.NewClient(b, &http.Client{
		Transport: &cos.AuthorizationTransport{
			SecretID:  c.COSSecretID,
			SecretKey: c.COSSecretKey,
		},
	})
	return &cosStorage{client: client, cfg: c}, nil
}

func (s *cosStorage) StorageMode() string { return string(ModeCOS) }

func (s *cosStorage) Put(ctx context.Context, objectKey string, r io.Reader, size int64) error {
	_, err := s.client.Object.Put(ctx, objectKey, r, nil)
	return err
}

func (s *cosStorage) PublicURL(objectKey string) string {
	return publicJoin(s.cfg.COSSchema, s.cfg.COSDomain, objectKey)
}

func (s *cosStorage) Delete(ctx context.Context, objectKey string) error {
	_, err := s.client.Object.Delete(ctx, objectKey)
	return err
}

func (s *cosStorage) ChunkWrite(ctx context.Context, hash string, chunkIndex int, r io.Reader) error {
	return s.Put(ctx, chunkObjectKey(hash, chunkIndex), r, -1)
}

func (s *cosStorage) ChunkOpen(ctx context.Context, hash string, chunkIndex int) (io.ReadCloser, error) {
	resp, err := s.client.Object.Get(ctx, chunkObjectKey(hash, chunkIndex), nil)
	if err != nil {
		return nil, err
	}
	return resp.Body, nil
}

func (s *cosStorage) ChunkDeleteAll(ctx context.Context, hash string, totalChunks int) {
	for i := 0; i < totalChunks; i++ {
		_ = s.Delete(ctx, chunkObjectKey(hash, i))
	}
}
