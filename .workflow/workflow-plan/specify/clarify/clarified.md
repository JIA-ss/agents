# Clarified Requirements: workflow-plan 阶段设计

> **Feature ID**: workflow-plan
> **澄清日期**: 2026-01-14
> **基于调研**: 业界主流 AI 编程工作流 Planning 阶段设计

---

## 1. 澄清决策记录

### Q1: 多阶段流程设计

**问题**: workflow-plan 是否需要类似 workflow-specify 的多阶段流程？

**用户要求**: 一定要拆分为多阶段流程，但具体拆分要参考业界实践

**调研结论**: 基于 Spec-Kit、Kiro、BMAD、MetaGPT 的分析，推荐采用 **4 阶段流程**：

| 阶段 | 名称 | 对应业界实践 |
|------|------|-------------|
| **ANALYZE** | 需求分析 | Spec-Kit 的 Research & Clarification |
| **DESIGN** | 架构设计 | Kiro Design、BMAD Architect、MetaGPT Architect Agent |
| **REVIEW** | 设计审查 | Spec-Kit Gate Validation、Kiro Design Review |
| **VALIDATE** | 用户批准 | 与 workflow-specify 保持一致 |

**决策**: 采用 `ANALYZE → DESIGN → REVIEW → VALIDATE` 4 阶段流程

---

### Q2: 模板模式

**问题**: plan.md 是否需要支持模板模式（mini/standard/full）？

**用户决策**: 否，只用单一模板

**决策**: 所有场景使用统一的完整模板

---

### Q3: 核心章节

**问题**: plan.md 需要包含哪些核心章节？

**用户决策**: 完整版（6 章节）

**决策**: plan.md 包含以下 6 个核心章节：
1. 概述
2. 架构设计（含系统架构图、模块说明）
3. 技术选型
4. 依赖分析（内部/外部）
5. 风险评估
6. 架构决策记录（ADR）

---

## 2. 确认的需求

### 2.1 功能需求 (FR) - 已确认

| ID | 需求 | 优先级 | 状态 |
|----|------|--------|------|
| FR-01 | 读取并解析 spec.md | P0 | 确认 |
| FR-02 | 生成系统架构设计 | P0 | 确认 |
| FR-03 | 输出技术选型及理由 | P0 | 确认 |
| FR-04 | 分析内部和外部依赖 | P1 | 确认 |
| FR-05 | 评估技术风险并制定缓解策略 | P1 | 确认 |
| FR-06 | 记录架构决策（ADR） | P1 | 确认 |
| FR-07 | 生成 Mermaid 架构图 | P2 | 确认 |
| FR-08 | **采用 4 阶段流程** | P0 | 新增确认 |
| FR-09 | 支持独立审查机制 | P2 | 确认 |
| FR-10 | **支持需求可追溯性** | P1 | 新增（来自调研） |

### 2.2 非功能需求 (NFR) - 已确认

| ID | 需求 | 可量化指标 |
|----|------|-----------|
| NFR-01 | plan.md 必须结构化可解析 | 所有章节有固定标题格式 |
| NFR-02 | 生成时间 | < 60 秒（标准复杂度） |
| NFR-03 | 与 spec.md 需求可追溯 | 每个架构决策关联 FR/NFR ID |
| NFR-04 | **设计完整性** | 覆盖 ≥ 95% 的 spec 需求 |

---

## 3. 4 阶段流程详细设计

### 3.1 流程图

```
ANALYZE → DESIGN → REVIEW → VALIDATE
  分析      设计      审查      验证
    │         │          │         │
    ▼         ▼          ▼         ▼
analysis  plan.md    plan.md   plan.md
   .md    (草稿)    (已审查)  (已批准)
```

### 3.2 各阶段定义

#### 阶段 1: ANALYZE（分析）

**目标**: 分析 spec.md，提取技术决策点

**输入**:
- `.workflow/{feature}/specify/spec.md`（已批准）

**动作**:
1. 读取并解析 spec.md
2. 提取功能需求 (FR) 和非功能需求 (NFR)
3. 识别技术约束和依赖
4. 标记需要架构决策的点
5. 分析现有代码库（如适用）

**输出**: `.workflow/{feature}/plan/analyze/analysis.md`

**参考**: Spec-Kit 的 Research & Clarification 阶段

---

#### 阶段 2: DESIGN（设计）

**目标**: 设计系统架构，生成技术方案

**输入**:
- `analysis.md`
- 项目上下文（CLAUDE.md, constitution.md）

**动作**:
1. 设计系统整体架构
2. 选择技术栈并说明理由
3. 定义模块边界和职责
4. 分析内部/外部依赖
5. 评估技术风险
6. 记录架构决策（ADR）
7. 生成 Mermaid 架构图

**输出**: `.workflow/{feature}/plan/plan.md`（草稿）

**参考**: Kiro Design、BMAD Architect、MetaGPT Architect Agent

---

#### 阶段 3: REVIEW（审查）

**目标**: 独立审查设计方案的质量

**输入**:
- `plan.md`（草稿）
- `spec.md`（用于验证覆盖度）

**动作**:
1. 使用 Task 工具启动独立审查 Agent
2. 验证设计完整性（覆盖所有 spec 需求）
3. 检查一致性（设计内部无矛盾）
4. 评估可实现性
5. 检查可追溯性（决策→需求映射）
6. 生成审查报告

**审查清单**:
- 架构是否覆盖所有功能需求？
- 技术选型是否有合理理由？
- 依赖分析是否完整？
- 风险评估是否全面？
- ADR 是否完整记录关键决策？
- 是否存在可扩展性问题？

**输出**: `.workflow/{feature}/plan/reviews/round-{N}/review-response.md`

**参考**: Spec-Kit Gate Validation、Kiro Design Review

---

#### 阶段 4: VALIDATE（验证）

**目标**: 最终验证，获取用户批准

**动作**:
1. 运行完整性检查（所有必填章节已填写）
2. 运行覆盖度检查（plan vs spec）
3. 展示验证结果和建议
4. 通过 AskUserQuestion 请求用户批准
5. 更新 plan 状态为 "approved"

**输出**: `.workflow/{feature}/plan/plan.md`（已批准）

---

## 4. 输出结构

```
.workflow/{feature}/plan/
├── analyze/
│   └── analysis.md        # 阶段 1 输出
├── reviews/
│   └── round-{N}/         # 阶段 3 审查记录
│       ├── review-prompt.md
│       └── review-response.md
├── plan.md                # 最终技术计划
└── .state.yaml            # 进度跟踪
```

---

## 5. plan.md 模板结构（确认版）

```markdown
# 技术计划: {feature}

> **状态**: draft | reviewed | approved
> **Spec 版本**: {spec-version}
> **创建日期**: {date}

## 1. 概述
{项目背景和技术目标}

## 2. 架构设计

### 2.1 系统架构图
```mermaid
graph TB
    ...
```

### 2.2 模块说明
| 模块 | 职责 | 依赖 | 关联需求 |
|------|------|------|----------|

## 3. 技术选型

| 领域 | 选型 | 理由 | 备选方案 |
|------|------|------|----------|

## 4. 依赖分析

### 4.1 内部依赖
### 4.2 外部依赖

## 5. 风险评估

| 风险 | 可能性 | 影响 | 缓解策略 |
|------|--------|------|----------|

## 6. 架构决策记录 (ADR)

### ADR-001: {决策标题}
- **状态**: 已采纳 | 待定 | 已废弃
- **上下文**: {背景}
- **决策**: {决策内容}
- **后果**: {影响}
- **关联需求**: FR-XX, NFR-XX
```

---

## 6. 与 workflow-specify 的对比

| 维度 | workflow-specify | workflow-plan |
|------|-----------------|---------------|
| 阶段数 | 5 阶段 | 4 阶段 |
| 阶段名称 | CAPTURE→CLARIFY→STRUCTURE→REVIEW→VALIDATE | ANALYZE→DESIGN→REVIEW→VALIDATE |
| 模板模式 | mini/standard/full | 单一模板 |
| 核心输出 | spec.md | plan.md |
| 审查机制 | 独立 Agent 审查 | 独立 Agent 审查 |
| 可追溯性 | N/A | 需求→设计映射 |

---

*Clarified by workflow-specify | 2026-01-14*
