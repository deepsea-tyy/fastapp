"""未设置 *_GGUF_MAIN / *_MMPROJ 时按固定文件名优先级选权重，避免依赖 mtime（低配 CPU 可稳定复现）。

量化策略：优先 ``Q4_K_M``；次选 ``Q4_K_S``；兜底 Q4（如 ``Q4_0``）。主模型不自动回退 Q8_0 / F16。
"""

from __future__ import annotations

import os
from pathlib import Path

# Qwen/Qwen2.5-7B-Instruct-GGUF（官方小写名 + 社区 Pascal 名）
LLM_MAIN_GGUF_PREFERRED: tuple[str, ...] = (
    "qwen2.5-7b-instruct-q4_k_m.gguf",
    "Qwen2.5-7B-Instruct-Q4_K_M.gguf",
    "qwen2.5-7b-instruct-q4_k_s.gguf",
    "Qwen2.5-7B-Instruct-Q4_K_S.gguf",
    "qwen2.5-7b-instruct-q4_0.gguf",
    "Qwen2.5-7B-Instruct-Q4_0.gguf",
)

# Qwen/Qwen3-Embedding-0.6B-GGUF
EMBED_GGUF_PREFERRED: tuple[str, ...] = (
    "Qwen3-Embedding-0.6B-Q4_K_M.gguf",
    "Qwen3-Embedding-0.6B-Q4_K_S.gguf",
    "Qwen3-Embedding-0.6B-Q4_0.gguf",
)

# PaddlePaddle/PaddleOCR-VL-1.5-GGUF
OCR_MAIN_GGUF_PREFERRED: tuple[str, ...] = ("PaddleOCR-VL-1.5.gguf",)
OCR_MMPROJ_PREFERRED: tuple[str, ...] = ("PaddleOCR-VL-1.5-mmproj.gguf",)

_HIGHER_BIT_QUANT_MARKERS: tuple[str, ...] = ("Q8", "F16", "FP16")


def _env_path(d: Path, raw: str) -> Path:
    p = Path(raw)
    return p if p.is_absolute() else (d / p)


def _resolve_gguf_file(d: Path, raw: str) -> Path | None:
    """单文件 GGUF，或 HuggingFace 分片 ``name-00001-of-NNNN.gguf``（返回首片供 llama.cpp 加载）。"""
    cand = _env_path(d, raw)
    if cand.is_file():
        return cand
    name = cand.name
    if not name.lower().endswith(".gguf"):
        return None
    stem = name[: -len(".gguf")]
    if "-00001-of-" in stem.lower():
        return None
    shards = sorted(d.glob(f"{stem}-00001-of-*.gguf"))
    return shards[0] if shards else None


def _is_q4_main_quant(filename: str) -> bool:
    if "mmproj" in filename.lower():
        return False
    upper = filename.upper()
    if any(m in upper for m in _HIGHER_BIT_QUANT_MARKERS):
        return False
    return "Q4_K_M" in upper or "Q4_K_S" in upper or "Q4_0" in upper or "-Q4_" in upper or "_Q4_" in upper


def _q4_quant_rank(filename: str) -> int:
    upper = filename.upper()
    if "Q4_K_M" in upper:
        return 0
    if "Q4_K_S" in upper:
        return 1
    if "Q4_0" in upper:
        return 2
    return 3


def _pick_from_glob(d: Path, *, want_mmproj: bool) -> Path | None:
    candidates: list[Path] = []
    for g in d.glob("*.gguf"):
        is_mmproj = "mmproj" in g.name.lower()
        if want_mmproj != is_mmproj:
            continue
        if not want_mmproj and not _is_q4_main_quant(g.name):
            continue
        candidates.append(g)
    if not candidates:
        return None
    if want_mmproj:
        candidates.sort(key=lambda x: x.stat().st_mtime, reverse=True)
        return candidates[0]
    candidates.sort(key=lambda g: (_q4_quant_rank(g.name), -g.stat().st_mtime))
    return candidates[0]


def pick_main_not_mmproj(
    d: Path,
    *,
    env_main: str,
    preferred: tuple[str, ...],
) -> Path | None:
    explicit = (os.environ.get(env_main) or "").strip()
    if explicit:
        return _resolve_gguf_file(d, explicit)
    for name in preferred:
        resolved = _resolve_gguf_file(d, name)
        if resolved is not None:
            return resolved
    return _pick_from_glob(d, want_mmproj=False)


def pick_mmproj(
    d: Path,
    *,
    env_mmproj: str,
    preferred: tuple[str, ...],
) -> Path | None:
    explicit = (os.environ.get(env_mmproj) or "").strip()
    if explicit:
        return _resolve_gguf_file(d, explicit)
    for name in preferred:
        resolved = _resolve_gguf_file(d, name)
        if resolved is not None:
            return resolved
    return _pick_from_glob(d, want_mmproj=True)


def pick_embed_gguf(d: Path, *, env_main: str = "EMBED_GGUF_MAIN") -> Path | None:
    explicit = (os.environ.get(env_main) or "").strip()
    if explicit:
        return _resolve_gguf_file(d, explicit)
    for name in EMBED_GGUF_PREFERRED:
        resolved = _resolve_gguf_file(d, name)
        if resolved is not None:
            return resolved
    return _pick_from_glob(d, want_mmproj=False)
