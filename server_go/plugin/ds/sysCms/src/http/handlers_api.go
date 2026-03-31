package scmhttp

import (
	"context"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	cmsmodel "fastapp/plugin/ds/sysCms/src/model"

	"gorm.io/gorm"
)

const categoryCorrArticle = 1

func apiArticleNews(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	lang := tools.ProfileLang(h.D.DBx(h.C), uid)
	page, pageSize := tools.ParsePage(h.C)
	keyword := strings.TrimSpace(h.C.Query("keyword"))
	list := listArticlesByCategoryCode(h.D.DBx(h.C), "news", lang, keyword, page, pageSize)
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

func apiArticleNotice(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	lang := tools.ProfileLang(h.D.DBx(h.C), uid)
	page, pageSize := tools.ParsePage(h.C)
	keyword := strings.TrimSpace(h.C.Query("keyword"))
	list := listArticlesByCategoryCode(h.D.DBx(h.C), "notice", lang, keyword, page, pageSize)
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

func apiArticleHelpManual(h *deps.HandlerCtx) {
	var rows []cmsmodel.Category
	_ = h.D.DBx(h.C).Select("id", "name").Where("code = ?", "help_manual").Order("sort DESC").Find(&rows).Error
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows}))
}

func apiArticleCategoryList(h *deps.HandlerCtx) {
	cid, _ := strconv.ParseInt(h.C.Query("category_id"), 10, 64)
	var ids []int64
	_ = h.D.DBx(h.C).Model(&cmsmodel.CategoryCorrelation{}).
		Where("type = ? AND category_id = ?", categoryCorrArticle, cid).
		Pluck("data_id", &ids).Error
	response.JSON(h.C, 200, response.OK(map[string]any{"list": ids}))
}

func apiArticleSearchList(h *deps.HandlerCtx) {
	lang := tools.ProfileLang(h.D.DBx(h.C), middleware.UserID(h.C))
	page, pageSize := tools.ParsePage(h.C)
	keyword := strings.TrimSpace(h.C.Query("keyword"))
	tbl := (&cmsmodel.Article{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.Article{}).Where(tbl+".lang = ? AND "+tbl+".status = ?", lang, 1)
	if keyword != "" {
		k := "%" + keyword + "%"
		q = q.Where(tbl+".title LIKE ? OR "+tbl+".content LIKE ?", k, k)
	}
	var total int64
	_ = q.Count(&total).Error
	var rows []cmsmodel.Article
	_ = q.Order(tbl + ".sort DESC, " + tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error
	list := make([]map[string]any, 0, len(rows))
	for _, a := range rows {
		m := tools.FormatArticleRow(a)
		if a.CreatedBy != nil {
			m["profile"] = tools.CmsUserProfileMap(h.D.DBx(h.C), *a.CreatedBy)
		}
		list = append(list, m)
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

func apiArticleDetail(h *deps.HandlerCtx) {
	id, _ := strconv.ParseInt(h.C.Query("id"), 10, 64)
	if id <= 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "id invalid", nil))
		return
	}
	lang := tools.ProfileLang(h.D.DBx(h.C), middleware.UserID(h.C))
	var a cmsmodel.Article
	if err := h.D.DBx(h.C).Where("id = ? AND lang = ? AND status = ?", id, lang, 1).First(&a).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("not found"))
		return
	}
	go func(db *gorm.DB) {
		_ = db.Model(&cmsmodel.Article{}).Where("id = ?", id).UpdateColumn("view_count", gorm.Expr("view_count + ?", 1)).Error
	}(h.D.DB.Session(&gorm.Session{}))

	out := tools.FormatArticleRow(a)
	if a.CreatedBy != nil {
		out["profile"] = tools.CmsUserProfileMap(h.D.DBx(h.C), *a.CreatedBy)
		out["created_by"] = *a.CreatedBy
	}
	response.JSON(h.C, 200, response.OK(out))
}

func listArticlesByCategoryCode(db *gorm.DB, code, lang, keyword string, page, pageSize int) []map[string]any {
	var cat cmsmodel.Category
	if err := db.Where("code = ?", code).First(&cat).Error; err != nil {
		return nil
	}
	var ids []int64
	_ = db.Model(&cmsmodel.CategoryCorrelation{}).
		Where("type = ? AND category_id = ?", categoryCorrArticle, cat.ID).
		Pluck("data_id", &ids).Error
	if len(ids) == 0 {
		return nil
	}
	at := (&cmsmodel.Article{}).TableName()
	q := db.Model(&cmsmodel.Article{}).Where(at+".id IN ? AND "+at+".lang = ? AND "+at+".status = ?", ids, lang, 1)
	if keyword != "" {
		k := "%" + keyword + "%"
		q = q.Where(at+".title LIKE ? OR "+at+".content LIKE ?", k, k)
	}
	offset := (page - 1) * pageSize
	var rows []cmsmodel.Article
	if err := q.Order(at + ".sort DESC, " + at + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil || len(rows) == 0 {
		return nil
	}
	list := make([]map[string]any, 0, len(rows))
	for _, a := range rows {
		m := tools.FormatArticleRow(a)
		if a.CreatedBy != nil {
			m["profile"] = tools.CmsUserProfileMap(db, *a.CreatedBy)
		}
		list = append(list, m)
	}
	return list
}

func apiAppPageContentDownload(h *deps.HandlerCtx) {
	platform := 2
	if v := strings.TrimSpace(h.C.Query("platform")); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			platform = n
		}
	}
	key := "app:init" + strconv.Itoa(platform)
	if h.D.RDB != nil {
		if s, err := h.D.RDB.Get(context.Background(), key).Result(); err == nil && s != "" {
			h.C.Data(200, "application/json; charset=utf-8", []byte(s))
			return
		}
	}
	if h.D.UploadDir == "" {
		response.JSON(h.C, 404, response.Fail("文件不存在"))
		return
	}
	suffix := "app"
	if platform == 1 {
		suffix = "web"
	}
	full := filepath.Join(tools.StorageAppPageContentDir(h.D.UploadDir), "page-content-"+suffix+".json")
	if _, err := os.Stat(full); err != nil {
		response.JSON(h.C, 404, response.Fail("文件不存在"))
		return
	}
	h.C.File(full)
}
