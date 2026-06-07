# CLI（fastapp-cli）

入口 **`cmd/cli`**，根命令 [`root.go`](../internal/cli/root.go)：`plugin`、`migrate`、`gen`、`ws`。

**工程根**：`SERVER_GO_ROOT` 或 cwd（须含 `go.mod`），[`ResolveServerGoRoot`](../internal/app/common/paths.go)。执行前加载根目录 `.env`（不覆盖已有变量）。

```bash
go build -o bin/fastapp-cli ./cmd/cli
./bin/fastapp-cli <子命令>   # 或 go run ./cmd/cli …
```

<a id="plugin-cli"></a>

## plugin — 插件

| 子命令 | 说明 |
|--------|------|
| `install <path>` | `plugin/<path>/` 须有 **`config.go`**；migrations → seeders → **`install.lock`** |
| `uninstall <path>` | 按菜单前缀删菜单；migrations 逆序 DROP；删 lock |
| `list` | 含 `config.go` 的插件及安装状态 |
| `create <path>` | 脚手架；须在 [`plugin.go`](../plugin/plugin.go) **登记** |
| `sync-admin [path]` | 插件 `web/` → `../admin/src/plugins/...` |
| `script <path>` | 读 **`publish.json`** 拷贝资源 |

选项：`install`/`uninstall` 的 **`--yes`**；`create` 的 **`--name|--description|--author|--type`**；`sync-admin` **`--all`**；`script` **`--show|--id|--force`**。

**详情** → [插件](plugins.md)。

<a id="migrate-cli"></a>

## migrate

| 子命令 | 说明 |
|--------|------|
| `up <databaseDir>` | `migrations/*.sql` |
| `seed <databaseDir>` | `seeders/*.sql` |
| `dump` | 核心 DDL → `gen/migrations/` |
| `import-sql <file>` | 导入 SQL |

核心目录 **`internal/store/database`**；插件 **`plugin/…/database`**。`{{prefix}}` → **`DB_PREFIX`**。

常用选项：`dump` 的 **`--force|--prefix|--filename|--out-dir|--plugin-root`**；`import-sql` **`--skip-errors|--transaction|--batch-size`**。

<a id="gen-cli"></a>

## gen — 代码生成

**`gen crud`** 与 **`curd`** 同义。子命令：`model`、`crud`、`seeders`。

**`gen crud`**：Go、model、前端、菜单 SQL、snippets、路由尾部追加；**`--sql`** 才执行菜单 SQL。选项 **`--table|--module|--plugin|--admin-root|--http-prefix|--sql|--pid|--skip-front|--skip-go|…** → 细节 [代码生成器](code-generator.md#gen-crud-manual-steps)。

<a id="ws-cli"></a>

## ws — WebSocket / Redis

需 Redis，键见 [redis_contract.md](../internal/websocket/redis_contract.md)。

`stats`、`fix-stats`、`list`、`clear --yes`、`online <ids>`；`list` 用 **`--page|--page-size|--user`**。

## 相关文档

[插件](plugins.md) · [代码生成器](code-generator.md)
