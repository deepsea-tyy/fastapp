# 代码生成器

参数总表 → **[CLI · gen](cli.md#gen-cli)**；**`migrate` / SQL** → **[CLI · migrate](cli.md#migrate-cli)**。

## 子命令

| 命令 | 作用 |
|------|------|
| **`gen model`** | 表 → GORM model |
| **`gen crud`**（**`curd`**） | model、handler、前端、菜单 SQL、snippets；**路由源码尾部追加**；**默认不执行**菜单 SQL（加 **`--sql`**） |
| **`gen seeders`** | 核心表 → INSERT SQL |

模板：`internal/cli/templates/model.go.tmpl`、`internal/cli/templates/crud/`。

<a id="gen-crud-manual-steps"></a>

## `gen crud` 自动项

执行本命令时（非 **`--skip-go`**）会自动：

| 项 | 行为 |
|----|------|
| **路由** | 在 [`endpoints.go`](../internal/app/router/endpoints.go) 或 **`plugin/…/src/http/routes.go`** 的 **`Endpoints()`** 尾部追加 CRUD 四条；`list` Path 已存在则跳过；无 `routes.go` 则生成 |
| **宿主登记** | 在 [`plugin/plugin.go`](../plugin/plugin.go) 追加 **`RegisterHTTPEndpoints`**（已登记则跳过） |
| **model / handler / 前端 / SQL 文件** | 按约定目录生成 |

**手工**加接口仍须自行改 **`endpoints` / `routes.go`** 与 **`plugin.go`**。菜单数据默认不落库，**`--sql`** 才执行当次 `*_menu.sql`。

前端默认 **`server_go` 兄弟目录 `admin`**（**`--admin-root`** 可改）。

<a id="gen-crud-plugin-menu"></a>

插件菜单前缀与 **`MenuPerm`** → [插件 · menu.name](plugins.md#plugin-menu-names)。
