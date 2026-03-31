# 快速开始

## 环境

- **Go** 1.23+（与 `go.mod` 一致）
- **admin**（前端）：与 `server_go` 同级时常为 `../admin`，**Node** 见 `admin/package.json` → `engines`

## 首次运行

在 **`server_go` 根**（含 `go.mod`）：

```bash
cp .env.example .env
# 编辑 .env：DB_*、DB_PREFIX 等，见 [配置](configuration.md)

go run ./cmd/cli migrate up internal/store/database
go run ./cmd/cli migrate seed internal/store/database

go run ./cmd/server
```

另开终端启动前端（路径按仓库布局调整）：

```bash
cd ../admin && npm install && npm run dev
```

`admin/.env.development` 中 API 须与 `.env` 里 **`APP_PORT`**（默认 **9501**）一致；WebSocket 默认 **9502**（`APP_WS_PORT`）。

**默认管理端**：**`admin`** / **`123456`**（种子 `internal/store/database/seeders/2025_10_17_132807_init_admin.sql`）。生产请改密。

**先编译再运行**（可选）：

```bash
go build -o bin/server ./cmd/server && go build -o bin/fastapp-cli ./cmd/cli
./bin/server
```

在非仓库目录执行 `./bin/server` 时设置 **`SERVER_GO_ROOT`** 指向本仓根（见 [配置](configuration.md)）。

## 独立仓库

可将本目录作为 Git 根；`go.mod` 的 **`module fastapp`** 与 import **`fastapp/...`** 绑定。若要改 module：修改 `go.mod`、全局替换 import，并同步 **`internal/app/common/paths.go`**（`tools` 包）中的 **`Module`**。

## CLI

`plugin`、`migrate`、`gen`、`ws` 见 **[命令行（CLI）](cli.md)**。  
用 **`gen crud`**（**`curd`**）时：**model**、**handler/前端**、**在 `endpoints.go` / 插件 `routes.go` 尾部追加路由** 等均按 **[代码生成器](code-generator.md#gen-crud-manual-steps)** 自动完成；菜单入库另加 **`--sql`**。
