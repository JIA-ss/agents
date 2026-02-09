# Skill 生命周期管理规则

本文档定义 Skill 从创建到废弃的全生命周期管理规范，确保 Skill 体系在长期演进中保持高质量和可维护性。

---

## 1. Skill 创建标准

并非所有知识都需要封装为 Skill。创建新 Skill 前，必须满足以下三个条件：

### 1.1 准入条件

| 条件 | 说明 | 反例 |
|------|------|------|
| **存在独立的功能域** | 该 Skill 覆盖一个明确、可界定的技术领域或系统模块，与现有 Skill 的职责边界清晰 | 仅涉及某个函数的用法说明，不构成独立功能域 |
| **预计会被多次修改** | 对应的代码/配置会随项目演进持续变更，Skill 需要随之同步更新 | 一次性脚本、临时工具、不再维护的遗留模块 |
| **有足够的领域知识值得沉淀** | 包含非显而易见的架构决策、常见陷阱、调优经验等，值得作为团队知识资产保留 | 标准库的简单封装、无特殊约束的 CRUD 操作 |

### 1.2 创建流程

```
1. 确认满足上述三个准入条件
2. 检查现有 Skill 索引，排除职责重叠（Reference Files 重叠不超过 50%）
3. 使用 SKILL.template.md 模板创建 SKILL.md
4. 填写 frontmatter（name, description, related-skills 等）
5. 完成必选章节（Overview, Core Rules, Reference Files）
6. 在 CLAUDE.local.md 的 Skill 索引表中注册
7. 提交代码并记录到 changelog
```

### 1.3 创建检查清单

- [ ] 功能域边界明确，与现有 Skill 无大面积重叠
- [ ] 包含至少 3 条 Core Rules
- [ ] Reference Files 路径准确且有注释
- [ ] frontmatter 的 description 符合编写规范（200-500 字符，含动作短语和领域术语）
- [ ] 已在 CLAUDE.local.md 注册

---

## 2. 废弃流程

当 Skill 不再适用（功能下线、被新 Skill 取代、领域合并等），需要按以下流程正式废弃。

### 2.1 废弃步骤

```
Step 1: 标记废弃
  - 在 SKILL.md 的 frontmatter 中设置 deprecated: true
  - 填写 superseded-by 字段，指向替代 Skill 的 name
  - 在 SKILL.md 正文顶部添加废弃提示块

Step 2: 更新引用
  - 修改 CLAUDE.local.md 中 Skill 索引表，标注 [已废弃]
  - 检查其他 Skill 的 related-skills 字段，移除或更新引用
  - 更新所有文档中对该 Skill 的引用链接

Step 3: 保留与归档
  - 保留废弃 Skill 文件至少一个版本周期（通常为一个大版本或一个季度）
  - 保留期满后，将 Skill 目录移至归档位置（如 .claude/skills/_archived/）
  - 归档后从 CLAUDE.local.md 索引中移除
```

### 2.2 frontmatter 变更示例

**废弃前：**

```yaml
---
name: old-render-pipeline
description: >
  旧版渲染管线专家。Use when the user asks to "configure rendering",
  "debug pipeline", mentions "OldPipelineManager", "LegacyRenderer".
related-skills: [lighting-expert, post-processing]
deprecated: false
superseded-by: ""
---
```

**废弃后：**

```yaml
---
name: old-render-pipeline
description: >
  [已废弃] 旧版渲染管线专家。Use when the user asks to "configure rendering",
  "debug pipeline", mentions "OldPipelineManager", "LegacyRenderer".
related-skills: [lighting-expert, post-processing]
deprecated: true
superseded-by: "new-render-pipeline"
---
```

同时在正文顶部添加：

```markdown
> **[已废弃]** 此 Skill 已废弃，请使用 [new-render-pipeline](../new-render-pipeline/SKILL.md) 替代。
```

---

## 3. 废弃引用检测规则 (AC-4.5)

AI 在加载 Skill 时必须执行废弃检测，具体行为如下：

### 3.1 检测逻辑

```
当 AI 加载任意 SKILL.md 时：
  1. 读取 frontmatter 中的 deprecated 字段
  2. 如果 deprecated: true：
     a. 向用户提示："此 Skill 已废弃"
     b. 读取 superseded-by 字段
     c. 如果 superseded-by 非空：
        - 提示："请使用替代 Skill: {superseded-by}"
        - 自动加载替代 Skill 继续执行任务
     d. 如果 superseded-by 为空：
        - 提示："此 Skill 已废弃且无替代方案，请评估是否仍需使用"
        - 等待用户决策
  3. 如果 deprecated: false 或字段不存在：
     - 正常加载，无额外提示
```

### 3.2 提示格式

```
[Skill 废弃提示] "old-render-pipeline" 已标记为废弃。
替代 Skill: "new-render-pipeline"
正在自动加载替代 Skill...
```

---

## 4. 合并规则

当两个 Skill 的职责高度重叠时，应将其合并以避免维护负担和知识碎片化。

### 4.1 触发条件

当满足以下条件时，触发合并评估：

- **Reference Files 重叠超过 50%**：两个 Skill 的 Reference Files 章节中，指向相同文件的条目超过各自总数的 50%
- **功能域边界模糊**：用户无法明确判断某类问题应查阅哪个 Skill
- **Core Rules 存在矛盾**：两个 Skill 对同一行为给出了不同的指导

### 4.2 合并方式

```
Step 1: 评估
  - 对比两个 Skill 的 Reference Files，计算重叠比例
  - 对比 Core Rules，识别矛盾点和互补点
  - 确定"主 Skill"（保留）和"副 Skill"（被合并）

Step 2: 选择主 Skill
  - 优先保留内容更完善、覆盖面更广的 Skill
  - 如果难以判断，优先保留创建时间更早、维护记录更丰富的 Skill

Step 3: 内容迁移
  - 将副 Skill 中独有的 Core Rules 迁入主 Skill
  - 将副 Skill 中独有的 Reference Files 迁入主 Skill
  - 将副 Skill 中独有的 Workflow / Best Practices / Common Issues 迁入主 Skill
  - 合并 description 中的触发词，确保覆盖两者的触发场景

Step 4: 废弃副 Skill
  - 按照第 2 节废弃流程处理副 Skill
  - superseded-by 指向主 Skill 的 name
```

### 4.3 frontmatter 变更示例（合并场景）

**主 Skill（合并后更新）：**

```yaml
---
name: unified-pipeline
description: >
  统一渲染管线专家，涵盖前向渲染和延迟渲染。
  Use when the user asks to "configure forward rendering",
  "debug deferred pipeline", "optimize draw calls",
  mentions "ForwardRenderer", "DeferredRenderer", "PipelineManager".
  Also responds to "配置渲染管线", "优化渲染", "调试管线".
related-skills: [lighting-expert, post-processing]
deprecated: false
superseded-by: ""
---
```

**副 Skill（合并后废弃）：**

```yaml
---
name: deferred-pipeline
description: >
  [已废弃 - 已合并至 unified-pipeline] 延迟渲染管线专家。
related-skills: []
deprecated: true
superseded-by: "unified-pipeline"
---
```

---

## 5. 合并冲突裁决流程 (AC-4.6)

合并过程中可能出现内容冲突（例如两个 Skill 对同一参数给出了不同的推荐值）。此类冲突必须通过以下流程解决：

### 5.1 冲突识别与报告

```
Step 1: 生成内容差异对比报告
  - 逐章节对比两个 SKILL.md 的内容
  - 标记以下类型的冲突：
    a. 规则冲突：同一行为，两个 Skill 给出矛盾指导
    b. 参数冲突：同一参数，推荐值不同
    c. 流程冲突：同一场景，工作流步骤不同
  - 输出对比报告格式见 5.2
```

### 5.2 差异对比报告格式

```markdown
## Skill 合并差异对比报告

**主 Skill**: {主 Skill name}
**副 Skill**: {副 Skill name}
**对比日期**: {YYYY-MM-DD}

### Reference Files 重叠分析

| 文件路径 | 主 Skill | 副 Skill | 状态 |
|----------|----------|----------|------|
| path/to/file1 | 包含 | 包含 | 重叠 |
| path/to/file2 | 包含 | 不包含 | 仅主 |
| path/to/file3 | 不包含 | 包含 | 待迁入 |

**重叠率**: {X}%

### 冲突点清单

#### 冲突 1: {冲突描述}
- **主 Skill 内容**: {内容摘要}
- **副 Skill 内容**: {内容摘要}
- **冲突类型**: 规则冲突 / 参数冲突 / 流程冲突
- **裁决结果**: [待人工审批]

#### 冲突 2: ...

### 可直接合并的内容

- {副 Skill 独有内容 1}
- {副 Skill 独有内容 2}
```

### 5.3 人工审批

```
Step 2: 人工审批冲突点
  - 将差异对比报告提交给用户/维护者
  - 对每个冲突点，由人工选择：
    a. 采用主 Skill 的内容
    b. 采用副 Skill 的内容
    c. 重新编写合并内容
  - 所有冲突点必须逐一确认，不可跳过
```

### 5.4 记录合并结果

```
Step 3: 记录到 changelog
  - 在主 Skill 的 .evolution/changelog.md 中记录合并事件
  - 格式：

    ## [YYYY-MM-DD] 合并 {副 Skill name}

    ### 合并原因
    - Reference Files 重叠率: {X}%
    - {补充原因}

    ### 迁入内容
    - {从副 Skill 迁入的内容清单}

    ### 冲突裁决记录
    - 冲突 1: {描述} -> 采用 {哪方} 的内容，原因: {原因}
    - 冲突 2: ...

    ### 废弃的 Skill
    - {副 Skill name}: 已标记 deprecated: true, superseded-by: "{主 Skill name}"
```

---

## 6. 定期审计清单

在 **大版本发布前** 或 **每季度** 执行一次 Skill 体系审计，确保整体质量。

### 6.1 审计时机

| 触发条件 | 说明 |
|----------|------|
| 大版本发布前 | Release 分支切出后、正式发布前执行 |
| 每季度末 | Q1/Q2/Q3/Q4 最后一周执行 |
| Skill 数量超过阈值 | 新增 Skill 累计超过 10 个时触发一次额外审计 |

### 6.2 审计检查项

```markdown
## Skill 定期审计清单

**审计日期**: {YYYY-MM-DD}
**审计人**: {姓名}
**Skill 总数**: {N}

### 一、完整性检查

- [ ] 所有 Skill 的 SKILL.md 包含必选章节（Overview, Core Rules, Reference Files）
- [ ] 所有 Skill 的 frontmatter 字段完整且格式正确
- [ ] 所有 Skill 已在 CLAUDE.local.md 的索引表中注册
- [ ] description 长度在 200-500 字符之间，包含中英文触发词

### 二、准确性检查

- [ ] Reference Files 中的路径全部有效（文件未被删除或移动）
- [ ] Core Rules 与当前代码实现一致（无过时规则）
- [ ] Workflow 步骤与当前架构匹配
- [ ] 示例代码可正常运行

### 三、冗余检查

- [ ] 任意两个 Skill 的 Reference Files 重叠率不超过 50%
- [ ] 无功能域完全相同的重复 Skill
- [ ] 废弃 Skill（deprecated: true）是否已超过保留期，需要归档

### 四、健康度检查

- [ ] 每个 Skill 在过去一个季度内至少被更新过一次（否则标记为"待评估"）
- [ ] changelog 记录与实际代码变更一致
- [ ] related-skills 引用的目标 Skill 均存在且未废弃

### 五、审计结论

| 类别 | 通过数 | 问题数 | 待处理项 |
|------|--------|--------|----------|
| 完整性 | {n}/{total} | {n} | {待处理描述} |
| 准确性 | {n}/{total} | {n} | {待处理描述} |
| 冗余性 | {n}/{total} | {n} | {待处理描述} |
| 健康度 | {n}/{total} | {n} | {待处理描述} |

### 六、后续行动

- [ ] {行动项 1}: {负责人}, 截止日期: {YYYY-MM-DD}
- [ ] {行动项 2}: {负责人}, 截止日期: {YYYY-MM-DD}
```

---

## 7. 生命周期状态总览

以下是 Skill 从创建到归档的完整生命周期状态图：

```
[评估] --> [创建] --> [活跃] --> [废弃] --> [归档]
                        |          ^
                        |          |
                        +--[合并]--+
```

| 状态 | frontmatter 标记 | 说明 |
|------|------------------|------|
| 活跃 | `deprecated: false` | 正常使用和维护 |
| 废弃 | `deprecated: true`, `superseded-by: "{name}"` | 已有替代方案，保留一个版本周期 |
| 归档 | 文件移至 `_archived/` | 保留期满，从索引中移除 |

---

**最后更新**: 2026-02-09
**版本**: 1.0
**维护者**: SDD 团队
