# Task Specification: Refactor Skill Generator

## Metadata
- **Task ID**: refactor-skill-generator
- **Created**: 2026-01-13
- **Type**: Implementation

## Objective

根据 Claude Code Skill 最佳实践研究结果，重构 skill-generator skill，使其完全符合官方规范。

## Current State Analysis

### 问题识别

1. **description 格式不完全合规**
   - 缺少 "做什么" 和 "何时使用" 的清晰分离
   - 缺少更多具体的触发场景

2. **缺少 Progressive Disclosure 架构**
   - 没有 references/ 目录
   - 没有 scripts/ 目录
   - 所有内容都在 SKILL.md 中

3. **缺少官方推荐的核心内容**
   - 缺少 Degrees of Freedom 概念
   - 缺少评估驱动开发流程
   - 缺少迭代改进指南

4. **Quality Checklist 不完整**
   - 未包含官方规范中的限制（name max 64, description max 1024）
   - 未包含禁止内容规则
   - 未包含路径规范

## Success Criteria

- [ ] SKILL.md <500 行（官方建议）
- [ ] description 包含 "做什么" AND "何时使用"
- [ ] 实现 Progressive Disclosure 架构
- [ ] 包含完整的官方规范限制
- [ ] 包含初始化脚本和验证脚本
- [ ] 包含详细参考文档（references/）
- [ ] 包含评估驱动开发流程

## Scope

- 重构 SKILL.md 主文件
- 创建 scripts/init-skill.sh
- 创建 scripts/validate-skill.sh
- 创建 references/spec-reference.md
- 创建 references/best-practices.md
