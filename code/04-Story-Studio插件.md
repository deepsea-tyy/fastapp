# Story Studio 插件

Story Studio 是项目的核心业务插件，提供从小说文本到短视频生成的完整 AI 创作管线。

## 后端架构

```
plugin/ds/storyStudio/src/
├── Http/
│   └── Admin/
│       ├── Controller/    # 管理端 API 控制器
│       └── Service/       # 业务服务
├── WebSocket/
│   ├── Service/           # 异步 AI 推理服务（核心）
│   ├── Job/               # 任务上下文与结果封装
│   ├── StoryStudioMessageHandler.php  # WS 消息路由
│   └── WsStatusService.php            # 推理状态管理
├── Model/                 # 业务数据模型
├── Repository/            # 数据仓储
├── Support/
│   ├── DefaultPrompt/     # AI 提示词预设
│   │   ├── Models/        # 模型特定预设
│   │   └── Presets/       # 预设数据（PHP 数组）
│   ├── Infra/             # 基础设施（FFmpeg、推理网关）
│   └── AssetBundlePersist.php  # 资源包持久化
└── Listener/              # 事件监听器
```

## 核心业务模型

| 模型 | 文件 | 职责 |
|---|---|---|
| StoryProject | [StoryProject.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryProject.php) | 创作项目（根节点） |
| StoryChapter | [StoryChapter.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryChapter.php) | 章节（小说正文分段） |
| StoryScene | [StoryScene.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryScene.php) | 场景（章节内的叙事单元） |
| StoryAsset | [StoryAsset.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryAsset.php) | 视觉资产（角色/道具/场景等） |
| StoryAssetPose | [StoryAssetPose.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryAssetPose.php) | 姿势存档 |
| StorySpeech | [StorySpeech.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StorySpeech.php) | 台词行（对白/旁白/内心） |
| StoryPresentation | [StoryPresentation.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryPresentation.php) | 画面呈现单元（对应 Scene） |
| StoryPresentationFrame | [StoryPresentationFrame.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryPresentationFrame.php) | 剧情帧（时间线节点） |
| StoryPresentationActor | [StoryPresentationActor.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryPresentationActor.php) | 演员状态（帧内元素） |
| StoryPresentationAction | [StoryPresentationAction.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryPresentationAction.php) | 演员动作（动画） |
| StoryAttachmentInfer | [StoryAttachmentInfer.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryAttachmentInfer.php) | 附件推理快照（参数记录） |
| StoryRenderOutput | [StoryRenderOutput.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/Model/StoryRenderOutput.php) | 渲染输出 |

## 业务关系图

```
StoryProject (1)
  └── StoryChapter (N)
        └── StoryScene (N)
              ├── StorySpeech (N)  ─── 台词行
              └── StoryPresentation (1)
                    └── StoryPresentationFrame (N)  ─── 剧情帧
                          └── StoryPresentationActor (N)  ─── 演员
                                └── StoryPresentationAction (N)  ─── 动作

StoryAsset (项目全局/角色/道具/场景)
  ├── bundle (JSON: 资源包，含 portrait/pose/emotion/outfit/style/view)
  └── StoryAssetPose (N)  ─── 姿势存档
```

## WebSocket 异步服务 (AI 推理)

所有 AI 推理任务通过 WebSocket 异步执行，由 [StoryStudioMessageHandler.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/StoryStudioMessageHandler.php) 统一调度。

### 支持的推理动作

| WS Action | 服务类 | 功能 |
|---|---|---|
| `story_studio_chapter_extract_scenes` | [ChapterExtractService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/ChapterExtractService.php) | 章节解析（切分场景+提取对白） |
| `story_studio_asset_image_generate` | [AssetImageGenerateService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetImageGenerateService.php) | AI 生图（txt2img） |
| `story_studio_asset_image_standardize` | AssetImageGenerateService::standardize | 图像标准化（BiRefNet + 尺寸规范） |
| `story_studio_asset_image_matting` | [AssetImageMattingService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetImageMattingService.php) | 图像抠图 |
| `story_studio_asset_pose_save` | [AssetPoseSaveService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetPoseSaveService.php) | 3D 定姿存档 |
| `story_studio_asset_bundle_anatomy_fix` | [AssetBundleAnatomyFixService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetBundleAnatomyFixService.php) | 局部解剖修复 |
| `story_studio_asset_bundle_outfit` | [AssetBundleOutfitService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetBundleOutfitService.php) | 换装合成 |
| `story_studio_asset_bundle_emotion` | [AssetBundleEmotionService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetBundleEmotionService.php) | 表情生成 |
| `story_studio_asset_bundle_style` | [AssetBundleStyleService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetBundleStyleService.php) | 风格转换 |
| `story_studio_asset_bundle_view` | [AssetBundleViewService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetBundleViewService.php) | 视角转换 |
| `story_studio_asset_pose_save` | [AssetPoseSaveService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetPoseSaveService.php) | 定姿存档 |
| `story_studio_shot_preview_compile` | [PresentationPreviewCompileService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/PresentationPreviewCompileService.php) | 场景视频导出 |
| `story_studio_voice_preview` | [AssetAudioGenerateService.php](file:///Users/wangxiansheng/Workspace/fastapp/server/plugin/ds/storyStudio/src/WebSocket/Service/AssetAudioGenerateService.php) | 语音合成（TTS） |
| `story_studio_material_music_generate` | AssetAudioGenerateService::runMusic | 音乐生成 |
| `story_studio_cancel_operation` | StoryStudioMessageHandler::cancelOperation | 取消正在执行的任务 |

## AI 图像管线

### 模型分工

| 资源类型 | SDXL 模型 | 渲染风格 |
|---|---|---|
| scene (场景) | `sdxl_juggernaut` | realistic (写实) |
| character/prop/costume/creature/vehicle | `sdxl_illustrious` | anime_realistic (动漫写实) |

> **注意**：character 类型已由 3D 管线接管，SDXL 不再处理角色生成。

### 提示词模板
```
{subject}, {genre} {era}, {environment}, {architecture}, {style},
{weather}, {lighting}, {color_palette}, {composition}, {viewpoint},
{texture}, {detail_level}, {mood}, {fx}, masterpiece, best quality,
highly detailed
```

### 图像处理流程

```
原始素材 (txt2img via SDXL)
    │
    ▼
标准化 (BiRefNet 抠图 + 尺寸规范化)
    ├── person/creature: 704×1024
    ├── vehicle: 1024×704
    └── prop: 1024×1024
    │
    ▼
资源包 (Bundle) 生成
    ├── portrait (标准立绘)
    ├── pose (姿势变体)
    ├── outfit (换装)
    ├── emotion (表情)
    ├── style (风格)
    └── view (视角)
```

### Qwen-Image-Edit 管线（隔离）

Qwen-Image-Edit 管线完全独立于 SDXL，用于：
- 表情编辑：保持全身构图不变，仅修改面部表情
- 风格转换：整体风格迁移
- 局部修复：脸部/手部等解剖区域修复

**关键约束：**
- 请求必须包含 `person_image_path`（字符串，而非 `images` 数组）
- 必须包含 `width` 和 `height` 参数
- 表情/风格编辑提示词必须包含："Keep the same full body framing, do not crop or zoom in on the character"

## 前端 Story Studio

```
admin/src/plugins/ds/storyStudio/views/storyStudio/
├── asset/                          # 资产管理
│   ├── registry/
│   │   ├── composables/           # 组合式函数
│   │   │   ├── materialPanel.ts   # 素材面板逻辑
│   │   │   ├── useAsset.ts        # 资产 CRUD
│   │   │   ├── useAssetInfer.ts   # 推理任务触发
│   │   │   ├── useAssetLibrary.ts # 资产库面板
│   │   │   ├── useBundleWorkbench.ts  # 资源包工作台
│   │   │   └── useMaterialLibrary.ts   # 素材库
│   │   ├── ui/                     # UI 组件
│   │   │   ├── material/           # 素材生成（图像/音乐）
│   │   │   ├── pose/               # 3D 姿势编辑器
│   │   │   └── resource/           # 资源包工作台
│   │   └── bundle.ts               # Bundle 数据结构
│   └── voice/                      # 音色管理
├── story/                          # 剧情编辑
│   ├── chapter/                    # 章节管理
│   ├── scene/                      # 场景管理
│   └── structure/                  # 帧结构编排
├── presentation/                   # 画面呈现
│   ├── actor/                      # 演员状态管理
│   ├── mount/                      # 帧挂载
│   ├── schedule/                   # 时间线
│   └── schema/                     # 数据模型定义
├── renderer/                       # 渲染引擎
│   ├── adapter/                    # 渲染适配器（Phaser/Video）
│   ├── editor/                     # 编辑器渲染
│   └── runtime/                    # 运行时渲染
├── workspace/                      # 工作台布局
│   ├── state/                      # 工作区状态
│   │   ├── wsTasks.ts              # 任务进度管理（核心）
│   │   └── useStudio.ts            # 工作室状态
│   └── StoryStudioLayout.vue       # 主布局
└── index.vue                       # 入口
```

### 关键前端模块

#### 1. 任务进度管理 (wsTasks.ts)
[wsTasks.ts](file:///Users/wangxiansheng/Workspace/fastapp/admin/src/plugins/ds/storyStudio/views/storyStudio/workspace/state/wsTasks.ts) 是 WebSocket 异步任务的前端核心管理模块。

**功能：**
- 任务创建、执行、取消
- 实时进度推送（通过 WebSocket）
- 任务持久化（localStorage，10分钟 TTL）
- 历史记录保留（最多 5 条完成记录）
- scope 级去重（同 scope 同一时间只允许一个任务）

**支持的任务类型：**
```typescript
type AssetInferJobKind =
  | 'preview' | 'bundle' | 'standardize' | 'anatomy_fix'
  | 'outfit' | 'view' | 'emotion' | 'style'
  | 'voice' | 'music' | 'animation' | 'pose_save'
```

#### 2. 3D 姿势编辑器 (PoseEditorCanvas.vue)
位于 `asset/registry/ui/pose/`，基于 Three.js + @pixiv/three-vrm。

**核心 composables：**
| 文件 | 职责 |
|---|---|
| `usePoseEditor.ts` | 编辑器主逻辑（选中、重置、保存） |
| `usePoseBones.ts` | 骨骼节点选择与操作 |
| `usePoseBody.ts` | 体型参数（厚度/长度） |
| `usePoseFace.ts` | 面部表情（BlendShape） |
| `usePoseModel.ts` | VRM 模型加载与管理 |
| `usePoseScene.ts` | 场景控制（相机/灯光/视图） |
| `usePoseEditorCanvas.ts` | Canvas 初始化与事件绑定 |
| `poseMorph.ts` | 变形目标管理 |
| `poseHumanoid.ts` | 人形骨骼定义 |

#### 3. 资源包工作台 (useBundleWorkbench.ts)
管理资产的资源包（Bundle）编辑，包括：
- 标准立绘（portrait）选择
- 姿势（pose）变体管理
- 换装（outfit）合成
- 表情（emotion）编辑
- 风格（style）转换
- 视角（view）切换

#### 4. 素材面板 (materialPanel.ts)
管理素材生成：
- 维度选择（主题/时代/环境/建筑/风格等）
- 主题联动过滤（era_lock/environment_pool/architecture_pool）
- AI 图像生成触发
- 音乐生成触发
