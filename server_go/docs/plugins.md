# 插件体系

仅 **`plugin/{组织}/{插件}/`** 两级（如 `plugin/ds/sysConfig`）。逻辑名 = 相对路径；**无根 `config.json`**，元数据在根 **`config.go`** 常量。

## 依赖方向（强制）

**仅允许 `fastapp/plugin` → 插件树**。插件**禁止** `import "fastapp/plugin"`。  
HTTP/WS 登记只在 **[`plugin/plugin.go`](../plugin/plugin.go)** 的 **`init`** + [`registry.go`](../plugin/registry.go)。  
根 **`config.go`**：仅常量，**无 `init`**、不 import 宿主。

## 运行期挂载条件

`LoadInstalled` 要求根目录同时具备 **`config.go`** + **`install.lock`**。  
编译期还须 **[`plugin.go`](../plugin/plugin.go)** **`RegisterHTTPEndpoints` / `RegisterWebSocket`**，否则**不挂路由**。  
**`cmd/server`** 只 **`import fastapp/plugin`**（Go 无法按目录动态 import）。

<a id="plugin-load-runtime"></a>

### 加载顺序（简）

1. 包加载：`plugin.go` 各插件 **`init`** → 写入 registry。
2. **`main`**：`LoadInstalled` → `LoadPluginI18n`（有 `config.go` 即可合并 **`src/locales`**，**不要**求 `install.lock`）。
3. HTTP：**`HTTPEndpoints(loaded)`** 按 `loaded` 顺序追加；交给 **`router.New`**。
4. WS：**`BindingWS(loaded)`** 同序注册 action。

**设计要点**：`install.lock` 区分「有代码」/「本环境已装」；`loaded` 顺序为目录遍历序；`plugin.go` import 的代码会进二进制，未装只运行时不挂路由。

### 开发约定

- HTTP：逻辑在 **`src/http/*.go`**，表在 **`routes.go`** 的 **`Endpoints()`**。
- WS：逻辑在 **`src/websocket/`**，登记集中在 **`RegisterWebSocket(reg)`**（如 **`register_ws.go`**）。
- **勿**在 websocket 子包 **`init`** 里调宿主登记。

根目录允许文件：**`config.go`**、**`install.lock`**、可选 **`readme.md`**、**`publish.json`**（给 **`plugin script`**）。

**CLI** → [cli.md#plugin-cli](cli.md#plugin-cli)（`install` / `uninstall` / `create` / `sync-admin` / `script`）。

<a id="plugin-menu-names"></a>

## 菜单 `menu.name`（`MenuPerm`、`plugin uninstall`）

规则同 **[`pluginMenuNamePrefix`](../internal/cli/migrate_cmd.go)**：路径 **`org/plugin`** → 前缀 **`org:plugin`**（**`/` → `:`**，段内大小写与目录一致）。  
卸载按 **`menu.name LIKE '{前缀}%'`** 清关联与菜单；再按 migrations 逆序 **DROP**。

**`Endpoint.MenuPerm`** 必须与 **`menu.name`** 完全一致。种子 SQL 里插件菜单名须带正确前缀，否则 uninstall 删不全。

**`gen crud --plugin=…`**：`PermPrefix` = `{前缀}:{资源snake}`，子权限 **`:list`** 等 → [代码生成器](code-generator.md#gen-crud-plugin-menu)。

## 数据库

**`database/migrations/`**、**`seeders/`**。`{{prefix}}` → **`DB_PREFIX`**。  
**`plugin install`**：migrations → seeders → **`install.lock`**。**`plugin uninstall`**：菜单 + 逆序 DROP + 删 lock。仅跑 SQL 可用 **[migrate](cli.md#migrate-cli)**。

seeders 建议：`*_menu.sql`、`*_config.sql`（`system_config` 等须 `NOT EXISTS`）、`*_data.sql`。

## 与核心路由

合并规则 → [HTTP · 路由](http.md#routing)。
