#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VENV_PYTHON="${REPO_ROOT}/.venv/bin/python"

if [[ ! -x "$VENV_PYTHON" ]]; then
  echo ".venv가 없습니다. 먼저 설치하세요:" >&2
  echo "  python3 -m venv .venv && .venv/bin/pip install -r requirements.txt" >&2
  exit 1
fi

# ROS 등 외부 PYTHONPATH가 venv 동작을 오염시키지 않도록 제거
unset PYTHONPATH

exec "$VENV_PYTHON" "${REPO_ROOT}/scripts/run_scheduled_sync.py"
