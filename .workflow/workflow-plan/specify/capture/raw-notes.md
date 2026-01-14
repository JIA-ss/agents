# Raw Notes: workflow-plan 阶段设计

> **Feature ID**: workflow-plan
> **捕获日期**: 2026-01-14
> **Ambiguity Score**: 2/10 (低歧义)

---

## 1. 项目上下文

### 1.1 现有工作流
- **workflow-specify**: 已完整实现，5 阶段流程（CAPTURE → CLARIFY → STRUCTURE → REVIEW → VALIDATE）
- **workflow-plan**: 框架已存在，待完善
- **workflow-task**: 框架已存在，待实现
- **workflow-implement**: 框架已存在，待实现
- **workflow-review**: 框架已存在，待实现

### 1.2 参考来源
1. **调研报告** (`.tasks/self-review/ai-workflow-research-20260112/final-report.md`)
   - Spec-Kit 的 `/plan` 命令模式
   - BMAD-METHOD 的架构师角色
   - Hybrid Approach 的 Planning 阶段

2. **设计文档** (`.tasks/self-review/ai-workflow-design-20260112/workflow-design.md`)
   - Phase 2: PLAN 定义
   - plan.md 模板结构
   - 配置文件设计

### 1.3 技术约束
- 必须与 workflow-specify 输出（spec.md）兼容
- 必须为 workflow-task 提供可解析的输入
- 使用 Mermaid 生成架构图
- 支持 ADR（架构决策记录）

---

## 2. 利益相关者

| 角色 | 需求 |
|------|------|
| **开发者** | 清晰的技术方案指导实现 |
| **AI Agent** | 可解析的结构化输入 |
| **审查者** | 可追溯的架构决策 |
| **项目经理** | 风险评估和依赖分析 |

---

## 3. 原始需求提取

### 3.1 功能需求 (FR)

| ID | 需求 | 优先级 | 来源 |
|----|------|--------|------|
| FR-01 | 读取并解析 spec.md | P0 | workflow-design.md |
| FR-02 | 生成系统架构设计 | P0 | final-report.md |
| FR-03 | 输出技术选型及理由 | P0 | workflow-design.md |
| FR-04 | 分析内部和外部依赖 | P1 | workflow-design.md |
| FR-05 | 评估技术风险并制定缓解策略 | P1 | final-report.md |
| FR-06 | 记录架构决策（ADR） | P1 | workflow-design.md |
| FR-07 | 生成 Mermaid 架构图 | P2 | workflow-design.md |
| FR-08 | 支持多阶段流程（类似 specify） | P2 | workflow-specify 参考 |
| FR-09 | 支持独立审查机制 | P2 | workflow-specify 参考 |

### 3.2 非功能需求 (NFR)

| ID | 需求 | 可量化指标 |
|----|------|-----------|
| NFR-01 | plan.md 必须结构化可解析 | 所有章节有固定标题格式 |
| NFR-02 | 生成时间 | < 60 秒（标准复杂度） |
| NFR-03 | 与 spec.md 需求可追溯 | 每个架构决策关联 FR/NFR ID |

### 3.3 约束条件

| 约束 | 说明 |
|------|------|
| C-01 | 输入必须是已批准的 spec.md |
| C-02 | 输出路径固定为 `.workflow/{feature}/plan/` |
| C-03 | 必须使用中文输出 |
| C-04 | 架构图使用 Mermaid 语法 |

---

## 4. 待澄清问题

| # | 问题 | 推荐默认值 |
|---|------|-----------|
| Q1 | 是否需要类似 specify 的多阶段流程？ | 是，采用 ANALYZE → DESIGN → REVIEW → VALIDATE 4 阶段 |
| Q2 | 是否需要独立审查机制？ | 是，与 specify 保持一致 |
| Q3 | plan.md 是否需要模板模式（mini/standard/full）？ | 是，与 specify 保持一致 |
| Q4 | 是否支持恢复执行？ | 是，使用 .state.yaml |

---

## 5. 与其他 workflow 的关系

```
workflow-specify (spec.md)
        │
        ▼
workflow-plan (plan.md)  ← 当前设计目标
        │
        ▼
workflow-task (tasks.md)
        │
        ▼
workflow-implement (代码)
        │
        ▼
workflow-review (审查报告)
```

---

## 6. 参考架构

### 来自 Spec-Kit
```
/plan 命令:
- 读取 spec.md
- 输出 plan.md
- 包含技术方案、依赖、风险
```

### 来自 BMAD-METHOD
```
Architect Agent:
- 系统设计
- 技术选型
- 架构决策记录
```

### 来自 workflow-design.md
```markdown
## plan.md 模板
1. 概述
2. 架构设计
   - 系统架构图
   - 模块说明
3. 技术选型
4. 依赖分析
5. 风险评估
6. 架构决策记录 (ADR)
```

---

*Captured by workflow-specify | 2026-01-14*
