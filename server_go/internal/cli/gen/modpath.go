package gen

import (
	"bufio"
	"fmt"
	"os"
	"strings"

	tools "fastapp/internal/app/common"
)

// ReadModulePath 读取 root 目录下 go.mod 的 module 声明，作为生成代码中 import 路径前缀。
func ReadModulePath(root string) (string, error) {
	path := tools.RootJoin(root, "go.mod")
	f, err := os.Open(path)
	if err != nil {
		return "", fmt.Errorf("open go.mod: %w", err)
	}
	defer f.Close()
	sc := bufio.NewScanner(f)
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if strings.HasPrefix(line, "module ") {
			return strings.TrimSpace(strings.TrimPrefix(line, "module ")), nil
		}
	}
	if err := sc.Err(); err != nil {
		return "", err
	}
	return "", fmt.Errorf("go.mod 中未找到 module 行: %s", path)
}

// JoinImport 将 module 路径与仓库内包相对路径（如 internal/app/model）拼成完整 import 路径。
func JoinImport(modulePath, pkgRel string) string {
	m := strings.Trim(strings.TrimSpace(modulePath), "/")
	r := strings.Trim(strings.TrimSpace(pkgRel), "/")
	if r == "" {
		return m
	}
	return m + "/" + r
}
