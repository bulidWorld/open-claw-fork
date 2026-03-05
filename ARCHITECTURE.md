# OpenClaw 架构说明

## 项目概述

OpenClaw 是一个个人 AI 助手网关，支持多渠道消息集成（WhatsApp、Telegram、Slack、Discord、Google Chat、Signal、iMessage、Microsoft Teams、Matrix、Zalo 等）。Gateway 是控制平面，助手本身才是产品。

- **项目名称**: OpenClaw
- **版本**: 2026.2.9
- **运行时要求**: Node.js >= 22.12.0
- **包管理器**: pnpm 10.23.0
- **许可协议**: MIT

---

## 核心架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         消息渠道层                                │
│  WhatsApp | Telegram | Slack | Discord | Signal | iMessage |   │
│  Microsoft Teams | Matrix | Zalo | WebChat                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Gateway (控制平面)                           │
│                 WebSocket Server: ws://127.0.0.1:18789            │
│  - 会话管理                                                       │
│  - 配置管理                                                       │
│  - 工具调用                                                       │
│  - 事件调度                                                       │
│  - Cron 定时任务                                                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┬──────────────────────┐
        ▼                ▼                ▼                      ▼
┌─────────────┐  ┌──────────────┐  ┌──────────┐          ┌──────────┐
│ Pi Agent    │  │ CLI 客户端   │  │ WebChat  │  ┌─────────┤ 节点设备  │
│ (RPC 模式)  │  │ openclaw ... │  │   UI     │  │         │  Nodes   │
└─────────────┘  └──────────────┘  └──────────┘  │         └──────────┘
                                                  │   macOS | iOS | Android
┌──────────────────────────────────────────────────────────────────┐
│                       配套应用层                                   │
│  - macOS 菜单栏应用                                               │
│  - iOS 节点                                                      │
│  - Android 节点                                                   │
└──────────────────────────────────────────────────────────────────┘
```

---

## 目录结构

```
E:\plantform\openclaw\openclaw
├── src/                    # 核心源代码
│   ├── gateway/            # Gateway 服务端
│   ├── channels/           # 各渠道实现 (whatsapp, telegram, discord, slack等)
│   ├── agents/             # AI Agent 运行时
│   ├── sessions/           # 会话管理
│   ├── cli/                # 命令行工具
│   ├── config/             # 配置处理
│   ├── security/           # 安全模块
│   ├── browser/            # 浏览器控制
│   ├── canvas-host/        # Canvas 宿主
│   ├── node-host/          # 节点管理
│   ├── cron/               # 定时任务
│   ├── process/            # 后台进程管理
│   ├── tts/                # 文本转语音
│   ├── providers/          # AI 模型提供商
│   ├── web/                # Web 服务 (Control UI + WebChat)
│   └── ...                 # 其他模块
│
├── packages/               # 子包
│   ├── clawdbot/          # ClawBot 插件
│   └── moltbot/           # MoltBot 插件
│
├── apps/                   # 平台应用
│   ├── macos/             # macOS 原生应用
│   ├── ios/               # iOS 应用
│   ├── android/           # Android 应用
│   └── shared/            # 共享代码 (OpenClawKit)
│
├── skills/                 # 内置技能
├── extensions/             # 扩展
├── config/                 # 配置模板
├── docs/                   # 文档
├── scripts/                # 构建和工具脚本
├── test/                   # 测试
├── ui/                     # Web UI 前端
├── dist/                   # 编译输出目录
└── openclaw.mjs           # CLI 入口点
```

---

## 关键模块说明

### 1. Gateway (核心服务)

- **位置**: `src/gateway/`
- **功能**:
  - WebSocket 控制平面 (默认端口: 18789)
  - 会话生命周期管理
  - 工具调用路由
  - 配置热更新
  - 事件分发
  - Cron 定时任务调度
  - Webhook 处理

### 2. Channels (消息渠道)

- **位置**: `src/channels/`
- **支持渠道**:
  - WhatsApp (Baileys)
  - Telegram (grammY)
  - Slack (Bolt)
  - Discord (discord.js)
  - Google Chat (Chat API)
  - Signal (signal-cli)
  - BlueBubbles (iMessage)
  - iMessage (legacy)
  - Microsoft Teams
  - Matrix
  - Zalo
  - WebChat

### 3. Agent Runtime

- **位置**: `src/agents/`
- **模式**: RPC (远程过程调用)
- **功能**:
  - 基于 pi-mono 的 Agent 核心运行时
  - 工具流式输出
  - 块流式输出
  - 模型调用
  - 上下文管理

### 4. Tools (工具系统)

- **浏览器控制**: `src/browser/` - 使用 Playwright 控制 Chrome/Chromium
- **Canvas**: `src/canvas-host/` - 可视化工作区
- **节点管理**: `src/node-host/` - 设备节点控制
- **定时任务**: `src/cron/` - Cron 调度
- **进程管理**: `src/process/` - 后台进程
- **TTS**: `src/tts/` - 文本转语音

### 5. Security (安全)

- **位置**: `src/security/`
- **功能**:
  - DM 策略控制 (pairing/open)
  - 沙箱模式 (Docker)
  - 权限验证
  - 允许列表/拒绝列表

### 6. Web Surface

- **位置**: `src/web/`, `ui/`
- **功能**:
  - Control UI (管理界面)
  - WebChat (网页聊天)
  - Dashboard

---

## 编译方式

### 前置要求

- Node.js >= 22.12.0
- pnpm 10.23.0

### 安装依赖

```bash
cd E:\plantform\openclaw\openclaw
pnpm install
```

### 构建项目

```bash
# 完整构建
pnpm build

# 构建包括以下步骤:
# 1. pnpm canvas:a2ui:bundle      # 打包 A2UI
# 2. tsdown                         # TypeScript 编译 (使用 Rolldown)
# 3. pnpm build:plugin-sdk:dts     # 生成插件 SDK 类型定义
# 4. 脚本处理各种元数据生成和复制
```

### 编译输出

- **输出目录**: `dist/`
- **入口文件**: `dist/index.js`, `dist/entry.js`
- **插件 SDK**: `dist/plugin-sdk/`

### 单独构建 UI

```bash
pnpm ui:build
```

---

## 启动方式

### 方式 1: 直接运行 CLI (推荐)

```bash
# 开发模式 (TypeScript 直接运行)
pnpm openclaw gateway

# 带详细日志
pnpm openclaw gateway --verbose

# 指定端口
pnpm openclaw gateway --port 18789
```

### 方式 2: 构建后运行

```bash
# 先构建
pnpm build

# 运行编译后的代码
node dist/entry.js gateway
```

### 方式 3: 使用 npm scripts

```bash
# 开发模式 (跳过渠道)
pnpm gateway:dev

# 监听模式 (自动重新加载)
pnpm gateway:watch

# 生产模式
pnpm start
```

### 方式 4: 全局安装后运行

```bash
# 安装到全局
pnpm add -g openclaw

# 运行
openclaw gateway
```

### 启动 Gateway 服务

```bash
# 启动 Gateway 守护进程
openclaw gateway start

# 查看状态
openclaw gateway status

# 停止
openclaw gateway stop

# 重启
openclaw gateway restart
```

### Docker 运行

```bash
# 构建镜像
docker build -t openclaw .

# 运行
docker run -p 18789:18789 openclaw
```

---

## 开发模式

### 监听模式 (自动重载)

```bash
# TypeScript 变更自动重新加载
pnpm gateway:watch
```

### 调试模式

```bash
# VSCode 调试配置
# 或使用 --inspect 标志
node --inspect dist/entry.js gateway
```

---

## 关键配置文件

| 文件 | 用途 |
|------|------|
| `tsconfig.json` | TypeScript 编译配置 |
| `tsdown.config.ts` | Tsdown 编译器配置 |
| `vitest.config.ts` | 测试配置 |
| `package.json` | 项目依赖和脚本 |
| `pnpm-workspace.yaml` | pnpm workspace 配置 |
| `openclaw.mjs` | CLI 入口点 |
| `.gitignore` | Git 忽略规则 |
| `.npmrc` | npm 配置 |

---

## 技术栈

### 核心技术

- **语言**: TypeScript 5.9.3
- **运行时**: Node.js >= 22.12.0
- **编译器**: Tsdown (Rolldown)
- **包管理器**: pnpm 10.23.0

### 主要依赖

- **Agent Core**: `@mariozechner/pi-agent-core` (0.52.9)
- **WebSocket**: `ws` (8.19.0)
- **HTTP 服务**: `express` (5.2.1), `hono` (4.11.9)
- **浏览器控制**: `playwright-core` (1.58.2)
- **Markdown**: `markdown-it` (14.1.0)
- **数据验证**: `zod` (4.3.6), `@sinclair/typebox` (0.34.48)
- **数据库**: `sqlite-vec` (向量搜索)

### 渠道依赖

- WhatsApp: `@whiskeysockets/baileys`
- Telegram: `grammy`
- Slack: `@slack/bolt`
- Discord: `discord-api-types`

---

## 测试

```bash
# 运行所有测试
pnpm test

# 单元测试
vitest run

# E2E 测试
pnpm test:e2e

# 覆盖率
pnpm test:coverage

# Live 测试 (需要真实环境)
pnpm test:live

# Docker 测试
pnpm test:docker:all
```

---

## 代码检查和格式化

```bash
# 检查
pnpm check
# 包括: format:check + tsgo + lint

# 格式化
pnpm format

# Lint
pnpm lint

# 修复 Lint 问题
pnpm lint:fix
```

---

## 贡献者

本项目由 Peter Steinberger 和社区贡献者共同维护。

**GitHub**: https://github.com/openclaw/openclaw
**文档**: https://docs.openclaw.ai
**Discord**: https://discord.gg/clawd

---

## 许可证

MIT License
