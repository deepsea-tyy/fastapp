from __future__ import annotations

import asyncio
import logging
import time

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, ConfigDict, Field

from gguf_backend import load_gguf_embedding
from gguf_resolve import EMBED_GGUF_PREFERRED
from tools_env import bind_host, embed_env, log_request_ok, uvicorn_access_log

logger = logging.getLogger("embed_service")

app = FastAPI(title="embed_service", version="0.7.0")
_embed_lock = asyncio.Lock()
_gguf_engine: object | None = None


def _embed_sync(texts: list[str]) -> list[list[float]]:
    global _gguf_engine
    cfg = embed_env()
    if _gguf_engine is None:
        gguf_path = cfg.model_dir / EMBED_GGUF_PREFERRED[0]
        n_batch = min(cfg.n_ctx, cfg.n_batch_cap)
        _gguf_engine = load_gguf_embedding(
            gguf_path,
            n_ctx=cfg.n_ctx,
            n_batch=n_batch,
            n_gpu_layers=cfg.n_gpu_layers,
            verbose=False,
        )

    clipped = [t if len(t) <= cfg.max_input_chars else t[: cfg.max_input_chars] for t in texts]
    vecs = _gguf_engine.embed(clipped, normalize=True, truncate=True)  # type: ignore[attr-defined]
    return [[float(x) for x in row] for row in vecs]


class EmbeddingsRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    input: str | list[str] = Field(..., description="单条或多条文本")


def _embedding_payload(vectors: list[list[float]]) -> dict:
    cfg = embed_env()
    data = [{"object": "embedding", "embedding": vec, "index": i} for i, vec in enumerate(vectors)]
    return {
        "object": "list",
        "data": data,
        "model": cfg.model_id,
        "usage": {"prompt_tokens": 0, "total_tokens": 0},
    }


@app.post("/v1/embeddings")
async def embeddings(req: EmbeddingsRequest):
    t0 = time.perf_counter()
    raw = [req.input] if isinstance(req.input, str) else req.input
    texts = [t for t in (s.strip() for s in raw) if t]
    if not texts:
        log_request_ok(logger, "embeddings", t0, count=0)
        return _embedding_payload([])

    try:
        async with _embed_lock:
            vectors = await asyncio.to_thread(_embed_sync, texts)
    except Exception as e:
        logger.error("embeddings failed: %s", e, exc_info=True)
        raise HTTPException(status_code=502, detail=str(e)) from e

    payload = _embedding_payload(vectors)
    log_request_ok(logger, "embeddings", t0, count=len(vectors))
    return payload


def main() -> None:
    import uvicorn

    cfg = embed_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
