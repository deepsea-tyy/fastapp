# 代码生成器

细则与全部参数见 **[命令行 · gen](cli.md#gen--代码生成)**；**`migrate` / SQL** 见 **[命令行 · migrate](cli.md#migrate)**。

## 子命令

| 子命令 | 作用 | 示例 |
|--------|------|------|
| **`gen model`** | 表 → GORM model | `gen model --table=user`；`--out internal/app/model/x.go` |
| **`gen crud`** | Go、**默认路径 model**、前端、菜单 SQL 文件、snippets；**路由尾部自动追加**；**`--sql`** 才执行菜单 SQL | `gen crud --table=keyword --module=search`；插件加 `--plugin=ds/sysCms`（**`curd`** 同义） |
| **`gen seeders`** | 核心表数据导出为 INSERT SQL | `gen seeders --limit=1000` |

## 模板

- Model：`internal/cli/templates/model.go.tmpl`
- CRUD：`internal/cli/templates/crud/`

<a id="gen-crud-manual-steps"></a>

## `gen crud` 一条命令内做掉的事

（插件仅需自行 **`plugin install` / `uninstall`**；无需再手改 `Endpoints()` 或宿主登记。）

| 自动化项 | 行为 |
|----------|------|
| **路由注册（源码）** | **是**：在 [`internal/app/router/endpoints.go`](../internal/app/router/endpoints.go) 或 **`plugin/…/src/http/routes.go`** 里，向 **`Endpoints()` 的 `return []…` 切片尾部追加**本表 4 条路由；插件若无 `routes.go` **自动生成**该文件后再写入。若本次 `GET …/list` 的 `Path` 已在文件中存在则**跳过追加**。**`--skip-go`** 时不改路由文件。 |
| **插件 HTTP 宿主登记** | **是**（与上一行同为 `--skip-go` 时跳过）：在 [`plugin/plugin.go`](../plugin/plugin.go) 的 `import` 与 `init()` 中追加 **`RegisterHTTPEndpoints(<config 包>.PluginName, <src/http>.Endpoints)`**（按 `config.go` 与 `src/http` 的包名解析；已登记同一插件则跳过）。 |
| **Model** | **是**（默认路径）：核心 `internal/app/model/<表>.go`，插件 `plugin/…/src/model/<表>.go`；文件已存在且未 **`--force`** 则跳过覆盖。**`--model-out`** 可改路径。 |
| **Go handler / 前端 / snippets / 菜单 SQL 文件** | **是**（照常生成到约定目录）。 |
| **菜单数据入库** | **否（默认）**：不加 **`--sql`** 则**不执行** SQL；加 `--sql` 才执行当次生成的 `*_menu.sql`。 |

前端默认写在 **与 `server_go` 同级的 `admin`**（`--admin-root` 可改）。

<a id="gen-crud-plugin-menu"></a>

**插件菜单 `name` / 卸载前缀**：与 `MenuPerm` 须一致，见 **[插件 · 菜单 name](plugins.md#plugin-menu-names)**。
