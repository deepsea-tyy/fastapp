package snfyhttp

import (
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/router"

	"github.com/gin-gonic/gin"
)

func ep(fn func(*deps.HandlerCtx)) func(*deps.Deps) gin.HandlerFunc {
	return func(d *deps.Deps) gin.HandlerFunc { return deps.Bind(d, fn) }
}

// Endpoints 注册本插件 HTTP 路由。
func Endpoints() []router.Endpoint {
	return []router.Endpoint{
		{Method: "GET", Path: "/admin/ds/sysNotify/message_notify/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysNotify:message_notify:list", Handler: ep(sysNotifyAdminPageList)},
		{Method: "POST", Path: "/admin/ds/sysNotify/message_notify/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysNotify:message_notify:create", Handler: ep(sysNotifyAdminCreate)},
		{Method: "PUT", Path: "/admin/ds/sysNotify/message_notify/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysNotify:message_notify:save", Handler: ep(sysNotifyAdminSave)},
		{Method: "DELETE", Path: "/admin/ds/sysNotify/message_notify/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysNotify:message_notify:delete", Handler: ep(sysNotifyAdminDelete)},

		{Method: "GET", Path: "/api/sysNotify/list", Auth: router.KindAPIJWT, Handler: ep(apiSysNotifyList)},
		{Method: "POST", Path: "/api/sysNotify/read", Auth: router.KindAPIJWT, Handler: ep(apiSysNotifyRead)},
		{Method: "GET", Path: "/api/sysNotify/unread-statistics", Auth: router.KindAPIJWT, Handler: ep(apiSysNotifyUnreadStatistics)},
		{Method: "GET", Path: "/api/sysNotify/unread-total", Auth: router.KindAPIJWT, Handler: ep(apiSysNotifyUnreadTotal)},
		{Method: "POST", Path: "/api/sysNotify/clear-unread", Auth: router.KindAPIJWT, Handler: ep(apiSysNotifyClearUnread)},
	}
}
