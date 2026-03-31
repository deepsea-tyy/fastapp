package gen

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	tools "fastapp/internal/app/common"
)

var (
	reImportLine = regexp.MustCompile(`^([A-Za-z_][A-Za-z0-9_]*)\s+"(.+)"\s*$`)
	reRegHTTP    = regexp.MustCompile(`RegisterHTTPEndpoints\s*\(\s*([A-Za-z_][A-Za-z0-9_]*)\.PluginName\s*,\s*([A-Za-z_][A-Za-z0-9_]*)\.Endpoints\s*\)`)
)

// AppendPluginHostHTTPEndpointRegistration 在 server_go 根下的 plugin/plugin.go 中确保存在
// 指向该插件的 import 与 RegisterHTTPEndpoints(<config 包>.PluginName, <src/http 包>.Endpoints)。
// 若已登记同一对路径则跳过。
func AppendPluginHostHTTPEndpointRegistration(root, pluginPath, modulePath, rootPkg, httpPkg string, out io.Writer) error {
	pluginPath = filepath.ToSlash(strings.TrimSpace(pluginPath))
	if pluginPath == "" {
		return fmt.Errorf("插件路径为空")
	}
	if rootPkg == "" {
		return fmt.Errorf("未解析到插件根 config.go 的 package 名")
	}
	if httpPkg == "" {
		return fmt.Errorf("未解析到 src/http 的 package 名")
	}

	hostPath := tools.RootJoin(root, "plugin", "plugin.go")
	raw, err := os.ReadFile(hostPath)
	if err != nil {
		return fmt.Errorf("读取宿主 %s: %w", hostPath, err)
	}

	rootImp := modulePath + "/plugin/" + pluginPath
	httpImp := rootImp + "/src/http"
	text := string(raw)

	aliasByPath := parseAliasedImports(text)
	pathByAlias := invertPathAlias(aliasByPath)
	if err := conflictingPluginHTTPRegistration(text, pathByAlias, rootImp, httpImp, pluginPath); err != nil {
		return err
	}
	ar := aliasByPath[rootImp]
	ah := aliasByPath[httpImp]
	if registrationExists(text, ar, ah, rootImp, httpImp) {
		fmt.Fprintf(out, "提示: plugin/plugin.go 已登记 %s 的 HTTP Endpoints，跳过\n", pluginPath)
		return nil
	}

	used := collectImportAliases(text)
	var importLines []string
	if ar == "" {
		ar = uniqueAlias(rootPkg, used)
		importLines = append(importLines, fmt.Sprintf("\t%s %q", ar, rootImp))
	}
	if ah == "" {
		ah = uniqueAlias(httpPkg, used)
		if ah == ar {
			ah = uniqueAlias(httpPkg+"HTTP", used)
		}
		importLines = append(importLines, fmt.Sprintf("\t%s %q", ah, httpImp))
	} else if ar != "" && ah == ar {
		// 的路径已从文件解析出同别名（不应发生）；强制新 http 别名
		ah = uniqueAlias(httpPkg+"HTTP", used)
		importLines = append(importLines, fmt.Sprintf("\t%s %q", ah, httpImp))
	}

	regLine := fmt.Sprintf("\tRegisterHTTPEndpoints(%s.PluginName, %s.Endpoints)", ar, ah)

	outLines, err := insertImportsAndInitRegistration(strings.Split(text, "\n"), importLines, regLine)
	if err != nil {
		return err
	}
	newText := strings.Join(outLines, "\n")
	if err := os.WriteFile(hostPath, []byte(newText), 0o644); err != nil {
		return fmt.Errorf("写入 %s: %w", hostPath, err)
	}
	fmt.Fprintf(out, "已登记插件 HTTP 至 plugin/plugin.go: %s\n", pluginPath)
	return nil
}

func invertPathAlias(aliasByPath map[string]string) map[string]string {
	out := make(map[string]string, len(aliasByPath))
	for p, a := range aliasByPath {
		out[a] = p
	}
	return out
}

// conflictingPluginHTTPRegistration 若已为 rootImp 登记过 RegisterHTTPEndpoints，但第二项不是 httpImp，则报错。
func conflictingPluginHTTPRegistration(text string, pathByAlias map[string]string, rootImp, httpImp, pluginPath string) error {
	for _, m := range reRegHTTP.FindAllStringSubmatch(text, -1) {
		if len(m) < 3 {
			continue
		}
		aRoot, aHTTP := m[1], m[2]
		if pathByAlias[aRoot] != rootImp {
			continue
		}
		if pathByAlias[aHTTP] == httpImp {
			return nil
		}
		return fmt.Errorf("plugin/plugin.go 已为 %s 登记 RegisterHTTPEndpoints，但 Endpoints 的 import 为 %q（期望 %q），请手动修正",
			pluginPath, pathByAlias[aHTTP], httpImp)
	}
	return nil
}

func registrationExists(text, ar, ah, rootImp, httpImp string) bool {
	if ar == "" || ah == "" {
		return false
	}
	rootImpQuoted := `"` + rootImp + `"`
	httpImpQuoted := `"` + httpImp + `"`
	if !strings.Contains(text, rootImpQuoted) || !strings.Contains(text, httpImpQuoted) {
		return false
	}
	for _, m := range reRegHTTP.FindAllStringSubmatch(text, -1) {
		if len(m) >= 3 && m[1] == ar && m[2] == ah {
			return true
		}
	}
	return false
}

func parseAliasedImports(text string) map[string]string {
	out := map[string]string{}
	start := strings.Index(text, "import (")
	if start < 0 {
		return out
	}
	rest := text[start+len("import ("):]
	end := strings.Index(rest, "\n)")
	if end < 0 {
		return out
	}
	block := rest[:end]
	for _, ln := range strings.Split(block, "\n") {
		ln = strings.TrimSpace(ln)
		if ln == "" || strings.HasPrefix(ln, "//") {
			continue
		}
		if m := reImportLine.FindStringSubmatch(ln); len(m) == 3 {
			out[m[2]] = m[1]
		}
	}
	return out
}

func collectImportAliases(text string) map[string]bool {
	used := map[string]bool{}
	start := strings.Index(text, "import (")
	if start < 0 {
		return used
	}
	rest := text[start+len("import ("):]
	end := strings.Index(rest, "\n)")
	if end < 0 {
		return used
	}
	block := rest[:end]
	for _, ln := range strings.Split(block, "\n") {
		ln = strings.TrimSpace(ln)
		if m := reImportLine.FindStringSubmatch(ln); len(m) == 3 {
			used[m[1]] = true
		}
	}
	return used
}

func uniqueAlias(base string, used map[string]bool) string {
	s := base
	if !used[s] {
		used[s] = true
		return s
	}
	for i := 2; i < 1000; i++ {
		cand := fmt.Sprintf("%s%d", base, i)
		if !used[cand] {
			used[cand] = true
			return cand
		}
	}
	return base + "X"
}

func insertImportsAndInitRegistration(lines []string, importLines []string, registerLine string) ([]string, error) {
	out := append([]string(nil), lines...)

	importClose := -1
	inImport := false
	for i, ln := range out {
		t := strings.TrimSpace(ln)
		if t == "import (" {
			inImport = true
			continue
		}
		if inImport && t == ")" {
			importClose = i
			break
		}
	}
	if importClose < 0 {
		return nil, fmt.Errorf("无法在 plugin/plugin.go 中定位 import 块结束")
	}
	if len(importLines) > 0 {
		before := out[:importClose]
		after := out[importClose:]
		out = append(append(append([]string{}, before...), importLines...), after...)
	}

	initLine := -1
	for i, ln := range out {
		if strings.HasPrefix(strings.TrimSpace(ln), "func init()") {
			initLine = i
			break
		}
	}
	if initLine < 0 {
		return nil, fmt.Errorf("plugin/plugin.go 中无 func init()")
	}
	brace := 0
	started := false
	insertAt := -1
	for j := initLine; j < len(out); j++ {
		ln := out[j]
		for _, ch := range ln {
			if ch == '{' {
				brace++
				started = true
			} else if ch == '}' {
				brace--
			}
		}
		if started && brace == 0 {
			insertAt = j
			break
		}
	}
	if insertAt < 0 {
		return nil, fmt.Errorf("无法定位 init 结束")
	}
	marker := "\t// gen crud: plugin HTTP registration"
	newOut := make([]string, 0, len(out)+3)
	newOut = append(newOut, out[:insertAt]...)
	newOut = append(newOut, marker, registerLine)
	newOut = append(newOut, out[insertAt:]...)
	return newOut, nil
}

// ReadPluginRootPackage 读取 plugin/<path>/config.go 的 package 名。
func ReadPluginRootPackage(root, pluginPath string) (string, error) {
	p := tools.RootJoin(root, "plugin", filepath.FromSlash(pluginPath), "config.go")
	b, err := os.ReadFile(p)
	if err != nil {
		return "", fmt.Errorf("读取 %s: %w", p, err)
	}
	pkg := goPackageFromSource(string(b))
	if pkg == "" {
		return "", fmt.Errorf("%s 中无 package 声明", p)
	}
	return pkg, nil
}
