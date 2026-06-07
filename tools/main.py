#!/usr/bin/env python3
"""tools 服务进程管理入口：start / stop / restart / status / clear / download。"""

from service_ctl.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
