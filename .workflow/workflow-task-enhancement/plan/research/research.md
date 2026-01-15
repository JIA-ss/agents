# 技术调研: workflow-task-enhancement

> **调研日期**: 2026-01-15
> **超时设置**: 5 分钟

---

## 证据等级说明

| 等级  | 来源类型    | 说明        |
| --- | ------- | --------- |
| A   | 标准/官方规范 | 可信度高，优先采用 |
| B   | 维护者文档   | 可信度中高     |
| C   | 社区实践/博客 | 需交叉验证     |
| D   | 论坛观点    | 仅作参考      |
|     |         |           |

---

## 1. 调研主题

### 主题 1: workflow-plan 的审查 prompt 结构

**问题**: 如何设计 REVIEW 阶段的审查清单，保持与 workflow-plan 一致的风格？

**评价准则**: 完整性、可复用性、一致性

**调研方法**: 代码分析

**调研过程**:
1. 读取 `workflow-plan/references/review-checklist.md`
2. 分析审查清单结构和判定规则

**证据等级**: A（项目内部规范）

**置信度**: High

**结论**:
- 审查清单分为多个维度（覆盖度、完整性、质量）
- 每个维度包含具体检查项（checkbox 格式）
- 判定规则使用表格格式，包含判定、条件、动作
- 严重程度分为 BLOCKER/CRITICAL/MAJOR/MINOR 四级

**建议**: 
- 为 workflow-task 设计 3 个审查维度：任务完整性、粒度合理性、依赖正确性
- 使用相同的判定规则格式
- 复用严重程度定义

**适用范围**: REVIEW 阶段设计

**参考来源**:
- `skills/workflow-plan/references/review-checklist.md`

---

### 主题 2: workflow-plan 的 .state.yaml 完整格式

**问题**: 如何设计状态文件以支持断点恢复和回退？

**评价准则**: 完整性、可扩展性、兼容性

**调研方法**: 代码分析

**证据等级**: A（项目内部规范）

**置信度**: High

**结论**:
`.state.yaml` 完整格式包含：
```yaml
feature: {feature-id}
version: 2.0.0
phase: parse | decompose | analyze | review | refine | validate
status: in_progress | completed | failed

completed_phases:
  parse:
    completed_at: "2026-01-15T10:00:00Z"
    output: parse/parsed.md
  # ...

reviews:
  review:
    current_round: 1
    max_rounds: 3
    history:
      - round: 1
        verdict: PASS | NEEDS_IMPROVEMENT | REJECTED
        confidence: 0.92

rollbacks:
  - from: review
    to: decompose
    reason: "任务粒度不合理"
    timestamp: "2026-01-15T12:00:00Z"
```

**建议**: 
- 采用相同的 YAML 结构
- 调整 `phase` 枚举值为 workflow-task 的 6 阶段名称
- 调整 `reviews` 结构以匹配单次审查阶段（不是两次）

**适用范围**: 状态管理和断点恢复设计

**参考来源**:
- `skills/workflow-plan/references/phase-details.md`

---

### 主题 3: 现有 workflow-task 的 tasks.md 模板

**问题**: 现有模板有哪些可复用部分，需要增强什么？

**评价准则**: 完整性、可用性

**调研方法**: 代码分析

**证据等级**: A（项目内部规范）

**置信度**: High

**结论**:

**现有模板可复用部分**:
- 任务总览（甘特图）
- 任务清单表格格式（ID, 任务, 优先级, 依赖, 标记, 状态）
- 依赖关系图（Mermaid DAG）
- 关键路径显示
- 任务标记说明（[T][P][R]）

**需要增强部分**:
- 添加 frontmatter（状态、版本信息）
- 添加任务详情区（description, estimate, module）
- 添加粒度警告汇总区
- 添加需求追溯性映射（FR → Task）

**建议**: 
- 保留现有模板结构作为基础
- 在 assets/tasks-template.md 中添加增强内容
- 确保向后兼容（现有字段保留）

**适用范围**: tasks-template.md 设计

**参考来源**:
- `skills/workflow-task/SKILL.md`（现有模板部分）

---

### 主题 4: workflow-implement 消费 tasks.md 的方式

**问题**: tasks.md 需要包含哪些字段以确保 workflow-implement 正常工作？

**评价准则**: 兼容性、完整性

**调研方法**: 代码分析

**证据等级**: A（项目内部规范）

**置信度**: High

**结论**:

workflow-implement 需要从 tasks.md 获取：
1. **任务列表**: ID, 描述, 标记
2. **依赖关系**: `depends_on` 数组（用于 DAG 构建和拓扑排序）
3. **任务状态**: `[ ]` / `[x]` / `[~]` / `[!]` / `[-]` 标记
4. **标记信息**: `[T]`（TDD 模式）, `[P]`（并行执行）

**关键兼容点**:
- 任务表格必须包含 ID 列（用于定位）
- 依赖列格式：`T1, T2` 或 `-`（无依赖）
- 标记列格式：`[T]`, `[P]`, `[T][P]`
- 状态列格式：checkbox `[ ]`

**建议**: 
- 保持现有表格格式不变
- 添加的新字段（estimate, module）放在任务详情区，不影响主表格
- 确保 DAG 图和关键路径信息正确

**适用范围**: tasks.md 输出格式设计

**参考来源**:
- `skills/workflow-implement/SKILL.md`

---

### 主题 5: DAG 生成和关键路径算法

**问题**: 如何在 ANALYZE 阶段实现依赖分析和关键路径计算？

**评价准则**: 正确性、清晰性

**调研方法**: 最佳实践分析

**证据等级**: B（标准算法）

**置信度**: High

**结论**:

**DAG 生成逻辑**:
1. 从 plan.md 提取模块依赖关系
2. 将模块映射到任务
3. 推导任务间依赖（模块 A 依赖模块 B → 实现 A 的任务依赖实现 B 的任务）
4. 添加显式依赖（如测试依赖实现）

**关键路径算法**:
1. 拓扑排序所有任务
2. 计算每个任务的最早开始时间（ES）和最早结束时间（EF）
3. 反向计算最晚开始时间（LS）和最晚结束时间（LF）
4. 松弛时间 = LS - ES，松弛时间为 0 的任务在关键路径上

**循环依赖检测**:
- 使用 DFS 检测后向边
- 发现循环时报错并列出循环路径

**并行标记规则**:
- 无共同依赖且不相互依赖的任务可并行
- 同一批次内的任务标记 `[P]`

**建议**: 
- 在 ANALYZE 阶段说明中描述算法逻辑
- 提供 Mermaid DAG 图示例
- 在 references/phase-details.md 中提供详细伪代码

**适用范围**: ANALYZE 阶段设计

**参考来源**:
- 标准图算法（Kahn's algorithm, CPM）

---

## 2. 技术方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| 方案 A: 完全复制 workflow-plan 结构 | 一致性高，维护简单 | 可能有不适用的章节 | ⭐⭐ |
| 方案 B: 定制化设计（保持风格一致但内容定制） | 针对性强，内容精准 | 需要更多设计工作 | ⭐⭐⭐ |
| 方案 C: 最小化实现 | 快速完成 | 与其他 workflow-* 不一致 | ⭐ |

---

## 3. 权衡决策矩阵

| 准则 | 权重 | 方案 A | 方案 B | 说明 |
|------|------|--------|--------|------|
| 一致性 | 0.4 | 5 | 4 | A 完全复制，B 风格一致但内容定制 |
| 适用性 | 0.3 | 3 | 5 | B 针对任务分解场景定制 |
| 维护成本 | 0.3 | 4 | 3 | A 可直接参考，B 需独立维护 |
| **加权总分** | - | **4.0** | **4.0** | 持平，优先考虑适用性选 B |

**决策**: 选择 **方案 B**（定制化设计），保持章节结构和格式风格与 workflow-plan 一致，但内容针对任务分解场景定制。

---

## 4. 依赖评估

| 依赖 | 版本 | 维护状态 | 最近更新 | 风险 |
|------|------|----------|----------|------|
| workflow-plan SKILL.md | 1.0 | 活跃 | 2026-01-15 | 低 |
| workflow-implement SKILL.md | 1.0 | 待完善 | 2026-01-15 | 中（也标注待完整实现） |
| Mermaid 图表语法 | - | 稳定 | - | 低 |

---

## 5. 最佳实践

- **实践 1**: 使用 6 阶段流程（与 workflow-plan 类似但名称不同）
- **实践 2**: 单次审查阶段（REVIEW）比双审查（REVIEW-1/REVIEW-2）更适合任务分解场景
- **实践 3**: 任务粒度自动检测应作为警告而非阻塞
- **实践 4**: 保持与上下游（plan→task→implement）的格式兼容
- **实践 5**: 资源文件分离，主文档保持简洁

---

## 6. 调研结论

### 已解决的决策点

- [x] 决策点 2: REVIEW 阶段使用 3 维度审查清单（任务完整性、粒度合理性、依赖正确性）
- [x] 决策点 3: .state.yaml 格式与 workflow-plan 保持一致结构，调整阶段名称
- [x] 决策点 5: DAG 使用拓扑排序 + CPM 算法计算关键路径

### 仍需讨论的问题

- 无

### 推荐的技术选型

| 领域 | 推荐 | 理由 |
|------|------|------|
| 整体结构 | 定制化设计（方案 B） | 平衡一致性和适用性 |
| 流程设计 | 6 阶段单审查 | 符合 spec 需求，比双审查更简洁 |
| 状态管理 | YAML 格式 | 与 workflow-plan 一致 |
| 图表工具 | Mermaid | 项目标准 |

---

*Generated by workflow-plan (RESEARCH) | 2026-01-15*
