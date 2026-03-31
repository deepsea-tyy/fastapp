package gen

import (
	"fmt"
	"regexp"
	"sort"
	"strings"
)

const importDatatypes = "gorm.io/datatypes"

// ModelField 模板中单行字段。
type ModelField struct {
	Name    string
	DBTag   string
	GoType  string
	Comment string
}

// ModelTemplateData 根模板数据。
type ModelTemplateData struct {
	Package       string
	TableComment  string
	StructName    string
	TableShort    string
	Fields        []ModelField
	Imports       []string
	UseBasemodelP bool // true: TableName() 用 basemodel.P；false 且 Package=model 时用 P
}

var reVarcharSize = regexp.MustCompile(`varchar\((\d+)\)`)
var reCharSize = regexp.MustCompile(`char\((\d+)\)`)

// BuildModelData 从列元数据构造模板数据；pkg / useBasemodelP 由 ResolveModelOutput 等解析；modulePath 来自仓库 go.mod。
func BuildModelData(table string, cols []ColumnMeta, tableComment, pkg, modulePath string, useBasemodelP bool) ModelTemplateData {
	st := StructNameFromTable(table)
	if tableComment == "" {
		tableComment = table
	}

	importSet := map[string]struct{}{}
	var fields []ModelField
	for _, c := range cols {
		fields = append(fields, modelFieldFromColumn(c, importSet))
	}

	if useBasemodelP {
		importSet[JoinImport(modulePath, "internal/app/model")] = struct{}{}
	}

	imports := make([]string, 0, len(importSet))
	for k := range importSet {
		imports = append(imports, k)
	}
	sort.Strings(imports)

	return ModelTemplateData{
		Package:       pkg,
		TableComment:  tableComment,
		StructName:    st,
		TableShort:    table,
		Fields:        fields,
		Imports:       imports,
		UseBasemodelP: useBasemodelP,
	}
}

func modelFieldFromColumn(c ColumnMeta, importSet map[string]struct{}) ModelField {
	name := ExportedField(c.Name)
	goType, extraImps := mysqlToGo(c.DataType, c.ColumnType, c.Nullable, c.Key, c.Extra)
	for _, im := range extraImps {
		importSet[im] = struct{}{}
	}
	tag := buildGormTag(c, goType)
	comment := strings.TrimSpace(c.Comment)
	if idx := strings.Index(comment, "["); idx > 0 {
		comment = strings.TrimSpace(comment[:idx])
	}
	lineComment := ""
	if comment != "" {
		lineComment = "// " + comment
	}
	return ModelField{Name: name, DBTag: tag, GoType: goType, Comment: lineComment}
}

func buildGormTag(c ColumnMeta, goType string) string {
	parts := []string{fmt.Sprintf("column:%s", c.Name)}
	if c.Key == "PRI" {
		parts = append(parts, "primaryKey")
		if strings.Contains(strings.ToLower(c.Extra), "auto_increment") {
			parts = append(parts, "autoIncrement")
		}
	}
	dt := strings.ToLower(c.DataType)
	switch dt {
	case "varchar", "char":
		if m := reVarcharSize.FindStringSubmatch(strings.ToLower(c.ColumnType)); len(m) == 2 {
			parts = append(parts, "size:"+m[1])
		} else if m := reCharSize.FindStringSubmatch(strings.ToLower(c.ColumnType)); len(m) == 2 {
			parts = append(parts, "size:"+m[1])
		}
	case "text", "mediumtext", "longtext", "tinytext":
		parts = append(parts, "type:text")
	case "json":
		parts = append(parts, "type:json")
	}
	return strings.Join(parts, ";")
}

func mysqlToGo(dataType, columnType, nullable, colKey, extra string) (string, []string) {
	dt := strings.ToLower(strings.TrimSpace(dataType))
	var imp []string
	var typ string
	switch dt {
	case "tinyint":
		if strings.Contains(columnType, "(1)") {
			typ = "int"
		} else {
			typ = "int"
		}
	case "smallint", "mediumint", "int":
		typ = "int"
	case "bigint":
		typ = "int64"
	case "decimal", "float", "double":
		typ = "float64"
	case "date", "datetime", "timestamp":
		typ = "time.Time"
		imp = append(imp, "time")
	case "json":
		typ = "datatypes.JSON"
		imp = append(imp, importDatatypes)
	case "blob", "tinyblob", "mediumblob", "longblob", "binary", "varbinary":
		typ = "[]byte"
	default:
		typ = "string"
	}
	if strings.ToUpper(nullable) == "YES" && colKey != "PRI" && !strings.Contains(strings.ToLower(extra), "auto_increment") {
		typ = nullableGoType(typ)
	}
	return typ, imp
}

func nullableGoType(base string) string {
	switch base {
	case "int":
		return "*int"
	case "int64":
		return "*int64"
	case "float64":
		return "*float64"
	case "time.Time":
		return "*time.Time"
	case "datatypes.JSON":
		return "*datatypes.JSON"
	case "[]byte":
		return "[]byte"
	case "string":
		return "*string"
	default:
		if strings.HasPrefix(base, "[]") {
			return "[]byte" // keep
		}
		return "*" + base
	}
}
