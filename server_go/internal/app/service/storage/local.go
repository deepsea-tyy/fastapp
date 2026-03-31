package storage

import (
	"context"
	"io"
	"os"
	"path/filepath"
	"strings"
)

type localStorage struct {
	root string
}

func newLocalStorage(root string) *localStorage {
	return &localStorage{root: root}
}

func (s *localStorage) StorageMode() string { return string(ModeLocal) }

func (s *localStorage) absKey(objectKey string) string {
	objectKey = filepath.FromSlash(objectKey)
	return filepath.Join(s.root, objectKey)
}

func (s *localStorage) Put(ctx context.Context, objectKey string, r io.Reader, size int64) error {
	full := s.absKey(objectKey)
	if err := os.MkdirAll(filepath.Dir(full), 0o755); err != nil {
		return err
	}
	out, err := os.Create(full)
	if err != nil {
		return err
	}
	defer out.Close()
	_, err = io.Copy(out, r)
	return err
}

func (s *localStorage) PublicURL(objectKey string) string {
	k := strings.Trim(objectKey, "/")
	return "/uploads/" + filepath.ToSlash(k)
}

func (s *localStorage) Delete(ctx context.Context, objectKey string) error {
	return os.Remove(s.absKey(objectKey))
}

func (s *localStorage) ChunkWrite(ctx context.Context, hash string, chunkIndex int, r io.Reader) error {
	return s.Put(ctx, chunkObjectKey(hash, chunkIndex), r, -1)
}

func (s *localStorage) ChunkOpen(ctx context.Context, hash string, chunkIndex int) (io.ReadCloser, error) {
	return os.Open(s.absKey(chunkObjectKey(hash, chunkIndex)))
}

func (s *localStorage) ChunkDeleteAll(ctx context.Context, hash string, totalChunks int) {
	for i := 0; i < totalChunks; i++ {
		_ = s.Delete(ctx, chunkObjectKey(hash, i))
	}
	_ = os.RemoveAll(filepath.Join(s.root, "tmp", hash))
}
