"""Juggernaut XL：单文件 .safetensors 或 diffusers 目录 + 可选 SDXL base。"""

from __future__ import annotations

import logging
from pathlib import Path

import torch
from diffusers import (
    AutoencoderKL,
    DPMSolverMultistepScheduler,
    StableDiffusionXLPipeline,
)

from sdxl_checkpoint.config import SdxlServiceConfig
from sdxl_checkpoint.runtime import SdxlRuntime
from tools_env import (
    SDXL_BASE_MODEL_DIR,
    sdxl_juggernaut_env,
    torch_device,
    torch_dtype_for_device,
)

_SCHEDULER_CFG = {
    "algorithm_type": "sde-dpmsolver++",
    "use_karras_sigmas": True,
    "beta_schedule": "scaled_linear",
    "beta_start": 0.00085,
    "beta_end": 0.012,
    "timestep_spacing": "leading",
    "steps_offset": 1,
}


def _find_single_file_checkpoint(path: Path) -> tuple[Path, Path | None]:
    safetensors = sorted(path.glob("*.safetensors"), key=lambda p: p.stat().st_size, reverse=True)
    main: Path | None = None
    vae: Path | None = None
    for f in safetensors:
        if "vae" in f.name.lower():
            vae = vae or f
        elif main is None:
            main = f
    return main, vae


def _load_single_file(local: Path, dev) -> StableDiffusionXLPipeline:
    ckpt, vae_path = _find_single_file_checkpoint(local)
    dt = torch_dtype_for_device(dev)
    base = StableDiffusionXLPipeline.from_pretrained(
        str(SDXL_BASE_MODEL_DIR), torch_dtype=dt, local_files_only=True, use_safetensors=True
    )
    single_kw: dict = {
        "config": str(SDXL_BASE_MODEL_DIR),
        "torch_dtype": dt,
        "local_files_only": True,
        "text_encoder": base.text_encoder,
        "text_encoder_2": base.text_encoder_2,
        "tokenizer": base.tokenizer,
        "tokenizer_2": base.tokenizer_2,
    }
    if vae_path is not None:
        single_kw["vae"] = AutoencoderKL.from_single_file(str(vae_path), torch_dtype=dt)
    return StableDiffusionXLPipeline.from_single_file(str(ckpt), **single_kw)


def _load_from_dir(src: Path, dev) -> StableDiffusionXLPipeline:
    kw: dict = {
        "torch_dtype": torch_dtype_for_device(dev),
        "local_files_only": True,
        "use_safetensors": True,
    }
    if (src / "unet" / "diffusion_pytorch_model.fp16.safetensors").is_file():
        kw["variant"] = "fp16"
    return StableDiffusionXLPipeline.from_pretrained(str(src), **kw)


def load_juggernaut_pipeline(model_dir: Path, logger: logging.Logger) -> StableDiffusionXLPipeline:
    dev = torch_device()
    if (model_dir / "model_index.json").is_file():
        pipe = _load_from_dir(model_dir, dev)
    else:
        pipe = _load_single_file(model_dir, dev)
    pipe.scheduler = DPMSolverMultistepScheduler.from_config(_SCHEDULER_CFG)
    pipe.to(dev)
    logger.info("[sdxl_juggernaut] loaded %s device=%s", model_dir, dev)
    return pipe


def build_juggernaut_runtime(logger: logging.Logger) -> SdxlRuntime:
    env = sdxl_juggernaut_env()
    cfg = SdxlServiceConfig(
        capability="sdxl_juggernaut",
        log_label="sdxl_juggernaut",
        num_inference_steps=env.num_inference_steps,
        guidance_scale=env.guidance_scale,
        seed=env.seed,
    )

    def _load(log: logging.Logger) -> StableDiffusionXLPipeline:
        return load_juggernaut_pipeline(env.model_dir, log)

    return SdxlRuntime(cfg, _load, logger)
