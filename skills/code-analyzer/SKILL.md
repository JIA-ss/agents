---
name: code-analyzer
description: Use when the user asks to "analyze code", "understand codebase", "trace dependencies", "visualize architecture", "complexity analysis", mentions "code structure", "call graph", "module dependencies", or needs help understanding unfamiliar code. Also responds to "分析代码", "梳理逻辑", "追踪依赖", "可视化架构", "代码结构".
---

# Code Analyzer Skill Guide

## Overview

专业的代码逻辑梳理和可视化分析工具，帮助开发者快速理解代码结构、依赖关系和执行流程。

**核心价值**：自动识别代码结构、绘制依赖关系图、生成执行流程可视化、评估代码复杂度

## Analysis Scenarios

| Input Type | Scenario | Focus |
|------------|----------|-------|
| File path | File-level | 深度分析函数定义、内部逻辑、复杂度评估 |
| Directory path | Module-level | 模块结构、导出接口、依赖关系 |
| Function name | Call chain | 追踪定义位置、调用者、被调用者 |
| "arch"/"overview" | Architecture | 宏观目录结构、模块划分、技术栈 |

## Workflow

1. **Scenario Identification** - 根据输入智能判断分析场景
2. **Code Scanning** - 使用 Glob/Read/Grep 定位和读取代码
3. **Structure Parsing** - 提取模块、类、函数、入口点、依赖关系
4. **Visualization** - 智能选择图表类型，生成 Mermaid 可视化
5. **Documentation** - 生成标准化 Markdown 分析报告

## Chart Selection Strategy

| Analysis Target | Optimal Chart | Mermaid Type |
|-----------------|---------------|--------------|
| Overall architecture | 架构拓扑图 | `graph TB` |
| Module dependencies | 依赖关系图 | `graph LR` |
| Execution flow | 流程图 | `flowchart TD` |
| Function call chain | 时序图 | `sequenceDiagram` |
| Class inheritance | 类图 | `classDiagram` |

## Output Report Structure (8 Sections)

1. **概览** - 技术栈识别、代码规模统计
2. **架构可视化** - Mermaid 架构图 + 架构说明
3. **执行流程** - Mermaid 流程图/时序图 + 关键流程
4. **核心组件说明** - 位置、职责、关键方法、依赖项
5. **复杂度评估** - 整体评估、高复杂度区域、改进建议
6. **依赖关系** - Mermaid 依赖图 + 分析
7. **关键发现** - 优点、风险点、改进方向
8. **相关文件索引** - 按重要性排序

## Quality Requirements

- At least 2 Mermaid diagrams (architecture + flow/dependency)
- Code references with exact file path and line number (`file.js:123`)
- Report length: 300-500 lines
- Max 12 nodes per diagram (use subgraph for larger)
- No ASCII art or plain text trees

## Limitations

- Single analysis: recommend ≤ 50 files
- Dynamic imports may not be fully tracked
- Complex semantic analysis needs manual verification
