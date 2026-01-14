# AI 工作流后续阶段规范

> **功能 ID**: workflow-remaining-phases
> **状态**: draft
> **创建时间**: 2026-01-14
> **版本**: 1.0.0

---

## 1. 概述

### 1.1 背景

AI 工作流框架已完成调研和初步设计，包含 5 个阶段：
- SPECIFY → PLAN → TASK → IMPLEMENT → REVIEW

其中 SPECIFY 阶段已通过 `/specify` skill 实现，REVIEW 阶段可使用现有 `/self-review` skill。

### 1.2 目标

实现工作流框架的后续三个阶段，完成完整的 AI 工作流闭环：
1. **PLAN 阶段**: `/plan` skill - 定义"怎么做"
2. **TASK 阶段**: `/task` skill - 分解为可执行任务
3. **IMPLEMENT 阶段**: `/implement` skill - 执行任务生成代码

### 1.3 范围

| 范围内 | 范围外 |
|--------|--------|
| /plan skill 完整实现 | 修改现有 /specify |
| /task skill 完整实现 | 修改现有 /self-review |
| /implement skill 完整实现 | 创建 /workflow 统一入口 |
| 中文文档和描述 | 复用 /task-planner |
| 与现有目录结构集成 | 多语言支持 |

---

## 2. 利益相关者

| 角色 | 关注点 |
|------|--------|
| 开发者 | 使用工作流加速开发，确保质量 |
| 项目管理 | 任务可追溯，进度可视化 |
| AI 工具 | 结构化输入输出，上下文明确 |

---

## 3. 用户故事

### US-01: 技术方案规划

```
作为 开发者，
我想要 基于需求规范生成技术方案，
以便 在实现前明确架构和技术选型。
```

**验收标准**:
- AC-01.1: 输入已批准的 spec.md，输出 plan.md
- AC-01.2: plan.md 包含技术方案、架构决策、依赖分析、风险评估
- AC-01.3: 使用 Mermaid 图表可视化架构
- AC-01.4: 支持人工审批检查点
- AC-01.5: 保存到 `.agent/specs/{feature}/plan.md`

### US-02: 任务分解

```
作为 开发者，
我想要 将技术方案分解为可执行的任务列表，
以便 有序地执行实现工作。
```

**验收标准**:
- AC-02.1: 输入 plan.md，输出 tasks.md
- AC-02.2: 任务列表包含优先级和依赖关系
- AC-02.3: 支持并行标记 `[P]` 和测试先行标记 `[T]`
- AC-02.4: 任务粒度在 30 分钟 - 8 小时之间
- AC-02.5: 使用 DAG 图可视化依赖关系
- AC-02.6: 保存到 `.agent/specs/{feature}/tasks.md`

### US-03: 任务执行

```
作为 开发者，
我想要 按照任务列表逐个执行实现，
以便 高效、有序地完成代码编写。
```

**验收标准**:
- AC-03.1: 从 tasks.md 读取任务，按依赖顺序执行
- AC-03.2: 支持 TDD 模式（[T] 标记的任务先写测试）
- AC-03.3: 每个任务完成后更新状态标记
- AC-03.4: 支持并行任务执行（使用 Task 工具）
- AC-03.5: 每个任务完成后自动运行测试验证
- AC-03.6: 支持原子提交（每任务一个 commit）

### US-04: 工作流串联

```
作为 开发者，
我想要 各阶段自动识别上一阶段的输出，
以便 无缝衔接整个工作流。
```

**验收标准**:
- AC-04.1: /plan 自动读取同目录下的 spec.md
- AC-04.2: /task 自动读取同目录下的 plan.md
- AC-04.3: /implement 自动读取同目录下的 tasks.md
- AC-04.4: 支持通过参数指定 feature-id
- AC-04.5: 阶段间状态通过 .state.yaml 追踪
- AC-04.6: 当找不到上阶段输出时，提示用户并显示可用的 feature 列表

### US-05: 错误恢复

```
作为 开发者，
我想要 在任务执行失败时能够恢复和重试，
以便 不需要从头开始整个工作流。
```

**验收标准**:
- AC-05.1: 失败任务自动标记为 `[!]` 状态
- AC-05.2: 支持 `--resume` 从上次失败点继续
- AC-05.3: 支持 `--retry {task-id}` 重试指定任务
- AC-05.4: 连续失败 3 次后中止并提示用户
- AC-05.5: 失败日志保存到 `.agent/specs/{feature}/logs/`

---

## 4. 功能需求

### 4.1 /plan Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-P01 | 读取并解析 spec.md | P0 |
| FR-P02 | 生成技术方案（架构、技术选型） | P0 |
| FR-P03 | 记录架构决策（ADR 格式） | P0 |
| FR-P04 | 分析依赖关系（内部、外部） | P0 |
| FR-P05 | 评估风险并提供缓解策略 | P1 |
| FR-P06 | 使用 Mermaid 生成架构图 | P0 |
| FR-P07 | 支持交互模式确认关键决策 | P1 |
| FR-P08 | 输出到 .agent/specs/{feature}/plan.md | P0 |

### 4.2 /task Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-T01 | 读取并解析 plan.md | P0 |
| FR-T02 | 生成任务列表（带优先级） | P0 |
| FR-T03 | 标识任务依赖关系 | P0 |
| FR-T04 | 标记可并行任务 [P] | P0 |
| FR-T05 | 标记测试先行任务 [T] | P0 |
| FR-T06 | 使用 Mermaid 生成 DAG 图 | P0 |
| FR-T07 | 计算关键路径 | P1 |
| FR-T08 | 输出到 .agent/specs/{feature}/tasks.md | P0 |

### 4.3 /implement Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-I01 | 读取并解析 tasks.md | P0 |
| FR-I02 | 按拓扑顺序执行任务 | P0 |
| FR-I03 | TDD 模式支持（[T] 任务先写测试） | P0 |
| FR-I04 | 并行任务使用 Task 工具执行 | P1 |
| FR-I05 | 每任务完成后运行测试 | P0 |
| FR-I06 | 原子提交（每任务一个 commit） | P1 |
| FR-I07 | 更新 tasks.md 中的任务状态 | P0 |
| FR-I08 | 失败任务处理（重试/跳过/中止） | P1 |

---

## 5. 非功能需求

| NFR ID | 描述 | 指标 |
|--------|------|------|
| NFR-01 | 每个 SKILL.md 不超过 500 行 | <500 行 |
| NFR-02 | 使用 Progressive Disclosure 架构 | Level 1: <100 tokens, Level 2: <5k tokens |
| NFR-03 | 支持增量执行（可从中间阶段恢复） | 断点恢复时间 < 5秒，状态恢复准确率 100% |
| NFR-04 | 与现有 /self-review 集成 | IMPLEMENT 完成后 /self-review 可直接读取上下文，无需额外参数 |
| NFR-05 | 技术栈无关 | 默认命令可通过配置覆盖 |

---

## 6. 技术约束

### 6.1 目录结构

```
.agent/specs/{feature}/
├── capture/
│   └── raw-notes.md       # /specify 输出
├── clarify/
│   └── clarified.md       # /specify 输出
├── spec.md                # /specify 输出（已批准）
├── plan.md                # /plan 输出
├── tasks.md               # /task 输出
└── .state.yaml            # 状态追踪
```

### 6.2 任务标记规范

| 标记 | 含义 | 说明 |
|------|------|------|
| `[ ]` | 待执行 | 任务尚未开始 |
| `[~]` | 进行中 | 任务正在执行 |
| `[x]` | 已完成 | 任务成功完成 |
| `[!]` | 失败 | 任务执行失败 |
| `[-]` | 跳过 | 任务被跳过 |
| `[T]` | 测试先行 | 需要先写测试再实现 |
| `[P]` | 可并行 | 可与其他 [P] 任务并行 |
| `[R]` | 需审查 | 完成后需要人工审查 |

### 6.3 Skill 设计规范

- 遵循 skill-best-practices-research 的规范
- 使用中文 description 和文档
- 支持 `--resume` 恢复执行
- 支持 `--validate` 验证输入

---

## 7. 范围外

| 明确排除 | 原因 |
|----------|------|
| 修改 /specify | 已完成且稳定 |
| 修改 /self-review | 已完成且可直接使用 |
| 创建 /workflow 统一入口 | 用户选择独立 skills |
| 复用 /task-planner | 用户选择完全重写 |
| 多语言支持 | 当前仅需中文 |
| IDE 集成 | 超出当前范围 |

---

## 8. 依赖关系

### 8.1 内部依赖

| 依赖项 | 类型 | 说明 |
|--------|------|------|
| /specify 输出 | 数据 | plan 需要 spec.md |
| /self-review | 功能 | implement 后调用审查 |
| .agent/ 目录结构 | 约定 | 所有输出遵循此结构 |

### 8.2 外部依赖

| 依赖项 | 版本 | 用途 |
|--------|------|------|
| Mermaid | 任意 | 图表渲染 |
| Git | 任意 | 原子提交 |

---

## 9. 验收清单

- [ ] /plan skill 实现完成
  - [ ] 读取 spec.md 并生成 plan.md
  - [ ] 包含技术方案、架构决策、依赖、风险
  - [ ] 使用 Mermaid 图表
  - [ ] 支持人工审批
- [ ] /task skill 实现完成
  - [ ] 读取 plan.md 并生成 tasks.md
  - [ ] 任务带优先级和依赖
  - [ ] 支持 [P][T][R] 标记
  - [ ] 使用 Mermaid DAG 图
- [ ] /implement skill 实现完成
  - [ ] 按拓扑顺序执行任务
  - [ ] 支持 TDD 模式
  - [ ] 更新任务状态
  - [ ] 支持原子提交
- [ ] 集成测试
  - [ ] 完整工作流测试: /specify → /plan → /task → /implement → /self-review
  - [ ] 各阶段可独立执行
  - [ ] 支持从中间阶段恢复

---

## 附录 A: 决策记录

| 决策 ID | 决策 | 理由 | 日期 |
|---------|------|------|------|
| D-01 | 独立 Skills 架构 | 用户选择，更灵活 | 2026-01-14 |
| D-02 | 完全重写而非复用 | 用户选择，与工作流设计对齐 | 2026-01-14 |
| D-03 | 全中文文档 | 与 /specify 保持一致 | 2026-01-14 |

---

## 附录 B: 参考资料

| 文档 | 路径 |
|------|------|
| 工作流设计 | `.tasks/self-review/ai-workflow-design-20260112/workflow-design.md` |
| Skill 最佳实践 | `.tasks/self-review/skill-best-practices-research/final-report.md` |
| /specify 实现 | `skills/specify/SKILL.md` |
| /self-review 实现 | `skills/self-review/SKILL.md` |

---

*Generated by /specify STRUCTURE phase*
