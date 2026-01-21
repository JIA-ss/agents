---
name: task-planner
description: 将复杂大型任务进行系统性规划和拆分，通过模块化和时序化分解，输出结构化的任务规划文档。当用户要求"任务规划"、"拆分任务"、"创建任务计划"、"需求分解"、"模块化规划"，或提到"任务分解"、"项目规划"时使用。也响应 "plan a task", "break down project", "create task plan"。
---

# Task Planner

系统性任务规划：UNDERSTAND → MODULAR → SEQUENTIAL → DEPEND → DOCUMENT → CONFIRM

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户输入，提取任务目标和约束
2. 评估任务复杂度
3. 创建目录：`.tasks/{task-name}/`
4. 开始 Phase 1: UNDERSTAND

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: UNDERSTAND → 理解任务目标和范围
- [ ] Phase 2: MODULAR → 模块化分解（3-7 个模块）
- [ ] Phase 3: SEQUENTIAL → 时序化分解（执行阶段）
- [ ] Phase 4: DEPEND → 依赖分析和关键路径
- [ ] Phase 5: DOCUMENT → 生成规划文档
- [ ] Phase 6: CONFIRM → 用户确认
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| UNDERSTAND | 目标和范围已明确 | → MODULAR |
| MODULAR | 模块已识别 | → SEQUENTIAL |
| SEQUENTIAL | 阶段已划分 | → DEPEND |
| DEPEND | 依赖已分析 | → DOCUMENT |
| DOCUMENT | 文档已生成 | → CONFIRM |
| CONFIRM | 用户已确认 | → 结束 |

---

## Phase 详情

### Phase 1: UNDERSTAND（理解任务）

**你必须：**
1. 解析任务目标和预期产出
2. 识别约束条件（技术栈、时间、资源）
3. 评估复杂度（低/中/高）
4. 确定分解深度（2-4 层）

**完成标志**: 目标和范围已明确

---

### Phase 2: MODULAR（模块化分解）

**你必须：**
1. 按单一职责原则识别核心模块（3-7 个）
2. 为每个模块定义：
   - 职责边界
   - 输入/输出
   - 对外接口
3. 生成 Mermaid 组件图
4. 对复杂模块递归应用四步法则（深度 2-3 层）

**四步法则**:
1. Summarize - 概括性介绍
2. Visualize - 先 Mermaid 图，后文字
3. Decompose - 拆分为更小单元
4. Recurse - 对复杂子系统重复

**完成标志**: 模块已识别

---

### Phase 3: SEQUENTIAL（时序化分解）

**你必须：**
1. 划分执行阶段
2. 为每个阶段定义目标和产出
3. 识别并行机会
4. 标注关键路径
5. 生成 Mermaid 甘特图或流程图

**完成标志**: 阶段已划分

---

### Phase 4: DEPEND（依赖分析）

**你必须：**
1. 整合模块依赖和任务依赖
2. 构建依赖 DAG
3. 检测循环依赖
4. 计算关键路径
5. 验证任务粒度（30min-8h）

**完成标志**: 依赖已分析

---

### Phase 5: DOCUMENT（生成文档）

**你必须：**
1. 生成 `main-plan.md`：
   - 任务目标
   - 整体架构（Mermaid）
   - 模块概览
   - 执行阶段
   - 关键路径
   - 约束与风险
2. 生成 `tasks.md`：
   - 任务总览（甘特图）
   - 任务清单（按阶段分组）
   - 依赖关系图
   - 验收标准
3. 为复杂模块生成 `module-{name}.md`

**完成标志**: 文档已生成

---

### Phase 6: CONFIRM（用户确认）

**你必须：**
1. 展示规划摘要
2. 展示关键 Mermaid 图
3. 通过 AskUserQuestion 确认：
   - 模块划分合理性
   - 执行顺序正确性
   - 依赖关系完整性
4. 收集反馈，优化规划

**完成标志**: 用户已确认

---

## 输出结构

```
.tasks/{task-name}/
├── main-plan.md         # 主框架技术方案
├── tasks.md             # 任务编排文档
├── module-{模块1}.md    # 子模块1技术方案
└── module-{模块2}.md    # 子模块2技术方案
```

---

## 禁止内容（红线）

| 禁止 | 示例 | 替代方案 |
|------|------|----------|
| 函数代码 | `function handleLogin()` | Mermaid 类图 |
| SQL 语句 | `SELECT * FROM...` | ER 图 + 描述 |
| 配置文件 | `package.json` 内容 | 技术栈清单 |
| API 调用 | `axios.get('/api/user')` | 接口表 |

---

## 约束

- 分解深度：2-4 层（避免过度拆分）
- 任务粒度：30min - 8h
- Mermaid 图复杂度：≤15 节点
- 可视化优先，先图后文
