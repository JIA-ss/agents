---
name: workflow-plan
description: 基于需求规范生成技术计划。通过 6 阶段流程（ANALYZE→RESEARCH→REVIEW-1→PLAN→REVIEW-2→VALIDATE）将 spec.md 转化为 plan.md，包含架构设计、技术选型、风险评估和 ADR。当用户想要"制定计划"、"技术方案"、"架构设计"时使用。也响应 "workflow plan"、"工作流计划"。
---

# Workflow Plan

将需求规范转化为技术计划：ANALYZE → RESEARCH → REVIEW-1 → PLAN → REVIEW-2 → VALIDATE

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 验证 `.workflow/{feature}/specify/spec.md` 存在且 status: approved
2. 创建目录: `.workflow/{feature}/plan/`
3. 开始 Phase 1: ANALYZE

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: ANALYZE → 输出: analyze/analysis.md
- [ ] Phase 2: RESEARCH → 输出: research/research.md
- [ ] Phase 3: REVIEW-1 → 判定: PASS 进入下一阶段
- [ ] Phase 4: PLAN → 输出: plan.md（草稿）
- [ ] Phase 5: REVIEW-2 → 判定: PASS 进入下一阶段
- [ ] Phase 6: VALIDATE → 输出: plan.md（status: approved）
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| ANALYZE | `analyze/analysis.md` 存在 | → RESEARCH |
| RESEARCH | `research/research.md` 存在 | → REVIEW-1 |
| REVIEW-1 | 判定 PASS | → PLAN |
| PLAN | `plan.md` 草稿存在 | → REVIEW-2 |
| REVIEW-2 | 判定 PASS | → VALIDATE |
| VALIDATE | 用户批准，status: approved | → 结束 |

---

## Phase 详情

### Phase 1: ANALYZE（需求分析）

**你必须：**
1. 读取 spec.md，解析功能需求 (FR) 和非功能需求 (NFR)
2. 识别技术约束和依赖
3. 标记需要架构决策的点
4. 识别需要调研的技术领域
5. 使用 [assets/analysis-template.md](assets/analysis-template.md) 创建 `analyze/analysis.md`

**完成标志**: `analyze/analysis.md` 存在

---

### Phase 2: RESEARCH（技术调研）

**你必须：**
1. 按 5 子阶段执行: Overview → Current State → Analysis → Deep Dive(可选) → Implementation(可选)
2. 每次搜索/分析记录证据到 `research/evidence/evidence-{N}.md`
3. 汇总生成 `research/research.md`

**子阶段模板**: 参见 [assets/research/](assets/research/) 目录

**完成标志**: `research/research.md` 存在且所有 P0 调研主题有结论

---

### Phase 3: REVIEW-1（分析审查）

**你必须：**
1. 使用 Task 工具启动独立审查 Agent
2. 审查: FR/NFR 覆盖度、调研完整性、决策点结论
3. 创建 `reviews/review-1/round-{N}/review-response.md`

**判定规则**:
- **PASS**: 覆盖度 ≥ 95% → PLAN
- **NEEDS_ANALYZE**: 分析不完整 → 回退 ANALYZE
- **NEEDS_RESEARCH**: 调研不充分 → 回退 RESEARCH

**完成标志**: 判定为 PASS

---

### Phase 4: PLAN（架构设计）

**你必须：**
1. 设计系统整体架构，生成 Mermaid 架构图
2. 确定技术选型（基于调研结果）
3. 评估技术风险（3-5 个关键风险）
4. 记录架构决策（ADR）
5. 使用 [assets/plan-template.md](assets/plan-template.md) 创建 `plan.md`

**完成标志**: `plan.md` 草稿存在且包含架构图

---

### Phase 5: REVIEW-2（设计审查）

**你必须：**
1. 使用 Task 工具启动独立审查 Agent
2. 审查: 架构覆盖度、技术选型一致性、风险评估、ADR 完整性
3. 创建 `reviews/review-2/round-{N}/review-response.md`

**判定规则**:
- **PASS**: 覆盖度 ≥ 95% → VALIDATE
- **NEEDS_PLAN**: 设计需修改 → 回退 PLAN
- **NEEDS_RESEARCH**: 需更多调研 → 回退 RESEARCH → REVIEW-1 → PLAN

**完成标志**: 判定为 PASS

---

### Phase 6: VALIDATE（用户批准）

**你必须：**
1. 生成输出概要（关键信息摘要，≤200 字）
2. 输出文档链接：
   - 使用 Markdown 链接格式：`[plan.md](.workflow/{feature}/plan/plan.md)`
   - 用户可点击跳转到完整文档
3. 通过 AskUserQuestion 请求用户批准
4. 更新 plan.md frontmatter: `status: approved`
5. 更新 `.state.yaml`

**概要格式**:
```
## 📄 技术计划已完成

**核心内容**:
- 架构模式: {架构类型}
- 技术栈: {主要技术选型}
- 关键风险: {风险数量} 个
- ADR 记录: {决策数量} 个

**详细文档**: [plan.md](.workflow/{feature}/plan/plan.md)
```

**完成标志**: plan.md 状态为 approved

---

## 目录结构

```
.workflow/{feature}/plan/
├── analyze/
│   └── analysis.md
├── research/
│   ├── 1-overview/overview.md
│   ├── 2-current-state/current-state.md
│   ├── 3-analysis/analysis.md
│   ├── evidence/evidence-{N}.md
│   └── research.md
├── reviews/
│   ├── review-1/round-{N}/review-response.md
│   └── review-2/round-{N}/review-response.md
├── plan.md
└── .state.yaml
```

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 分析模板 | [assets/analysis-template.md](assets/analysis-template.md) | ANALYZE 阶段 |
| 调研模板 | [assets/research-template.md](assets/research-template.md) | RESEARCH 汇总 |
| 计划模板 | [assets/plan-template.md](assets/plan-template.md) | PLAN 阶段 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 详细子任务 |
| 审查清单 | [references/review-checklist.md](references/review-checklist.md) | REVIEW 阶段 |

---

## 集成

**输入**: `/workflow-specify` 生成的 `spec.md`（已批准）
**输出**: 供 `/workflow-task` 使用的 `plan.md`（已批准）
