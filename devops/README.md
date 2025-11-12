# DevOps 工具目录

## 概述

此目录包含 Claude Code Agents 项目的部署和运维工具，提供自动化脚本简化 agents 的部署流程。

## 工具列表

### 部署脚本

| 脚本文件 | 适用平台 | 功能说明 |
|---------|---------|---------|
| `deploy-windows.bat` | Windows | 一键部署所有 agents 到 Windows 本地配置 |
| `deploy-macos.sh` | macOS/Linux | 一键部署所有 agents 到 Unix 系统本地配置 |

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

脚本会自动将 `agents/` 目录下的所有 `.md` 文件复制到：

- **Windows**: `%USERPROFILE%\.claude\agents\`
- **macOS/Linux**: `~/.claude/agents/`

## 部署后操作

重启 Claude Code 以加载新部署的 agents。

## 脚本功能

两个脚本都会自动完成以下操作：

1. 检测目标目录是否存在
2. 如果不存在，自动创建目录
3. 复制所有 agent 文件到目标位置
4. 显示部署结果和文件列表
5. 提示用户重启 Claude Code

## 维护

如需修改部署逻辑，请同时更新两个平台的脚本，确保功能一致性。
