from __future__ import annotations

import asyncio
import gc
import logging
import threading
import time
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict, Field

from gguf_backend import load_gguf_chat
from gguf_resolve import LLM_MAIN_GGUF_PREFERRED, pick_main_not_mmproj
from tools_env import bind_host, llm_env, log_request_ok, uvicorn_access_log

CHAT_PATH = "/v1/llm/chat/completions"

logger = logging.getLogger("llm_service")

_llm_lock = asyncio.Lock()
_engine_lock = threading.Lock()
_gguf_engine: Any = None


def _get_engine() -> Any:
    global _gguf_engine
    with _engine_lock:
        if _gguf_engine is not None:
            return _gguf_engine

        cfg = llm_env()
        main_gguf = pick_main_not_mmproj(
            cfg.model_dir,
            env_main="LLM_GGUF_MAIN",
            preferred=LLM_MAIN_GGUF_PREFERRED,
        )
        if main_gguf is None:
            raise FileNotFoundError(f"No LLM GGUF in {cfg.model_dir}")

        t0 = time.perf_counter()
        _gguf_engine = load_gguf_chat(
            main_gguf,
            n_ctx=cfg.n_ctx,
            n_gpu_layers=cfg.n_gpu_layers,
            verbose=cfg.gguf_verbose,
        )
        logger.info("[model] loaded %.1fs %s", time.perf_counter() - t0, main_gguf.name)
        try:
            _gguf_engine.create_chat_completion(
                messages=[{"role": "user", "content": "ping"}],
                temperature=0.0,
                max_tokens=16,
            )
            logger.info("[model] warmup ok")
        except Exception as e:
            logger.error("[model] warmup failed: %s", e)
        return _gguf_engine


def _unload_models_sync() -> None:
    global _gguf_engine
    _gguf_engine = None
    gc.collect()


@asynccontextmanager
async def _lifespan(_app: FastAPI):
    logger.info("[startup] listening (models load on first %s)", CHAT_PATH)
    try:
        yield
    finally:
        await asyncio.to_thread(_unload_models_sync)
        logger.info("[shutdown] ok")


app = FastAPI(title="llm_service", version="0.7.0", lifespan=_lifespan)


class ChatCompletionsBody(BaseModel):
    model_config = ConfigDict(extra="ignore")

    model: str | None = None
    messages: list[dict[str, Any]] = Field(..., min_length=1)
    stream: bool = False


def _response_model_name() -> str:
    cfg = llm_env()
    return cfg.model_name or "qwen2.5-7b-instruct-q4_k_m"


def _to_openai(raw: dict[str, Any]) -> dict[str, Any]:
    choice = (raw.get("choices") or [{}])[0]
    msg = choice.get("message") or {}
    model_id = _response_model_name()
    return {
        "id": "chatcmpl-local",
        "object": "chat.completion",
        "model": model_id,
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": msg.get("role", "assistant"),
                    "content": (msg.get("content") or "").strip(),
                },
                "finish_reason": str(choice.get("finish_reason") or "stop"),
            }
        ],
    }


def _sync_chat(messages: list[dict[str, Any]]) -> dict[str, Any]:
    cfg = llm_env()
    raw = _get_engine().create_chat_completion(
        messages=messages,
        temperature=cfg.temperature,
        max_tokens=cfg.max_tokens,
    )
    return _to_openai(raw)


@app.post(CHAT_PATH)
async def chat_completions(req: ChatCompletionsBody):
    if req.stream:
        raise HTTPException(status_code=400, detail="暂不支持 stream，请传 stream: false")
    async with _llm_lock:
        t0 = time.perf_counter()
        try:
            payload = await asyncio.to_thread(_sync_chat, req.messages)
        except Exception as e:
            logger.error("[chat] failed: %s", e, exc_info=True)
            raise HTTPException(status_code=502, detail=str(e)) from e
    choice = (payload.get("choices") or [{}])[0]
    content = (choice.get("message") or {}).get("content") or ""
    log_request_ok(
        logger,
        "chat",
        t0,
        finish_reason=choice.get("finish_reason"),
        output_chars=len(content),
    )
    return payload


def main() -> None:
    import uvicorn

    cfg = llm_env()
    uvicorn.run(
        app,
        host=bind_host("0.0.0.0"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
