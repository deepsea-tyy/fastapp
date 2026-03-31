package admin

import (
	"encoding/json"
	"strconv"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/menu"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type menuBtnPayload struct {
	ID    int64  `json:"id"`
	Type  string `json:"type"`
	Code  string `json:"code"`
	Title string `json:"title"`
	I18n  string `json:"i18n"`
}

type menuCreateBody struct {
	ParentID      int64            `json:"parent_id"`
	Name          string           `json:"name"`
	Path          string           `json:"path"`
	Component     string           `json:"component"`
	Redirect      string           `json:"redirect"`
	Status        int              `json:"status"`
	Sort          int              `json:"sort"`
	Remark        string           `json:"remark"`
	Meta          map[string]any   `json:"meta"`
	BtnPermission []menuBtnPayload `json:"btnPermission"`
}

type menuSaveBody struct {
	ParentID      int64             `json:"parent_id"`
	Name          string            `json:"name"`
	Path          string            `json:"path"`
	Component     string            `json:"component"`
	Redirect      string            `json:"redirect"`
	Status        int               `json:"status"`
	Sort          int               `json:"sort"`
	Remark        string            `json:"remark"`
	Meta          map[string]any    `json:"meta"`
	BtnPermission *[]menuBtnPayload `json:"btnPermission,omitempty"`
}

func MenuList(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var flat []model.Menu
		if err := h.D.DBx(h.C).Order("sort asc, id asc").Find(&flat).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("menu query failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(menu.BuildTree(flat)))
	})
}

func MenuCreate(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var body menuCreateBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Name == "" || metaTitle(body.Meta) == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "name and meta.title required", nil))
			return
		}
		if body.Status == 0 {
			body.Status = 1
		}
		metaBytes, err := marshalMeta(body.Meta)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("meta invalid"))
			return
		}
		uid := middleware.UserID(h.C)
		m := model.Menu{
			ParentID:  body.ParentID,
			Name:      body.Name,
			Path:      body.Path,
			Component: body.Component,
			Redirect:  body.Redirect,
			Status:    body.Status,
			Sort:      body.Sort,
			Remark:    body.Remark,
			Meta:      metaBytes,
			CreatedBy: uid,
		}
		err = h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			if err := tx.Create(&m).Error; err != nil {
				return err
			}
			if metaType(body.Meta) == "M" && len(body.BtnPermission) > 0 {
				for _, bp := range body.BtnPermission {
					if bp.Code == "" {
						continue
					}
					bmeta, _ := json.Marshal(map[string]any{
						"title": bp.Title,
						"i18n":  bp.I18n,
						"type":  "B",
					})
					ch := model.Menu{
						ParentID:  m.ID,
						Name:      bp.Code,
						Status:    1,
						Sort:      0,
						Meta:      bmeta,
						CreatedBy: uid,
					}
					if err := tx.Create(&ch).Error; err != nil {
						return err
					}
				}
			}
			return nil
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("create failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func MenuSave(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		idStr := h.C.Param("id")
		id, err := strconv.ParseInt(idStr, 10, 64)
		if err != nil || id < 1 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "invalid id", nil))
			return
		}
		var body menuSaveBody
		if !tools.BindJSONOr422(h.C, &body) {
			return
		}
		if body.Name == "" || metaTitle(body.Meta) == "" {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "name and meta.title required", nil))
			return
		}
		if body.Status == 0 {
			body.Status = 1
		}
		metaBytes, err := marshalMeta(body.Meta)
		if err != nil {
			response.JSON(h.C, 200, response.Fail("meta invalid"))
			return
		}
		uid := middleware.UserID(h.C)
		err = h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			up := map[string]any{
				"parent_id":  body.ParentID,
				"name":       body.Name,
				"path":       body.Path,
				"component":  body.Component,
				"redirect":   body.Redirect,
				"status":     body.Status,
				"sort":       body.Sort,
				"remark":     body.Remark,
				"meta":       metaBytes,
				"updated_by": uid,
			}
			if err := tx.Model(&model.Menu{}).Where("id = ?", id).Updates(up).Error; err != nil {
				return err
			}
			if body.BtnPermission != nil && metaType(body.Meta) == "M" {
				return syncBtnPermissions(tx, id, uid, *body.BtnPermission)
			}
			return nil
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("save failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func MenuDelete(d *deps.Deps) gin.HandlerFunc {
	return deps.Bind(d, func(h *deps.HandlerCtx) {
		var ids []int64
		if !tools.BindJSONOr422(h.C, &ids) {
			return
		}
		if len(ids) == 0 {
			response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "ids required", nil))
			return
		}
		err := h.D.DBx(h.C).Transaction(func(tx *gorm.DB) error {
			return deleteMenusByIDs(tx, ids)
		})
		if err != nil {
			response.JSON(h.C, 200, response.Fail("delete failed"))
			return
		}
		response.JSON(h.C, 200, response.OK(nil))
	})
}

func metaType(m map[string]any) string {
	if m == nil {
		return ""
	}
	v, _ := m["type"].(string)
	return v
}

func metaTitle(m map[string]any) string {
	if m == nil {
		return ""
	}
	v, _ := m["title"].(string)
	return v
}

func marshalMeta(m map[string]any) (json.RawMessage, error) {
	if m == nil {
		return json.RawMessage("{}"), nil
	}
	return json.Marshal(m)
}

// syncBtnPermissions 对齐 MenuService::updateById 中 btnPermission 与按钮子节点逻辑。
func syncBtnPermissions(tx *gorm.DB, parentID int64, uid int64, items []menuBtnPayload) error {
	var children []model.Menu
	if err := tx.Where("parent_id = ?", parentID).Find(&children).Error; err != nil {
		return err
	}
	existingB := make(map[int64]struct{})
	for _, ch := range children {
		var mo map[string]any
		if len(ch.Meta) == 0 {
			continue
		}
		_ = json.Unmarshal(ch.Meta, &mo)
		if metaType(mo) == "B" {
			existingB[ch.ID] = struct{}{}
		}
	}

	for _, item := range items {
		if item.Type != "B" || item.Code == "" {
			continue
		}
		bmeta, _ := json.Marshal(map[string]any{
			"title": item.Title,
			"i18n":  item.I18n,
			"type":  "B",
		})
		if item.ID > 0 {
			if err := tx.Model(&model.Menu{}).Where("id = ?", item.ID).Updates(map[string]any{
				"name":       item.Code,
				"meta":       bmeta,
				"updated_by": uid,
			}).Error; err != nil {
				return err
			}
			delete(existingB, item.ID)
			continue
		}
		ch := model.Menu{
			ParentID:  parentID,
			Name:      item.Code,
			Status:    1,
			Sort:      0,
			Meta:      bmeta,
			CreatedBy: uid,
		}
		if err := tx.Create(&ch).Error; err != nil {
			return err
		}
	}

	if len(existingB) > 0 {
		ids := make([]int64, 0, len(existingB))
		for bid := range existingB {
			ids = append(ids, bid)
		}
		if err := deleteMenusByIDs(tx, ids); err != nil {
			return err
		}
	}
	return nil
}

func deleteMenusByIDs(tx *gorm.DB, ids []int64) error {
	if len(ids) == 0 {
		return nil
	}
	if err := tx.Exec("DELETE FROM "+model.P+"role_belongs_menu WHERE menu_id IN ?", ids).Error; err != nil {
		return err
	}
	return tx.Where("id IN ?", ids).Delete(&model.Menu{}).Error
}
