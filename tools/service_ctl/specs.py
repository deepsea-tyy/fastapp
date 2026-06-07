"""服务规格、环境与路径。"""

from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from service_ctl.constants import SCHEDULER_SERVICE, SRC_DIR, TOOLS_ROOT


@dataclass(frozen=True)
class ServiceSpec:
    name: str
    script: Path
    port_env: str
    port_default: int
    needs_device: bool = True
    needs_playwright: bool = False


def _service_specs() -> dict[str, ServiceSpec]:
    return {
        "emb": ServiceSpec("emb", SRC_DIR / "embed_service.py", "EMB_PORT", 8002),
        "ocr": ServiceSpec("ocr", SRC_DIR / "ocr_service.py", "OCR_PORT", 8001),
        "llm": ServiceSpec("llm", SRC_DIR / "llm_service.py", "LLM_PORT", 8000),
        "playwright": ServiceSpec(
            "playwright",
            SRC_DIR / "playwright_service.py",
            "PW_PORT",
            8003,
            needs_device=False,
            needs_playwright=True,
        ),
        "sdxl_juggernaut": ServiceSpec(
            "sdxl_juggernaut",
            SRC_DIR / "sdxl_juggernaut_service.py",
            "SDXL_JUGGERNAUT_PORT",
            8009,
        ),
        "sdxl_illustrious": ServiceSpec(
            "sdxl_illustrious", SRC_DIR / "sdxl_illustrious_service.py", "SDXL_ILLUSTRIOUS_PORT", 8010
        ),
        "ip_adapter": ServiceSpec(
            "ip_adapter", SRC_DIR / "ip_adapter_service.py", "IP_ADAPTER_PORT", 8008
        ),
        "voice": ServiceSpec("voice", SRC_DIR / "omnivoice_service.py", "OMNIVOICE_PORT", 8005),
        SCHEDULER_SERVICE: ServiceSpec(
            SCHEDULER_SERVICE,
            SRC_DIR / "scheduler_service.py",
            "SCHEDULER_PORT",
            8012,
            needs_device=False,
        ),
    }


def logs_dir() -> Path:
    raw = os.environ.get("LOGS_DIR", "logs").strip() or "logs"
    p = Path(raw)
    if not p.is_absolute():
        p = TOOLS_ROOT / p
    return p.resolve()


def port_for(name: str) -> int:
    spec = _service_specs()[name]
    raw = os.environ.get(spec.port_env, "").strip()
    if raw:
        return int(raw)
    return spec.port_default


def service_base_url(name: str) -> str:
    from tools_env import bind_host

    host = bind_host()
    if host in ("0.0.0.0", "::"):
        host = "127.0.0.1"
    return f"http://{host}:{port_for(name)}"

