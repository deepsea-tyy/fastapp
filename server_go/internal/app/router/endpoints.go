package router

import (
	"fastapp/internal/app/common/deps"
	apphttp "fastapp/internal/app/http"
	"fastapp/internal/app/http/admin"
	"fastapp/internal/app/http/api/user"

	"github.com/gin-gonic/gin"
)

// Kind 鉴权方式（无占位路由，未注册即 404）。
type Kind int

const (
	// KindPublic 无需 JWT（如登录、验证码）。
	KindPublic Kind = iota
	// KindAdminJWT 管理端 access token；可选再叠加 MenuPerm。
	KindAdminJWT
	// KindAPIJWT App 端 access token。
	KindAPIJWT
)

// Endpoint 单条 HTTP 路由声明。MenuPerm 与菜单表 name 一致。
type Endpoint struct {
	Method   string
	Path     string
	Auth     Kind
	MenuPerm string
	Handler  func(*deps.Deps) gin.HandlerFunc
}

// Endpoints 核心 HTTP 路由表；已安装插件路由由 plugin 包聚合为 []Endpoint 并入 registerCoreRoutes。
func Endpoints() []Endpoint {
	return []Endpoint{
		// Admin — Passport（无菜单权限）
		{Method: "POST", Path: "/admin/passport/login", Auth: KindPublic, Handler: admin.PassportLogin},
		{Method: "GET", Path: "/admin/passport/captcha", Auth: KindPublic, Handler: admin.PassportCaptcha},
		{Method: "GET", Path: "/admin/passport/refresh", Auth: KindPublic, Handler: admin.PassportRefresh},
		{Method: "POST", Path: "/admin/passport/logout", Auth: KindAdminJWT, Handler: admin.PassportLogout},
		{Method: "GET", Path: "/admin/passport/getInfo", Auth: KindAdminJWT, Handler: admin.PassportGetInfo},
		// 仅需登录的管理端接口
		{Method: "GET", Path: "/admin/permission/menus", Auth: KindAdminJWT, Handler: admin.PermissionMenus},
		{Method: "GET", Path: "/admin/permission/roles", Auth: KindAdminJWT, Handler: admin.PermissionRoles},
		{Method: "POST", Path: "/admin/permission/update", Auth: KindAdminJWT, Handler: admin.PermissionSelfUpdate},
		// 菜单管理（MenuController）
		{Method: "GET", Path: "/admin/menu/list", Auth: KindAdminJWT, MenuPerm: "permission:menu:index", Handler: admin.MenuList},
		{Method: "POST", Path: "/admin/menu", Auth: KindAdminJWT, MenuPerm: "permission:menu:create", Handler: admin.MenuCreate},
		{Method: "PUT", Path: "/admin/menu/:id", Auth: KindAdminJWT, MenuPerm: "permission:menu:save", Handler: admin.MenuSave},
		{Method: "DELETE", Path: "/admin/menu", Auth: KindAdminJWT, MenuPerm: "permission:menu:delete", Handler: admin.MenuDelete},
		// 用户 / 角色 / 部门
		{Method: "GET", Path: "/admin/user/list", Auth: KindAdminJWT, MenuPerm: "permission:user:index", Handler: admin.PermissionUserList},
		{Method: "GET", Path: "/admin/user/selectUser", Auth: KindAdminJWT, Handler: admin.PermissionUserSelect},
		{Method: "GET", Path: "/admin/user/clearCache", Auth: KindAdminJWT, Handler: admin.PermissionUserClearCache},
		{Method: "PUT", Path: "/admin/user", Auth: KindAdminJWT, MenuPerm: "permission:user:update", Handler: admin.PermissionUserUpdateSelf},
		{Method: "PUT", Path: "/admin/user/password", Auth: KindAdminJWT, MenuPerm: "permission:user:password", Handler: admin.PermissionUserResetPassword},
		{Method: "POST", Path: "/admin/user", Auth: KindAdminJWT, MenuPerm: "permission:user:save", Handler: admin.PermissionUserCreate},
		{Method: "DELETE", Path: "/admin/user", Auth: KindAdminJWT, MenuPerm: "permission:user:delete", Handler: admin.PermissionUserDelete},
		{Method: "PUT", Path: "/admin/user/:userId", Auth: KindAdminJWT, MenuPerm: "permission:user:update", Handler: admin.PermissionUserSave},
		{Method: "GET", Path: "/admin/user/:userId/roles", Auth: KindAdminJWT, MenuPerm: "permission:user:getRole", Handler: admin.PermissionUserRolesGet},
		{Method: "PUT", Path: "/admin/user/:userId/roles", Auth: KindAdminJWT, MenuPerm: "permission:user:setRole", Handler: admin.PermissionUserRolesPut},
		{Method: "GET", Path: "/admin/role/list", Auth: KindAdminJWT, MenuPerm: "permission:role:index", Handler: admin.PermissionRoleList},
		{Method: "POST", Path: "/admin/role", Auth: KindAdminJWT, MenuPerm: "permission:role:save", Handler: admin.PermissionRoleCreate},
		{Method: "PUT", Path: "/admin/role/:id", Auth: KindAdminJWT, MenuPerm: "permission:role:update", Handler: admin.PermissionRoleSave},
		{Method: "DELETE", Path: "/admin/role", Auth: KindAdminJWT, MenuPerm: "permission:role:delete", Handler: admin.PermissionRoleDelete},
		{Method: "GET", Path: "/admin/role/:id/permissions", Auth: KindAdminJWT, MenuPerm: "permission:role:save", Handler: admin.PermissionRoleMenusGet},
		{Method: "PUT", Path: "/admin/role/:id/permissions", Auth: KindAdminJWT, MenuPerm: "permission:role:save", Handler: admin.PermissionRoleMenusPut},
		{Method: "GET", Path: "/admin/role/:id/departments", Auth: KindAdminJWT, MenuPerm: "permission:role:save", Handler: admin.PermissionRoleDeptsGet},
		{Method: "GET", Path: "/admin/department/list", Auth: KindAdminJWT, MenuPerm: "permission:department:index", Handler: admin.PermissionDepartmentList},
		{Method: "GET", Path: "/admin/department/selectDept", Auth: KindAdminJWT, MenuPerm: "permission:department:index", Handler: admin.PermissionDepartmentSelect},
		{Method: "POST", Path: "/admin/department", Auth: KindAdminJWT, MenuPerm: "permission:department:save", Handler: admin.PermissionDepartmentCreate},
		{Method: "PUT", Path: "/admin/department/:id", Auth: KindAdminJWT, MenuPerm: "permission:department:update", Handler: admin.PermissionDepartmentSave},
		{Method: "DELETE", Path: "/admin/department", Auth: KindAdminJWT, MenuPerm: "permission:department:delete", Handler: admin.PermissionDepartmentDelete},
		// 附件（路径与 admin/src/base/api/attachment.ts 一致，非 /admin 前缀）
		{Method: "GET", Path: "/attachment/list", Auth: KindAdminJWT, MenuPerm: "dataCenter:attachment:list", Handler: admin.AttachmentList},
		{Method: "POST", Path: "/attachment/upload", Auth: KindAdminJWT, MenuPerm: "dataCenter:attachment:upload", Handler: admin.AttachmentUpload},
		{Method: "DELETE", Path: "/attachment/:id", Auth: KindAdminJWT, MenuPerm: "dataCenter:attachment:delete", Handler: admin.AttachmentDelete},
		{Method: "POST", Path: "/attachment/chunk-upload", Auth: KindAdminJWT, MenuPerm: "dataCenter:attachment:upload", Handler: admin.AttachmentChunkUpload},
		{Method: "POST", Path: "/attachment/chunk-merge", Auth: KindAdminJWT, MenuPerm: "dataCenter:attachment:upload", Handler: admin.AttachmentChunkMerge},
		// 搜索后台
		{Method: "GET", Path: "/admin/search/keyword/list", Auth: KindAdminJWT, MenuPerm: "search:keyword:list", Handler: admin.SearchKeywordList},
		{Method: "POST", Path: "/admin/search/keyword/create", Auth: KindAdminJWT, MenuPerm: "search:keyword:create", Handler: admin.SearchKeywordCreate},
		{Method: "PUT", Path: "/admin/search/keyword/save/:id", Auth: KindAdminJWT, MenuPerm: "search:keyword:save", Handler: admin.SearchKeywordSave},
		{Method: "DELETE", Path: "/admin/search/keyword/delete", Auth: KindAdminJWT, MenuPerm: "search:keyword:delete", Handler: admin.SearchKeywordDelete},
		{Method: "GET", Path: "/admin/search/indexs/list", Auth: KindAdminJWT, MenuPerm: "search:indexs:list", Handler: admin.SearchIndexList},
		{Method: "POST", Path: "/admin/search/indexs/create", Auth: KindAdminJWT, MenuPerm: "search:indexs:create", Handler: admin.SearchIndexCreate},
		{Method: "PUT", Path: "/admin/search/indexs/save/:id", Auth: KindAdminJWT, MenuPerm: "search:indexs:save", Handler: admin.SearchIndexSave},
		{Method: "DELETE", Path: "/admin/search/indexs/delete", Auth: KindAdminJWT, MenuPerm: "search:indexs:delete", Handler: admin.SearchIndexDelete},
		// 登录 / 操作日志（Logstash）
		{Method: "GET", Path: "/admin/user-login-log/list", Auth: KindAdminJWT, MenuPerm: "log:userLogin:list", Handler: admin.UserAdminLoginLogList},
		{Method: "DELETE", Path: "/admin/user-login-log", Auth: KindAdminJWT, MenuPerm: "log:userLogin:delete", Handler: admin.UserAdminLoginLogDelete},
		{Method: "GET", Path: "/admin/user-operation-log/list", Auth: KindAdminJWT, MenuPerm: "log:userOperation:list", Handler: admin.UserAdminOperationLogList},
		{Method: "DELETE", Path: "/admin/user-operation-log", Auth: KindAdminJWT, MenuPerm: "log:userOperation:delete", Handler: admin.UserAdminOperationLogDelete},
		// App — 用户认证与资料
		{Method: "POST", Path: "/api/user/register", Auth: KindPublic, Handler: apphttp.UserRegister},
		{Method: "GET", Path: "/api/user/isRegister", Auth: KindPublic, Handler: apphttp.UserIsRegister},
		{Method: "GET", Path: "/api/sms", Auth: KindPublic, Handler: apphttp.UserSms},
		{Method: "POST", Path: "/api/user/smsCheck", Auth: KindPublic, Handler: apphttp.UserSmsCheck},
		{Method: "POST", Path: "/api/user/login", Auth: KindPublic, Handler: apphttp.UserLogin},
		{Method: "POST", Path: "/api/user/logout", Auth: KindAPIJWT, Handler: user.UserLogout},
		{Method: "POST", Path: "/api/user/refreshToken", Auth: KindPublic, Handler: apphttp.UserRefreshToken},
		{Method: "GET", Path: "/api/user/info", Auth: KindAPIJWT, Handler: user.UserInfo},
		{Method: "POST", Path: "/api/user/password/change", Auth: KindAPIJWT, Handler: user.UserPasswordChange},
		{Method: "POST", Path: "/api/user/account/disable", Auth: KindAPIJWT, Handler: user.UserAccountDisable},
		{Method: "POST", Path: "/api/user/account/delete", Auth: KindAPIJWT, Handler: user.UserAccountDelete},
		{Method: "GET", Path: "/api/user/google2fa/qrcode", Auth: KindAPIJWT, Handler: user.UserGoogle2faQrcode},
		{Method: "POST", Path: "/api/user/google2fa/bind", Auth: KindAPIJWT, Handler: user.UserGoogle2faBind},
		{Method: "POST", Path: "/api/user/google2fa/unbind", Auth: KindAPIJWT, Handler: user.UserGoogle2faUnbind},
		{Method: "POST", Path: "/api/user/email/bind", Auth: KindAPIJWT, Handler: user.UserEmailBind},
		{Method: "POST", Path: "/api/user/email/unbind", Auth: KindAPIJWT, Handler: user.UserEmailUnbind},
		{Method: "POST", Path: "/api/user/mobile/bind", Auth: KindAPIJWT, Handler: user.UserMobileBind},
		{Method: "POST", Path: "/api/user/mobile/unbind", Auth: KindAPIJWT, Handler: user.UserMobileUnbind},
		{Method: "GET", Path: "/api/user/accountLogs", Auth: KindAPIJWT, Handler: user.UserAccountLogs},
		{Method: "POST", Path: "/api/user/profile/update", Auth: KindAPIJWT, Handler: user.UserProfileUpdate},
		{Method: "POST", Path: "/api/user/resetPassword", Auth: KindPublic, Handler: apphttp.UserResetPassword},
		{Method: "GET", Path: "/api/user/baseInfo", Auth: KindPublic, Handler: apphttp.UserBaseInfo},
		// App — 文件 / 附件 / 搜索
		{Method: "GET", Path: "/api/file", Auth: KindPublic, Handler: user.StorageFileGet},
		{Method: "GET", Path: "/api/attachment/list", Auth: KindAPIJWT, Handler: admin.AppAttachmentList},
		{Method: "POST", Path: "/api/attachment/upload", Auth: KindAPIJWT, Handler: admin.AttachmentUpload},
		{Method: "DELETE", Path: "/api/attachment/:id", Auth: KindAPIJWT, Handler: admin.AttachmentDelete},
		{Method: "POST", Path: "/api/attachment/chunk-upload", Auth: KindAPIJWT, Handler: admin.AttachmentChunkUpload},
		{Method: "POST", Path: "/api/attachment/chunk-merge", Auth: KindAPIJWT, Handler: admin.AttachmentChunkMerge},
		{Method: "GET", Path: "/api/search", Auth: KindPublic, Handler: user.SearchGlobal},
		{Method: "GET", Path: "/api/search/suggest", Auth: KindPublic, Handler: user.SearchSuggest},
		{Method: "GET", Path: "/api/search/ranking", Auth: KindPublic, Handler: user.SearchRanking},
		{Method: "GET", Path: "/api/search/keywords/hot", Auth: KindPublic, Handler: user.SearchHotKeywords},
		{Method: "POST", Path: "/api/search/click", Auth: KindPublic, Handler: user.SearchClick},
	}
}
