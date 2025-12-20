---
name: review-fixer
description: Use when the user asks to "fix review issues", "apply review suggestions", "auto-fix code problems", "resolve audit findings", mentions "review fixes", "batch fix", or needs to automatically fix issues identified in a code review report. Also responds to "修复审查问题", "应用审查建议", "自动修复".
---

# Review Fixer Skill Guide

## Overview

审查问题修复器是 task-code-reviewer 的配套修复工具，解析代码审查报告并结合任务规划文档，自动规划并执行代码修复。

**核心价值**：自动化修复 + 规划驱动 + 可配置范围 + 先规划后执行

## Workflow (5 Phases)

1. **Document Parsing** - 解析 Review 报告和 Plan 文档，关联分析
2. **Scope Filtering** - 根据配置参数筛选待处理问题
3. **Fix Planning** - 生成修复方案，依赖排序，用户审批
4. **Execute Fixes** - 批准后按顺序执行，验证检查
5. **Generate Report** - 输出修复摘要、变更清单、剩余问题

## Configuration Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `--type` | 只处理特定类型 | `--type logic,security` |
| `--module` | 只处理特定模块 | `--module user-service` |
| `--priority` | 只处理特定优先级 | `--priority high,medium` |
| `--skip` | 跳过特定问题 | `--skip 3,7,12` |

## Problem Classification & Fix Strategies

| Type | Subtype | Strategy | Risk |
|------|---------|----------|------|
| Completeness | 缺失模块 | 创建新文件/函数 | High |
| Completeness | 缺失功能 | 补充实现代码 | Medium |
| Dependency | 时序错误 | 调整初始化顺序 | High |
| Dependency | 循环依赖 | 重构模块结构 | High |
| Logic | 边界条件 | 添加边界检查 | Medium |
| Logic | 空值检查 | 添加 null 检查 | Low |
| Integration | 命名规范 | 重命名变量/函数 | Low |
| Security | 输入验证 | 添加验证逻辑 | High |

## Fix Plan Structure

Each fix includes:
- Problem ID and description
- Target file and location
- Fix strategy and risk level
- Original code vs fixed code
- Dependency on other fixes

## Execution Strategy

- **Dependency-first**: Execute in topological order
- **Atomic operations**: Single fix failure doesn't affect others
- **Verification**: Syntax check after each fix
- **Rollback**: Auto-rollback on verification failure

## Best Practices

1. Process in batches by type or module for large issues
2. Handle low-risk fixes first, then high-risk
3. Carefully review fix plans, especially high-risk items
4. Run tests after fixes to ensure no regressions
5. Re-run reviewer to verify fixes
