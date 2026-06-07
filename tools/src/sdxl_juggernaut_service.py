"""Scheduler 槽位 B：sdxl_juggernaut（写实定妆 Juggernaut XL）。"""

from __future__ import annotations

from sdxl_checkpoint import build_juggernaut_runtime, create_checkpoint_app
from tools_env import bind_host, sdxl_juggernaut_env, setup_service_logger, uvicorn_access_log

logger = setup_service_logger("sdxl_juggernaut_service")
_runtime = build_juggernaut_runtime(logger)

app = create_checkpoint_app(
    title="Story Studio SDXL Juggernaut",
    version="0.2.0",
    model_id="sdxl_juggernaut",
    runtime=_runtime,
)


def main() -> None:
    import uvicorn

    cfg = sdxl_juggernaut_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
