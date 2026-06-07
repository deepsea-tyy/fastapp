"""定妆推理请求（juggernaut / illustrious 共用）。"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class SdxlInferRequest:
    prompt: str = ""
    output_path: str = ""
    negative_prompt: str | None = None
    width: int = 1024
    height: int = 1024
    seed: int | None = None
    num_inference_steps: int | None = None
    guidance_scale: float | None = None
    conditioning_image_path: str | None = None
    img2img_strength: float | None = None
    job_id: str | None = None
    remove_background: bool = False
    output_canvas_width: int | None = None
    output_canvas_height: int | None = None
    output_canvas_fit: str | None = None
