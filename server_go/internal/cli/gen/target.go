package gen

import (
	"path/filepath"
	"strings"

	tools "fastapp/internal/app/common"

	"github.com/jinzhu/inflection"
)

// DefaultCoreModelRelPath 相对 server_go 根：internal/app/model/<表单数蛇形>.go
func DefaultCoreModelRelPath(table string) string {
	t := strings.TrimSpace(strings.ReplaceAll(table, "/", "_"))
	base := inflection.Singular(t) + ".go"
	return filepath.ToSlash(filepath.Join("internal", "app", "model", base))
}

// DefaultPluginModelRelPath 相对 server_go 根：plugin/<path>/src/model/<表单数蛇形>.go
func DefaultPluginModelRelPath(pluginPath, table string) string {
	t := strings.TrimSpace(strings.ReplaceAll(table, "/", "_"))
	base := inflection.Singular(t) + ".go"
	p := filepath.ToSlash(strings.TrimSpace(pluginPath))
	return filepath.ToSlash(filepath.Join("plugin", p, "src", "model", base))
}

// ResolveModelOutput 解析输出路径、package 名、是否使用 basemodel.P（插件与 genmodel 为 true；仅 internal/app/model 下核心包为 false）。
func ResolveModelOutput(root, outFlag, packageFlag, table string) (outPath string, pkg string, useBasemodelP bool) {
	st := StructNameFromTable(table)
	if strings.TrimSpace(outFlag) == "-" {
		pkg = strings.TrimSpace(packageFlag)
		if pkg == "" {
			pkg = "genmodel"
		}
		return "-", pkg, true
	}
	if strings.TrimSpace(outFlag) == "" {
		outPath = tools.RootJoin(root, "gen", "model", st+"_gen.go")
	} else {
		outPath = outFlag
	}

	root = filepath.Clean(root)
	outAbs, _ := filepath.Abs(outPath)
	if outAbs == "" {
		outAbs = filepath.Clean(outPath)
	}
	coreModel := tools.RootJoin(root, "internal", "app", "model")
	corePrefix := filepath.Clean(coreModel) + string(filepath.Separator)

	if strings.TrimSpace(packageFlag) != "" {
		pkg = strings.TrimSpace(packageFlag)
	} else if strings.HasPrefix(outAbs, corePrefix) || outAbs == filepath.Clean(coreModel) {
		pkg = "model"
	} else if isPluginModelPath(outAbs) {
		pkg = "model"
	} else {
		pkg = "genmodel"
	}

	useBasemodelP = true
	if pkg == "model" && (strings.HasPrefix(outAbs, corePrefix) || outAbs == filepath.Clean(coreModel)) {
		useBasemodelP = false
	}

	return outPath, pkg, useBasemodelP
}

func isPluginModelPath(p string) bool {
	s := filepath.ToSlash(p)
	return strings.Contains(s, "/plugin/") && strings.Contains(s, "/model/")
}
