# Raw Notes: workflow-task 完善需求

## 捕获时间
2026-01-15

## 项目上下文

### 现有 Workflow 流程
```
workflow-specify → workflow-plan → workflow-task → workflow-implement → workflow-review
     需求规范         技术方案         任务分解         代码实现           代码审查
```

### workflow-task 当前状态
- **位置**: `skills/workflow-task/SKILL.md`
- **状态**: 基础框架已定义，标注为"待完整实现"
- **行数**: 146 行（相对简单）

### 现有内容分析

**已定义**:
1. 4 阶段工作流程（计划分析→任务分解→依赖分析→输出生成）
2. 基本命令格式（/workflow-task {feature}）
3. 任务标记系统（[T]测试先行、[P]可并行、[R]需审查）
4. tasks.md 基础模板
5. 任务粒度约束（30分钟-8小时）
6. 与上下游的集成关系

**缺失/待完善**:
1. 详细的阶段说明（类似 workflow-plan 的详细程度）
2. 审查机制（REVIEW 阶段）
3. 验证阶段（VALIDATE）
4. 状态管理（.state.yaml）
5. 资源文件（assets/、references/、scripts/）
6. 错误处理和边界情况
7. 与 task-planner skill 的关系说明

## 相关 Skills 对比

| Skill | 阶段数 | 有审查 | 有验证 | 完整度 |
|-------|--------|--------|--------|--------|
| workflow-specify | 5 | ✅ | ✅ | 高 |
| workflow-plan | 6 | ✅✅ | ✅ | 高 |
| workflow-task | 4 | ❌ | ❌ | 低 |
| workflow-implement | 4 | ❌ | ❌ | 中 |
| workflow-review | 4 | ✅ | ❌ | 中 |

## 利益相关者
- **用户**: 需要将技术方案转化为可执行任务的开发者
- **上游**: workflow-plan 提供 plan.md
- **下游**: workflow-implement 消费 tasks.md

## 原始需求提取

### 功能性需求 (FR)
1. 完善阶段定义，增加 REVIEW 和 VALIDATE 阶段
2. 添加详细的动作说明和输出规范
3. 添加资源文件（模板、脚本、参考文档）
4. 与 task-planner 的功能边界清晰化
5. 支持增量任务生成（已有任务时的处理）
6. 支持任务优先级自动计算

### 非功能性需求 (NFR)
1. 与其他 workflow-* skills 保持一致的结构和风格
2. 文档格式遵循现有规范
3. 命令格式与其他 workflow 命令保持一致

### 约束条件
1. 必须与现有的 workflow 流程兼容
2. 不能破坏与 workflow-plan 和 workflow-implement 的接口
3. 保持与 task-planner 的差异化定位

## 待澄清问题

| # | 问题 | 推荐默认值 |
|---|------|------------|
| 1 | workflow-task 是否需要独立的 REVIEW 阶段？ | 是，使用独立 Agent 审查任务分解质量 |
| 2 | 是否需要支持手动任务调整？ | 是，在 VALIDATE 阶段允许用户修改 |
| 3 | task-planner 和 workflow-task 的边界如何划分？ | workflow-task 专注于 plan.md→tasks.md 转换，task-planner 是独立的任务规划工具 |
| 4 | 任务粒度是否需要自动检测和警告？ | 是，超出 30min-8h 范围时警告 |
| 5 | 是否需要支持多种输出格式？ | 否，统一使用 tasks.md |

## Ambiguity Score
3/5 - 存在一些需要澄清的边界和功能细节
