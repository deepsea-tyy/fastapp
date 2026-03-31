package user

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"unicode/utf8"

	"fastapp/internal/app/common/deps"

	"github.com/gin-gonic/gin"
	"golang.org/x/text/encoding/simplifiedchinese"
)

// StorageFileGet
func StorageFileGet(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		if h.D == nil || h.D.UploadDir == "" {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在",
				"data":    []any{},
			})
			return
		}
		raw := strings.TrimSpace(h.C.Query("path"))
		raw = strings.TrimPrefix(raw, "/")
		if raw == "" || strings.Contains(raw, "..") {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在",
				"data":    []any{},
			})
			return
		}
		if !strings.HasPrefix(raw, "uploads/") {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在",
				"data":    []any{},
			})
			return
		}
		rel := strings.TrimPrefix(raw, "uploads/")
		rel = filepath.ToSlash(rel)
		if rel == "" || rel == "." || strings.Contains(rel, "..") {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在",
				"data":    []any{},
			})
			return
		}
		full := filepath.Clean(filepath.Join(h.D.UploadDir, filepath.FromSlash(rel)))
		base := filepath.Clean(h.D.UploadDir)
		if !strings.HasPrefix(full, base+string(os.PathSeparator)) && full != base {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在",
				"data":    []any{},
			})
			return
		}
		st, err := os.Stat(full)
		if err != nil || st.IsDir() {
			h.C.JSON(http.StatusNotFound, gin.H{
				"code":    404,
				"message": "文件不存在" + full,
				"data":    []any{},
			})
			return
		}

		mimeType := mimeByExt(full)
		filename := filepath.Base(full)
		isVid := isVideoExt(full)
		acceptEnc := h.C.GetHeader("Accept-Encoding")
		hasCompression := acceptEnc != ""

		if isVid {
			f, err := os.Open(full)
			if err != nil {
				h.C.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "文件不存在", "data": []any{}})
				return
			}
			defer f.Close()
			chunk := int64(1024 * 1024)
			readSize := st.Size()
			if readSize > chunk {
				readSize = chunk
			}
			buf := make([]byte, readSize)
			n, _ := io.ReadFull(f, buf)
			buf = buf[:n]
			h.C.Header("Content-Type", mimeType)
			h.C.Header("Content-Disposition", fmt.Sprintf(`inline; filename="%s"`, filename))
			if !hasCompression {
				h.C.Header("Content-Length", fmt.Sprintf("%d", n))
			}
			h.C.Data(http.StatusOK, mimeType, buf)
			return
		}

		b, err := os.ReadFile(full)
		if err != nil {
			h.C.JSON(http.StatusNotFound, gin.H{"code": 404, "message": "文件不存在", "data": []any{}})
			return
		}
		if isTextExt(full) {
			b = []byte(toUTF8String(b))
		}
		h.C.Header("Content-Type", mimeType)
		h.C.Header("Content-Disposition", fmt.Sprintf(`inline; filename="%s"`, filename))
		if !hasCompression {
			h.C.Header("Content-Length", fmt.Sprintf("%d", len(b)))
		}
		h.C.Data(http.StatusOK, mimeType, b)
	})
}

func mimeByExt(p string) string {
	ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(p), "."))
	m := map[string]string{
		"jpg": "image/jpeg", "jpeg": "image/jpeg", "png": "image/png", "gif": "image/gif",
		"webp": "image/webp", "svg": "image/svg+xml", "pdf": "application/pdf",
		"doc": "application/msword", "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		"xls": "application/vnd.ms-excel", "xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		"ppt": "application/vnd.ms-powerpoint", "pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
		"zip": "application/zip", "rar": "application/x-rar-compressed",
		"mp4": "video/mp4", "mp3": "audio/mpeg", "wav": "audio/wav",
		"json": "application/json; charset=utf-8", "xml": "application/xml; charset=utf-8",
		"txt": "text/plain; charset=utf-8", "html": "text/html; charset=utf-8", "htm": "text/html; charset=utf-8",
		"css": "text/css; charset=utf-8", "js": "application/javascript; charset=utf-8",
	}
	if v, ok := m[ext]; ok {
		return v
	}
	return "application/octet-stream"
}

func isVideoExt(p string) bool {
	ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(p), "."))
	for _, v := range []string{"mp4", "avi", "mov", "wmv", "flv", "webm", "mkv", "m4v", "3gp", "ogv"} {
		if ext == v {
			return true
		}
	}
	return false
}

func isTextExt(p string) bool {
	ext := strings.ToLower(strings.TrimPrefix(filepath.Ext(p), "."))
	for _, v := range []string{"txt", "html", "htm", "css", "js", "json", "xml", "csv", "md", "log", "ini", "conf", "config", "php"} {
		if ext == v {
			return true
		}
	}
	return false
}

func toUTF8String(b []byte) string {
	if utf8.Valid(b) {
		return string(b)
	}
	out, err := simplifiedchinese.GBK.NewDecoder().Bytes(b)
	if err == nil && utf8.Valid(out) {
		return string(out)
	}
	return string(b)
}
