---
name: workflow-implement
description: 按任务列表执行代码实现。读取 tasks.md，按拓扑顺序执行任务，支持 TDD 模式、并行执行和原子提交。内置质量检查和断点恢复。当用户想要"执行任务"、"开始实现"、"写代码"时使用。也响应 "workflow implement"、"工作流实现"。
---

# Workflow Implement 指南

## 概述

按照任务列表（tasks.md）逐个执行实现任务，通过 6 阶段流程确保代码质量。

**核心价值**：将任务计划转化为实际代码，通过 TDD 驱动、内置审查和原子提交确保质量可控。

---

## 工作流程（6 阶段）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         WORKFLOW-IMPLEMENT                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                           │
│  │   LOAD   │───►│   PLAN   │───►│ EXECUTE  │                           │
│  │ 加载任务 │    │ 执行计划 │    │ 任务执行 │                           │
│  └──────────┘    └──────────┘    └────┬─────┘                           │
│                                       │                                  │
│                                       ▼                                  │
│                                 ┌──────────┐                            │
│                                 │  REVIEW  │                            │
│                                 │ 质量检查 │                            │
│                                 └────┬─────┘                            │
│                                      │                                   │
│                        ┌─────────────┼─────────────┐                    │
│                        ▼             ▼             ▼                    │
│                    [PASS]      [NEEDS_FIX]    [REJECTED]                │
│                        │             │             │                    │
│                        │        回退 EXECUTE      停止                  │
│                        │        (最多3轮)                               │
│                        ▼                                                │
│                  ┌──────────┐    ┌──────────┐                           │
│                  │  COMMIT  │───►│  REPORT  │                           │
│                  │ 原子提交 │    │ 生成报告 │                           │
│                  └──────────┘    └──────────┘                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 阶段详细说明

> **详细参考**: [references/phase-details.md](references/phase-details.md) 包含各阶段的完整子任务、代码示例和判定规则。

### 阶段 1: LOAD（加载任务）

**目标**: 解析 tasks.md，构建任务依赖图

**输入**:
- `.workflow/{feature}/task/tasks.md`（状态必须为 approved）

**动作**:
1. 验证 tasks.md 存在且状态为 approved
2. 解析 frontmatter 获取元信息
3. 解析任务列表，提取:
   - 任务 ID、标题、描述
   - 优先级 (P0/P1/P2/P3)
   - 标记 ([T], [P], [R])
   - 依赖关系
4. 构建 DAG（有向无环图）
5. 验证 DAG 无循环依赖

**输出**: 任务 DAG + 初始 .state.yaml

> **模板**: 初始化状态时使用 [assets/state-template.yaml](assets/state-template.yaml)

**错误处理**:
| 错误 | 处理 |
|------|------|
| tasks.md 不存在 | 中止，提示路径 |
| 状态非 approved | 中止，提示状态 |
| 循环依赖 | 中止，显示循环 |

---

### 阶段 2: PLAN（执行计划）

**目标**: 基于 DAG 生成执行计划

**输入**: 任务 DAG

**动作**:
1. 拓扑排序确定执行顺序
2. 识别并行批次:
   - 同批次任务无依赖关系
   - 优先关键路径任务
3. 计算关键路径
4. 生成执行计划

**输出**:
- 批次划分 (batches[])
- 关键路径标记
- 预估执行顺序

**并行批次划分**:
```
批次 1: [无依赖的任务]
批次 2: [仅依赖批次1的任务]
批次 N: [仅依赖批次1..N-1的任务]
```

---

### 阶段 3: EXECUTE（任务执行）

**目标**: 按计划执行任务

**输入**: 执行计划 + 当前批次

#### 3.1 顺序执行流程

```
for batch in batches:
    for task in batch:
        execute_task(task)
        update_state(task, "completed")
```

#### 3.2 并行执行流程 ([P] 标记)

```
for batch in batches:
    parallel_tasks = [t for t in batch if t.has_parallel_flag]
    sequential_tasks = [t for t in batch if not t.has_parallel_flag]

    # 并行任务使用 Task 工具同时执行
    launch_parallel(parallel_tasks, max_concurrent=5)

    # 顺序任务依次执行
    for task in sequential_tasks:
        execute_task(task)
```

#### 3.3 TDD 执行流程 ([T] 标记)

对于 [T] 标记的任务，执行 TDD 五步循环：

1. **编写测试**: 先编写单元测试
2. **验证红灯**: 确认测试失败
3. **编写实现**: 编写实现代码
4. **验证绿灯**: 确认测试通过
5. **重构**: 可选的代码重构

```python
def execute_tdd_task(task):
    write_test(task)
    if run_tests().passed:
        raise Error("测试应该失败")
    implement(task)
    if not run_tests().passed:
        return FAILED
    return COMPLETED
```

#### 3.4 失败处理策略

| 任务优先级 | 失败处理 |
|------------|----------|
| P0 (关键路径) | 立即中止整个流程 |
| P1 (核心逻辑) | 立即中止整个流程 |
| P2 (辅助功能) | 跳过，继续执行 |
| P3 (优化文档) | 跳过，继续执行 |

#### 3.5 重试策略

| 错误类型 | 重试策略 |
|----------|----------|
| 网络超时 | 重试 3 次，指数退避 |
| 资源锁定 | 等待 + 重试 3 次 |
| 服务不可用 | 重试 3 次，指数退避 |

**输出**: 任务执行结果 + 执行日志 + 更新的 .state.yaml

---

### 阶段 4: REVIEW（质量检查）

**目标**: 执行内置质量检查

**输入**: 执行结果 + 变更文件列表

**检查项**:

| 检查项 | 阈值 | 权重 |
|--------|------|------|
| 测试通过率 | 100% | 必须 |
| Lint 错误 | 0 | 必须 |
| 任务完成率 | 按优先级 | 加权 |

**判定逻辑**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 所有检查通过 | 进入 COMMIT |
| **NEEDS_FIX** | 部分检查不通过 | 回退到 EXECUTE（最多 3 轮）|
| **REJECTED** | 关键任务失败 或 超过 3 轮 | 中止流程，人工介入 |

**输出**: 审查报告 + 判定结果

---

### 阶段 5: COMMIT（原子提交）

**目标**: 为每个完成的任务创建 git commit

**输入**: 已完成任务列表 + 变更文件映射

**动作**:
1. 检测每个任务关联的文件变更
2. 执行 `git add` 添加相关文件
3. 生成 commit message
4. 执行 `git commit`
5. 记录 commit SHA

**Commit Message 格式**:
```
task({task-id}): {task-title}

- {变更描述}
- 关联需求: {相关 US}
```

**错误处理**:
| 错误 | 处理 |
|------|------|
| git 不可用 | 记录警告，继续流程 |
| commit 失败 | 记录错误，继续流程 |
| 无文件变更 | 跳过 commit |

**输出**: commits/commit-log.md + 更新的 .state.yaml

> **模板**: 使用 [assets/commit-template.md](assets/commit-template.md)

---

### 阶段 6: REPORT（生成报告）

**目标**: 生成执行摘要报告

**输入**: 执行状态 + 审查结果 + 提交记录

**报告内容**:
- 执行摘要（总数、完成、跳过、失败）
- 任务详情表
- 审查结果
- 后续步骤建议

**输出**: implement-report.md + 最终 .state.yaml

---

## 命令

```bash
# 完整流程
/workflow-implement {feature}

# 单阶段执行
/workflow-implement load {feature}
/workflow-implement execute {feature}
/workflow-implement review {feature}

# 选项
/workflow-implement --resume {feature}       # 断点恢复
/workflow-implement --task={id} {feature}    # 执行单个任务
/workflow-implement --retry {feature}        # 重试失败任务
/workflow-implement --parallel=3 {feature}   # 限制并行数
/workflow-implement --skip-review {feature}  # 跳过内置审查
```

---

## 输出结构

```
.workflow/{feature}/implement/
├── .state.yaml           # 执行状态
├── logs/                  # 执行日志
│   ├── batch-1.log
│   ├── batch-2.log
│   └── ...
├── commits/
│   └── commit-log.md     # 提交记录
├── reviews/
│   ├── round-1/
│   │   └── review.md
│   └── ...
└── implement-report.md   # 最终报告
```

---

## 配置

```yaml
config:
  # 执行模式
  mode: sequential  # sequential | parallel

  # 并行设置
  parallel:
    max_concurrent: 5
    prefer_critical_path: true

  # TDD 设置
  tdd:
    enabled: true
    require_red_phase: true

  # 提交设置
  commit:
    enabled: true
    granularity: per_task  # per_task | per_batch
    message_format: "task({id}): {title}"

  # 审查设置
  review:
    max_rounds: 3
    test_threshold: 100
    lint_errors_threshold: 0

  # 失败策略
  failure:
    p0_p1: abort
    p2_p3: skip
    retry:
      max_attempts: 3
      backoff: exponential
```

---

## 状态管理

**.state.yaml 格式**:

```yaml
feature: {feature-id}
version: 1.0.0
phase: execute  # load/plan/execute/review/commit/report
status: in_progress  # pending/in_progress/completed/failed

phases:
  load:
    status: completed
    completed_at: "2026-01-16T10:00:00Z"
  execute:
    status: in_progress
    current_batch: 2
    total_batches: 4
  review:
    status: pending
    rounds: 0
    max_rounds: 3

tasks:
  T1.1:
    status: completed
    completed_at: "2026-01-16T10:02:00Z"
    commit_sha: "abc123"
  T2.1:
    status: in_progress
    started_at: "2026-01-16T10:03:00Z"

reviews:
  - round: 1
    verdict: NEEDS_FIX
    issues: ["T2.1 测试失败"]
```

> **模板**: 使用 [assets/state-template.yaml](assets/state-template.yaml)

### 断点恢复

使用 `--resume` 选项时：

1. 读取 .state.yaml
2. 跳过已完成任务
3. 重试失败任务（最多 3 次）
4. 从当前阶段继续

---

## 回退规则

### REVIEW 不通过时的回退

```
NEEDS_FIX (轮次 < 3) → EXECUTE → REVIEW
NEEDS_FIX (轮次 = 3) → 停止，提示用户
REJECTED → 停止流程
```

### 任务失败时的处理

| 任务优先级 | 依赖任务 | 处理 |
|------------|----------|------|
| P0/P1 | - | 中止整个流程 |
| P2/P3 | 有依赖 | 跳过本任务，依赖任务也跳过 |
| P2/P3 | 无依赖 | 仅跳过本任务 |

---

## 任务标记说明

| 标记 | 含义 | 执行策略 |
|------|------|----------|
| `[T]` | 测试先行（TDD） | 先写测试用例，再实现功能 |
| `[P]` | 可并行 | 可与同组 [P] 任务并行执行 |
| `[R]` | 需审查 | 完成后需要人工代码审查 |

---

## 任务状态

| 状态 | 标记 | 说明 |
|------|------|------|
| 待执行 | `[ ]` | 任务尚未开始 |
| 进行中 | `[~]` | 任务正在执行 |
| 已完成 | `[x]` | 任务成功完成 |
| 失败 | `[!]` | 任务执行失败 |
| 跳过 | `[-]` | 任务被跳过 |

---

## 优先级说明

| 优先级 | 含义 | 失败处理 |
|--------|------|----------|
| P0 | 关键路径阻塞任务 | 立即中止 |
| P1 | 核心业务逻辑 | 立即中止 |
| P2 | 辅助功能 | 跳过继续 |
| P3 | 优化和文档 | 跳过继续 |

---

## 集成

**输入**: `/workflow-task` 生成的 `tasks.md`（已批准）
**输出**: 代码变更 + 执行报告，供 `/workflow-review` 使用

---

## 资源

| 资源 | 路径 | 何时使用 |
|------|------|----------|
| 状态模板 | [assets/state-template.yaml](assets/state-template.yaml) | LOAD 阶段初始化状态时 |
| 提交模板 | [assets/commit-template.md](assets/commit-template.md) | COMMIT 阶段记录提交时 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 需要了解阶段子任务详情时 |

---

*Generated by skill-generator | 2026-01-16*
