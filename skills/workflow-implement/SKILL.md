---
name: workflow-implement
description: 按任务列表执行代码实现。读取 tasks.md，按拓扑顺序执行任务，支持 TDD 模式和并行执行。当用户想要"执行任务"、"开始实现"、"写代码"时使用。也响应 "workflow implement"、"工作流实现"。
---

# Implement Skill 指南

## 概述

按照任务列表（tasks.md）逐个执行实现任务，支持 TDD 模式、并行执行和原子提交。

**核心价值**：将任务计划转化为实际代码，确保测试驱动和质量可控。

---

## 工作流程

```
读取 tasks.md → 构建 DAG → 拓扑排序 → 执行任务 → 更新状态
```

### 阶段 1: 任务加载

**动作**:
1. 读取 `.workflow/{feature}/task/tasks.md`
2. 解析任务列表和依赖关系
3. 构建 DAG（有向无环图）

### 阶段 2: 执行计划

**动作**:
1. 拓扑排序确定执行顺序
2. 识别可并行任务批次
3. 计算关键路径

### 阶段 3: 任务执行

**动作**:
1. 按批次执行任务
2. `[T]` 任务先写测试再实现
3. `[P]` 任务使用 Task 工具并行执行
4. 每个任务完成后运行测试

### 阶段 4: 状态更新

**动作**:
1. 更新 tasks.md 中的任务状态
2. 记录执行日志
3. 原子提交（每任务一个 commit）

**输出**: `.workflow/{feature}/implement/logs/`

---

## 命令

```bash
# 基本用法
/workflow-implement {feature}

# 执行单个任务
/workflow-implement {feature} --task={task-id}

# 恢复执行
/workflow:implement --resume {feature}

# 重试失败任务
/workflow:implement --retry {feature}

# 并行任务数限制
/workflow-implement {feature} --parallel=3
```

---

## 输出结构

```
.workflow/{feature}/implement/
├── logs/
│   ├── T1.log           # 任务执行日志
│   ├── T2.log
│   └── summary.md       # 执行摘要
└── commits/
    └── commit-log.md    # 提交记录
```

---

## 任务状态

| 状态 | 标记 | 说明 |
|------|------|------|
| 待执行 | `[ ]` | 任务尚未开始 |
| 进行中 | `[~]` | 任务正在执行 |
| 已完成 | `[x]` | 任务成功完成 |
| 失败 | `[!]` | 任务执行失败 |
| 跳过 | `[-]` | 任务被跳过 |

---

## TDD 模式

对于 `[T]` 标记的任务：

1. **写测试**: 先编写单元测试
2. **验证失败**: 确认测试失败（红灯）
3. **实现代码**: 编写实现代码
4. **验证通过**: 确认测试通过（绿灯）
5. **重构**: 可选的代码重构

---

## 并行执行

对于 `[P]` 标记的任务：

```python
# 伪代码示例
parallel_tasks = [t for t in ready_tasks if '[P]' in t.markers]

for task in parallel_tasks:
    Task(
        prompt=f"执行任务: {task.description}",
        subagent_type="general-purpose",
        description=f"实现 {task.id}"
    )
```

最大并行数：5（避免资源竞争）

---

## 失败处理

| 策略 | 条件 | 动作 |
|------|------|------|
| 重试 | 临时错误（网络、资源） | 重新执行该任务 |
| 跳过 | 非关键任务失败 | 依赖该任务的后续任务也被跳过 |
| 中止 | 关键任务失败 或 连续失败 3 次 | 停止执行，提示用户 |

---

## 集成

- **输入**: `/workflow-task` 生成的 `tasks.md`
- **输出**: 代码变更，供 `/workflow-review` 审查

---

*待完整实现*
