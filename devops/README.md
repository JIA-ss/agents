# DevOps 工具目录

## 概述

此目录包含 Claude Code Skills & Agents 项目的统一部署工具，通过**软连接 (symlink)** 方式将 skills、agents、commands 一键部署到 Claude Code 和 Codex CLI。

## 部署原理

使用软连接而非文件复制，修改仓库中的源文件后**立即生效**，无需重新运行部署脚本。

```
~/.claude/skills/   -> /path/to/agents/skills/
~/.claude/agents/   -> /path/to/agents/agents/
~/.claude/commands/ -> /path/to/agents/commands/

~/.codex/skills/    -> /path/to/agents/skills/
~/.codex/agents/    -> /path/to/agents/agents/
~/.codex/commands/  -> /path/to/agents/commands/
```

## 工具列表

| 脚本文件 | 适用平台 | 功能说明 |
|---------|---------|---------|
| `deploy-macos.sh` | macOS/Linux | 软连接部署 skills + agents + commands |
| `deploy-windows.bat` | Windows | 软连接部署 skills + agents + commands |

## 使用说明

### macOS/Linux

```bash
chmod +x devops/deploy-macos.sh
./devops/deploy-macos.sh
```

### Windows

```batch
devops\deploy-windows.bat
```

> Windows 下优先使用 Junction（不需要管理员权限），失败时回退到 Symlink（需要管理员权限或开发者模式）。

## 部署资源

| 资源类型 | 源目录 | 说明 |
|---------|--------|------|
| Skills | `skills/` | Skill 定义（含 SKILL.md） |
| Agents | `agents/` | Agent 定义（.md 文件） |
| Commands | `commands/` | 斜杠命令定义（.md 文件） |

## 部署目标

### Claude Code

- **macOS/Linux**: `~/.claude/{skills,agents,commands}/`
- **Windows**: `%USERPROFILE%\.claude\{skills,agents,commands}\`

### Codex CLI

- **macOS/Linux**: `~/.codex/{skills,agents,commands}/`
- **Windows**: `%USERPROFILE%\.codex\{skills,agents,commands}\`

## 部署行为

脚本会自动处理以下情况：

1. **目标不存在** → 直接创建软连接
2. **已是正确的软连接** → 跳过，无需操作
3. **软连接指向错误** → 自动修复
4. **目标是普通目录** → 备份后替换为软连接

## 部署后操作

- **Claude Code**: 重启以加载变更
- **Codex CLI**: 运行 `codex --enable skills` 启用 skills
- 后续修改源文件**无需重新部署**，重启工具即可生效

## 旧脚本

`bin/deploy-agents.sh` 已废弃，会自动转发到统一部署脚本。
