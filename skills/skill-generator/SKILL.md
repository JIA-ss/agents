---
name: skill-generator
description: Use when the user asks to "create a skill", "generate skill file", "build new skill", "design AI skill", mentions "skill generation", "skill template", or needs to create a new Claude Code skill following SKILL.md standards. Also responds to "创建 skill", "生成 skill", "构建新 skill".
---

# Skill Generator Guide

## Overview

元级别的 AI skill，用于根据用户需求自动生成符合规范的 Claude Code skills（SKILL.md 文件）。

**核心价值**：标准化、自动化、可视化、质量保证

## SKILL.md 标准格式

```markdown
---
name: skill-name
description: Use when the user asks to "keyword1", "keyword2", mentions "keyword3", or needs help with specific-task. Also responds to "中文关键词1", "中文关键词2".
---

# Skill Name Guide

## Overview
[概括性介绍：是什么、做什么、为什么]

## Workflow
[工作流程说明]

## Core Rules
[核心规则/约束]

## Output Requirements
[输出格式要求]

## Best Practices
[最佳实践]
```

## Workflow (5 Phases)

1. **Requirement Analysis** - 多轮对话理解需求，定义触发关键词
2. **Structure Design** - 设计工作流程、核心规则、输出要求
3. **Content Generation** - 递归应用四步法则生成内容
4. **Quality Assurance** - 多维度质量检查
5. **Auto Deployment** - 保存到 skills/ 目录，部署到 ~/.claude/skills/

## Frontmatter 规范

| 字段 | 说明 | 必需 |
|------|------|------|
| `name` | Skill 名称（对应目录名） | ✅ |
| `description` | 触发关键词描述（中英文） | ✅ |

**注意**: Skills 不需要 `model` 字段，由 Claude Code 自动选择模型。

## Quality Checklist

- [ ] Frontmatter 包含 name 和 description
- [ ] description 包含中英文触发关键词
- [ ] Overview 说明"是什么、做什么、为什么"
- [ ] Workflow 有清晰的步骤
- [ ] 包含 Core Rules 或关键约束
- [ ] 包含 Output Requirements 或输出格式
- [ ] 文件行数控制在 100-300 行

## Best Practices

1. 触发关键词要具体、明确，避免过于宽泛
2. 中英文关键词都要覆盖
3. 使用 Mermaid 图表可视化复杂流程
4. 保持内容简洁，避免冗余
5. 部署后在 Claude Code 中测试触发效果
