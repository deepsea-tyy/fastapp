package gen

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/model"
	"fastapp/internal/config"

	"gorm.io/gorm"
)

// BuildCrudBundle 聚合表元数据、字段与输出路径。
func BuildCrudBundle(db *gorm.DB, cfg config.Config, opts CrudOptions, root string) (*CrudBundle, error) {
	if strings.TrimSpace(opts.Table) == "" {
		return nil, fmt.Errorf("--table 必填")
	}
	if strings.TrimSpace(opts.Plugin) == "" && strings.TrimSpace(opts.Module) == "" {
		return nil, fmt.Errorf("请指定 --module（核心 admin 模块名）或 --plugin（如 ds/sysCms）")
	}

	pk, err := PrimaryKeyColumn(db, cfg, opts.Table)
	if err != nil {
		return nil, err
	}
	cols, err := ListColumnMeta(db, cfg, opts.Table)
	if err != nil {
		return nil, err
	}
	if len(cols) == 0 {
		return nil, fmt.Errorf("表无列: %s%s", model.P, opts.Table)
	}
	modulePath, err := ReadModulePath(root)
	if err != nil {
		return nil, err
	}
	tcomment, err := TableComment(db, cfg, opts.Table)
	if err != nil {
		return nil, err
	}

	singular := SingularizeTableName(opts.Table)
	structName := StructNameFromTable(opts.Table)
	camel := CamelFromSnake(singular)
	pascal := structName

	moduleSeg := ModuleURLSegment(opts.Module)
	pkgLower := strings.ToLower(strings.TrimSpace(opts.Module))
	if opts.Plugin != "" {
		pkgLower = ""
	}

	resource := ResourceURLSeg(moduleSeg, opts.Table, structName)
	isPlugin := strings.TrimSpace(opts.Plugin) != ""
	pluginPath := NormalizePluginPath(opts.Plugin)

	var httpPrefix, permPrefix, modelImport, handlerPkg, modelAlias string
	var permSnake string
	apits := APITSFileBase(resource)
	tsvo := TSVoNameFromResource(resource)

	if isPlugin {
		pl := strings.ToLower(pluginPath)
		httpPrefix = "/admin/" + pl + "/" + SnakeFromPascal(structName)
		pb := PluginPermColonBase(pluginPath)
		permSnake = SnakeFromPascal(structName)
		permPrefix = pb + ":" + permSnake
		modelImport = JoinImport(modulePath, "plugin/"+pluginPath+"/src/model")
		handlerPkg = readHTTPGoPackage(tools.RootJoin(root, "plugin", filepath.FromSlash(pluginPath), "src", "http"))
		if handlerPkg == "" {
			handlerPkg = "pluginhttp"
		}
		modelAlias = strings.TrimSpace(opts.ModelAlias)
		if modelAlias == "" {
			modelAlias = "plugmodel"
		}
	} else {
		httpPrefix = "/admin/" + moduleSeg + "/" + resource
		permPrefix = moduleSeg + ":" + resource
		permSnake = SnakeFromPascal(structName)
		modelImport = JoinImport(modulePath, "internal/app/model")
		handlerPkg = "admin"
		modelAlias = "model"
	}

	if strings.TrimSpace(opts.HTTPPrefix) != "" {
		httpPrefix = strings.TrimSpace(opts.HTTPPrefix)
	}

	hasDel := false
	hasCB, hasUB := false, false
	for _, c := range cols {
		if c.Name == "deleted_at" {
			hasDel = true
		}
		if c.Name == "created_by" {
			hasCB = true
		}
		if c.Name == "updated_by" {
			hasUB = true
		}
	}

	tableInfo := TableInfoCrud{
		PID:        opts.PID,
		Name:       opts.Table,
		Comment:    tcomment,
		CamelCase:  camel,
		PascalCase: pascal,
		PrimaryKey: pk,
	}

	mod := strings.TrimSpace(opts.Module)
	if mod == "" && isPlugin {
		parts := strings.Split(pluginPath, "/")
		mod = parts[len(parts)-1]
	}
	if mod == "" {
		mod = "app"
	}

	form := BuildCrudFormFields(mod, tableInfo, cols)
	tblf := TableFieldsFiltered(form)
	qf := BuildQueryFields(form)
	bf := BuildBodyFields(form)

	b := &CrudBundle{
		Opts:           opts,
		ModulePath:     modulePath,
		StructName:     structName,
		TableSingular:  singular,
		CamelName:      camel,
		ResourceSeg:    resource,
		ModuleSeg:      moduleSeg,
		PackageLower:   pkgLower,
		HTTPPrefix:     httpPrefix,
		PermPrefix:     permPrefix,
		PermSnake:      permSnake,
		APITSBase:      apits,
		TSVoName:       tsvo,
		PrimaryKey:     pk,
		PrimaryKeyGo:   ExportedField(pk),
		HasDeletedAt:   hasDel,
		FormFields:     form,
		TableFields:    tblf,
		QueryFields:    qf,
		BodyFields:     bf,
		IsPlugin:       isPlugin,
		ModelImport:    modelImport,
		HandlerPackage: handlerPkg,
		ModelPkgAlias:  modelAlias,
		SkipForm:       CrudSkipFormFields,
		TableFl:        CrudSkipTableFields,
		TransFl:        CrudTransFields,
		MenuName:       strings.ReplaceAll(tcomment, "表", ""),
		DBPrefix:       cfg.DBPrefix,
		NowSQL:         NowSQLDefault(),
		PluginPath:     pluginPath,
		HasCreatedBy:   hasCB,
		HasUpdatedBy:   hasUB,
	}
	if b.MenuName == "" {
		b.MenuName = structName
	}
	b.TSVoFields = BuildTSVoFields(cols)

	ml := strings.ToLower(strings.TrimSpace(opts.Module))
	if isPlugin {
		parts := strings.Split(pluginPath, "/")
		ml = strings.ToLower(parts[len(parts)-1])
	}
	if ml == "" {
		ml = "app"
	}
	b.PackageLower = ml
	if isPlugin {
		b.DefineOptionsName = PluginPermColonBase(pluginPath) + ":" + b.PermSnake
		b.APIImportPath = "$/" + pluginPath + "/api/" + b.APITSBase + ".ts"
	} else {
		b.DefineOptionsName = ml + ":" + resource
		b.APIImportPath = "~/" + ml + "/api/" + b.APITSBase + ".ts"
	}
	b.MenuMetaJSON = buildMenuMetaJSON(b)
	b.MenuMetaSQL = strings.ReplaceAll(b.MenuMetaJSON, "'", "''")
	return b, nil
}

func buildMenuMetaJSON(b *CrudBundle) string {
	cp := "modules/"
	if b.IsPlugin {
		cp = "plugins/"
	}
	m := map[string]any{
		"title":            b.MenuName,
		"i18n":             fmt.Sprintf("%s.%s", b.PackageLower, b.StructName),
		"icon":             "mdi:menu",
		"type":             "M",
		"hidden":           false,
		"componentPath":    cp,
		"componentSuffix":  ".vue",
		"breadcrumbEnable": true,
		"copyright":        true,
		"cache":            true,
		"affix":            false,
	}
	raw, err := json.Marshal(m)
	if err != nil {
		return "{}"
	}
	return string(raw)
}

// BuildTSVoFields 从列元数据生成 TS 字段行。
func BuildTSVoFields(cols []ColumnMeta) []TSVoField {
	var out []TSVoField
	for _, c := range cols {
		ts := tsTypeFromMySQL(c.DataType, c.ColumnType)
		cm := strings.TrimSpace(c.Comment)
		if idx := strings.Index(cm, "["); idx > 0 {
			cm = strings.TrimSpace(cm[:idx])
		}
		out = append(out, TSVoField{Name: c.Name, TSType: ts, Comment: cm})
	}
	return out
}

func tsTypeFromMySQL(dataType, columnType string) string {
	dt := strings.ToLower(dataType)
	if strings.Contains(dt, "int") || strings.Contains(dt, "decimal") || dt == "float" || dt == "double" {
		return "number"
	}
	if dt == "json" {
		return "any"
	}
	_ = columnType
	return "string"
}

func readHTTPGoPackage(pluginRoot string) string {
	for _, name := range []string{"routes.go", "endpoints.go"} {
		b, err := os.ReadFile(filepath.Join(pluginRoot, name))
		if err == nil {
			if p := goPackageFromSource(string(b)); p != "" {
				return p
			}
		}
	}
	entries, err := os.ReadDir(pluginRoot)
	if err != nil {
		return ""
	}
	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		n := e.Name()
		if !strings.HasSuffix(n, ".go") || strings.HasSuffix(n, "_test.go") {
			continue
		}
		b, err := os.ReadFile(filepath.Join(pluginRoot, n))
		if err != nil {
			continue
		}
		if p := goPackageFromSource(string(b)); p != "" {
			return p
		}
	}
	return ""
}

func goPackageFromSource(src string) string {
	for _, ln := range strings.Split(src, "\n") {
		ln = strings.TrimSpace(ln)
		if strings.HasPrefix(ln, "package ") {
			return strings.TrimSpace(strings.TrimPrefix(ln, "package "))
		}
	}
	return ""
}
