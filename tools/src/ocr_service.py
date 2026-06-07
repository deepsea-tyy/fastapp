from __future__ import annotations

import asyncio
import base64
import logging
import io
import os
import tempfile
import time
from pathlib import Path
from typing import Annotated, Any

from fastapi import FastAPI, File, HTTPException, UploadFile
from pydantic import BaseModel, ConfigDict, Field
from PIL import Image

from gguf_backend import PaddleOCRVLChatHandler, load_gguf_vl
from gguf_resolve import OCR_MAIN_GGUF_PREFERRED, OCR_MMPROJ_PREFERRED
from tools_env import bind_host, log_request_ok, ocr_env, uvicorn_access_log

logger = logging.getLogger("ocr_service")

app = FastAPI(title="ocr_service", version="0.4.0")
_ocr_lock = asyncio.Lock()
_gguf_engine: Any | None = None
_backend = ""


def _load_sync() -> None:
    global _gguf_engine, _backend
    if _gguf_engine is not None:
        return

    cfg = ocr_env()
    main_gguf = cfg.model_dir / OCR_MAIN_GGUF_PREFERRED[0]
    mmproj = cfg.model_dir / OCR_MMPROJ_PREFERRED[0]

    chat_handler = PaddleOCRVLChatHandler(str(mmproj), verbose=cfg.mtmd_verbose)
    _gguf_engine = load_gguf_vl(
        main_gguf,
        chat_handler,
        n_ctx=cfg.n_ctx,
        n_gpu_layers=cfg.n_gpu_layers,
        verbose=cfg.gguf_verbose,
    )
    _backend = "gguf"


def _image_path_from_bytes(raw: bytes, suffix: str) -> str:
    img = Image.open(io.BytesIO(raw))
    img = img.convert("RGB")
    fd, path = tempfile.mkstemp(suffix=suffix or ".png")
    os.close(fd)
    img.save(path, format="PNG")
    return path


def _data_url_for_path(image_path: str) -> str:
    raw = Path(image_path).read_bytes()
    b64 = base64.standard_b64encode(raw).decode("ascii")
    return f"data:image/png;base64,{b64}"


def _predict_sync(image_path: str) -> str:
    assert _gguf_engine is not None
    cfg = ocr_env()
    data_url = _data_url_for_path(image_path)
    messages = [
        {
            "role": "user",
            "content": [
                {"type": "image_url", "image_url": data_url},
                {"type": "text", "text": cfg.default_prompt},
            ],
        }
    ]
    out = _gguf_engine.create_chat_completion(
        messages=messages,
        max_tokens=cfg.max_tokens,
        temperature=cfg.temperature,
        top_p=cfg.top_p,
    )
    choice = (out.get("choices") or [{}])[0]
    msg = choice.get("message") or {}
    return (msg.get("content") or "").strip()


class OCRJsonBody(BaseModel):
    model_config = ConfigDict(extra="forbid")

    image_base64: str = Field(..., description="纯 base64，不要 data URL 前缀")


@app.post("/v1/ocr")
async def ocr_json(body: OCRJsonBody):
    t0 = time.perf_counter()
    b64 = body.image_base64.strip()
    if b64.startswith("data:") and "," in b64:
        b64 = b64.split(",", 1)[1]
    try:
        try:
            raw = base64.standard_b64decode(b64, validate=False)
        except TypeError:
            raw = base64.standard_b64decode(b64)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"base64 无效: {e}") from e
    if not raw:
        raise HTTPException(status_code=400, detail="空图片")
    path = _image_path_from_bytes(raw, ".png")
    cfg = ocr_env()
    try:
        async with _ocr_lock:
            await asyncio.to_thread(_load_sync)
            text = await asyncio.to_thread(_predict_sync, path)
    except Exception as e:
        logger.error("ocr /v1/ocr failed: %s", e, exc_info=True)
        raise HTTPException(status_code=502, detail=str(e)) from e
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass
    payload = {"model": cfg.model_name, "text": text, "raw": {}}
    log_request_ok(logger, "ocr", t0, text_chars=len(text))
    return payload


@app.post("/v1/ocr/upload")
async def ocr_upload(image: Annotated[UploadFile, File(description="待识别图片")]):
    t0 = time.perf_counter()
    raw = await image.read()
    if not raw:
        raise HTTPException(status_code=400, detail="空文件")
    ext = Path(image.filename or "img").suffix or ".png"
    path = _image_path_from_bytes(raw, ext)
    cfg = ocr_env()
    try:
        async with _ocr_lock:
            await asyncio.to_thread(_load_sync)
            text = await asyncio.to_thread(_predict_sync, path)
    except Exception as e:
        logger.error("ocr /v1/ocr/upload failed: %s", e, exc_info=True)
        raise HTTPException(status_code=502, detail=str(e)) from e
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass
    payload = {"model": cfg.model_name, "text": text, "raw": {}}
    log_request_ok(logger, "ocr_upload", t0, text_chars=len(text))
    return payload


def main() -> None:
    import uvicorn

    cfg = ocr_env()
    uvicorn.run(
        app,
        host=bind_host("0.0.0.0"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
