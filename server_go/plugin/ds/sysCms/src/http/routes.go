package scmhttp

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
		{Method: "GET", Path: "/admin/article/article/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:article:list", Handler: ep(articleAdminList)},
		{Method: "POST", Path: "/admin/article/article/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:article:create", Handler: ep(articleAdminCreate)},
		{Method: "PUT", Path: "/admin/article/article/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:article:save", Handler: ep(articleAdminSave)},
		{Method: "DELETE", Path: "/admin/article/article/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:article:delete", Handler: ep(articleAdminDelete)},

		{Method: "GET", Path: "/admin/article/category/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:list", Handler: ep(categoryAdminList)},
		{Method: "POST", Path: "/admin/article/category/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:create", Handler: ep(categoryAdminCreate)},
		{Method: "PUT", Path: "/admin/article/category/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:save", Handler: ep(categoryAdminSave)},
		{Method: "DELETE", Path: "/admin/article/category/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:delete", Handler: ep(categoryAdminDelete)},
		{Method: "GET", Path: "/admin/article/category/selectCategory", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:list", Handler: ep(categorySelectTree)},
		{Method: "GET", Path: "/admin/article/category/selectCreator", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:category:create", Handler: ep(categorySelectCreator)},

		{Method: "GET", Path: "/admin/ds/sysCms/placement_position/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_position:list", Handler: ep(placementPositionList)},
		{Method: "GET", Path: "/admin/ds/sysCms/placement_position/selectPlacementPosition", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_position:list", Handler: ep(placementPositionSelect)},
		{Method: "POST", Path: "/admin/ds/sysCms/placement_position/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_position:create", Handler: ep(placementPositionCreate)},
		{Method: "PUT", Path: "/admin/ds/sysCms/placement_position/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_position:save", Handler: ep(placementPositionSave)},
		{Method: "DELETE", Path: "/admin/ds/sysCms/placement_position/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_position:delete", Handler: ep(placementPositionDelete)},

		{Method: "GET", Path: "/admin/ds/sysCms/placement_content/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_content:list", Handler: ep(placementContentList)},
		{Method: "POST", Path: "/admin/ds/sysCms/placement_content/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_content:create", Handler: ep(placementContentCreate)},
		{Method: "PUT", Path: "/admin/ds/sysCms/placement_content/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_content:save", Handler: ep(placementContentSave)},
		{Method: "DELETE", Path: "/admin/ds/sysCms/placement_content/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:placement_content:delete", Handler: ep(placementContentDelete)},

		{Method: "GET", Path: "/admin/ds/sysCms/app_page_content/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content:list", Handler: ep(appPageContentList)},
		{Method: "POST", Path: "/admin/ds/sysCms/app_page_content/create", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content:create", Handler: ep(appPageContentCreate)},
		{Method: "PUT", Path: "/admin/ds/sysCms/app_page_content/save/:id", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content:save", Handler: ep(appPageContentSave)},
		{Method: "DELETE", Path: "/admin/ds/sysCms/app_page_content/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content:delete", Handler: ep(appPageContentDelete)},

		{Method: "GET", Path: "/admin/ds/sysCms/app_page_content_sync/list", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content_sync:list", Handler: ep(appPageContentSyncList)},
		{Method: "POST", Path: "/admin/ds/sysCms/app_page_content_sync/generate", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content_sync:generate", Handler: ep(appPageContentSyncGenerate)},
		{Method: "DELETE", Path: "/admin/ds/sysCms/app_page_content_sync/delete", Auth: router.KindAdminJWT, MenuPerm: "ds:sysCms:app_page_content_sync:list", Handler: ep(appPageContentSyncDelete)},

		{Method: "GET", Path: "/api/feed/article/news", Auth: router.KindAPIJWT, Handler: ep(apiArticleNews)},
		{Method: "GET", Path: "/api/feed/article/notice", Auth: router.KindAPIJWT, Handler: ep(apiArticleNotice)},
		{Method: "GET", Path: "/api/feed/article/helpManual", Auth: router.KindAPIJWT, Handler: ep(apiArticleHelpManual)},
		{Method: "GET", Path: "/api/feed/article/categoryList", Auth: router.KindAPIJWT, Handler: ep(apiArticleCategoryList)},
		{Method: "GET", Path: "/api/feed/article/list", Auth: router.KindAPIJWT, Handler: ep(apiArticleSearchList)},
		{Method: "GET", Path: "/api/feed/article/detail", Auth: router.KindAPIJWT, Handler: ep(apiArticleDetail)},
		{Method: "GET", Path: "/api/app/page-content/download", Auth: router.KindPublic, Handler: ep(apiAppPageContentDownload)},
	}
}
