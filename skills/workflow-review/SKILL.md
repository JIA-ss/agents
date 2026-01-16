---
name: workflow-review
description: 独立审查代码实现质量。通过 6 阶段流程（COLLECT→ANALYZE→REVIEW→VERDICT→IMPROVE→REPORT）对 workflow-implement 输出进行全面审查，支持五维度检查和迭代改进。当用户想要"审查代码"、"质量检查"、"代码评审"时使用。也响应 "workflow review"、"工作流审查"。
---

# Workflow Review 指南

## 概述

使用独立 Agent 对代码实现进行全面审查，形成 implement → review → implement 的完整闭环。

**核心价值**：五维度审查 + 独立审查 + 信息隔离 + 迭代改进 + 完整闭环

---

## 工作流程（6 阶段）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW-REVIEW                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                           │
│  │ COLLECT  │───►│ ANALYZE  │───►│  REVIEW  │                           │
│  │ 收集证据 │    │ 多维分析 │    │ 独立审查 │                           │
│  └──────────┘    └──────────┘    └────┬─────┘                           │
│                                       │                                  │
│                                       ▼                                  │
│                                 ┌──────────┐                            │
│                                 │ VERDICT  │                            │
│                                 │   判定   │                            │
│                                 └────┬─────┘                            │
│                                      │                                   │
│                        ┌─────────────┼─────────────┐                    │
│                        ▼             ▼             ▼                    │
│                    [PASS]      [NEEDS_FIX]    [REJECTED]                │
│                        │             │             │                    │
│                        │      ┌──────▼──────┐     停止                  │
│                        │      │   IMPROVE   │                           │
│                        │      │ 触发修复    │                           │
│                        │      └──────┬──────┘                           │
│                        │             │                                   │
│                        │      ┌──────▼──────┐                           │
│                        │      │ workflow-   │                           │
│                        │      │ implement   │                           │
│                        │      └──────┬──────┘                           │
│                        │             │                                   │
│                        │             ▼                                   │
│                        │      重新触发 COLLECT                          │
│                        │      (最多 3 轮)                                │
│                        ▼                                                │
│                  ┌──────────┐                                           │
│                  │  REPORT  │                                           │
│                  │ 生成报告 │                                           │
│                  └──────────┘                                           │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 阶段详细说明

> **详细参考**: [references/phase-details.md](references/phase-details.md) 包含各阶段的完整子任务、代码示例和错误处理。

### 阶段 1: COLLECT（收集证据）

**目标**: 收集审查所需的所有证据

**输入**:
- `.workflow/{feature}/implement/` 目录
- 项目代码

**动作**:
1. 读取 implement 执行日志和报告
2. 运行项目测试，收集结果
3. 运行 lint 检查，收集结果
4. 生成代码变更 diff
5. 收集覆盖率报告（如有）

**输出**: `evidence/` 目录

> **模板**: 初始化状态时使用 [assets/state-template.yaml](assets/state-template.yaml)

**错误处理**:
| 错误 | 处理 |
|------|------|
| implement 目录不存在 | 中止，提示先执行 workflow-implement |
| 测试命令不存在 | 跳过测试收集，记录警告 |
| lint 工具不存在 | 跳过 lint 收集，记录警告 |

---

### 阶段 2: ANALYZE（多维分析）

**目标**: 从五个维度分析代码质量

**输入**:
- `evidence/` 目录
- `spec.md`（规范合规检查）

**五维度检查**:

| 维度 | 检查项 | 阈值 |
|------|--------|------|
| **代码质量** | 代码规范、异味、复杂度 | 圈复杂度 ≤15，无 CRITICAL |
| **测试覆盖** | 通过率、覆盖率 | 100% 通过，≥80% 覆盖 |
| **规范合规** | 符合 spec.md 验收标准 | 100% 验收标准满足 |
| **安全检查** | 硬编码密钥、SQL注入、XSS | 无 BLOCKER |
| **性能检查** | O(n²) 循环、资源泄露 | 无 MAJOR 性能问题 |

**输出**: `analysis/dimension-report.md`

> **检查清单**: 参见 [references/review-checklist.md](references/review-checklist.md)

---

### 阶段 3: REVIEW（独立审查）

**目标**: 使用独立 Agent 进行审查，确保信息隔离

**输入**:
- `evidence/` 目录
- `analysis/dimension-report.md`

**动作**:
1. 构建证据包（只包含审查所需信息）
2. 使用 Task 工具启动独立审查 Agent
3. 收集审查结果

**信息隔离边界**:

| 传递 | 不传递 |
|------|--------|
| 测试结果、Lint 结果 | 实现过程思考记录 |
| 覆盖率报告、代码变更 | 调试信息和日志 |
| 规范文档、任务列表 | 历史对话上下文 |

**输出**: `reviews/round-{N}/review-response.md`

---

### 阶段 4: VERDICT（判定）

**目标**: 根据审查结果给出判定

**输入**:
- `reviews/round-{N}/review-response.md`
- 问题分类统计

**严重程度定义**:

| 级别 | 定义 | 示例 |
|------|------|------|
| **BLOCKER** | 阻止合并 | 安全漏洞、测试失败 |
| **CRITICAL** | 影响核心功能 | 逻辑错误、数据丢失 |
| **MAJOR** | 影响可维护性 | 代码异味、复杂度高 |
| **MINOR** | 可选优化 | 命名、注释 |

**判定规则**:

```yaml
PASS:
  - blocker_count == 0
  - critical_count == 0
  - major_count <= 5
  - tests_passed == true

NEEDS_FIX:
  - blocker_count == 0
  - (critical_count IN [1, 2] OR major_count > 5)
  - round < max_rounds

REJECTED:
  - blocker_count > 0
  - OR critical_count > 2
  - OR tests_passed == false
  - OR round >= max_rounds
```

**输出**: 判定结果 + 问题列表

---

### 阶段 5: IMPROVE（触发修复）

**目标**: 回退到 workflow-implement 重新执行失败任务

**触发条件**: VERDICT 判定为 NEEDS_FIX 且轮次 < 3

**动作**:
1. 识别需要修复的任务
2. 分析问题根因
3. 生成修复指令
4. 调用 workflow-implement 重新执行
5. workflow-implement 完成后自动触发 workflow-review

**闭环流程**:
```
workflow-implement → workflow-review → NEEDS_FIX
                                          │
                                          ▼
                              workflow-implement (重新执行)
                                          │
                                          ▼
                              workflow-review (重新审查)
```

**输出**: `improvements/round-{N}/fix-log.md`

---

### 阶段 6: REPORT（生成报告）

**目标**: 生成最终审查报告

**触发条件**: VERDICT 判定为 PASS

**动作**:
1. 汇总所有轮次审查历史
2. 统计问题和修复记录
3. 生成最终状态摘要
4. 输出建议

**输出**: `final-report.md`

> **模板**: 使用 [assets/report-template.md](assets/report-template.md)

---

## 命令

```bash
# 完整流程
/workflow-review {feature}

# 单阶段执行
/workflow-review collect {feature}
/workflow-review analyze {feature}
/workflow-review review {feature}
/workflow-review verdict {feature}
/workflow-review improve {feature}
/workflow-review report {feature}

# 选项
/workflow-review --resume {feature}       # 断点恢复
/workflow-review --check-only {feature}   # 仅审查不改进
/workflow-review --max-rounds=N {feature} # 设置最大轮次
```

---

## 输出结构

```
.workflow/{feature}/review/
├── .state.yaml              # 执行状态
├── evidence/                # 证据目录
│   ├── test-results.txt
│   ├── lint-results.txt
│   ├── coverage-report.txt
│   ├── changes.diff
│   └── implement-log.md
├── analysis/                # 分析结果
│   └── dimension-report.md
├── reviews/                 # 审查记录
│   └── round-{N}/
│       ├── review-prompt.md
│       └── review-response.md
├── improvements/            # 改进记录
│   └── round-{N}/
│       └── fix-log.md
└── final-report.md          # 最终报告
```

---

## 配置

```yaml
config:
  # 审查设置
  review:
    max_rounds: 3                    # 最大审查轮次
    consecutive_reject_limit: 2      # 连续 REJECTED 限制
    early_exit_confidence: 0.9       # 早期退出置信度

  # 维度阈值
  thresholds:
    code_quality:
      max_cyclomatic_complexity: 15
      max_function_length: 100
    test_coverage:
      min_coverage_percent: 80
      require_all_pass: true
    security:
      check_hardcoded_secrets: true
      check_sql_injection: true
      check_xss: true
    performance:
      max_loop_complexity: "O(n)"
      check_resource_leaks: true

  # IMPROVE 设置
  improve:
    auto_trigger_implement: true     # 自动触发 workflow-implement
    retry_failed_tasks_only: true    # 仅重试失败任务
```

---

## 状态管理

**.state.yaml 格式**:

```yaml
feature: {feature-id}
version: 1.0.0
phase: collect | analyze | review | verdict | improve | report
status: pending | in_progress | completed | failed

phases:
  collect:
    status: completed
    completed_at: "2026-01-16T10:00:00Z"
  analyze:
    status: in_progress
  # ...

reviews:
  - round: 1
    verdict: NEEDS_FIX
    issues_count: {blocker: 0, critical: 1, major: 3, minor: 2}
```

> **模板**: 使用 [assets/state-template.yaml](assets/state-template.yaml)

### 断点恢复

使用 `--resume` 选项时：
1. 读取 .state.yaml
2. 跳过已完成阶段
3. 从当前阶段继续

---

## 回退规则

```
NEEDS_FIX (轮次 < 3) → IMPROVE → workflow-implement → workflow-review (COLLECT)
NEEDS_FIX (轮次 = 3) → 停止，提示用户介入
REJECTED → 停止流程，输出问题报告
```

---

## 集成

**输入**: `/workflow-implement` 生成的代码变更和执行报告
**输出**: 审查报告，或触发 `/workflow-implement` 重新执行

**完整闭环**:
```
workflow-specify → workflow-plan → workflow-task → workflow-implement → workflow-review
                                                          ↑                    │
                                                          └────── NEEDS_FIX ───┘
```

---

## 资源

| 资源 | 路径 | 何时使用 |
|------|------|----------|
| 状态模板 | [assets/state-template.yaml](assets/state-template.yaml) | COLLECT 阶段初始化状态时 |
| 报告模板 | [assets/report-template.md](assets/report-template.md) | REPORT 阶段生成最终报告时 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 需要了解阶段子任务详情时 |
| 审查清单 | [references/review-checklist.md](references/review-checklist.md) | ANALYZE 和 REVIEW 阶段执行审查时 |

---

*Generated by skill-generator | 2026-01-16*
