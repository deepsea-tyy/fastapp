# FastApp Desktop 架构

本目录是 FastApp **唯一的** Tauri 桌面工程。请勿在仓库根目录 clone [tauri-apps/tauri](https://github.com/tauri-apps/tauri) 框架源码——框架通过 npm/cargo 依赖引入即可。

## 职责边界

| 层级 | 目录 | 内容 |
|------|------|------|
| 安装包 | `splash/` + `src-tauri/` + `bundle/` | 7z seed、CDN 下载 phar、进程编排、GPU 仲裁 |
| 操作台 UI | `admin/dist`（打入安装包） | 完整 admin SPA |
| 用户数据 | AppData `FastApp/` | seed 的 ui/tools/cmd + 下载的 phar + 按需模型 |

## 数据流

```
安装包 bundled（7zz + ui.7z / tools.7z / cmd.7z）
    → 首次 7z 解压到 AppData
    → CDN manifest → 仅下载 server（phar + plugin）
    → 启动 Hyperf :9501 + scheduler :8312
    → WebView 加载 AppData/ui/index.html
    → 模型按需 download_model / scheduler 引导
```

## AppData 布局

```
FastApp/
├── ui/       # admin dist 扁平化
├── server/   # fastapp.phar + plugin（CDN）
├── tools/    # Python 源码
├── cmd/      # php、uv、ffmpeg
└── logs/
```

## 打包组件

| 包 | 来源 | 打入方式 |
|----|------|----------|
| cmd | [`cmd/`](../cmd/) 平台二进制 | `script/desktop-bundle-stage.sh` → `cmd.7z` |
| ui | `admin/dist` | 同上 → `ui.7z` |
| tools | `tools/` | 同上 → `tools.7z`（不含 models/.venv） |
| server | `script/park.sh` → phar + plugin | **CDN** `script/desktop-publish.sh` |

## GPU 策略

- UI 默认纯 DOM；Phaser 懒加载，推理时 `gpu_saver` 挂起
- Rust 轮询 scheduler `active_slots`，向 UI 广播 `gpu_locked`

## 硬件检查

启动页（`splash/`）调用 Tauri command `get_hardware_report`：

| 来源 | 内容 |
| --- | --- |
| Rust 本地 | OS、内存 GB、NVIDIA GPU 名称/显存（`nvidia-smi`） |
| scheduler `:8312` | `profile`（platform/accelerator/memory_gb）+ capabilities tier |

聚合为产品档位 **basic / sdxl / song_pro**（与 [Story Studio 模型选型](../server/plugin/ds/storyStudio/docs/模型选型.md) 一致）：

- **basic 可用**：编辑器、叙事、配音、BGM 等，**无需**下载 SDXL 权重
- **sdxl 不可用**：提示升级配置，仍允许进入应用
- **sdxl 可用/受限**：`suggested_downloads` 含 `juggernaut-xl`、`illustrious-xl`，按需 `download_model`

tier 逻辑以 Python [`hardware_profile.py`](../tools/src/hardware_profile.py) 为准；scheduler 未启动时使用 Rust 本地启发式。

## 分阶段

| 阶段 | 内容 |
|------|------|
| P0 | 胖包 seed + CDN 下载 server |
| P1 | tools + scheduler + GPU 协作 |
| P2 | 模型/HF_TOKEN、托盘、单实例 |
| P3 | server 增量更新、日志 |
| P4 | spc-php 替换 swoole-cli |

## 关键路径

- phar 与 plugin 同级：[`server/app/Common/Tools.php`](../server/app/Common/Tools.php) `phar_path()`
- ffmpeg：AppData `cmd/ffmpeg`，PHP 经 `FfmpegCommand`、Python 经 `tools_env.py`
- 推理网关：[`InferenceGateway.php`](../server/plugin/ds/storyStudio/src/Support/Infra/InferenceGateway.php)
- tools 根目录：[`tools/service_ctl/constants.py`](../tools/service_ctl/constants.py) `TOOLS_ROOT`
- Staging：[`script/desktop-bundle-stage.sh`](../script/desktop-bundle-stage.sh)
- CDN 发布：[`script/desktop-publish.sh`](../script/desktop-publish.sh)
