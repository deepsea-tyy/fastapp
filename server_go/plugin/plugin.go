package plugin

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/i18n"
	"fastapp/internal/app/router"
	"fastapp/internal/websocket"

	syscms "fastapp/plugin/ds/sysCms"
	scmhttp "fastapp/plugin/ds/sysCms/src/http"
	sysconfig "fastapp/plugin/ds/sysConfig"
	scfghttp "fastapp/plugin/ds/sysConfig/src/http"
	syskefu "fastapp/plugin/ds/sysKefu"
	skfuhttp "fastapp/plugin/ds/sysKefu/src/http"
	kefuws "fastapp/plugin/ds/sysKefu/src/websocket"
	sysnotify "fastapp/plugin/ds/sysNotify"
	snfyhttp "fastapp/plugin/ds/sysNotify/src/http"
)

func init() {
	// 依赖方向仅此一处：fastapp/plugin → 插件根（元数据）与 src/*（实现）。插件树内禁止 import fastapp/plugin。
	RegisterHTTPEndpoints(syscms.PluginName, scmhttp.Endpoints)
	RegisterHTTPEndpoints(sysconfig.PluginName, scfghttp.Endpoints)
	RegisterHTTPEndpoints(syskefu.PluginName, skfuhttp.Endpoints)
	RegisterWebSocket(syskefu.PluginName, kefuws.RegisterWebSocket)
	RegisterHTTPEndpoints(sysnotify.PluginName, snfyhttp.Endpoints)
}

const installLockFile = "install.lock"

// RootConfigFileName 插件根目录元数据文件名（LoadInstalled / LoadPluginI18n / CLI 一致）。
const RootConfigFileName = "config.go"

// Info 已加载插件
type Info struct {
	Name string // 与目录一致，如 ds/sysConfig（组织/插件）
	Root string // 绝对路径：.../plugin/ds/sysConfig
}

// ValidateOrgPluginPath 仅允许「组织/插件」两级相对路径（相对于 plugin/），段内为常见标识字符
func ValidateOrgPluginPath(rel string) error {
	rel = strings.Trim(rel, `/\`)
	rel = filepath.ToSlash(rel)
	parts := strings.Split(rel, "/")
	if len(parts) != 2 {
		return fmt.Errorf("插件路径必须为 组织/插件 两级，例如 ds/sysConfig，当前: %q", rel)
	}
	for _, p := range parts {
		if p == "" {
			return fmt.Errorf("插件路径段不能为空: %q", rel)
		}
		for _, r := range p {
			if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '_' || r == '-' {
				continue
			}
			return fmt.Errorf("插件路径段仅允许字母、数字、_、-: %q", rel)
		}
	}
	return nil
}

// LoadInstalled 扫描 base/plugin/{org}/{name}/：存在 install.lock 且根目录含 config.go 时加载；插件名由目录路径推导。仅识别两级目录。
func LoadInstalled(base string) ([]Info, error) {
	pluginRoot := tools.PluginRoot(base)
	st, err := os.Stat(pluginRoot)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, nil
		}
		return nil, err
	}
	if !st.IsDir() {
		return nil, fmt.Errorf("plugin root not a directory: %s", pluginRoot)
	}

	orgEntries, err := os.ReadDir(pluginRoot)
	if err != nil {
		return nil, err
	}

	var out []Info
	for _, orgEnt := range orgEntries {
		if !orgEnt.IsDir() {
			continue
		}
		orgName := orgEnt.Name()
		orgPath := filepath.Join(pluginRoot, orgName)
		plugEntries, err := os.ReadDir(orgPath)
		if err != nil {
			return nil, err
		}
		for _, plugEnt := range plugEntries {
			if !plugEnt.IsDir() {
				continue
			}
			plugName := plugEnt.Name()
			dir := filepath.Join(orgPath, plugName)
			if !hasInstallLock(dir) {
				continue
			}
			if _, err := os.Stat(filepath.Join(dir, RootConfigFileName)); err != nil {
				continue
			}
			rel := filepath.ToSlash(filepath.Join(orgName, plugName))
			if err := ValidateOrgPluginPath(rel); err != nil {
				return nil, fmt.Errorf("%s: %w", dir, err)
			}
			if err := validatePluginRootFiles(dir); err != nil {
				return nil, fmt.Errorf("plugin %s: %w", rel, err)
			}
			out = append(out, Info{Name: rel, Root: dir})
		}
	}
	return out, nil
}

func validatePluginRootFiles(dir string) error {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return err
	}
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		name := e.Name()
		if name == RootConfigFileName || name == installLockFile {
			continue
		}
		if name == "publish.json" {
			continue
		}
		if strings.EqualFold(name, "readme.md") {
			continue
		}
		return fmt.Errorf("根目录仅允许文件 %q、%q、publish.json（可选）与 readme.md（可选），禁止根级文件 %q", RootConfigFileName, installLockFile, name)
	}
	return nil
}

func hasInstallLock(dir string) bool {
	st, err := os.Stat(filepath.Join(dir, installLockFile))
	return err == nil && !st.IsDir()
}

// PluginLocaleKeyPrefix 将插件名（如 ds/sysKefu）转为 Merge 用的键前缀（ds.sysKefu.）。
func PluginLocaleKeyPrefix(pluginName string) string {
	s := strings.TrimSpace(filepath.ToSlash(pluginName))
	return strings.ReplaceAll(s, "/", ".") + "."
}

// LoadPluginI18n 扫描 plugin/{org}/{name}/：路径合法且存在 config.go 则检查 src/locales；与 install.lock 无关。
func LoadPluginI18n(serverGoRoot string) error {
	pluginRoot := tools.PluginRoot(serverGoRoot)
	st, err := os.Stat(pluginRoot)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	if !st.IsDir() {
		return fmt.Errorf("plugin root not a directory: %s", pluginRoot)
	}

	orgEntries, err := os.ReadDir(pluginRoot)
	if err != nil {
		return err
	}

	for _, orgEnt := range orgEntries {
		if !orgEnt.IsDir() {
			continue
		}
		orgPath := filepath.Join(pluginRoot, orgEnt.Name())
		plugEntries, err := os.ReadDir(orgPath)
		if err != nil {
			return err
		}
		for _, plugEnt := range plugEntries {
			if !plugEnt.IsDir() {
				continue
			}
			dir := filepath.Join(orgPath, plugEnt.Name())
			if _, err := os.Stat(filepath.Join(dir, RootConfigFileName)); err != nil {
				continue
			}
			rel := filepath.ToSlash(filepath.Join(orgEnt.Name(), plugEnt.Name()))
			if err := ValidateOrgPluginPath(rel); err != nil {
				continue
			}
			if err := mergePluginLocaleFiles(rel, dir); err != nil {
				return err
			}
		}
	}
	return nil
}

func mergePluginLocaleFiles(pluginName, pluginRootDir string) error {
	locDir := filepath.Join(pluginRootDir, "src", "locales")
	st, err := os.Stat(locDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}
	if !st.IsDir() {
		return nil
	}

	prefix := PluginLocaleKeyPrefix(pluginName)
	for _, pair := range []struct {
		locale string
		file   string
	}{
		{"en", "en.json"},
		{"zh_CN", "zh_CN.json"},
	} {
		path := filepath.Join(locDir, pair.file)
		b, err := os.ReadFile(path)
		if err != nil {
			if os.IsNotExist(err) {
				continue
			}
			return fmt.Errorf("%s: %w", path, err)
		}
		var raw map[string]string
		if err := json.Unmarshal(b, &raw); err != nil {
			return fmt.Errorf("%s: %w", path, err)
		}
		if len(raw) == 0 {
			continue
		}
		out := make(map[string]string, len(raw))
		for k, v := range raw {
			out[prefix+k] = v
		}
		i18n.Merge(pair.locale, out)
	}
	return nil
}

// HTTPEndpoints 根据已安装插件合并路由表（与 router.Endpoints 结构一致）。
func HTTPEndpoints(loaded []Info) []router.Endpoint {
	names := make([]string, len(loaded))
	for i, p := range loaded {
		names[i] = p.Name
	}
	return mergeHTTPEndpoints(names)
}

// BindingWS 按 LoadInstalled 返回顺序构建 WebSocket ActionRegistry。
func BindingWS(loaded []Info) *websocket.ActionRegistry {
	names := make([]string, len(loaded))
	for i, p := range loaded {
		names[i] = p.Name
	}
	return buildBindingWS(names)
}
