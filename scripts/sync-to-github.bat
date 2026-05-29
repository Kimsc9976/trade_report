@echo off
setlocal EnableDelayedExpansion

set "EXIT_CODE=0"
cd /d "%~dp0.."
set "LOCK_FILE=%CD%\.sync-to-github.lock"

if exist "%LOCK_FILE%" (
    echo sync already running, skipping
    exit /b 0
)

echo.>"%LOCK_FILE%"

if defined GIT_BRANCH (
    set "BRANCH=%GIT_BRANCH%"
) else (
    for /f "delims=" %%b in ('git branch --show-current 2^>nul') do set "BRANCH=%%b"
)

git status --porcelain daily-report journal 2>nul | findstr /r "." >nul
if errorlevel 1 goto :done

git add daily-report journal
if errorlevel 1 (
    set "EXIT_CODE=1"
    goto :done
)

git diff --cached --quiet
if not errorlevel 1 goto :done

git rev-parse --abbrev-ref "@{u}" >nul 2>&1
if not errorlevel 1 (
    git pull --rebase origin "!BRANCH!"
    if errorlevel 1 (
        set "EXIT_CODE=1"
        goto :done
    )
)

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value 2^>nul') do set "DT=%%I"
if defined DT (
    set "TS=!DT:~0,4!-!DT:~4,2!-!DT:~6,2! !DT:~8,2!:!DT:~10,2!:!DT:~12,2!"
) else (
    set "TS=%date% %time%"
)
set "MSG=auto: sync !TS!"

git commit -m "!MSG!"
if errorlevel 1 (
    set "EXIT_CODE=1"
    goto :done
)

git push origin "!BRANCH!"
if errorlevel 1 (
    set "EXIT_CODE=1"
    goto :done
)

echo pushed to origin/!BRANCH! at !TS!

:done
if exist "%LOCK_FILE%" del /f /q "%LOCK_FILE%"
exit /b !EXIT_CODE!
