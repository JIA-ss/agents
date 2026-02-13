---
name: openclaw-devops
description: OpenClaw 运维管理助手。管理 Gateway 服务（启停重启、健康检查）、查看日志、诊断排错、模型与 Provider 管理、Skill/Plugin 管理、Cron 任务管理和配置操作。Use when the user mentions openclaw, gateway, 网关, asks to check OpenClaw status, view logs, manage models/providers, restart gateway, run diagnostics, or manage cron jobs. Also responds to "openclaw 状态", "openclaw 日志", "openclaw 诊断", "openclaw 模型", "openclaw doctor", "openclaw logs", "openclaw cron".
---

# OpenClaw DevOps

运维管理助手 — 在 Claude Code 中直接管理、监控和诊断本地 OpenClaw 实例。

---

## 🚀 执行流程

**当此 skill 被触发时，按以下流程执行：**

### 立即行动

1. 识别用户意图属于哪个模块
2. 执行对应 CLI 命令
3. 解析输出，提供结构化反馈
4. 如需修复，确认后执行操作

### 📋 进度追踪 Checklist

```
- [ ] IDENTIFY → 识别操作模块和具体意图
- [ ] EXECUTE → 运行对应 openclaw CLI 命令
- [ ] ANALYZE → 解析命令输出，提炼关键信息
- [ ] ACTION → 根据诊断结果执行修复 (需确认)
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| IDENTIFY | 已确定目标模块和操作 | → EXECUTE |
| EXECUTE | CLI 命令已执行，输出已获取 | → ANALYZE |
| ANALYZE | 结构化分析已输出给用户 | → ACTION (如需) |
| ACTION | 操作已执行并验证生效 | → 结束 |

---

## 模块速查

| 模块 | 触发关键词 | 首选命令 |
|------|-----------|----------|
| Gateway 管理 | 网关、gateway、状态、启停 | `openclaw gateway status` |
| 日志监控 | 日志、logs、报错 | `openclaw logs --limit 50` |
| 诊断排错 | 诊断、doctor、修复、问题 | `openclaw doctor` |
| 状态总览 | 状态、status、健康 | `openclaw status --all` |
| 模型管理 | 模型、model、provider、切换模型 | `openclaw models status` |
| Skill/Plugin | skill、plugin、插件 | `openclaw skills list` |
| Cron 任务 | cron、定时、计划任务 | `openclaw cron list` |
| 配置管理 | 配置、config、设置 | `openclaw config get` |

---

## Phase 1: IDENTIFY（识别意图）

**你必须：**
1. 根据用户请求，匹配上方模块表中的模块
2. 如意图模糊（如"openclaw 有问题"），默认运行综合健康检查脚本: `bash scripts/oc-health.sh`
3. 如涉及多个模块，按优先级依次执行
4. 如需了解当前环境详情（通道、模型、Cron 等），读取 [references/env-config.md](references/env-config.md)

**完成标志**: 已确定目标模块和操作

---

## Phase 2: EXECUTE（执行命令）

**你必须：** 根据识别的模块，使用 Bash 工具执行对应 CLI 命令。遇到不在下方列表中的命令时，读取 [references/cli-reference.md](references/cli-reference.md) 查找完整命令参考。

### Gateway 管理

```bash
# 查看状态
openclaw gateway status
openclaw health

# 启停服务（破坏性操作，需先确认）
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# 服务安装管理
openclaw daemon status
openclaw daemon install
openclaw daemon uninstall
```

**注意**: `start`/`stop`/`restart` 是破坏性操作，执行前必须确认用户意图。

### 日志监控

```bash
# 网关日志
openclaw logs --limit 50           # 最近 50 行
openclaw logs --limit 100 --json   # JSON 格式

# 通道日志
openclaw channels logs --channel telegram
```

### 诊断排错

```bash
# 基础诊断
openclaw doctor

# 自动修复
openclaw doctor --repair

# 深度扫描
openclaw doctor --deep

# 安全审计
openclaw security audit
openclaw security audit --fix
```

### 状态总览

```bash
openclaw status                    # 通道 + 会话
openclaw status --all              # 完整诊断
openclaw status --usage            # 包含模型用量
openclaw status --deep             # 探测所有通道
```

### 模型与 Provider 管理

```bash
# 查看状态
openclaw models status             # 配置状态
openclaw models status --probe     # 实时探测 auth
openclaw models list               # 已配置模型
openclaw models list --all         # 完整模型目录

# 切换模型
openclaw models set <model-id>
openclaw models set-image <model-id>

# Fallback 管理
openclaw models fallbacks list
openclaw models fallbacks add <model-id>
openclaw models fallbacks remove <model-id>

# Auth 管理
openclaw models auth add
openclaw models auth login --provider <id>
openclaw models auth setup-token
openclaw models auth paste-token --provider <id>

# 扫描可用模型
openclaw models scan
openclaw models scan --min-params 70

# 别名管理
openclaw models aliases list
openclaw models aliases add <alias> <model>
```

### Skill/Plugin 管理

```bash
# Skills
openclaw skills list
openclaw skills list --eligible
openclaw skills info <name>
openclaw skills check

# Plugins
openclaw plugins list
openclaw plugins list --enabled
openclaw plugins info <name>
openclaw plugins enable <name>
openclaw plugins disable <name>
openclaw plugins install <spec>
openclaw plugins doctor
```

### Cron 任务管理

```bash
openclaw cron status               # 调度器状态
openclaw cron list                 # 任务列表
openclaw cron list --all           # 含禁用任务
openclaw cron runs --id <job-id>   # 运行历史
openclaw cron run <job-id> --force # 手动触发
openclaw cron enable <job-id>
openclaw cron disable <job-id>
openclaw cron add --name <n> --every <interval> --message <msg>
openclaw cron rm <job-id>
openclaw cron edit <job-id> --message <msg>
```

### 配置管理

```bash
openclaw config get <dot.path>
openclaw config set <dot.path> <value>
openclaw config unset <dot.path>
```

**完成标志**: CLI 命令已执行，输出已获取

---

## Phase 3: ANALYZE（分析输出）

**你必须：**
1. 解析命令输出，提取关键状态信息
2. 用结构化格式（表格或列表）呈现结果
3. 标注异常项并给出建议
4. 对于模糊问题，提供可能的原因分析

**输出格式示例**:

```
## OpenClaw 状态摘要

| 组件 | 状态 | 详情 |
|------|------|------|
| Gateway | ✅ 运行中 | port 18789, uptime 3d |
| Telegram | ✅ 已连接 | bot active |
| iMessage | ✅ 已连接 | via imsg CLI |
| Models | ⚠️ 注意 | Kimi Code auth expires in 2h |

### 建议
- Kimi Code auth 即将过期，建议运行 `openclaw models auth login --provider kimi`
```

**完成标志**: 结构化分析已输出

---

## Phase 4: ACTION（修复操作）

**你必须：**
1. 只在诊断发现问题时提供修复建议
2. 修复操作需先向用户确认
3. 修复后重新检查状态验证效果

**破坏性操作清单**（必须确认）:
- Gateway 启停: `gateway start/stop/restart`
- 服务安装/卸载: `daemon install/uninstall`
- 配置修改: `config set/unset`
- 自动修复: `doctor --repair`, `security audit --fix`
- Cron 增删: `cron add/rm`
- Plugin 启停: `plugins enable/disable`

**完成标志**: 操作已执行并验证

---

## 环境信息

| 项目 | 值 |
|------|------|
| Gateway 端口 | `18789` |
| 认证方式 | Token |
| 系统服务 | `ai.openclaw.gateway` (launchd) |
| 工作区 | `/Users/joshuasun/clawd` |
| 配置文件 | `~/.openclaw/openclaw.json` |
| 日志 | `~/.openclaw/logs/gateway.log` |
| 已启用通道 | Telegram, iMessage, Web |
| 模型 | Kimi Code, OpenAI CodeX |

---

## 资源

| 资源 | 路径 | 用途 | 使用时机 |
|------|------|------|----------|
| CLI 速查 | [references/cli-reference.md](references/cli-reference.md) | 完整 CLI 命令参考（含 Channel、Session、Browser、Update 等） | Phase 2 遇到不在上方列表中的命令需求时读取 |
| 环境配置 | [references/env-config.md](references/env-config.md) | 实例配置详情（Cron 详情、设备信息、模型参数） | Phase 1 需要了解当前环境上下文时读取 |
| 健康检查 | [scripts/oc-health.sh](scripts/oc-health.sh) | 一键综合健康检查（组合 health+status+models+cron） | Phase 1 用户意图模糊时运行: `bash scripts/oc-health.sh` |
