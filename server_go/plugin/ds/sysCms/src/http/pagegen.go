package scmhttp

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strconv"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	cmsmodel "fastapp/plugin/ds/sysCms/src/model"

	"gorm.io/gorm"
)

func appPageContentSyncGenerate(h *deps.HandlerCtx) {
	if h.D.UploadDir == "" {
		response.JSON(h.C, 200, response.Fail("upload dir not configured"))
		return
	}
	baseDir := tools.StorageAppPageContentDir(h.D.UploadDir)
	if err := os.MkdirAll(baseDir, 0755); err != nil {
		response.JSON(h.C, 200, response.Fail("mkdir failed"))
		return
	}
	version := strconv.FormatInt(time.Now().Unix(), 10)
	var results []map[string]any

	for _, spec := range []struct {
		platform int
		suffix   string
		redisKey string
	}{
		{1, "web", "app:init1"},
		{2, "app", "app:init2"},
	} {
		rows, err := loadEnabledAppPageContents(h.D.DBx(h.C), spec.platform)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		if len(rows) == 0 {
			continue
		}
		data := make(map[string]any, len(rows))
		for _, r := range rows {
			if r.Code == nil || *r.Code == "" {
				continue
			}
			data[*r.Code] = map[string]any{
				"data":         r.Data,
				"content_type": r.ContentType,
			}
		}
		if len(data) == 0 {
			continue
		}
		raw, err := json.Marshal(data)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("encode failed"))
			return
		}
		fullPath := filepath.Join(baseDir, "page-content-"+spec.suffix+".json")
		if err := os.WriteFile(fullPath, raw, 0644); err != nil {
			response.JSON(h.C, 200, response.Fail("write failed"))
			return
		}
		st, _ := os.Stat(fullPath)
		rel := tools.PageContentJSONWebRel(spec.suffix)
		if h.D.RDB != nil {
			_ = h.D.RDB.Set(context.Background(), spec.redisKey, string(raw), 0).Err()
		}
		now := time.Now()
		row := cmsmodel.AppPageContentSync{
			Version:     version,
			Platform:    spec.platform,
			FilePath:    rel,
			FileSize:    int(st.Size()),
			RecordCount: len(data),
			GeneratedAt: &now,
		}
		if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("sync record failed"))
			return
		}
		results = append(results, map[string]any{
			"platform":     spec.platform,
			"version":      version,
			"file_path":    fullPath,
			"file_size":    st.Size(),
			"record_count": len(data),
		})
	}
	if len(results) == 0 {
		response.JSON(h.C, 200, response.Fail("没有可用的页面内容数据，请先添加并启用页面内容后再生成文件"))
		return
	}
	response.JSON(h.C, 200, response.OKWithMessage("文件生成成功", results))
}

func loadEnabledAppPageContents(db *gorm.DB, platform int) ([]cmsmodel.AppPageContent, error) {
	var rows []cmsmodel.AppPageContent
	err := db.Where("status = ?", 1).Where("platform IN ?", []int{platform, 3}).
		Order("sort ASC, id ASC").Find(&rows).Error
	return rows, err
}
