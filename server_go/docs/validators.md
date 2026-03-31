# 验证器使用

**参数校验**在 **handler 入口** 完成；校验失败：**HTTP 200**、`code` 为 **422**、首条错误文案（见 `tools.BindJSONOr422`）。

分层关系见 [MVC 与分层](mvc.md)。

## struct 校验

请求体用 **带 `binding` 标签的 struct**（Gin 内部使用 **validator/v10**，与 `json` 标签并列）。handler 入口调用 **`tools.BindJSONOr422`**：成功返回 `true` 且已写入 `body`；失败则**已写回响应**（HTTP **200**、`code` 为 **422**、`message` 为首条校验错误），应 **`return`** 不再执行业务逻辑。

### 1. 定义请求体

与 [`internal/app/http/admin/routes.go`](../internal/app/http/admin/routes.go) 等处的写法一致：

```go
type loginBody struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}
```

常用 `binding` 示例：`required`、`min=6`、`max=20`、`email`、`oneof=a b` 等（见 [go-playground/validator](https://github.com/go-playground/validator)）。**嵌套 struct** 可对子字段写 `binding:"dive"` 等以校验切片/子结构。

### 2. 在 handler 中绑定并校验

```go
func Xxx(d *deps.Deps) gin.HandlerFunc {
	return func(c *gin.Context) {
		var body loginBody
		if !tools.BindJSONOr422(c, &body) {
			return
		}
		// 此处 body 已通过校验，可调用 service
	}
}
```

### 3. 错误文案

[`tools.validationFirstError`](../internal/app/common/tools.go) 对常见 tag 做了简短英文提示（如 `required` → `Field is required`，`email`、`min`/`max` 略有区分）；其余 tag 为 `{Field} invalid`。若需更细的中英文或 i18n，可在该函数或统一封装上扩展。
