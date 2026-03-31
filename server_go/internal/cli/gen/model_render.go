package gen

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"text/template"
)

// RenderModelGo 从 internal/cli/templates/model.go.tmpl 渲染（工作区根由调用方传入）。
func RenderModelGo(templatesDir string, data ModelTemplateData) ([]byte, error) {
	path := filepath.Join(templatesDir, "model.go.tmpl")
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read template %s: %w", path, err)
	}
	t, err := template.New("model.go").Parse(string(raw))
	if err != nil {
		return nil, err
	}
	var buf bytes.Buffer
	if err := t.Execute(&buf, data); err != nil {
		return nil, err
	}
	return formatGeneratedGo(buf.Bytes()), nil
}

func formatGeneratedGo(b []byte) []byte {
	s := string(b)
	s = strings.ReplaceAll(s, "\n\n\n", "\n\n")
	return []byte(s)
}
