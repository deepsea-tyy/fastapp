package admin

import (
	"crypto/md5"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/i18n"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/storage"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func attachmentMergeFailMsg(c *gin.Context, step string) string {
	return i18n.T(i18n.FromGin(c), "attachment.upload_failed") + ": " + step
}

func AttachmentList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) { attachmentList(h, nil) })
}

// AppAttachmentList App `/api/attachment/list`：仅当前登录用户上传的附件。
func AppAttachmentList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		uid := middleware.UserID(h.C)
		attachmentList(h, &uid)
	})
}

func AttachmentUpload(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		st, err := storage.New(h.C.Request.Context(), h.D.DBx(h.C), h.D.UploadDir)
		if err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		fh, err := h.C.FormFile("file")
		if err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "file required", nil))
			return
		}
		src, err := fh.Open()
		if err != nil {
			response.JSON(h.C, 200, response.Fail("open upload failed"))
			return
		}
		defer src.Close()

		dig := md5.New()
		if _, err := io.Copy(dig, src); err != nil {
			response.JSON(h.C, 200, response.Fail("read file failed"))
			return
		}
		hashHex := fmt.Sprintf("%x", dig.Sum(nil))

		var exist model.Attachment
		if err := h.D.DBx(h.C).Where(model.P+"attachment.hash = ?", hashHex).First(&exist).Error; err == nil {
			response.JSON(h.C, 200, response.OK(&exist))
			return
		}

		src2, err := fh.Open()
		if err != nil {
			response.JSON(h.C, 200, response.Fail("reopen file failed"))
			return
		}
		defer src2.Close()

		uid := middleware.UserID(h.C)
		row, serr := saveUploadedStream(h, st, src2, fh.Filename, uid, hashHex)
		if serr != nil {
			response.JSON(h.C, 200, response.Fail(serr.Error()))
			return
		}
		response.JSON(h.C, 200, response.OK(row))
	})
}

func AttachmentDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		idStr := h.C.Param("id")
		id, err := strconv.ParseInt(idStr, 10, 64)
		if err != nil || id <= 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "id invalid", nil))
			return
		}
		var row model.Attachment
		if err := h.D.DBx(h.C).First(&row, id).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("附件不存在"))
			return
		}
		uid := middleware.UserID(h.C)
		if row.CreatedBy == nil || *row.CreatedBy != uid {
			response.JSON(h.C, 200, response.Fail("无权限删除此附件"))
			return
		}
		if err := h.D.DBx(h.C).Delete(&model.Attachment{}, id).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		st, err := storage.New(h.C.Request.Context(), h.D.DBx(h.C), h.D.UploadDir)
		if err == nil {
			if key, kerr := storage.ObjectKeyFromPublicURL(row.URL, row.StorageMode); kerr == nil {
				_ = st.Delete(h.C.Request.Context(), key)
			}
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func AttachmentChunkUpload(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		st, err := storage.New(h.C.Request.Context(), h.D.DBx(h.C), h.D.UploadDir)
		if err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		hash := strings.TrimSpace(h.C.PostForm("file_md5"))
		if hash == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "file_md5 required", nil))
			return
		}
		ciStr := h.C.PostForm("chunk_index")
		ci, err := strconv.Atoi(ciStr)
		if err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "chunk_index invalid", nil))
			return
		}

		var exist model.Attachment
		if err := h.D.DBx(h.C).Where(model.P+"attachment.hash = ?", hash).First(&exist).Error; err == nil {
			response.JSON(h.C, 200, response.OK(map[string]any{
				"file_exists":  true,
				"chunk_index":  ci,
				"id":           exist.ID,
				"storage_mode": exist.StorageMode,
				"origin_name":  exist.OriginName,
				"object_name":  exist.ObjectName,
				"hash":         exist.Hash,
				"mime_type":    exist.MimeType,
				"suffix":       exist.Suffix,
				"size_byte":    exist.SizeByte,
				"size_info":    exist.SizeInfo,
				"url":          exist.URL,
				"created_by":   exist.CreatedBy,
				"updated_by":   exist.UpdatedBy,
				"created_at":   exist.CreatedAt,
				"updated_at":   exist.UpdatedAt,
				"remark":       exist.Remark,
			}))
			return
		}

		fh, err := h.C.FormFile("file")
		if err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "file required", nil))
			return
		}
		src, err := fh.Open()
		if err != nil {
			response.JSON(h.C, 200, response.Fail("open chunk failed"))
			return
		}
		defer src.Close()

		if err := st.ChunkWrite(h.C.Request.Context(), hash, ci, src); err != nil {
			response.JSON(h.C, 200, response.Fail("分片上传失败: "+err.Error()))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"chunk_index": ci}))
	})
}

func AttachmentChunkMerge(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		st, err := storage.New(h.C.Request.Context(), h.D.DBx(h.C), h.D.UploadDir)
		if err != nil {
			response.JSON(h.C, 200, response.Fail(err.Error()))
			return
		}
		hash := strings.TrimSpace(h.C.PostForm("file_md5"))
		filename := sanitizeUploadFilename(h.C.PostForm("filename"))
		tcStr := h.C.PostForm("total_chunks")
		totalChunks, err := strconv.Atoi(tcStr)
		if hash == "" || filename == "" || err != nil || totalChunks < 1 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "file_md5, filename, total_chunks required", nil))
			return
		}

		var exist model.Attachment
		if err := h.D.DBx(h.C).Where(model.P+"attachment.hash = ?", hash).First(&exist).Error; err == nil {
			response.JSON(h.C, 200, response.OK(&exist))
			return
		}

		tmpMerged, err := os.CreateTemp("", "attach-merge-*")
		if err != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "temp")))
			return
		}
		tmpPath := tmpMerged.Name()
		defer func() { _ = os.Remove(tmpPath) }()

		ctx := h.C.Request.Context()
		for i := 0; i < totalChunks; i++ {
			rc, rerr := st.ChunkOpen(ctx, hash, i)
			if rerr != nil {
				_ = tmpMerged.Close()
				response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "missing chunk "+strconv.Itoa(i))))
				return
			}
			if _, werr := io.Copy(tmpMerged, rc); werr != nil {
				_ = rc.Close()
				_ = tmpMerged.Close()
				response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, werr.Error())))
				return
			}
			_ = rc.Close()
		}
		if err := tmpMerged.Close(); err != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "close temp")))
			return
		}

		merged, err := os.Open(tmpPath)
		if err != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "reopen")))
			return
		}
		defer merged.Close()

		dig := md5.New()
		if _, err := io.Copy(dig, merged); err != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "hash")))
			return
		}
		hashHex := fmt.Sprintf("%x", dig.Sum(nil))
		if _, err := merged.Seek(0, 0); err != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, "seek")))
			return
		}

		var dup model.Attachment
		if err := h.D.DBx(h.C).Where(model.P+"attachment.hash = ?", hashHex).First(&dup).Error; err == nil {
			st.ChunkDeleteAll(ctx, hash, totalChunks)
			response.JSON(h.C, 200, response.OK(&dup))
			return
		}

		uid := middleware.UserID(h.C)
		row, serr := saveUploadedStream(h, st, merged, filename, uid, hashHex)
		if serr != nil {
			response.JSON(h.C, 200, response.Fail(attachmentMergeFailMsg(h.C, serr.Error())))
			return
		}
		st.ChunkDeleteAll(ctx, hash, totalChunks)
		response.JSON(h.C, 200, response.OK(row))
	})
}

func attachmentList(h *deps.HandlerCtx, onlyCreator *int64) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := model.P + "attachment"
	q := h.D.DBx(h.C).Model(&model.Attachment{})
	if onlyCreator != nil {
		q = q.Where(tbl+".created_by = ?", *onlyCreator)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	offset := (page - 1) * pageSize
	var rows []model.Attachment
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

func saveUploadedStream(h *deps.HandlerCtx, st storage.FileStorage, r io.Reader, clientName string, userID int64, contentMD5 string) (*model.Attachment, error) {
	ext := strings.TrimPrefix(strings.ToLower(filepath.Ext(clientName)), ".")
	if ext == "" {
		ext = "bin"
	}
	objectName := uuid.NewString() + "." + ext
	dateDir := time.Now().Format("20060102")
	objectKey := dateDir + "/" + objectName

	tmpf, err := os.CreateTemp("", "attach-up-*")
	if err != nil {
		return nil, err
	}
	tmpPath := tmpf.Name()
	defer func() { _ = os.Remove(tmpPath) }()

	n, err := io.Copy(tmpf, r)
	if err != nil {
		_ = tmpf.Close()
		return nil, err
	}
	if err := tmpf.Close(); err != nil {
		return nil, err
	}

	fh, err := os.Open(tmpPath)
	if err != nil {
		return nil, err
	}
	head := make([]byte, 512)
	k, _ := fh.Read(head)
	mimeType := "application/octet-stream"
	if k > 0 {
		mimeType = http.DetectContentType(head[:k])
	}
	if _, err := fh.Seek(0, 0); err != nil {
		_ = fh.Close()
		return nil, err
	}

	ctx := h.C.Request.Context()
	if err := st.Put(ctx, objectKey, fh, n); err != nil {
		_ = fh.Close()
		return nil, err
	}
	_ = fh.Close()

	url := st.PublicURL(objectKey)
	mode := st.StorageMode()
	uid := userID
	row := &model.Attachment{
		StorageMode: mode,
		OriginName:  filepath.Base(clientName),
		ObjectName:  objectName,
		Hash:        contentMD5,
		MimeType:    mimeType,
		Suffix:      ext,
		SizeByte:    n,
		SizeInfo:    humanSize(n),
		URL:         url,
		CreatedBy:   &uid,
	}
	if err := h.D.DBx(h.C).Create(row).Error; err != nil {
		_ = st.Delete(ctx, objectKey)
		return nil, err
	}
	return row, nil
}

func humanSize(n int64) string {
	const kb, mb, gb = 1024, 1024 * 1024, 1024 * 1024 * 1024
	switch {
	case n >= gb:
		return fmt.Sprintf("%.2fG", float64(n)/float64(gb))
	case n >= mb:
		return fmt.Sprintf("%.2fM", float64(n)/float64(mb))
	default:
		return fmt.Sprintf("%.2fK", float64(n)/float64(kb))
	}
}

func sanitizeUploadFilename(name string) string {
	name = strings.TrimSpace(name)
	name = filepath.Base(name)
	if name == "" || name == "." || strings.Contains(name, "..") {
		return ""
	}
	return name
}

// ParseFlexibleIDList 解析 DELETE 请求体：JSON 数组或 {"ids":[...]}。
func ParseFlexibleIDList(c *gin.Context) ([]int64, error) {
	return tools.ParseFlexibleIDList(c)
}
