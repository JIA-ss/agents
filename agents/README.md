# Agents 目录

此目录用于存放 Claude Code 的 agent 描述文件。

## 说明

- 每个 agent 文件都是一个独立的 Markdown 文档
- 文件命名采用小写-连字符格式（如 `doc-writer.md`）
- 所有 agent 必须遵循 `../AGENT_SPEC.md` 中定义的规范

## ⚠️ 强制要求：Frontmatter

**所有 agent 文件必须在顶部包含 YAML frontmatter，否则 Claude Code 将无法识别。**

### 标准格式

```markdown
---
name: agent-name
description: Agent 的简短描述
model: sonnet
---

# Agent 名称

## 概述
...
```

### 必需字段

- `name`: Agent 名称（对应文件名，不含 .md 后缀）
- `description`: 简短描述（1-2 句话）
- `model`: Claude 模型名称（sonnet/opus/haiku）

### 自动添加 Frontmatter

如果你的 agent 文件缺少 frontmatter，可以使用自动化工具：

**Windows**:
```bash
..\devops\add-frontmatter.bat
```

**macOS/Linux**:
```bash
chmod +x ../devops/add-frontmatter.sh
../devops/add-frontmatter.sh
```

更多详细规范请参考 [AGENT_SPEC.md](../AGENT_SPEC.md) § 2.4 章节。

## 部署

生成的 agent 文件将通过部署脚本自动复制到本地 Claude Code 配置目录：
- **Windows**: `%USERPROFILE%\.claude\agents\`
- **macOS**: `~/.claude/agents/`

执行部署脚本：
- Windows: `devops\deploy-windows.bat`
- macOS: `./devops/deploy-macos.sh`
