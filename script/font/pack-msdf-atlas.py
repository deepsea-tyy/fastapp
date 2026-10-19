#!/usr/bin/env python3
"""
Glyph-level MSDF atlas packer (shelf Best-Height-Fit + tight crop).

Input JSON (argv[1]):
{
  "outPng": "...",
  "outJson": "...",
  "maxSize": 8192,
  "pad": 2,
  "sheets": [
    { "png": "...", "meta": { ... bmfont json ... } }
  ]
}

Writes unified PNG + JSON. Prints summary JSON to stdout last line.
"""
from __future__ import annotations

import json
import math
import sys
from copy import deepcopy

from PIL import Image


def next_multiple(n: int, m: int = 4) -> int:
  return int(math.ceil(n / m) * m)


def shelf_pack(items: list[dict], atlas_w: int, pad: int) -> tuple[dict[int, tuple[int, int]], int] | None:
  """items: {key, w, h}. Returns placements key→(x,y) and used height, or None if overflow."""
  # tallest first, then widest — classic font atlas heuristic
  ordered = sorted(items, key=lambda it: (-it["h"], -it["w"], it["key"]))
  x = y = 0
  row_h = 0
  pos: dict[int, tuple[int, int]] = {}
  for it in ordered:
    w, h = it["w"], it["h"]
    if w > atlas_w:
      return None
    if x > 0 and x + w > atlas_w:
      x = 0
      y += row_h + pad
      row_h = 0
    pos[it["key"]] = (x, y)
    x += w + pad
    row_h = max(row_h, h)
  used_h = y + row_h if ordered else 0
  return pos, used_h


def choose_atlas(items: list[dict], max_size: int, pad: int) -> tuple[int, int, dict[int, tuple[int, int]]]:
  area = sum(it["w"] * it["h"] for it in items)
  max_w = max((it["w"] for it in items), default=1)
  # estimate side from area with ~12% packing slack
  est = max(max_w, int(math.ceil(math.sqrt(area * 1.12))))
  est = next_multiple(est, 64)

  candidates: set[int] = set()
  for w in (est - 256, est - 128, est, est + 128, est + 256, 2048, 4096, 5120, 6144, 8192):
    ww = next_multiple(max(w, max_w), 64)
    if max_w <= ww <= max_size:
      candidates.add(ww)
  # denser sweep near estimate
  for w in range(max(next_multiple(max_w, 64), est - 512), min(max_size, est + 512) + 1, 64):
    candidates.add(w)

  best = None  # (area, w, h, pos)
  for atlas_w in sorted(candidates):
    packed = shelf_pack(items, atlas_w, pad)
    if packed is None:
      continue
    pos, used_h = packed
    if used_h > max_size:
      continue
    atlas_h = next_multiple(used_h, 4)
    score = atlas_w * atlas_h
    if best is None or score < best[0] or (score == best[0] and atlas_w < best[1]):
      best = (score, atlas_w, atlas_h, pos)

  if best is None:
    raise SystemExit(f"cannot pack {len(items)} glyphs into {max_size}x{max_size}")
  return best[1], best[2], best[3]


def main() -> None:
  cfg = json.load(open(sys.argv[1], encoding="utf-8"))
  out_png = cfg["outPng"]
  out_json = cfg["outJson"]
  max_size = int(cfg.get("maxSize", 8192))
  pad = int(cfg.get("pad", 2))
  sheets = cfg["sheets"]

  glyphs: list[dict] = []
  zero_chars: list[dict] = []
  seen: set[int] = set()
  base_meta = None
  kernings: list[dict] = []
  kern_seen: set[tuple[int, int]] = set()

  for sheet in sheets:
    meta = sheet["meta"]
    if base_meta is None:
      base_meta = deepcopy(meta)
    im = Image.open(sheet["png"]).convert("RGBA")
    for ch in meta.get("chars") or []:
      cid = ch["id"]
      if cid in seen:
        continue
      seen.add(cid)
      w = int(ch.get("width") or 0)
      h = int(ch.get("height") or 0)
      if w <= 0 or h <= 0:
        zero_chars.append(deepcopy(ch))
        continue
      x, y = int(ch["x"]), int(ch["y"])
      crop = im.crop((x, y, x + w, y + h))
      key = len(glyphs)
      glyphs.append({"key": key, "w": w, "h": h, "img": crop, "ch": deepcopy(ch)})
    for k in meta.get("kernings") or []:
      pair = (k["first"], k["second"])
      if pair in kern_seen:
        continue
      kern_seen.add(pair)
      kernings.append(k)

  if base_meta is None:
    raise SystemExit("no sheets")

  atlas_w, atlas_h, pos = choose_atlas(
    [{"key": g["key"], "w": g["w"], "h": g["h"]} for g in glyphs],
    max_size,
    pad,
  )

  # MSDF 只编码在 RGB；空区用黑底（alpha 恒 1 时 shader 仍会 discard）
  atlas = Image.new("RGB", (atlas_w, atlas_h), (0, 0, 0))
  out_chars: list[dict] = []
  for g in glyphs:
    gx, gy = pos[g["key"]]
    atlas.paste(g["img"].convert("RGB"), (gx, gy))
    ch = g["ch"]
    ch["x"] = gx
    ch["y"] = gy
    ch["page"] = 0
    out_chars.append(ch)

  for ch in zero_chars:
    ch["x"] = 0
    ch["y"] = 0
    ch["page"] = 0
    out_chars.append(ch)

  out_chars.sort(key=lambda c: c["id"])

  page_name = cfg.get("pageName") or "AlibabaPuHuiTi-3-55-Regular-42.png"
  base_meta["pages"] = [page_name]
  base_meta["common"] = {
    **(base_meta.get("common") or {}),
    "scaleW": atlas_w,
    "scaleH": atlas_h,
  }
  base_meta["chars"] = out_chars
  base_meta["kernings"] = kernings

  atlas.save(out_png, optimize=True, compress_level=9)
  with open(out_json, "w", encoding="utf-8") as f:
    json.dump(base_meta, f, ensure_ascii=False, separators=(",", ":"))

  glyph_area = sum(g["w"] * g["h"] for g in glyphs)
  summary = {
    "atlas": [atlas_w, atlas_h],
    "glyphs": len(glyphs),
    "zero": len(zero_chars),
    "fill": round(glyph_area / (atlas_w * atlas_h), 4),
  }
  print(json.dumps(summary, ensure_ascii=False))


if __name__ == "__main__":
  main()
