package skfuhttp

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"strconv"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/middleware"
	kefumodel "fastapp/plugin/ds/sysKefu/src/model"
	kefuws "fastapp/plugin/ds/sysKefu/src/websocket"

	"gorm.io/gorm"
)

const visitorIDPrefix = "visitor_"

func apiKefuMessageList(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	cidStr := h.C.Query("conversation_id")
	if cidStr == "" {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "conversation_id required", nil))
		return
	}
	cid, err := strconv.ParseInt(cidStr, 10, 64)
	if err != nil || cid <= 0 {
		response.JSON(h.C, 200, response.WithCode(response.CodeUnprocessable, "conversation_id invalid", nil))
		return
	}
	var conv kefumodel.KefuConversation
	if err := h.D.DBx(h.C).Where("id = ? AND user_id = ?", cid, uid).First(&conv).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("not found"))
		return
	}
	page, pageSize := tools.ParsePage(h.C)
	var list []kefumodel.KefuMessage
	if err := h.D.DBx(h.C).Where("conversation_id = ?", cid).Order("id DESC").Limit(pageSize).Offset((page - 1) * pageSize).Find(&list).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("query failed"))
		return
	}
	for i, j := 0, len(list)-1; i < j; i, j = i+1, j-1 {
		list[i], list[j] = list[j], list[i]
	}
	response.JSON(h.C, 200, response.OK(map[string]any{"list": list}))
}

func apiKefuGetConversation(h *deps.HandlerCtx) {
	uid := middleware.UserID(h.C)
	lang := tools.ProfileLang(h.D.DBx(h.C), uid)

	var conv kefumodel.KefuConversation
	err := h.D.DBx(h.C).Where("user_id = ?", uid).First(&conv).Error
	var kefu kefumodel.Kefu
	if err != nil {
		if !errors.Is(err, gorm.ErrRecordNotFound) {
			response.JSON(h.C, 200, response.Fail("query failed"))
			return
		}
		if err := h.D.DBx(h.C).Order("current_concurrent ASC, id ASC").First(&kefu).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("no kefu available"))
			return
		}
		conv = kefumodel.KefuConversation{KefuID: kefu.ID, UserID: uid, Status: 1}
		if err := h.D.DBx(h.C).Create(&conv).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("create conversation failed"))
			return
		}
		_ = h.D.DBx(h.C).Model(&kefumodel.Kefu{}).Where("id = ?", kefu.ID).UpdateColumn("current_concurrent", gorm.Expr("current_concurrent + ?", 1)).Error
	} else {
		if err := h.D.DBx(h.C).Where("id = ?", conv.KefuID).First(&kefu).Error; err != nil {
			response.JSON(h.C, 200, response.Fail("kefu not found"))
			return
		}
	}

	var help []string
	if rules, err := kefuws.FetchEnabledAutoReplyRules(h.C.Request.Context(), h.D.DBx(h.C), h.D.RDB, lang); err == nil {
		for i := range rules {
			help = append(help, rules[i].Title)
		}
	}

	data := map[string]any{
		"id":      conv.ID,
		"kefu_id": conv.KefuID,
		"user_id": conv.UserID,
		"status":  conv.Status,
		"kefu_info": map[string]any{
			"id":        kefu.ID,
			"nickname":  kefu.Nickname,
			"avatar":    kefu.Avatar,
			"is_online": kefu.Status == 1,
		},
		"help": help,
	}
	response.JSON(h.C, 200, response.OK(data))
}

func apiKefuGetVisitorKefu(h *deps.HandlerCtx) {
	var kefuRow kefumodel.Kefu
	if err := h.D.DBx(h.C).Order("current_concurrent ASC, id ASC").First(&kefuRow).Error; err != nil {
		response.JSON(h.C, 200, response.Fail("no kefu available"))
		return
	}
	b := make([]byte, 4)
	_, _ = rand.Read(b)
	vid := visitorIDPrefix + hex.EncodeToString(b)
	response.JSON(h.C, 200, response.OK(map[string]any{"kefu_id": kefuRow.ID, "visitor_id": vid}))
}
