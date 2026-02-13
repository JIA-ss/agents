# OpenClaw Environment Configuration

## Instance Details

| Item | Value |
|------|-------|
| Version | 2026.2.1 |
| Binary | `~/.npm-global/bin/openclaw` |
| Package | `~/.npm-global/lib/node_modules/openclaw` |
| Config | `~/.openclaw/openclaw.json` |

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
| Config Directory | `~/.openclaw/` |
| Skills (workspace) | `~/clawd/skills/` |
| Skills (bundled) | 52+ in package |

## Enabled Channels

| Channel | Status |
|---------|--------|
| Telegram | Active (bot token configured, proxy: 127.0.0.1:1082) |
| iMessage | Active (via imsg CLI) |
| Web | Active |

## Models

| Provider | Model | Context Window |
|----------|-------|---------------|
| Kimi Code | kimi-code | 262,144 tokens |
| OpenAI | CodeX (OAuth) | - |

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
