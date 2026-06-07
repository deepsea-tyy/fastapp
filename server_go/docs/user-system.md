# 用户体系与 App API

## 一张 `user` 表，两类账号

数据模型为 **[`model.User`](../internal/app/model/user.go)**，映射表 **`{DB_PREFIX}user`**。**管理端后台账号**与 **App（C 端）用户**共用此表，靠字段 **`user_type`** 区分：

| `user_type`（常量） | 含义 | 典型用途 |
|---------------------|------|----------|
| **`100`**（`UserTypeSystem`，查询里兼容整型 `100`） | 系统/管理端账号 | 后台登录、RBAC、菜单权限 |
| **`200`**（`UserTypeUser`） | App 注册用户 | `/api/user/*` 注册、登录、资料 |

业务查询时会带 **`user_type`** 条件，避免把后台账号当 C 端用户处理（反之亦然）。资料扩展等业务表（如 **`user_profile`**）通过 **`user_id`** 关联同一主键。

## 用「哪套 Token」区分入口（管理端 vs App）

两套 JWT **密钥与签发逻辑独立**（环境变量 **`JWT_SECRET`** / **`JWT_API_SECRET`**，见 [配置](configuration.md)）：

| 入口 | 路由前缀与 `Kind` | 校验中间件 | 签发 |
|------|-------------------|------------|------|
| **管理端** | `/admin/*`，多数为 **`KindAdminJWT`** | `RequireAdminJWT`（可选菜单权限） | 登录 [`PassportLogin`](../internal/app/http/admin/routes.go) → **`d.JWT.IssuePair(uid)`**，仅 **`user_type IN ('100', 100)`** |
| **App** | `/api/*` 中带 **`KindAPIJWT`** 的接口 | `RequireAPIJWT` | 注册/登录等 → **`tools.IssueAPIToken`**，操作用户均为 **`user_type = '200'`** |

客户端统一使用：

```http
Authorization: Bearer <access_token>
```

但必须使用**对应入口签发的 access**：管理端 token **不能**通过 `RequireAPIJWT`；App token **不能**通过 `RequireAdminJWT`。WebSocket `login` 会先按 admin 再按 api 解析，与 HTTP 双场景一致（见 [WebSocket](websocket.md)）。

**刷新**：管理端与 App 各自有 refresh 流程；App 侧公开路由 **`POST /api/user/refreshToken`** 见下表。

---

## App 侧 HTTP 接口（`/api/*`）

以下为 **`router.Endpoints()`** 中与 App 相关且当前核心的路由（插件还可追加更多 `/api`）。**真源**以 [`endpoints.go`](../internal/app/router/endpoints.go) 为准。

### 鉴权说明

- **`公开`**：`KindPublic`，无需 Bearer。
- **需 App Token**：`KindAPIJWT`，须 **`JWT_API_SECRET`** 已配置且 Bearer 为 **API 场景** access token。

### 用户与账号

| 方法 | 路径 | 鉴权 | 说明 |
|------|------|------|------|
| POST | `/api/user/register` | 公开 | 注册（多方式，见 body `type`） |
| GET | `/api/user/isRegister` | 公开 | 是否已注册 |
| GET | `/api/sms` | 公开 | 短信相关 |
| POST | `/api/user/smsCheck` | 公开 | 短信校验 |
| POST | `/api/user/login` | 公开 | 登录，签发 **API** token |
| POST | `/api/user/logout` | App JWT | 登出（可配合黑名单等） |
| POST | `/api/user/refreshToken` | 公开 | 刷新令牌 |
| GET | `/api/user/info` | App JWT | 当前用户信息 |
| POST | `/api/user/password/change` | App JWT | 修改密码 |
| POST | `/api/user/account/disable` | App JWT | 停用账号 |
| POST | `/api/user/account/delete` | App JWT | 注销账号 |
| GET | `/api/user/google2fa/qrcode` | App JWT | 2FA 绑定二维码 |
| POST | `/api/user/google2fa/bind` | App JWT | 绑定 2FA |
| POST | `/api/user/google2fa/unbind` | App JWT | 解绑 2FA |
| POST | `/api/user/email/bind` | App JWT | 绑定邮箱 |
| POST | `/api/user/email/unbind` | App JWT | 解绑邮箱 |
| POST | `/api/user/mobile/bind` | App JWT | 绑定手机 |
| POST | `/api/user/mobile/unbind` | App JWT | 解绑手机 |
| GET | `/api/user/accountLogs` | App JWT | 账号日志 |
| POST | `/api/user/profile/update` | App JWT | 更新资料 |
| POST | `/api/user/resetPassword` | 公开 | 重置密码 |
| GET | `/api/user/baseInfo` | 公开 | 基础信息（按业务约定查询） |

实现主要在 [`internal/app/http/user.go`](../internal/app/http/user.go)（`apphttp` 包，注册/登录等）与 [`internal/app/http/api/user/`](../internal/app/http/api/user/)（需登录后的用户接口）。

### 附件与文件

| 方法 | 路径 | 鉴权 | 说明 |
|------|------|------|------|
| GET | `/api/file` | 公开 | 存储文件读取 |
| GET | `/api/attachment/list` | App JWT | 附件列表 |
| POST | `/api/attachment/upload` | App JWT | 上传 |
| DELETE | `/api/attachment/:id` | App JWT | 删除 |
| POST | `/api/attachment/chunk-upload` | App JWT | 分片上传 |
| POST | `/api/attachment/chunk-merge` | App JWT | 分片合并 |

### 搜索（示例公开接口）

| 方法 | 路径 | 鉴权 |
|------|------|------|
| GET | `/api/search` | 公开 |
| GET | `/api/search/suggest` | 公开 |
| GET | `/api/search/ranking` | 公开 |
| GET | `/api/search/keywords/hot` | 公开 |
| POST | `/api/search/click` | 公开 |

## 响应格式

与全站一致：**`code` / `message` / `data`**，见 [HTTP 文档 · API 约定](http.md#api-conventions)。

## 相关文档

- [鉴权与权限](auth-and-permission.md)：`KindAdminJWT` / `KindAPIJWT`、401 行为
- [HTTP 文档 · 路由](http.md#routing)：插件如何合并 `/api` 路由
