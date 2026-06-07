"""SDXL 定妆 checkpoint（scheduler 槽位 B，与 juggernaut / illustrious / ip_adapter 互斥）。

入口（各独立进程，由 scheduler ensure 拉起其一）::

  sdxl_juggernaut_service.py    →  capability ``sdxl_juggernaut``   写实 Juggernaut XL
  sdxl_illustrious_service.py   →  capability ``sdxl_illustrious``  二次元 Illustrious XL

本包分层::

  http.py      FastAPI 路由（txt2img / img2img / job 查询）
  runtime.py   懒加载 pipeline + 调用 infer
  infer.py     推理与 job 进度（与具体模型无关）
  loaders/     各 checkpoint 的 diffusers 加载方式
"""

from sdxl_checkpoint.config import SdxlServiceConfig
from sdxl_checkpoint.http import create_checkpoint_app
from sdxl_checkpoint.loaders.illustrious import build_illustrious_runtime
from sdxl_checkpoint.loaders.juggernaut import build_juggernaut_runtime
from sdxl_checkpoint.request import SdxlInferRequest
from sdxl_checkpoint.runtime import SdxlRuntime

__all__ = [
    "SdxlInferRequest",
    "SdxlRuntime",
    "SdxlServiceConfig",
    "build_illustrious_runtime",
    "build_juggernaut_runtime",
    "create_checkpoint_app",
]
