from __future__ import annotations

import os
import tempfile
import threading
import time
import wave
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any, Iterator

import numpy as np
from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel

from tools_env import (
    bind_host,
    hf_device_map,
    log_request_ok,
    omnivoice_env,
    setup_service_logger,
    torch_device,
    uvicorn_access_log,
)

SAMPLE_RATE = 24_000

logger = setup_service_logger("omnivoice_service")

_model_lock = threading.Lock()
_model = None
_load_error: str | None = None


def _sync_device(dev) -> None:
    import torch

    if dev.type == "cuda":
        torch.cuda.synchronize()
    elif dev.type == "mps":
        torch.mps.synchronize()


def _warmup_profiles() -> Iterator[dict[str, Any]]:
    """与 Story Studio 试听一致的 Voice Design 参数（中/英 instruct 各一条）。"""
    cfg = omnivoice_env()
    yield {
        "text": cfg.preview_default_text,
        "instruct": cfg.warmup_default_instruct,
    }
    yield {
        "text": cfg.preview_text_en,
        "instruct": cfg.warmup_en_instruct,
    }


def _warmup_model(model, dev) -> bool:
    profiles = list(_warmup_profiles())
    last_err: BaseException | None = None
    for attempt in range(2):
        try:
            for kwargs in profiles:
                model.generate(**kwargs)
                _sync_device(dev)
            logger.info("[model] warmup ok (%d profile(s))", len(profiles))
            return True
        except Exception as e:
            last_err = e
            logger.error("[model] warmup attempt %d/%d failed: %s", attempt + 1, 2, e)
    logger.error("[model] warmup failed after retries: %s", last_err)
    return False


def _get_model():
    global _model, _load_error
    with _model_lock:
        if _model is not None:
            return _model
        bundle = omnivoice_env().model_dir

        try:
            import torch
            from omnivoice import OmniVoice
        except ImportError as e:
            _load_error = None
            logger.warning("[model] omnivoice 未安装: %s", e)
            return None

        _load_error = None
        dev = torch_device()
        device = hf_device_map(dev)
        t0 = time.perf_counter()
        local_dir = str(bundle)
        _model = OmniVoice.from_pretrained(
            local_dir,
            device_map=device,
            dtype=torch.float16 if dev.type != "cpu" else torch.float32,
        )
        logger.info("[model] loaded %.1fs %s device=%s", time.perf_counter() - t0, local_dir, device)
        _warmup_model(_model, dev)
        return _model


def _write_wav(path: Path, audio_1d=None, *, silent_sec: float = 0.3) -> None:
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        if audio_1d is None:
            w.writeframes(b"\x00\x00" * max(1, int(SAMPLE_RATE * silent_sec)))
            return
        x = np.clip(np.asarray(audio_1d, dtype=np.float64).reshape(-1), -1.0, 1.0)
        w.writeframes((x * 32767.0).astype(np.int16).tobytes())


def _synthesize_wav(b: OmniVoiceBody, out: Path) -> tuple[str, str | None]:
    if not (b.text or "").strip():
        _write_wav(out, silent_sec=0.1)
        return "stub_empty_text", None

    model = _get_model()
    if model is None:
        _write_wav(out, silent_sec=0.4)
        return ("stub_missing_bundle", _load_error) if _load_error else ("stub_no_package", None)

    kwargs: dict = {"text": b.text}
    if ins := (b.instruct or "").strip():
        kwargs["instruct"] = ins
    ref = (b.reference_audio_path or "").strip()
    if ref and Path(ref).is_file():
        kwargs["ref_audio"] = ref
        if rt := (b.ref_text or "").strip():
            kwargs["ref_text"] = rt

    try:
        audio = model.generate(**kwargs)
    except Exception as e:
        logger.exception("[tts] %s", e)
        _write_wav(out, silent_sec=0.2)
        return "stub_error", str(e)

    if not audio:
        _write_wav(out, silent_sec=0.15)
        return "stub_no_audio", None

    _write_wav(out, audio[0])
    return "omnivoice", None


@asynccontextmanager
async def _lifespan(_app: FastAPI):
    if omnivoice_env().eager_load:
        logger.info("[startup] OMNIVOICE_EAGER_LOAD enabled, preloading model")
        _get_model()
    yield


app = FastAPI(title="omnivoice_service", version="0.2.0", lifespan=_lifespan)


class OmniVoiceBody(BaseModel):
    text: str = ""
    instruct: str | None = None
    reference_audio_path: str | None = None
    ref_text: str | None = None
    output_path: str | None = None


@app.post("/v1/voice/synthesize")
def voice_synthesize(b: OmniVoiceBody):
    """``output_path`` 非空则落盘返回 JSON，否则返回 WAV 试听流。"""
    t0 = time.perf_counter()
    raw_out = (b.output_path or "").strip()
    if raw_out:
        out = Path(raw_out).expanduser().resolve()
        out.parent.mkdir(parents=True, exist_ok=True)
        mode, detail = _synthesize_wav(b, out)
        resp: dict = {"ok": True, "output_path": str(out), "mode": mode}
        if detail:
            resp["detail"] = detail
        log_request_ok(logger, "omnivoice_preview", t0, mode=mode, saved=1)
        return resp

    if not (b.text or "").strip():
        b = b.model_copy(update={"text": omnivoice_env().preview_default_text})

    fd, tmp = tempfile.mkstemp(suffix=".wav", prefix="story_omnivoice_")
    os.close(fd)
    mode, detail = _synthesize_wav(b, Path(tmp))
    headers: dict[str, str] = {"X-OmniVoice-Mode": mode}
    if detail:
        headers["X-OmniVoice-Detail"] = detail[:400]
    log_request_ok(logger, "omnivoice_preview", t0, mode=mode, stream=1)
    return FileResponse(tmp, media_type="audio/wav", filename="preview.wav", headers=headers)


def main() -> None:
    import uvicorn

    cfg = omnivoice_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
