# AI 辅助开发流程指南

> 📚 **快速导航**：[AI 能力边界](#ai-能力边界) | [开发流程](#ai-开发流程) | [代码生成器](#使用代码生成器) | [最佳实践](#最佳实践)
>
> 📖 **相关文档**：[AI开发提示词模板](./AI开发提示词模板.md)

本文档说明如何利用 AI 基于 FastApp 开发文档来实现各种功能。

## ⚡ AI 能力边界

### ✅ AI 能力

**可以做什么**：
- 阅读分析文档、生成代码、优化重构、检查规范

**自动执行**：
- 代码生成器命令、数据库 SQL、菜单 SQL

**协作流程**：生成 → 执行 → 验证 → 后续操作

---

## 🚀 AI 开发流程

### 一、理解阶段

AI 会读取和分析项目文档：

**核心文档**（必读）：
- `docs/README.md` - 文档导航
- `docs/getting-started/项目结构.md` - 项目目录结构
- `docs/development/开发规范.md` - 代码规范和开发模式
- `docs/getting-started/快速开始.md` - 项目安装和基础配置

**功能文档**（按需阅读）：
- `docs/features/代码生成器.md` - 代码生成器使用方式
- `docs/features/插件系统使用指南.md` - 插件开发方式
- `docs/permission/权限系统使用文档.md` - 权限系统使用方式

**代码结构**：
- 分层：Controller → Service → Repository → Model
- 命名：UserController → UserService → UserRepository → User
- 路由：`/api/模块/功能` 或 `/admin/模块/功能`

**开发模式**：
- **Admin**：继承 `App\Http\Admin\Controller\AbstractController`，使用 `PermissionMiddleware`
- **API**：继承 `App\Common\AbstractController`，使用 `TokenMiddleware`

### 二、规划阶段

#### 需求分析

AI 会：
1. 理解业务需求（提取功能点、识别数据模型）
2. 技术选型（Admin/API 模式、权限控制、数据权限）
3. 依赖分析（需要的服务类、Repository、Model）

#### 判断是否需要代码生成器

**需要使用代码生成器**：
- ✅ 需要创建新的数据库表 + 完整 CRUD
- ✅ 需要前端页面（Admin 模式）
- ✅ 需要标准化的代码结构

**不需要使用代码生成器**：
- ❌ 扩展已有功能
- ❌ 单个接口开发
- ❌ WebSocket、工具类等非数据库功能

**判断流程**：新数据库表 + 完整 CRUD → ✅ 使用代码生成器 | 扩展已有功能 → ❌ 不使用

#### 开发计划制定

**使用代码生成器**：设计表结构 → 执行 SQL → 执行代码生成器 → 添加业务逻辑 → 配置权限 → 优化代码

**不使用代码生成器**：分析现有代码 → 添加方法 → 优化代码

---

### 三、代码生成阶段

#### 数据库设计

AI 会根据需求生成数据库表结构：

**字段注释格式**：`字段说明[验证规则,其他规则]`，如 `产品名称[required,search]`、`状态 0=下架,1=上架`

**表结构要求**：
- ✅ 表名蛇形命名，主键 `id`（bigint(20) unsigned）
- ✅ 包含 `created_at`、`updated_at`，数据权限需 `created_by`
- ✅ 字段注释包含验证规则

#### 使用代码生成器

**重要前提**：代码生成器需要先执行 SQL 创建表，因为代码生成器会读取表结构来生成代码。

**AI 自动执行流程**：判断需求 → 执行 SQL → 执行代码生成器 → 验证文件 → 添加数据权限和业务逻辑 → 执行菜单 SQL

**代码生成器流程**：读取表结构 → 生成 JSON 配置 → 生成后端代码 → Admin 模式生成前端和菜单 SQL

**生成文件位置**：
- 后端：`app/Http/Admin|Api/{Controller,Service}/{Module}/`
- 前端（仅Admin）：`web/src/modules/{module}/views/{tableName}/`
- 菜单SQL（仅Admin）：`runtime/sql/{TableName}Menu.sql`

**注意**：Service 默认不包含数据权限，AI 会自动添加；菜单 SQL 自动执行或使用 `--sql=true`

#### 自定义业务逻辑

代码生成器生成基础代码后，AI 会补充业务逻辑（Service/Repository 层）。

**数据权限应用方式**：

**方式一：Service 层（推荐）**
```php
use App\Http\Admin\Service\Permission\DataScopeTool;
use App\Repository\IRepository;

public function page(array $params, int $page = 1, int $pageSize = 10): array
{
    $query = $this->repository->getQuery();
    DataScopeTool::applyUserDataScope(0, $query);
    $query = $this->repository->perQuery($query, $params);
    $result = $query->paginate(
        perPage: $pageSize,
        pageName: IRepository::PER_PAGE_PARAM_NAME,
        page: $page,
    );
    return $this->repository->handlePage($result);
}
```

**方式二：Repository 的 handleSearch**
```php
use App\Http\Admin\Service\Permission\DataScopeTool;
use App\Repository\IRepository;
use Hyperf\Collection\Arr;
use Hyperf\Database\Model\Builder;

public function handleSearch(Builder $query, array $params): Builder
{
    if (Arr::has($params, 'created_by')) {
        DataScopeTool::applyUserDataScope($params['created_by'], $query);
        unset($params['created_by']); // ⚠️ 必须移除
    }
    return parent::handleSearch($query, $params); // ⚠️ 必须调用父类
}
```

**常见错误**：
- ❌ Repository 中处理参数后未 `unset` 或未调用 `parent::handleSearch()`
- ❌ 使用 `$this->model->newQuery()` 或 `$this->repository->model->newQuery()` 而不是 `getQuery()`
- ❌ 手动调用 `handleSearch()` 而不是使用 `perQuery()`

---

### 四、代码验证和优化

#### 代码验证和优化

**验证**：语法正确性、命名规范、代码分层、注解使用、功能完整性

**优化**：
- 权限控制：`#[Permission(code: 'product:product:list')]`
- 数据权限：Service 层使用 `DataScopeTool::applyUserDataScope(0, $query)`
- 响应格式：`$this->success($data, '操作成功')`
- 性能：避免 N+1 查询、使用索引、合理缓存

---

## ✨ 最佳实践

1. **从文档开始**：让 AI 先理解文档
2. **使用代码生成器**：优先使用代码生成器生成基础代码
3. **引用现有代码**：参考现有代码，让 AI 理解代码风格
4. **分步骤验证**：复杂任务分解为多个步骤，每步验证
5. **明确规范**：明确指定 Admin 或 API 模式
6. **执行顺序**：AI 自动先创建表，再执行代码生成器
7. **权限格式**：使用正确格式（`module:table:action`）
8. **数据权限**：在 Service 层应用，AI 会自动添加
9. **菜单 SQL**：AI 自动执行或使用 `--sql=true`
10. **验证代码**：每步完成后 AI 自动验证

---

## ⚠️ 常见陷阱避免

| 陷阱 | 错误做法 | 正确做法 |
|------|---------|---------|
| 插件类型参数 | `--type=mixed` | `--type=mix`（使用枚举键名） |
| 表结构格式 | 字段注释格式不正确 | 使用 `[required,search]` 格式 |
| 模块名大小写 | `--module=Product` | `--module=product`（小写） |
| 数据权限应用 | 在 Repository 层应用 | 在 Service 层应用 |
| 数据权限实现 | 使用 `$this->model->newQuery()` 或 `$this->repository->model->newQuery()` | 使用 `getQuery()` |
| 搜索条件处理 | 手动调用 `handleSearch()` | 使用 `perQuery()` 统一处理 |
| 权限代码格式 | `product.product.list` | `product:product:list` |
| 响应格式 | 直接返回数组 | 使用 `$this->success($data, $message)` |

