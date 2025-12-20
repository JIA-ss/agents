---
name: doc-writer
description: Use when the user asks to "write documentation", "generate README", "create API docs", "document this code", "restructure documentation", mentions "technical documentation", or discusses documentation quality, documentation standards, or improving existing docs. Also responds to "写文档", "生成 README", "创建 API 文档".
---

# Documentation Writer Skill Guide

## Overview

专注于技术文档编写的 AI skill，自动生成结构化、高质量的 README、API 文档和架构说明。

**核心价值**：标准化、结构化、自动化、可维护性

## Workflow (5 Phases)

1. **Requirement Analysis** - 识别文档类型、目标受众、风格要求
2. **Information Gathering** - 分析代码结构、提取 API、读取配置、解析注释
3. **Structure Design** - 选择模板、规划章节、规划可视化元素
4. **Content Generation** - 填充内容、生成图表、生成代码示例
5. **Quality Check** - 完整性、准确性、格式、可读性检查

## Document Templates

| Type | Core Sections |
|------|---------------|
| **README** | 项目简介、功能特性、快速开始、安装部署、使用示例、贡献指南 |
| **API Docs** | 接口概述、认证方式、端点列表、请求/响应格式、错误码、示例 |
| **Architecture** | 系统概述、架构设计、技术栈、模块说明、数据流、部署架构 |
| **Dev Guide** | 环境搭建、项目结构、开发流程、编码规范、测试指南、发布流程 |

## Quality Checklist

- [ ] 必需章节完整
- [ ] API 信息准确一致
- [ ] Markdown 语法正确
- [ ] 代码块语言标识正确
- [ ] Mermaid 图表可渲染
- [ ] 章节层次清晰（不超过4级）
- [ ] 示例充足、可运行
- [ ] 专业术语有解释

## Visualization Requirements

复杂架构和流程**必须**使用 Mermaid 图表：
- 系统架构：使用 `flowchart` + `subgraph` 分层
- 数据流：使用 `sequenceDiagram`
- 关系模型：使用 `erDiagram`
- 能力概览：使用 `mindmap`

## Best Practices

1. 保持代码注释完整（JSDoc/TSDoc/Docstring）
2. 使用标准项目结构（src/、docs/、tests/）
3. 明确文档受众，调整技术深度
4. 每个 API 接口提供完整调用示例
5. 定期更新，代码重构后及时同步

## Limitations

- 文档质量依赖于代码注释完整性
- 复杂业务逻辑需人工补充背景
- 支持语言：JavaScript/TypeScript、Python、Java、Go
- 生成的是静态快照，代码变更后需重新生成
