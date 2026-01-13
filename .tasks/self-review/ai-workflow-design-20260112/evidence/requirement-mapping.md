# Requirement Mapping

## Design Objectives Mapping

| 目标 | 状态 | 交付物 |
|------|------|--------|
| 工作流阶段划分 | COMPLETE | workflow-design.md Section 2 |
| 目录结构设计 | COMPLETE | workflow-design.md Section 3 |
| 核心配置文件 | COMPLETE | templates/*.yaml, templates/*.md |
| 与现有 skills 集成 | COMPLETE | workflow-design.md Section 5 |

## Deliverables

| 文件 | 描述 | 状态 |
|------|------|------|
| workflow-design.md | 完整设计文档 | Complete |
| templates/spec.md | 规范模板 | Complete |
| templates/plan.md | 计划模板 | Complete |
| templates/tasks.md | 任务模板 | Complete |
| templates/config.yaml | 配置文件模板 | Complete |
| templates/constitution.md | 项目原则模板 | Complete |
| templates/CLAUDE.md | Claude 配置模板 | Complete |

## Design Principles Applied

| 原则 | 体现 |
|------|------|
| Spec-First | 5 阶段模型以 SPECIFY 开始 |
| TDD | tasks.md 中 [T] 标记支持测试优先 |
| Human-in-Loop | checkpoints 配置支持人工审批 |
| Traceable | .tasks/ 目录记录完整执行历史 |
| Tool-Agnostic | 支持 Codex, Claude 等多种引擎 |

## Integration Points

| 现有 Skill | 集成方式 |
|-----------|----------|
| /self-review | REVIEW 阶段调用 |
| /task-planner | SPECIFY 阶段可用 |
| /research | PLAN 阶段可用 |
| /codex | IMPLEMENT 阶段可用 |
