"""调度器纯逻辑：槽位互斥与 ensure 计划（供 scheduler_service 与单测共用）。"""

from __future__ import annotations

SLOT_A = frozenset({"llm"})
SLOT_B = frozenset({"sdxl_juggernaut", "sdxl_illustrious", "ip_adapter"})
SLOT_C = frozenset({"voice"})

SLOT_LETTERS: dict[frozenset[str], str] = {
    SLOT_A: "A",
    SLOT_B: "B",
    SLOT_C: "C",
}

CAPABILITY_SLOT_LETTER: dict[str, str] = {
    cap: letter
    for slot, letter in SLOT_LETTERS.items()
    for cap in slot
}


def slot_letter_for(capability: str) -> str:
    return CAPABILITY_SLOT_LETTER.get(capability, "?")


def describe_active_slots(active: set[str]) -> str:
    if not active:
        return "空"
    parts = [f"{slot_letter_for(c)}:{c}" for c in sorted(active)]
    return ", ".join(parts)


def memory_profile(raw: str | None) -> str:
    p = (raw or "32g").strip().lower()
    return p if p in ("32g", "64g") else "32g"


def conflicts_to_stop(
    capability: str,
    *,
    active: set[str],
) -> list[str]:
    """返回需 stop 的服务名（不含 voice，除非 capability 本身在 voice）。"""
    stop: set[str] = set()

    if capability in SLOT_B:
        stop |= (SLOT_B - {capability}) & active
        stop |= SLOT_A & active

    elif capability == "llm":
        stop |= SLOT_B & active

    elif capability == "voice":
        pass

    stop.discard(capability)
    return sorted(stop)


def ensure_unchanged(*, capability: str, is_up: bool) -> bool:
    return is_up
