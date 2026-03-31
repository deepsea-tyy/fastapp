# 配置

环境变量见 [.env.example](../.env.example)。支持在工程根放置 `.env`（简单 `KEY=VALUE`，不覆盖已存在的环境变量）。

## 常用变量

| 变量 | 说明 |
|------|------|
| `SERVER_GO_ROOT` | 工程根（含 `plugin/`、`go.mod`），默认可不设置（用当前目录） |
| `APP_ENV` | 设为 `prod` 时 Gin 使用 Release 模式 |
| `APP_PORT` / `APP_WS_PORT` | HTTP / WS 端口 |
| `DB_*` / `DB_PREFIX` | MySQL；未配置 `DB_DATABASE` 时仅跑占位路由（无真实登录） |
| `DB_LOG_LEVEL` | GORM SQL 日志：`silent` / `error` / `warn` / `info`（另可 `debug`、`0`–`3`）；默认 `warn`；需要打印每条 SQL 时设为 **`info`** |
| `JWT_SECRET` / `JWT_API_SECRET` | HS256 密钥；缺失则对应场景 JWT 不可用 |
| `CACHE_PREFIX` | Redis 逻辑前缀（默认 `fastapp:`），用于 JWT 黑名单等键 |
| `REDIS_*` | 验证码、黑名单、WebSocket 映射。**`APP_ENV=prod`** 时管理端验证码与登录依赖 Redis；非 prod 可无 Redis（开发态降级） |

## 附件存储（sys_storage）

附件上传、分片合并与删除由 [`internal/app/service/storage`](../internal/app/service/storage) 按 **`system_config`** 选择后端；云密钥走数据库配置，**不**放在 `.env`。

| 项 | 说明 |
|----|------|
| **配置来源** | 表 `system_config`，`group_code = 'sys_storage'`。无行或空 `storage_mode` 视为 **`local`**。 |
| **本地模式 `local`** | **`Deps.UploadDir`**（默认 `{根目录}/storage/uploads`）。附件 URL：`/uploads/{Ymd}/{uuid}.{ext}`；Gin 挂载静态目录。 |
| **对象键** | 正式文件：`{Ymd}/{uuid}.{ext}`（`Ymd` 为 `20060102`）；分片临时对象：`tmp/{file_md5}/{chunk_index}.tmp`。 |

**`storage_mode` 取值与必填项**（键名与后台表单项一致，实现见 [`storage/config.go`](../internal/app/service/storage/config.go)）：

| `storage_mode` | 使用的 `key`（`system_config.key`） | 备注 |
|----------------|--------------------------------------|------|
| `local` | 无额外密钥 | 仅依赖 `UploadDir` 目录可写。 |
| `oss` | `oss_access_id`, `oss_access_secret`, `oss_bucket`, `oss_endpoint`, **`oss_domain`** | 访问 URL：`http://` + `oss_domain` + `/` + 对象键；HTTPS 在域名或网关侧终止。 |
| `qiniu` | `qiniu_access_key`, `qiniu_secret_key`, `qiniu_bucket`, **`qiniu_domain`** | 访问 URL 拼装同 OSS；**私有桶**若需公网可读 URL 请自行扩展签名逻辑。 |
| `cos` | `cos_secret_id`, `cos_secret_key`, `cos_bucket`, **`cos_region`**, **`cos_domain`** | 上传走 `https://{bucket}.cos.{region}.myqcloud.com`；对外 **`url`** 为 `http://` + `cos_domain` + `/` + 对象键。 |

切换模式或修改密钥后**下一次请求**即按新配置实例化存储后端；云端配置不完整时上传接口会返回 `validateConfig` 中的明确错误文案。
