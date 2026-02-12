@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

set "MODE=%~1"

if "%MODE%"=="" set MODE=gateway
if "%MODE%"=="help" goto SHOW_HELP

echo [OpenClaw] Checking environment...

where node >nul 2>&1
if errorlevel 1 (
    echo [Error] Node.js not found. Install Node.js 22+ from https://nodejs.org/
    exit /b 1
)

where pnpm >nul 2>&1
if errorlevel 1 (
    echo [Info] Using npm
    set "PM=npm"
) else (
    echo [Info] Using pnpm
    set "PM=pnpm"
)

echo [OpenClaw] Mode: %MODE%
echo.

if "%MODE%"=="gateway" goto RUN_GATEWAY
if "%MODE%"=="agent" goto RUN_AGENT
if "%MODE%"=="tui" goto RUN_TUI
if "%MODE%"=="dev" goto RUN_DEV
if "%MODE%"=="watch" goto RUN_WATCH
if "%MODE%"=="onboard" goto RUN_ONBOARD

echo [Error] Unknown option: %MODE%
goto SHOW_HELP

:RUN_GATEWAY
echo [OpenClaw] Starting Gateway...
%PM% run openclaw gateway --port 18789 --verbose
goto END

:RUN_AGENT
echo [OpenClaw] Starting Agent...
%PM% run openclaw agent
goto END

:RUN_TUI
echo [OpenClaw] Starting TUI...
%PM% run tui
goto END

:RUN_DEV
echo [OpenClaw] Starting dev mode...
%PM% run gateway:dev
goto END

:RUN_WATCH
echo [OpenClaw] Starting watch mode...
%PM% run gateway:watch
goto END

:RUN_ONBOARD
echo [OpenClaw] Running onboarding...
%PM% run openclaw onboard --install-daemon
goto END

:SHOW_HELP
echo.
echo OpenClaw Launcher
echo.
echo Usage: start.bat [option]
echo.
echo Options:
echo   gateway  - Start Gateway (default)
echo   agent    - Start Agent mode
echo   tui      - Start TUI interface
echo   dev      - Start development mode
echo   watch    - Start watch mode
echo   onboard  - Run onboarding wizard
echo   help     - Show this help
echo.
goto END

:END
endlocal
