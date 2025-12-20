---
name: task-code-reviewer
description: Use when the user asks to "review code against plan", "check implementation completeness", "validate task implementation", "verify code matches specification", mentions "task-based review", "plan compliance", or needs to verify code implementation against a task planning document. Also responds to "代码审查", "检查实现", "验证代码", "任务完成度".
---

# Task Code Reviewer Skill Guide

## Overview

基于任务规划文档检查代码实现的完成度、时序依赖、逻辑正确性和框架集成，输出结构化的代码审查报告。

**核心价值**：规划对齐 + 依赖验证 + 逻辑分析 + 集成评估 + 结构化报告

## Workflow (7 Phases)

| Phase | Description |
|-------|-------------|
| 1. Plan Parsing | 从 `.tasks/` 解析规划文档，提取模块、依赖、验收标准 |
| 2. Change Detection | git diff 分析，分类变更文件，映射到规划模块 |
| 3. Completeness Check | 验证模块实现、核心函数、接口定义、任务清单 |
| 4. Dependency Verification | 检查时序依赖、数据依赖、初始化顺序、模块依赖 |
| 5. Logic Analysis | 边界条件、异常路径、状态一致性、竞态条件 |
| 6. Framework Integration | 代码模式、命名规范、文件组织、架构层级 |
| 7. Extended Analysis | 安全性、最佳实践、代码质量（按重要性分级） |

## Check Dimensions

### Completeness
| Check | Criteria |
|-------|----------|
| Module implementation | 文件路径匹配 |
| Core functions | 符号存在性 |
| Interface definitions | 接口签名匹配 |
| Task checklist | 变更关联 |

### Dependencies
| Type | Example Issue |
|------|---------------|
| Temporal | 任务B依赖A，但A未完成就实现B |
| Data | 使用了未定义的数据结构 |
| Initialization | 依赖服务未初始化就调用 |
| Module | 循环依赖、跨层调用 |

### Logic Analysis
| Check | Example Issue |
|-------|---------------|
| Boundary conditions | 数组越界、未检查null |
| Exception paths | catch块为空、未处理所有错误 |
| State consistency | 状态更新不原子、数据不一致 |
| Race conditions | 共享资源未加锁、死锁风险 |

### Extended Checks (Priority)
| Level | Checks |
|-------|--------|
| Required | 输入验证、认证授权、敏感数据、边界条件、异常路径 |
| Important | 错误处理、日志记录、文档完整性 |
| Optional | 代码复杂度、重复代码、性能优化 |

## Report Structure

1. **Executive Summary** - 总体状态、各维度评分、Top 3 问题
2. **Detailed Analysis** - 规划文档分析、完成度、依赖验证、逻辑分析、集成评估
3. **Improvement Suggestions** - 高/中/低优先级建议
4. **File Index** - 文件路径、变更类型、关联模块、问题数

## Best Practices

1. Use task-planner first to generate plan before development
2. Submit code incrementally, review incrementally
3. Prioritize Top 3 issues from executive summary
4. Adjust development practices based on review reports
