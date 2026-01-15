# Clarified Requirements: workflow-task 完善

## 澄清时间
2026-01-15

## 已确认决策

| # | 问题 | 决策 | 理由 |
|---|------|------|------|
| 1 | REVIEW 阶段 | ✅ 添加 REVIEW 阶段 | 与 workflow-specify/plan 保持一致，确保任务分解质量 |
| 2 | 边界定位 | workflow-task 专注 plan→tasks | 清晰的职责边界，task-planner 作为独立通用工具 |
| 3 | 粒度检测 | ✅ 自动检测并警告 | 帮助用户识别过大或过小的任务 |
| 4 | 完善程度 | 完整重构 | 达到与 workflow-plan 相同的完整度 |

## 功能边界澄清

### workflow-task 职责
- **输入**: workflow-plan 生成的 `plan.md`
- **输出**: 供 workflow-implement 使用的 `tasks.md`
- **定位**: workflow 流程中的任务分解环节
- **特点**: 严格遵循 plan.md 的架构设计

### task-planner 职责
- **输入**: 任意需求描述
- **输出**: 独立的任务规划文档（main-plan.md + tasks.md）
- **定位**: 通用的任务规划工具
- **特点**: 从零开始进行模块化和时序化分解

### 关键差异
| 维度 | workflow-task | task-planner |
|------|--------------|--------------|
| 输入来源 | 必须有 plan.md | 任意描述 |
| 输出位置 | .workflow/{feature}/task/ | .tasks/{task-name}/ |
| 流程定位 | workflow 链条中的一环 | 独立工具 |
| 重点 | 任务分解和调度 | 模块化设计 + 任务分解 |

## 确认的需求范围

### 必须实现（In Scope）
1. 扩展为 6 阶段工作流程（对齐 workflow-plan）
2. 添加 REVIEW 阶段（独立 Agent 审查）
3. 添加 VALIDATE 阶段（用户确认）
4. 任务粒度自动检测和警告
5. 完整的资源文件（模板、脚本、参考文档）
6. 状态管理（.state.yaml）
7. 详细的阶段说明和输出规范

### 不实现（Out of Scope）
1. 与 task-planner 合并
2. 多种输出格式支持
3. 直接从需求生成任务（需先经过 specify→plan）
4. 任务执行功能（属于 workflow-implement）

## 消除的歧义

| 原始表述 | 澄清后 |
|----------|--------|
| "完善 workflow-task" | 达到与 workflow-plan 相同的完整度，包括 6 阶段、审查机制、资源文件 |
| "任务分解" | 将 plan.md 中的模块和架构转化为具体可执行的任务列表，而非从零设计 |
| "支持 TDD" | 标记 `[T]` 的任务在 workflow-implement 中先写测试再实现 |

## 下一步
进入 STRUCTURE 阶段，生成正式的 spec.md
