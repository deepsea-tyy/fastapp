# tools

本地 AI 推理：FastAPI 微服务 + `main.py` 进程管理 + **scheduler** 按内存槽位按需启停。

**Story Studio 用法**：只常驻 scheduler；PHP 经 `SCHEDULER_URL` 调 `ensure` 拉起 llm / SDXL 等。直连调试某服务：`start llm` 等（勿与 scheduler 混启）。

---

## 快速开始

```bash
cd tools
uv sync
cp .env.example .env
# 填 HF_TOKEN；可选 HF_ENDPOINT=https://hf-mirror.com

uv run python main.py download              # 列出服务与模型
uv run python main.py download scheduler    # Story 起步：调度能力所需权重

uv run python main.py start              # = start scheduler（推荐）
uv run python main.py start scheduler -d # 后台，日志 logs/scheduler.log
uv run python main.py status
```

插件服务端 `.env` 配置 `SCHEDULER_URL`（默认 `http://127.0.0.1:8012`）。内存策略由 tools `.env` 的 `TOOLS_MEMORY_PROFILE`（`32g` / `64g`）决定。

---

## 服务

| 别名 | 端口 | 后端 | 说明 |
|------|------|------|------|
| `llm` | 8000 | GGUF | Qwen2.5 对话 |
| `ocr` | 8001 | GGUF | PaddleOCR-VL |
| `emb` | 8002 | GGUF | Qwen3 向量 |
| `playwright` | 8003 | — | Chromium 采集 |
| `voice` | 8005 | — | OmniVoice TTS |
| `ip_adapter` | 8008 | diffusers | IP-Adapter 定妆微调 |
| `sdxl_juggernaut` | 8009 | diffusers | 定妆 Juggernaut XL |
| `sdxl_illustrious` | 8010 | diffusers | 定妆 Illustrious XL |
| `scheduler` | 8012 | — | 推理调度 |

OpenAPI：`http://127.0.0.1:<port>/docs`

Story 常用路径示例：`POST /v1/llm/chat/completions`、`/v1/ip_adapter/img2img`、`/v1/sdxl_juggernaut/txt2img` 等（以各服务 `/docs` 为准）。

---

## Scheduler 与内存槽

32–64GB 无法同时常驻 llm + 重型 SDXL。每次推理前：

```http
POST /v1/scheduler/ensure
{"capability": "llm", "profile": "32g"}
```

- 同 capability 已运行 → `changed: false`，不重启

```
槽位     服务（互斥关系）
────────────────────────────────────────
A        llm
B        sdxl_juggernaut | sdxl_illustrious | ip_adapter   （三选一）
C        voice                                          （可与上共存）
```

| 配置 | 行为 |
|------|------|
| **32g / 64g** | A 与 B 互斥；voice 不参与互斥 |

---

## CLI（`uv run python main.py …`）

| 命令 | 说明 |
|------|------|
| `status` | 各服务 pid / 端口 |
| `start [-d] [服务…]` | 无参 = 仅 scheduler；`-d` 后台；不可混启 scheduler + 推理服务 |
| `stop [服务…]` | 无参 = 停全部 |
| `restart [服务…]` | 无参 = 仅重启 scheduler |
| `clear` | 清空 `logs/*.log` |
| `download [服务…]` | 按服务名从 Hugging Face 下载权重；别名 `scheduler` / `all` / `gguf` |

`status` 只表示 HTTP 已监听；权重多在**首次业务请求**时加载。

---

## 模型

权重须**手动下载**；HF 仓库与本地目录在 [`service_ctl/cli.py`](service_ctl/cli.py) 写死，**不可通过 `.env` 改路径**。gated 模型需配置 `HF_TOKEN`。

```bash
uv run python main.py download              # 列出服务 ↔ 模型 ↔ 本地目录
uv run python main.py download scheduler    # llm + SDXL 槽位 + ip_adapter + voice
uv run python main.py download all          # 除 playwright 外全部推理服务
uv run python main.py download gguf         # llm + emb + ocr
uv run python main.py download llm voice    # 按服务名组合
```

| 服务 | 本地目录 | 说明 |
|------|----------|------|
| `llm` | `models/qwen2.5-7b-instruct-gguf` | Qwen2.5-7B Instruct GGUF |
| `emb` | `models/qwen3-embedding-0.6b-gguf` | Qwen3 Embedding |
| `ocr` | `models/paddleocr-vl-gguf` | PaddleOCR-VL |
| `sdxl_juggernaut` | `models/juggernaut-xl` | Juggernaut XL |
| `sdxl_illustrious` | `models/illustrious-xl` | Illustrious XL diffusers |
| `ip_adapter` | `models/sdxl-base-1.0` + `models/ip-adapter-h94` | SDXL 基模 + h94 权重 |
| `voice` | `models/omnivoice-k2-fsa` | OmniVoice TTS |
| `playwright` | — | 无模型 |

Hub 缓存：`models/.hf_hub`（见 `.env` 附录）。GGUF 文件名在代码中固定（见 [`gguf_resolve.py`](src/gguf_resolve.py)）。

Story 起步：

```bash
uv run python main.py download scheduler
```

Illustrious 仅需 `sdxl_illustrious` 对应目录；Juggernaut 单文件 checkpoint 模式会共用 `models/sdxl-base-1.0`。

---

## 配置

| 文件 | 说明 |
|------|------|
| `.env.example` | 分 **全局 / Story Studio / 模型调优 / 可选服务** 四层；端口与下载见文件末尾附录 |
| `.env` | 复制 example 后本地修改；Story 只需关注 `DEVICE`、`LLM_N_CTX`；模型路径不可配 |

`.env.example` 结构：

1. **全局** — `DEVICE`、`TOOLS_MEMORY_PROFILE`、`LLM_N_CTX`、`HF_TOKEN` 等
2. **Story Studio** — scheduler 槽位 A/B/C（llm、SDXL、ip_adapter、voice）
3. **模型调优** — 第 2b 节注释块（按需取消注释）
4. **可选** — emb / ocr / playwright（注释块，按需启用）
5. **附录** — 默认端口、超时、下载命令（不必写入 `.env`）

全局只需设 **`DEVICE`**，GGUF layer 与 PyTorch 设备均由 [`tools_env.py`](src/tools_env.py) 推导：

| `DEVICE` | Qwen2.5 GGUF | SDXL / IP-Adapter | OmniVoice | Embed / OCR |
|----------|--------------|-------------------|-----------|-------------|
| `cpu` | CPU | CPU | CPU fp32 | CPU |
| `mps` | Metal 全 offload | MPS fp16 | MPS fp16 | CPU |
| `cuda` | CUDA 全 offload | cuda:0 fp16 | cuda:0 fp16 | CPU |

### CPU / GPU 配置示例（32GB）

复制 `.env.example` 为 `.env` 后，按机器改 **`DEVICE`** 与 **`LLM_N_CTX`** 即可：

**CPU（无 GPU、或纯调试）**

```env
DEVICE=cpu
LLM_N_CTX=4096
TOOLS_MEMORY_PROFILE=32g
```

**GPU · Apple Silicon**

```env
DEVICE=mps
LLM_N_CTX=8192
TOOLS_MEMORY_PROFILE=32g
```

**GPU · NVIDIA（Linux）**

```env
DEVICE=cuda
LLM_N_CTX=8192
TOOLS_MEMORY_PROFILE=32g
```

内存充裕时 `LLM_N_CTX` 可试 `12288`（8K~16K）；scheduler 槽位互斥不变（llm 与 SDXL 仍不能同时常驻）。

常用其它项：`BIND_HOST`、`LOGS_DIR`、`HF_TOKEN`。

### 模型调优

**优先级**：HTTP 请求体 / Story Studio 业务参数 → `.env` → [`tools_env.py`](src/tools_env.py) 代码默认。

Story Studio 定妆、分镜等接口会传入 `num_inference_steps`、`guidance_scale`、`width`、`height`、`seed` 等，**以请求为准**；未传时使用 `.env` 或下表默认值。

#### 全局与内存

| 变量 | 默认 | 调优说明 |
|------|------|----------|
| `DEVICE` | `mps`（Darwin 自动） | `cpu` / `mps` / `cuda`；唯一 GPU 开关 |
| `LLM_N_CTX` | `8192` | 影响 Qwen KV 占用；32GB GPU 推荐 8192，CPU 用 4096 |
| `TOOLS_MEMORY_PROFILE` | `32g` | scheduler 标识；槽位互斥策略见上文 |

#### 槽位 A · llm（Qwen2.5-7B GGUF）

| 变量 | 默认 | 调优说明 |
|------|------|----------|
| `LLM_MAX_TOKENS` | `-1` | 单次回复 token 上限，`-1` 不限制 |
| `LLM_TEMPERATURE` | `0` | `0` 确定性输出；略升增加多样性 |
| `LLM_GGUF_VERBOSE` | `0` | 设 `1` 调试 GGUF/Metal 加载 |

权重文件：`models/qwen2.5-7b-instruct-gguf/qwen2.5-7b-instruct-q4_k_m.gguf`（固定，见 `gguf_resolve.py`）。

#### 槽位 B · SDXL 定妆（juggernaut / illustrious）

| 变量 | juggernaut 默认 | illustrious 默认 | 调优说明 |
|------|-----------------|------------------|----------|
| `*_NUM_INFERENCE_STEPS` | `20` | `28` | 步数越多越慢、细节可能更好 |
| `*_GUIDANCE_SCALE` | `5.0` | `7.0` | cfg 过高易过饱和、过低易发灰 |
| `*_SEED` | 空 | 空 | 整数可复现同一张图 |

请求级还可传：`width`、`height`（默认 1024）、`negative_prompt`；img2img 另传 `conditioning_image_path`、`img2img_strength`。

#### 槽位 B · ip_adapter（定妆微调）

| 变量 | 默认 | 调优说明 |
|------|------|----------|
| `IP_ADAPTER_NUM_INFERENCE_STEPS` | `28`（example 为 `22`） | 步数；example 略快 |
| `IP_ADAPTER_GUIDANCE_SCALE` | `5.0` | 与 SDXL 类似 |
| `IP_ADAPTER_SCALE_DEFAULT` | `0.55` | 参考脸相似度，常用 0.3~0.7 |
| `IP_ADAPTER_SEED` | 空 | 固定种子复现 |

须先执行 `uv run python main.py download ip_adapter`（固定目录 `models/sdxl-base-1.0` 与 `models/ip-adapter-h94`）。

#### 槽位 C · voice（OmniVoice）

| 变量 | 默认 | 调优说明 |
|------|------|----------|
| `OMNIVOICE_EAGER_LOAD` | 关 | `1` 启动时预加载，首条合成更快 |
| `OMNIVOICE_WARMUP_INSTRUCT` | 英文 instruct | 仅影响启动 warmup，非业务合成 |

合成时的 `text` / `instruct` / 参考音由 API 请求传入。

#### 可选 · emb / ocr

| 服务 | 常用变量 | 默认 | example 推荐 |
|------|----------|------|----------------|
| embed | `EMBED_N_CTX` | `8192` | `4096`（省内存） |
| embed | `EMBED_MAX_INPUT_CHARS` | `6000` | `4000` |
| ocr | `OCR_N_CTX` | `8192` | `4096` |
| ocr | `OCR_MAX_TOKENS` | `4096` | `1536` |
| ocr | `OCR_DEFAULT_PROMPT` | 中文 OCR 提示 | 可改识别指令 |

完整可调项见 [`.env.example`](.env.example) 第 2b 节注释块。

---

## 目录

```
tools/
  main.py              # CLI（含 download）
  service_ctl/         # 进程管理 + 模型下载
  src/                 # FastAPI 服务
    sdxl_checkpoint/   # 定妆 SDXL（槽位 B：juggernaut / illustrious 共用 infer + http）
    sdxl_*_service.py  # 各 capability 薄入口（scheduler 按名拉起）
  models/              # 权重（含 qwen2.5-7b-instruct-gguf）
  logs/                # pid / 日志
  tests/
```

Story 默认 prompt / 风格预设：`server/plugin/ds/storyStudio/src/Support/DefaultPrompt/`。
