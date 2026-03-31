package user

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type searchCacheKeyOpts struct {
	Page     int      `json:"page"`
	PageSize int      `json:"page_size"`
	Sort     string   `json:"sort"`
	Types    []string `json:"types,omitempty"`
}

func searchCacheKey(keyword string, o searchCacheKeyOpts) string {
	raw, _ := json.Marshal(o)
	h := md5.Sum(append([]byte(keyword), raw...))
	return "search:mysql:" + hex.EncodeToString(h[:])
}

func parseSearchPage(c *gin.Context) (page, pageSize int) {
	page, pageSize = 1, 10
	_, _ = fmt.Sscan(c.Query("page"), &page)
	_, _ = fmt.Sscan(c.Query("page_size"), &pageSize)
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}
	return page, pageSize
}

func recordSearchKeywordHit(d *deps.Deps, keyword string) {
	if d == nil || d.DB == nil {
		return
	}
	db := d.DB.WithContext(context.Background())
	now := time.Now()
	res := db.Model(&model.SearchKeyword{}).Where("keyword = ?", keyword).
		Updates(map[string]any{
			"hit_count":        gorm.Expr("hit_count + 1"),
			"last_searched_at": now,
		})
	if res.Error == nil && res.RowsAffected > 0 {
		return
	}
	_ = db.Create(&model.SearchKeyword{Keyword: keyword, HitCount: 1, LastSearchedAt: &now}).Error
}

// SearchGlobal GET /api/search — 。
func SearchGlobal(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		keyword := strings.TrimSpace(h.C.Query("keyword"))
		if keyword == "" {
			response.JSON(h.C, 200, response.Fail("搜索关键词不能为空"))
			return
		}
		typeFilter := strings.TrimSpace(h.C.Query("type"))
		if typeFilter == "" {
			typeFilter = "all"
		}
		sort := strings.TrimSpace(h.C.Query("sort"))
		if sort == "" {
			sort = "relevance"
		}
		page, pageSize := parseSearchPage(h.C)

		go recordSearchKeywordHit(h.D, keyword)

		var types []string
		if typeFilter != "all" {
			types = []string{typeFilter}
		}
		keyOpts := searchCacheKeyOpts{Page: page, PageSize: pageSize, Sort: sort, Types: types}
		cacheKey := searchCacheKey(keyword, keyOpts)

		if h.D.RDB != nil {
			if s, err := h.D.RDB.Get(h.C.Request.Context(), cacheKey).Result(); err == nil && s != "" {
				var cached map[string]any
				if json.Unmarshal([]byte(s), &cached) == nil {
					cached["from_cache"] = true
					response.JSON(h.C, 200, response.OK(cached))
					return
				}
			}
		}

		start := time.Now()
		kw := strings.ToLower(keyword)
		tbl := (&model.SearchIndex{}).TableName()
		kwPat := "%" + kw + "%"
		jq, _ := json.Marshal(keyword)

		q := h.D.DBx(h.C).Model(&model.SearchIndex{}).
			Select("target_type", "target_id", "title", "content", "tags", "weight", "click_count", "last_at").
			Where(
				"("+tbl+".title LIKE ? OR "+tbl+".content LIKE ? OR JSON_CONTAINS(COALESCE("+tbl+".keyword, JSON_ARRAY()), CAST(? AS JSON)))",
				kwPat, kwPat, string(jq),
			)
		if len(types) > 0 {
			q = q.Where(tbl+".target_type IN ?", types)
		}

		offset := (page - 1) * pageSize
		var rows []model.SearchIndex
		orderSQL := tbl + ".last_at DESC"
		if sort == "relevance" {
			orderSQL = tbl + ".weight DESC, " + tbl + ".click_count DESC, " + tbl + ".last_at DESC"
		}
		if err := q.Order(orderSQL).Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("search failed"))
			return
		}
		took := int(time.Since(start).Milliseconds())
		out := map[string]any{"list": rows, "took": took}

		if h.D.RDB != nil {
			if b, err := json.Marshal(out); err == nil {
				_ = h.D.RDB.Set(h.C.Request.Context(), cacheKey, b, 300*time.Second).Err()
			}
		}
		response.JSON(h.C, 200, response.OK(out))
	})
}

// SearchSuggest GET /api/search/suggest
func SearchSuggest(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		keyword := strings.TrimSpace(h.C.Query("keyword"))
		if keyword == "" {
			response.JSON(h.C, 200, response.OK([]any{}))
			return
		}
		limit := 10
		_, _ = fmt.Sscan(h.C.Query("limit"), &limit)
		if limit < 1 {
			limit = 10
		}
		if limit > 50 {
			limit = 50
		}
		pref := keyword + "%"
		tbl := (&model.SearchIndex{}).TableName()
		var rows []model.SearchIndex
		err := h.D.DBx(h.C).Model(&model.SearchIndex{}).
			Where(tbl+".title LIKE ? OR "+tbl+".content LIKE ?", pref, pref).
			Select("target_type", "target_id", "title", "content", "tags", "weight", "click_count", "last_at").
			Distinct().
			Order(tbl + ".weight DESC").
			Limit(limit).
			Find(&rows).Error
		if err != nil {
			response.JSON(h.C, 200, response.Fail("suggest failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(rows))
	})
}

// SearchRanking GET /api/search/ranking
func SearchRanking(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		tbl := (&model.SearchIndex{}).TableName()
		var rows []model.SearchIndex
		if err := h.D.DBx(h.C).Model(&model.SearchIndex{}).
			Select("target_type", "target_id", "title", "content", "tags", "weight", "click_count", "last_at").
			Order(tbl + ".click_count DESC, " + tbl + ".weight DESC, " + tbl + ".last_at DESC").
			Limit(20).
			Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("ranking failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": rows}))
	})
}

// SearchHotKeywords GET /api/search/keywords/hot
func SearchHotKeywords(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		limit := 10
		_, _ = fmt.Sscan(h.C.Query("limit"), &limit)
		if limit < 1 {
			limit = 10
		}
		if limit > 100 {
			limit = 100
		}
		tbl := (&model.SearchKeyword{}).TableName()
		var rows []model.SearchKeyword
		if err := h.D.DBx(h.C).Where(tbl+".source <> ?", 1).
			Order(tbl + ".sort DESC, " + tbl + ".hit_count DESC").
			Limit(limit).
			Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		list := make([]map[string]any, 0, len(rows))
		now := time.Now()
		for i := range rows {
			r := rows[i]
			var badge any
			if i < 3 && r.HitCount > 100 {
				badge = "HOT"
			} else if r.LastSearchedAt != nil && now.Sub(*r.LastSearchedAt) < 24*time.Hour {
				badge = "NEW"
			}
			list = append(list, map[string]any{
				"id":        r.ID,
				"keyword":   r.Keyword,
				"hit_count": r.HitCount,
				"icon":      r.Icon,
				"color":     r.Color,
				"sort":      r.Sort,
				"badge":     badge,
			})
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
	})
}

// SearchClick POST /api/search/click
func SearchClick(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body struct {
			TargetType string `json:"target_type"`
			TargetID   int64  `json:"target_id"`
		}
		if err := h.C.ShouldBindJSON(&body); err != nil {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "参数错误", nil))
			return
		}
		if strings.TrimSpace(body.TargetType) == "" || body.TargetID <= 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "参数错误", nil))
			return
		}
		tbl := (&model.SearchIndex{}).TableName()
		res := h.D.DBx(h.C).Model(&model.SearchIndex{}).
			Where(tbl+".target_type = ? AND "+tbl+".target_id = ?", strings.TrimSpace(body.TargetType), body.TargetID).
			UpdateColumn("click_count", gorm.Expr("click_count + 1"))
		if res.Error != nil {
			response.JSON(h.C, 200, response.Fail("update failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}
