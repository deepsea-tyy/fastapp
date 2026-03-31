package gen

import (
	"fmt"
	"io"
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"
)

// WriteEndpointsSnippet 写入需手工合并到路由表的片段。
func WriteEndpointsSnippet(w io.Writer, b *CrudBundle) error {
	p := b.PermPrefix
	h := b.HTTPPrefix
	if b.IsPlugin {
		hb := b.handlerPluginBase()
		_, err := fmt.Fprintf(w, `// 对照用（gen crud 已尝试自动追加到 src/http/routes.go 末尾）。MenuPerm 须与 menu.name、plugin uninstall 一致；见 docs/plugins.md#plugin-menu-names：
{Method: "GET", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: ep(%sList)},
{Method: "POST", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: ep(%sCreate)},
{Method: "PUT", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: ep(%sSave)},
{Method: "DELETE", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: ep(%sDelete)},
`, h+"/list", p+":list", hb,
			h+"/create", p+":create", hb,
			h+"/save/:id", p+":save", hb,
			h+"/delete", p+":delete", hb,
		)
		return err
	}
	_, err := fmt.Fprintf(w, `// 对照用（gen crud 已尝试自动追加到 internal/app/router/endpoints.go 末尾）：
{Method: "GET", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: admin.%sList},
{Method: "POST", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: admin.%sCreate},
{Method: "PUT", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: admin.%sSave},
{Method: "DELETE", Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: admin.%sDelete},
`, h+"/list", p+":list", b.StructName,
		h+"/create", p+":create", b.StructName,
		h+"/save/:id", p+":save", b.StructName,
		h+"/delete", p+":delete", b.StructName,
	)
	return err
}

// CrudGoOutputPath 生成 Go handler 文件路径。
func CrudGoOutputPath(root string, b *CrudBundle) string {
	if b.Opts.GoOut != "" {
		return b.Opts.GoOut
	}
	base := "crud_gen_" + strings.ReplaceAll(b.Opts.Table, "/", "_") + ".go"
	if b.IsPlugin {
		return tools.RootJoin(root, "plugin", filepath.FromSlash(b.PluginPath), "src", "http", base)
	}
	return tools.RootJoin(root, "internal", "app", "http", "admin", base)
}

// CrudAdminFrontDir admin 前端 views 目录。
func CrudAdminFrontDir(adminRoot string, b *CrudBundle) string {
	return filepath.Join(adminRoot, "src", "modules", b.PackageLower, "views", b.APITSBase)
}

// CrudAdminAPIDir admin 前端 api 路径。
func CrudAdminAPIPath(adminRoot string, b *CrudBundle) string {
	return filepath.Join(adminRoot, "src", "modules", b.PackageLower, "api", b.APITSBase+".ts")
}

// CrudPluginWebDir 插件 web 目录根。
func CrudPluginWebDir(root string, b *CrudBundle) string {
	return tools.RootJoin(root, "plugin", filepath.FromSlash(b.PluginPath), "web")
}
