package gen

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"text/template"
)

// RenderCRUDTemplate 渲染 internal/cli/templates/crud 下的模板。
func RenderCRUDTemplate(templatesDir, file string, b *CrudBundle) ([]byte, error) {
	path := filepath.Join(templatesDir, "crud", file)
	src, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read template %s: %w", path, err)
	}
	fn := template.FuncMap{
		"transKey":       crudTransKey,
		"renderComp":     crudRenderComp,
		"dictSelectIf":   crudDictMap,
		"formRenderComp": func(c string) string { return crudRenderComp(crudDictMap(c)) },
		"yamlQuote":      yamlSafe,
		"joinPath":       filepath.Join,
		"skipFormCol": func(name string) bool {
			return stringInSlice(name, CrudSkipFormFields)
		},
		"renderPropVal": renderPropVal,
		"eq":            func(a, b any) bool { return a == b },
	}
	t, err := template.New(file).Funcs(fn).Parse(string(src))
	if err != nil {
		return nil, err
	}
	var buf bytes.Buffer
	if err := t.Execute(&buf, b); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func crudTransKey(pkg, pascal string, f CrudFormField) string {
	cf := camelFieldI18n(f.Field)
	for _, t := range CrudTransFields {
		if cf == t {
			return "crud." + cf
		}
	}
	if f.Field == "remark" {
		return "crud.remark"
	}
	return pkg + "." + pascal + "Fields." + f.Field
}

func crudRenderComp(comp string) string {
	return map[string]string{
		"el-input":        "<el-input />",
		"el-input-number": "<el-input-number />",
		"el-select":       "<el-select />",
		"el-date-picker":  "<el-date-picker />",
		"el-switch":       "<el-switch />",
		"el-radio":        "<el-radio />",
		"el-checkbox":     "<el-checkbox />",
		"ma-upload-image": "<ma-upload-image />",
		"ma-upload-file":  "<ma-upload-file />",
		"ma-dict-select":  "<ma-dict-select />",
		"el-color-picker": "<el-color-picker />",
		"el-rate":         "<el-rate />",
		"el-editor":       "<NmTinyMCE height={300}/>",
		"NmTinyMCE":       "<NmTinyMCE height={300}/>",
	}[comp]
}

func crudDictMap(comp string) string {
	if comp == "el-switch" || comp == "el-select" {
		return "ma-dict-select"
	}
	if comp == "el-editor" {
		return "el-input"
	}
	return comp
}

func renderPropVal(v any) string {
	switch x := v.(type) {
	case string:
		ts := strings.TrimSpace(x)
		if strings.HasPrefix(ts, "t(") {
			return x
		}
		return strconv.Quote(x)
	case int:
		return strconv.Itoa(x)
	case int64:
		return strconv.FormatInt(x, 10)
	case float64:
		return strconv.FormatFloat(x, 'f', -1, 64)
	case bool:
		return strconv.FormatBool(x)
	default:
		b, err := json.Marshal(x)
		if err != nil {
			return "null"
		}
		return string(b)
	}
}

func yamlSafe(s string) string {
	s = strings.ReplaceAll(s, "'", "''")
	if strings.ContainsAny(s, ":#\n") {
		return "'" + s + "'"
	}
	return s
}
