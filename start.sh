#!/usr/bin/env bash
# OpenClaw 启动脚本 (Linux/macOS)
# 使用方法: ./start.sh [gateway|agent|dev|watch|onboard|help]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

show_help() {
    echo ""
    echo "OpenClaw 启动脚本"
    echo ""
    echo "用法: ./start.sh [选项]"
    echo ""
    echo "选项:"
    echo "  gateway  - 启动 Gateway (默认)"
    echo "  agent    - 启动 Agent 模式"
    echo "  dev      - 启动开发模式"
    echo "  watch    - 启动 Gateway 监听模式"
    echo "  onboard  - 运行向导"
    echo "  help     - 显示帮助"
    echo ""
}

check_environment() {
    echo "[OpenClaw] 检查环境..."

    if ! command -v node &> /dev/null; then
        echo "[错误] 未找到 Node.js，请先安装 Node.js 22+"
        echo "下载地址: https://nodejs.org/"
        exit 1
    fi

    if ! command -v pnpm &> /dev/null; then
        if ! command -v npm &> /dev/null; then
            echo "[错误] 未找到 npm 或 pnpm，请先安装 Node.js"
            exit 1
        fi
        echo "[提示] 未找到 pnpm，使用 npm 代替"
        PKG_MANAGER="npm"
    else
        PKG_MANAGER="pnpm"
    fi

    echo "[OpenClaw] 使用包管理器: $PKG_MANAGER"
}

main() {
    local mode="${1:-gateway}"

    if [ "$mode" = "help" ]; then
        show_help
        exit 0
    fi

    check_environment

    echo "[OpenClaw] 启动模式: $mode"
    echo ""

    case "$mode" in
        gateway)
            echo "[OpenClaw] 启动 Gateway..."
            $PKG_MANAGER run openclaw gateway --port 18789 --verbose
            ;;
        agent)
            echo "[OpenClaw] 启动 Agent 模式..."
            $PKG_MANAGER run openclaw agent
            ;;
        dev)
            echo "[OpenClaw] 启动开发模式..."
            $PKG_MANAGER run gateway:dev
            ;;
        watch)
            echo "[OpenClaw] 启动 Gateway 监听模式..."
            $PKG_MANAGER run gateway:watch
            ;;
        onboard)
            echo "[OpenClaw] 运行向导..."
            $PKG_MANAGER run openclaw onboard --install-daemon
            ;;
        *)
            echo "[错误] 未知的选项: $mode"
            echo "运行 './start.sh help' 查看帮助"
            exit 1
            ;;
    esac
}

main "$@"
