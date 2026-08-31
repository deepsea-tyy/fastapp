# Story Studio 插件

Story Studio 是项目的核心业务插件，提供从小说文本到短视频生成的完整 AI 创作管线。

## 开发文档索引

详细编码链路文档位于插件目录 `docs/code/`：

| 文档 | 内容 |
|---|---|
| [WebSocket任务管线.md](../server/plugin/ds/storyStudio/docs/code/WebSocket任务管线.md) | WS 任务统一管线、Bundle/源头写回分离、禁止踩坑清单 |
| [编辑器外壳与画布.md](../server/plugin/ds/storyStudio/docs/code/编辑器外壳与画布.md) | Phaser 编辑器 Shell 布局、模式接线、数据挂载链路 |
| [编辑器时间线链路.md](../server/plugin/ds/storyStudio/docs/code/编辑器时间线链路.md) | Playhead/Seek/Reset/Playback → 画布同步 → shotFocus 完整链路 |
| [剧情帧时间线.md](../server/plugin/ds/storyStudio/docs/code/剧情帧时间线.md) | 帧时间语义、段时长计算、挂载时间规则、已移除字段清单 |
| [翻译链路.md](./翻译链路.md) | 字典定义 → 运行时注册 → MaDictSelect → locale YAML 完整链路 |
| [推理端链路.md](../server/plugin/ds/storyStudio/docs/code/推理端链路.md) | 图片编辑（qwen_image_edit）8 Service + Builder + InferBody 分袋 + resolveWh 尺寸派生；生图（qwen_image_flash / Qwen-Image-Flash-8bit MLX 4 步蒸馏）调用端 + 推理端 + 信封示例 + 文件清单 |

---

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
| StoryProject | `Model/StoryProject.php` | 创作项目（根节点） |
| StoryChapter | `Model/StoryChapter.php` | 章节（小说正文分段） |
| StoryScene | `Model/StoryScene.php` | 场景（章节内的叙事单元） |
| StoryAsset | `Model/StoryAsset.php` | 视觉资产（character/prop/scene/costume/creature/vehicle） |
| StoryAssetPose | `Model/StoryAssetPose.php` | 姿势存档 |
| StorySpeech | `Model/StorySpeech.php` | 台词行（对白/旁白/内心） |
| StoryPresentation | `Model/StoryPresentation.php` | 画面呈现单元（对应 Scene） |
| StoryPresentationFrame | `Model/StoryPresentationFrame.php` | 剧情帧（时间线节点） |
| StoryPresentationActor | `Model/StoryPresentationActor.php` | 演员状态（帧内元素，含 scene 全屏背景） |
| StoryPresentationAction | `Model/StoryPresentationAction.php` | 演员动作（动画） |
| StoryAttachmentInfer | `Model/StoryAttachmentInfer.php` | 附件推理快照（参数记录） |
| StoryRenderOutput | `Model/StoryRenderOutput.php` | 渲染输出 |

## 业务关系图

```
StoryProject (1)
  └── StoryChapter (N)
        └── StoryScene (N)
              ├── StorySpeech (N)  ─── 台词行
              └── StoryPresentation (1)
                    └── StoryPresentationFrame (N)  ─── 剧情帧
                          └── StoryPresentationActor (N)  ─── 演员（含 scene 全屏背景 + material 音频材质）
                                └── StoryPresentationAction (N)  ─── 动作

StoryAsset（项目全局，asset_type 区分）
  ├── character / costume / creature / vehicle / prop  ─── 按 896×896 编辑，走 BiRefNet 抠图
  └── scene  ─── 按 672×672 编辑，跳过抠图，输出归一化 1216×832
  ├── bundle (JSON: 资源包，含 portrait/pose/emotion/outfit/style/view)
  └── StoryAssetPose (N)  ─── 姿势存档
```

**关键统一**：`background` 资产类型已删除，场景背景完全复用 `StoryPresentationActor` 管线（`asset.asset_type == 'scene'` + `backgroundMode: true` 控制全屏渲染）。

**音频材质统一管理**：音频素材（voice/music）作为 material 类型 actor 挂载到剧情帧，与对白（speech）统一管理。音频材质只参与时间轴计时与音频混音，不在编辑器画布显示。时长通过 `attachment.duration_ms` 回写（py 推理端返回 → PHP 透传），与对白的 `audio_duration_ms` 在挂载/播放/合成时统一处理。

---

## 剧情帧时间模型

### 帧数据结构（StoryPresentationFrame）

```ts
type StoryFrame = {
  id?: number
  presentation_id?: number
  front_in: string         // 帧前入场动画（dict: story-transition-in）
  front_in_ms: number      // 帧前入场时长(ms)
  front_wait_ms: number     // 帧前等待时长(ms)
  back_out: string         // 帧后出场动画（dict: story-transition-out）
  back_out_ms: number      // 帧后出场时长(ms)
  back_wait_ms: number     // 帧后等待时长(ms)
}
```

**已删除字段**（勿再引用）：
- `story_presentation_frame.time_ms` / `interval_ms`
- `story_presentation_frame.scene_asset_id`（统一由 actor 中 `asset_type=scene` 管理）
- `story_presentation.transition_in` / `transition_out` / `transition_duration`
- `story_presentation.scene_asset_id`

### 帧时间顺序

```
入场(front_in_ms) → 帧前等待(front_wait_ms) → 内容(contentDurationMs) → 帧后等待(back_wait_ms) → 出场(back_out_ms)
```

段时长：`durationMs = front_in_ms + front_wait_ms + contentDurationMs + back_wait_ms + back_out_ms`

### 挂载时间语义（硬规则）

所有挂载（actor / speech / overlay / window）**基于帧 0 点独立计时，挂载之间无关联**：

| 字段 | 语义 |
|---|---|
| `start_ms >= 0` | 帧内开始时间 |
| `end_ms = 0` | **一直显示**，不参与帧内容时长计算 |
| `end_ms > 0` | 帧内结束时间，参与帧内容时长计算 |
| `actorVisibleAt` | `end_ms=0` 时恒可见（只要过了 start） |
| `speechEndMs` | `end_ms>0` 用 end_ms；否则 `start + audio_duration_ms`；否则 start |
| `audioMaterialEndMs` | 音频材质 actor：`end_ms>0` 用 end_ms；否则 `start + duration_ms`；否则 start |

**帧内容时长**：`max(所有 speechEndMs, 所有 actor.end_ms>0, 所有 audioMaterialEndMs)`，全 `end_ms=0` 时返回 0。

**已移除**：`DEFAULT_ACTION_SPAN_MS`、`validateFrameTiming`、`frameSpanMs` / `fallbackSpan` 参数。

### 对白与音频材质挂载时间规则

对白（speech）与音频材质 actor（material 类型，含 voice/music）**统一管理**，挂载时仅计算当前条时间，不改写其他条目。

- **挂载新对白**：
  - 有音频：`start_ms = 帧内已挂载对白/音频材质 max(end_ms, start_ms+duration)`；`end_ms = start_ms + audio_duration_ms`
  - 无音频：`start_ms = 0`；`end_ms = 0`
- **挂载音频材质 actor**（`duration_ms > 0`）：
  - `start_ms = 帧内已挂载对白/音频材质 max(end_ms, start_ms+duration)`；`end_ms = start_ms + duration_ms`
  - 无 `duration_ms`：`start_ms = 0`；`end_ms = 0`（仅时间轴占位，不参与计时）
- **取消挂载/删除**：**不重算**剩余条目时间
- **时间输入框**：全部 8 个字段（对白/演员/动作的 start_ms/end_ms + 帧前 front_in_ms/front_wait_ms + 帧后 back_out_ms/back_wait_ms）统一 `min=0` + `value-on-clear="0"`，禁止空值/负数
- **音频材质 actor 游标**：`audioMountCursorMs` 取帧内所有对白和音频材质 actor 的 `max(end_ms, start_ms+duration)`，作为新挂载条目的 `start_ms`

### 帧索引单一数据源

`__activeSegmentIndex`（帧下标）是**唯一**数据源，`__activeFrameId` 字段已删除：

- `activeFrameFromPresentation(pres) = pres.frames[activeSegmentIndex(pres)]`
- `syncTimelineMeta` **不再**调用 `setActiveSegmentIndex`（避免时间解析覆盖用户选择）
- `useStructureDock.applySegment` 必须先 `setSegmentIndex` 再 `syncEditorCanvas`

---

## WebSocket 异步服务 (AI 推理)

所有 AI 推理任务通过 WebSocket 异步执行，由 `WebSocket/StoryStudioMessageHandler.php` 统一调度。

前端统一管线：`kinds 注册表 → runWsTask → 推送只更新 progress/result → HTTP onSuccess commit 恰好一次 → done`

### 统一管线硬规则

1. **业务写回只走 HTTP `onSuccess`**；WS 推送不写 `assetRows` / 章节树 / novel bundle
2. **新增/改 kind 只改 `kinds.ts`**（progressAction / keepOnSuccess / restore）+ 调用方 commit
3. runtime 只做运输、busy、进度、persist；不碰业务 state
4. 无 dataApplier、无双写、不向后兼容旧 kind
5. `novel_*`：`WsTask.kind` ≡ `track.kind` ≡ `wsScope.kind`，无中间别名

### 支持的推理动作

| WS Action | 服务类 | 功能 |
|---|---|---|
| `story_studio_chapter_extract_scenes` | `WebSocket/Service/ChapterExtractService.php` | 章节解析（切分场景+提取对白） |
| `story_studio_asset_image_generate` | `WebSocket/Service/AssetImageGenerateService.php` | AI 生图（txt2img） |
| `story_studio_asset_image_standardize` | AssetImageGenerateService::standardize | 图像标准化（尺寸规范） |
| `story_studio_asset_image_matting` | `WebSocket/Service/AssetImageMattingService.php` | 图像抠图（scene 类型跳过） |
| `story_studio_asset_pose_save` | `WebSocket/Service/AssetPoseSaveService.php` | 3D 定姿存档 |
| `story_studio_asset_bundle_anatomy_fix` | `WebSocket/Service/AssetBundleAnatomyFixService.php` | 局部解剖修复 |
| `story_studio_asset_bundle_outfit` | `WebSocket/Service/AssetBundleOutfitService.php` | 换装合成 |
| `story_studio_asset_bundle_emotion` | `WebSocket/Service/AssetBundleEmotionService.php` | 表情生成 |
| `story_studio_asset_bundle_style` | `WebSocket/Service/AssetBundleStyleService.php` | 风格转换 |
| `story_studio_asset_bundle_view` | `WebSocket/Service/AssetBundleViewService.php` | 视角转换 |
| `story_studio_shot_preview_compile` | `WebSocket/Service/PresentationPreviewCompileService.php` | 场景视频导出 |
| `story_studio_voice_preview` | `WebSocket/Service/AssetAudioGenerateService.php` | 语音合成（TTS） |
| `story_studio_material_music_generate` | AssetAudioGenerateService::runMusic | 音乐生成 |
| `story_studio_cancel_operation` | StoryStudioMessageHandler::cancelOperation | 取消正在执行的任务 |

### Bundle 编辑写回分离（源头 ≠ Bundle）

| 层 | 字段 | API |
|---|---|---|
| 源头 | `portrait_attachment_id`、基础字段 | `updateAssetSource(row)` → `saveAssetRow` |
| Bundle | `row.bundle[refId][channel][key]` | `commitAssetBundleResult`（WS onSuccess 唯一写点） |

**禁止踩坑**：
1. 不整行替换 `arr[ix] = { ...live, bundle }`（slotRow 与 live 会分裂）
2. 不用 bundle 回包写 `portrait_attachment_id`（覆盖参考图源头）
3. 不在推送/dataApplier 中再 commit（双写/失败态不一致）
4. 不发明 `persistAssetBundle` 等 bundle 专用薄包装（VM 上不存在）
5. 目标图必须在 Form 点选，不能右侧资源库直接设
6. 缺 `referenceId` 不跑任务（否则结果挂到 `ref=0`）

### LLM 参数下发硬规则

- 所有 LLM 调用**必须**下发 `max_tokens` 和 `context_length` 参数（PHP 侧提供）
- Python 推理侧**禁止硬编码**这两个值
- `ChapterExtractService` 复用 `NovelLlmJson` trait 的 `llmJsonRaw`（`max_tokens=8192`，`context_length=16384`），不拼接 `GLOBAL_RULE` 提示
- 章节正文生成按 `section_length_pref` 动态 `max_tokens`，避免重复
- `prev_summary` 为空时注入空字符串，不用固定「故事开篇」

### 音频时长回写硬规则

音频时长（`duration_ms`）完整链路：**py 推理端返回 → PHP 透传 → attachment.duration_ms → 前端展示**，禁止 PHP ffprobe 或前端 `Audio.duration` 探测。

| 来源 | 服务 | 回写字段 |
|---|---|---|
| TTS 语音（voice） | `AssetAudioGenerateService` | `attachment.duration_ms` |
| 音乐生成（music） | `AssetAudioGenerateService::runMusic` | `attachment.duration_ms` |
| py 推理端 | `ace_step_service.py` / `musicgen_medium_service.py` | 返回 `duration_ms` |

- `AttachmentService.attachLocal` 支持 `durationMs` 参数，写入 `attachment.duration_ms`
- `StorySceneRepository.formatSceneForApi` 为 material 类型 actor 补充 `attachment_url` 和 `duration_ms`
- 对白使用 `audio_duration_ms`（speech 行字段），音频材质使用 `duration_ms`（attachment 字段），两者在挂载/播放/合成时统一处理

### 语音重新生成的附件删除规则

重新生成语音音频时，**附件删除统一走后端**，前端不再直接调用 HTTP DELETE 接口。

**删除链路（`AssetAudioGenerateService::runVoice`，`regenerate=true` 时）**：

1. **按对白 id 删除主附件**：若 `speech_id > 0`，查询 `StorySpeech.attachment_id`，通过 `AttachmentService::deleteById` 删除原有附件记录与物理文件
2. **按 object_name 清理缓存**：调用 `AttachmentService::deleteByAssetTypeAndObjectName('voice', object_name)` 删除同名预览缓存

**前端配合**：
- `picker.ts` / `AssetVoicePicker.vue`：移除 `regenerate` 时的 `useHttp().delete('/attachment/{id}')` 调用，仅透传 `regenerate: 1` 标记
- `AssetVoicePicker` 删除 `attachmentId` 输入 prop（不再需要前端知晓旧附件 id）
- `SpeechLineForm.vue` 同步移除 `:attachment-id` 绑定

---

## AI 图像管线

### 模型分工

调用端默认统一走 `qwen_image_flash`（Qwen-Image-Flash-8bit MLX，4 步蒸馏）；按 `asset_type` 仅在画布尺寸与归一化策略上分工。

| 资源类型（asset_type） | 生图模型 | 编辑画布 | 归一化输出 | 抠图 |
|---|---|---|---|---|
| scene | `qwen_image_flash` | **1344×768** | **1216×832**（`normalize_scene_cover` 缩放+居中裁剪） | **跳过 BiRefNet** |
| character / costume / creature | `qwen_image_flash` | **768×1344** | 按各自标准尺寸 | BiRefNet 抠图 |
| vehicle | `qwen_image_flash` | **1344×768** | 按各自标准尺寸 | BiRefNet 抠图 |
| prop | `qwen_image_flash` | **1024×1024** | 按各自标准尺寸 | BiRefNet 抠图 |

`ImagePresets::$models['qwen_image_flash']['type_meta']` 集中定义各 `asset_type` 的 `steps=4` / `cfg=1.0` / 画布尺寸（与 MLX 8bit 4 步蒸馏配置对齐）。`checkpointForAssetType()` 一律返回 `qwen_image_flash`，业务侧不再按风格分模型。

### 提示词约束

**非 scene 类型的正向提示词**必须包含主体完全可见约束：
- `fully visible`、`completely unobstructed`、`nothing covering the subject`

**非 scene 类型的负向提示词**必须包含遮挡相关项：
- `obscured`、`occluded`、`cut off`、`hidden subject`

**style 维度的预设按 asset_type 作用域隔离**，防止跨模型风格冲突。

### 图像处理流程

```
原始素材 (txt2img via Qwen-Image-Flash MLX)
    │
    ▼
标准化
    ├── scene: 672×672，跳过 BiRefNet → normalize_scene_cover 缩放到 1216×832
    ├── person/creature: 704×1024 + BiRefNet
    ├── vehicle: 1024×704 + BiRefNet
    └── prop: 1024×1024 + BiRefNet
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

### outfitPrompt / posePrompt 结构约束

- outfitPrompt：严格保留图 1 的风格/姿势/面部特征/**体形**，**只取**图 2 的服装设计（剪裁/图案/颜色/层次/面料/装饰/配饰）；服装尺码/合身度/垂感必须按图 1 人物体形适配，自然穿着，禁止把人物体形拉伸去迁就图 2 服装轮廓
- posePrompt：严格保留图 1 的风格/面部特征，**只取**图 2 的身体姿势（体位/四肢位置/头部倾斜/视线方向），**排除**相机角度/构图变化
- `buildContentReplaceInfer`：优先保留图 1，图 2 只提供主体内容和位置，**不影响**图 1 的渲染风格/笔触/配色/光照/材质/透视

### 双图 prompt 实际形态（`QwenImageEditPresets::buildDualImageInfer`）

- 结构：`base_keep` + 维度句（clothing/pose/prop/...）= 2 句正向；negative 固定空格
- `base_keep` 通用前置（所有双图维度共用，命中 outfit/pose/prop/... 全部路径）：
  - 保留图 1 身份/面部/体形/身高/比例不变
  - **构图硬约束**：保持与图 1 相同的全身构图与取景，禁止裁剪/截断/放大/拉近
  - **头顶留白**：头顶上方必须留出清晰空间，头顶、脚、四肢完整可见在画框内
- 各维度按 Image 2 含义分别约束适配关系，**不**用服装代表所有图二：
  - `clothing`：服装尺码/合身度/垂感按图 1 体形适配，自然穿着；只从图 2 取设计元素
  - `pose`：图 1 人物做图 2 姿势，但保持图 1 自身体形，不抄图 2 体形/比例
  - `prop`：道具按图 1 手部与身体尺寸缩放
  - `style` / `hairstyle` / `expression` / `background`：只取图 2 对应元素，主体保持图 1
- `dims` 含 `pose` 时挂 AnyPose LoRA（lightning + anypose_base/helper @ 0.7）

---

## 前端 Story Studio

```
admin/src/plugins/ds/storyStudio/views/storyStudio/
├── asset/                          # 资产管理
│   ├── registry/
│   │   ├── composables/           # 组合式函数
│   │   │   ├── materialPanel.ts   # 素材面板逻辑
│   │   │   ├── useAsset.ts        # 资产 CRUD
│   │   │   ├── useAssetInfer.ts   # 推理任务触发 + commitAssetBundleResult
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
│   ├── scene/                      # 场景管理 + useScenePersist 持久化
│   ├── structure/                  # 帧结构编排（StructureDock：对白/帧/挂载）
│   └── model/                      # 领域类型/默认值/序列化（跨 presentation/asset 共享）
├── presentation/                   # 画面呈现
│   ├── actor/                      # 演员状态管理（含 mount.ts：__activeSegmentIndex 唯一数据源）
│   ├── mount/                      # 帧挂载（labels.ts：类型筛选，无 background）
│   ├── schedule/                   # 时间线（timeline.ts / mountTiming.ts / action.ts）
│   └── schema/                     # 数据模型定义
├── renderer/                       # 渲染引擎
│   ├── adapter/                    # 渲染适配器（Phaser/Video）
│   ├── editor/                     # 编辑器渲染
│   │   └── phaserEditor/           # Phaser 画布（scene 复用 actorLayer，backgroundMode 全屏）
│   └── runtime/                    # 运行时渲染
├── workspace/                      # 工作台布局
│   ├── state/                      # 工作区状态
│   │   ├── wsTasks/                # 任务进度管理（kinds / scope / bridge / runtime）
│   │   ├── useStudio.ts            # 工作室状态编排
│   │   └── useStudioEditor.ts      # 编辑器镜像状态 + shotFocus 同步
│   ├── playAudioTracks.ts          # 统一音频轨道（对白 + 音频材质 actor）
│   ├── WorkspacePlay.vue           # 播放/合成台
│   └── StoryStudioLayout.vue       # 主布局
└── index.vue                       # 入口
```

### 关键前端模块

#### 1. 任务进度管理 (wsTasks/)

`workspace/state/wsTasks/` 是 WebSocket 异步任务的前端核心管理目录：

| 文件 | 职责 |
|---|---|
| `kinds.ts` | **唯一** trackKind 表：action / keep / restore |
| `types.ts` | kind 常量、`WsTask`、`RunWsTaskOptions` |
| `scope.ts` | `wsScope.*` 工厂；`wsScopeTrack` 从 kinds 取 action |
| `labels.ts` | 任务栏文案 / 阶段文案 |
| `bridge.ts` | patch WS；多 runtime 按 `job_id` 分发进度（无业务 applier） |
| `runtime.ts` | `createWsTaskRuntime`：busy / persist / `runWsTask` / `destroy` |

#### 2. 编辑器渲染管线（Phaser）

- scene 资产**复用** `actorLayer` 管线（不再走独立 backgroundLayer），通过 `backgroundMode: true` 控制 `fullViewport` 全屏渲染
- `buildSceneSnapshotAtTime` 包含 scene-type actor，`resolveSceneAsset` 取背景
- 出图唯一入口：`paintTimelineAt(ms)` → `buildSceneSnapshotAtTime` → `syncRuntimeToPhaser`

#### 3. 3D 姿势编辑器 (PoseEditorCanvas.vue)

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

#### 4. 资源包工作台 (useBundleWorkbench.ts)

管理资产的资源包（Bundle）编辑，包括：
- 标准立绘（portrait）选择
- 姿势（pose）变体管理
- 换装（outfit）合成
- 表情（emotion）编辑
- 风格（style）转换
- 视角（view）切换

**素材选择标准化硬约束**：
- 换装（outfit）、姿态（pose）、内容替换（content）三个 Tab 的素材选择器均强制 `onlyNormalized=true`
- 标准化判定：`attachment.image_wh` 字段非空（通过 `/admin/ds/storyStudio/attachment/normalize` 接口完成尺寸规范后写入）
- 选择器列表**全部显示**图片（不做后端过滤），未标准化图片也可正常点击选中
- 未标准化时**确认按钮自动禁用**，弹框底部显示提示文字（警告色）引导用户操作
- 每行行尾提供「裁剪（标准化）」按钮，用户可在弹框内直接对图片执行标准化操作，完成后即可确认选择
- 标准化前置条件：图片需先通过行尾「编辑」按钮设置 `asset_type`（人物/服装/生物/道具/场景/载具），否则标准化按钮置灰禁用

#### 5. 素材面板 (materialPanel.ts)

管理素材生成：
- 维度选择（主题/时代/环境/建筑/风格等）
- 主题联动过滤（era_lock / environment_pool / architecture_pool，时代与主题风格不冲突）
- AI 图像生成触发
- 音乐生成触发（music asset_type 同时保存用户选项和生成歌词，歌词用 `lyrics` key 存入 JSON 数组）

#### 6. 叙事内容编辑 (story/)

负责章节内的**项目/章节导航、场景数据、结构编辑**。

由 `workspace/state/useStudio.ts` 编排；布局入口 `StoryStudioLayout.vue`。

**子目录职责**（`story/` 下）：
- `model/` — 领域类型、默认值、序列化（跨 presentation / asset 共享）
- `chapter/` — 项目与章节导航、正文编辑、章节解析流水线
- `scene/` — 场景行数据与 CRUD（useStoryScenes + useScenePersist 持久化）
- `structure/` — 底部结构面板：StructureDock（左对白 / 中剧情帧 / 右挂载编辑）

**数据流**：
1. **选章节** → `loadChapterStoryScenes`（`navTree`，无 HTTP）
2. **选场景** → `loadSceneDetail`（加载 presentation + speech 子树）
3. **解析剧情**（可选）→ `chapterPipeline` 写入场景树与对白（**不自动创建** `story_asset`）
4. **编辑** → `StructureDock`，持久化走 `story/scene/composables/useScenePersist.ts`
5. **预览** → `EditorDesk`

**公共出口**：外部模块从 `story/index.ts` 或 `story/model/types.ts` 导入 `StorySceneRow`、`ScenePresentationHost` 等类型。

#### 7. 统一音频轨道管理 (playAudioTracks.ts)

`workspace/playAudioTracks.ts` 统一对白（speech）与音频材质 actor 的播放/合成流程：

| 函数 | 职责 |
|---|---|
| `buildPlayAudioTracks` | 合并对白轨道 + 音频材质 actor 轨道 |
| `buildPlaySpeechTracks` | 仅对白轨道 |
| `buildPlayActorAudioTracks` | 仅音频材质 actor 轨道（`duration_ms > 0`） |
| `audioTracksToMixPayload` | 统一生成混音 payload（`attachment_id` + `start_ms`） |
| `createAudioPool` / `syncAudioAt` / `stopAudioPool` | 音频池创建/同步/停止 |

**素材拖拽规则**：
- 图片素材（character/scene/prop/costume/creature/vehicle）→ 编辑器画布显示 + 帧挂载
- 音频素材（voice/music）→ 仅帧挂载（material 类型 actor），不显示在画布，只参与时间轴计时与音频混音
- 音频素材拖拽携带 `duration_ms`，挂载时按 `audioMountCursorMs` 计算 `start_ms`/`end_ms`

**类型**：`PlayAudioTrack = PlaySpeechTrack | PlayActorAudioTrack`，`isActorAudioTrack` 类型守卫区分。

---

## 全局设置硬约束

- 主题、世界观、角色卡为**必填**字段
- 角色卡的**姓名**和**关系**字段不能为空
- 新增角色**不设默认姓名**
- WS 请求**不显示**任何 prompt 消息
