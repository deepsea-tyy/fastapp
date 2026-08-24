# FastApp Code Wiki

> 代码知识库导航。全局架构文档位于 `code/`，Story Studio 插件的编码链路分析位于 `server/plugin/ds/storyStudio/docs/code/`。

---

## 全局架构

| 文档                                   | 覆盖内容 |
|--------------------------------------|---|
| [01-项目概述与整体架构](code/01-项目概述与整体架构.md) | 项目定位、五大子目录（server/admin/desktop/website/tools）、架构分层图、技术栈速查 |
| [02-后端架构](code/02-后端架构.md)           | 依赖与环境、启动命令、目录结构、HTTP 请求处理链路（Controller→Service→Repository→Model）、命名规范、JWT/中间件/RBAC 认证链、WebSocket 基类、插件安装链路、关键文件索引 |
| [03-前端架构](code/03-前端架构.md)           | 技术栈、启动命令、目录结构、应用启动链路、页面渲染链路、Pinia Store、ma-*/m-* 组件库、ma-form/MaProTable 开发、图标系统与离线配置、字典系统、响应式布局、文件上传、插件前端同步链路 |
| [13-企业官网](code/13-企业官网.md)           | Nuxt.js 4.2 SSR/SSG、目录结构、页面路由、部署方式 |
| [Desktop 打包](desktop/README.md) | phar→sfx→stage→tauri；tools 不进桌面包 |

## 后端开发指南

| 文档 | 覆盖内容 |
|---|---|
| [06-WebSocket系统](code/06-WebSocket系统.md) | WS 分层架构、事件驱动推送、插件化处理器注册、连接生命周期、Redis 存储设计、水平扩展、安全设计 |
| [07-代码生成器](code/07-代码生成器.md) | CRUD 生成命令参数、admin/api 模式差异、字段映射规则（后缀/前缀/包含）、验证规则自动生成、模板定制 |
| [08-插件系统](code/08-插件系统.md) | 插件目录结构、config.json、插件类型（mix/frond/backend）、命令速查、开发要点 |
| [09-数据库迁移工具](code/09-数据库迁移工具.md) | 生成迁移/Seeder/导入 SQL 三大命令、分片处理、备份恢复流程 |
| [10-监听与异步操作](code/10-监听与异步操作.md) | 事件定义/监听/分发、Tools 异步封装、组件异步速查表、协程使用 |
| [11-IP位置查询](code/11-IP位置查询.md) | IpLocationService 多 API 降级、多语言、24h 缓存、内网识别、统一数据格式 |
| [12-权限系统](code/12-权限系统.md) | RBAC 功能权限（用户→角色→菜单）、Permission 注解、5 种数据权限（data_scope）、优先级策略、DataScopeTool、超级管理员 |

## Story Studio 插件

| 文档 | 覆盖内容 |
|---|---|
| [04-Story-Studio插件](code/04-Story-Studio插件.md) | 后端架构、核心业务模型关系图、剧情帧时间模型、WebSocket 异步推理服务（14 种 action）、AI 图像管线（SDXL/Qwen-Image-Edit 模型分工）、前端核心模块（wsTasks/编辑器渲染/3D 姿势/资源包工作台/素材面板/音频轨道）、全局设置约束 |

### 插件编码链路文档

位于 `server/plugin/ds/storyStudio/docs/code/`，改代码时必看：

| 文档 | 覆盖链路 |
|---|---|
| [WebSocket任务管线](server/plugin/ds/storyStudio/docs/code/WebSocket任务管线.md) | WS 任务统一管线、Bundle/源头写回分离、禁止踩坑清单 |
| [推理端链路](server/plugin/ds/storyStudio/docs/code/推理端链路.md) | 8 个 Service → Builder → runSlot → resolveWh 尺寸派生 → InferBody 分袋 → Python 推理，完整参数流转 |
| [剧情帧时间线](server/plugin/ds/storyStudio/docs/code/剧情帧时间线.md) | UI → composable → 持久化 → API → Repository → DB，帧时间语义与段时长计算 |
| [编辑器时间线链路](server/plugin/ds/storyStudio/docs/code/编辑器时间线链路.md) | playheadMs ↔ eventTimeMs ↔ segmentIndex ↔ frameId 四态同步、paintTimelineAt 出图入口 |
| [编辑器外壳与画布](server/plugin/ds/storyStudio/docs/code/编辑器外壳与画布.md) | Phaser 编辑器 Shell 布局、模式接线、数据挂载链路 |
| [翻译链路](server/plugin/ds/storyStudio/docs/code/翻译链路.md) | 字典定义 → dictStore 注册 → MaDictSelect/useTrans 两条翻译链路 |
| [数据库设计](server/plugin/ds/storyStudio/docs/code/数据库设计.md) | 11 张业务表结构、ER 图、资产挂载统一管线（单一 actor 流程）、遗留概念禁止清单 |

### 插件编辑器交互约定

| 类别 | 约定 | 说明 |
|---|---|---|
| UI | 剧情帧播放高亮 | 调试播放（debugPlayStoryFrames）期间，`debugPlayStoryFramesBusy=true`，DockFrameCol 当前剧情帧下全部挂载对象行（mount-row：素材/编辑动作）追加 `--playing` 类：蓝色背景 `light-7` + 边框 `light-5`；结束 Busy=false 自动还原。帧列、mount 容器不变。 |
| 音频 | 手势批量解锁 | `debugPlayStoryFrames()` 用户手势栈内：建完 audioPool 立刻对全部 `hasAudio` 轨道做「静音 play()→then pause/还原 muted」一次性解锁。避免后续 Phaser 回调中非手势触发的 play() 被浏览器策略拦截（NotAllowedError）。 |
| 音频 | 单次播放语义 + 循环预留 | 每次调试播放会话：`audioPlayedIndices` Set 记录已播放轨道下标，`syncAudioAt` 在 `!loopAudio` 时对已播轨道跳过。会话结束 `clearAudio()` 清空 Set，下次播放重新计数。预留 `audioLoopEnabled=false`（ContentScenePlayback 字段）与 `loopAudio` 参数，后续接 UI 开关只需改字段来源。 |

