package gen

import "time"

// CrudOptions CLI 与路径解析结果。
type CrudOptions struct {
	Table      string
	Module     string
	Plugin     string
	AdminRoot  string
	HTTPPrefix string // 覆盖自动推导，如 /admin/search/keyword
	Force      bool
	PID        int
	RunMenuSQL bool
	SkipFront  bool
	SkipGo     bool
	ModelOut   string
	ModelAlias string // 插件 model import 别名，默认 plugmodel
	GoOut      string // 覆盖生成的 Go handler 路径
}

// CrudBundle 渲染模板与 Go handler 所需的全部数据。
type CrudBundle struct {
	Opts CrudOptions

	StructName    string // Pascal，如 SearchKeyword
	TableSingular string
	CamelName     string // searchKeyword，由 singular 表名推导
	ResourceSeg   string // URL/API 资源段，如 keyword
	ModuleSeg     string // URL 模块段；含 / 时取末段 studly 小写
	PackageLower  string // module 小写（菜单/API 前缀）

	HTTPPrefix string // /admin/search/keyword
	PermPrefix string // search:keyword 或 ds:sysCms:placement_position
	PermSnake  string // 权限第三段（snake 模型名）
	APITSBase  string // keyword / placementPosition（文件名，不含 .ts）
	TSVoName   string // KeywordVo / PlacementPositionVo

	PrimaryKey   string // 列名
	PrimaryKeyGo string // ID
	HasDeletedAt bool

	FormFields  []CrudFormField
	TableFields []CrudFormField
	QueryFields []CrudQueryField
	BodyFields  []CrudBodyField // create/save 表单列

	IsPlugin       bool
	ModulePath     string // go.mod module 行，生成 import 用
	ModelImport    string
	HandlerPackage string
	ModelPkgAlias  string // 插件 generated: plugmodel

	SkipForm []string
	TableFl  []string
	TransFl  []string

	MenuName   string
	DBPrefix   string
	NowSQL     string
	PluginPath string // ds/sysCms — web 与 import 用

	HasCreatedBy bool
	HasUpdatedBy bool

	TSVoFields []TSVoField // admin *.ts 接口类型

	DefineOptionsName string // index.vue defineOptions name
	APIImportPath     string // form/index 中 import api 的路径
	MenuMetaJSON      string // menu.meta JSON
	MenuMetaSQL       string // 嵌入 SQL 单引号字符串时对 ' 转义
}

// TSVoField 列在 TypeScript Vo 中的映射。
type TSVoField struct {
	Name    string
	TSType  string
	Comment string
}

// CrudFormField 。
type CrudFormField struct {
	Field           string
	IsList          bool
	IsQuery         bool
	IsForm          bool
	Label           string
	Component       string
	ComponentConfig map[string]any
	RenderProps     map[string]any
	Required        bool
	DBType          string
	Sortable        bool
	Nullable        bool
	RequestRules    []string
	GoType          string // Go 结构体字段类型
	GoName          string // 导出字段名
	JSONName        string // json tag
	IsJSONCol       bool
	IsTime          bool
}

// CrudQueryField 列表筛选。
type CrudQueryField struct {
	DBName    string
	QueryMode string // like | eq | eq_int
}

// CrudBodyField HTTP JSON 绑定字段。
type CrudBodyField struct {
	JSONName    string
	GoName      string
	GoType      string // 指针或值类型，如 *int, *string
	Ptr         bool
	ParseTime   bool   // body 为 *string，入库 time.Time
	ModelGoType string // 目标 model 字段类型，如 time.Time
}

// TableInfoCrud 表基础信息。
type TableInfoCrud struct {
	PID        int
	Name       string
	Comment    string
	CamelCase  string
	PascalCase string
	PrimaryKey string
}

func (b *CrudBundle) handlerCoreName(action string) string {
	// List / Create / Save / Delete
	return b.StructName + action
}

func (b *CrudBundle) handlerPluginBase() string {
	return LowerFirst(b.StructName) + "Admin"
}

// NowSQLDefault 用于菜单 SQL 占位。
func NowSQLDefault() string {
	return time.Now().Format("2006-01-02 15:04:05")
}
