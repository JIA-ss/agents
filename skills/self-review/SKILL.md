---
name: self-review
description: Execute tasks with independent AI review cycles using Codex, self-correction, and iterative improvement until quality criteria are met. Use when needing self-supervised execution, automated QA loops, iterative code review, or quality assurance workflows. Also responds to "自我监督", "迭代审查", "自我修正", "质量循环", "自动改进", "独立审查".
---

# Self-Review

自我监督执行框架：执行→审查→改进的闭环，直到任务通过评估才交付。

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户输入，提取任务描述
2. 生成 task-name: `{简短描述}-{YYYYMMDD}` 格式
3. 创建任务目录: `.tasks/self-review/{task-name}/`
4. 开始 Phase 1

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: Task Confirmation → 输出: 00-task-spec.md
- [ ] Phase 2: Task Execution → 输出: evidence/
- [ ] Phase 3: Independent Review → 输出: reviews/round-{N}/review-response.md
- [ ] Phase 4: Review Analysis → 判定: PASS/NEEDS_IMPROVEMENT/REJECTED
- [ ] Phase 5: Improvement (如需要) → 回到 Phase 2
- [ ] Phase 6: Delivery → 输出: final-report.md
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| Phase 1 | `00-task-spec.md` 存在 | → Phase 2 |
| Phase 2 | `evidence/` 目录含 ≥3 文件 | → Phase 3 |
| Phase 3 | `reviews/round-{N}/review-response.md` 存在 | → Phase 4 |
| Phase 4 | 判定结果明确 | → Phase 5/6 |
| Phase 5 | 改进完成 | → Phase 2 |
| Phase 6 | `final-report.md` 存在 | → 结束 |

---

## Phase 详情

### Phase 1: Task Confirmation

**你必须：**
1. 创建目录 `.tasks/self-review/{task-name}/`
2. 使用模板 [templates/task-spec.md](templates/task-spec.md) 创建 `00-task-spec.md`
3. 填写: 任务描述、验收标准、涉及文件

**完成标志**: `00-task-spec.md` 文件存在且包含验收标准

---

### Phase 2: Task Execution

**你必须：**
1. 执行任务中定义的代码修改
2. 创建 `evidence/` 目录
3. 生成证据文件:
   - `execution-manifest.json`: 记录所有修改的文件
   - `test-results.txt`: 运行测试的输出
   - `requirement-mapping.md`: 需求与实现的对应关系

**完成标志**: `evidence/` 目录存在且包含至少 3 个文件

---

### Phase 3: Independent Review

**你必须：**
1. 创建 `reviews/round-{N}/` 目录
2. 准备 `review-prompt.md` (使用模板 [templates/review-prompt.md](templates/review-prompt.md))
3. 调用 Codex 进行独立审查 (参见 [references/codex-integration.md](references/codex-integration.md))
4. 将审查结果保存到 `review-response.md`

**完成标志**: `reviews/round-{N}/review-response.md` 存在

---

### Phase 4: Review Analysis

**你必须：**
1. 分析审查结果，按严重程度分类问题
2. 统计: blocker_count, critical_count, major_count, minor_count
3. 根据判定规则得出结论

**判定规则**:
- **PASS**: blocker=0, critical=0, major≤5
- **NEEDS_IMPROVEMENT**: blocker=0, critical∈[1,2] 或 major>5
- **REJECTED**: blocker>0 或 critical>2

**完成标志**: 判定结果明确 (PASS/NEEDS_IMPROVEMENT/REJECTED)

---

### Phase 5: Improvement

**触发条件**: 判定为 NEEDS_IMPROVEMENT 且 round < 3

**你必须：**
1. 创建 `improvements/round-{N}-changes.md`
2. 记录需要修复的问题列表
3. 执行修复
4. 回到 Phase 2 重新生成证据

**完成标志**: 修复完成，返回 Phase 2

---

### Phase 6: Delivery

**触发条件**: 判定为 PASS

**你必须：**
1. 使用模板 [templates/final-report.md](templates/final-report.md) 生成最终报告
2. 汇总所有审查轮次记录
3. 输出 `final-report.md`

**完成标志**: `final-report.md` 存在

---

## 目录结构

```
.tasks/self-review/{task-name}/
├── 00-task-spec.md
├── evidence/
│   ├── execution-manifest.json
│   ├── test-results.txt
│   └── requirement-mapping.md
├── reviews/round-{N}/
│   ├── review-prompt.md
│   └── review-response.md
├── improvements/
│   └── round-{N}-changes.md
└── final-report.md
```

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 任务规范模板 | [templates/task-spec.md](templates/task-spec.md) | Phase 1 创建任务规范 |
| 审查提示模板 | [templates/review-prompt.md](templates/review-prompt.md) | Phase 3 准备审查 |
| 最终报告模板 | [templates/final-report.md](templates/final-report.md) | Phase 6 生成报告 |
| 证据规范 | [references/evidence-spec.md](references/evidence-spec.md) | 证据分类说明 |
| Codex 集成 | [references/codex-integration.md](references/codex-integration.md) | 如何调用独立审查 |
| 判定规则 | [references/verdict-rules.md](references/verdict-rules.md) | 详细判定逻辑 |
