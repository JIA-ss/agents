# Task Specification: Implement /specify Skill

## Task ID
`specify-skill-impl-20260113`

## Objective
基于 specify-phase-design-20260113 设计文档，使用 skill-generator 实现 /specify skill。

## Context
- 依赖设计: `specify-phase-design-20260113` (已完成，PASS)
- 使用工具: skill-generator skill

## Deliverables

1. **SKILL.md** - 主 skill 文件
   - 符合 skill-generator 规范
   - 包含四阶段工作流
   - 支持 mini/standard/full 模式

2. **Assets**
   - spec-template.md - 完整模板
   - spec-mini.md - 精简模板

3. **References**
   - phase-details.md - 阶段详细文档

4. **Scripts**
   - validate-spec.sh - spec 验证脚本

## Success Criteria
- [ ] SKILL.md 通过 validate-skill.sh 验证
- [ ] 模板包含设计文档中定义的所有章节
- [ ] 验证脚本可执行
- [ ] 通过 Codex 独立审查

---
*Created: 2026-01-13*
