# AI 开发提示词模板

> 📚 **快速导航**：[使用说明](#使用说明) | [模板分类](#模板分类) | [常见问题](#常见问题) | [快速参考](#快速参考表)
>
> 📖 **相关文档**：[AI辅助开发流程指南](./AI辅助开发流程指南.md)

本文档提供可直接使用的 AI 提示词模板。

## 📖 使用说明

1. **选择模板**：根据需求选择合适的模板
2. **复制模板**：复制整个模板内容
3. **填充变量**：将 `{变量名}` 替换为实际值
4. **发送给 AI**：直接使用模板与 AI 对话

### 变量说明

| 变量 | 说明 | 示例 |
|------|------|------|
| `{模块名}` | 功能模块名称（小写） | `product`、`user` |
| `{table}` | 数据库表名（蛇形命名） | `products`、`users` |
| `{organization}/{plugin}` | 插件标识 | `ds/article` |

## ⚡ AI 能力边界

**AI 可以做什么**：
- ✅ 自动执行：代码生成器命令、数据库 SQL、菜单 SQL
- ✅ 生成代码：PHP、SQL、配置文件等
- ✅ 验证和优化：语法检查、规范验证、代码优化

**AI 判断逻辑**：
- ✅ 使用代码生成器：新数据库表 + 完整 CRUD
- ❌ 不使用代码生成器：扩展已有功能、单个接口、WebSocket 等

## 📚 模板分类

| 场景 | 模板编号 | 跳转 |
|------|---------|------|
| 首次使用 AI | 1.1 | [让 AI 理解项目](#模板-11让-ai-理解项目) |
| 功能需求分析 | 1.3 | [功能需求分析](#模板-13功能需求分析) |
| Admin CRUD | 2.1 | [完整 CRUD（Admin 模式）](#模板-21完整-crudadmin-模式) |
| API CRUD | 2.2 | [完整 CRUD（API 模式）](#模板-22完整-crudapi-模式) |
| 插件开发 | 3.1 | [创建新插件](#模板-31创建新插件) |
| WebSocket | 4.1 | [开发 WebSocket](#模板-41开发-websocket) |
| 数据权限 | 6.3 | [添加数据权限](#模板-63添加数据权限) |
| 快速开发 | 10.1 | [快速 CRUD](#模板-101快速-crud) |

---

### 一、初始化模板

#### 模板 1.1：让 AI 理解项目

```
请先阅读以下文档，理解 FastApp 框架的开发规范：

1. docs/README.md - 文档导航
2. docs/getting-started/项目结构.md - 项目结构
3. docs/development/开发规范.md - 开发规范
4. docs/getting-started/快速开始.md - 快速开始指南
5. docs/development/AI辅助开发流程指南.md - AI开发流程

阅读完成后，请确认已理解：
- 代码分层架构（Controller → Service → Repository → Model）
- Admin 模式和 API 模式的区别
- 代码生成器的使用方式

然后告诉我你已经准备好开始开发了。
```

#### 模板 1.3：功能需求分析

```
我需要开发以下功能：

{功能需求描述}

请按照以下流程处理：

1. **需求分析**：分析功能需求，确定是否需要数据库表和完整 CRUD
2. **判断是否需要代码生成器**：
   - 如果需要新数据库表 + 完整 CRUD → ✅ 使用代码生成器
   - 如果只是扩展已有功能 → ❌ 不使用代码生成器
3. **如果需要代码生成器**：
   - 设计数据库表结构，生成 CREATE TABLE SQL
   - 自动执行 SQL 创建表
   - 自动执行代码生成器命令
   - 验证生成的文件，自动添加数据权限和业务逻辑
4. **如果不需要代码生成器**：直接生成代码

请开始分析并给出判断结果。
```

---

### 二、CRUD 功能开发模板

#### 模板 2.1：完整 CRUD（Admin 模式）

```
我需要开发一个 {模块名} 管理功能：

**需求：**
- 列表查询（分页、搜索、筛选）
- 新增、编辑、删除
- {其他功能}

**技术要求：**
- Admin 模式
- 权限控制（PermissionMiddleware）
- 数据权限（按部门）
- 遵循 FastApp 开发规范

**AI 处理流程：**
1. 设计数据库表结构（字段注释格式：`字段说明[required,search]`，枚举值：`状态 0=禁用,1=启用`）
2. 自动执行 SQL 创建表
3. 自动执行代码生成器命令：`php bin/hyperf.php ds:generate-crud --table={table} --module={module} --pid={pid}`
4. 验证生成的文件完整性
5. 自动在 Service 层添加数据权限（`DataScopeTool::applyUserDataScope(0, $query)`）
6. 自动执行菜单 SQL（或使用 `--sql=true`）

**重要提示：**
- 权限代码格式：`{module}:{table}:{action}`
- 数据权限在 Service 层应用，AI 会自动添加

请按照流程执行。
```

#### 模板 2.2：完整 CRUD（API 模式）

```
我需要开发一个 {模块名} API 接口：

**需求：**
- GET /api/{模块名}/list - 列表查询
- POST /api/{模块名}/create - 创建
- PUT /api/{模块名}/save/{id} - 更新
- DELETE /api/{模块名}/delete - 删除（支持单个或批量删除）
  - 请求体：直接数组格式 `[1, 2, 3]`，不是对象格式
  - Swagger 注解：`#[RequestBody(content: new JsonContent(type: 'array', items: new OA\Items(type: 'integer'), example: '[1, 2, 3]'))]`
  - 实现：`$this->service->deleteById($this->getRequestData(), [])`

**技术要求：**
- API 模式（--target=api）
- JWT Token 认证
- 继承 `App\Common\AbstractController`
- 使用 `TokenMiddleware`

**开发步骤：**
1. 设计数据库表结构并自动执行 SQL 创建表
2. 自动执行代码生成器命令：`php bin/hyperf.php ds:generate-crud --table={table} --module={module} --target=api`
3. 验证生成的文件完整性

**重要提示：**
- API 模式只生成后端代码，不生成前端代码和菜单 SQL
- 路由路径：`/api/{module}/{table}/{action}`
```

---

#### 模板 2.3：扩展已有 CRUD 功能

```
现有 {模块名} 模块已通过代码生成器生成了基础 CRUD 代码，现在需要添加以下功能：

**新增功能：**
- {功能1描述}
- {功能2描述}

**参考文件：**
- Controller: {控制器路径}
- Service: {服务类路径}

**要求：**
- 遵循现有代码风格
- 添加权限控制（权限代码格式：`{module}:{table}:{action}`）
- 添加 Swagger 注解
- 如需数据权限，在 Service 层添加

请分析现有代码结构，然后添加新功能。
```

---

### 三、插件开发模板

#### 模板 3.1：创建新插件

```
我需要创建一个新的插件：

**插件信息：**
- 插件名称：{插件名}
- 插件标识：{organization}/{plugin}
- 插件类型：{mix/frond/backend}
  - `mix` - 混合类型（包含前后端）
  - `frond` - 前端类型（仅前端代码）
  - `backend` - 后端类型（仅后端代码）

**开发步骤：**
1. 自动执行插件创建命令：`php bin/hyperf.php plugin:create {organization}/{plugin} --name="{插件名}" --type=mix --description="{描述}" --author="{作者}"`
2. 验证插件目录结构
3. 生成数据库迁移文件（如需要）

**注意事项：**
- `--type` 参数值：`mix`（混合）、`frond`（前端）、`backend`（后端），必须使用枚举键名
```

#### 模板 3.2：在插件中生成 CRUD

```
我需要在插件 {organization}/{plugin} 中生成 {模块名} 的 CRUD 代码：

**表结构：**
{table_structure_sql}

**开发步骤：**
1. 自动执行 SQL 创建表
2. 自动执行代码生成器命令：`php bin/hyperf.php ds:generate-crud --table={table} --module={module} --plugin={organization}/{plugin}`
3. 验证生成的文件完整性
4. 自动在 Service 层添加数据权限逻辑

**重要提示：**
- 权限代码格式：`{plugin_path}:{table_name}:{action}`（如 `ds/article` → `ds:article:article:list`）
- 插件路径中的 `/` 会被转换为 `:`
```

---

### 四、WebSocket 开发模板

#### 模板 4.1：开发 WebSocket

```
我需要开发一个 WebSocket 功能：

**功能需求：**
- Action: {action_name}
- 功能描述：{功能描述}
- 参数：{参数说明}
- 返回：{返回数据说明}

**开发步骤：**
1. 阅读 docs/WebSocket开发文档.md
2. 创建 WebSocket 消息处理器类
3. 实现 WsMessageHandlerInterface 接口
4. 实现处理方法（使用 protected 访问修饰符）
5. 注册 Action 映射
6. 返回 WsResponse 格式的响应

请按照步骤执行。
```

---

### 六、业务逻辑开发模板

#### 模板 6.3：添加数据权限

```
我需要在 {ServiceClass} 的查询方法中添加数据权限：

**方法：** {方法名}（通常是 `page()` 方法）

**实现方式（推荐）：**
```php
public function page(array $params, int $page = 1, int $pageSize = 10): array
{
    $query = $this->repository->getQuery();
    
    // 应用数据权限过滤（按部门）
    DataScopeTool::applyUserDataScope(0, $query);
    
    // 应用搜索条件和排序
    $query = $this->repository->perQuery($query, $params);
    
    // 分页查询
    $result = $query->paginate(
        perPage: $pageSize,
        pageName: 'per_page',
        page: $page,
    );
    
    return $this->repository->handlePage($result);
}
```

**注意事项：**
- 使用 `$this->repository->getQuery()` 而不是 `model()->newQuery()`
- 使用 `perQuery()` 统一处理搜索和排序
- 先应用数据权限，再应用搜索条件和排序
- 参数 `0` 表示使用当前登录用户

请添加数据权限逻辑。
```

---

### 十、快速开发模板

#### 模板 10.1：快速 CRUD

```
快速开发 {模块名} CRUD 功能：

表结构：
```sql
{table_structure_sql}
```

要求：
- Admin 模式
- 基础 CRUD 功能
- 权限控制
- 数据权限（按部门）

**执行步骤：**
1. 自动执行 CREATE TABLE SQL 创建表
2. 自动执行代码生成器命令
3. 验证生成的文件完整性
4. 自动在 Service 层添加数据权限
5. 自动执行菜单 SQL（或使用 `--sql=true`）
```

#### 模板 10.2：快速 API

```
快速开发 {模块名} API 接口：

表结构：
```sql
{table_structure_sql}
```

要求：
- API 模式（--target=api）
- 基础 CRUD 接口
- JWT 认证

**执行步骤：**
1. 自动执行 CREATE TABLE SQL 创建表
2. 自动执行代码生成器命令：`php bin/hyperf.php ds:generate-crud --table={table} --module={module} --target=api`
3. 验证生成的文件完整性
```

---

## 📋 快速参考表

### 命令快速参考

| 操作 | 命令 |
|------|------|
| **代码生成器** | `php bin/hyperf.php ds:generate-crud --table={table} --module={module}` |
| **插件创建** | `php bin/hyperf.php plugin:create {org}/{plugin} --type=mix` |
| **语法检查** | `php -l {file}` |

### 权限代码格式

| 模式 | 格式 | 示例 |
|------|------|------|
| **普通模式** | `{module}:{table}:{action}` | `product:product:list` |
| **插件模式** | `{plugin_path}:{table_name}:{action}` | `ds:article:article:list`（插件 `ds/article`，表 `article`） |

**注意**：插件路径中的 `/` 会被转换为 `:`（如 `ds/gift-card` → `ds:gift-card`）

### 插件类型参数

| 类型 | 参数值 | 说明 |
|------|--------|------|
| **混合类型** | `mix` | 包含前后端代码 |
| **前端类型** | `frond` | 仅前端代码 |
| **后端类型** | `backend` | 仅后端代码 |

**重要**：必须使用枚举键名（`mix`、`frond`、`backend`），不是全称

### 数据权限实现

```php
// ✅ 正确方式
public function page(array $params, int $page = 1, int $pageSize = 10): array
{
    $query = $this->repository->getQuery();
    DataScopeTool::applyUserDataScope(0, $query);
    $query = $this->repository->perQuery($query, $params);
    // ...
}

// ❌ 错误方式
public function page(array $params, int $page = 1, int $pageSize = 10): array
{
    $query = $this->repository->model()->newQuery(); // ❌ 错误
    $query = $this->repository->handleSearch($query, $params); // ❌ 错误
    // ...
}
```

---

## ❓ 常见问题

| 问题 | 答案 |
|------|------|
| **如何让 AI 理解项目结构？** | 使用模板 1.1，让 AI 先阅读文档 |
| **如何快速开发 CRUD？** | 使用模板 10.1 或 10.2，提供表结构即可 |
| **权限代码格式是什么？** | 普通模式：`{module}:{table}:{action}`，插件模式：`{plugin_path}:{table_name}:{action}` |
| **数据权限在哪里应用？** | Service 层，使用 `DataScopeTool::applyUserDataScope(0, $query)` |
| **代码生成器执行前需要做什么？** | AI 会自动执行 CREATE TABLE SQL 创建表 |
| **菜单 SQL 会自动执行吗？** | 会，AI 会自动执行菜单 SQL 或使用 `--sql=true` |
| **代码生成器生成的 Service 是否包含数据权限？** | 不包含，AI 会自动添加 |
| **AI 会自行调用代码生成器吗？** | 会，AI 会自动执行代码生成器命令 |

---

## 📖 更多信息

> 📚 **相关文档**：
> - [AI辅助开发流程指南](./AI辅助开发流程指南.md) - 详细的开发流程和原理说明
> - [最佳实践](./AI辅助开发流程指南.md#最佳实践) - 开发最佳实践
> - [常见陷阱避免](./AI辅助开发流程指南.md#常见陷阱避免) - 常见错误和正确做法

