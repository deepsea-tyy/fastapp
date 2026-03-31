package gen

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"
	"gorm.io/gorm"
)

func crudPluginArtifactStem(b *CrudBundle) string {
	p := strings.TrimSpace(b.PluginPath)
	if p == "" {
		return ""
	}
	return strings.ReplaceAll(filepath.ToSlash(p), "/", "_") + "_" + strings.ReplaceAll(b.Opts.Table, "/", "_")
}

func crudEndpointsSnippetBase(b *CrudBundle) string {
	if b.IsPlugin {
		if s := crudPluginArtifactStem(b); s != "" {
			return s
		}
	}
	return strings.ReplaceAll(b.Opts.Table, "/", "_")
}

func crudMenuSQLBase(b *CrudBundle) string {
	if b.IsPlugin {
		if s := crudPluginArtifactStem(b); s != "" {
			return s
		}
	}
	return b.StructName
}

// WriteCrudArtifacts 写出 Go、前端片段、SQL、路由提示。
func WriteCrudArtifacts(db *gorm.DB, b *CrudBundle, root, templatesDir, adminRoot string, out io.Writer) error {
	snippetDir := tools.RootJoin(root, "gen", "crud", "snippets")
	if err := os.MkdirAll(snippetDir, 0o755); err != nil {
		return err
	}
	snp := filepath.Join(snippetDir, crudEndpointsSnippetBase(b)+"_endpoints.txt")
	var snip strings.Builder
	if err := WriteEndpointsSnippet(&snip, b); err != nil {
		return err
	}
	if err := writeFileIf(snp, []byte(snip.String()), b.Opts.Force); err != nil {
		return err
	}
	fmt.Fprintf(out, "已写入路由片段 %s\n", snp)

	sqlDir := tools.RootJoin(root, "gen", "crud", "sql")
	if err := os.MkdirAll(sqlDir, 0o755); err != nil {
		return err
	}
	sqlPath := filepath.Join(sqlDir, crudMenuSQLBase(b)+"_menu.sql")
	sqlB, err := RenderCRUDTemplate(templatesDir, "menu.sql.tmpl", b)
	if err != nil {
		return err
	}
	if err := writeFileIf(sqlPath, sqlB, b.Opts.Force); err != nil {
		return err
	}
	fmt.Fprintf(out, "已写入菜单 SQL %s\n", sqlPath)

	if !b.Opts.SkipGo {
		goPath := CrudGoOutputPath(root, b)
		var buf strings.Builder
		if err := WriteCrudGoHandlers(&buf, b); err != nil {
			return err
		}
		if err := writeFileIf(goPath, []byte(buf.String()), b.Opts.Force); err != nil {
			return err
		}
		fmt.Fprintf(out, "已写入 Go handler %s\n", goPath)
	}

	if !b.Opts.SkipFront {
		if b.IsPlugin {
			web := CrudPluginWebDir(root, b)
			sub := filepath.Join(web, "views", b.APITSBase)
			if err := writeFrontTmplSet(templatesDir, sub, b); err != nil {
				return err
			}
			api := filepath.Join(web, "api", b.APITSBase+".ts")
			if err := writeOneTmpl(templatesDir, "api.ts.tmpl", api, b, b.Opts.Force); err != nil {
				return err
			}
			fmt.Fprintf(out, "已写入插件前端：\n")
			fmt.Fprintf(out, "  • 页面: %s/index.vue、form.vue、data/*.tsx\n", sub)
			fmt.Fprintf(out, "  • API:  %s\n", api)
		} else {
			sub := CrudAdminFrontDir(adminRoot, b)
			if err := writeFrontTmplSet(templatesDir, sub, b); err != nil {
				return err
			}
			api := CrudAdminAPIPath(adminRoot, b)
			if err := writeOneTmpl(templatesDir, "api.ts.tmpl", api, b, b.Opts.Force); err != nil {
				return err
			}
			fmt.Fprintf(out, "已写入 admin 前端（adminRoot=%s）：\n", adminRoot)
			fmt.Fprintf(out, "  • 页面: %s/index.vue、form.vue、data/getFormItems.tsx、getTableColumns.tsx、getSearchItems.tsx\n", sub)
			fmt.Fprintf(out, "  • API:  %s\n", api)
		}
	}

	if err := AppendCrudEndpointsTail(root, b, out); err != nil {
		return err
	}

	if b.IsPlugin && !b.Opts.SkipGo {
		modPath, err := ReadModulePath(root)
		if err != nil {
			return fmt.Errorf("读取 go module: %w", err)
		}
		httpDir := tools.RootJoin(root, "plugin", filepath.FromSlash(b.PluginPath), "src", "http")
		httpPkg := readHTTPGoPackage(httpDir)
		rootPkg, err := ReadPluginRootPackage(root, b.PluginPath)
		if err != nil {
			return fmt.Errorf("插件宿主登记: %w", err)
		}
		if err := AppendPluginHostHTTPEndpointRegistration(root, b.PluginPath, modPath, rootPkg, httpPkg, out); err != nil {
			return err
		}
	}

	if b.Opts.RunMenuSQL && db != nil {
		body, err := os.ReadFile(sqlPath)
		if err != nil {
			return err
		}
		stmts := SplitSQLStatements(string(body))
		if err := execStmts(db, stmts); err != nil {
			return fmt.Errorf("执行菜单 SQL: %w", err)
		}
		fmt.Fprintf(out, "已执行菜单 SQL: %s\n", sqlPath)
	}
	return nil
}

func writeFrontTmplSet(templatesDir, viewDir string, b *CrudBundle) error {
	if err := os.MkdirAll(filepath.Join(viewDir, "data"), 0o755); err != nil {
		return err
	}
	m := map[string]string{
		"index.vue.tmpl":           "index.vue",
		"form.vue.tmpl":            "form.vue",
		"getFormItems.tsx.tmpl":    filepath.Join("data", "getFormItems.tsx"),
		"getTableColumns.tsx.tmpl": filepath.Join("data", "getTableColumns.tsx"),
		"getSearchItems.tsx.tmpl":  filepath.Join("data", "getSearchItems.tsx"),
	}
	for tmpl, name := range m {
		path := filepath.Join(viewDir, name)
		if err := writeOneTmpl(templatesDir, tmpl, path, b, b.Opts.Force); err != nil {
			return err
		}
	}
	return nil
}

func writeOneTmpl(templatesDir, tmplFile, outPath string, b *CrudBundle, force bool) error {
	bb, err := RenderCRUDTemplate(templatesDir, tmplFile, b)
	if err != nil {
		return err
	}
	return writeFileIf(outPath, bb, force)
}

func writeFileIf(path string, data []byte, force bool) error {
	if _, err := os.Stat(path); err == nil && !force {
		return fmt.Errorf("文件已存在: %s（使用 --force）", path)
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}
	return os.WriteFile(path, data, 0o644)
}

func execStmts(db *gorm.DB, stmts []string) error {
	for _, s := range stmts {
		s = strings.TrimSpace(s)
		if s == "" {
			continue
		}
		if err := db.Exec(s).Error; err != nil {
			return err
		}
	}
	return nil
}
