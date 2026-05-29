#!/usr/bin/env python3
"""daily-report/, journal/ 변경분을 매일 12:00, 16:00, 20:00에 GitHub로 push."""

from __future__ import annotations

import logging
import subprocess
import sys
import time
from pathlib import Path

import schedule

REPO_ROOT = Path(__file__).resolve().parent.parent
LOG_DIR = REPO_ROOT / "logs"
LOG_FILE = LOG_DIR / "scheduler.log"

SYNC_TIMES = ("12:00", "16:00", "20:00")
POLL_INTERVAL_SEC = 30


def sync_command() -> list[str]:
    if sys.platform == "win32":
        ps1 = REPO_ROOT / "scripts" / "sync-to-github.ps1"
        return [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy",
            "Bypass",
            "-File",
            str(ps1),
        ]
    sh = REPO_ROOT / "scripts" / "sync-to-github.sh"
    return [str(sh)]


def setup_logging() -> None:
    LOG_DIR.mkdir(exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="[%(asctime)s] %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=[
            logging.FileHandler(LOG_FILE, encoding="utf-8"),
            logging.StreamHandler(sys.stdout),
        ],
    )


def run_sync() -> None:
    logging.info("scheduled sync 시작")
    result = subprocess.run(
        sync_command(),
        cwd=REPO_ROOT,
        check=False,
    )
    if result.returncode == 0:
        logging.info("scheduled sync 완료")
    else:
        logging.error("scheduled sync 실패 (exit %s)", result.returncode)


def main() -> None:
    setup_logging()
    logging.info(
        "스케줄러 시작: 매일 %s (변경 없으면 push 생략)",
        ", ".join(SYNC_TIMES),
    )
    for sync_time in SYNC_TIMES:
        schedule.every().day.at(sync_time).do(run_sync)

    while True:
        schedule.run_pending()
        time.sleep(POLL_INTERVAL_SEC)


if __name__ == "__main__":
    main()
