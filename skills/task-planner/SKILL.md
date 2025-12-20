---
name: task-planner
description: Use when the user asks to "plan a task", "break down project", "create task plan", "decompose requirements", "modular planning", mentions "task breakdown", "project planning", or needs to systematically organize a complex development task into executable steps. Also responds to "任务规划", "拆分任务", "创建任务计划", "需求分解", "模块化规划".
---

# Task Planner Skill Guide

## Overview

将复杂大型任务进行系统性规划和拆分，通过模块化和时序化分解，输出结构化的任务规划文档。

**核心价值**：
- 系统性拆分（模块化 + 时序化双维度递归分解）
- 可视化优先（先 Mermaid 图表，后文字说明）
- 分层文档结构（技术方案 + 任务编排分离）
- 高层架构视角（只搭建大框架，严禁深入代码实现细节）

## Core Methodology: Four-Step Rule

1. **Summarize** - 从整体概览开始，概括性介绍
2. **Visualize** - 先放 Mermaid 图表，再补充文字
3. **Decompose** - 识别子系统，拆分为更小单元
4. **Recurse** - 对复杂子系统重复应用四步法则（深度 2-3 层）

## Workflow (7 Phases)

| Phase | Description |
|-------|-------------|
| 1. Task Understanding | 解析目标、范围、约束、评估复杂度 |
| 2. Modular Decomposition | 按单一职责识别 3-7 个核心模块 |
| 3. Sequential Decomposition | 划分执行阶段、识别并行机会、标注关键路径 |
| 4. Dependency Analysis | 整合模块依赖和任务依赖 |
| 5. Technical Plan Doc | 生成 main-plan.md + module-*.md |
| 6. Task Scheduling Doc | 独立生成 tasks.md |
| 7. User Confirmation | 展示结果、收集反馈、优化规划 |

## Output Structure

```
.tasks/
└── {task-name}/
    ├── main-plan.md            # 主框架技术方案（高层架构）
    ├── tasks.md                # 任务编排文档（独立）
    ├── module-{模块1}.md       # 子模块1技术方案
    └── module-{模块2}.md       # 子模块2技术方案
```

## Document Templates Overview

### main-plan.md
- 任务目标（一句话 + 预期产出）
- 整体架构（Mermaid 架构图 + 文字说明）
- 模块概览（组件图 + 模块职责表）
- 执行阶段概览（流程图 + 阶段目标表）
- 关键路径（甘特图）
- 约束与风险

### tasks.md
- 任务总览（Mermaid 甘特图）
- 任务清单（按阶段分组，含优先级、依赖、可并行、状态）
- 依赖关系图
- 验收标准

### module-{模块名}.md
- 模块职责 + 输入/输出
- 模块架构（类图或组件图）
- 核心流程（流程图）
- 接口设计（类图 + 接口表）
- 依赖关系

## Prohibited Content (Red Lines)

| Prohibited | Example | Alternative |
|------------|---------|-------------|
| Function code | `function handleLogin() {...}` | Mermaid class diagram |
| SQL statements | `SELECT * FROM users...` | ER diagram + description |
| Config files | `package.json` content | Tech stack list |
| API calls | `axios.get('/api/user')` | Interface table |
| Script content | Shell/Batch scripts | Flowchart + steps |

## Recommended Approaches

- **Interface design** → Mermaid `classDiagram`
- **Algorithm logic** → Pseudocode or natural language steps
- **Data model** → Mermaid `erDiagram`
- **Process flow** → Mermaid `flowchart`
- **Timeline** → Mermaid `gantt`

## Constraints

- **Decomposition depth**: 2-4 levels (avoid over-splitting)
- **Task granularity**: 30 min - 8 hours per task
- **Diagram complexity**: Max 15 nodes per Mermaid diagram

## Best Practices

1. Always visualize first, then describe in text
2. Separate technical design (main-plan.md) from execution plan (tasks.md)
3. Keep main doc at high-level architecture view
4. Use class diagrams instead of code for interfaces
5. Use pseudocode instead of real code for algorithms
