"""Illustrious XL v1.0：diffusers 目录 + Euler Ancestral。"""

from __future__ import annotations

import logging
from pathlib import Path

from diffusers import EulerAncestralDiscreteScheduler, StableDiffusionXLPipeline

from sdxl_checkpoint.config import SdxlServiceConfig
from sdxl_checkpoint.runtime import SdxlRuntime
from tools_env import sdxl_illustrious_env, torch_device, torch_dtype_for_device


def load_illustrious_pipeline(model_dir: Path, logger: logging.Logger) -> StableDiffusionXLPipeline:
    dev = torch_device()
    dt = torch_dtype_for_device(dev)
    kw: dict = {
        "torch_dtype": dt,
        "local_files_only": True,
        "use_safetensors": True,
    }
    if (model_dir / "unet" / "diffusion_pytorch_model.fp16.safetensors").is_file():
        kw["variant"] = "fp16"
    pipe = StableDiffusionXLPipeline.from_pretrained(str(model_dir), **kw)
    pipe.scheduler = EulerAncestralDiscreteScheduler.from_config(pipe.scheduler.config)
    pipe.to(dev)
    logger.info("[sdxl_illustrious] loaded diffusers dir=%s device=%s", model_dir, dev)
    return pipe


def build_illustrious_runtime(logger: logging.Logger) -> SdxlRuntime:
    env = sdxl_illustrious_env()
    cfg = SdxlServiceConfig(
        capability="sdxl_illustrious",
        log_label="sdxl_illustrious",
        num_inference_steps=env.num_inference_steps,
        guidance_scale=env.guidance_scale,
        seed=env.seed,
    )

    def _load(log: logging.Logger) -> StableDiffusionXLPipeline:
        return load_illustrious_pipeline(env.model_dir, log)

    return SdxlRuntime(cfg, _load, logger)
