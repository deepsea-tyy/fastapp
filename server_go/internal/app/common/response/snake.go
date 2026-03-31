package response

import (
	"bytes"
	"encoding/json"

	"github.com/iancoleman/strcase"
)

// marshalJSONSnake 先标准序列化再对 JSON 对象键递归转为 snake_case，省略 json 标注或驼峰 tag 时仍以下划线输出。
func marshalJSONSnake(v any) ([]byte, error) {
	raw, err := json.Marshal(v)
	if err != nil {
		return nil, err
	}
	dec := json.NewDecoder(bytes.NewReader(raw))
	dec.UseNumber()
	var tree any
	if err := dec.Decode(&tree); err != nil {
		return nil, err
	}
	return json.Marshal(keysToSnake(tree))
}

func keysToSnake(v any) any {
	switch x := v.(type) {
	case map[string]any:
		out := make(map[string]any, len(x))
		for k, val := range x {
			out[strcase.ToSnake(k)] = keysToSnake(val)
		}
		return out
	case []any:
		out := make([]any, len(x))
		for i := range x {
			out[i] = keysToSnake(x[i])
		}
		return out
	default:
		return v
	}
}
