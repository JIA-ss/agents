# Workflow Skills 审查方式选择增强

## 概述

本次修改为所有 `workflow-*` skills 添加了**用户可选的审查方式**功能。在每个 workflow skill 开始执行时，会让用户选择使用哪种审查方式来进行质量检查。

## 影响的 Skills

本次修改影响以下 5 个 workflow skills：

1. `workflow-specify` - 需求规范化
2. `workflow-plan` - 技术计划制定
3. `workflow-task` - 任务分解
4. `workflow-implement` - 代码实现
5. `workflow-review` - 代码审查

## 修改内容

### 1. 立即行动阶段

在每个 skill 的"立即行动"阶段，新增了**审查方式选择步骤**：

```markdown
**询问用户审查方式**：使用 AskUserQuestion 让用户选择:
   - **选项 1: Codex 审查**（推荐）- 使用 /codex skill 进行高质量审查
   - **选项 2: 独立 Agent 审查** - 使用 Task 工具启动独立审查 Agent
```

此选择会在开始执行时立即进行，并记录到 `.state.yaml` 中供后续审查阶段使用。

### 2. REVIEW 阶段

在每个 skill 的审查阶段，根据用户选择执行对应的审查方式：

#### Codex 审查方式
```markdown
**Codex 审查**: 使用 Skill 工具调用 `/codex` skill，传递相应的文档路径
```

#### 独立 Agent 审查方式
```markdown
**独立 Agent 审查**: 使用 Task 工具启动独立审查 Agent
```

## 审查方式对比

| 特性 | Codex 审查 | 独立 Agent 审查 |
|------|-----------|----------------|
| **推荐度** | ⭐⭐⭐⭐⭐（推荐） | ⭐⭐⭐ |
| **审查质量** | 高质量，专业化 | 标准质量 |
| **执行速度** | 快速 | 中等 |
| **资源消耗** | 低 | 中等 |
| **适用场景** | 所有场景 | 需要自定义审查逻辑 |

## 各 Skill 审查点

### workflow-specify
- **审查对象**: spec.md
- **审查内容**: 用户故事格式、验收标准、NFR、无技术实现越界

### workflow-plan
- **审查对象**: analysis.md, research.md (REVIEW-1), plan.md (REVIEW-2)
- **审查内容**:
  - REVIEW-1: FR/NFR 覆盖度、调研完整性、决策点结论
  - REVIEW-2: 架构覆盖度、技术选型一致性、风险评估、ADR、无实施细节越界

### workflow-task
- **审查对象**: tasks.md
- **审查内容**: 任务完整性、粒度合理性、依赖正确性

### workflow-implement
- **审查对象**: 代码变更、测试结果、lint 结果
- **审查内容**: 代码质量、测试通过率、lint 合规性

### workflow-review
- **审查对象**: 测试结果、lint 结果、代码变更
- **审查内容**: 五维度检查（代码质量、测试覆盖、规范合规、安全检查、性能检查）

## 实现细节

### 状态记录

审查方式选择会记录到每个 workflow 阶段的 `.state.yaml` 中：

```yaml
review_method: codex  # 或 agent
```

### AskUserQuestion 调用示例

```json
{
  "questions": [
    {
      "question": "请选择审查方式（推荐使用 Codex 审查获得更高质量）",
      "header": "审查方式",
      "multiSelect": false,
      "options": [
        {
          "label": "Codex 审查（推荐）",
          "description": "使用 /codex skill 进行高质量专业化审查，速度快、资源消耗低"
        },
        {
          "label": "独立 Agent 审查",
          "description": "使用 Task 工具启动独立审查 Agent，适合需要自定义审查逻辑的场景"
        }
      ]
    }
  ]
}
```

## 向后兼容性

- ✅ 不影响现有工作流程
- ✅ 用户可在每次执行时自由选择
- ✅ 默认推荐 Codex 审查
- ✅ 两种方式审查标准一致

## 优势

1. **灵活性**: 用户可根据场景选择最合适的审查方式
2. **质量提升**: Codex 审查提供更专业的质量检查
3. **资源优化**: Codex 审查资源消耗更低
4. **用户友好**: 在开始时一次性选择，后续自动应用

## 测试建议

1. 测试每个 workflow skill 的审查方式选择交互
2. 验证两种审查方式都能正常工作
3. 确认审查结果格式一致性
4. 检查 `.state.yaml` 中的记录是否正确

## 后续优化方向

1. 支持全局默认审查方式配置
2. 支持审查方式的中途切换
3. 增加审查方式性能统计和对比
4. 支持混合审查模式（关键阶段使用 Codex，其他使用 Agent）

---

**修改完成时间**: 2026-01-27
**修改文件数量**: 5 个 SKILL.md 文件
**影响范围**: workflow-specify, workflow-plan, workflow-task, workflow-implement, workflow-review
