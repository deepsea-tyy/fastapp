package tools

import (
	"os"
	"path"
	"path/filepath"

	"fastapp/internal/config"
)

// Module 为 go.mod 的 module 路径，修改仓库 module 时请同步更新此处与 go.mod。
const Module = "fastapp"

// ImportPath 返回本 module 下的 Go import 路径，例如 ImportPath("internal", "app", "model")。
func ImportPath(elem ...string) string {
	if len(elem) == 0 {
		return Module
	}
	return path.Join(append([]string{Module}, elem...)...)
}

// EnvServerGoRoot 环境变量名：工程根目录（含 go.mod）。
const EnvServerGoRoot = "SERVER_GO_ROOT"

const monorepoServerGoSubdir = "server_go"

// ResolveServerGoRoot 从 EnvServerGoRoot 或当前工作目录得到工程根路径（已 Clean）。
func ResolveServerGoRoot() (string, error) {
	if r := os.Getenv(EnvServerGoRoot); r != "" {
		return filepath.Clean(r), nil
	}
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}
	return filepath.Clean(wd), nil
}

// LoadDotEnvForServerRoot 加载 .env：优先 root/.env，否则 root/server_go/.env；不覆盖已存在环境变量。
func LoadDotEnvForServerRoot(root string) error {
	root = filepath.Clean(root)
	primary := filepath.Join(root, ".env")
	if _, err := os.Stat(primary); err == nil {
		return config.LoadDotEnv(primary)
	}
	return config.LoadDotEnv(filepath.Join(root, monorepoServerGoSubdir, ".env"))
}

// RootJoin 在工程根目录下拼接路径（会先 Clean root）。
func RootJoin(serverGoRoot string, elem ...string) string {
	base := filepath.Clean(serverGoRoot)
	if len(elem) == 0 {
		return base
	}
	return filepath.Join(append([]string{base}, elem...)...)
}

// StorageUploadsDir 本地附件根：{root}/storage/uploads。
func StorageUploadsDir(serverGoRoot string) string {
	return RootJoin(serverGoRoot, "storage", "uploads")
}

// StorageLocalesDir 核心 i18n JSON 目录：{root}/storage/locales。
func StorageLocalesDir(serverGoRoot string) string {
	return RootJoin(serverGoRoot, "storage", "locales")
}

// StorageAppPageContentDir 由 uploads 目录推导 CMS 页面 JSON 目录（.../storage/app/page-content）。
func StorageAppPageContentDir(uploadsDir string) string {
	return filepath.Join(filepath.Dir(filepath.Clean(uploadsDir)), "app", "page-content")
}

// PageContentJSONWebRel 页面 JSON 站点内相对路径（正斜杠）。
func PageContentJSONWebRel(suffix string) string {
	return filepath.ToSlash(filepath.Join("storage", "app", "page-content", "page-content-"+suffix+".json"))
}

// SiblingAdminDir 与工程根同级的 admin 前端目录（monorepo 布局）。
func SiblingAdminDir(serverGoRoot string) string {
	return filepath.Clean(filepath.Join(filepath.Clean(serverGoRoot), "..", "admin"))
}

// PluginRoot {root}/plugin
func PluginRoot(serverGoRoot string) string {
	return RootJoin(serverGoRoot, "plugin")
}

// PluginPath {root}/plugin/<parts...>
func PluginPath(serverGoRoot string, parts ...string) string {
	return filepath.Join(append([]string{PluginRoot(serverGoRoot)}, parts...)...)
}
