---
name: self-review
description: Use when the user asks for "self-supervised execution", "iterative review", "auto-improve", "review loop", "quality assurance loop", mentions "self-correction", "independent review", or needs AI to execute tasks with self-review and improvement cycles. Also responds to "自我监督", "迭代审查", "自我修正", "质量循环", "自动改进".
---

# Self-Review Skill Guide

## Overview

自我监督自我修改的执行框架，通过独立Reviewer（Codex）对执行结果进行严格审查，形成"执行→审查→改进"的闭环，直到任务通过评估才交付。

**核心价值**：独立审查 + 信息隔离 + 过程可追溯 + 迭代改进 + 质量保证

---

## Task Directory Structure

所有过程文件存储在 `.tasks/self-review/{task-name}/` 目录下，确保完整可追溯。

```
.tasks/self-review/{task-name}/
├── 00-task-spec.md                    # Phase 1: 任务规范文档
│
├── evidence/                          # Executor 提供的证据（不含 git 信息）
│   ├── execution-manifest.json        # 执行清单（含 commit_hash 锚点）
│   ├── test-results.txt               # 测试执行输出
│   ├── lint-results.txt               # Lint 检查输出
│   └── requirement-mapping.md         # 需求-代码映射
│   # 注意：git-diff/git-state 由 Reviewer 自行获取，不在此目录
│
├── reviews/                           # 审查记录目录
│   ├── round-01/                      # 第一轮审查
│   │   ├── review-prompt.md           # 发送给 Reviewer（含 commit 锚点）
│   │   ├── review-response.md         # Reviewer 原始响应（含自行获取的 git 信息）
│   │   ├── review-analysis.md         # 分析结果（问题分类+判定）
│   │   └── improvement-plan.md        # 改进计划（如 NEEDS_IMPROVEMENT）
│   ├── round-02/
│   │   └── ...
│   └── round-{N}/
│       └── ...
│
├── improvements/                      # 改进记录目录
│   ├── round-01-changes.md            # 第一轮改进详情
│   ├── round-02-changes.md
│   └── ...
│
└── final-report.md                    # 最终交付报告
```

---

## Workflow (6 Phases)

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: Task Confirmation                                     │
│  ├── 解析用户提示词                                              │
│  ├── 确认任务目标和边界                                          │
│  └── 输出: .tasks/self-review/{task}/00-task-spec.md            │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 2: Task Execution                                        │
│  ├── 执行任务                                                    │
│  ├── 生成证据包                                                  │
│  └── 输出: .tasks/self-review/{task}/evidence/*                 │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 3: Independent Review (Codex)                            │
│  ├── 从 evidence/ 读取证据包                                     │
│  ├── 构建隔离式 Review Prompt，保存到 reviews/round-{N}/         │
│  ├── 调用 Codex 进行独立审查                                     │
│  └── 输出: reviews/round-{N}/review-response.md                 │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│  Phase 4: Review Analysis                                       │
│  ├── 解析 Review 报告                                            │
│  ├── 分类问题（BLOCKER/CRITICAL/MAJOR/MINOR）                    │
│  ├── 判断: PASS / NEEDS_IMPROVEMENT / REJECTED                  │
│  └── 输出: reviews/round-{N}/review-analysis.md                 │
└────────────────────────┬────────────────────────────────────────┘
                         ▼
          ┌──────────────┴──────────────┐
          ▼                             ▼
    ┌──────────┐                 ┌──────────────┐
    │   PASS   │                 │ NEEDS_IMPROVE│
    └────┬─────┘                 │ / REJECTED   │
         │                       └──────┬───────┘
         ▼                              │
┌─────────────────┐                     ▼
│  Phase 6:       │       ┌─────────────────────────────────────┐
│  Delivery       │       │  Phase 5: Improvement               │
│  生成最终报告    │       │  ├── 记录改进计划到 improvement-plan.md│
│  final-report.md│       │  ├── 执行修复                        │
└─────────────────┘       │  ├── 更新 evidence/                  │
                          │  ├── 保存变更到 improvements/         │
                          │  └── 回到 Phase 3 (N+1轮)            │
                          └─────────────────────────────────────┘
```

---

## File Templates

### 00-task-spec.md

```markdown
# Task Specification

## Task ID
{task-name}

## Created
{timestamp}

## Original Requirement
{user_original_prompt}

## Success Criteria
- [ ] {criterion_1}
- [ ] {criterion_2}
- [ ] {criterion_3}

## Scope
### In Scope
- {item_1}

### Out of Scope
- {item_1}

## Constraints
- {constraint_1}
```

### evidence/execution-manifest.json

Executor 提供的锚点文件，Reviewer 据此自行验证 Git 状态：

```json
{
  "task_id": "{task-name}",
  "timestamp": "2026-01-03T12:00:00Z",
  "commit_hash": "abc123...",
  "base_commit": "def456...",
  "commands_executed": [
    {"command": "npm test", "exit_code": 0},
    {"command": "npm run lint", "exit_code": 0}
  ],
  "tool_versions": {
    "node": "20.10.0"
  }
}
```

**注意**：不再包含 `is_dirty` 或 `git_state`，这些由 Reviewer 自行验证。

### reviews/round-{N}/review-prompt.md

```markdown
# Review Prompt - Round {N}

## Metadata
- Task: {task-name}
- Round: {N}
- Timestamp: {timestamp}
- Previous Verdict: {previous_verdict or "N/A"}

---

## Review Request

你是一个严格的独立代码审查者。请独立评估以下任务的执行结果。

**重要：你需要自行获取 Git 证据，不要依赖 Executor 提供的 diff。**

### 原始任务
{task_description}

### Executor 声明的锚点信息
- Commit Hash: {commit_hash}
- Base Commit: {base_commit}
- 执行时间: {timestamp}

### 你需要自行执行的验证步骤

1. **验证 Commit 匹配**
   ```bash
   git rev-parse HEAD
   # 必须等于上述 commit_hash，否则 REJECTED
   ```

2. **验证代码干净**
   ```bash
   git status --porcelain
   # 必须为空，否则 REJECTED
   ```

3. **获取代码变更**
   ```bash
   git diff {base_commit}..{commit_hash}
   git diff {base_commit}..{commit_hash} --stat
   ```

4. **查看相关文件**（根据 diff 结果）
   ```bash
   cat {changed_files}
   ```

### Executor 提供的执行结果

（以下是 Executor 执行测试/lint 的输出，你无法自行复现）

#### Test Results
{test_results_content}

#### Lint Results
{lint_results_content}

### 审查要求
1. **先验证后审查**：必须先完成上述验证步骤
2. **独立获取证据**：自行执行 git 命令查看代码
3. **质疑优先**：假设方案有问题，验证是否正确
4. **理论依据**：所有判断基于明确的最佳实践

### 输出格式
- VERIFICATION: {PASSED/FAILED} (commit 和 dirty 检查结果)
- VERDICT: PASS / NEEDS_IMPROVEMENT / REJECTED
- BLOCKER_ISSUES: []
- CRITICAL_ISSUES: []
- MAJOR_ISSUES: []
- MINOR_ISSUES: [] (non-blocking)
- REASONING: []
```

### reviews/round-{N}/review-analysis.md

```markdown
# Review Analysis - Round {N}

## Verdict
**{PASS / NEEDS_IMPROVEMENT / REJECTED}**

## Issue Summary
| Severity | Count | Action |
|----------|-------|--------|
| BLOCKER  | {n}   | Must fix immediately |
| CRITICAL | {n}   | Must fix before merge |
| MAJOR    | {n}   | Should fix |
| MINOR    | {n}   | Optional (non-blocking) |

## Issues Detail

### BLOCKER
1. {issue_description}
   - Location: {file:line}
   - Reason: {reason}

### CRITICAL
1. {issue_description}

### MAJOR
1. {issue_description}

### MINOR (non-blocking)
1. {issue_description}

## Decision
Based on verdict rules:
- blocker_count = {n} (threshold: 0)
- critical_count = {n} (threshold: 2)
- major_count = {n} (threshold: 5)
- tests_passed = {true/false}

**Result: {VERDICT}**

## Next Steps
{improvement_plan_or_delivery}
```

### final-report.md

```markdown
# Self-Review Final Report

## Task Summary
- **Task ID**: {task-name}
- **Started**: {start_timestamp}
- **Completed**: {end_timestamp}
- **Total Rounds**: {N}
- **Final Verdict**: PASS

## Review History
| Round | Verdict | Blockers | Criticals | Majors | Minors |
|-------|---------|----------|-----------|--------|--------|
| 1     | REJECTED | 1 | 2 | 3 | 5 |
| 2     | NEEDS_IMPROVEMENT | 0 | 1 | 2 | 3 |
| 3     | PASS | 0 | 0 | 1 | 2 |

## Key Improvements Made
1. Round 1 → 2: {summary}
2. Round 2 → 3: {summary}

## Remaining Minor Issues (non-blocking)
1. {issue_1}
2. {issue_2}

## Files Changed
- {file_1}: {description}
- {file_2}: {description}

## Evidence Package Location
`.tasks/self-review/{task-name}/evidence/`

## Reviewer
- Model: Codex (OpenAI)
- Reasoning Effort: xhigh
```

---

## Evidence Package Specification

### 证据分类原则

证据分为两类，确保审查独立性：

| 类型 | 获取方 | 原因 |
|------|--------|------|
| **Reviewer 自行获取** | Codex | 避免 Executor 篡改，确保真实性 |
| **Executor 必须提供** | Claude | 执行结果只有 Executor 知道 |

### Reviewer 自行获取的证据

Reviewer（Codex）在审查时自行执行命令获取，无需 Executor 提供：

| 证据 | 命令 | 说明 |
|------|------|------|
| Git Diff | `git diff {base_commit}..{target_commit}` | 代码变更内容 |
| Git State | `git status --porcelain` | 检查是否 dirty |
| Git Log | `git log --oneline -5` | 最近提交记录 |
| 文件内容 | `cat {file}` | 直接读取相关代码 |

**Reviewer 必须验证**：
```bash
# 1. 验证 commit 匹配
current_commit=$(git rev-parse HEAD)
if [ "$current_commit" != "{executor_claimed_commit}" ]; then
  echo "REJECTED: Commit mismatch"
fi

# 2. 验证代码干净
if [ -n "$(git status --porcelain)" ]; then
  echo "REJECTED: Working directory is dirty"
fi
```

### Executor 必须提供的证据

这些是执行结果，只有 Executor 能提供：

| 文件 | 格式 | 说明 |
|------|------|------|
| `execution-manifest.json` | JSON | 执行清单（命令、时间、版本） |
| `test-results.txt` | Text | 测试执行的完整输出 |
| `lint-results.txt` | Text | Lint 检查的完整输出 |
| `requirement-mapping.md` | Markdown | 需求-代码映射 |

### Optional Evidence

| 文件 | 触发条件 |
|------|----------|
| `coverage-report.txt` | 有测试覆盖率工具 |
| `security-scan.txt` | 涉及安全相关变更 |

### 简化后的目录结构

```
.tasks/self-review/{task-name}/
├── 00-task-spec.md                    # 任务规范
│
├── evidence/                          # Executor 提供的证据
│   ├── execution-manifest.json        # 执行清单（含 commit_hash 锚点）
│   ├── test-results.txt               # 测试输出
│   ├── lint-results.txt               # Lint 输出
│   └── requirement-mapping.md         # 需求映射
│
├── reviews/                           # 审查记录
│   └── round-{N}/
│       ├── review-prompt.md           # 只需传递 commit_hash + 任务描述
│       ├── review-response.md         # Reviewer 自行获取证据后的响应
│       └── ...
```

### execution-manifest.json（锚点文件）

Executor 只需提供这个锚点，Reviewer 据此自行验证：

```json
{
  "task_id": "{task-name}",
  "timestamp": "2026-01-03T12:00:00Z",
  "commit_hash": "abc123...",
  "base_commit": "def456...",
  "commands_executed": [
    {"command": "npm test", "exit_code": 0},
    {"command": "npm run lint", "exit_code": 0}
  ],
  "tool_versions": {
    "node": "20.10.0"
  }
}
```

### Evidence Generation Script（简化版）

```bash
#!/bin/bash
# generate-evidence.sh

TASK_DIR=".tasks/self-review/${TASK_NAME}/evidence"
mkdir -p "$TASK_DIR"

echo "=== Generating Evidence Package ==="

# 1. Execution Manifest (锚点)
cat > "$TASK_DIR/execution-manifest.json" << EOF
{
  "task_id": "${TASK_NAME}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "commit_hash": "$(git rev-parse HEAD)",
  "base_commit": "$(git merge-base HEAD main)",
  "commands_executed": [],
  "tool_versions": {
    "node": "$(node --version 2>/dev/null || echo 'N/A')",
    "python": "$(python3 --version 2>/dev/null || echo 'N/A')"
  }
}
EOF

# 2. Test Results (执行结果)
echo "=== Running Tests ==="
npm test 2>&1 | tee "$TASK_DIR/test-results.txt"
echo "EXIT_CODE: $?" >> "$TASK_DIR/test-results.txt"

# 3. Lint Results (执行结果)
echo "=== Running Lint ==="
npm run lint 2>&1 | tee "$TASK_DIR/lint-results.txt"
echo "EXIT_CODE: $?" >> "$TASK_DIR/lint-results.txt"

echo "Evidence package generated at: $TASK_DIR"
echo "Note: Reviewer will independently verify git state using commit_hash"
```

---

## Severity Levels

| 级别 | 图标 | 定义 | 示例 | 处理 |
|------|------|------|------|------|
| **BLOCKER** | `[!]` | 阻止合并 | 安全漏洞、测试失败、需求缺失 | 必须修复 |
| **CRITICAL** | `[C]` | 影响核心功能 | 逻辑错误、数据风险、缺少关键测试 | >2个则 REJECTED |
| **MAJOR** | `[M]` | 影响可维护性 | 代码重复、命名不清、复杂度过高 | >5个则 NEEDS_IMPROVEMENT |
| **MINOR** | `[m]` | 可选优化 | 风格建议、可选重构 | 不影响判定 (non-blocking) |

---

## Verdict Rules

```yaml
PASS:
  conditions:
    - blocker_count == 0
    - critical_count == 0
    - major_count <= 5
    - tests_passed == true
    - lint_errors == 0

NEEDS_IMPROVEMENT:
  conditions:
    - blocker_count == 0
    - critical_count IN [1, 2]
    - OR major_count > 5
    - OR no_test_framework (首次, with justification)

REJECTED:
  conditions:
    - blocker_count > 0
    - OR critical_count > 2
    - OR tests_passed == false
    - OR test_results_missing
    - OR security_high_critical > 0
    - OR git_is_dirty == true
```

---

## Loop Control

### 循环配置

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| `max_rounds` | 3 | 最大循环次数 |
| `consecutive_reject_limit` | 2 | 连续 REJECTED 上限 |

### 退出条件

| 条件 | 动作 | 输出 |
|------|------|------|
| PASS | 进入交付阶段 | `final-report.md` |
| 循环 >= max_rounds | 暂停，请求用户决策 | 当前状态报告 |
| REJECTED 连续 >= 2 | 暂停，建议重新评估需求 | 问题汇总 |

---

## Codex Integration

### 调用模板

```bash
# 从文件读取 prompt，输出保存到文件
TASK_DIR=".tasks/self-review/${TASK_NAME}"
ROUND=1

codex exec --full-auto \
  "$(cat ${TASK_DIR}/reviews/round-${ROUND}/review-prompt.md)" \
  > "${TASK_DIR}/reviews/round-${ROUND}/review-response.md" 2>&1
```

### 为什么使用 Codex

1. **上下文隔离**：Codex 不共享当前会话上下文
2. **独立推理**：使用 xhigh reasoning effort 确保深度分析
3. **客观评估**：不受执行者思路影响
4. **文件化交互**：prompt 和 response 都以文件形式保存

---

## Execution Commands

### 启动自我监督任务
```bash
/self-review 执行并审查: {任务描述}
```

### 手动触发 Review（仅审查当前状态）
```bash
/self-review --review-only
```

### 继续上次未完成的任务
```bash
/self-review --resume {task-name}
```

### 强制交付（跳过 Review）
```bash
/self-review --force-deliver
```

### 查看任务历史
```bash
/self-review --list
```

---

## Best Practices

1. **任务命名**：使用有意义的 task-name，如 `fix-login-bug-20260103`
2. **原子任务**：将大任务拆分为可独立审查的小任务
3. **证据完整**：确保 evidence/ 目录包含所有必需文件
4. **及时归档**：完成后将 `.tasks/self-review/{task}/` 归档或提交
5. **定期清理**：清理过期的任务目录
