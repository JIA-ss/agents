---
name: task-plan-reviewer
description: Use when the user asks to "review task plan", "evaluate planning quality", "check task structure", "validate dependencies", mentions "plan review", "architecture assessment", or needs to assess the quality and feasibility of a task planning document before execution. Also responds to "评审任务计划", "检查规划质量", "验证依赖", "评估可行性".
---

# Task Plan Reviewer Skill Guide

## Overview

通过六维度评审体系对 task-planner 生成的规划文档进行系统性审查，输出结构化评审报告并给出改进建议。

**核心价值**：质量检查 + 问题发现 + 改进建议 + 结构化报告

## Workflow (5 Phases)

| Phase | Description |
|-------|-------------|
| 1. Document Loading | 读取 `.tasks/{task-name}/` 下所有文档，构建文档模型 |
| 2. Six-Dimension Review | 架构、依赖、执行、完整性、文档、风险 |
| 3. Issue Aggregation | 按严重程度分类（Critical/Major/Minor） |
| 4. Score Calculation | 加权计算总分，应用质量门禁 |
| 5. Report Generation | 生成结构化 Markdown 评审报告 |

## Six-Dimension Framework

| Dimension | Weight | Key Checks |
|-----------|--------|------------|
| Architecture | 20% | 单一职责、模块粒度(3-7个)、边界清晰、功能覆盖、无重叠 |
| Dependencies | 20% | 循环依赖检测、依赖方向、完整性、耦合度(≤3) |
| Execution Order | 15% | 阶段顺序、步骤依赖、并行合理、关键路径、顺序冲突 |
| Task Completeness | 20% | 需求覆盖、任务粒度(30min-8h)、验收标准、优先级 |
| Documentation | 15% | 主文档视角、子文档详细度、图表质量、链接有效 |
| Risk Assessment | 10% | 技术风险、依赖风险、应对策略 |

## Scoring Rules

| Score Range | Grade | Action |
|-------------|-------|--------|
| 90-100 | Excellent | 可直接执行 |
| 80-89 | Good | 建议优化后执行 |
| 70-79 | Acceptable | 需要优化后执行 |
| 60-69 | Needs Improvement | 必须修复主要问题 |
| < 60 | Fail | 需重新规划 |

## Issue Classification

| Severity | Definition | Examples |
|----------|------------|----------|
| Critical | 必须修复，否则无法执行 | 循环依赖、顺序冲突 |
| Major | 建议修复，影响效率/质量 | 需求遗漏、边界模糊 |
| Minor | 可选优化，提升文档质量 | 格式问题、链接失效 |

## Report Structure

1. **Review Overview** - 总分、等级、各维度得分、评审结论
2. **Critical Issues** - 必须修复的问题及建议
3. **Major Issues** - 建议修复的问题及建议
4. **Minor Issues** - 可选优化表格
5. **Detailed Review** - 各维度详细发现
6. **Improvement Summary** - P0/P1/P2 优先级建议
7. **Review Metadata** - 工具版本、耗时、文档数量

## Best Practices

1. Review before task execution (lowest cost to find issues)
2. Re-review after fixing issues
3. Human review for critical issue fix suggestions
4. Focus on dependency and execution order (highest impact)
5. Keep review history in version control
