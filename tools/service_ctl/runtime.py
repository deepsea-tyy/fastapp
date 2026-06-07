"""进程启停、端口检测与 pid 文件。"""

from __future__ import annotations

import os
import platform
import shutil
import signal
import socket
import subprocess
import sys
import time
from pathlib import Path

from service_ctl.constants import (
    READY_TIMEOUT_DEFAULT,
    READY_TIMEOUT_ENV,
    SCHEDULABLE_CAPABILITIES,
    SCHEDULER_SERVICE,
    SERVICES_ORDER,
    SRC_DIR,
    TOOLS_ROOT,
)
from service_ctl.specs import (
    _service_specs,
    logs_dir,
    port_for,
)


def ensure_uv() -> None:
    if shutil.which("uv") is None:
        print("[error] 需要 uv: https://docs.astral.sh/uv/getting-started/installation/", file=sys.stderr)
        sys.exit(1)


def uv_sync(quiet: bool = False) -> None:
    cmd = ["uv", "sync"]
    if quiet:
        cmd.append("-q")
    subprocess.run(cmd, cwd=TOOLS_ROOT, check=True)


def tcp_port_open(host: str, port: int, timeout: float = 1.0) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def wait_tcp_port(name: str, port: int, max_sec: int) -> bool:
    elapsed = 0
    while elapsed < max_sec:
        if tcp_port_open("127.0.0.1", port):
            return True
        time.sleep(1)
        elapsed += 1
    hint = READY_TIMEOUT_ENV.get(name, "READY_TIMEOUT_SEC")
    print(
        f"[{name}] 端口 {port} 超时 {max_sec}s（{hint}；{logs_dir()}/{name}.log）",
        file=sys.stderr,
    )
    return False


def pid_listening_on_port(port: int) -> int | None:
    if shutil.which("lsof") is None:
        return None
    try:
        out = subprocess.run(
            ["lsof", "-nP", f"-iTCP:{port}", "-sTCP:LISTEN", "-t"],
            capture_output=True,
            text=True,
            check=False,
        )
        if out.returncode != 0:
            return None
        for line in out.stdout.split():
            if line.strip().isdigit():
                return int(line.strip())
    except (ValueError, OSError):
        return None
    return None


def process_cmdline(pid: int) -> str:
    try:
        out = subprocess.run(
            ["ps", "-p", str(pid), "-o", "command="],
            capture_output=True,
            text=True,
            check=False,
        )
        if out.returncode == 0:
            return out.stdout.strip()
    except OSError:
        pass
    return ""


def is_our_service_process(name: str, pid: int) -> bool:
    spec = _service_specs()[name]
    cmd = process_cmdline(pid)
    return spec.script.name in cmd if cmd else False


def pidfile_path(name: str) -> Path:
    return logs_dir() / f"{name}.pid"


def logfile_path(name: str) -> Path:
    return logs_dir() / f"{name}.log"


def try_adopt_running_service(name: str, port: int) -> int | None:
    if not tcp_port_open("127.0.0.1", port):
        return None
    occupant = pid_listening_on_port(port)
    if occupant is None or not process_alive(occupant) or not is_our_service_process(name, occupant):
        return None
    logs_dir().mkdir(parents=True, exist_ok=True)
    pidfile_path(name).write_text(str(occupant), encoding="utf-8")
    return occupant


def port_conflict_message(name: str, port: int) -> str:
    occupant = pid_listening_on_port(port)
    extra = f" pid={occupant}" if occupant is not None else ""
    return f"[{name}] 端口 {port} 已被占用{extra}，且非本服务进程；请先 stop 或释放端口"


def read_pid(name: str) -> int | None:
    pf = pidfile_path(name)
    if not pf.is_file():
        return None
    raw = pf.read_text(encoding="utf-8").strip()
    if not raw.isdigit():
        return None
    return int(raw)


def process_alive(pid: int) -> bool:
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def is_service_up(name: str) -> bool:
    pid = read_pid(name)
    if pid is None or not process_alive(pid):
        return False
    return tcp_port_open("127.0.0.1", port_for(name))


def pgrep_children(pid: int) -> list[int]:
    try:
        out = subprocess.run(
            ["pgrep", "-P", str(pid)],
            capture_output=True,
            text=True,
            check=False,
        )
        if out.returncode != 0:
            return []
        return [int(x) for x in out.stdout.split() if x.strip().isdigit()]
    except (FileNotFoundError, ValueError):
        return []


def kill_descendants_bottom_up(pid: int) -> None:
    for child in pgrep_children(pid):
        if child != pid:
            kill_descendants_bottom_up(child)
    try:
        os.kill(pid, signal.SIGKILL)
    except OSError:
        pass


def kill_pid_subtree(root: int) -> None:
    for child in pgrep_children(root):
        if child != root:
            kill_descendants_bottom_up(child)
    try:
        os.kill(root, signal.SIGKILL)
    except OSError:
        pass


def playwright_chromium_installed() -> bool:
    code = (
        "import os\n"
        "from playwright.sync_api import sync_playwright\n"
        "with sync_playwright() as p:\n"
        "    ep = p.chromium.executable_path\n"
        "    raise SystemExit(0 if ep and os.path.isfile(ep) else 1)\n"
    )
    r = subprocess.run(
        ["uv", "run", "python", "-c", code],
        cwd=TOOLS_ROOT,
        capture_output=True,
    )
    return r.returncode == 0


def ensure_playwright_chromium() -> bool:
    if playwright_chromium_installed():
        return True
    print("[playwright] 未检测到 Chromium，执行 uv run playwright install chromium …")
    subprocess.run(["uv", "run", "playwright", "install", "chromium"], cwd=TOOLS_ROOT, check=False)
    if playwright_chromium_installed():
        return True
    print("[playwright] install chromium 后仍检测不到可执行文件", file=sys.stderr)
    return False


def child_env(
    name: str,
    port: int,
    env_overlay: dict[str, str] | None = None,
) -> dict[str, str]:
    sys.path.insert(0, str(SRC_DIR))
    from tools_env import device_str, hf_hub_cache_dir

    hub = hf_hub_cache_dir()
    env = os.environ.copy()
    env["HF_HOME"] = str(hub)
    env["HF_HUB_CACHE"] = str(hub)
    env["TRANSFORMERS_CACHE"] = str(hub / "transformers")
    env["TOOLS_UVICORN_ACCESS"] = env.get("TOOLS_UVICORN_ACCESS", "1")
    env["BIND_HOST"] = env.get("BIND_HOST", "127.0.0.1")
    env["TOKENIZERS_PARALLELISM"] = "false"
    for k in ("OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS", "NUMEXPR_NUM_THREADS"):
        env.setdefault(k, "1")
    spec = _service_specs()[name]
    env[spec.port_env] = str(port)
    if name == "playwright":
        env["PLAYWRIGHT_PORT"] = str(port)
        env.setdefault("PLAYWRIGHT_HEADLESS", "1")
    elif spec.needs_device:
        env["DEVICE"] = device_str()
    if env_overlay:
        env.update(env_overlay)
    return env


def start_one(
    name: str,
    *,
    env_overlay: dict[str, str] | None = None,
    daemon: bool = False,
) -> bool:
    spec = _service_specs()[name]
    port = port_for(name)
    logs_dir().mkdir(parents=True, exist_ok=True)
    pf = pidfile_path(name)
    lf = logfile_path(name)

    overlay = dict(env_overlay) if env_overlay else None

    pid = read_pid(name)
    if pid is not None and process_alive(pid):
        print(f"[{name}] 已在运行 pid={pid} port={port}")
        if name in READY_TIMEOUT_ENV:
            max_sec = int(os.environ.get(READY_TIMEOUT_ENV[name], READY_TIMEOUT_DEFAULT[name]))
            wait_tcp_port(name, port, max_sec)
        return True

    adopted = try_adopt_running_service(name, port)
    if adopted is not None:
        print(f"[{name}] 已在运行 pid={adopted} port={port}（已恢复 pid 文件）")
        return True

    if tcp_port_open("127.0.0.1", port):
        print(port_conflict_message(name, port), file=sys.stderr)
        return False

    if not spec.script.is_file():
        print(f"[{name}] 未找到脚本: {spec.script}", file=sys.stderr)
        return False

    ensure_uv()
    uv_sync(quiet=True)

    if spec.needs_playwright and not ensure_playwright_chromium():
        return False

    env = child_env(name, port, overlay)
    cmd = ["uv", "run", "python", str(spec.script)]
    if platform.system() == "Darwin":
        env["OBJC_DISABLE_INITIALIZE_FORK_SAFETY"] = "YES"

    fg_debug = name == SCHEDULER_SERVICE and not daemon

    if daemon:
        logf = open(lf, "a", encoding="utf-8")
        child = subprocess.Popen(
            cmd,
            cwd=TOOLS_ROOT,
            env=env,
            stdout=logf,
            stderr=subprocess.STDOUT,
            start_new_session=True,
        )
        logf.close()
    elif fg_debug:
        # 不 start_new_session：日志留在当前终端；关终端或 Ctrl+C 会停 scheduler
        child = subprocess.Popen(
            cmd,
            cwd=TOOLS_ROOT,
            env=env,
            stdin=subprocess.DEVNULL,
        )
    else:
        child = subprocess.Popen(cmd, cwd=TOOLS_ROOT, env=env)

    pf.write_text(str(child.pid), encoding="utf-8")
    time.sleep(0.3)

    if not process_alive(child.pid):
        pf.unlink(missing_ok=True)
        hint = f"，见 {lf}" if daemon else ""
        print(f"[{name}] 启动失败{hint}", file=sys.stderr)
        return False

    print(
        f"[{name}] 已启动"
        f"pid={child.pid} port={port} DEVICE={env.get('DEVICE', '-')}"
    )
    if name in READY_TIMEOUT_ENV:
        max_sec = int(os.environ.get(READY_TIMEOUT_ENV[name], READY_TIMEOUT_DEFAULT[name]))
        ready = wait_tcp_port(name, port, max_sec)
    elif fg_debug:
        ready = wait_tcp_port(name, port, 30)
    else:
        ready = tcp_port_open("127.0.0.1", port, timeout=0.5)

    if ready and not process_alive(child.pid):
        print(
            f"[{name}] 进程已退出，但端口 {port} 仍被其它进程占用；{port_conflict_message(name, port)}",
            file=sys.stderr,
        )
        ready = False

    if not ready:
        if not daemon or fg_debug:
            try:
                child.terminate()
            except OSError:
                pass
        pf.unlink(missing_ok=True)
        return False

    if daemon:
        return True

    try:
        return child.wait() == 0
    finally:
        pf.unlink(missing_ok=True)


def stop_one(name: str, *, quiet: bool = False) -> None:
    if name == SCHEDULER_SERVICE:
        stop_scheduled_capabilities()
    pf = pidfile_path(name)
    pid = read_pid(name) if pf.is_file() else None
    if pid is not None and process_alive(pid):
        kill_pid_subtree(pid)
        if not quiet:
            print(f"[{name}] 已停止 pid={pid}")
        pf.unlink(missing_ok=True)
        return

    port = port_for(name)
    if tcp_port_open("127.0.0.1", port):
        occupant = pid_listening_on_port(port)
        if occupant is not None and process_alive(occupant) and is_our_service_process(name, occupant):
            kill_pid_subtree(occupant)
            if not quiet:
                print(f"[{name}] 已停止 pid={occupant}（由端口发现，无 pid 文件）")
            pf.unlink(missing_ok=True)
            return

    if not quiet:
        if pid is None:
            print(f"[{name}] 无 pid 文件")
        else:
            print(f"[{name}] 无运行进程")
    pf.unlink(missing_ok=True)


def _scheduled_capability_running(name: str) -> bool:
    if is_service_up(name) or read_pid(name) is not None:
        return True
    port = port_for(name)
    if not tcp_port_open("127.0.0.1", port):
        return False
    occupant = pid_listening_on_port(port)
    return occupant is not None and process_alive(occupant) and is_our_service_process(name, occupant)


def stop_scheduled_capabilities() -> list[str]:
    """停止 scheduler ensure 拉起的推理进程（scheduler 退出时调用）。"""
    stopped: list[str] = []
    for name in reversed(SERVICES_ORDER):
        if name not in SCHEDULABLE_CAPABILITIES:
            continue
        if _scheduled_capability_running(name):
            stop_one(name)
            stopped.append(name)
    return stopped
