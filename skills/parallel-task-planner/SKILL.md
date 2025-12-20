---
name: parallel-task-planner
description: Use when the user asks to "plan parallel tasks", "optimize task execution", "identify parallel opportunities", "generate task documents", mentions "parallel execution", "task dependencies", "auto-execution", or needs to decompose tasks with parallel execution planning and document generation. Also responds to "并行任务规划", "优化执行顺序", "识别并行机会".
---

# Parallel Task Planner Skill Guide

## Overview

将复杂任务智能拆解为可并行执行的子任务树，生成完整的任务文档体系。

**核心价值**：
- 智能分解 + 可视化规划
- 并行优化 + 自动执行
- 文档完备 + 多终端协同

## Workflow (4 Phases)

| Phase | Description |
|-------|-------------|
| 1. Requirement Collection | 收集任务描述、路径配置、清理选项、自动执行选项 |
| 2. Task Analysis | 复杂度评估、风险评估、依赖识别、任务树构建 |
| 3. Document Generation | 执行指引、通用背景、任务提示词、自动执行脚本 |
| 4. User Confirmation | 展示任务树、确认拆分合理性、依赖正确性、并行可行性 |

## Risk Level Assessment

| Risk Level | Examples | Execution Mode |
|------------|----------|----------------|
| Low | 文档生成、代码分析、UI设计 | 自动执行 |
| Medium | 代码编写、测试执行、配置修改 | 半自动（需审查） |
| High | 数据库操作、部署发布、删除操作 | 强制人工确认 |

## Execution Modes

| Mode | Description |
|------|-------------|
| Auto | 低风险任务自动后台执行 |
| Manual | 所有任务需人工确认 |
| Hybrid | 低风险自动，高风险人工（推荐） |

## Output Documents

| File | Content |
|------|---------|
| `execution-guide.md` | 任务概览、Mermaid树状图、自动执行策略、依赖说明 |
| `common-context.md` | 项目概述、技术栈、开发环境、代码库结构 |
| `task-{id}.md` | 任务概述、目标、验收标准、依赖、执行命令 |
| `auto-execution.md` | 自动执行任务清单、批量执行脚本、失败回滚策略 |
| `cleanup-task.md` | 清理目标、步骤、验证方式 |

## Task File Template

- Task overview (ID, name, type, priority, risk level, execution mode)
- Task goals and acceptance criteria
- Input/Output and dependencies
- Execution steps
- Claude Code execution command (for auto tasks)

## Constraints

- Task granularity: 30 min - 4 hours
- High coupling limits parallelization benefits
- Parallel tasks must not modify same files
- Parallelism ≤ team size

## Auto-Execution Best Practices

1. Start with manual mode to verify task decomposition quality
2. Prioritize auto-execution for read-only tasks
3. Use semi-auto for medium-risk: generate code, human review
4. Force manual confirmation for high-risk operations
5. Monitor auto-execution logs
6. Set timeout mechanisms
