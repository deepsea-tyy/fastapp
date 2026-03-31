package admin

import (
	"encoding/json"
	"strconv"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"

	"github.com/gin-gonic/gin"
	"gorm.io/datatypes"
)

func SearchKeywordList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		tbl := model.P + "search_keyword"
		q := h.D.DBx(h.C).Model(&model.SearchKeyword{})
		if v := strings.TrimSpace(h.C.Query("keyword")); v != "" {
			q = q.Where(tbl+".keyword LIKE ?", "%"+v+"%")
		}
		if v := strings.TrimSpace(h.C.Query("source")); v != "" {
			if n, err := strconv.Atoi(v); err == nil {
				q = q.Where(tbl+".source = ?", n)
			}
		}
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var rows []model.SearchKeyword
		if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
	})
}

type searchKeywordBody struct {
	Keyword        string  `json:"keyword"`
	HitCount       *int    `json:"hit_count"`
	Icon           *string `json:"icon"`
	Color          *string `json:"color"`
	Source         *int    `json:"source"`
	Sort           *int    `json:"sort"`
	LastSearchedAt *string `json:"last_searched_at"`
}

func SearchKeywordCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body searchKeywordBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if strings.TrimSpace(body.Keyword) == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "keyword is required", nil))
			return
		}
		row := model.SearchKeyword{
			Keyword:  strings.TrimSpace(body.Keyword),
			HitCount: 1,
			Source:   1,
		}
		if body.HitCount != nil {
			row.HitCount = *body.HitCount
		}
		row.Icon = body.Icon
		row.Color = body.Color
		if body.Source != nil {
			row.Source = *body.Source
		}
		if body.Sort != nil {
			row.Sort = *body.Sort
		}
		if body.LastSearchedAt != nil && strings.TrimSpace(*body.LastSearchedAt) != "" {
			t, err := time.ParseInLocation("2006-01-02 15:04:05", strings.TrimSpace(*body.LastSearchedAt), time.Local)
			if err == nil {
				row.LastSearchedAt = &t
			}
		}
		if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("create failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func SearchKeywordSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var body searchKeywordBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		updates := map[string]any{}
		if body.Keyword != "" {
			updates["keyword"] = strings.TrimSpace(body.Keyword)
		}
		if body.HitCount != nil {
			updates["hit_count"] = *body.HitCount
		}
		if body.Icon != nil {
			updates["icon"] = *body.Icon
		}
		if body.Color != nil {
			updates["color"] = *body.Color
		}
		if body.Source != nil {
			updates["source"] = *body.Source
		}
		if body.Sort != nil {
			updates["sort"] = *body.Sort
		}
		if body.LastSearchedAt != nil {
			if strings.TrimSpace(*body.LastSearchedAt) == "" {
				updates["last_searched_at"] = nil
			} else if t, err := time.ParseInLocation("2006-01-02 15:04:05", strings.TrimSpace(*body.LastSearchedAt), time.Local); err == nil {
				updates["last_searched_at"] = t
			}
		}
		if len(updates) == 0 {
			response.JSON(h.C, 200, response.OK(nil))
			return
		}
		res := h.D.DBx(h.C).Model(&model.SearchKeyword{}).Where("id = ?", id).Updates(updates)
		if res.Error != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func SearchKeywordDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		ids, err := tools.ParseFlexibleIDList(h.C)
		if err != nil || len(ids) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&model.SearchKeyword{}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func SearchIndexList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		page, pageSize := tools.ParsePage(h.C)
		tbl := model.P + "search_index"
		q := h.D.DBx(h.C).Model(&model.SearchIndex{})
		if v := strings.TrimSpace(h.C.Query("target_type")); v != "" {
			q = q.Where(tbl+".target_type = ?", v)
		}
		if v := strings.TrimSpace(h.C.Query("target_id")); v != "" {
			if n, err := strconv.ParseInt(v, 10, 64); err == nil {
				q = q.Where(tbl+".target_id = ?", n)
			}
		}
		if v := strings.TrimSpace(h.C.Query("title")); v != "" {
			q = q.Where(tbl+".title LIKE ?", "%"+v+"%")
		}
		var total int64
		if err := q.Count(&total).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("count failed"))
			return
		}
		offset := (page - 1) * pageSize
		var rows []model.SearchIndex
		if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
	})
}

type searchIndexBody struct {
	TargetType string          `json:"target_type"`
	TargetID   int64           `json:"target_id"`
	Title      string          `json:"title"`
	Content    *string         `json:"content"`
	Keyword    json.RawMessage `json:"keyword"`
	Tags       json.RawMessage `json:"tags"`
	Weight     *int            `json:"weight"`
	ClickCount *int            `json:"click_count"`
	LastAt     *string         `json:"last_at"`
}

func SearchIndexCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body searchIndexBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if strings.TrimSpace(body.TargetType) == "" || body.TargetID <= 0 || strings.TrimSpace(body.Title) == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "target_type, target_id, title required", nil))
			return
		}
		row := model.SearchIndex{
			TargetType: strings.TrimSpace(body.TargetType),
			TargetID:   body.TargetID,
			Title:      strings.TrimSpace(body.Title),
			Content:    body.Content,
		}
		if len(body.Keyword) > 0 {
			row.Keyword = datatypes.JSON(body.Keyword)
		}
		if len(body.Tags) > 0 {
			row.Tags = datatypes.JSON(body.Tags)
		}
		if body.Weight != nil {
			row.Weight = *body.Weight
		}
		if body.ClickCount != nil {
			row.ClickCount = *body.ClickCount
		}
		if body.LastAt != nil && strings.TrimSpace(*body.LastAt) != "" {
			if t, err := time.ParseInLocation("2006-01-02 15:04:05", strings.TrimSpace(*body.LastAt), time.Local); err == nil {
				row.LastAt = &t
			}
		}
		if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("create failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func SearchIndexSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		id, ok := tools.ParseIDParam(h.C, "id")
		if !ok {
			return
		}
		var body searchIndexBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		updates := map[string]any{}
		if body.TargetType != "" {
			updates["target_type"] = strings.TrimSpace(body.TargetType)
		}
		if body.TargetID > 0 {
			updates["target_id"] = body.TargetID
		}
		if body.Title != "" {
			updates["title"] = strings.TrimSpace(body.Title)
		}
		if body.Content != nil {
			updates["content"] = *body.Content
		}
		if len(body.Keyword) > 0 {
			updates["keyword"] = datatypes.JSON(body.Keyword)
		}
		if len(body.Tags) > 0 {
			updates["tags"] = datatypes.JSON(body.Tags)
		}
		if body.Weight != nil {
			updates["weight"] = *body.Weight
		}
		if body.ClickCount != nil {
			updates["click_count"] = *body.ClickCount
		}
		if body.LastAt != nil {
			if strings.TrimSpace(*body.LastAt) == "" {
				updates["last_at"] = nil
			} else if t, err := time.ParseInLocation("2006-01-02 15:04:05", strings.TrimSpace(*body.LastAt), time.Local); err == nil {
				updates["last_at"] = t
			}
		}
		if len(updates) == 0 {
			response.JSON(h.C, 200, response.OK(nil))
			return
		}
		res := h.D.DBx(h.C).Model(&model.SearchIndex{}).Where("id = ?", id).Updates(updates)
		if res.Error != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func SearchIndexDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		ids, err := tools.ParseFlexibleIDList(h.C)
		if err != nil || len(ids) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&model.SearchIndex{}).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}
