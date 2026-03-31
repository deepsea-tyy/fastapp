package snfyhttp

import (
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	nmodel "fastapp/plugin/ds/sysNotify/src/model"

	"gorm.io/gorm"
)

func apiSysNotifyList(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	if v := strings.TrimSpace(h.C.Query("notify_type")); v != "" {
		nt, _ := strconv.Atoi(v)
		if nt < 1 || nt > 3 {
			response.JSON(h.C, 200, response.Fail("通知分类参数错误"))
			return
		}
	}
	page, pageSize := 1, 10
	_, _ = fmt.Sscan(h.C.Query("page"), &page)
	_, _ = fmt.Sscan(h.C.Query("page_size"), &pageSize)
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}

	tbl := (&nmodel.MessageNotify{}).TableName()
	q := h.D.DBx(h.C).Model(&nmodel.MessageNotify{}).Where(tbl+".type = ?", 1).
		Where("("+tbl+".user_id = 0 OR "+tbl+".user_id = ?)", uid)
	if v := strings.TrimSpace(h.C.Query("notify_type")); v != "" {
		if nt, err := strconv.Atoi(v); err == nil {
			q = q.Where(tbl+".notify_type = ?", nt)
		}
	}
	offset := (page - 1) * pageSize
	var rows []nmodel.MessageNotify
	if err := q.Order(tbl + ".id DESC").Limit(pageSize).Offset(offset).Find(&rows).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	readMap := loadNotifyReadMap(h, uid)
	lang := strings.TrimSpace(h.C.GetHeader("Accept-Language"))
	if lang == "" {
		lang = "zh_CN"
	}
	list := make([]map[string]any, 0, len(rows))
	for _, row := range rows {
		isRead := 0
		if maxID, ok := readMap[row.NotifyType]; ok && maxID >= row.ID {
			isRead = 1
		}
		m := messageNotifyToMap(row, lang)
		m["is_read"] = isRead
		list = append(list, m)
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

func loadNotifyReadMap(h *deps.HandlerCtx, uid int64) map[int]int64 {
	out := make(map[int]int64)
	var reads []nmodel.MessageNotifyRead
	_ = h.D.DBx(h.C).Where("user_id = ?", uid).Find(&reads).Error
	for _, r := range reads {
		out[int(r.NotifyType)] = r.NotifyID
	}
	return out
}

func messageNotifyToMap(row nmodel.MessageNotify, lang string) map[string]any {
	return map[string]any{
		"id":           row.ID,
		"title":        rawJSON(row.Title),
		"content":      rawJSON(row.Content),
		"type":         row.Type,
		"user_id":      row.UserID,
		"notify_type":  row.NotifyType,
		"link":         row.Link,
		"created_at":   row.CreatedAt.Format("2006-01-02 15:04:05"),
		"updated_at":   row.UpdatedAt.Format("2006-01-02 15:04:05"),
		"title_text":   tools.FormatLang(row.Title, lang),
		"content_text": tools.FormatLang(row.Content, lang),
	}
}

func rawJSON(b json.RawMessage) any {
	if len(b) == 0 {
		return []any{}
	}
	var v any
	if err := json.Unmarshal(b, &v); err != nil {
		return string(b)
	}
	return v
}

func apiSysNotifyRead(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	var body struct {
		NotifyType int `json:"notify_type"`
		NotifyID   int `json:"notify_id"`
	}
	if !tools.BindJSONOr422(h.C, &body) {
		return
	}
	if body.NotifyType < 1 || body.NotifyType > 3 || body.NotifyID < 1 {
		response.JSON(h.C, 200, response.Fail("参数错误"))
		return
	}
	var r nmodel.MessageNotifyRead
	err := h.D.DBx(h.C).Where("user_id = ? AND notify_type = ?", uid, body.NotifyType).First(&r).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		r = nmodel.MessageNotifyRead{
			UserID:     uid,
			NotifyType: int64(body.NotifyType),
			NotifyID:   int64(body.NotifyID),
		}
		_ = h.D.DBx(h.C).Create(&r).Error
	} else if err != nil {
		response.JSON(h.C, 200, response.Fail("db error"))
		return
	} else {
		r.NotifyID = int64(body.NotifyID)
		_ = h.D.DBx(h.C).Save(&r).Error
	}
	response.JSON(h.C, 200, response.OKWithMessage("更新成功", map[string]any{}))
}

func apiSysNotifyUnreadStatistics(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	data, err := queryNotifyUnreadStats(h, uid)
	if err != nil {
		response.JSON(h.C, 200, response.Fail("stats failed"))
		return
	}
	response.JSON(h.C, 200, response.OK(data))
}

func apiSysNotifyUnreadTotal(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	data, err := queryNotifyUnreadStats(h, uid)
	if err != nil {
		response.JSON(h.C, 200, response.Fail("stats failed"))
		return
	}
	var total int
	if t, ok := data["total"].(int); ok {
		total = t
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"total": total}))
}

func apiSysNotifyClearUnread(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	tbl := (&nmodel.MessageNotify{}).TableName()
	for _, nt := range []int{1, 2, 3, 4, 5} {
		var row struct {
			M *int64 `gorm:"column:m"`
		}
		_ = h.D.DBx(h.C).Model(&nmodel.MessageNotify{}).
			Where(tbl+".notify_type = ? AND ("+tbl+".user_id = 0 OR "+tbl+".user_id = ?)", nt, uid).
			Select("MAX(id) as m").
			Scan(&row).Error
		maxID := int64(0)
		if row.M != nil {
			maxID = *row.M
		}
		if maxID <= 0 {
			continue
		}
		var r nmodel.MessageNotifyRead
		err := h.D.DBx(h.C).Where("user_id = ? AND notify_type = ?", uid, nt).First(&r).Error
		if errors.Is(err, gorm.ErrRecordNotFound) {
			_ = h.D.DBx(h.C).Create(&nmodel.MessageNotifyRead{
				UserID: uid, NotifyType: int64(nt), NotifyID: maxID,
			}).Error
		} else if err == nil {
			r.NotifyID = maxID
			_ = h.D.DBx(h.C).Save(&r).Error
		}
	}
	response.JSON(h.C, 200, response.OKWithMessage("清除成功", map[string]any{}))
}

type notifyStatSQLRow struct {
	NotifyType      int64  `gorm:"column:notify_type"`
	UnreadCount     int64  `gorm:"column:unread_count"`
	LatestID        int64  `gorm:"column:latest_id"`
	LatestTitle     string `gorm:"column:latest_title"`
	LatestContent   string `gorm:"column:latest_content"`
	LatestCreatedAt string `gorm:"column:latest_created_at"`
}

func queryNotifyUnreadStats(h *deps.HandlerCtx, userID int64) (map[string]any, error) {
	mn := (&nmodel.MessageNotify{}).TableName()
	mr := (&nmodel.MessageNotifyRead{}).TableName()
	sql := fmt.Sprintf(`
WITH notify_types AS (
  SELECT 1 AS notify_type UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
),
unread_stats AS (
  SELECT mn.notify_type, COUNT(*) AS unread_count
  FROM %s mn
  LEFT JOIN %s mnr ON mn.notify_type = mnr.notify_type AND mnr.user_id = ?
  WHERE (mn.user_id = 0 OR mn.user_id = ?)
    AND mn.id > COALESCE(mnr.notify_id, 0)
  GROUP BY mn.notify_type
),
latest_messages AS (
  SELECT mn1.notify_type, mn1.id, mn1.title, mn1.content, mn1.created_at
  FROM %s mn1
  INNER JOIN (
    SELECT notify_type, MAX(id) AS max_id
    FROM %s
    WHERE (user_id = 0 OR user_id = ?)
    GROUP BY notify_type
  ) mn2 ON mn1.notify_type = mn2.notify_type AND mn1.id = mn2.max_id
)
SELECT
  nt.notify_type,
  COALESCE(us.unread_count, 0) AS unread_count,
  COALESCE(lm.id, 0) AS latest_id,
  COALESCE(lm.title, '[]') AS latest_title,
  COALESCE(lm.content, '[]') AS latest_content,
  COALESCE(lm.created_at, '') AS latest_created_at
FROM notify_types nt
LEFT JOIN unread_stats us ON nt.notify_type = us.notify_type
LEFT JOIN latest_messages lm ON nt.notify_type = lm.notify_type
ORDER BY nt.notify_type
`, mn, mr, mn, mn)

	var rows []notifyStatSQLRow
	if err := h.D.DBx(h.C).Raw(sql, userID, userID, userID).Scan(&rows).Error; err != nil {
		return nil, err
	}
	lang := strings.TrimSpace(h.C.GetHeader("Accept-Language"))
	if lang == "" {
		lang = "zh_CN"
	}
	out := make(map[string]any)
	sum := 0
	for _, row := range rows {
		title := tools.FormatLang([]byte(row.LatestTitle), lang)
		content := tools.FormatLang([]byte(row.LatestContent), lang)
		out[strconv.FormatInt(row.NotifyType, 10)] = map[string]any{
			"unread_count": int(row.UnreadCount),
			"title":        title,
			"content":      content,
			"last_id":      row.LatestID,
			"created_at":   row.LatestCreatedAt,
		}
		sum += int(row.UnreadCount)
	}
	out["total"] = sum
	return out, nil
}
