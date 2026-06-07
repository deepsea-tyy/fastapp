"""tools 进程管理 CLI：start / stop / restart / status / clear / download。"""

from __future__ import annotations

import os
import platform
import sys
import time
from dataclasses import dataclass
from pathlib import Path

from huggingface_hub import HfApi, snapshot_download
from huggingface_hub.utils import HfHubHTTPError

from service_ctl.constants import (
    INFERENCE_SERVICES,
    SCHEDULABLE_CAPABILITIES,
    SCHEDULER_SERVICE,
    SERVICES_ORDER,
    SRC_DIR,
    TOOLS_ROOT,
)
from service_ctl.runtime import (
    logs_dir,
    port_for,
    process_alive,
    read_pid,
    start_one,
    stop_one,
    tcp_port_open,
)
from service_ctl.select import parse_start_flags, select_services, validate_start_selection

sys.path.insert(0, str(SRC_DIR))
import tools_env  # noqa: E402, F401 — 加载 .env


_GGUF_META = ("*.gguf", "README*", ".gitattributes", "LICENSE*", "*.md")


@dataclass(frozen=True)
class ModelEntry:
    repo_id: str
    rel_dir: str
    allow_patterns: list[str] | None = None


MODELS: dict[str, ModelEntry] = {
    "qwen2.5-7b-instruct-gguf": ModelEntry(
        "Qwen/Qwen2.5-7B-Instruct-GGUF",
        "models/qwen2.5-7b-instruct-gguf",
        list(_GGUF_META),
    ),
    "qwen3-embedding-0.6b-gguf": ModelEntry(
        "Qwen/Qwen3-Embedding-0.6B-GGUF",
        "models/qwen3-embedding-0.6b-gguf",
        list(_GGUF_META),
    ),
    "paddleocr-vl-gguf": ModelEntry(
        "PaddlePaddle/PaddleOCR-VL-1.5-GGUF",
        "models/paddleocr-vl-gguf",
        list(_GGUF_META),
    ),
    "omnivoice-k2-fsa": ModelEntry("k2-fsa/OmniVoice", "models/omnivoice-k2-fsa"),
    "sdxl-base-1.0": ModelEntry(
        "stabilityai/stable-diffusion-xl-base-1.0",
        "models/sdxl-base-1.0",
    ),
    "ip-adapter-sdxl": ModelEntry(
        "h94/IP-Adapter",
        "models/ip-adapter-h94",
        ["sdxl_models/**", "models/image_encoder/**", "README*", "LICENSE*"],
    ),
    "juggernaut-xl": ModelEntry("RunDiffusion/Juggernaut-XL-v9", "models/juggernaut-xl"),
    "illustrious-xl": ModelEntry(
        "OnomaAIResearch/Illustrious-XL-v1.0",
        "models/illustrious-xl",
    ),
}

SERVICE_MODEL_KEYS: dict[str, list[str]] = {
    "llm": ["qwen2.5-7b-instruct-gguf"],
    "emb": ["qwen3-embedding-0.6b-gguf"],
    "ocr": ["paddleocr-vl-gguf"],
    "playwright": [],
    "sdxl_juggernaut": ["juggernaut-xl"],
    "sdxl_illustrious": ["illustrious-xl"],
    "ip_adapter": ["sdxl-base-1.0", "ip-adapter-sdxl"],
    "voice": ["omnivoice-k2-fsa"],
}


def _hf_token() -> str | None:
    t = (os.environ.get("HF_TOKEN") or "").strip().lstrip("\ufeff")
    if len(t) >= 2 and t[0] == t[-1] and t[0] in "'\"":
        t = t[1:-1].strip()
    return t or None


def _expand_download_token(token: str) -> list[str]:
    if token == "gguf":
        return ["llm", "emb", "ocr"]
    if token == "all":
        return [s for s in INFERENCE_SERVICES if s != "playwright"]
    if token == "scheduler":
        return [s for s in SERVICES_ORDER if s in SCHEDULABLE_CAPABILITIES]
    return [token]


def _resolve_download_services(args: list[str]) -> list[str]:
    expanded: list[str] = []
    for a in args:
        expanded.extend(_expand_download_token(a.strip().lower()))

    inference_names = " ".join(INFERENCE_SERVICES)
    for a in args:
        tok = a.strip().lower()
        if tok in ("all", "gguf", "scheduler"):
            continue
        if tok not in SERVICE_MODEL_KEYS:
            print(
                f"[error] 未知服务: {tok}（可选: {inference_names} | scheduler | all | gguf）",
                file=sys.stderr,
            )
            sys.exit(1)

    selected: list[str] = []
    seen: set[str] = set()
    for s in SERVICES_ORDER:
        if s in expanded and s not in seen:
            selected.append(s)
            seen.add(s)
    return selected


def _keys_for_services(services: list[str]) -> list[str]:
    keys: list[str] = []
    for svc in services:
        if svc == "playwright":
            print("[playwright] 无需下载模型")
            continue
        for k in SERVICE_MODEL_KEYS.get(svc, []):
            if k not in keys:
                keys.append(k)
    return keys


def _print_download_help() -> None:
    print(
        "用法:\n"
        "  uv run python main.py download [<服务名> ... | scheduler | all | gguf]\n"
        "无参数列出下列项。模型仓库与本地路径固定，仅 HF_TOKEN 可配。\n"
    )
    for svc in SERVICES_ORDER:
        if svc not in SERVICE_MODEL_KEYS:
            continue
        keys = SERVICE_MODEL_KEYS[svc]
        if not keys:
            print(f"  [{svc}] 无需下载模型\n")
            continue
        print(f"  [{svc}]")
        for key in keys:
            e = MODELS[key]
            print(f"      {key}: {e.repo_id} -> {e.rel_dir}")
        print()


def _download_one(key: str, token: str | None) -> None:
    e = MODELS[key]
    out_dir = TOOLS_ROOT / e.rel_dir
    out_dir.mkdir(parents=True, exist_ok=True)
    print(f"[{key}] {e.repo_id} -> {out_dir}")
    kw: dict = {
        "repo_id": e.repo_id,
        "local_dir": str(out_dir),
        "token": token,
    }
    if e.allow_patterns is not None:
        kw["allow_patterns"] = e.allow_patterns
    snapshot_download(**kw)


def run_download(args: list[str]) -> int:
    if not args or args in (["-h"], ["--help"]):
        _print_download_help()
        return 0

    services = _resolve_download_services(args)
    keys = _keys_for_services(services)
    if not keys:
        return 0

    token = _hf_token()
    if token:
        try:
            HfApi(token=token).whoami()
        except HfHubHTTPError as ex:
            print(f"HF_TOKEN 无效: {ex}", file=sys.stderr)
            return 1
    else:
        print("未设置 HF_TOKEN：公开仓可匿名；gated 请在 tools/.env 配置。")

    for key in keys:
        _download_one(key, token)
        print()

    print("完成。")
    return 0


def cmd_start(args: list[str]) -> int:
    service_args, daemon = parse_start_flags(args)
    selected = select_services(service_args)
    validate_start_selection(selected)
    if SCHEDULER_SERVICE in selected:
        cmd_clear()
    gap = 8 if platform.system() == "Darwin" else 4
    for i, name in enumerate(selected):
        if not start_one(name, daemon=daemon):
            return 1
        if daemon and i < len(selected) - 1:
            time.sleep(gap)
    return 0


def cmd_stop(args: list[str]) -> int:
    args, _ = parse_start_flags(args)
    if not args:
        for name in reversed(SERVICES_ORDER):
            stop_one(name)
        return 0
    selected = select_services(args)
    sel_set = set(selected)
    for name in reversed(SERVICES_ORDER):
        if name in sel_set:
            stop_one(name)
    return 0


def cmd_restart(args: list[str]) -> int:
    service_args, _ = parse_start_flags(args)
    cmd_stop(service_args)
    time.sleep(0.5)
    return cmd_start(args)


def cmd_status() -> int:
    for name in SERVICES_ORDER:
        port = port_for(name)
        pid = read_pid(name)
        pid_state = str(pid) if pid is not None and process_alive(pid) else "—"
        http = "up" if tcp_port_open("127.0.0.1", port) else "down"
        url = f"127.0.0.1:{port}"
        print(f"{name:<14} pid={pid_state:<8} tcp={http:<4} {url}")
    return 0


def cmd_download(args: list[str]) -> int:
    return run_download(args)


def cmd_clear() -> int:
    d = logs_dir()
    d.mkdir(parents=True, exist_ok=True)
    logs = list(d.glob("*.log"))
    for f in logs:
        f.unlink(missing_ok=True)
    if not logs:
        print(f"[logs] 无 *.log 可删 ({d})")
        return 0
    print(f"[logs] 已删除 {len(logs)} 个日志文件 ({d})")
    return 0


def main(argv: list[str] | None = None) -> int:
    argv = argv if argv is not None else sys.argv[1:]
    if not argv:
        return cmd_status()

    cmd = argv[0]
    rest = argv[1:]

    if cmd == "start":
        return cmd_start(rest)
    if cmd == "stop":
        return cmd_stop(rest)
    if cmd == "restart":
        return cmd_restart(rest)
    if cmd == "status":
        return cmd_status()
    if cmd == "clear":
        return cmd_clear()
    if cmd == "download":
        return cmd_download(rest)

    print(f"[error] 未知命令: {cmd}", file=sys.stderr)
    return 1
