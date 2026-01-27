---
name: workflow-review
description: 独立审查代码实现质量。通过 6 阶段流程（COLLECT→ANALYZE→REVIEW→VERDICT→IMPROVE→REPORT）对 workflow-implement 输出进行全面审查，支持五维度检查和迭代改进。当用户想要"审查代码"、"质量检查"、"代码评审"时使用。也响应 "workflow review"、"工作流审查"。
---

# Workflow Review

独立审查代码实现质量：COLLECT → ANALYZE → REVIEW → VERDICT → IMPROVE → REPORT

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 验证 `.workflow/{feature}/implement/` 目录存在
2. **询问用户审查方式**：使用 AskUserQuestion 让用户选择:
   - **选项 1: Codex 审查**（推荐）- 使用 /codex skill 进行高质量审查
   - **选项 2: 独立 Agent 审查** - 使用 Task 工具启动独立审查 Agent
3. 记录审查方式到 `.state.yaml`
4. 创建目录: `.workflow/{feature}/review/`
5. 开始 Phase 1: COLLECT

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: COLLECT → 输出: evidence/
- [ ] Phase 2: ANALYZE → 输出: analysis/dimension-report.md
- [ ] Phase 3: REVIEW → 输出: reviews/round-{N}/review-response.md
- [ ] Phase 4: VERDICT → 判定: PASS/NEEDS_FIX/REJECTED
- [ ] Phase 5: IMPROVE (如需要) → 触发 workflow-implement，回到 Phase 1
- [ ] Phase 6: REPORT → 输出: final-report.md
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| COLLECT | `evidence/` 目录含测试结果 | → ANALYZE |
| ANALYZE | `analysis/dimension-report.md` 存在 | → REVIEW |
| REVIEW | `reviews/round-{N}/review-response.md` 存在 | → VERDICT |
| VERDICT | 判定结果明确 | → IMPROVE/REPORT |
| IMPROVE | workflow-implement 完成 | → COLLECT |
| REPORT | `final-report.md` 存在 | → 结束 |

---

## Phase 详情

### Phase 1: COLLECT（收集证据）

**你必须：**
1. 读取 implement 执行日志和报告
2. 运行项目测试，收集结果到 `evidence/test-results.txt`
3. 运行 lint 检查，收集结果到 `evidence/lint-results.txt`
4. 生成代码变更 diff 到 `evidence/changes.diff`
5. 收集覆盖率报告（如有）

**错误处理**:
- implement 目录不存在 → 中止，提示先执行 workflow-implement
- 测试命令不存在 → 跳过，记录警告

**完成标志**: `evidence/` 目录存在且含测试结果

---

### Phase 2: ANALYZE（多维分析）

**你必须：**
1. 从五个维度分析代码质量
2. 创建 `analysis/dimension-report.md`

**五维度检查**:

| 维度 | 检查项 | 阈值 |
|------|--------|------|
| 代码质量 | 规范、异味、复杂度 | 圈复杂度 ≤15 |
| 测试覆盖 | 通过率、覆盖率 | 100% 通过，≥80% 覆盖 |
| 规范合规 | 符合 spec.md | 100% 验收标准 |
| 安全检查 | 密钥、注入、XSS | 无 BLOCKER |
| 性能检查 | 循环、资源泄露 | 无 MAJOR 问题 |

> 检查清单: [references/review-checklist.md](references/review-checklist.md)

**完成标志**: `analysis/dimension-report.md` 存在

---

### Phase 3: REVIEW（独立审查）

**你必须：**
1. 根据用户在"立即行动"阶段选择的审查方式执行:
   - **Codex 审查**: 使用 Skill 工具调用 `/codex` skill，传递测试结果、lint 结果、代码变更
   - **独立 Agent 审查**: 使用 Task 工具启动独立审查 Agent（信息隔离）
2. 传递内容（两种方式共通）:
   - 传递: 测试结果、lint 结果、代码变更
   - 不传递: 实现过程思考、调试日志、历史对话
3. 创建 `reviews/round-{N}/review-response.md`

**完成标志**: `reviews/round-{N}/review-response.md` 存在

---

### Phase 4: VERDICT（判定）

**你必须：**
1. 分析审查结果，统计问题数量
2. 按严重程度分类: BLOCKER/CRITICAL/MAJOR/MINOR
3. 根据规则判定

**判定规则**:
- **PASS**: blocker=0, critical=0, major≤5, tests_passed=true → REPORT
- **NEEDS_FIX**: blocker=0, (critical∈[1,2] 或 major>5), round<3 → IMPROVE
- **REJECTED**: blocker>0 或 critical>2 或 tests_failed 或 round≥3 → 停止

**完成标志**: 判定结果明确

---

### Phase 5: IMPROVE（触发修复）

**触发条件**: 判定为 NEEDS_FIX 且 round < 3

**你必须：**
1. 识别需要修复的任务
2. 分析问题根因
3. 生成修复指令到 `improvements/round-{N}/fix-log.md`
4. 触发 workflow-implement 重新执行
5. 完成后返回 Phase 1: COLLECT

**完成标志**: workflow-implement 完成，返回 COLLECT

---

### Phase 6: REPORT（生成报告）

**触发条件**: 判定为 PASS

**你必须：**
1. 汇总所有轮次审查历史
2. 统计问题和修复记录
3. 使用 [assets/report-template.md](assets/report-template.md) 创建 `final-report.md`

**完成标志**: `final-report.md` 存在

---

## 目录结构

```
.workflow/{feature}/review/
├── .state.yaml
├── evidence/
│   ├── test-results.txt
│   ├── lint-results.txt
│   └── changes.diff
├── analysis/
│   └── dimension-report.md
├── reviews/
│   └── round-{N}/
│       └── review-response.md
├── improvements/
│   └── round-{N}/
│       └── fix-log.md
└── final-report.md
```

---

## 严重程度定义

| 级别 | 定义 | 示例 |
|------|------|------|
| BLOCKER | 阻止合并 | 安全漏洞、测试失败 |
| CRITICAL | 影响核心功能 | 逻辑错误、数据丢失 |
| MAJOR | 影响可维护性 | 代码异味、复杂度高 |
| MINOR | 可选优化 | 命名、注释 |

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 状态模板 | [assets/state-template.yaml](assets/state-template.yaml) | COLLECT 阶段 |
| 报告模板 | [assets/report-template.md](assets/report-template.md) | REPORT 阶段 |
| 审查清单 | [references/review-checklist.md](references/review-checklist.md) | ANALYZE/REVIEW 阶段 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 详细子任务 |

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
