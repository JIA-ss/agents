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
Delivery            └── 回到 Phase 3
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

| 配置项 | 默认值 |
|--------|--------|
| max_rounds | 3 |
| consecutive_reject_limit | 2 |

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
