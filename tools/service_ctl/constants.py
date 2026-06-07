"""服务名、端口与就绪超时常量。"""

from __future__ import annotations

from pathlib import Path

TOOLS_ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = TOOLS_ROOT / "src"

INFERENCE_SERVICES = (
    "emb",
    "ocr",
    "llm",
    "playwright",
    "sdxl_juggernaut",
    "sdxl_illustrious",
    "ip_adapter",
    "voice",
)

SCHEDULER_SERVICE = "scheduler"

SERVICES_ORDER = INFERENCE_SERVICES + (SCHEDULER_SERVICE,)

SCHEDULABLE_CAPABILITIES = frozenset(
    {"llm", "sdxl_juggernaut", "sdxl_illustrious", "ip_adapter", "voice"}
)

READY_TIMEOUT_ENV: dict[str, str] = {
    "llm": "LLM_READY_TIMEOUT_SEC",
    "sdxl_juggernaut": "SDXL_JUGGERNAUT_READY_TIMEOUT_SEC",
    "sdxl_illustrious": "SDXL_ILLUSTRIOUS_READY_TIMEOUT_SEC",
    "ip_adapter": "IP_ADAPTER_READY_TIMEOUT_SEC",
    "voice": "OMNIVOICE_READY_TIMEOUT_SEC",
}

READY_TIMEOUT_DEFAULT: dict[str, int] = {
    "llm": 900,
    "sdxl_juggernaut": 900,
    "sdxl_illustrious": 900,
    "ip_adapter": 900,
    "voice": 120,
}
