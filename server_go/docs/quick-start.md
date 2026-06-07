# 快速开始

## 环境

- **Go**：**1.25+**（见 `go.mod`）
- **admin**（前端）：与 `server_go` 同级时常为 `../admin`；**Node** 以 `admin/package.json` → `engines` 为准

## 首次运行

在含 `go.mod` 的 **`server_go` 根**：

```bash
cp .env.example .env
# 编辑 DB_*、DB_PREFIX 等 → [配置](configuration.md)

go run ./cmd/cli migrate up internal/store/database
go run ./cmd/cli migrate seed internal/store/database

go run ./cmd/server
```

另开终端（路径按仓库布局调整）：

```bash
cd ../admin && npm install && npm run dev
```

`admin/.env.development` 中 API 与 `.env` 的 **`APP_PORT`**（默认 **9501**）一致；WebSocket 默认 **9502**（`APP_WS_PORT`）。

**默认管理端**：`admin` / `123456`（种子 `internal/store/database/seeders/2025_10_17_132807_init_admin.sql`）。生产请改密。

**可选：先编译**

```bash
go build -o bin/server ./cmd/server && go build -o bin/fastapp-cli ./cmd/cli
./bin/server
```

在非仓库目录跑 `./bin/server` 时设置 **`SERVER_GO_ROOT`** 指向本仓根 → [配置](configuration.md)。

## 独立仓库

本目录可作 Git 根。`module fastapp` 与 import `fastapp/...` 绑定。改 module 时需改 `go.mod`、全局替换 import，并同步 **`internal/app/common/paths.go`**（`tools.Module`）。

## CLI

`plugin`、`migrate`、`gen`、`ws` → **[CLI](cli.md)**。  
**`gen crud`**（别名 **`curd`**）自动生成 model、handler、前端、路由尾部追加等 → **[代码生成器](code-generator.md#gen-crud-manual-steps)**；菜单入库加 **`--sql`**。
