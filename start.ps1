# OpenClaw 启动脚本 (PowerShell)
# 使用方法: .\start.ps1 [gateway|agent|dev|watch|onboard|help]

param(
    [Parameter(Position=0)]
    [ValidateSet('gateway', 'agent', 'dev', 'watch', 'onboard', 'help')]
    [string]$Mode = 'gateway'
)

function Show-Help {
    Write-Host ""
    Write-Host "OpenClaw 启动脚本"
    Write-Host ""
    Write-Host "用法: .\start.ps1 [选项]"
    Write-Host ""
    Write-Host "选项:"
    Write-Host "  gateway  - 启动 Gateway (默认)"
    Write-Host "  agent    - 启动 Agent 模式"
    Write-Host "  dev      - 启动开发模式"
    Write-Host "  watch    - 启动 Gateway 监听模式"
    Write-Host "  onboard  - 运行向导"
    Write-Host "  help     - 显示帮助"
    Write-Host ""
}

function Test-Command {
    param([string]$Command)
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Check-Environment {
    Write-Host "[OpenClaw] 检查环境..."

    if (-not (Test-Command "node")) {
        Write-Host "[错误] 未找到 Node.js，请先安装 Node.js 22+"
        Write-Host "下载地址: https://nodejs.org/"
        exit 1
    }

    if (Test-Command "pnpm") {
        $script:PKG_MANAGER = "pnpm"
    }
    elseif (Test-Command "npm") {
        Write-Host "[提示] 未找到 pnpm，使用 npm 代替"
        $script:PKG_MANAGER = "npm"
"
    }
    else {
        Write-Host "[错误] 未找到 npm 或 pnpm，请先安装 Node.js"
        exit 1
    }

    Write-Host "[OpenClaw] 使用包管理器: $script:PKG_MANAGER"
}

function Invoke-OpenClaw {
    param([string]$Action)

    switch ($Action) {
        "gateway" {
            Write-Host "[OpenClaw] 启动 Gateway..."
            & $script:PKG_MANAGER run openclaw gateway --port 18789 --verbose
        }
        "agent" {
            Write-Host "[OpenClaw] 启动 Agent 模式..."
            & $script:PKG_MANAGER run openclaw agent
        }
        "dev" {
            Write-Host "[OpenClaw] 启动开发模式..."
            & $script:PKG_MANAGER run gateway:dev
        }
        "watch" {
            Write-Host "[OpenClaw] 启动 Gateway 监听模式..."
            & $script:PKG_MANAGER run gateway:watch
        }
        "onboard" {
            Write-Host "[OpenClaw] 运行向导..."
            & $script:PKG_MANAGER run openclaw onboard --install-daemon
        }
    }
}

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $SCRIPT_DIR

try {
    if ($Mode -eq "help") {
        Show-Help
        exit 0
    }

    Check-Environment

    Write-Host "[OpenClaw] 启动模式: $Mode"
    Write-Host ""

    Invoke-OpenClaw $Mode
}
finally {
    Pop-Location
}
