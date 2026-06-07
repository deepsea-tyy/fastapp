"""GGUF 推理唯一入口：VL ChatHandler 与权重加载均封装于此；业务服务只依赖本模块。"""

from __future__ import annotations

import sys
from pathlib import Path
from typing import Any

from llama_cpp import Llama
from llama_cpp.llama_chat_format import Llava15ChatHandler


class Qwen3VLChatHandler(Llava15ChatHandler):
    """Qwen3-VL GGUF：User/Assistant 多轮 + image_url 占位（由 mtmd 替换为内部 marker）。"""

    DEFAULT_SYSTEM_MESSAGE = "You are a helpful assistant."

    CHAT_FORMAT = r"""
{% for message in messages %}
{% if message['role'] == 'system' %}
<|im_start|>system
{{ message['content'] }}<|im_end|>
{% elif message['role'] == 'user' %}
<|im_start|>user
{% if message['content'] is string %}
{{ message['content'] }}
{% else %}
{% for content in message['content'] %}
{% if content['type'] == 'image_url' %}
{% if content.image_url is mapping %}
{{ content.image_url.url }}
{% else %}
{{ content.image_url }}
{% endif %}
{% elif content['type'] == 'text' %}
{{ content['text'] }}
{% endif %}
{% endfor %}
{% endif %}<|im_end|>
{% elif message['role'] == 'assistant' %}
<|im_start|>assistant
{{ message['content'] }}<|im_end|>
{% endif %}
{% endfor %}
{% if add_generation_prompt %}
<|im_start|>assistant
{% endif %}
""".strip()

    def __call__(self, **kwargs: Any) -> Any:
        ctx = kwargs["llama"]
        ctx.reset()
        ctx._ctx.kv_cache_clear()
        ctx.n_tokens = 0
        if hasattr(ctx, "input_ids"):
            ctx.input_ids.fill(0)
        if hasattr(self, "_last_image_embed"):
            self._last_image_embed = None
            self._last_image_hash = None
        if self.verbose:
            msgs = kwargs.get("messages", [])
            n = len(self.get_image_urls(msgs))
            print(f"[Qwen3-VL] images={n}", file=sys.stderr)
        return super().__call__(**kwargs)


class PaddleOCRVLChatHandler(Llava15ChatHandler):
    """PaddleOCR-VL 1.5 GGUF：文档解析 / OCR 提示，与官方 chat_template 对齐（图像用 URL 占位）。"""

    DEFAULT_SYSTEM_MESSAGE: str | None = None

    CHAT_FORMAT = (
        "<|begin_of_sentence|>"
        "{% for message in messages %}"
        "{% if message['role'] == 'user' %}"
        "User: "
        "{% if message['content'] is string %}"
        "{{ message['content'] }}"
        "{% else %}"
        "{% for content in message['content'] %}"
        "{% if content['type'] == 'image_url' %}"
        "{% if content.image_url is mapping %}"
        "{{ content.image_url.url }}"
        "{% else %}"
        "{{ content.image_url }}"
        "{% endif %}"
        "{% elif content['type'] == 'text' %}"
        "{{ content['text'] }}"
        "{% endif %}"
        "{% endfor %}"
        "{% endif %}"
        "\n"
        "{% elif message['role'] == 'assistant' %}"
        "Assistant:\n"
        "{% if message['content'] is string %}"
        "{{ message['content'] }}"
        "{% else %}"
        "{% for content in message['content'] %}"
        "{% if content['type'] == 'text' %}"
        "{{ content['text'] }}"
        "{% endif %}"
        "{% endfor %}"
        "{% endif %}"
        " "
        "{% endif %}"
        "{% endfor %}"
        "{% if add_generation_prompt %}"
        "Assistant:\n"
        "{% endif %}"
    )

    def __call__(self, **kwargs: Any) -> Any:
        ctx = kwargs["llama"]
        ctx.reset()
        ctx._ctx.kv_cache_clear()
        ctx.n_tokens = 0
        if hasattr(ctx, "input_ids"):
            ctx.input_ids.fill(0)
        if hasattr(self, "_last_image_embed"):
            self._last_image_embed = None
            self._last_image_hash = None
        if self.verbose:
            msgs = kwargs.get("messages", [])
            n = len(self.get_image_urls(msgs))
            print(f"[PaddleOCR-VL] images={n}", file=sys.stderr)
        return super().__call__(**kwargs)


def load_gguf_chat(
    main_gguf: Path,
    *,
    n_ctx: int,
    n_gpu_layers: int,
    verbose: bool,
) -> Any:
    return Llama(
        model_path=str(main_gguf),
        n_ctx=n_ctx,
        n_gpu_layers=n_gpu_layers,
        chat_format="chatml",
        verbose=verbose,
    )


def load_gguf_vl(
    main_gguf: Path,
    chat_handler: Llava15ChatHandler,
    *,
    n_ctx: int,
    n_gpu_layers: int,
    verbose: bool,
) -> Any:
    return Llama(
        model_path=str(main_gguf),
        n_ctx=n_ctx,
        n_gpu_layers=n_gpu_layers,
        chat_handler=chat_handler,
        verbose=verbose,
    )


def load_gguf_embedding(
    gguf: Path,
    *,
    n_ctx: int,
    n_batch: int,
    n_gpu_layers: int,
    verbose: bool,
) -> Any:
    return Llama(
        model_path=str(gguf),
        embedding=True,
        logits_all=True,
        n_ctx=n_ctx,
        n_batch=n_batch,
        n_gpu_layers=n_gpu_layers,
        verbose=verbose,
    )
