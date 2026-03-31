package gen

import (
	"strconv"
	"strings"
)

// BuildCrudFormFields 。
func BuildCrudFormFields(module string, tableInfo TableInfoCrud, cols []ColumnMeta) []CrudFormField {
	sfx := fieldSuffixMap()
	pfx := fieldPrefixMap()
	cmap := fieldContainsMap()
	var out []CrudFormField
	for _, col := range cols {
		field := col.Name
		if field == "id" || field == tableInfo.PrimaryKey {
			continue
		}
		comp := determineComponentType(field, sfx, pfx, cmap)
		dbType := simplifyDbType(col.ColumnType)
		isList := isListField(dbType, field, col.Name)
		isQuery, compCfg := getComponentConfig(field, col.Comment, comp)
		label, required, ruleSearch, hidden := parseFieldComment(field, col.Comment)
		if hidden {
			isList = false
			isQuery = false
		}
		if ruleSearch {
			isQuery = true
		}
		isForm := isFormField(field)
		sortable := stringInSlice(dbType, CrudSortableTypes)

		goType, _ := mysqlToGo(col.DataType, col.ColumnType, col.Nullable, col.Key, col.Extra)
		goName := ExportedField(field)
		isJSON := dbType == "json"
		isTime := goType == "time.Time" || goType == "*time.Time"

		renderProps := map[string]any{}
		placeholderMsg := "t('" + module + "." + tableInfo.PascalCase + "Fields." + field + "')"
		phKey := "pleaseInput"
		if comp != "el-input" && comp != "el-input-number" {
			phKey = "pleaseSelect"
		}
		renderProps["placeholder"] = "t('form." + phKey + "', { msg: " + placeholderMsg + " })"

		switch comp {
		case "el-input-number":
			renderProps["min"] = 0
			renderProps["precision"] = 2
		case "el-editor", "NmTinyMCE":
			// 前端模板里 getFormItems 会把 el-editor 换成 el-input；此处保留 editor
		}
		if strings.Contains(field, "description") || strings.Contains(field, "remark") || comp == "el-editor" {
			renderProps["type"] = "textarea"
			renderProps["rows"] = 3
		}
		if comp == "ma-upload-file" {
			renderProps["title"] = "文件上传"
			renderProps["fileSize"] = 10 * 1024 * 1024
			renderProps["fileType"] = []string{"doc", "xls", "ppt", "txt", "pdf"}
			renderProps["limit"] = 1
			renderProps["multiple"] = false
		}
		if (comp == "el-select" || comp == "el-switch") && len(compCfg) > 0 {
			for k, v := range compCfg {
				renderProps[k] = v
			}
		}
		if comp == "el-date-picker" {
			renderProps["valueFormat"] = "YYYY-MM-DD"
			renderProps["clearable"] = true
			renderProps["type"] = "date"
		}

		reqRules := generateRequestRules(field, dbType, comp, required)

		out = append(out, CrudFormField{
			Field:           field,
			IsList:          isList,
			IsQuery:         isQuery,
			IsForm:          isForm,
			Label:           label,
			Component:       comp,
			ComponentConfig: compCfg,
			RenderProps:     renderProps,
			Required:        required,
			DBType:          dbType,
			Sortable:        sortable,
			Nullable:        strings.ToUpper(col.Nullable) == "YES",
			RequestRules:    reqRules,
			GoType:          goType,
			GoName:          goName,
			JSONName:        field,
			IsJSONCol:       isJSON,
			IsTime:          isTime,
		})
	}
	return out
}

func parseFieldComment(field, comment string) (label string, required, search, hidden bool) {
	comment = strings.TrimSpace(comment)
	label = comment
	if idx := strings.Index(comment, "["); idx >= 0 {
		endRel := strings.Index(comment[idx:], "]")
		if endRel > 0 {
			end := idx + endRel
			inside := comment[idx+1 : end]
			rules := strings.Split(inside, ",")
			for _, r := range rules {
				r = strings.TrimSpace(r)
				switch r {
				case "required":
					required = true
				case "search":
					search = true
				case "hidden":
					hidden = true
				}
			}
			label = strings.TrimSpace(comment[:idx] + comment[end+1:])
		}
	}
	if label == "" {
		label = formatFieldNameFallback(field)
	}
	return label, required, search, hidden
}

func formatFieldNameFallback(field string) string {
	switch field {
	case "created_at":
		return "创建时间"
	case "updated_at":
		return "更新时间"
	case "deleted_at":
		return "删除时间"
	default:
		parts := strings.Split(field, "_")
		for i, p := range parts {
			if p == "" {
				continue
			}
			parts[i] = strings.ToUpper(p[:1]) + p[1:]
		}
		return strings.Join(parts, " ")
	}
}

func isListField(dbType, field, colName string) bool {
	if stringInSlice(dbType, CrudLargeTextTypes) {
		return false
	}
	skip := []string{"description", "content", "password", "deleted_at"}
	for _, s := range skip {
		if containsFold(field, s) || containsFold(colName, s) {
			return false
		}
	}
	return true
}

func isFormField(field string) bool {
	for _, sf := range CrudSkipFormFields {
		if strings.Contains(field, sf) {
			return false
		}
	}
	return true
}

func determineComponentType(field string, sfx []struct{ Suf, Comp string }, pfx map[string]string, cmap map[string]string) string {
	for _, row := range sfx {
		if row.Suf == "" {
			continue
		}
		if strings.HasSuffix(field, row.Suf) {
			return row.Comp
		}
	}
	for pref, comp := range pfx {
		if strings.HasPrefix(field, pref) {
			return comp
		}
	}
	// contains 映射按 key 长度降序可能更稳；此处按 map 无序 — 对生成器可接受
	bestLen := 0
	best := "el-input"
	for sub, comp := range cmap {
		if strings.Contains(field, sub) && len(sub) > bestLen {
			bestLen = len(sub)
			best = comp
		}
	}
	return best
}

func getComponentConfig(field, comment, componentType string) (bool, map[string]any) {
	cfg := map[string]any{}
	isQuery := false
	quick := []string{"mobile", "username", "email", "status", "type", "category_id", "parent_id"}
	for _, q := range quick {
		if field == q {
			isQuery = true
			break
		}
	}
	if strings.Contains(comment, ":") && strings.Contains(comment, "=") {
		parts := strings.SplitN(comment, ":", 2)
		if len(parts) == 2 {
			rest := strings.TrimSpace(parts[1])
			tokens := strings.Split(rest, ",")
			if len(tokens) > 1 {
				var data []map[string]any
				for _, tok := range tokens {
					tok = strings.TrimSpace(tok)
					kv := strings.SplitN(tok, "=", 2)
					if len(kv) != 2 {
						continue
					}
					val := strings.TrimSpace(kv[0])
					lb := strings.TrimSpace(kv[1])
					n, _ := strconv.Atoi(val)
					data = append(data, map[string]any{"label": lb, "value": n})
				}
				if len(data) > 0 && (componentType == "el-switch" || componentType == "el-select" || componentType == "el-radio") {
					isQuery = true
					cfg["clearable"] = true
					cfg["data"] = data
				}
			}
		}
	}
	if componentType == "el-date-picker" && field != "updated_at" && field != "deleted_at" {
		isQuery = true
		cfg["clearable"] = true
		cfg["type"] = "daterange"
		cfg["valueFormat"] = "YYYY-MM-DD"
	}
	return isQuery, cfg
}

func simplifyDbType(columnType string) string {
	t := strings.ToLower(columnType)
	switch {
	case strings.Contains(t, "int"):
		return "int"
	case strings.Contains(t, "decimal"):
		return "decimal"
	case strings.Contains(t, "bigint"):
		return "bigint"
	case strings.Contains(t, "varchar"):
		return "varchar"
	default:
		if idx := strings.Index(t, "("); idx > 0 {
			return t[:idx]
		}
		return t
	}
}

func generateRequestRules(fieldName, dbType, componentType string, required bool) []string {
	rules := []string{"sometimes"}
	if required {
		rules = []string{"required"}
	}
	if strings.Contains(dbType, "int") {
		rules = append(rules, "integer")
	} else if strings.Contains(dbType, "decimal") || strings.Contains(dbType, "float") || strings.Contains(dbType, "double") {
		rules = append(rules, "numeric")
	} else if strings.Contains(dbType, "date") || strings.Contains(dbType, "time") {
		rules = append(rules, "date")
	} else if strings.Contains(dbType, "json") {
		rules = append(rules, "array")
	}
	addFieldNameRules(&rules, fieldName)
	if componentType == "el-input-number" {
		hasNum := false
		for _, r := range rules {
			if r == "numeric" || r == "integer" {
				hasNum = true
				break
			}
		}
		if !hasNum {
			rules = append(rules, "numeric")
		}
	}
	if componentType == "el-date-picker" {
		hasDate := false
		for _, r := range rules {
			if r == "date" {
				hasDate = true
				break
			}
		}
		if !hasDate {
			rules = append(rules, "date")
		}
	}
	if stringInSlice("sometimes", rules) && len(rules) > 1 {
		var nr []string
		for _, r := range rules {
			if r != "sometimes" {
				nr = append(nr, r)
			}
		}
		rules = nr
	}
	// unique
	seen := map[string]struct{}{}
	var u []string
	for _, r := range rules {
		if _, ok := seen[r]; !ok {
			seen[r] = struct{}{}
			u = append(u, r)
		}
	}
	return u
}

func addFieldNameRules(rules *[]string, fieldName string) {
	if strings.Contains(fieldName, "email") {
		*rules = append(*rules, "email")
		return
	}
	if fieldName == "password" || fieldName == "pass" || strings.HasSuffix(fieldName, "_password") {
		*rules = append(*rules, "min:6")
		if fieldName == "password" {
			*rules = append(*rules, "confirmed")
		}
		return
	}
	if fieldName == "phone" || fieldName == "mobile" || strings.HasSuffix(fieldName, "_phone") || strings.HasSuffix(fieldName, "_mobile") {
		*rules = append(*rules, "regex")
		return
	}
	if fieldName == "ip" {
		*rules = append(*rules, "ip")
		return
	}
	if strings.HasSuffix(fieldName, "_at") {
		*rules = append(*rules, "date")
		return
	}
	if fieldName == "status" || strings.HasSuffix(fieldName, "_status") {
		*rules = append(*rules, "integer")
	}
}

// BuildQueryFields 列表筛选字段。
func BuildQueryFields(form []CrudFormField) []CrudQueryField {
	var q []CrudQueryField
	for _, f := range form {
		if !f.IsQuery {
			continue
		}
		mode := "like"
		if strings.Contains(f.DBType, "int") || f.Component == "el-switch" {
			mode = "eq_int"
		}
		if f.Component == "el-date-picker" {
			mode = "eq"
		}
		q = append(q, CrudQueryField{DBName: f.Field, QueryMode: mode})
	}
	return q
}

// BuildBodyFields 生成 JSON body 用（排除不参与表单的列）；save 时便于区分「未传」与零值，非 JSON 列统一用指针。
func BuildBodyFields(form []CrudFormField) []CrudBodyField {
	var b []CrudBodyField
	for _, f := range form {
		if !f.IsForm {
			continue
		}
		if stringInSlice(f.Field, CrudSkipFormFields) {
			continue
		}
		if f.IsJSONCol {
			b = append(b, CrudBodyField{
				JSONName: f.Field,
				GoName:   f.GoName,
				GoType:   "json.RawMessage",
				Ptr:      false,
			})
			continue
		}
		goT := f.GoType
		if strings.HasPrefix(goT, "*") {
			b = append(b, CrudBodyField{JSONName: f.Field, GoName: f.GoName, GoType: goT, Ptr: true})
			continue
		}
		if f.IsTime {
			b = append(b, CrudBodyField{
				JSONName: f.Field, GoName: f.GoName, GoType: "*string", Ptr: true,
				ParseTime: true, ModelGoType: "time.Time",
			})
			continue
		}
		bodyType := "*" + goT
		b = append(b, CrudBodyField{JSONName: f.Field, GoName: f.GoName, GoType: bodyType, Ptr: true, ModelGoType: goT})
	}
	return b
}

// TableFieldsFiltered 表格列（排除 tableFl）。
func TableFieldsFiltered(form []CrudFormField) []CrudFormField {
	var t []CrudFormField
	for _, f := range form {
		if !f.IsList {
			continue
		}
		if stringInSlice(f.Field, CrudSkipTableFields) {
			continue
		}
		t = append(t, f)
	}
	return t
}

func camelFieldI18n(dbName string) string {
	parts := strings.Split(dbName, "_")
	for i, p := range parts {
		if p == "" {
			continue
		}
		if i == 0 {
			parts[i] = strings.ToLower(p[:1]) + p[1:]
		} else {
			parts[i] = strings.ToUpper(p[:1]) + p[1:]
		}
	}
	return strings.Join(parts, "")
}
