# 配置

环境变量见 [.env.example](../.env.example)。可在工程根放 `.env`（`KEY=VALUE`，不覆盖已存在环境变量）。

## 常用变量

| 变量 | 说明 |
|------|------|
| `SERVER_GO_ROOT` | 含 `plugin/`、`go.mod` 的根；默认可不设（cwd） |
| `APP_ENV` | `prod` → Gin Release |
| `APP_PORT` / `APP_WS_PORT` | HTTP / WS 端口 |
| `DB_*` / `DB_PREFIX` | MySQL；**未设 `DB_DATABASE`** 则无 DSN、无业务路由（仅占位） |
| `DB_LOG_LEVEL` | GORM 日志：`silent` / `error` / `warn` / `info`（或 `debug`、`0`–`3`）；默认 `warn` |
| `JWT_SECRET` / `JWT_API_SECRET` | HS256；缺失则对应 JWT 场景不可用或路由不注册（见 [鉴权](auth-and-permission.md)） |
| `CACHE_PREFIX` | Redis 逻辑前缀（默认 `fastapp:`），JWT 黑名单等 |
| `REDIS_*` | 验证码、黑名单、WS。**`APP_ENV=prod`** 时管理端验证码/登录依赖 Redis；非 prod 可无 Redis |

## 附件（`sys_storage`）

实现 [`internal/app/service/storage`](../internal/app/service/storage)，配置来自表 **`system_config`**（`group_code = 'sys_storage'`）。云密钥在库表，**不在** `.env`。

| 项 | 说明 |
|----|------|
| **默认** | 无行或空 `storage_mode` → **`local`**，`Deps.UploadDir`（默认 `{根}/storage/uploads`），URL `/uploads/{Ymd}/{uuid}.{ext}` |
| **对象键** | 正式：`{Ymd}/{uuid}.{ext}`；分片临时：`tmp/{file_md5}/{chunk_index}.tmp` |

| `storage_mode` | 主要 `system_config.key` |
|----------------|-------------------------|
| `local` | 无额外密钥 |
| `oss` | `oss_access_id`, `oss_access_secret`, `oss_bucket`, `oss_endpoint`, **`oss_domain`** |
| `qiniu` | `qiniu_access_key`, `qiniu_secret_key`, `qiniu_bucket`, **`qiniu_domain`** |
| `cos` | `cos_secret_id`, `cos_secret_key`, `cos_bucket`, **`cos_region`**, **`cos_domain`** |

细节与校验错误文案见 [`storage/config.go`](../internal/app/service/storage/config.go)。
