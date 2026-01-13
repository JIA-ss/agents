# Review Prompt for AI Workflow Research

## Task Context

**Task ID**: ai-workflow-research-20260112
**Task Type**: Research
**Objective**: 调研 GitHub 上类似 spec-kit 的 AI 编程工作流，从宏观到细节进行全面分析

## Deliverables to Review

1. **final-report.md** - 完整调研报告
2. **evidence/requirement-mapping.md** - 需求映射
3. **evidence/project-comparison.md** - 项目对比分析
4. **evidence/execution-manifest.json** - 执行清单

## Review Criteria

### 1. Completeness (完整性)
- [ ] 是否覆盖了宏观方法论 (TDD, Spec-driven, Multi-agent)?
- [ ] 是否分析了足够数量的核心项目 (目标: 5+)?
- [ ] 是否从宏观到细节形成完整链路?

### 2. Accuracy (准确性)
- [ ] 项目信息是否准确?
- [ ] GitHub 链接是否有效?
- [ ] 技术描述是否正确?

### 3. Actionability (可操作性)
- [ ] 是否提供了具体的工具推荐?
- [ ] 是否给出了架构模式?
- [ ] 对用户搭建自己的工作流是否有帮助?

### 4. Organization (组织性)
- [ ] 报告结构是否清晰?
- [ ] 分类是否合理?
- [ ] 是否易于导航和查阅?

## Expected Output

请按以下格式提供审查结果：

```yaml
verdict: PASS | NEEDS_IMPROVEMENT | REJECTED
confidence: 0.0-1.0

issues:
  - severity: BLOCKER|CRITICAL|MAJOR|MINOR
    description: ...
    recommendation: ...

summary: |
  整体评价...
```
