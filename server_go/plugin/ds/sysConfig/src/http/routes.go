package scfghttp

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
		{Method: "GET", Path: "/system/ConfigGroup/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfigGroup:list", Handler: ep(sysConfigGroupListWithInfo)},
		{Method: "POST", Path: "/system/ConfigGroup", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfigGroup:index:create", Handler: ep(sysConfigGroupCreate)},
		{Method: "PUT", Path: "/system/ConfigGroup/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfigGroup:update", Handler: ep(sysConfigGroupSave)},
		{Method: "DELETE", Path: "/system/ConfigGroup", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfigGroup:delete", Handler: ep(sysConfigGroupDelete)},

		{Method: "GET", Path: "/system/Config/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:list", Handler: ep(sysConfigPageList)},
		{Method: "POST", Path: "/system/Config", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:create", Handler: ep(sysConfigCreate)},
		{Method: "PUT", Path: "/system/Config/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:update", Handler: ep(sysConfigSave)},
		{Method: "DELETE", Path: "/system/Config", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:delete", Handler: ep(sysConfigDelete)},
		{Method: "GET", Path: "/system/Config/Details/:code", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:details", Handler: ep(sysConfigDetails)},
		{Method: "POST", Path: "/system/Config/batchUpdate", Auth: router.KindAdminJWT, MenuPerm: "ds:sysConfig:batchUpdate", Handler: ep(sysConfigBatchUpdate)},

		{Method: "GET", Path: "/api/ds/sysConfig/configByGroup", Auth: router.KindAPIJWT, Handler: ep(apiSystemConfigByGroup)},
	}
}
