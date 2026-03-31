# MVC 与分层

框架采用 **薄 Controller（Gin handler）+ Service + Model（GORM）**；**无注解驱动路由**，路由表为显式 `router.Endpoint` 列表。

## 分层职责

| 层 | 落点 | 职责 |
|----|------|------|
| **请求校验** | handler 内 [`tools.BindJSONOr422`](../internal/app/common/tools.go) 等 | Body：`ShouldBindJSON` + struct `binding`；失败 `response.WithCode(CodeUnprocessable, …)`。详见 [验证器使用](validators.md)。 |
| **全局校验钩子** | [`middleware.ValidatorHook`](../internal/app/middleware/validator.go) | 占位（`c.Next()`）；业务校验勿依赖此项。 |
| **HTTP / 插件 handler** | [`internal/app/http`](../internal/app/http)、[`plugin/ds/*/src/http`](../plugin/ds/sysConfig/src/http/) | 薄层：解析参数、调 service、`response.JSON`。 |
| **服务层** | [`internal/app/service`](../internal/app/service) | 无 Gin 依赖；核心与插件可复用。 |
| **模型层** | [`internal/app/model`](../internal/app/model) | GORM 实体与表映射。 |

## 参数校验约定

**参数校验**在 **handler 入口** 完成；校验失败：**HTTP 200**、`code` 为 **422**、首条错误文案（见 `tools.BindJSONOr422`）。代码示例见 [验证器使用](validators.md)。

## 请求链路

见 [流程](flows.md) 中的 Mermaid 简图。

**依赖与 HandlerCtx**：[deps](deps.md)。**统一响应与业务码**：[API 约定](api-conventions.md)。
