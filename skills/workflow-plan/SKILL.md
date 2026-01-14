---
name: workflow-plan
description: 基于需求规范生成技术计划。通过 6 阶段流程（ANALYZE→RESEARCH→REVIEW-1→PLAN→REVIEW-2→VALIDATE）将 spec.md 转化为 plan.md，包含架构设计、技术选型、风险评估和 ADR。当用户想要"制定计划"、"技术方案"、"架构设计"时使用。也响应 "workflow plan"、"工作流计划"。
---

# Workflow Plan 指南

## 概述

基于已批准的需求规范（spec.md）生成详细的技术计划（plan.md），定义"怎么做"。

**核心价值**：将需求转化为可执行的技术方案，通过双重审查机制确保架构决策质量和风险可控。

---

## 工作流程（6 阶段）

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WORKFLOW-PLAN                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                           │
│  │ ANALYZE  │───►│ RESEARCH │───►│ REVIEW-1 │                           │
│  │ 需求分析 │◄───│ 技术调研 │◄───│ 分析审查 │                           │
│  └────▲─────┘    └────▲─────┘    └────┬─────┘                           │
│       │               │               │                                  │
│       │               │         ┌─────┴─────┐                            │
│       │               │         ▼           ▼                            │
│       │               │      [PASS]   [NEEDS_WORK]                       │
│       │               │         │           │                            │
│       │               │         │    ┌──────┴──────┐                     │
│       │               │         │    ▼             ▼                     │
│       │               └─────────┤ [RESEARCH]  [ANALYZE]                  │
│       └─────────────────────────┴──────────────────┘                     │
│                                 │                                        │
│                                 ▼                                        │
│                          ┌──────────┐                                    │
│                          │   PLAN   │◄──────────────┐                    │
│                          │ 架构设计 │               │                    │
│                          └────┬─────┘               │                    │
│                               │                     │                    │
│                               ▼                     │                    │
│                          ┌──────────┐               │                    │
│                          │ REVIEW-2 │               │                    │
│                          │ 设计审查 │               │                    │
│                          └────┬─────┘               │                    │
│                               │                     │                    │
│                         ┌─────┴─────┐               │                    │
│                         ▼           ▼               │                    │
│                      [PASS]   [NEEDS_WORK]          │                    │
│                         │           │               │                    │
│                         │    ┌──────┴──────┐        │                    │
│                         │    ▼             ▼        │                    │
│                         │ [RESEARCH]    [PLAN]──────┘                    │
│                         │    │                                           │
│                         │    └───► REVIEW-1 ───► PLAN ───► REVIEW-2      │
│                         │                                                │
│                         ▼                                                │
│                    ┌──────────┐                                          │
│                    │ VALIDATE │                                          │
│                    │ 用户批准 │                                          │
│                    └──────────┘                                          │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 阶段详细说明

### 阶段 1: ANALYZE（需求分析）

**目标**: 解析 spec.md，提取技术决策点

**动作**:
1. 读取 `.workflow/{feature}/specify/spec.md`
2. 提取功能需求 (FR) 和非功能需求 (NFR)
3. 识别技术约束和依赖
4. 标记需要架构决策的点
5. 识别需要技术调研的领域

**输出**: `.workflow/{feature}/plan/analyze/analysis.md`

---

### 阶段 2: RESEARCH（技术调研）

**目标**: 调研技术方案、最佳实践、依赖选型

**动作**:
1. 使用 WebSearch/WebFetch 搜索技术资料
2. 使用 Task (Explore) 分析现有代码库
3. 对比技术方案的优缺点
4. 评估依赖项的成熟度
5. 收集最佳实践

**超时配置**:
- 阶段超时: 5 分钟
- 单次搜索: 30 秒
- 最多引用: 10 个来源

**输出**: `.workflow/{feature}/plan/research/research.md`

---

### 阶段 3: REVIEW-1（分析审查）

**目标**: 审查分析和调研是否充分

**审查清单**:
- 是否所有 FR 都被分析？
- 是否所有 NFR 都被分析？
- 调研主题是否全部完成？
- 待决策点是否全部有结论？

**判定规则**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 覆盖度 ≥ 95%，无遗漏 | 进入 PLAN |
| **NEEDS_ANALYZE** | 需求分析不完整 | 回退到 ANALYZE |
| **NEEDS_RESEARCH** | 调研不充分 | 回退到 RESEARCH |

**输出**: `.workflow/{feature}/plan/reviews/review-1/round-{N}/review-response.md`

---

### 阶段 4: PLAN（架构设计）

**目标**: 生成技术计划 plan.md

**动作**:
1. 设计系统整体架构
2. 生成 Mermaid 架构图
3. 确定技术选型（基于调研结果）
4. 分析内部/外部依赖
5. 评估技术风险
6. 记录架构决策（ADR）
7. 建立需求可追溯性映射

**输出**: `.workflow/{feature}/plan/plan.md`（草稿）

---

### 阶段 5: REVIEW-2（设计审查）

**目标**: 审查设计质量和完整性

**审查清单**:
- 架构是否覆盖所有功能需求？
- 技术选型是否与调研结论一致？
- 依赖分析是否完整？
- 风险评估是否全面？
- ADR 是否完整记录关键决策？

**判定规则**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 覆盖度 ≥ 95%，质量达标 | 进入 VALIDATE |
| **NEEDS_RESEARCH** | 需要更多调研支撑 | 回退到 RESEARCH → REVIEW-1 → PLAN |
| **NEEDS_PLAN** | 设计有问题需修改 | 回退到 PLAN |

**输出**: `.workflow/{feature}/plan/reviews/review-2/round-{N}/review-response.md`

---

### 阶段 6: VALIDATE（用户批准）

**目标**: 最终验证，获取用户批准

**动作**:
1. 运行完整性检查
2. 运行覆盖度检查
3. 展示设计摘要
4. 通过 AskUserQuestion 请求用户批准
5. 更新 plan 状态为 "approved"

**输出**: `.workflow/{feature}/plan/plan.md`（已批准）

---

## 命令

```bash
# 完整流程
/workflow-plan {feature}

# 单阶段执行
/workflow-plan analyze {feature}
/workflow-plan research {feature}
/workflow-plan review-1 {feature}
/workflow-plan plan {feature}
/workflow-plan review-2 {feature}
/workflow-plan validate {feature}

# 恢复执行
/workflow-plan --resume {feature}

# 查看状态
/workflow-plan --status {feature}
```

---

## 输出结构

```
.workflow/{feature}/plan/
├── analyze/
│   └── analysis.md           # ANALYZE 阶段输出
├── research/
│   └── research.md           # RESEARCH 阶段输出
├── reviews/
│   ├── review-1/             # 分析审查
│   │   └── round-{N}/
│   │       └── review-response.md
│   └── review-2/             # 设计审查
│       └── round-{N}/
│           └── review-response.md
├── plan.md                   # 最终技术计划
└── .state.yaml               # 状态跟踪
```

---

## 循环控制

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| max_rounds | 3 | 每个 REVIEW 阶段最大轮次 |
| early_exit_confidence | 0.9 | 早期退出置信度阈值 |
| research_timeout | 300s | RESEARCH 阶段超时 |

---

## 回退规则

### REVIEW-1 回退后执行路径

```
NEEDS_ANALYZE → ANALYZE → RESEARCH → REVIEW-1
NEEDS_RESEARCH → RESEARCH → REVIEW-1
```

### REVIEW-2 回退后执行路径

```
NEEDS_PLAN → PLAN → REVIEW-2
NEEDS_RESEARCH → RESEARCH → REVIEW-1 → PLAN → REVIEW-2
```

---

## 集成

**输入**: `/workflow-specify` 生成的 `spec.md`（已批准）
**输出**: 供 `/workflow-task` 使用的 `plan.md`（已批准）

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 计划模板 | [assets/plan-template.md](assets/plan-template.md) | plan.md 模板 |
| 分析模板 | [assets/analysis-template.md](assets/analysis-template.md) | analysis.md 模板 |
| 调研模板 | [assets/research-template.md](assets/research-template.md) | research.md 模板 |
| 阶段参考 | [references/phase-details.md](references/phase-details.md) | 详细阶段文档 |
| 审查清单 | [references/review-checklist.md](references/review-checklist.md) | 审查清单详情 |
