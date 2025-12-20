# DevOps 工具目录

## 概述

此目录包含 Claude Code Skills 项目的部署和运维工具，提供自动化脚本简化 skills 的部署流程。

## 工具列表

### 部署脚本

| 脚本文件 | 适用平台 | 功能说明 |
|---------|---------|---------|
| `deploy-windows.bat` | Windows | 一键部署所有 skills 到 Claude Code 和 Codex CLI |
| `deploy-macos.sh` | macOS/Linux | 一键部署所有 skills 到 Claude Code 和 Codex CLI |

## 使用说明

### Windows 平台

在项目根目录执行：

```batch
devops\deploy-windows.bat
```

### macOS/Linux 平台

在项目根目录执行：

```bash
chmod +x devops/deploy-macos.sh
./devops/deploy-macos.sh
```

## 部署目标

脚本会自动将 `skills/` 目录下的所有子目录中的 `SKILL.md` 文件复制到两个环境：

### Claude Code

- **Windows**: `%USERPROFILE%\.claude\skills\`
- **macOS/Linux**: `~/.claude/skills/`

### Codex CLI

- **Windows**: `%USERPROFILE%\.codex\skills\`
- **macOS/Linux**: `~/.codex/skills/`

## 部署后操作

1. **Claude Code**: 重启 Claude Code 以加载新部署的 skills
2. **Codex CLI**: 运行 `codex --enable skills` 启用 skills 功能

## 脚本功能

两个脚本都会自动完成以下操作：

1. 检测源文件目录是否存在
2. 检测 Claude Code 和 Codex CLI 目标目录
3. 如果目录不存在，自动创建
4. 遍历 skills/ 子目录，复制 SKILL.md 文件
5. 显示部署结果和 skills 列表
6. 提示用户重启应用或启用 skills

## 维护

如需修改部署逻辑，请同时更新两个平台的脚本，确保功能一致性。
