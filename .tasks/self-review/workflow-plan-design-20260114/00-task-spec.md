# Task Specification: workflow-plan 阶段设计

> **Task ID**: workflow-plan-design-20260114
> **创建日期**: 2026-01-14
> **状态**: in_progress

---

## 1. 任务目标

基于现有的 `.workflow/workflow-plan/specify/spec.md` 规范，重新设计 workflow-plan 阶段的流程，增加：
1. **RESEARCH** 阶段 - 技术调研
2. **双重 REVIEW 机制** - 分析/调研后审查 + 设计后审查
3. **回退控制** - 根据审查结果决定回退到哪个阶段

---

## 2. 用户需求（原文）

> 基于 .workflow/workflow-plan/ 的 spec 及相关总结，设计 workflow-plan 阶段，但是需要额外加一个 RESEARCH 阶段，ANALYSIS 和 RESEARCH 之后加一个 REVIEW 阶段控制是否需要回退到 ANALYSIS 继续分析或继续调研。直到通过才进入 PLAN 阶段，PLAN 阶段完成后，也要进入 REVIEW 阶段，判断是要回到 RESEARCH 阶段还是继续回到 PLAN 阶段。使用 /skill-generator 来做 skill 的最终生成与重构。

---

## 3. 设计约束

### 3.1 新流程设计

```
                    ┌─────────────────────────────────────────────┐
                    │              RESEARCH LOOP                   │
                    │                                              │
┌──────────┐    ┌───▼──────┐    ┌───────────┐    ┌─────────────┐  │
│ ANALYZE  │───►│ RESEARCH │───►│ REVIEW-1  │───►│    PLAN     │  │
│ 需求分析 │    │ 技术调研 │    │ 分析审查  │    │  架构设计   │  │
└────▲─────┘    └────▲─────┘    └─────┬─────┘    └──────┬──────┘  │
     │               │                │                  │         │
     │               │          ┌─────┴─────┐            │         │
     │               │          ▼           ▼            │         │
     │               │       [PASS]    [NEEDS_WORK]      │         │
     │               │          │           │            │         │
     │               │          │     ┌─────┴─────┐      │         │
     │               │          │     ▼           ▼      │         │
     │               └──────────┼─[RESEARCH]  [ANALYZE]──┘         │
     └──────────────────────────┴─────────────────────────────────-┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │       REVIEW-2        │
                    │       设计审查        │
                    └───────────┬───────────┘
                          ┌─────┴─────┐
                          ▼           ▼
                       [PASS]    [NEEDS_WORK]
                          │           │
                          │     ┌─────┴─────┐
                          │     ▼           ▼
                          │  [RESEARCH]   [PLAN]
                          │     │           │
                          │     └─────┬─────┘
                          │           │
                          ▼           │
                    ┌───────────┐     │
                    │ VALIDATE  │◄────┘
                    │ 用户批准  │
                    └───────────┘
```

### 3.2 阶段定义

| 阶段 | 名称 | 职责 | 输出 |
|------|------|------|------|
| **ANALYZE** | 需求分析 | 解析 spec.md，提取技术决策点 | analysis.md |
| **RESEARCH** | 技术调研 | 调研技术方案、最佳实践 | research.md |
| **REVIEW-1** | 分析审查 | 审查分析和调研是否充分 | review-1-response.md |
| **PLAN** | 架构设计 | 生成 plan.md | plan.md (draft) |
| **REVIEW-2** | 设计审查 | 审查设计质量和完整性 | review-2-response.md |
| **VALIDATE** | 用户批准 | 获取用户最终批准 | plan.md (approved) |

### 3.3 审查回退规则

#### REVIEW-1（分析审查）回退规则

| 判定 | 条件 | 动作 |
|------|------|------|
| PASS | 分析完整，调研充分 | 进入 PLAN |
| NEEDS_ANALYZE | 需求分析不足 | 回退到 ANALYZE |
| NEEDS_RESEARCH | 技术调研不足 | 回退到 RESEARCH |

#### REVIEW-2（设计审查）回退规则

| 判定 | 条件 | 动作 |
|------|------|------|
| PASS | 设计完整，质量达标 | 进入 VALIDATE |
| NEEDS_RESEARCH | 技术方案需要更多调研 | 回退到 RESEARCH |
| NEEDS_PLAN | 设计需要修改 | 回退到 PLAN |

---

## 4. 交付物

1. **SKILL.md** - 完整的 workflow-plan skill 文档
2. **assets/** - 模板文件（plan-template.md, analysis-template.md, research-template.md）
3. **references/** - 参考文档（phase-details.md, review-checklist.md）

---

## 5. 验收标准

- [ ] 6 阶段流程设计完整
- [ ] 双重 REVIEW 机制实现
- [ ] 回退规则定义清晰
- [ ] 使用 /skill-generator 生成最终 SKILL.md
- [ ] 独立审查通过

---

*Created by self-review skill | 2026-01-14*
