---
name: task-dispatcher
description: Use when the user asks to "execute task plan", "dispatch tasks", "run task scheduler", "parallel task execution", mentions "task execution", "DAG scheduling", "progress tracking", or needs to execute tasks from a planning document with dependency management. Also responds to "执行任务", "任务调度", "并行执行", "进度跟踪".
---

# Task Dispatcher Skill Guide

## Overview

根据任务规划文档进行任务分发、调度和执行，支持并行任务编排和进度跟踪，确保按依赖顺序高效完成所有任务。

**核心价值**：智能调度 + 并行编排 + 进度追踪 + 失败处理 + 文档同步

## Workflow (4 Phases)

| Phase | Description |
|-------|-------------|
| 1. Task Loading | 读取文档，提取任务清单和依赖关系，构建 DAG |
| 2. Plan Generation | 拓扑排序，分组为并行批次，计算关键路径 |
| 3. Task Execution | 按批次执行，并行任务使用 Task 工具，验证结果 |
| 4. Progress Sync | 更新文档状态，生成进度报告，处理失败任务 |

## DAG Scheduling Algorithm

**Kahn's Algorithm (Topological Sort)**:
1. Add all nodes with in-degree 0 to queue
2. Remove node from queue, add to result
3. Decrease in-degree of all successors by 1
4. Add nodes with in-degree 0 to queue
5. Repeat until queue is empty

**Parallel Grouping**:
```
Batch 1: [in-degree 0 tasks] -- parallel
Batch 2: [depend on Batch 1, in-degree becomes 0] -- parallel
Batch 3: [depend on Batch 2, in-degree becomes 0] -- parallel
```

## Task Status

| Status | Mark | Description |
|--------|------|-------------|
| Pending | `[ ]` | 任务尚未开始 |
| In Progress | `[~]` | 任务正在执行 |
| Completed | `[x]` | 任务成功完成 |
| Failed | `[!]` | 任务执行失败 |
| Skipped | `[-]` | 任务被跳过 |

## Output Documents

| File | Content |
|------|---------|
| `execution-plan.md` | 任务依赖图、执行批次、关键路径、执行命令示例 |
| `progress-report.md` | 完成率、模块进度、任务状态明细、阻塞分析 |

## Failure Handling Strategies

| Strategy | When to Use | Impact |
|----------|-------------|--------|
| Retry | 临时性错误（网络、资源） | 重新执行该任务 |
| Skip | 非关键任务失败 | 依赖该任务的后续任务也被跳过 |
| Abort | 关键任务失败 | 停止整个执行流程 |

## Constraints

- Max parallel tasks: 5 (avoid resource contention)
- Dependencies must be explicitly marked in task documents
- Task granularity: 30 min - 4 hours
- Cycle detection: abort scheduling if found

## Best Practices

1. Verify 1-2 tasks serially before parallelizing
2. Update document status immediately after completion
3. Prioritize critical path tasks
4. Handle failed tasks promptly to avoid blocking
5. Review progress report after each batch
