"""Story Studio 推理调度：按内存槽位启停 tools 进程。"""

from __future__ import annotations

import asyncio
import logging
import os
import sys
import time
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict

# tools 根目录加入 path，供 import service_ctl
_TOOLS_ROOT = Path(__file__).resolve().parent.parent
_SRC_DIR = _TOOLS_ROOT / "src"
if str(_TOOLS_ROOT) not in sys.path:
    sys.path.insert(0, str(_TOOLS_ROOT))
if str(_SRC_DIR) not in sys.path:
    sys.path.insert(0, str(_SRC_DIR))

import service_ctl as proc  # noqa: E402
from scheduler_logic import (  # noqa: E402
    conflicts_to_stop,
    ensure_unchanged,
    memory_profile,
)
from tools_env import bind_host, env_str, uvicorn_access_log  # noqa: E402

logger = logging.getLogger("scheduler_service")

_ensure_lock = asyncio.Lock()
_last_switch_ms: int | None = None


def _active_capabilities() -> set[str]:
    active: set[str] = set()
    for name in proc.SCHEDULABLE_CAPABILITIES:
        if proc.is_service_up(name):
            active.add(name)
    return active


def _scheduler_profile() -> str:
    return memory_profile(os.environ.get("TOOLS_MEMORY_PROFILE") or env_str("TOOLS_MEMORY_PROFILE", "32g"))


class EnsureBody(BaseModel):
    model_config = ConfigDict(extra="ignore")

    capability: str
    profile: str | None = None


class ReleaseBody(BaseModel):
    model_config = ConfigDict(extra="ignore")

    capability: str


def _validate_capability(capability: str) -> None:
    if capability not in proc.SCHEDULABLE_CAPABILITIES:
        raise HTTPException(
            status_code=400,
            detail=f"未知 capability: {capability}（可选: {', '.join(sorted(proc.SCHEDULABLE_CAPABILITIES))}）",
        )


def _run_ensure_sync(body: EnsureBody) -> dict[str, Any]:
    global _last_switch_ms
    capability = body.capability.strip()

    _validate_capability(capability)

    active = _active_capabilities()

    if ensure_unchanged(capability=capability, is_up=capability in active):
        return {
            "capability": capability,
            "base_url": proc.service_base_url(capability),
            "changed": False,
            "stopped": [],
            "started": [],
        }

    stopped: list[str] = []
    started: list[str] = []
    changed = False

    to_stop = conflicts_to_stop(
        capability,
        active=active,
    )

    for name in reversed(proc.SERVICES_ORDER):
        if name in to_stop:
            if proc.is_service_up(name) or proc.read_pid(name) is not None:
                proc.stop_one(name)
                stopped.append(name)
                changed = True

    if capability not in active or capability in stopped:
        ok = proc.start_one(capability, daemon=True)
        if not ok:
            log_path = proc.logfile_path(capability)
            raise RuntimeError(f"启动 {capability} 失败，见 {log_path}")
        started.append(capability)
        changed = True

    if changed:
        _last_switch_ms = int(time.time() * 1000)

    return {
        "capability": capability,
        "base_url": proc.service_base_url(capability),
        "changed": changed,
        "stopped": stopped,
        "started": started,
    }


def _run_release_sync(capability: str) -> dict[str, Any]:
    _validate_capability(capability)
    stopped: list[str] = []
    if proc.is_service_up(capability) or proc.read_pid(capability) is not None:
        proc.stop_one(capability)
        stopped.append(capability)
    return {"capability": capability, "stopped": stopped}


def _status_payload() -> dict[str, Any]:
    caps: dict[str, Any] = {}
    for name in sorted(proc.SCHEDULABLE_CAPABILITIES):
        pid = proc.read_pid(name)
        port = proc.port_for(name)
        tcp = proc.tcp_port_open("127.0.0.1", port)
        caps[name] = {
            "pid": pid,
            "tcp": tcp,
            "port": port,
            "base_url": proc.service_base_url(name),
        }
    return {
        "profile": _scheduler_profile(),
        "active_slot": list(_active_capabilities()),
        "last_switch_ms": _last_switch_ms,
        "capabilities": caps,
    }


def _stop_scheduled_on_shutdown() -> None:
    stopped = proc.stop_scheduled_capabilities()
    if stopped:
        logger.info("[shutdown] 已停止槽位进程: %s", ", ".join(stopped))
    else:
        logger.info("[shutdown] ok")


@asynccontextmanager
async def _lifespan(_app: FastAPI):
    logger.info("[startup] scheduler profile=%s", _scheduler_profile())
    yield
    await asyncio.to_thread(_stop_scheduled_on_shutdown)


app = FastAPI(title="scheduler_service", version="0.2.0", lifespan=_lifespan)


@app.post("/v1/scheduler/ensure")
async def scheduler_ensure(body: EnsureBody):
    async with _ensure_lock:
        try:
            return await asyncio.to_thread(_run_ensure_sync, body)
        except HTTPException:
            raise
        except Exception as e:
            logger.error("[ensure] failed: %s", e, exc_info=True)
            raise HTTPException(status_code=502, detail=str(e)) from e


@app.get("/v1/scheduler/status")
async def scheduler_status():
    return await asyncio.to_thread(_status_payload)


@app.post("/v1/scheduler/release")
async def scheduler_release(body: ReleaseBody):
    async with _ensure_lock:
        try:
            return await asyncio.to_thread(_run_release_sync, body.capability.strip())
        except HTTPException:
            raise
        except Exception as e:
            logger.error("[release] failed: %s", e, exc_info=True)
            raise HTTPException(status_code=502, detail=str(e)) from e


def main() -> None:
    import uvicorn

    port = proc.port_for("scheduler")
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
