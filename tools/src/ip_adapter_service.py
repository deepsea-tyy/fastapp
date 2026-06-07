"""SDXL + IP-Adapter 人设定妆微调（diffusers）。与 PHP StoryInferenceGateway 对齐。"""

from __future__ import annotations

import threading
import time
from typing import Literal

import torch
from diffusers import StableDiffusionXLPipeline
from fastapi import FastAPI, HTTPException
from transformers import CLIPVisionModelWithProjection
from PIL import Image
from pydantic import BaseModel

import inference_job_store as job_store
from tools_env import (
    bind_host,
    ip_adapter_env,
    ip_adapter_vit_h_image_encoder_dir,
    log_request_ok,
    setup_service_logger,
    torch_device,
    torch_dtype_for_device,
    uvicorn_access_log,
)

logger = setup_service_logger("ip_adapter_service")

_pipe_lock = threading.Lock()
_pipe: StableDiffusionXLPipeline | None = None


def _ensure_pipe() -> StableDiffusionXLPipeline:
    global _pipe
    with _pipe_lock:
        if _pipe is not None:
            return _pipe
        cfg = ip_adapter_env()
        src = str(cfg.base_model_dir)
        weight_src = str(cfg.ip_adapter_weight_dir)
        dev = torch_device()
        dt = torch_dtype_for_device(dev)
        logger.info(
            "[ip_adapter] loading base=%s weights=%s device=%s dtype=%s",
            src,
            weight_src,
            dev,
            dt,
        )
        enc_dir = ip_adapter_vit_h_image_encoder_dir(cfg)
        image_encoder = CLIPVisionModelWithProjection.from_pretrained(
            str(enc_dir), torch_dtype=dt, local_files_only=True
        )
        _pipe = StableDiffusionXLPipeline.from_pretrained(
            src,
            image_encoder=image_encoder,
            torch_dtype=dt,
            local_files_only=True,
        )
        _pipe.load_ip_adapter(
            weight_src,
            subfolder=cfg.ip_adapter_subfolder,
            weight_name=cfg.ip_adapter_weight_name,
            image_encoder_folder=None,
            local_files_only=True,
        )
        _pipe.to(dev)
        return _pipe


def _generator(request_seed: int | None) -> torch.Generator | None:
    cfg = ip_adapter_env()
    seed = request_seed if request_seed is not None else cfg.seed
    if seed is None:
        return None
    dev = torch_device()
    return torch.Generator(device=dev).manual_seed(int(seed) % (2**31))


def _ip_scale(request_scale: float | None) -> float:
    if request_scale is not None:
        return float(request_scale)
    return ip_adapter_env().default_ip_adapter_scale


app = FastAPI(title="Story Studio IP-Adapter", version="0.1.0")


class IpAdapterPortraitBody(BaseModel):
    prompt: str = ""
    output_path: str = ""
    conditioning_image_path: str = ""
    negative_prompt: str | None = None
    task: Literal["keyframe", "cast_portrait"] | None = None
    frame_type: str | None = None
    width: int | None = None
    height: int | None = None
    seed: int | None = None
    conditioning_mode: Literal["img2img", "ip_adapter"] | None = None
    img2img_strength: float | None = None
    ip_adapter_scale: float | None = None
    num_inference_steps: int | None = None
    guidance_scale: float | None = None
    job_id: str | None = None


def _track(job_id: str | None) -> bool:
    return bool((job_id or "").strip())


@app.get("/v1/ip_adapter/inference-jobs/{job_id}")
def get_inference_job(job_id: str):
    job_store.evict_expired()
    rec = job_store.get(job_id)
    if rec is None:
        raise HTTPException(status_code=404, detail=f"job not found: {job_id}")
    return rec.to_dict()


@app.post("/v1/ip_adapter/img2img")
def ip_adapter_img2img(b: IpAdapterPortraitBody):
    t0 = time.perf_counter()
    cfg = ip_adapter_env()
    out = resolve_tools_path(b.output_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    track = _track(b.job_id)
    jid = (b.job_id or "").strip()

    cond = resolve_tools_path(b.conditioning_image_path)
    w = b.width if b.width and b.width > 0 else 1024
    h = b.height if b.height and b.height > 0 else 1024

    steps = b.num_inference_steps or cfg.num_inference_steps
    if track:
        job_store.create(jid, capability="ip_adapter", total_steps=steps)
        job_store.mark_running(jid, phase="loading")

    try:
        pipe = _ensure_pipe()
    except Exception as e:
        if track:
            job_store.finish_error(jid, f"pipeline load failed: {e}")
        raise HTTPException(status_code=503, detail=f"IP-Adapter pipeline load failed: {e}") from e

    if track:
        pipe.set_progress_bar_config(disable=True)
        job_store.mark_running(jid, phase="denoise")

    scale = _ip_scale(b.ip_adapter_scale)
    pipe.set_ip_adapter_scale(scale)

    ref = Image.open(cond).convert("RGB")
    gen = _generator(b.seed)
    gen_kw: dict = {
        "prompt": (b.prompt or "").strip() or " ",
        "ip_adapter_image": ref,
        "width": w,
        "height": h,
        "num_inference_steps": steps,
        "guidance_scale": b.guidance_scale or cfg.guidance_scale,
    }
    neg = (b.negative_prompt or "").strip()
    if neg:
        gen_kw["negative_prompt"] = neg
    if gen is not None:
        gen_kw["generator"] = gen
    if track:
        gen_kw["callback_on_step_end"] = job_store.make_step_callback(jid, total_steps=steps)

    try:
        with _pipe_lock:
            images = pipe(**gen_kw).images

        if track:
            job_store.mark_running(jid, phase="save")
        images[0].save(out, format="PNG")
        if track:
            job_store.finish_ok(jid, output_path=str(out))
    except HTTPException as e:
        if track:
            detail = e.detail if isinstance(e.detail, str) else str(e.detail)
            job_store.finish_error(jid, detail)
        raise
    except Exception as e:
        if track:
            job_store.finish_error(jid, str(e))
        raise HTTPException(status_code=502, detail=str(e)) from e

    payload = {
        "ok": True,
        "output_path": str(out),
        "width": w,
        "height": h,
        "ip_adapter_scale": scale,
    }
    if track:
        payload["job_id"] = jid
    log_request_ok(logger, "ip_adapter_portrait", t0, size=f"{w}x{h}", scale=scale)
    return payload


def main() -> None:
    import uvicorn

    cfg = ip_adapter_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
