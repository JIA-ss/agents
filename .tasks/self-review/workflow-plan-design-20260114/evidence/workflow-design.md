# workflow-plan 6 阶段流程设计

> **版本**: 2.0.0
> **日期**: 2026-01-14

---

## 1. 流程概览

```
┌─────────────────────────────────────────────────────────────────────┐
│                         WORKFLOW-PLAN                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                       │
│  │ ANALYZE  │───►│ RESEARCH │───►│ REVIEW-1 │                       │
│  │ 需求分析 │    │ 技术调研 │    │ 分析审查 │                       │
│  └────▲─────┘    └────▲─────┘    └────┬─────┘                       │
│       │               │               │                              │
│       │               │         ┌─────┴─────┐                        │
│       │               │         ▼           ▼                        │
│       │               │      [PASS]   [NEEDS_WORK]                   │
│       │               │         │           │                        │
│       │               │         │     ┌─────┴─────┐                  │
│       │               │         │     ▼           ▼                  │
│       └───────────────┼─────────┴─[ANALYZE]   [RESEARCH]             │
│                       └─────────────────────────────┘                │
│                                 │                                    │
│                                 ▼                                    │
│                          ┌──────────┐                                │
│                          │   PLAN   │                                │
│                          │ 架构设计 │                                │
│                          └────┬─────┘                                │
│                               │                                      │
│                               ▼                                      │
│                          ┌──────────┐                                │
│                          │ REVIEW-2 │                                │
│                          │ 设计审查 │                                │
│                          └────┬─────┘                                │
│                               │                                      │
│                         ┌─────┴─────┐                                │
│                         ▼           ▼                                │
│                      [PASS]   [NEEDS_WORK]                           │
│                         │           │                                │
│                         │     ┌─────┴─────┐                          │
│                         │     ▼           ▼                          │
│                         │  [RESEARCH]   [PLAN]                       │
│                         │     │           │                          │
│                         │     └─────┬─────┘                          │
│                         ▼           │                                │
│                    ┌──────────┐     │                                │
│                    │ VALIDATE │◄────┘                                │
│                    │ 用户批准 │                                      │
│                    └──────────┘                                      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. 阶段详细设计

### 2.1 ANALYZE（需求分析）

**目标**: 解析 spec.md，提取技术决策点

**输入**:
- `.workflow/{feature}/specify/spec.md`（已批准）
- 项目上下文（CLAUDE.md, constitution.md）

**动作**:
1. 读取并解析 spec.md
2. 提取功能需求 (FR) 列表
3. 提取非功能需求 (NFR) 列表
4. 识别技术约束
5. 标记需要架构决策的点
6. 识别需要技术调研的领域
7. 分析现有代码库结构（如适用）

**输出**: `.workflow/{feature}/plan/analyze/analysis.md`

**analysis.md 结构**:
```markdown
# 需求分析: {feature}

## 1. 功能需求摘要
| ID | 需求 | 技术影响 | 需调研 |
|----|------|----------|--------|

## 2. 非功能需求摘要
| ID | 需求 | 约束类型 | 量化指标 |
|----|------|----------|----------|

## 3. 技术约束
- 约束 1
- 约束 2

## 4. 待决策点
- [ ] 决策点 1（需调研）
- [ ] 决策点 2

## 5. 调研主题
| 主题 | 原因 | 优先级 |
|------|------|--------|
```

---

### 2.2 RESEARCH（技术调研）

**目标**: 调研技术方案、最佳实践、依赖选型

**输入**:
- `analysis.md`
- 调研主题列表

**动作**:
1. 使用 WebSearch/WebFetch 搜索技术资料
2. 使用 Task (Explore) 分析现有代码库
3. 对比技术方案的优缺点
4. 评估依赖项的成熟度和维护状态
5. 收集最佳实践和参考实现
6. 记录调研结论和建议

**输出**: `.workflow/{feature}/plan/research/research.md`

**research.md 结构**:
```markdown
# 技术调研: {feature}

## 1. 调研主题

### 主题 1: {topic}
**问题**: {question}
**调研方法**: WebSearch / 代码分析 / 文档阅读
**结论**: {conclusion}
**建议**: {recommendation}
**参考来源**:
- [来源1](url)

### 主题 2: {topic}
...

## 2. 技术方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|

## 3. 依赖评估

| 依赖 | 版本 | 维护状态 | 风险 |
|------|------|----------|------|

## 4. 最佳实践

- 实践 1
- 实践 2

## 5. 调研结论

### 已解决的决策点
- [x] 决策点 1: {结论}

### 仍需讨论的问题
- [ ] 问题 1
```

---

### 2.3 REVIEW-1（分析审查）

**目标**: 审查分析和调研是否充分，决定是否进入 PLAN 阶段

**输入**:
- `analysis.md`
- `research.md`
- `spec.md`（用于验证覆盖度）

**审查清单**:
1. 是否所有 FR 都被分析？
2. 是否所有 NFR 都被分析？
3. 调研主题是否全部完成？
4. 调研结论是否有足够依据？
5. 待决策点是否全部有结论？
6. 是否遗漏重要的技术约束？

**判定规则**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 所有检查项通过，覆盖度 ≥ 95% | 进入 PLAN |
| **NEEDS_ANALYZE** | 需求分析不完整或有遗漏 | 回退到 ANALYZE |
| **NEEDS_RESEARCH** | 调研不充分或结论不明确 | 回退到 RESEARCH |

**输出**: `.workflow/{feature}/plan/reviews/review-1/round-{N}/review-response.md`

---

### 2.4 PLAN（架构设计）

**目标**: 基于分析和调研结果，设计系统架构，生成 plan.md

**输入**:
- `analysis.md`
- `research.md`
- 项目上下文

**动作**:
1. 设计系统整体架构
2. 生成 Mermaid 架构图
3. 定义模块边界和职责
4. 确定技术选型（基于调研结果）
5. 分析内部/外部依赖
6. 评估技术风险
7. 记录架构决策（ADR）
8. 建立需求可追溯性映射

**输出**: `.workflow/{feature}/plan/plan.md`（草稿）

**plan.md 结构**: （见 spec.md 附录 A）

---

### 2.5 REVIEW-2（设计审查）

**目标**: 审查设计质量和完整性，决定是否进入 VALIDATE 阶段

**输入**:
- `plan.md`（草稿）
- `spec.md`（用于验证覆盖度）
- `research.md`（验证设计是否基于调研结论）

**审查清单**:
1. 架构是否覆盖所有功能需求？
2. 技术选型是否与调研结论一致？
3. 依赖分析是否完整？
4. 风险评估是否全面？
5. ADR 是否完整记录关键决策？
6. 模块职责是否清晰、无重叠？
7. 是否存在可扩展性问题？
8. 是否存在安全风险？

**判定规则**:

| 判定 | 条件 | 动作 |
|------|------|------|
| **PASS** | 所有检查项通过，覆盖度 ≥ 95% | 进入 VALIDATE |
| **NEEDS_RESEARCH** | 技术方案需要更多调研支撑 | 回退到 RESEARCH |
| **NEEDS_PLAN** | 设计有问题需要修改 | 回退到 PLAN |

**输出**: `.workflow/{feature}/plan/reviews/review-2/round-{N}/review-response.md`

---

### 2.6 VALIDATE（用户批准）

**目标**: 最终验证，获取用户批准

**输入**:
- `plan.md`（已审查）
- 审查报告

**动作**:
1. 运行完整性检查
2. 运行覆盖度检查
3. 展示设计摘要和审查结果
4. 通过 AskUserQuestion 请求用户批准
5. 更新 plan 状态为 "approved"

**输出**: `.workflow/{feature}/plan/plan.md`（已批准）

---

## 3. 目录结构

```
.workflow/{feature}/plan/
├── analyze/
│   └── analysis.md           # ANALYZE 阶段输出
├── research/
│   └── research.md           # RESEARCH 阶段输出
├── reviews/
│   ├── review-1/             # 分析审查
│   │   └── round-{N}/
│   │       ├── review-prompt.md
│   │       └── review-response.md
│   └── review-2/             # 设计审查
│       └── round-{N}/
│           ├── review-prompt.md
│           └── review-response.md
├── plan.md                   # 最终技术计划
└── .state.yaml               # 状态跟踪
```

---

## 4. 状态管理

### .state.yaml 格式

```yaml
feature: {feature-id}
version: 2.0.0
phase: analyze | research | review-1 | plan | review-2 | validate
status: in_progress | completed | failed

# 阶段完成记录
completed_phases:
  analyze:
    completed_at: "2026-01-14T10:00:00Z"
    output: analyze/analysis.md
  research:
    completed_at: "2026-01-14T11:00:00Z"
    output: research/research.md

# Review 状态
reviews:
  review-1:
    current_round: 1
    max_rounds: 3
    history:
      - round: 1
        verdict: NEEDS_RESEARCH
        reason: "技术选型调研不足"
  review-2:
    current_round: 1
    max_rounds: 3
    history: []

# 回退记录
rollbacks:
  - from: review-1
    to: research
    reason: "需要调研数据库选型"
    timestamp: "2026-01-14T12:00:00Z"
```

---

## 5. 循环控制

### 5.1 最大轮次限制

| Review | 最大轮次 | 超限动作 |
|--------|----------|----------|
| REVIEW-1 | 3 | 强制进入 PLAN，标记风险 |
| REVIEW-2 | 3 | 强制进入 VALIDATE，标记风险 |

### 5.2 早期退出条件

```yaml
early_exit:
  confidence_threshold: 0.9
  conditions:
    - no_blocker_issues
    - no_critical_issues
    - coverage >= 95%
```

---

## 6. 命令设计

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

# 跳过审查（不推荐）
/workflow-plan --skip-review {feature}

# 查看状态
/workflow-plan --status {feature}
```

---

*Designed for self-review | 2026-01-14*
