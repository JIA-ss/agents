---
name: self-review
description: Execute tasks with independent AI review cycles using Codex, self-correction, and iterative improvement until quality criteria are met. Use when needing self-supervised execution, automated QA loops, iterative code review, or quality assurance workflows. Also responds to "自我监督", "迭代审查", "自我修正", "质量循环", "自动改进", "独立审查".
---

# Self-Review Skill Guide

## Overview

自我监督执行框架，通过独立 Reviewer（Codex）对执行结果进行严格审查，形成"执行→审查→改进"的闭环，直到任务通过评估才交付。

**核心价值**：独立审查 + 信息隔离 + 过程可追溯 + 迭代改进 + 质量保证

## Non-goals

以下场景不适用本 skill：
- 简单的一次性代码审查（无迭代）
- 手动 review 请求
- 不需要独立验证的任务

---

## Task Directory Structure

```
.tasks/self-review/{task-name}/
├── 00-task-spec.md                    # 任务规范
├── evidence/
│   ├── execution-manifest.json        # 执行清单
│   ├── test-results.txt               # 测试输出
│   ├── lint-results.txt               # Lint 输出
│   └── requirement-mapping.md         # 需求映射
├── reviews/round-{N}/
│   ├── review-prompt.md
│   ├── review-response.md
│   └── review-analysis.md
├── improvements/
│   └── round-{N}-changes.md
└── final-report.md
```

---

## Workflow (6 Phases)

```
Phase 1: Task Confirmation
    └── 输出: 00-task-spec.md
            ▼
Phase 2: Task Execution
    ├── 执行代码修改
    ├── 运行: ./scripts/generate-evidence.sh {task-name} "{test-cmd}" "{lint-cmd}"
    └── 输出: evidence/*
            ▼
Phase 3: Independent Review (Codex)
    └── 输出: reviews/round-{N}/review-response.md
            ▼
Phase 4: Review Analysis
    ├── 分类问题 (BLOCKER/CRITICAL/MAJOR/MINOR)
    └── 判断: PASS / NEEDS_IMPROVEMENT / REJECTED
            ▼
    ┌───────┴───────┐
    ▼               ▼
  PASS          NEEDS_IMPROVEMENT
    │               │
    ▼               ▼
Phase 6:        Phase 5: Improvement
Delivery            └── 回到 Phase 2
    │
    ├── 运行: ./scripts/validate.sh {task-name}
    └── 输出: final-report.md
```

### Phase 详细说明

#### Phase 2: Task Execution

执行任务后，使用脚本生成证据包：

```bash
# 生成证据包（测试结果、lint 结果、需求映射）
./scripts/generate-evidence.sh {task-name} "{test-command}" "{lint-command}"

# 示例
./scripts/generate-evidence.sh fix-auth-bug-20260103 "npm test" "npm run lint"
./scripts/generate-evidence.sh refactor-api "pytest" "ruff check ."
```

#### Phase 6: Delivery

交付前验证任务目录完整性：

```bash
# 标准验证
./scripts/validate.sh {task-name}

# 严格模式（验证所有审查轮次）
./scripts/validate.sh {task-name} --strict
```

---

## Severity Levels

| 级别 | 定义 | 处理 |
|------|------|------|
| **BLOCKER** | 阻止合并（安全漏洞、测试失败） | 必须修复 |
| **CRITICAL** | 影响核心功能 | >2个则 REJECTED |
| **MAJOR** | 影响可维护性 | >5个则 NEEDS_IMPROVEMENT |
| **MINOR** | 可选优化 | 不影响判定 |

---

## Verdict Rules

```yaml
PASS:
  - blocker_count == 0
  - critical_count == 0
  - major_count <= 5

NEEDS_IMPROVEMENT:
  - blocker_count == 0
  - critical_count IN [1, 2] OR major_count > 5

REJECTED:
  - blocker_count > 0 OR critical_count > 2
  - OR tests_passed == false
  - OR git_is_dirty == true
```

---

## Loop Control

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| max_rounds | 3 | 最大审查轮次 |
| consecutive_reject_limit | 2 | 连续 REJECTED 次数限制 |
| early_exit_confidence | 0.9 | 早期退出置信度阈值 |

### Early Exit Mechanism

当满足以下条件时，可提前退出审查循环：

```yaml
early_exit_conditions:
  - reviewer_confidence >= 0.9
  - blocker_count == 0
  - critical_count == 0
  - major_count <= 2
```

**触发逻辑**：
1. Reviewer 在 response 中提供置信度评分 (0.0-1.0)
2. 若 `confidence >= early_exit_confidence` 且无严重问题，跳过后续审查
3. 节省 API 调用成本和时间

---

## Cost Control

API 调用成本监控与预算控制。

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| cost_budget_usd | 10.0 | 单任务成本预算 (USD) |
| cost_per_round_limit | 3.0 | 单轮成本上限 (USD) |
| cost_alert_threshold | 0.8 | 预算消耗告警阈值 (80%) |

### Cost Tracking

在 `execution-manifest.json` 中记录成本：

```json
{
  "cost_tracking": {
    "rounds": [
      {"round": 1, "tokens_in": 5000, "tokens_out": 2000, "cost_usd": 0.15},
      {"round": 2, "tokens_in": 4000, "tokens_out": 1500, "cost_usd": 0.12}
    ],
    "total_cost_usd": 0.27,
    "budget_remaining_usd": 9.73
  }
}
```

### Budget Enforcement

```
if accumulated_cost > cost_budget_usd * cost_alert_threshold:
    log_warning("Cost budget 80% consumed")

if accumulated_cost >= cost_budget_usd:
    pause_and_request_user_decision()
```

---

## Execution Commands

```bash
# 启动自我监督任务
/self-review 执行并审查: {任务描述}

# 继续上次未完成的任务
/self-review --resume {task-name}

# 手动触发 Review
/self-review --review-only

# 查看任务历史
/self-review --list
```

---

## Best Practices

1. **任务命名**：使用有意义的 task-name，如 `fix-login-bug-20260103`
2. **原子任务**：将大任务拆分为可独立审查的小任务
3. **证据完整**：确保 evidence/ 目录包含所有必需文件
4. **及时归档**：完成后归档或提交任务目录

---

## Additional Resources

详细文档请参考以下文件：

| 文档 | 路径 | 内容 |
|------|------|------|
| 文件模板 | [templates/](templates/) | task-spec, review-prompt, final-report 等模板 |
| 证据规范 | [references/evidence-spec.md](references/evidence-spec.md) | Reviewer/Executor 证据分类 |
| Codex 集成 | [references/codex-integration.md](references/codex-integration.md) | Codex 调用方式 |
| 验证脚本 | [scripts/validate.sh](scripts/validate.sh) | 任务目录验证 |
| 生成脚本 | [scripts/generate-evidence.sh](scripts/generate-evidence.sh) | 证据包生成 |
