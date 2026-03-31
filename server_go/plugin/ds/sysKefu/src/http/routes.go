package skfuhttp

import (
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/router"

	"github.com/gin-gonic/gin"
)

func ep(fn func(*deps.HandlerCtx)) func(*deps.Deps) gin.HandlerFunc {
	return func(d *deps.Deps) gin.HandlerFunc { return deps.Bind(d, fn) }
}

// Endpoints 注册本插件 HTTP 路由（后台与开放 API）。
func Endpoints() []router.Endpoint {
	return []router.Endpoint{
		{Method: "GET", Path: "/admin/ds/sysKefu/kefu/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefu:index", Handler: ep(kefuAdminPageList)},
		{Method: "POST", Path: "/admin/ds/sysKefu/kefu/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefu:save", Handler: ep(kefuAdminCreate)},
		{Method: "PUT", Path: "/admin/ds/sysKefu/kefu/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefu:update", Handler: ep(kefuAdminSave)},
		{Method: "DELETE", Path: "/admin/ds/sysKefu/kefu/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefu:delete", Handler: ep(kefuAdminDelete)},

		{Method: "GET", Path: "/admin/ds/sysKefu/kefuConversation/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefuConversation:index", Handler: ep(kefuConversationAdminPage)},
		{Method: "DELETE", Path: "/admin/ds/sysKefu/kefuConversation", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:kefuConversation:delete", Handler: ep(kefuConversationAdminDelete)},
		{Method: "GET", Path: "/admin/ds/sysKefu/kefuConversation/chatTree", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:chat", Handler: ep(kefuAdminChatTree)},
		{Method: "GET", Path: "/admin/ds/sysKefu/kefuConversation/chatVisitorTree", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:chat", Handler: ep(kefuAdminChatVisitorTree)},
		{Method: "GET", Path: "/admin/ds/sysKefu/kefuConversation/message", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:chat", Handler: ep(kefuConversationAdminMessage)},
		{Method: "GET", Path: "/admin/ds/sysKefu/kefuConversation/messageVisitor", Auth: router.KindAdminJWT, MenuPerm: "ds:sysKefu:chat", Handler: ep(kefuConversationAdminMessageVisitor)},

		{Method: "GET", Path: "/admin/ds/syskefu/kefu_auto_reply/list", Auth: router.KindAdminJWT, MenuPerm: "ds:syskefu:kefu_auto_reply:list", Handler: ep(kefuAutoReplyAdminList)},
		{Method: "POST", Path: "/admin/ds/syskefu/kefu_auto_reply/create", Auth: router.KindAdminJWT, MenuPerm: "ds:syskefu:kefu_auto_reply:create", Handler: ep(kefuAutoReplyAdminCreate)},
		{Method: "PUT", Path: "/admin/ds/syskefu/kefu_auto_reply/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:syskefu:kefu_auto_reply:save", Handler: ep(kefuAutoReplyAdminSave)},
		{Method: "DELETE", Path: "/admin/ds/syskefu/kefu_auto_reply/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:syskefu:kefu_auto_reply:delete", Handler: ep(kefuAutoReplyAdminDelete)},

		{Method: "GET", Path: "/api/ds/sysKefu/messages", Auth: router.KindAPIJWT, Handler: ep(apiKefuMessageList)},
		{Method: "GET", Path: "/api/ds/sysKefu/conversation", Auth: router.KindAPIJWT, Handler: ep(apiKefuGetConversation)},
		{Method: "GET", Path: "/api/ds/sysKefu/visitor/kefu", Auth: router.KindPublic, Handler: ep(apiKefuGetVisitorKefu)},
	}
}
