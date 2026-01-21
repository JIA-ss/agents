---
name: parallel-task-planner
description: 将复杂任务智能拆解为可并行执行的子任务树，生成完整的任务文档体系。当用户要求"并行任务规划"、"优化任务执行"、"识别并行机会"、"生成任务文档"，或提到"并行执行"、"任务依赖"、"自动执行"时使用。也响应 "plan parallel tasks", "optimize task execution", "identify parallel opportunities"。
---

# Parallel Task Planner

并行任务规划与文档生成：COLLECT → ANALYZE → PLAN → DOCUMENT → CONFIRM

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户输入，提取任务描述和配置选项
2. 识别目标路径和执行模式
3. 开始 Phase 1: COLLECT

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: COLLECT → 收集任务描述、路径配置、执行选项
- [ ] Phase 2: ANALYZE → 复杂度评估、风险评估、依赖识别
- [ ] Phase 3: PLAN → 构建任务树、划分并行批次
- [ ] Phase 4: DOCUMENT → 生成任务文档体系
- [ ] Phase 5: CONFIRM → 用户确认任务拆分
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| COLLECT | 任务信息已收集完整 | → ANALYZE |
| ANALYZE | 风险和依赖已识别 | → PLAN |
| PLAN | 任务树已构建 | → DOCUMENT |
| DOCUMENT | 文档已生成 | → CONFIRM |
| CONFIRM | 用户已确认 | → 结束 |

---

## Phase 详情

### Phase 1: COLLECT（收集需求）

**你必须：**
1. 提取任务描述和目标
2. 确定输出路径（默认 `.tasks/{task-name}/`）
3. 识别配置选项：
   - 是否需要清理任务
   - 执行模式（Auto/Manual/Hybrid）
4. 如信息不完整，使用 AskUserQuestion 收集

**完成标志**: 任务信息已收集完整

---

### Phase 2: ANALYZE（任务分析）

**你必须：**
1. 评估任务复杂度（低/中/高）
2. 识别子任务及其依赖关系
3. 评估每个子任务的风险等级

**风险等级判定**:
| 风险 | 示例 | 执行模式 |
|------|------|----------|
| 低 | 文档生成、代码分析 | 自动执行 |
| 中 | 代码编写、测试执行 | 半自动（需审查） |
| 高 | 数据库操作、部署发布 | 强制人工确认 |

**完成标志**: 风险和依赖已识别

---

### Phase 3: PLAN（构建任务树）

**你必须：**
1. 按依赖关系构建 DAG
2. 检测循环依赖（如有则报错）
3. 划分并行批次：
   - 批次 1: 无依赖任务
   - 批次 2: 仅依赖批次 1 的任务
   - ...
4. 计算关键路径
5. 验证任务粒度（30min-4h）

**完成标志**: 任务树已构建

---

### Phase 4: DOCUMENT（生成文档）

**你必须：**
1. 生成 `execution-guide.md`：任务概览、Mermaid 树状图、执行策略
2. 生成 `common-context.md`：项目背景、技术栈、代码结构
3. 为每个任务生成 `task-{id}.md`：目标、验收标准、依赖、执行步骤
4. 如需自动执行，生成 `auto-execution.md`

**完成标志**: 文档已生成

---

### Phase 5: CONFIRM（用户确认）

**你必须：**
1. 展示任务树可视化（Mermaid）
2. 汇总：总任务数、批次数、关键路径
3. 通过 AskUserQuestion 确认：
   - 任务拆分合理性
   - 依赖关系正确性
   - 并行可行性

**完成标志**: 用户已确认

---

## 输出文档结构

```
.tasks/{task-name}/
├── execution-guide.md     # 执行指引
├── common-context.md      # 通用背景
├── task-{id}.md           # 各任务详情
├── auto-execution.md      # 自动执行配置（可选）
└── cleanup-task.md        # 清理任务（可选）
```

---

## 约束

- 任务粒度：30min - 4h
- 高耦合任务限制并行收益
- 并行任务不可修改同一文件
- 并行度 ≤ 可用资源数
