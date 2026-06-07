"""
本机 HTTP 服务：用 Chromium 打开 URL，适合上交所 static、深交所 disc.static 等需执行 JS 后才返回 PDF 的地址。

供其它进程通过 POST /fetch 拉取二进制（成功时为 application/pdf），POST /fetch_post_json 在同源页面内 POST JSON（如深交所 annList）。
启动前在 tools/ 下：`uv sync` 后执行 `uv run playwright install chromium`
"""
from __future__ import annotations

import asyncio
import contextlib
import logging
import time
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Any, AsyncIterator, Optional

from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from playwright.async_api import Browser, Playwright, async_playwright
from pydantic import BaseModel, Field, HttpUrl

from tools_env import bind_host, log_request_ok, playwright_env, uvicorn_access_log

_pw: Playwright | None = None
_browser: Browser | None = None
_fetch_sem = asyncio.Semaphore(2)


@asynccontextmanager
async def _lifespan(_: FastAPI) -> AsyncIterator[None]:
    global _pw, _browser
    _pw = await async_playwright().start()
    _browser = await _pw.chromium.launch(headless=playwright_env().headless)
    try:
        yield
    finally:
        if _browser:
            await _browser.close()
            _browser = None
        if _pw:
            await _pw.stop()
            _pw = None


app = FastAPI(title="playwright_fetch_service", version="0.1.0", lifespan=_lifespan)


class FetchRequest(BaseModel):
    url: HttpUrl
    """目标 URL（如上交所披露 PDF 链接）。"""
    use_proxy: bool = True
    """为 False 时浏览器上下文不走 PLAYWRIGHT_PROXY（如深交所 annList / disc.static 需直连）。"""
    wait_ms: int = Field(default=2500, ge=0, le=60_000)
    """首次 navigation 后额外等待毫秒，便于页面脚本写入 Cookie 再二次请求。"""
    referer: str | None = Field(default=None, max_length=2048)
    """可选 Referer；默认使用 url 自身。"""
    prime_urls: list[HttpUrl] = Field(default_factory=list, max_length=32)
    """先依次打开的页面（如上交所首页、披露列表）；与 static PDF 先 HTML 再出 PDF 的流程一致。"""
    page_fetch: bool = False
    """为 True 时：预热 prime_urls（为空则用 referer）后，在页面上下文中用 fetch 拉取 url（同源 XHR），用于 TSPD 等需浏览器 Cookie/JS 的接口。"""


class PostJsonFetchRequest(BaseModel):
    """预热披露列表页后，在页面 document 内对同源 URL 发起 POST + JSON（如深交所 annList）。"""

    url: HttpUrl
    use_proxy: bool = True
    """为 False 时浏览器上下文不走 PLAYWRIGHT_PROXY。"""
    """POST 目标（须与末次 goto 的页面同源）。"""
    json_body: dict[str, Any] = Field(default_factory=dict)
    """请求体 JSON 对象（由服务端序列化为 application/json）。"""
    wait_ms: int = Field(default=2500, ge=0, le=60_000)
    referer: str | None = Field(default=None, max_length=2048)
    """末站预热失败时的 fallback 导航地址；通常与列表页 Referer 一致。"""
    prime_urls: list[HttpUrl] = Field(default_factory=list, max_length=32)
    """先依次 goto 的页面；末站应为上市公司公告列表页，以便 Origin/ Cookie 与 annList 一致。"""


_SSE_REFERER = "https://www.sse.com.cn/"

logger = logging.getLogger("playwright_service")


def _browser_proxy_config(use_proxy: bool) -> Optional[dict[str, str]]:
    if not use_proxy:
        return None
    proxy_url = playwright_env().proxy
    return {"server": proxy_url} if proxy_url else None


def _browser_context_kwargs() -> dict[str, Any]:
    cfg = playwright_env()
    return {
        "user_agent": cfg.user_agent,
        "locale": cfg.locale,
        "ignore_https_errors": True,
        "extra_http_headers": {"Accept-Language": cfg.accept_language},
    }


def _prime_goto_referer(prime_url: str) -> str:
    """预热导航的 Referer：按目标站点根域设置，避免深交所等站点收到上交所 Referer 触发风控。"""
    try:
        from urllib.parse import urlparse

        p = urlparse((prime_url or "").strip())
        if p.scheme and p.netloc:
            return f"{p.scheme}://{p.netloc}/"
    except ValueError:
        pass
    return _SSE_REFERER


async def _response_body_safe(resp) -> tuple[bytes, str]:
    """主文档 304 等情况下 body 可能为空，避免误判。"""
    if not resp:
        return b"", ""
    ct = (resp.headers.get("content-type") or "").split(";")[0].strip()
    try:
        data = await resp.body()
    except Exception:
        return b"", ct
    return data, ct


async def _goto_pdf_and_read(
    page,
    url: str,
    *,
    wait_until: str,
) -> tuple[bytes, str]:
    """Headless Chromium 对直链 PDF 常触发「下载」而非主文档 body，需兼容 Download is starting。"""
    dl_task: asyncio.Task | None = asyncio.create_task(
        page.wait_for_event("download", timeout=90_000)
    )
    try:
        r = await page.goto(url, wait_until=wait_until, timeout=90_000)
        if dl_task:
            dl_task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await dl_task
        return await _response_body_safe(r)
    except Exception as e:
        if dl_task and "Download is starting" in str(e):
            try:
                download = await dl_task
            except asyncio.CancelledError:
                download = await page.wait_for_event("download", timeout=90_000)
            path = await download.path()
            data = Path(path).read_bytes()
            return data, "application/pdf"
        if dl_task:
            dl_task.cancel()
            with contextlib.suppress(asyncio.CancelledError):
                await dl_task
        raise


async def _fetch_bytes(
    url: str,
    wait_ms: int,
    referer: str,
    prime_urls: list[str],
    *,
    use_proxy: bool = True,
) -> tuple[bytes, str]:
    assert _browser is not None
    proxy = _browser_proxy_config(use_proxy)
    ctx = await _browser.new_context(proxy=proxy, **_browser_context_kwargs())
    try:
        page = await ctx.new_page()
        for pu in prime_urls:
            s = (pu or "").strip()
            if not s:
                continue
            await page.set_extra_http_headers({"Referer": _prime_goto_referer(s)})
            try:
                await page.goto(s, wait_until="load", timeout=90_000)
            except Exception:
                continue
        # 与常见点击链路一致：从最后一站预热页进入 static PDF，而非 PDF 自引用
        last_prime = ""
        for pu in reversed(prime_urls):
            t = (pu or "").strip()
            if t:
                last_prime = t
                break
        ref_s = (referer or "").strip() or url
        url_s = (url or "").strip()
        # 与 PDF URL 不同的显式 Referer（如深交所主站根）优先于末站预热页，否则沿用 last_prime（上交所链路）。
        if ref_s and ref_s != url_s:
            pdf_referer = ref_s
        else:
            pdf_referer = last_prime if last_prime else ref_s
        await page.set_extra_http_headers({"Referer": pdf_referer})
        b1, ct1 = await _goto_pdf_and_read(page, url, wait_until="load")
        if b1.startswith(b"%PDF-"):
            return b1, ct1 or "application/pdf"
        # 壳页内 JS（如 acw_sc__v2）可能在 load 后继续跑
        try:
            await page.wait_for_load_state("networkidle", timeout=min(15_000, max(3_000, wait_ms + 2_000)))
        except Exception:
            pass
        if wait_ms > 0:
            await asyncio.sleep(wait_ms / 1000.0)
        # 关键：二次请求须为「文档导航」，与 DevTools 中 sec-fetch-dest: document 一致；
        # ctx.request.get 走 API 通道，Sec-Fetch-* 不同，易被 static 继续挡成 HTML。
        b2, ct2 = await _goto_pdf_and_read(page, url, wait_until="load")
        if b2.startswith(b"%PDF-"):
            return b2, ct2 or "application/pdf"
        b3, ct3 = await _goto_pdf_and_read(page, url, wait_until="domcontentloaded")
        if b3.startswith(b"%PDF-"):
            return b3, ct3 or "application/pdf"
        return (b3 if b3 else b2) or b1, ct3 or ct2 or ct1 or "application/octet-stream"
    finally:
        await ctx.close()


async def _fetch_via_page_xhr(
    url: str,
    wait_ms: int,
    referer: str,
    prime_urls: list[str],
    *,
    use_proxy: bool = True,
) -> tuple[bytes, str]:
    """预热栏目页后在当前 document 内 fetch API，与 DevTools 中 XHR 一致（Sec-Fetch-Mode: cors 等由浏览器补齐）。"""
    assert _browser is not None
    proxy = _browser_proxy_config(use_proxy)
    ctx = await _browser.new_context(proxy=proxy, **_browser_context_kwargs())
    try:
        page = await ctx.new_page()
        ref_s = (referer or "").strip() or url
        visit = [s for s in (u.strip() for u in prime_urls) if s]
        if not visit:
            visit = [ref_s]
        for pu in visit:
            await page.set_extra_http_headers({"Referer": _prime_goto_referer(pu)})
            try:
                await page.goto(pu, wait_until="load", timeout=90_000)
            except Exception:
                continue
        try:
            await page.wait_for_load_state(
                "networkidle",
                timeout=min(15_000, max(3_000, wait_ms + 3_000)),
            )
        except Exception:
            pass
        if wait_ms > 0:
            await asyncio.sleep(wait_ms / 1000.0)
        result = await page.evaluate(
            """async (targetUrl) => {
                const r = await fetch(targetUrl, {
                  method: 'GET',
                  credentials: 'include',
                  headers: {
                    'Accept': '*/*',
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-Security-Request': 'required',
                  },
                });
                const text = await r.text();
                const ct = r.headers.get('content-type') || '';
                return { ok: r.ok, status: r.status, text, ct };
              }""",
            url,
        )
        if not isinstance(result, dict):
            raise RuntimeError("page_xhr_bad_result")
        if not result.get("ok"):
            raise RuntimeError(f"page_xhr_http_{result.get('status')}")
        text = result.get("text") or ""
        if not str(text).strip():
            raise RuntimeError("page_xhr_empty_body")
        ct = (result.get("ct") or "").split(";")[0].strip()
        return str(text).encode("utf-8"), ct
    finally:
        await ctx.close()


async def _fetch_via_page_post_json(
    url: str,
    json_body: dict[str, Any],
    wait_ms: int,
    referer: str,
    prime_urls: list[str],
    *,
    use_proxy: bool = True,
) -> tuple[bytes, str]:
    """与列表页同会话内 fetch POST JSON，由浏览器补齐 Origin / Sec-Fetch-* / Cookie。"""
    assert _browser is not None
    proxy = _browser_proxy_config(use_proxy)
    ctx = await _browser.new_context(proxy=proxy, **_browser_context_kwargs())
    try:
        page = await ctx.new_page()
        ref_s = (referer or "").strip() or url
        visit = [s for s in (u.strip() for u in prime_urls) if s]
        if not visit:
            visit = [ref_s]
        goto_wait = playwright_env().goto_wait_until
        last_goto_err: BaseException | None = None
        any_goto_ok = False
        for pu in visit:
            await page.set_extra_http_headers({"Referer": _prime_goto_referer(pu)})
            try:
                await page.goto(pu, wait_until=goto_wait, timeout=90_000)
                any_goto_ok = True
            except Exception as e:
                last_goto_err = e
                continue
        if not any_goto_ok:
            raise RuntimeError(
                f"page_post_json_prime_goto_all_failed: {last_goto_err!s}"
            )
        try:
            await page.wait_for_load_state(
                "networkidle",
                timeout=min(15_000, max(3_000, wait_ms + 3_000)),
            )
        except Exception:
            pass
        if wait_ms > 0:
            await asyncio.sleep(wait_ms / 1000.0)
        result = await page.evaluate(
            """async (args) => {
                const url = args.url;
                const payload = args.payload;
                const r = await fetch(url, {
                  method: 'POST',
                  credentials: 'include',
                  headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json, text/javascript, */*; q=0.01',
                    'X-Requested-With': 'XMLHttpRequest',
                    'x-request-type': 'ajax',
                  },
                  body: JSON.stringify(payload),
                });
                const text = await r.text();
                const ct = r.headers.get('content-type') || '';
                return { ok: r.ok, status: r.status, text, ct };
              }""",
            {"url": url, "payload": json_body},
        )
        if not isinstance(result, dict):
            raise RuntimeError("page_post_json_bad_result")
        if not result.get("ok"):
            st = result.get("status")
            raw = (result.get("text") or "").strip()
            snip = raw[:800] + ("…" if len(raw) > 800 else "")
            raise RuntimeError(f"page_post_json_http_{st}: {snip!r}")
        text = result.get("text") or ""
        if not str(text).strip():
            raise RuntimeError("page_post_json_empty_body")
        ct = (result.get("ct") or "").split(";")[0].strip()
        return str(text).encode("utf-8"), ct
    finally:
        await ctx.close()


@app.post("/fetch")
async def fetch(req: FetchRequest) -> Response:
    t0 = time.perf_counter()
    url = str(req.url)
    referer = (req.referer or url).strip() or url
    primes = [str(u) for u in req.prime_urls]
    async with _fetch_sem:
        try:
            body, media_type = await _fetch_bytes(
                url, req.wait_ms, referer, primes, use_proxy=req.use_proxy
            )
        except Exception as e:
            logger.error("fetch %s: %s", url, e, exc_info=True)
            raise HTTPException(status_code=502, detail=f"playwright_error: {e}") from e
    if body.startswith(b"%PDF-"):
        log_request_ok(logger, "fetch", t0, bytes=len(body), pdf=1)
        return Response(content=body, media_type="application/pdf")
    detail = {
        "message": "not_pdf",
        "content_type": media_type,
        "size": len(body),
        "hint": "若为 HTML 鉴权页，可调大 wait_ms 或检查目标 URL",
    }
    logger.error("fetch not_pdf url=%s %s", url, detail)
    raise HTTPException(status_code=502, detail=detail)


@app.post("/fetch_body")
async def fetch_body(req: FetchRequest) -> Response:
    """与 /fetch 相同导航链，但原样返回响应体（JSON/HTML 等），供需过 TSPD/反爬的 XHR 接口。"""
    t0 = time.perf_counter()
    url = str(req.url)
    referer = (req.referer or url).strip() or url
    primes = [str(u) for u in req.prime_urls]
    async with _fetch_sem:
        try:
            if req.page_fetch:
                body, media_type = await _fetch_via_page_xhr(
                    url, req.wait_ms, referer, primes, use_proxy=req.use_proxy
                )
            else:
                body, media_type = await _fetch_bytes(
                    url, req.wait_ms, referer, primes, use_proxy=req.use_proxy
                )
        except Exception as e:
            logger.error("fetch_body %s: %s", url, e, exc_info=True)
            raise HTTPException(status_code=502, detail=f"playwright_error: {e}") from e
    if not body:
        d = {"message": "empty_body", "content_type": media_type}
        logger.error("fetch_body empty url=%s %s", url, d)
        raise HTTPException(status_code=502, detail=d)
    ct = (media_type or "application/octet-stream").split(";")[0].strip().lower()
    if "json" not in ct and body[:1] in (b"{", b"["):
        ct = "application/json"
    log_request_ok(logger, "fetch_body", t0, bytes=len(body))
    return Response(content=body, media_type=ct or "application/octet-stream")


@app.post("/fetch_post_json")
async def fetch_post_json(req: PostJsonFetchRequest) -> Response:
    """预热 prime_urls 后，在页面内对 url 发起 POST application/json；返回响应体（多为 annList JSON）。"""
    t0 = time.perf_counter()
    url = str(req.url)
    referer = (req.referer or url).strip() or url
    primes = [str(u) for u in req.prime_urls]
    async with _fetch_sem:
        try:
            body, media_type = await _fetch_via_page_post_json(
                url,
                dict(req.json_body),
                req.wait_ms,
                referer,
                primes,
                use_proxy=req.use_proxy,
            )
        except Exception as e:
            logger.error("fetch_post_json %s: %s", url, e, exc_info=True)
            raise HTTPException(status_code=502, detail=f"playwright_error: {e}") from e
    if not body:
        d = {"message": "empty_body", "content_type": media_type}
        logger.error("fetch_post_json empty url=%s %s", url, d)
        raise HTTPException(status_code=502, detail=d)
    ct = (media_type or "application/octet-stream").split(";")[0].strip().lower()
    if "json" not in ct and body[:1] in (b"{", b"["):
        ct = "application/json"
    log_request_ok(logger, "fetch_post_json", t0, bytes=len(body))
    return Response(content=body, media_type=ct or "application/octet-stream")


def main() -> None:
    import uvicorn

    cfg = playwright_env()
    uvicorn.run(
        app,
        host=bind_host("127.0.0.1"),
        port=cfg.port,
        log_level="info",
        access_log=uvicorn_access_log(),
    )


if __name__ == "__main__":
    main()
