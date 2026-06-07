"""推理 Job 进度内存存储（sdxl_juggernaut / sdxl_illustrious / ip_adapter 共用）。"""

from __future__ import annotations

import threading
import time
from dataclasses import dataclass, field
from typing import Any, Literal

Capability = Literal["sdxl_juggernaut", "sdxl_illustrious", "ip_adapter"]
JobStatus = Literal["pending", "running", "done", "failed"]
JobPhase = Literal["loading", "denoise", "save"]

DEFAULT_TTL_SEC = 3600


@dataclass
class JobRecord:
    job_id: str
    capability: Capability
    status: JobStatus = "pending"
    progress: int = 0
    step: int = 0
    total_steps: int = 0
    phase: JobPhase | None = None
    message: str = ""
    output_path: str | None = None
    error: str | None = None
    updated_at: float = field(default_factory=time.monotonic)

    def to_dict(self) -> dict[str, Any]:
        return {
            "ok": True,
            "job_id": self.job_id,
            "capability": self.capability,
            "status": self.status,
            "progress": self.progress,
            "step": self.step,
            "total_steps": self.total_steps,
            "phase": self.phase,
            "message": self.message,
            "output_path": self.output_path,
            "error": self.error,
            "updated_at": self.updated_at,
        }


_lock = threading.Lock()
_jobs: dict[str, JobRecord] = {}


def _touch(rec: JobRecord) -> None:
    rec.updated_at = time.monotonic()


def create(job_id: str, *, capability: Capability, total_steps: int) -> JobRecord:
    with _lock:
        rec = JobRecord(
            job_id=job_id,
            capability=capability,
            status="pending",
            total_steps=max(1, int(total_steps)),
            message="pending",
        )
        _jobs[job_id] = rec
        return rec


def mark_running(job_id: str, *, phase: JobPhase, message: str | None = None) -> None:
    with _lock:
        rec = _jobs.get(job_id)
        if rec is None:
            return
        rec.status = "running"
        rec.phase = phase
        if message is not None:
            rec.message = message
        elif phase == "loading":
            rec.message = "loading pipeline"
        elif phase == "denoise":
            rec.message = "denoising"
        elif phase == "save":
            rec.message = "saving image"
        _touch(rec)


def update_step(job_id: str, step: int, *, total_steps: int | None = None) -> None:
    with _lock:
        rec = _jobs.get(job_id)
        if rec is None:
            return
        total = max(1, int(total_steps if total_steps is not None else rec.total_steps))
        rec.total_steps = total
        rec.step = max(0, min(int(step), total))
        rec.status = "running"
        rec.phase = "denoise"
        rec.progress = int(rec.step / total * 100)
        rec.message = f"denoising {rec.step}/{total}"
        _touch(rec)


def finish_ok(job_id: str, *, output_path: str) -> None:
    with _lock:
        rec = _jobs.get(job_id)
        if rec is None:
            return
        rec.status = "done"
        rec.phase = "save"
        rec.progress = 100
        rec.step = rec.total_steps
        rec.output_path = output_path
        rec.message = "done"
        rec.error = None
        _touch(rec)


def finish_error(job_id: str, error: str) -> None:
    with _lock:
        rec = _jobs.get(job_id)
        if rec is None:
            return
        rec.status = "failed"
        rec.error = error
        rec.message = error
        _touch(rec)


def get(job_id: str) -> JobRecord | None:
    with _lock:
        rec = _jobs.get(job_id)
        if rec is None:
            return None
        return rec


def evict_expired(ttl_sec: float = DEFAULT_TTL_SEC) -> int:
    cutoff = time.monotonic() - ttl_sec
    with _lock:
        stale = [jid for jid, rec in _jobs.items() if rec.updated_at < cutoff]
        for jid in stale:
            del _jobs[jid]
        return len(stale)


def make_step_callback(job_id: str, *, total_steps: int):
    """diffusers callback_on_step_end；勿在 callback 内抢 _pipe_lock。"""

    def _on_step_end(_pipe, step_index, _timestep, callback_kwargs):
        update_step(job_id, step_index + 1, total_steps=total_steps)
        return callback_kwargs

    return _on_step_end


def reset_for_tests() -> None:
    with _lock:
        _jobs.clear()
