@echo off
setlocal

cd /d "%~dp0.."

if not exist ".venv\Scripts\python.exe" (
    echo .venv가 없습니다. README의 Python 가상환경 설정을 먼저 진행하세요.
    exit /b 1
)

set PYTHONPATH=
".venv\Scripts\python.exe" "scripts\run_scheduled_sync.py"
