package scmhttp

import (
	"encoding/json"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	cmsmodel "fastapp/plugin/ds/sysCms/src/model"
)

func articleAdminList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.Article{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.Article{})
	if v := strings.TrimSpace(h.C.Query("title")); v != "" {
		q = q.Where(tbl+".title LIKE ?", "%"+v+"%")
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("lang")); v != "" {
		q = q.Where(tbl+".lang = ?", v)
	}
	if v := strings.TrimSpace(h.C.Query("code")); v != "" {
		q = q.Where(tbl+".code = ?", v)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.Article
	if err := q.Order(tbl + ".sort DESC, " + tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type articleBody struct {
	Title        string  `json:"title"`
	Subtitle     string  `json:"subtitle"`
	Lang         string  `json:"lang"`
	Author       string  `json:"author"`
	Cover        string  `json:"cover"`
	Video        string  `json:"video"`
	ReleaseAt    string  `json:"release_at"`
	Brief        string  `json:"brief"`
	Content      string  `json:"content"`
	Remark       string  `json:"remark"`
	Sort         *int    `json:"sort"`
	Status       *int    `json:"status"`
	Code         *string `json:"code"`
	ViewCount    *int    `json:"view_count"`
	LikeCount    *int    `json:"like_count"`
	CommentCount *int    `json:"comment_count"`
	ShareCount   *int    `json:"share_count"`
	CollectCount *int    `json:"collect_count"`
}

func articleAdminCreate(h *deps.HandlerCtx) {
	var body articleBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	cb := int64(uid)
	row := cmsmodel.Article{
		Title: body.Title, Subtitle: body.Subtitle, Lang: body.Lang, Author: body.Author,
		Cover: body.Cover, Video: body.Video, ReleaseAt: body.ReleaseAt, Brief: body.Brief,
		Content: body.Content, Remark: body.Remark, Code: body.Code, CreatedBy: &cb, UpdatedBy: &cb,
	}
	if body.Sort != nil {
		row.Sort = *body.Sort
	}
	if body.Status != nil {
		row.Status = *body.Status
	} else {
		row.Status = 1
	}
	if body.ViewCount != nil {
		row.ViewCount = *body.ViewCount
	}
	if body.LikeCount != nil {
		row.LikeCount = *body.LikeCount
	}
	if body.CommentCount != nil {
		row.CommentCount = *body.CommentCount
	}
	if body.ShareCount != nil {
		row.ShareCount = *body.ShareCount
	}
	if body.CollectCount != nil {
		row.CollectCount = *body.CollectCount
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func articleAdminSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body articleBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	ub := int64(uid)
	up := map[string]any{"updated_by": ub}
	if body.Title != "" {
		up["title"] = body.Title
	}
	if body.Subtitle != "" {
		up["subtitle"] = body.Subtitle
	}
	if body.Lang != "" {
		up["lang"] = body.Lang
	}
	if body.Author != "" {
		up["author"] = body.Author
	}
	if body.Cover != "" {
		up["cover"] = body.Cover
	}
	if body.Video != "" {
		up["video"] = body.Video
	}
	if body.ReleaseAt != "" {
		up["release_at"] = body.ReleaseAt
	}
	if body.Brief != "" {
		up["brief"] = body.Brief
	}
	if body.Content != "" {
		up["content"] = body.Content
	}
	if body.Remark != "" {
		up["remark"] = body.Remark
	}
	if body.Sort != nil {
		up["sort"] = *body.Sort
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if body.Code != nil {
		up["code"] = *body.Code
	}
	if body.ViewCount != nil {
		up["view_count"] = *body.ViewCount
	}
	if body.LikeCount != nil {
		up["like_count"] = *body.LikeCount
	}
	if body.CommentCount != nil {
		up["comment_count"] = *body.CommentCount
	}
	if body.ShareCount != nil {
		up["share_count"] = *body.ShareCount
	}
	if body.CollectCount != nil {
		up["collect_count"] = *body.CollectCount
	}
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&cmsmodel.Article{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func articleAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.Article{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func categoryAdminList(h *deps.HandlerCtx) {
	page, pageSize := tools.ParsePage(h.C)
	tbl := (&cmsmodel.Category{}).TableName()
	q := h.D.DBx(h.C).Model(&cmsmodel.Category{})
	if v := strings.TrimSpace(h.C.Query("parent_id")); v != "" {
		if n, err := strconv.ParseInt(v, 10, 64); err == nil {
			q = q.Where(tbl+".parent_id = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("status")); v != "" {
		if n, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".status = ?", n)
		}
	}
	if v := strings.TrimSpace(h.C.Query("code")); v != "" {
		q = q.Where(tbl+".code = ?", v)
	}
	var total int64
	if err := q.Count(&total).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("count failed"))
		return
	}
	var rows []cmsmodel.Category
	if err := q.Order(tbl + ".sort DESC, " + tbl + ".id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": rows, "total": total}))
}

type categoryBody struct {
	Name     json.RawMessage `json:"name"`
	Icon     string          `json:"icon"`
	Sort     *int            `json:"sort"`
	ParentID *int64          `json:"parent_id"`
	Status   *int            `json:"status"`
	Remark   string          `json:"remark"`
	Code     *string         `json:"code"`
}

func categoryAdminCreate(h *deps.HandlerCtx) {
	var body categoryBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	cb := int64(uid)
	row := cmsmodel.Category{Name: body.Name, Icon: body.Icon, Remark: body.Remark, Code: body.Code, CreatedBy: &cb, UpdatedBy: &cb}
	if body.Sort != nil {
		row.Sort = *body.Sort
	}
	if body.ParentID != nil {
		row.ParentID = *body.ParentID
	}
	if body.Status != nil {
		row.Status = *body.Status
	} else {
		row.Status = 1
	}
	if err := h.D.DBx(h.C).Create(&row).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("create failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func categoryAdminSave(h *deps.HandlerCtx) {
	id, ok := tools.ParseIDParam(h.C, "id")
	if !ok {
		return
	}
	var body categoryBody
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	uid := middleware.UserID(h.C)
	ub := int64(uid)
	up := map[string]any{"updated_by": ub}
	if len(body.Name) > 0 {
		up["name"] = []byte(body.Name)
	}
	if body.Icon != "" {
		up["icon"] = body.Icon
	}
	if body.Remark != "" {
		up["remark"] = body.Remark
	}
	if body.Code != nil {
		up["code"] = *body.Code
	}
	if body.Sort != nil {
		up["sort"] = *body.Sort
	}
	if body.ParentID != nil {
		up["parent_id"] = *body.ParentID
	}
	if body.Status != nil {
		up["status"] = *body.Status
	}
	if len(up) <= 1 {
		response.JSON(h.C, 200, response.OK(nil))
		return
	}
	if err := h.D.DBx(h.C).Model(&cmsmodel.Category{}).Where("id = ?", id).Updates(up).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("save failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func categoryAdminDelete(h *deps.HandlerCtx) {
	ids, err := tools.ParseFlexibleIDList(h.C)
	if err != nil || len(ids) == 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
		return
	}
	if err := h.D.DBx(h.C).Where("id IN ?", ids).Delete(&cmsmodel.Category{}).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("delete failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(nil))
}

func categorySelectTree(h *deps.HandlerCtx) {
	var top []cmsmodel.Category
	if err := h.D.DBx(h.C).Where("parent_id = 0").Order("sort DESC, id DESC").Find(&top).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	lang := tools.ProfileLang(h.D.DBx(h.C), middleware.UserID(h.C))
	out := make([]map[string]any, 0)
	for _, p := range top {
		nameObj := tools.JSONToObject(p.Name)
		l1 := tools.FormatLang(nameObj, lang)
		out = append(out, map[string]any{
			"label": l1,
			"value": p.ID,
			"name":  nameObj,
		})
		var ch []cmsmodel.Category
		_ = h.D.DBx(h.C).Where("parent_id = ?", p.ID).Order("sort DESC, id DESC").Find(&ch).Error
		for _, c := range ch {
			cName := tools.JSONToObject(c.Name)
			l2 := tools.FormatLang(cName, lang)
			out = append(out, map[string]any{
				"label": l1 + "/" + l2,
				"value": c.ID,
				"name":  cName,
			})
		}
	}
	response.JSON(h.C, 200, response.OK(out))
}

// categorySelectCreator 未接入 Feed 模块时固定返回空列表，后台可用手工填作者。
func categorySelectCreator(h *deps.HandlerCtx) {
	response.JSON(h.C, 200, response.OK([]any{}))
}
