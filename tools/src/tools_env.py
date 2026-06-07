"""tools 全局配置：启动时加载 ``tools/.env``，各服务通过 ``*_env()`` 读取固定参数。"""

from __future__ import annotations

import logging
import os
import platform
import time
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

TOOLS_ROOT = Path(__file__).resolve().parent.parent
MODELS_DIR = (TOOLS_ROOT / "models").resolve()

LLM_MODEL_DIR = (MODELS_DIR / "qwen2.5-7b-instruct-gguf").resolve()
EMBED_MODEL_DIR = (MODELS_DIR / "qwen3-embedding-0.6b-gguf").resolve()
OCR_MODEL_DIR = (MODELS_DIR / "paddleocr-vl-gguf").resolve()
JUGGERNAUT_MODEL_DIR = (MODELS_DIR / "juggernaut-xl").resolve()
ILLUSTRIOUS_MODEL_DIR = (MODELS_DIR / "illustrious-xl").resolve()
SDXL_BASE_MODEL_DIR = (MODELS_DIR / "sdxl-base-1.0").resolve()
IP_ADAPTER_WEIGHT_DIR = (MODELS_DIR / "ip-adapter-h94").resolve()
OMNIVOICE_MODEL_DIR = (MODELS_DIR / "omnivoice-k2-fsa").resolve()


def hf_hub_cache_dir() -> Path:
    """HF 下载缓存目录（仅 ``main.py download`` 使用；推理服务只读本地模型）。"""
    raw = env_str("HF_HUB_CACHE", "")
    if raw:
        p = Path(raw).expanduser()
        return p.resolve() if p.is_absolute() else (TOOLS_ROOT / p).resolve()
    return (MODELS_DIR / ".hf_hub").resolve()


def configure_hf_cache() -> Path:
    """进程内统一 HF 缓存目录；各服务 import tools_env 时自动执行。"""
    hub = hf_hub_cache_dir()
    hub.mkdir(parents=True, exist_ok=True)
    os.environ["HF_HOME"] = str(hub)
    os.environ["HF_HUB_CACHE"] = str(hub)
    tf_cache = hub / "transformers"
    tf_cache.mkdir(parents=True, exist_ok=True)
    os.environ["TRANSFORMERS_CACHE"] = str(tf_cache)
    return hub


def resolve_optional_local_path(raw: str) -> Path | None:
    raw = (raw or "").strip()
    if not raw:
        return None
    p = Path(raw).expanduser()
    return p.resolve() if p.is_absolute() else (TOOLS_ROOT / p).resolve()


def first_existing_dir(*candidates: Path | None) -> Path | None:
    for p in candidates:
        if p is not None and p.is_dir():
            return p
    return None


def setup_service_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    if not logger.handlers:
        h = logging.StreamHandler()
        h.setFormatter(logging.Formatter("%(asctime)s %(message)s"))
        logger.addHandler(h)
        logger.setLevel(logging.INFO)
        logger.propagate = False
    return logger


def log_request_ok(logger: logging.Logger, tag: str, t0: float, **fields: object) -> None:
    ms = int((time.perf_counter() - t0) * 1000)
    if not fields:
        logger.info("[%s] ok elapsed_ms=%d", tag, ms)
        return
    extra = " ".join(f"{k}={v}" for k, v in fields.items())
    logger.info("[%s] ok elapsed_ms=%d %s", tag, ms, extra)


def _load_dotenv() -> None:
    try:
        from dotenv import load_dotenv

        load_dotenv(TOOLS_ROOT / ".env", override=False)
    except ImportError:
        pass


_load_dotenv()


def env_str(key: str, default: str = "") -> str:
    v = os.environ.get(key)
    if v is None:
        return default
    return v.strip() or default


def env_bool(key: str, default: bool = False) -> bool:
    raw = env_str(key, "")
    if not raw:
        return default
    return raw.lower() in ("1", "true", "yes", "on")


def env_int(key: str, default: int) -> int:
    raw = env_str(key, "")
    if not raw:
        return default
    return int(raw)


def env_float(key: str, default: float) -> float:
    raw = env_str(key, "")
    if not raw:
        return default
    return float(raw)


def env_optional_int(key: str) -> int | None:
    raw = env_str(key, "")
    if not raw:
        return None
    return int(raw)


def bind_host(default: str = "127.0.0.1") -> str:
    return env_str("BIND_HOST", default) or default


def uvicorn_access_log() -> bool:
    v = env_str("TOOLS_UVICORN_ACCESS", "1").lower()
    return v not in ("0", "false", "no", "off")


def device_str() -> str:
    raw = env_str("DEVICE", "").lower()
    if raw:
        return raw
    if platform.system() == "Darwin":
        import torch

        return "mps" if torch.backends.mps.is_available() else "cpu"
    try:
        if Path("/proc/driver/nvidia/version").is_file():
            text = Path("/proc/driver/nvidia/version").read_text(encoding="utf-8", errors="ignore")
            if "NVIDIA" in text:
                return "cuda"
    except OSError:
        pass
    return "cpu"


def gguf_n_gpu_layers(cap: str) -> int:
    if device_str() == "cpu":
        return 0
    return -1 if cap == "llm" else 0


def resolve_tools_path(raw: str, *, default: Path | None = None) -> Path:
    s = (raw or "").strip()
    if not s:
        if default is None:
            raise ValueError("resolve_tools_path: empty path and no default")
        return default.resolve()
    p = Path(s).expanduser()
    if p.is_absolute():
        return p.resolve()
    return (TOOLS_ROOT / p).resolve()


def torch_device():
    import torch

    d = device_str()
    if d == "mps" and torch.backends.mps.is_available():
        return torch.device("mps")
    if d in ("cuda", "gpu") and torch.cuda.is_available():
        return torch.device("cuda:0" if d == "cuda" else "cuda")
    return torch.device("cpu")


def torch_dtype_for_device(dev) -> Any:
    import torch

    if dev.type == "cuda":
        return torch.bfloat16 if torch.cuda.is_bf16_supported() else torch.float16
    if dev.type == "mps":
        return torch.float16
    return torch.float32


def hf_device_map(dev) -> str:
    return str(dev) if dev.type == "cuda" else dev.type


@dataclass(frozen=True)
class LlmEnv:
    port: int
    model_dir: Path
    model_name: str
    n_ctx: int
    n_gpu_layers: int
    gguf_verbose: bool
    temperature: float
    max_tokens: int


@lru_cache(maxsize=1)
def llm_env() -> LlmEnv:
    max_raw = env_str("LLM_MAX_TOKENS", "-1")
    max_tokens = int(max_raw) if max_raw else -1
    if max_tokens <= 0:
        max_tokens = -1
    model_name = env_str("LLM_MODEL_NAME", "qwen2.5-7b-instruct-q4_k_m")
    return LlmEnv(
        port=env_int("LLM_PORT", 8000),
        model_dir=LLM_MODEL_DIR,
        model_name=model_name,
        n_ctx=env_int("LLM_N_CTX", 8192),
        n_gpu_layers=gguf_n_gpu_layers("llm"),
        gguf_verbose=env_bool("LLM_GGUF_VERBOSE"),
        temperature=env_float("LLM_TEMPERATURE", 0.0),
        max_tokens=max_tokens,
    )


@dataclass(frozen=True)
class EmbedEnv:
    port: int
    model_dir: Path
    model_id: str
    n_ctx: int
    max_input_chars: int
    n_gpu_layers: int
    n_batch_cap: int


@lru_cache(maxsize=1)
def embed_env() -> EmbedEnv:
    n_batch_cap = 512 if device_str() != "cpu" else 1024
    return EmbedEnv(
        port=env_int("EMB_PORT", 8002),
        model_dir=EMBED_MODEL_DIR,
        model_id=env_str("EMBED_MODEL_ID", "qwen3-embedding-0.6b-gguf"),
        n_ctx=env_int("EMBED_N_CTX", 8192),
        max_input_chars=env_int("EMBED_MAX_INPUT_CHARS", 6000),
        n_gpu_layers=gguf_n_gpu_layers("emb"),
        n_batch_cap=n_batch_cap,
    )


@dataclass(frozen=True)
class OcrEnv:
    port: int
    model_dir: Path
    model_name: str
    n_ctx: int
    n_gpu_layers: int
    gguf_verbose: bool
    mtmd_verbose: bool
    max_tokens: int
    temperature: float
    top_p: float
    default_prompt: str


@lru_cache(maxsize=1)
def ocr_env() -> OcrEnv:
    return OcrEnv(
        port=env_int("OCR_PORT", 8001),
        model_dir=OCR_MODEL_DIR,
        model_name=env_str("OCR_MODEL_NAME", "paddleocr-vl-1.5-gguf"),
        n_ctx=env_int("OCR_N_CTX", 8192),
        n_gpu_layers=gguf_n_gpu_layers("ocr"),
        gguf_verbose=env_bool("OCR_GGUF_VERBOSE"),
        mtmd_verbose=env_bool("OCR_MTMD_VERBOSE"),
        max_tokens=env_int("OCR_MAX_TOKENS", 4096),
        temperature=env_float("OCR_TEMPERATURE", 0.0),
        top_p=env_float("OCR_TOP_P", 0.95),
        default_prompt=env_str(
            "OCR_DEFAULT_PROMPT",
            "请识别并输出图片中的全部文字，尽量保持阅读顺序与版面结构。",
        ),
    )



@dataclass(frozen=True)
class SdxlCheckpointEnv:
    port: int
    model_dir: Path
    num_inference_steps: int
    guidance_scale: float
    seed: int | None


def _sdxl_env(prefix: str, model_dir: Path, port: int, steps: int, cfg: float) -> SdxlCheckpointEnv:
    return SdxlCheckpointEnv(
        port=env_int(f"{prefix}_PORT", port),
        model_dir=model_dir,
        num_inference_steps=env_int(f"{prefix}_NUM_INFERENCE_STEPS", steps),
        guidance_scale=env_float(f"{prefix}_GUIDANCE_SCALE", cfg),
        seed=env_optional_int(f"{prefix}_SEED"),
    )


@lru_cache(maxsize=1)
def sdxl_juggernaut_env() -> SdxlCheckpointEnv:
    return _sdxl_env("SDXL_JUGGERNAUT", JUGGERNAUT_MODEL_DIR, 8009, 20, 5.0)


@lru_cache(maxsize=1)
def sdxl_illustrious_env() -> SdxlCheckpointEnv:
    return _sdxl_env("SDXL_ILLUSTRIOUS", ILLUSTRIOUS_MODEL_DIR, 8010, 28, 7.0)


@dataclass(frozen=True)
class IpAdapterEnv:
    port: int
    base_model_dir: Path
    ip_adapter_weight_dir: Path
    ip_adapter_subfolder: str
    ip_adapter_weight_name: str
    num_inference_steps: int
    guidance_scale: float
    default_ip_adapter_scale: float
    seed: int | None


def ip_adapter_weight_path(cfg: IpAdapterEnv | None = None) -> Path:
    c = cfg or ip_adapter_env()
    return c.ip_adapter_weight_dir / c.ip_adapter_subfolder / c.ip_adapter_weight_name


def ip_adapter_vit_h_image_encoder_dir(cfg: IpAdapterEnv | None = None) -> Path:
    """Plus / Plus Face（vit-h）须 ``models/image_encoder``（hidden 1280），非 ``sdxl_models/image_encoder``（1664）。"""
    c = cfg or ip_adapter_env()
    return c.ip_adapter_weight_dir / "models" / "image_encoder"


@lru_cache(maxsize=1)
def ip_adapter_env() -> IpAdapterEnv:
    return IpAdapterEnv(
        port=env_int("IP_ADAPTER_PORT", 8008),
        base_model_dir=SDXL_BASE_MODEL_DIR,
        ip_adapter_weight_dir=IP_ADAPTER_WEIGHT_DIR,
        ip_adapter_subfolder=env_str("IP_ADAPTER_WEIGHT_SUBFOLDER", "sdxl_models"),
        ip_adapter_weight_name=env_str(
            "IP_ADAPTER_WEIGHT_NAME",
            "ip-adapter-plus-face_sdxl_vit-h.safetensors",
        ),
        num_inference_steps=env_int("IP_ADAPTER_NUM_INFERENCE_STEPS", 28),
        guidance_scale=env_float("IP_ADAPTER_GUIDANCE_SCALE", 5.0),
        default_ip_adapter_scale=env_float("IP_ADAPTER_SCALE_DEFAULT", 0.55),
        seed=env_optional_int("IP_ADAPTER_SEED"),
    )


@dataclass(frozen=True)
class OmnivoiceEnv:
    port: int
    model_dir: Path
    preview_default_text: str
    warmup_default_instruct: str
    preview_text_en: str
    warmup_en_instruct: str
    eager_load: bool


@lru_cache(maxsize=1)
def omnivoice_env() -> OmnivoiceEnv:
    return OmnivoiceEnv(
        port=env_int("OMNIVOICE_PORT", 8005),
        model_dir=OMNIVOICE_MODEL_DIR,
        preview_default_text=env_str("OMNIVOICE_PREVIEW_DEFAULT_TEXT", "这是我的声音"),
        warmup_default_instruct=env_str(
            "OMNIVOICE_WARMUP_INSTRUCT",
            "female, young adult, moderate pitch",
        ),
        preview_text_en=env_str("OMNIVOICE_PREVIEW_TEXT_EN", "This is my voice"),
        warmup_en_instruct=env_str(
            "OMNIVOICE_WARMUP_EN_INSTRUCT",
            "female, young adult, high pitch, british accent",
        ),
        eager_load=env_bool("OMNIVOICE_EAGER_LOAD"),
    )


@dataclass(frozen=True)
class PlaywrightEnv:
    port: int
    headless: bool
    proxy: str
    user_agent: str
    locale: str
    accept_language: str
    goto_wait_until: str


@lru_cache(maxsize=1)
def playwright_env() -> PlaywrightEnv:
    return PlaywrightEnv(
        port=env_int("PW_PORT", env_int("PLAYWRIGHT_PORT", 8003)),
        headless=env_bool("PLAYWRIGHT_HEADLESS", default=True),
        proxy=env_str("PLAYWRIGHT_PROXY"),
        user_agent=env_str(
            "PLAYWRIGHT_UA",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 "
            "(KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
        ),
        locale=env_str("PLAYWRIGHT_LOCALE", "zh-CN"),
        accept_language=env_str("PLAYWRIGHT_ACCEPT_LANGUAGE", "zh-CN,zh;q=0.9,en;q=0.8"),
        goto_wait_until=env_str("PLAYWRIGHT_GOTO_WAIT_UNTIL", "domcontentloaded"),
    )


configure_hf_cache()
