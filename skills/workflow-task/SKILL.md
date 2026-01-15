---
name: workflow-task
description: 将技术计划分解为可执行的任务列表。通过 6 阶段流程（PARSE→DECOMPOSE→ANALYZE→REVIEW→REFINE→VALIDATE）将 plan.md 转化为 tasks.md，支持递归子模块规划、任务粒度检测、依赖分析和断点恢复。当用户想要"分解任务"、"任务列表"、"任务规划"时使用。也响应 "workflow task"、"工作流任务"。
---

# Workflow Task 指南

## 概述

基于已批准的技术计划（plan.md）生成可执行的任务列表（tasks.md），定义"做什么"。

**核心价值**：将技术方案转化为可执行任务，通过递归整合确保每个模块设计完善，支持 TDD 和并行执行。

---

## 工作流程（6 阶段）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW-TASK                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                           │
│  │  PARSE   │───►│DECOMPOSE │───►│ ANALYZE  │                           │
│  │ 解析计划 │    │ 分解任务 │    │ 依赖分析 │                           │
│  └──────────┘    └────┬─────┘    └────┬─────┘                           │
│                       │               │                                  │
│                       ▼               │                                  │
│                 ┌───────────┐         │                                  │
│                 │ 完整性检测 │         │                                  │
│                 └─────┬─────┘         │                                  │
│                       │               │                                  │
│                 ┌─────┴─────┐         │                                  │
│                 ▼           ▼         │                                  │
│              [完善]    [需细化]       │                                  │
│                 │           │         │                                  │
│                 │     ┌─────▼─────┐   │                                  │
│                 │     │ 触发子模块 │   │                                  │
│                 │     │ plan 规划 │   │                                  │
│                 │     └─────┬─────┘   │                                  │
│                 │           │         │                                  │
│                 │     ┌─────▼─────┐   │                                  │
│                 │     │ 合并子计划 │   │                                  │
│                 │     └─────┬─────┘   │                                  │
│                 │           │         │                                  │
│                 └─────┬─────┘         │                                  │
│                       ▼               ▼                                  │
│                 ┌──────────┐    ┌──────────┐                            │
│                 │  REVIEW  │◄───│ 生成任务 │                            │
│                 │ 独立审查 │    └──────────┘                            │
│                 └────┬─────┘                                            │
│                      │                                                   │
│                ┌─────┴─────┐                                            │
│                ▼           ▼                                            │
│             [PASS]  [NEEDS_IMPROVEMENT]                                 │
│                │           │                                            │
│                │     回退到 DECOMPOSE                                    │
│                ▼                                                         │
│          ┌──────────┐    ┌──────────┐                                   │
│          │  REFINE  │───►│ VALIDATE │                                   │
│          │ 优化任务 │    │ 用户确认 │                                   │
│          └──────────┘    └──────────┘                                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 阶段详细说明

> **详细参考**: [references/phase-details.md](references/phase-details.md) 包含各阶段的完整子任务列表、输入输出规范、判定规则和代码示例。本节仅提供概要说明。

### 阶段 1: PARSE（解析计划）

**目标**: 解析 plan.md，提取模块和架构信息

**输入**:
- `.workflow/{feature}/plan/plan.md`（状态必须为 approved）
- 项目上下文

**动作**:
1. 读取 plan.md，解析 frontmatter 和各章节
2. 提取模块列表（从 § 2.3 模块说明表）
3. 提取架构依赖关系
4. 提取技术选型信息
5. 验证 plan.md 状态为 approved

**输出**: 解析结果（内存中）

---

### 阶段 2: DECOMPOSE（分解任务）

**目标**: 将模块分解为任务，支持递归子模块规划

**输入**:
- PARSE 阶段的解析结果
- 子计划（如果有）

**动作**:
1. 遍历每个模块
2. **执行完整性检测**（5 维度）
3. 根据检测结果决定动作：
   - COMPLETE → 生成任务
   - TRIGGER_SUB_PLAN → 触发子模块 workflow-plan
   - REQUEST_USER_INPUT → 询问用户补充信息
4. 合并子计划到主计划
5. 为每个模块生成任务
6. 设置优先级（P0/P1/P2/P3）
7. 标记 [T] TDD 任务、[P] 并行任务、[R] 需审查任务

**输出**: `.workflow/{feature}/task/tasks.md`（草稿）

> **模板**: 使用 [assets/tasks-template.md](assets/tasks-template.md)

#### 完整性检测（5 维度）

| 维度 | 检测项 | 阈值 | 失败动作 |
|------|--------|------|----------|
| 职责清晰度 | 描述长度 | 20-200 字 | REQUEST_USER_INPUT |
| 接口定义 | 输入输出 | 必须有 | REQUEST_USER_INPUT |
| 技术选型 | 具体方案 | 必须有 | REQUEST_USER_INPUT |
| 粒度 | 任务估时 | ≤ 8 小时 | TRIGGER_SUB_PLAN |
| 子模块详情 | 复合模块细节 | 必须有 | TRIGGER_SUB_PLAN |

> **详细说明**: 参见 [references/completeness-check.md](references/completeness-check.md)

#### 子模块规划触发

当完整性检测结果为 `TRIGGER_SUB_PLAN` 时：

1. 检查递归深度（最大 3 层）
2. 通过 AskUserQuestion 确认是否触发
3. 调用 workflow-plan 生成子模块计划
4. 子计划存储到 `plan/sub-plans/{module-id}/plan.md`
5. 合并子计划到主计划
6. 重新检测子模块

> **子计划模板**: 使用 [workflow-plan/assets/sub-plan-template.md](../workflow-plan/assets/sub-plan-template.md) 生成子模块计划
>
> **合并策略**: 参见 [references/merge-strategy.md](references/merge-strategy.md)

---

### 阶段 3: ANALYZE（依赖分析）

**目标**: 分析任务依赖，生成 DAG，检测粒度

**输入**:
- `.workflow/{feature}/task/tasks.md`（草稿）

**动作**:
1. 分析任务间依赖关系
2. 构建有向无环图（DAG）
3. 检测循环依赖
4. 计算关键路径
5. 检测任务粒度（30min-8h）
6. 标记并行任务组

**输出**:
- 更新 tasks.md 的依赖关系图
- 关键路径分析
- 粒度警告列表

---

### 阶段 4: REVIEW（独立审查）

**目标**: 使用独立 Agent 审查任务分解质量

**输入**:
- `.workflow/{feature}/task/tasks.md`
- 依赖分析结果

**审查维度**:
1. **任务完整性** - 是否覆盖 plan.md 所有模块
2. **粒度合理性** - 任务粒度是否在 30min-8h 范围
3. **依赖正确性** - 依赖关系是否正确、无循环

> **完整清单**: 参见 [references/review-checklist.md](references/review-checklist.md)

**判定规则**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 三维度均合格 | 进入 REFINE |
| **NEEDS_IMPROVEMENT** | 部分问题 | 回退到 DECOMPOSE（最多 3 轮）|
| **REJECTED** | 严重问题 | 停止流程，提示用户 |

**输出**: `.workflow/{feature}/task/reviews/round-{N}/review-response.md`

---

### 阶段 5: REFINE（优化任务）

**目标**: 根据审查反馈优化任务列表

**输入**:
- `.workflow/{feature}/task/tasks.md`
- 审查反馈

**动作**:
1. 应用审查反馈修改
2. 调整任务结构
3. 更新依赖关系
4. 更新任务标记

**输出**: `.workflow/{feature}/task/tasks.md`（优化后）

---

### 阶段 6: VALIDATE（用户确认）

**目标**: 最终验证，获取用户批准

**输入**:
- `.workflow/{feature}/task/tasks.md`（优化后）
- 审查报告

**动作**:
1. 展示完整任务列表和依赖图
2. 汇总所有警告（粒度、依赖等）
3. 通过 AskUserQuestion 请求用户批准
4. 更新 tasks.md frontmatter 状态为 "approved"
5. 更新 `.state.yaml`

**输出**: `.workflow/{feature}/task/tasks.md`（已批准）

---

## 命令

```bash
# 完整流程
/workflow-task {feature}

# 单阶段执行
/workflow-task parse {feature}
/workflow-task decompose {feature}
/workflow-task analyze {feature}
/workflow-task review {feature}
/workflow-task refine {feature}
/workflow-task validate {feature}

# 选项
/workflow-task --resume {feature}      # 断点恢复
/workflow-task --validate {feature}    # 仅验证格式
/workflow-task --force {feature}       # 跳过审查
/workflow-task --no-recurse {feature}  # 禁用递归
```

---

## 输出结构

```
.workflow/{feature}/
├── plan/
│   ├── plan.md                    # 主计划
│   └── sub-plans/                 # 子模块计划（递归生成）
│       └── {module-id}/
│           ├── plan.md
│           └── .state.yaml
├── task/
│   ├── tasks.md                   # 最终任务列表
│   ├── reviews/
│   │   └── round-{N}/
│   │       └── review-response.md
│   └── .state.yaml                # 状态跟踪
```

---

## 配置

```yaml
# 递归配置
recursion:
  max_depth: 3                    # 最大递归深度
  auto_trigger: true              # 自动触发子模块规划
  user_confirm: true              # 触发前需要用户确认

# 完整性检测
completeness_check:
  min_responsibility_length: 20   # 职责描述最小字数
  max_responsibility_length: 200  # 职责描述最大字数
  require_interface: true         # 必须有接口定义
  require_tech_choice: true       # 必须有技术选型
  max_task_hours: 8              # 单任务最大小时数

# 粒度检测
granularity:
  min_minutes: 30                 # 最小粒度（分钟）
  max_hours: 8                    # 最大粒度（小时）
  warn_only: true                 # 仅警告不阻塞

# 循环控制
loop_control:
  max_review_rounds: 3            # 最大审查轮次
  early_exit_confidence: 0.9      # 早期退出置信度
```

---

## 状态管理

**.state.yaml 格式**:

```yaml
feature: {feature-id}
version: 2.1.0
phase: parse | decompose | analyze | review | refine | validate
status: in_progress | completed | failed

# 递归状态追踪
recursion:
  current_depth: 1
  max_depth: 3
  sub_plans:
    - module_id: "auth"
      depth: 1
      status: completed
      plan_path: "../plan/sub-plans/auth/plan.md"

# 模块完整性状态
module_status:
  auth:
    completeness: 0.6
    missing: ["SUBMODULES_NOT_DETAILED"]
    action: "TRIGGER_SUB_PLAN"
    refined: true

# 已完成阶段
completed_phases:
  parse:
    completed_at: "2026-01-15T09:00:00Z"
    output: "parse-result"

# 审查历史
reviews:
  current_round: 1
  max_rounds: 3
  history:
    - round: 1
      verdict: PASS
      confidence: 0.95
```

---

## 任务标记说明

| 标记 | 含义 | 使用场景 |
|------|------|----------|
| `[T]` | 测试先行（TDD） | 核心业务逻辑任务 |
| `[P]` | 可并行 | 无依赖或依赖相同的任务 |
| `[R]` | 需审查 | 关键任务完成后需人工审查 |

**优先级分配规则**:

| 优先级 | 条件 | 说明 |
|--------|------|------|
| P0 | 关键路径上的阻塞任务 | 阻塞其他多个任务 |
| P1 | 核心业务逻辑任务 | 实现主要功能 |
| P2 | 辅助功能任务 | 非核心但必需 |
| P3 | 优化和文档任务 | 可延后执行 |

---

## 回退规则

### REVIEW 不通过时的回退路径

```
NEEDS_IMPROVEMENT (轮次 < 3) → DECOMPOSE → ANALYZE → REVIEW
NEEDS_IMPROVEMENT (轮次 = 3) → 停止，提示用户
REJECTED → 停止流程
```

---

## 集成

**输入**: `/workflow-plan` 生成的 `plan.md`（已批准）
**输出**: 供 `/workflow-implement` 使用的 `tasks.md`（已批准）

---

## 资源

| 资源 | 路径 | 何时使用 |
|------|------|----------|
| 任务模板 | [assets/tasks-template.md](assets/tasks-template.md) | DECOMPOSE 阶段生成 tasks.md 时 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 需要了解阶段子任务详情时 |
| 完整性检测 | [references/completeness-check.md](references/completeness-check.md) | DECOMPOSE 阶段检测模块完整性时 |
| 合并策略 | [references/merge-strategy.md](references/merge-strategy.md) | 合并子计划时 |
| 审查清单 | [references/review-checklist.md](references/review-checklist.md) | REVIEW 阶段执行审查时 |
| 子计划模板 | [workflow-plan/assets/sub-plan-template.md](../workflow-plan/assets/sub-plan-template.md) | 触发子模块 workflow-plan 时生成子计划 |
