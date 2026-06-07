"""Scheduler 槽位 B：sdxl_illustrious（二次元定妆 Illustrious XL v1.0）。"""

from __future__ import annotations

from sdxl_checkpoint import build_illustrious_runtime, create_checkpoint_app
from tools_env import bind_host, sdxl_illustrious_env, setup_service_logger, uvicorn_access_log

logger = setup_service_logger("sdxl_illustrious_service")
_runtime = build_illustrious_runtime(logger)

app = create_checkpoint_app(
    title="Story Studio SDXL Illustrious",
    version="0.2.0",
    model_id="sdxl_illustrious",
    runtime=_runtime,
)


def main() -> None:
    import uvicorn

    cfg = sdxl_illustrious_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
