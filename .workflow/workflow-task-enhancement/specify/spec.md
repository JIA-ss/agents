# 需求规范: workflow-task 完善

| 字段 | 值 |
|------|-----|
| **规范 ID** | SPEC-WORKFLOW-TASK-001 |
| **版本** | 1.1.0 |
| **状态** | reviewed |
| **创建日期** | 2026-01-15 |
| **作者** | AI Assistant |

---

## 1. 概述

### 1.1 背景

`workflow-task` 是 workflow 流程链条中的任务分解环节，负责将技术计划（plan.md）转化为可执行的任务列表（tasks.md）。当前实现较为简单（146 行，标注"待完整实现"），需要完善到与 workflow-plan 相同的完整度。

### 1.2 目标

将 `workflow-task` skill 完善为一个完整的、与其他 workflow-* skills 风格一致的任务分解工具，具备：
- 6 阶段工作流程（含审查和验证）
- 任务粒度自动检测
- 完整的资源文件支持
- 状态管理和断点恢复

### 1.3 预期产出

- 重构后的 `skills/workflow-task/SKILL.md`
- 资源文件：`assets/tasks-template.md`
- 参考文档：`references/phase-details.md`
- 验证脚本：`scripts/validate-tasks.sh`

### 1.4 范围内（In Scope）

1. 完整的 6 阶段工作流程定义（PARSE→DECOMPOSE→ANALYZE→REVIEW→REFINE→VALIDATE）
2. 任务粒度自动检测和警告机制
3. 任务依赖分析和 DAG 生成
4. TDD 任务标记（[T]）和并行标记（[P]）
5. 独立 Agent 审查机制（通过 Task 工具）
6. 用户验证和确认流程
7. 状态管理和断点恢复
8. 资源文件（模板、参考文档、脚本）

---

## 2. 用户故事

### US-1: 基本任务分解

**作为** 使用 workflow 流程的开发者，
**我想要** 将已审批的技术方案自动分解为可执行的任务列表，
**以便** 我可以按照明确的步骤和顺序进行代码实现。

**验收标准**:
1. 给定一个有效的 `.workflow/{feature}/plan/plan.md`，系统生成 `tasks.md`
2. 生成的任务包含 ID、描述、优先级、依赖关系和状态字段
3. 任务按阶段分组，每阶段包含 Mermaid 甘特图
4. 生成依赖关系的 Mermaid DAG 图
5. 如果 plan.md 不存在或状态非 approved，显示错误信息

### US-2: 任务粒度检测

**作为** 开发者，
**我想要** 系统自动检测任务粒度是否合理，
**以便** 我可以避免任务过大难以管理或过小浪费上下文切换成本。

**验收标准**:
1. 任务估时 < 30 分钟时，显示警告"任务可能过小，考虑合并"
2. 任务估时 > 8 小时时，显示警告"任务可能过大，考虑拆分"
3. 警告不阻止流程继续，但记录到审查报告
4. 在 VALIDATE 阶段汇总所有粒度警告

### US-3: 任务依赖分析

**作为** 开发者，
**我想要** 系统自动分析任务间的依赖关系并计算关键路径，
**以便** 我可以了解哪些任务可以并行，哪些是阻塞点。

**验收标准**:
1. 基于 plan.md 中的模块依赖自动推导任务依赖
2. 可并行的任务标记为 `[P]`
3. 生成包含所有任务的 DAG 图
4. 计算并显示关键路径
5. 检测并报告循环依赖（如有）
6. 当所有任务无依赖时，显示"所有任务可并行执行"
7. 单任务场景下，显示"无依赖关系，单任务直接执行"

### US-4: TDD 任务标记

**作为** 实践 TDD 的开发者，
**我想要** 系统自动识别并标记需要测试先行的任务，
**以便** 在 workflow-implement 阶段可以先写测试再实现。

**验收标准**:
1. 核心业务逻辑任务自动标记 `[T]`
2. 纯配置或脚手架任务不标记 `[T]`
3. 用户可在 VALIDATE 阶段手动调整标记
4. 标记信息传递给 workflow-implement
5. 混合类型任务（既有业务逻辑又有配置）默认标记 `[T]`，用户可覆盖

### US-5: 任务分解审查

**作为** 开发者，
**我想要** 独立的 AI Agent 审查任务分解质量，
**以便** 确保任务划分合理、依赖正确、无遗漏。

**验收标准**:
1. REVIEW 阶段使用独立 Agent（通过 Task 工具）
2. 审查维度包括：任务完整性、粒度合理性、依赖正确性
3. 审查结果为 PASS/NEEDS_IMPROVEMENT/REJECTED
4. NEEDS_IMPROVEMENT 时返回修改，最多 3 轮
5. 审查记录保存到 `reviews/round-{N}/`

### US-6: 用户验证确认

**作为** 开发者，
**我想要** 在最终生成前预览和调整任务列表，
**以便** 我可以根据实际情况微调优先级或依赖。

**验收标准**:
1. VALIDATE 阶段展示完整的任务列表和依赖图
2. 汇总所有警告信息（粒度、依赖等）
3. 用户可选择批准、修改或拒绝
4. 批准后 tasks.md 状态更新为 approved
5. 拒绝时记录原因并结束流程

### US-7: 断点恢复

**作为** 开发者，
**我想要** 在流程中断后能够从上次位置继续，
**以便** 不需要重新开始整个流程。

**验收标准**:
1. 每个阶段完成后更新 `.state.yaml`
2. `--resume` 命令从中断点继续
3. 状态文件记录当前阶段、已完成阶段、输出文件路径
4. 恢复时验证已有输出的完整性
5. 验证失败时提示用户并提供重新开始选项

---

## 3. 功能性需求

### FR-1: 6 阶段工作流程

实现以下工作流程：

```
PARSE → DECOMPOSE → ANALYZE → REVIEW → REFINE → VALIDATE
 解析     分解       分析      审查     优化      验证
   │        │          │         │        │         │
   ▼        ▼          ▼         ▼        ▼         ▼
plan.md  tasks    dependencies review   refined   approved
(parsed)  (draft)   (DAG)      report   tasks.md  tasks.md
```

| 阶段 | 输入 | 输出 | 说明 |
|------|------|------|------|
| PARSE | plan.md | 解析结果 | 提取模块、接口、架构信息 |
| DECOMPOSE | 解析结果 | tasks.md (草稿) | 生成任务列表，标记 [T][P][R] |
| ANALYZE | tasks.md | DAG + 关键路径 | 依赖分析、粒度检测 |
| REVIEW | tasks.md + 分析结果 | 审查报告 | 独立 Agent 审查 |
| REFINE | 审查反馈 | tasks.md (优化) | 根据反馈修改 |
| VALIDATE | 优化后的 tasks.md | tasks.md (approved) | 用户确认 |

### FR-2: 任务结构

每个任务包含以下字段：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 是 | 唯一标识，格式 T{阶段}{序号}，如 T1.1 |
| title | string | 是 | 简短任务标题 |
| description | string | 是 | 详细任务描述 |
| priority | enum | 是 | P0(紧急)/P1(高)/P2(中)/P3(低) |
| estimate | string | 是 | 预估时间，如 "2h", "30m" |
| depends_on | array | 否 | 依赖的任务 ID 列表 |
| markers | array | 否 | 标记列表 [T]/[P]/[R] |
| status | enum | 是 | pending/in_progress/completed/blocked |
| module | string | 是 | 所属模块（来自 plan.md） |

### FR-3: 资源文件

| 文件 | 路径 | 用途 |
|------|------|------|
| tasks-template.md | assets/tasks-template.md | tasks.md 模板 |
| phase-details.md | references/phase-details.md | 详细阶段说明 |
| validate-tasks.sh | scripts/validate-tasks.sh | 验证 tasks.md 格式 |

### FR-4: 命令接口

```bash
# 基本用法
/workflow-task {feature}

# 单阶段执行
/workflow-task parse {feature}
/workflow-task decompose {feature}
/workflow-task analyze {feature}
/workflow-task review {feature}
/workflow-task refine {feature}
/workflow-task validate {feature}

# 选项
/workflow-task {feature} --resume      # 断点恢复
/workflow-task {feature} --validate    # 仅验证
/workflow-task {feature} --force       # 跳过审查
```

---

## 4. 非功能性需求

### NFR-1: 一致性

- SKILL.md 章节结构与 workflow-plan 至少 90% 一致（相同的主要章节）
- 命令格式与其他 workflow-* 命令一致（/workflow-{name} {feature} [options]）
- 输出目录结构遵循 `.workflow/{feature}/task/` 规范

**验证方法**: 对比 workflow-plan 和 workflow-task 的 SKILL.md 章节目录

### NFR-2: 可维护性

- 每个阶段定义独立于 SKILL.md 的单个章节中
- 资源文件（assets/, references/, scripts/）与主文档分离
- 代码变更影响范围可控：修改单个阶段不影响其他阶段

**验证方法**: 检查 SKILL.md 结构和资源文件独立性

### NFR-3: 兼容性

- 100% 兼容 workflow-plan v1.0+ 输出的 plan.md
- 生成的 tasks.md 可被 workflow-implement 直接消费
- 现有 `/workflow-task {feature}` 命令继续工作（向后兼容）

**验证方法**: 使用现有 plan.md 测试生成 tasks.md，确认 workflow-implement 可正常读取

### NFR-4: 优先级分配策略

任务优先级按以下规则自动分配：

| 优先级 | 条件 | 说明 |
|--------|------|------|
| P0 | 关键路径上的阻塞任务 | 阻塞其他多个任务 |
| P1 | 核心业务逻辑任务 | 实现主要功能 |
| P2 | 辅助功能任务 | 非核心但必需 |
| P3 | 优化和文档任务 | 可延后执行 |

用户可在 VALIDATE 阶段覆盖自动分配的优先级。

---

## 5. 输出结构

```
.workflow/{feature}/task/
├── tasks.md                    # 主任务文档
├── analysis/
│   ├── dag.md                  # 依赖关系图
│   └── critical-path.md        # 关键路径分析
├── reviews/
│   └── round-{N}/
│       ├── review-prompt.md    # 审查提示
│       └── review-response.md  # 审查结果
└── .state.yaml                 # 状态文件
```

---

## 6. 验收清单

- [ ] SKILL.md 包含完整的 6 阶段说明
- [ ] 每阶段有明确的输入、输出、动作
- [ ] 包含与 workflow-plan 相似的流程图
- [ ] 资源文件创建完成（assets/, references/, scripts/）
- [ ] 命令接口文档完整
- [ ] 任务粒度检测功能说明
- [ ] REVIEW 阶段使用 Task 工具的说明
- [ ] 状态管理和断点恢复说明
- [ ] 与上下游的集成说明清晰

---

## 7. 范围外（Out of Scope）

1. 与 task-planner skill 合并
2. 支持多种输出格式（仅 Markdown）
3. 直接从需求生成任务（需先 specify→plan）
4. 任务执行功能（属于 workflow-implement）
5. 与外部项目管理工具集成（Jira、Linear 等）

---

## 8. 风险与假设

### 风险

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| plan.md 格式不一致 | 解析失败 | 在 PARSE 阶段添加格式验证 |
| 任务粒度估算不准确 | 警告误报 | 允许用户在 VALIDATE 阶段覆盖 |
| 审查循环过多 | 流程卡住 | 限制最多 3 轮 |

### 假设

1. plan.md 已经通过 workflow-plan 生成并 approved
2. 用户熟悉 workflow 流程的基本概念
3. 项目环境支持运行 bash 脚本

---

## 9. 附录

### A. 术语表

| 术语 | 定义 |
|------|------|
| DAG | Directed Acyclic Graph，有向无环图 |
| 关键路径 | 任务依赖图中最长的执行路径 |
| TDD | Test-Driven Development，测试驱动开发 |
| [T] 标记 | 需要先写测试再实现的任务 |
| [P] 标记 | 可与其他 [P] 任务并行执行 |
| [R] 标记 | 完成后需要人工审查 |

### B. 参考文档

- workflow-plan SKILL.md（结构参考）
- workflow-specify SKILL.md（流程参考）
- task-planner SKILL.md（边界对比）
