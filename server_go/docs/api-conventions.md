# API 约定与统一响应

HTTP JSON 体固定三字段：**`code`**（业务码）、**`message`**、**`data`**。实现见 [`internal/app/common/response`](../internal/app/common/response)。

## 与 HTTP 状态码的关系

常见用法：**HTTP 状态码多为 200**，由 **`code` 表意**（便于 admin / App 统一解析）。鉴权失败、参数校验失败等同样可能返回 **200 + `code` 401 / 422** 等，以实际 handler / 中间件为准。

占位接口可使用 [`response.Stub`](../internal/app/common/response/result.go)：`code` 为 200，`data` 中带 `_stub`、`_path` 等调试字段。

## 业务码常量

定义见 [`resultcode.go`](../internal/app/common/response/resultcode.go)（[`result.go`](../internal/app/common/response/result.go) 中有 `Code*` 别名）：

| 常量 | 值 | 典型含义 |
|------|---|----------|
| `ResultSuccess` / `CodeSuccess` | 200 | 成功 |
| `ResultUnauthorized` / `CodeUnauthorized` | 401 | 未授权 / Token 无效或缺失 |
| `ResultForbidden` / `CodeForbidden` | 403 | 无权限（如菜单权限不足） |
| `ResultNotFound` / `CodeNotFound` | 404 | 资源不存在 |
| `ResultMethodNotAllowed` | 405 | 方法不允许 |
| `ResultNotAcceptable` | 406 | 不可接受 |
| `ResultUnprocessableEntity` / `CodeUnprocessable` | 422 | 参数校验失败（如 `BindJSONOr422`） |
| `ResultDisabled` / `CodeDisabled` | 423 | 禁用 |
| `ResultFail` / `CodeFail` | 500 | 通用失败 |

`422` 在 i18n 键上对应 `ResultMessageKey` 中的 **`result.conflict`**（与 PHP 侧词条对齐历史命名）。

## 构造响应

| 函数 | 说明 |
|------|------|
| `response.OK(data)` | 成功，`code=200`，`message` 为默认或后经 i18n 替换 |
| `response.OKWithMessage(msg, data)` | 成功且自定义 `message` |
| `response.Fail(message)` | `code=500` |
| `response.WithCode(code, message, data)` | 任意业务码；`data` 为 nil 时序列化为 **`{}`** |

写入 Gin：`response.JSON(c, httpStatus, r)`。**`data` 序列化**：会对 **JSON 对象键递归转为 snake_case**（见 [`snake.go`](../internal/app/common/response/snake.go)），故 Go 结构体可用驼峰字段名，输出仍为下划线形式。

## `message` 与多语言

若传入的 `message` 与 [`defaultMessage`](../internal/app/common/response/result.go) 中该 `code` 的默认英文**相同**，`response.JSON` 会改用 **`i18n.T(FromGin(c), ResultMessageKey(code))`** 替换为当前请求语言的文案。自定义业务文案（explicit 字符串）一般保持原样。见 [国际化](i18n.md)。

## 校验类错误

请求体校验：`tools.BindJSONOr422` 失败时 **HTTP 200**、`code=422`，`message` 为首条校验错误。见 [验证器使用](validators.md)。

## 相关文档

- [鉴权与权限](auth-and-permission.md)：401 等在中间件中的返回
- [核心功能与架构](core-features.md)：契约总览
