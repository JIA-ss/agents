---
name: sdd-init
description: >
  在目标项目中一键初始化 Skill 驱动开发（SDD）体系。
  Use when the user asks to "initialize SDD", "setup skill-driven development",
  "create CLAUDE.local.md", "bootstrap skill system", "init skill framework",
  mentions "SDD", "skill-driven", "skill体系搭建",
  or needs help with setting up a new project's skill-driven development framework.
  Also responds to "初始化SDD", "搭建skill体系", "创建skill框架", "部署SDD".
---

# SDD Init - Skill 驱动开发体系初始化

## Overview

在目标项目中一键搭建 Skill 驱动开发（SDD）体系。自动创建 CLAUDE.local.md、目录结构和首个 Skill，让项目在 5 分钟内开始使用 Skill 驱动开发。

**核心能力**：
- 交互式收集项目信息（名称、技术栈、核心模块）
- 生成定制化的 CLAUDE.local.md
- 创建首个框架级或特性级 Skill
- 可选运行索引生成脚本

## Workflow

### 触发后立即执行

**Step 1: 收集项目信息**

使用 AskUserQuestion 收集：

```
问题 1: 项目名称
  - 示例: "MyGameProject", "ecommerce-api", "data-pipeline"

问题 2: 技术栈
  - 选项: Unity/C#, Node.js, Python, Go, Java, 其他

问题 3: 第一个 Skill 名称
  - 引导: "你最近改得最多的模块叫什么？"
  - 示例: "character-controller", "payment-system", "etl-processor"

问题 4: 目标路径
  - 默认: 当前工作目录
```

**Step 2: 确定目标路径**

- 如果用户通过参数传入了路径，使用该路径
- 否则使用当前工作目录
- 验证路径存在

**Step 3: 创建目录结构**

```bash
mkdir -p <target>/.claude/skills/<skill-name>
```

**Step 4: 生成 CLAUDE.local.md**

基于模板 `templates/CLAUDE.local.template.md`（位于本 Skill 目录内），替换占位符：

| 占位符 | 替换为 |
|--------|--------|
| `{项目名称}` | 用户输入的项目名 |
| `{项目简介}` | 基于技术栈自动生成简介 |
| `{技术栈}` | 用户选择的技术栈 |
| `{模块路径1}` | 基于技术栈推断常见目录（如 `src/`, `Assets/Scripts/`） |
| `{框架Skill名称}` | 第一个 Skill 名称 |

将生成的内容写入 `<target>/CLAUDE.local.md`。

如果 `CLAUDE.local.md` 已存在，询问用户是覆盖还是跳过。

**Step 5: 生成首个 SKILL.md**

基于模板 `templates/SKILL.template.md`（位于本 Skill 目录内），生成精简版（仅保留必选章节）：

1. 填写 frontmatter（name, description 基于 Skill 名称和技术栈生成）
2. 填写 Overview（基于 Skill 名称生成概述）
3. 留空 Core Rules（提示用户后续填写）
4. 留空 Reference Files（提示用户后续填写）
5. 删除所有可选章节和模板注释

将生成的内容写入 `<target>/.claude/skills/<skill-name>/SKILL.md`。

**Step 6: 输出完成摘要**

```markdown
## SDD 初始化完成

**项目**: {项目名称}
**技术栈**: {技术栈}
**已创建**:
- CLAUDE.local.md（项目总纲）
- .claude/skills/{skill-name}/SKILL.md（首个 Skill）

**下一步**:
1. 编辑 `.claude/skills/{skill-name}/SKILL.md`，填写 Core Rules 和 Reference Files
2. 在 Claude Code 中测试 Skill 是否被识别
3. 逐步添加更多 Skill（参考 sdd/guides/feature-identification.md）
```

## Core Rules

### 规则 1: 不覆盖已有文件
如果目标路径已存在 CLAUDE.local.md 或 SKILL.md，必须询问用户后才能覆盖。

### 规则 2: 技术栈适配
不同技术栈的 CLAUDE.local.md 全局约束章节应有所不同：
- **Unity/C#**: PascalCase 规范、IL2CPP、性能要求
- **Node.js**: ESLint/Prettier、ES Modules、JWT
- **Python**: PEP 8、Ruff、type hints、Poetry
- **通用**: 仅保留 Git 规范和证据驱动原则

### 规则 3: SKILL.md 保持最小集
初始化时生成的 SKILL.md 只包含必选章节的骨架，不要过度填充。让用户在实际使用中逐步完善。

### 规则 4: Sync 规则不可删减
CLAUDE.local.md 中的"智能 Sync 规则"表格（9 种变更类型）是核心，初始化时必须完整包含，不可精简。

## Reference Files

**所有资源已内置于本 Skill 目录中**，部署时自包含：
```
skills/sdd-init/
├── SKILL.md                                 # 本文件
├── templates/
│   ├── CLAUDE.local.template.md             # CLAUDE.local.md 模板
│   ├── SKILL.template.md                    # SKILL.md 模板
│   └── examples/
│       ├── unity-csharp/                    # Unity/C# 适配示例
│       │   ├── CLAUDE.local.md
│       │   └── sample-skill/SKILL.md
│       ├── nodejs/                          # Node.js 适配示例
│       │   ├── CLAUDE.local.md
│       │   └── sample-skill/SKILL.md
│       └── python/                          # Python 适配示例
│           ├── CLAUDE.local.md
│           └── sample-skill/SKILL.md
├── guides/
│   ├── quick-start.md                       # 快速接入指南
│   ├── feature-identification.md            # 特性识别与 Skill 拆分指南
│   └── skill-lifecycle.md                   # Skill 生命周期管理规则
└── scripts/
    ├── generate-skill-index.py              # 索引自动生成脚本
    └── generate-health-report.py            # 健康报告生成脚本
```

## Related Systems

- **skill-generator**: 生成完整的 Skill（含 TDD 测试），适用于已有 SDD 体系后新增 Skill
- **sdd-init**: 本 Skill，初始化整个 SDD 体系，是 skill-generator 的前置步骤
