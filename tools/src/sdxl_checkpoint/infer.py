"""txt2img / img2img 推理循环（pipeline 由 runtime 注入）。"""

from __future__ import annotations

import logging
import threading
import time
from typing import Any, Callable

import torch
from fastapi import HTTPException
from PIL import Image

import inference_job_store as job_store
from sdxl_checkpoint.config import SdxlServiceConfig
from sdxl_checkpoint.request import SdxlInferRequest
from tools_env import log_request_ok, resolve_tools_path, torch_device

Pipe = Any
GetPipe = Callable[[bool], Pipe]


def _generator(seed: int | None, default_seed: int | None) -> torch.Generator | None:
    s = seed if seed is not None else default_seed
    if s is None:
        return None
    return torch.Generator(device=torch_device()).manual_seed(int(s) % (2**31))


def _normalize_isolated_bottom(img: Image.Image, tw: int, th: int, side_pad: int = 32, bottom_pad: int = 32) -> Image.Image:
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    rgba = img.convert("RGBA")
    bbox = rgba.getchannel("A").getbbox() or (0, 0, rgba.width, rgba.height)
    subject = rgba.crop(bbox)
    avail_w = tw - side_pad * 2
    avail_h = th - bottom_pad - side_pad
    scale = min(avail_w / subject.width, avail_h / subject.height)
    nw = max(1, int(subject.width * scale))
    nh = max(1, int(subject.height * scale))
    resized = subject.resize((nw, nh), Image.Resampling.LANCZOS)
    x = (tw - nw) // 2
    y = th - bottom_pad - nh
    canvas.paste(resized, (x, y), resized)
    return canvas


def _normalize_scene_cover(img: Image.Image, tw: int, th: int) -> Image.Image:
    rgb = img.convert("RGB")
    iw, ih = rgb.size
    scale = max(tw / iw, th / ih)
    nw = max(1, int(iw * scale))
    nh = max(1, int(ih * scale))
    resized = rgb.resize((nw, nh), Image.Resampling.LANCZOS)
    left = (nw - tw) // 2
    top = (nh - th) // 2
    return resized.crop((left, top, left + tw, top + th))


def _normalize_canvas(img: Image.Image, tw: int, th: int, fit: str) -> Image.Image:
    if fit == "isolated_bottom":
        return _normalize_isolated_bottom(img, tw, th)
    if fit == "scene_cover":
        return _normalize_scene_cover(img, tw, th)
    return img


def _resolve_steps_and_guidance(req: SdxlInferRequest, cfg: SdxlServiceConfig) -> tuple[int, float]:
    steps = req.num_inference_steps if req.num_inference_steps is not None else cfg.num_inference_steps
    guidance = req.guidance_scale if req.guidance_scale is not None else cfg.guidance_scale
    if cfg.min_inference_steps is not None:
        steps = max(steps, cfg.min_inference_steps)
    if cfg.min_guidance_scale is not None:
        guidance = max(guidance, cfg.min_guidance_scale)
    return steps, guidance


def run_infer(
    *,
    req: SdxlInferRequest,
    cfg: SdxlServiceConfig,
    logger: logging.Logger,
    get_pipe: GetPipe,
    pipe_lock: threading.Lock,
    img2img: bool,
) -> dict:
    t0 = time.perf_counter()
    out = resolve_tools_path(req.output_path)
    out.parent.mkdir(parents=True, exist_ok=True)

    jid = (req.job_id or "").strip()
    track = bool(jid)
    steps, guidance = _resolve_steps_and_guidance(req, cfg)
    strength = req.img2img_strength if req.img2img_strength is not None else cfg.default_img2img_strength
    mode = "img2img" if img2img else "txt2img"

    if track:
        job_store.create(jid, capability=cfg.capability, total_steps=steps)
        job_store.mark_running(jid, phase="loading")

    try:
        pipe = get_pipe(img2img)
    except Exception as e:
        if track:
            job_store.finish_error(jid, f"pipeline load failed: {e}")
        raise HTTPException(
            status_code=503,
            detail=f"SDXL {cfg.log_label} load failed: {e}",
        ) from e

    if track:
        pipe.set_progress_bar_config(disable=True)
        job_store.mark_running(jid, phase="denoise")

    gen_kw: dict[str, Any] = {
        "prompt": (req.prompt or "").strip() or " ",
        "num_inference_steps": steps,
        "guidance_scale": guidance,
        **cfg.extra_generate_kwargs,
    }
    if (req.negative_prompt or "").strip():
        gen_kw["negative_prompt"] = req.negative_prompt.strip()
    gen = _generator(req.seed, cfg.seed)
    if gen is not None:
        gen_kw["generator"] = gen
    if track:
        gen_kw["callback_on_step_end"] = job_store.make_step_callback(jid, total_steps=steps)

    out_w = req.output_canvas_width
    out_h = req.output_canvas_height
    out_fit = (req.output_canvas_fit or "").strip()

    try:
        with pipe_lock:
            if img2img:
                cond = (req.conditioning_image_path or "").strip()
                ip = resolve_tools_path(cond)
                gen_kw["image"] = Image.open(ip).convert("RGB").resize(
                    (req.width, req.height), Image.Resampling.LANCZOS
                )
                gen_kw["strength"] = strength
            else:
                gen_kw["width"] = req.width
                gen_kw["height"] = req.height
            images = pipe(**gen_kw).images

        if track:
            job_store.mark_running(jid, phase="save")
        image = images[0]
        if req.remove_background:
            from rembg import remove

            image = remove(image.convert("RGBA"))
        if out_w and out_h and out_fit:
            image = _normalize_canvas(image, int(out_w), int(out_h), out_fit)
        image.save(out, format="PNG")
        if track:
            job_store.finish_ok(jid, output_path=str(out))
    except HTTPException as e:
        if track:
            job_store.finish_error(jid, e.detail if isinstance(e.detail, str) else str(e.detail))
        raise
    except Exception as e:
        if track:
            job_store.finish_error(jid, str(e))
        raise HTTPException(status_code=502, detail=str(e)) from e

    log_request_ok(
        logger,
        cfg.log_label,
        t0,
        steps=steps,
        size=f"{req.width}x{req.height}",
        mode=mode,
    )
    payload_w = int(out_w) if out_w and out_h and out_fit else req.width
    payload_h = int(out_h) if out_w and out_h and out_fit else req.height
    payload: dict[str, Any] = {
        "ok": True,
        "output_path": str(out),
        "width": payload_w,
        "height": payload_h,
        "num_inference_steps": steps,
        "guidance_scale": guidance,
    }
    if cfg.extra_generate_kwargs:
        payload.update({k: v for k, v in cfg.extra_generate_kwargs.items() if k != "callback_on_step_end"})
    if track:
        payload["job_id"] = jid
    return payload
