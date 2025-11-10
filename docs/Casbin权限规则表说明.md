# Casbin 权限规则表说明

## 当前项目状态

- ✅ 已创建 `rules` 表（Casbin权限规则表）
- ❌ **当前未实际使用 Casbin**
- ✅ 当前使用的是基于菜单和角色的权限系统（RBAC）

**当前权限系统**：
- **用户** ↔ **角色** ↔ **菜单**（功能权限）
- **角色** ↔ **数据范围**（数据权限）
- 通过 `PermissionMiddleware` 中间件进行权限验证

## Rules 表结构说明

```sql
CREATE TABLE `rules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ptype` varchar(255) DEFAULT NULL COMMENT '策略类型（p=策略，g=角色继承）',
  `v0` varchar(255) DEFAULT NULL COMMENT '规则参数0',
  `v1` varchar(255) DEFAULT NULL COMMENT '规则参数1',
  `v2` varchar(255) DEFAULT NULL COMMENT '规则参数2',
  `v3` varchar(255) DEFAULT NULL COMMENT '规则参数3',
  `v4` varchar(255) DEFAULT NULL COMMENT '规则参数4',
  `v5` varchar(255) DEFAULT NULL COMMENT '规则参数5',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ptype` (`ptype`),
  KEY `idx_ptype_v0` (`ptype`,`v0`),
  KEY `idx_ptype_v0_v1` (`ptype`,`v0`,`v1`)
) COMMENT='Casbin权限规则表';
```

### 字段说明

**ptype（策略类型）**：
- `p`：策略（Policy），定义权限规则
- `g`：角色继承（Group），定义角色继承关系

**v0-v5（规则参数）**：

| 模型 | ptype | v0 | v1 | v2 | v3-v5 |
|------|-------|----|----|----|-------|
| **ACL** | p | 用户/角色 | 资源 | 操作 | - |
| **RBAC** | p | 角色 | 资源 | 操作 | - |
| **RBAC** | g | 用户 | 角色 | - | - |
| **ABAC** | p | 用户 | 资源 | 操作 | 属性条件 |

## 如何使用 Casbin

### 安装和配置

1. **安装依赖**：
```bash
composer require casbin/casbin hyperf/casbin
```

2. **创建模型文件** `config/rbac_model.conf`：
```ini
[request_definition]
r = sub, obj, act
[policy_definition]
p = sub, obj, act
[role_definition]
g = _, _
[policy_effect]
e = some(where (p.eft == allow))
[matchers]
m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act
```

3. **配置 Casbin** `config/autoload/casbin.php`：
```php
return [
    'default' => [
        'model' => BASE_PATH . '/config/rbac_model.conf',
        'adapter' => \Hyperf\Casbin\Adapter\DatabaseAdapter::class,
    ],
];
```

### 使用示例

```php
use Casbin\Enforcer;

$enforcer = make(Enforcer::class);

// 添加权限规则
$enforcer->addPolicy('admin', 'data1', 'read');
$enforcer->addGroupingPolicy('alice', 'admin');

// 权限检查
if ($enforcer->enforce('alice', 'data1', 'read')) {
    // 允许访问
}
```

## 两种权限系统对比

| 特性 | 当前 RBAC 系统 | Casbin 系统 |
|------|--------------|------------|
| **优点** | 简单直观、已完整实现、支持数据权限、性能优化 | 支持多种模型、灵活的权限规则、复杂的权限策略表达式 |
| **缺点** | 权限规则较为固定、难以实现复杂策略 | 学习成本较高、需要额外配置、与现有系统集成需要重构 |
| **状态** | ✅ 已实现并优化 | ❌ 未使用 |

## 建议

### 方案一：保留 Rules 表，暂不使用（推荐）

**理由**：当前权限系统已满足需求，避免不必要的复杂性，保留未来扩展的可能性

**操作**：保留 `rules` 表结构，暂时不集成 Casbin

### 方案二：移除 Rules 表

**理由**：当前不使用，避免混淆，简化数据库结构

**操作**：创建迁移文件删除 `rules` 表

### 方案三：集成 Casbin（未来扩展）

**适用场景**：
- 需要实现复杂的权限策略（基于时间、IP、属性的权限控制）
- 需要支持多种访问控制模型
- 权限规则需要频繁变更

**实施步骤**：按照"如何使用 Casbin"章节进行集成，与现有权限系统并行运行（渐进式迁移）

## 总结

- **当前状态**：`rules` 表已创建但未使用
- **建议**：保留表结构，暂不集成 Casbin，如未来需要复杂权限控制再考虑
- **当前权限系统**：基于菜单和角色的 RBAC 系统已满足大部分需求

## 参考资料

- [Casbin 官方文档](https://casbin.org/)
- [Hyperf Casbin 组件](https://github.com/hyperf/casbin)

