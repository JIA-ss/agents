---
name: research
description: Use when the user asks to "research technology", "compare frameworks", "evaluate solutions", "tech selection", mentions "technical research", "pros and cons", "best practices", or needs help with technology decision-making. Provides specialized support for rendering/graphics technologies. Also responds to "技术调研", "对比框架", "评估方案", "技术选型".
---

# Research Skill Guide

## Overview

遵循"自顶向下、层次递归、可视化优先"方法论的技术调研助手，对渲染领域提供专项支持。

**核心原则**：自顶向下、层次递归、可视化优先

## Workflow (5 Phases)

| Phase | Goal | Output |
|-------|------|--------|
| 1. Overview | 建立全局认知 | 概括性介绍 + 架构可视化 |
| 2. Current State | 收集现有资源 | 资源清单 + 时间线 + 方案汇总 |
| 3. Analysis | 对比各方案 | 自述优势 + 客观提炼 + 对比表格 |
| 4. Deep Dive | 子特性展开 | 递归应用"概括→可视化→详细" |
| 5. Implementation | 深度细节 | 伪代码 + 具体实现 + 最佳实践 |

## Output Requirements

**File Location**: `research-reports/【技术名称】-调研报告-【YYYYMMDD】.md`

**9 Required Sections**:
1. 整体概览 - 概括性介绍 + 架构可视化
2. 技术发展时间线 - Mermaid 时间线图 + 里程碑
3. 现有方案汇总 - 资源清单 + 对比表格
4. 方案详细分析 - 自述优势 + 客观提炼 + 适用场景 + 局限性
5. 核心子特性深入 - 递归展开
6. 技术实现细节 - 伪代码 + 具体实现
7. 渲染专项分析（如适用）
8. 最佳实践与建议
9. 总结与展望

## Rendering Domain Support

When analyzing rendering technologies, include specialized analysis:

| Dimension | Metrics |
|-----------|---------|
| Performance | FPS, 帧时间, GPU利用率, Draw Calls |
| Hardware | Desktop/Mobile/Web/Console support |
| Graphics API | Vulkan/DX12/Metal/OpenGL/WebGL/WebGPU |
| Pipeline | Forward/Deferred/Tile-Based, PBR, Post-processing |

## Best Practices

1. Always start with visualization before text description
2. Use adaptive timeline granularity (yearly/version/milestone)
3. Quote original claims, then provide objective analysis
4. Control recursive depth to 2-3 levels
5. All output must be in Chinese
