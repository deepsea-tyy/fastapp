"""CLI 服务名解析与 start 参数校验。"""

from __future__ import annotations

import sys

from service_ctl.constants import INFERENCE_SERVICES, SCHEDULER_SERVICE, SERVICES_ORDER
from service_ctl.specs import _service_specs


def parse_start_flags(args: list[str]) -> tuple[list[str], bool]:
    """解析 start/restart 参数；`-d` 表示后台运行。"""
    daemon = False
    services: list[str] = []
    for a in args:
        if a == "-d":
            daemon = True
        else:
            services.append(a)
    return services, daemon


def _expand_service_token(token: str) -> list[str]:
    if token == "gguf":
        return ["ocr", "llm"]
    return [token]


def select_services(args: list[str]) -> list[str]:
    if not args:
        return [SCHEDULER_SERVICE]

    expanded: list[str] = []
    for a in args:
        expanded.extend(_expand_service_token(a))

    inference_names = " ".join(INFERENCE_SERVICES)
    for a in args:
        if a == "gguf":
            continue
        if a not in _service_specs():
            print(
                f"[error] 未知服务: {a}（可选: {SCHEDULER_SERVICE} | {inference_names} | gguf）",
                file=sys.stderr,
            )
            sys.exit(1)

    selected: list[str] = []
    seen: set[str] = set()
    for c in SERVICES_ORDER:
        if c in expanded and c not in seen:
            selected.append(c)
            seen.add(c)
    return selected


def validate_start_selection(selected: list[str]) -> None:
    if SCHEDULER_SERVICE in selected and len(selected) > 1:
        print(
            "[error] scheduler 与推理服务请分开启动；"
            "Story 用 start scheduler，调试某能力用 start <name>",
            file=sys.stderr,
        )
        sys.exit(1)
