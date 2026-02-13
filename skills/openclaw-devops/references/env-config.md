# OpenClaw Environment Configuration

## Instance Details

| Item | Value |
|------|-------|
| Version | 2026.2.1 |
| Binary | `~/.npm-global/bin/openclaw` |
| Package | `~/.npm-global/lib/node_modules/openclaw` |
| Gateway Package | `~/.npm-global/lib/node_modules/clawdbot` |

## 双配置体系

OpenClaw 有两套独立的配置路径。CLI 和 Gateway 各读各的主配置文件，Agent 级配置需保持镜像同步。

### 主配置文件（不会自动同步）

| 文件 | 读取者 | 用途 |
|------|--------|------|
| `~/.openclaw/openclaw.json` | `openclaw` CLI | CLI 命令使用的配置 |
| `~/.clawdbot/clawdbot.json` | `clawdbot` gateway | Telegram bot / Web 等通道使用的配置 |

### Agent 级配置（需手动镜像同步）

| 文件（CLI 侧） | 文件（Gateway 侧） | 内容 |
|-----------------|---------------------|------|
| `~/.openclaw/agents/main/agent/models.json` | `~/.clawdbot/agents/main/agent/models.json` | 自定义 Provider 和模型定义 |
| `~/.openclaw/agents/main/agent/auth-profiles.json` | `~/.clawdbot/agents/main/agent/auth-profiles.json` | 认证凭证（API Key、OAuth Token） |

### 主配置中与模型相关的关键字段

| 字段路径 | 作用 |
|----------|------|
| `models.providers` | 主配置级自定义 Provider（与 agent 级 models.json 合并） |
| `agents.defaults.model.primary` | 默认主模型 |
| `agents.defaults.model.fallbacks` | Fallback 模型链（影响 Telegram `/models` 显示） |
| `agents.defaults.models` | 已配置模型允许列表（影响 Telegram `/models` 显示） |
| `auth.profiles` | 主配置级 auth 配置（与 agent 级 auth-profiles.json 合并） |

## Gateway

| Item | Value |
|------|-------|
| Port | `18789` |
| Auth | Token-based |
| Service | `ai.openclaw.gateway` (launchd) |
| Logs | `~/.openclaw/logs/gateway.log` |
| Error Logs | `~/.openclaw/logs/gateway.err.log` |

## Workspace

| Item | Value |
|------|-------|
| Agent Workspace | `/Users/joshuasun/clawd` |
| Config Directory (CLI) | `~/.openclaw/` |
| Config Directory (Gateway) | `~/.clawdbot/` |
| Skills (workspace) | `~/clawd/skills/` |
| Skills (bundled) | 52+ in package |

## Enabled Channels

| Channel | Status |
|---------|--------|
| Telegram | Active (bot token configured, proxy: 127.0.0.1:1082) |
| iMessage | Active (via imsg CLI) |
| Web | Active |

## Models

| Provider | Model | Context Window | Auth | 备注 |
|----------|-------|---------------|------|------|
| Kimi Code | kimi-for-coding | 262,144 tokens | API Key | 默认 primary 模型 |
| OpenAI | CodeX (OAuth) | - | OAuth | |
| Anthropic | claude-sonnet-4-5-20250929 | 200,000 tokens | API Key (PROXY_MANAGED) | via ccswitch proxy (127.0.0.1:15721) |
| Anthropic | claude-opus-4-6 | 200,000 tokens | API Key (PROXY_MANAGED) | via ccswitch proxy (127.0.0.1:15721) |
| Anthropic | claude-haiku-4-5-20251001 | 200,000 tokens | API Key (PROXY_MANAGED) | via ccswitch proxy (127.0.0.1:15721) |

### 受支持的 API 类型

| API 类型 | 对应服务 |
|----------|----------|
| `anthropic-messages` | Anthropic Claude |
| `openai-completions` | OpenAI / 兼容接口 |
| `openai-responses` | OpenAI Responses API |
| `openai-codex-responses` | OpenAI Codex |
| `azure-openai-responses` | Azure OpenAI |
| `google-generative-ai` | Google Gemini |
| `google-gemini-cli` | Google Gemini CLI |
| `google-vertex` | Google Vertex AI |
| `bedrock-converse-stream` | AWS Bedrock |

## Cron Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| money-maker-daily | 04:00 Asia/Shanghai | Daily automation |
| skill-improver-daily | 03:00 Asia/Shanghai | Skill improvement |
| moltbook-daily-play | 12:00 Asia/Shanghai | Moltbook tasks |
| money-maker-evolution | Fri 21:00 | Weekly strategy |
| free-exploration-time | Sun 22:00 | Weekly free time |
| oss-ai-pm-daily-report | 19:00 Asia/Shanghai | OSS AI reports |
| oss-ai-dev-daily | 12:30 Asia/Shanghai | Daily dev cycle |

## Paired Devices

| Device | Platform | Role |
|--------|----------|------|
| CLI | darwin | operator |
| Control UI | MacIntel | operator |

## 常见排错经验

### 症状：CLI 能看到模型，Telegram `/models` 看不到
**原因**：只修改了 `~/.openclaw/openclaw.json`，没同步到 `~/.clawdbot/clawdbot.json`
**解法**：将 `agents.defaults.model.fallbacks` 和 `agents.defaults.models` 同步到 `clawdbot.json`，然后 `openclaw gateway restart`

### 症状：添加 Provider 后报 "No API provider registered for api: xxx"
**原因**：`models.json` 中 `api` 字段值不正确
**解法**：确认使用正确的 API 类型（如 Anthropic 必须用 `anthropic-messages` 而非 `anthropic`）

### 症状：自定义 Provider 名称（如 `anthropic-ccswitch`）在配置中被丢弃
**原因**：OpenClaw 的 config pipeline 可能过滤非标准 provider 名称
**解法**：使用标准 provider 名称（如 `anthropic`），通过模型 display name 加 `[标记]` 来区分不同实例
