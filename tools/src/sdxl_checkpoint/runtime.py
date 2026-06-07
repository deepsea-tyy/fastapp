"""懒加载 txt2img / img2img pipeline，委托 infer 执行推理。"""

from __future__ import annotations

import logging
import threading
from typing import Callable

from diffusers import StableDiffusionXLImg2ImgPipeline, StableDiffusionXLPipeline

from sdxl_checkpoint.config import SdxlServiceConfig
from sdxl_checkpoint.infer import run_infer
from sdxl_checkpoint.request import SdxlInferRequest
from tools_env import torch_device

LoadTxt2img = Callable[[logging.Logger], StableDiffusionXLPipeline]


class SdxlRuntime:
    def __init__(
        self,
        cfg: SdxlServiceConfig,
        load_txt2img: LoadTxt2img,
        logger: logging.Logger,
    ) -> None:
        self._cfg = cfg
        self._load_txt2img = load_txt2img
        self._logger = logger
        self._pipe_lock = threading.Lock()
        self._txt2img: StableDiffusionXLPipeline | None = None
        self._img2img: StableDiffusionXLImg2ImgPipeline | None = None

    def _get_pipe(self, img2img: bool) -> StableDiffusionXLPipeline | StableDiffusionXLImg2ImgPipeline:
        with self._pipe_lock:
            if img2img:
                if self._img2img is None:
                    base = self._txt2img or self._load_txt2img(self._logger)
                    self._txt2img = base
                    self._img2img = StableDiffusionXLImg2ImgPipeline.from_pipe(base)
                return self._img2img
            if self._txt2img is None:
                self._logger.info("[%s] load txt2img device=%s", self._cfg.log_label, torch_device())
                self._txt2img = self._load_txt2img(self._logger)
            return self._txt2img

    def run_txt2img(self, req: SdxlInferRequest) -> dict:
        return run_infer(
            req=req,
            cfg=self._cfg,
            logger=self._logger,
            get_pipe=self._get_pipe,
            pipe_lock=self._pipe_lock,
            img2img=False,
        )

    def run_img2img(self, req: SdxlInferRequest) -> dict:
        return run_infer(
            req=req,
            cfg=self._cfg,
            logger=self._logger,
            get_pipe=self._get_pipe,
            pipe_lock=self._pipe_lock,
            img2img=True,
        )
