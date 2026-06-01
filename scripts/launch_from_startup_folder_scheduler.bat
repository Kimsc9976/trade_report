@echo off
REM ============================================================
REM Copy THIS file into your Windows Startup folder, then reboot or sign-in again.
REM Open Startup folder: Win+R -> shell:startup -> Enter
REM Do NOT move the original; keep one copy here and copy/paste into Startup.
REM Calls: trade_report\scripts\start-scheduler.bat
REM Works without TRADE_REPORT_ROOT when repo is:
REM   %USERPROFILE%\Desktop\trade_report
REM   or %USERPROFILE%\OneDrive\Desktop\trade_report
REM Otherwise set user env TRADE_REPORT_ROOT to your trade_report path.
REM ============================================================
setlocal EnableExtensions

if defined TRADE_REPORT_ROOT (
  call "%TRADE_REPORT_ROOT%\scripts\start-scheduler.bat"
  exit /b %ERRORLEVEL%
)

set "ROOT="
if exist "%USERPROFILE%\Desktop\trade_report\scripts\start-scheduler.bat" (
  set "ROOT=%USERPROFILE%\Desktop\trade_report"
)
if not defined ROOT if exist "%USERPROFILE%\OneDrive\Desktop\trade_report\scripts\start-scheduler.bat" (
  set "ROOT=%USERPROFILE%\OneDrive\Desktop\trade_report"
)

if not defined ROOT (
  echo [startup_launcher] ERROR: trade_report not found on Desktop / OneDrive Desktop.
  echo Set user env TRADE_REPORT_ROOT to your trade_report folder, then retry.
  pause
  exit /b 1
)

call "%ROOT%\scripts\start-scheduler.bat"
exit /b %ERRORLEVEL%
