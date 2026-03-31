# 命令行（fastapp-cli）

入口 **`cmd/cli`**，根命令见 [`internal/cli/root.go`](../internal/cli/root.go)：`plugin`、`migrate`、`gen`、`ws`。

**工程根**：`SERVER_GO_ROOT` 或当前目录（须含 `go.mod`），[`ResolveServerGoRoot`](../internal/app/common/paths.go)。子命令前会加载根目录 `.env`（不覆盖已有变量）。`migrate` / `plugin` / 多数 `gen` / `ws` 依赖 `.env` 中 **`DB_*`、`REDIS_*`** 等，见 [配置](configuration.md)。

```bash
go build -o bin/fastapp-cli ./cmd/cli
./bin/fastapp-cli <子命令> …   # 或 go run ./cmd/cli …
```

## plugin — 插件

| 子命令 | 说明 |
|--------|------|
| `plugin install <path>` | `plugin/<path>/` 须有 **`config.go`**；跑 **`migrations` → `seeders`**，写 **`install.lock`**。`path` 如 `ds/sysKefu`。已有 lock 报错。 |
| `plugin uninstall <path>` | 按菜单前缀删菜单（[菜单 name](plugins.md#plugin-menu-names)）；按 **`migrations`** 逆序 **DROP**；删 **`install.lock`**。无 lock 报错。 |
| `plugin list` | 列出含 **`config.go`** 的插件及安装状态。 |
| `plugin create <path>` | 脚手架；路由/WS 须在 [`plugin/plugin.go`](../plugin/plugin.go) **`init` 登记**。 |
| `plugin sync-admin [path]` | 插件 `web/` → **`../admin`** `src/plugins/<组织>/<插件>/`。 |
| `plugin script <path>` | 按 **`publish.json`** → **`publish`** 拷贝资源。 |

| 选项 | 适用 | 说明 |
|------|------|------|
| `--yes` / `-y` | `install`、`uninstall` | 跳过交互确认。 |
| `--name` | `create` | **`PluginName`**（默认同 path）；见 [插件](plugins.md)。 |
| `--description` | `create` | 描述（默认 `sample plugin`）。 |
| `--author` | `create` | 作者。 |
| `--type` | `create` | `mixed` \| `backend` \| `frontend`（默认 `mixed`）。 |
| `--all` / `-a` | `sync-admin` | 同步全部已安装且有 **`web/`** 的插件。 |
| `--show` / `-s` | `script` | 只打印 `publish` 项，不拷贝。 |
| `--id` / `-i` | `script` | 只执行指定 `publish` 条目的 `id`。 |
| `--force` / `-f` | `script` | 目标已存在仍覆盖。 |

插件目录约定、卸载规则、seeders 命名见 [插件](plugins.md)。

## migrate

| 子命令 | 说明 |
|--------|------|
| `migrate up <databaseDir>` | 跑 **`migrations/*.sql`**。核心根：`internal/store/database`；插件：`plugin/…/database`。 |
| `migrate seed <databaseDir>` | 跑 **`seeders/*.sql`**（同上）。 |
| `migrate dump` | 核心表 DDL → `gen/migrations/`，排除插件表。 |
| `migrate import-sql <file>` | 导入 SQL；相对路径：`gen/seeders` → `internal/store/database/seeders`；支持 `_part2`。 |

SQL 中 **`{{prefix}}`** 在 `up` / `seed` / `import-sql` 中替换为 **`DB_PREFIX`**。

| 选项 | 适用 | 说明 |
|------|------|------|
| `--force` | `dump` | 覆盖已存在文件。 |
| `--prefix` | `dump` | 表前缀（默认 `DB_PREFIX`）。 |
| `--filename` | `dump` | 输出文件名主体（默认 `all_tables`，实际带时间戳）。 |
| `--out-dir` | `dump` | 默认 `<root>/gen/migrations`。 |
| `--plugin-root` | `dump` | 识别插件表并排除（默认 `plugin/`）。 |
| `--skip-errors` | `import-sql` | 单条失败继续。 |
| `--transaction` | `import-sql` | 整体事务（默认 `true`）。 |
| `--batch-size` | `import-sql` | 进度打印间隔（默认每 100 条）。 |

示例：`migrate up internal/store/database`、`migrate seed …`、`migrate up plugin/ds/foo/database`、`migrate dump`、`migrate import-sql path/to.sql`。

## gen — 代码生成

管理端 CRUD 子命令为 **`crud`**（**`curd`** 为同一别名）。

| 子命令 | 说明 |
|--------|------|
| `gen model` | 表 → GORM model；全量 CRUD 用 **`gen crud`**。 |
| `gen crud` | Go、model（默认路径）、前端、菜单 SQL 文件、snippets；路由自动追加；**`--sql`** 才执行菜单入库。见 [代码生成器](code-generator.md#gen-crud-manual-steps)。 |
| `gen seeders` | 核心表 → `INSERT` SQL（可分片）。 |

DDL / 导入 SQL → [migrate](#migrate)。

| 选项 | 适用 | 说明 |
|------|------|------|
| `--table` | `model`（必填）、`crud` | 表名，**不含** `DB_PREFIX`。 |
| `--out` | `model` | 输出 `.go`；默认 `gen/model/{Struct}_gen.go`；**`-`** 为 stdout。 |
| `--package` | `model` | 覆盖 `package`。 |
| `--force` | `model`、`crud`、`seeders` | 覆盖已有文件。 |
| `--module` | `crud` | admin 模块目录名；插件模式可空。 |
| `--plugin` | `crud` | 如 `ds/sysCms`。 |
| `--admin-root` | `crud` | 默认 `<repo>/admin` 兄弟目录。 |
| `--http-prefix` | `crud` | 如 `/admin/search/keyword`。 |
| `--sql` | `crud` | 生成后执行菜单 SQL（**默认不执行**；核心与插件均可）。 |
| `--pid` | `crud` | 菜单 `parent_id`。 |
| `--model-out` | `crud` | 覆盖默认 model 路径；不设则核心→`internal/app/model/<表>.go`，插件→`plugin/…/src/model/<表>.go`。 |
| `--skip-front` | `crud` | 只生成 Go + SQL + 片段。 |
| `--skip-go` | `crud` | 只生成前端 + SQL + 片段。 |
| `--model-alias` | `crud` | 插件 model import 别名（默认 `plugmodel`）。 |
| `--go-out` | `crud` | 覆盖 Go handler 路径。 |
| `--prefix` | `seeders` | 表前缀（默认 `DB_PREFIX`）。 |
| `--filename` | `seeders` | 默认 `all_data`。 |
| `--out-dir` | `seeders` | 默认 `<root>/gen/seeders`。 |
| `--plugin-root` | `seeders` | 排除插件表。 |
| `--limit` | `seeders` | 每表最大行数（默认 1000）。 |
| `--chunk-size` | `seeders` | 单文件约上限 MB（默认 10）。 |

细节见 [代码生成器](code-generator.md#gen-crud-manual-steps)。

## ws — WebSocket / Redis 运维

需 Redis，键约定见 [redis_contract.md](../internal/websocket/redis_contract.md)。

| 子命令 | 说明 |
|--------|------|
| `ws stats` | 连接统计 JSON。 |
| `ws fix-stats` | 修正 `ws:stats:total` 与连接集合长度。 |
| `ws list` | 连接详情分页 JSON。 |
| `ws clear` | 清空 WS 相关 Redis 键（危险）；须 **`--yes`**。 |
| `ws online <ids>` | 逗号分隔用户 ID，是否在线。 |

| 选项 | 适用 | 说明 |
|------|------|------|
| `--yes` | `clear` | 确认执行。 |
| `--page` | `list` | 页码（默认 1）。 |
| `--page-size` | `list` | 每页条数（默认 20）。 |
| `--user` | `list` | 仅该用户 ID 或访客 `bind_key`。 |

## 相关文档

[插件](plugins.md) · [代码生成器](code-generator.md)
