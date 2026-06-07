"""单 checkpoint 服务运行时配置（对应 scheduler 一个 capability）。"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any


@dataclass(frozen=True)
class SdxlServiceConfig:
    capability: str
    log_label: str
    num_inference_steps: int
    guidance_scale: float
    seed: int | None
    min_inference_steps: int | None = None
    min_guidance_scale: float | None = None
    default_img2img_strength: float = 0.45
    extra_generate_kwargs: dict[str, Any] = field(default_factory=dict)
