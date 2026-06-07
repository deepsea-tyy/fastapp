"""Story Studio checkpoint HTTP（juggernaut / illustrious 共用路由形状）。"""

from __future__ import annotations

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

import inference_job_store as job_store
from sdxl_checkpoint.request import SdxlInferRequest
from sdxl_checkpoint.runtime import SdxlRuntime


class SdxlTxt2imgBody(BaseModel):
    prompt: str = ""
    output_path: str = ""
    negative_prompt: str | None = None
    width: int = 1024
    height: int = 1024
    seed: int | None = None
    num_inference_steps: int | None = None
    guidance_scale: float | None = None
    job_id: str | None = None
    remove_background: bool = False
    output_canvas_width: int | None = None
    output_canvas_height: int | None = None
    output_canvas_fit: str | None = None


class SdxlImg2imgBody(SdxlTxt2imgBody):
    conditioning_image_path: str = ""
    img2img_strength: float | None = None


def body_to_request(b: SdxlTxt2imgBody | SdxlImg2imgBody) -> SdxlInferRequest:
    kw: dict = {
        "prompt": b.prompt,
        "output_path": b.output_path,
        "negative_prompt": b.negative_prompt,
        "width": b.width,
        "height": b.height,
        "seed": b.seed,
        "num_inference_steps": b.num_inference_steps,
        "guidance_scale": b.guidance_scale,
        "job_id": b.job_id,
        "remove_background": b.remove_background,
        "output_canvas_width": b.output_canvas_width,
        "output_canvas_height": b.output_canvas_height,
        "output_canvas_fit": b.output_canvas_fit,
    }
    if isinstance(b, SdxlImg2imgBody):
        kw["conditioning_image_path"] = b.conditioning_image_path
        kw["img2img_strength"] = b.img2img_strength
    return SdxlInferRequest(**kw)


def create_checkpoint_app(
    *,
    title: str,
    version: str,
    model_id: str,
    runtime: SdxlRuntime,
) -> FastAPI:
    """``model_id`` 如 ``sdxl_juggernaut`` → ``/v1/sdxl_juggernaut/txt2img``。"""
    app = FastAPI(title=title, version=version)
    base = f"/v1/{model_id}"

    @app.get(f"{base}/inference-jobs/{{job_id}}")
    def get_inference_job(job_id: str):
        job_store.evict_expired()
        rec = job_store.get(job_id)
        if rec is None:
            raise HTTPException(status_code=404, detail=f"job not found: {job_id}")
        return rec.to_dict()

    @app.post(f"{base}/txt2img")
    def txt2img(b: SdxlTxt2imgBody):
        return runtime.run_txt2img(body_to_request(b))

    @app.post(f"{base}/img2img")
    def img2img(b: SdxlImg2imgBody):
        return runtime.run_img2img(body_to_request(b))

    return app
