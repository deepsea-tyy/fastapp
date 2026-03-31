package gen

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"
)

// AppendCrudEndpointsTail 在核心 endpoints.go 或插件 routes.go 的 return []…切片末尾（倒数第一个 \t} 之前）追加本批 CRUD 四条路由。
// SkipGo 时不处理；若 GET …/list 的 Path 已存在则跳过并写提示。
func AppendCrudEndpointsTail(root string, b *CrudBundle, out io.Writer) error {
	if b.Opts.SkipGo {
		return nil
	}

	var target string
	var block []string
	if b.IsPlugin {
		target = tools.RootJoin(root, "plugin", filepath.FromSlash(b.PluginPath), "src", "http", "routes.go")
		block = crudPluginEndpointBlock(b)
	} else {
		target = tools.RootJoin(root, "internal", "app", "router", "endpoints.go")
		block = crudCoreEndpointBlock(b)
	}

	raw, err := os.ReadFile(target)
	if err != nil {
		if os.IsNotExist(err) {
			if b.IsPlugin {
				return writeNewPluginRoutesGo(target, b, out)
			}
			return fmt.Errorf("未找到路由文件: %s", target)
		}
		return fmt.Errorf("读取路由文件: %w", err)
	}
	s := string(raw)
	listPath := b.HTTPPrefix + "/list"
	if strings.Contains(s, `Path: "`+listPath+`"`) {
		fmt.Fprintf(out, "提示: 路由 Path=%q 已存在，跳过追加 %s\n", listPath, target)
		return nil
	}

	lines := strings.Split(s, "\n")
	insertAt := -1
	for i := len(lines) - 2; i >= 0; i-- {
		a := strings.TrimRight(lines[i], "\r")
		bn := strings.TrimRight(lines[i+1], "\r")
		if a == "\t}" && bn == "}" {
			insertAt = i
			break
		}
	}
	if insertAt < 0 {
		return fmt.Errorf("无法在 %s 中定位 return 切片末尾（期望倒数两行依次为「\\t}」「}」）", target)
	}

	marker := fmt.Sprintf("\t\t// gen crud: %s", b.Opts.Table)
	if b.IsPlugin {
		marker += " (" + b.PluginPath + ")"
	} else if m := strings.TrimSpace(b.Opts.Module); m != "" {
		marker += " (module=" + m + ")"
	}

	outLines := make([]string, 0, len(lines)+len(block)+2)
	outLines = append(outLines, lines[:insertAt]...)
	outLines = append(outLines, marker)
	outLines = append(outLines, block...)
	outLines = append(outLines, lines[insertAt:]...)

	if err := os.WriteFile(target, []byte(strings.Join(outLines, "\n")), 0o644); err != nil {
		return fmt.Errorf("写入路由文件: %w", err)
	}
	fmt.Fprintf(out, "已追加路由至 %s\n", target)
	return nil
}

func crudCoreEndpointBlock(b *CrudBundle) []string {
	p := b.PermPrefix
	h := b.HTTPPrefix
	sn := b.StructName
	row := "\t\t{Method: %q, Path: %q, Auth: KindAdminJWT, MenuPerm: %q, Handler: admin.%s},"
	return []string{
		fmt.Sprintf(row, "GET", h+"/list", p+":list", sn+"List"),
		fmt.Sprintf(row, "POST", h+"/create", p+":create", sn+"Create"),
		fmt.Sprintf(row, "PUT", h+"/save/:id", p+":save", sn+"Save"),
		fmt.Sprintf(row, "DELETE", h+"/delete", p+":delete", sn+"Delete"),
	}
}

func crudPluginEndpointBlock(b *CrudBundle) []string {
	hb := b.handlerPluginBase()
	p := b.PermPrefix
	h := b.HTTPPrefix
	row := "\t\t{Method: %q, Path: %q, Auth: router.KindAdminJWT, MenuPerm: %q, Handler: ep(%s)},"
	return []string{
		fmt.Sprintf(row, "GET", h+"/list", p+":list", hb+"List"),
		fmt.Sprintf(row, "POST", h+"/create", p+":create", hb+"Create"),
		fmt.Sprintf(row, "PUT", h+"/save/:id", p+":save", hb+"Save"),
		fmt.Sprintf(row, "DELETE", h+"/delete", p+":delete", hb+"Delete"),
	}
}

func writeNewPluginRoutesGo(path string, b *CrudBundle, out io.Writer) error {
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	pkg := b.HandlerPackage
	block := crudPluginEndpointBlock(b)
	marker := fmt.Sprintf("\t\t// gen crud: %s (%s)", b.Opts.Table, b.PluginPath)
	inner := marker + "\n" + strings.Join(block, "\n")
	body := fmt.Sprintf(`package %s

import (
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/router"

	"github.com/gin-gonic/gin"
)

func ep(fn func(*deps.HandlerCtx)) func(*deps.Deps) gin.HandlerFunc {
	return func(d *deps.Deps) gin.HandlerFunc { return deps.Bind(d, fn) }
}

// Endpoints 插件 HTTP（gen crud 自动创建或向末尾追加）。
func Endpoints() []router.Endpoint {
	return []router.Endpoint{
%s
	}
}
`, pkg, inner)

	if err := os.WriteFile(path, []byte(body), 0o644); err != nil {
		return fmt.Errorf("写入路由文件: %w", err)
	}
	fmt.Fprintf(out, "已创建路由文件 %s\n", path)
	return nil
}
