# AI Programming Workflow Research Report

> **Task ID**: ai-workflow-research-20260112
> **Date**: 2026-01-12
> **Status**: PASS (Reviewed by Codex, 3 rounds)

---

## Executive Summary

本调研覆盖了 GitHub 上主流的 AI 编程工作流项目，从宏观方法论到具体实现进行了全面分析。核心发现：

1. **Spec-Driven Development** 正在成为 AI 编程的主流范式
2. **TDD + AI** 提供了可验证的代码生成方式
3. **Multi-Agent 架构** 正在从研究走向生产
4. 工作流的关键是 **Specify → Plan → Tasks → Implement** 的结构化流程

---

## Part 1: Macro-Level Methodologies (宏观方法论)

### 1.1 Spec-Driven Development (规范驱动开发)

**核心理念**：规范成为源代码的"源代码"，代码是规范在特定语言中的表达。

**关键原则**：
- 先定义"什么"和"为什么"，再考虑"怎么做"
- 规范是活文档，随项目演进
- 规范必须可验证（关联测试和CI）

**工作流程**：
```
Specify → Plan → Tasks → Implement → Validate
   ↑         ↑       ↑         ↑          ↑
 Human    Human   Human     Agent     Tests
```

**代表工具**：[GitHub Spec-Kit](https://github.com/github/spec-kit), [AWS Kiro](https://github.com/kirodotdev/Kiro)

**最佳适用场景**：
- 功能开发（8+ 小时的任务）
- 多stakeholder项目
- 需要文档和合规的团队

### 1.2 Test-Driven Development with AI (测试驱动 + AI)

**核心理念**：测试即规范，测试作为 prompt 指导 AI 生成代码。

**TDD + AI 工作流**：
1. 人类编写测试（描述期望行为）
2. AI 生成代码使测试通过
3. 测试验证正确性
4. 迭代到下一个行为

**关键优势**：
- 测试提供精确的行为规范
- 减少 AI 幻觉和错误
- 自动验证生成代码
- 增量开发，风险可控

**研究支持**：
- [ASE 2024 论文](https://dl.acm.org/doi/10.1145/3691620.3695527): TDD 显著提高 LLM 代码生成成功率
- [WebApp1K Benchmark](https://arxiv.org/abs/2505.09027): 测试作为 prompt 优于自然语言描述

**代表工具**：[Aider](https://github.com/Aider-AI/aider), Claude Code, [Tweag Agentic Coding Handbook](https://tweag.github.io/agentic-coding-handbook/WORKFLOW_TDD/)

### 1.3 Multi-Agent Collaboration (多智能体协作)

**核心理念**：模拟人类团队，多个专业化 Agent 协作完成复杂任务。

**常见角色**：
| 角色 | 职责 |
|------|------|
| Product Manager | 需求分析、PRD 生成 |
| Architect | 系统设计、技术选型 |
| Developer | 代码实现 |
| QA/Tester | 测试、质量保证 |
| Scrum Master | 流程协调、任务分解 |

**编排模式**：
- **Sequential**: 任务顺序执行
- **Hierarchical**: Manager 协调 Worker
- **Graph-based**: DAG 定义依赖关系

**代表工具**：[MetaGPT](https://github.com/FoundationAgents/MetaGPT), [CrewAI](https://github.com/crewAIInc/crewAI), [LangGraph](https://github.com/langchain-ai/langgraph)

---

## Part 2: Core Projects Analysis (核心项目分析)

### 2.1 GitHub Spec-Kit

**GitHub**: https://github.com/github/spec-kit
**Type**: Toolkit / CLI
**License**: MIT

**核心特性**：
- Agent-agnostic（支持 Claude, Copilot, Cursor, Gemini 等）
- 结构化目录 `.specify/`
- 斜杠命令：`/specify`, `/plan`, `/tasks`, `/implement`

**目录结构**：
```
.specify/
├── memory/
│   └── constitution.md    # 项目原则
├── specs/
│   └── [feature]/
│       ├── spec.md        # 需求规范
│       ├── plan.md        # 技术计划
│       └── tasks.md       # 任务分解
└── templates/             # 可复用模板
```

**适用场景**：为现有 AI 工具添加规范化工作流

---

### 2.2 AWS Kiro

**GitHub**: https://github.com/kirodotdev/Kiro
**Type**: Agentic IDE
**Base**: Code OSS (VS Code)

**核心特性**：
- 三阶段 Specs：Requirements → Design → Tasks
- Agent Hooks：文件变更触发自动化
- Steering：Markdown 规则定制行为
- MCP 集成：扩展外部工具

**定价** (Preview 期间免费，GA 后生效)：
- Free: 50 interactions/month
- Pro: $19/month (1,000 interactions)
- Pro+: $39/month (3,000 interactions)

**适用场景**：需要完整 IDE 体验的规范驱动开发

**来源**: [Kiro Official](https://kiro.dev/), [Kiro GitHub](https://github.com/kirodotdev/Kiro), [AWS Announcement](https://repost.aws/articles/AROjWKtr5RTjy6T2HbFJD_Mw)

---

### 2.3 BMAD-METHOD

**GitHub**: https://github.com/bmad-code-org/BMAD-METHOD
**Type**: Multi-Agent Framework
**License**: MIT

**核心特性**：
- **21 专业化 Agents**：PM, Architect, Developer, UX, Scrum Master 等
- **50+ 工作流模板**
- **Scale-Adaptive**：根据任务复杂度自动调整

**三种模式**：
| Mode | Time | Use Case |
|------|------|----------|
| Quick Flow | ~5 min | Bug fixes, minor features |
| BMad Method | ~15 min | Products, platforms |
| Enterprise | ~30 min | Compliance-heavy systems |

**工具兼容**：Claude Code, Cursor, Copilot, Gemini CLI, Codex

**适用场景**：需要正式敏捷流程的复杂项目

---

### 2.4 Aider

**GitHub**: https://github.com/Aider-AI/aider
**Type**: CLI Tool
**License**: Apache 2.0

**核心特性**：
- 终端 AI Pair Programming
- 深度 Git 集成（自动 commit）
- Codebase mapping（理解大型项目）
- 支持 100+ 语言
- [SWE-Bench 领先成绩](https://aider.chat/docs/leaderboards/) (官方排行榜)

**工作模式**：
```bash
$ aider --model claude-3-opus
> Add a function to validate email addresses
> /add tests/test_email.py
> Write tests first, then implement
```

**适用场景**：喜欢终端工作流的开发者

**来源**: [Aider GitHub](https://github.com/Aider-AI/aider), [Aider Documentation](https://aider.chat/docs/)

---

### 2.5 LangGraph

**GitHub**: https://github.com/langchain-ai/langgraph
**Type**: Orchestration Library
**License**: MIT

**核心概念**：
- **Nodes**: 计算单元（Agent, Function）
- **Edges**: 执行流控制
- **State**: 共享状态（TypedDict）

**关键特性**：
- 持久化执行（故障恢复）
- Human-in-the-loop
- Time-travel debugging
- 与 LangSmith 集成

**代码示例**：
```python
from langgraph.graph import StateGraph, START

graph = StateGraph(State)
graph.add_node("agent", agent_func)
graph.add_edge(START, "agent")
app = graph.compile()
```

**适用场景**：构建复杂的 stateful agent 工作流

---

### 2.6 CrewAI

**GitHub**: https://github.com/crewAIInc/crewAI
**Type**: Multi-Agent Framework
**License**: MIT

**双架构**：
- **Crews**: 自主 Agent 团队，动态协作
- **Flows**: 事件驱动流水线，精确控制

**Agent 定义**：
```yaml
# agents.yaml
researcher:
  role: Research Specialist
  goal: Gather cutting-edge information
  backstory: Expert at web research
  tools: [SerperDevTool]
```

**Process Types**：
- Sequential：顺序执行
- Hierarchical：Manager 协调

**适用场景**：需要角色化协作的自动化任务

---

### 2.7 MetaGPT

**GitHub**: https://github.com/FoundationAgents/MetaGPT
**Type**: Software Company Simulation
**License**: MIT

**核心理念**：`Code = SOP(Team)`

**Pipeline**：
```
One-line Requirement
        ↓
┌───────────────────────┐
│   Product Manager     │ → PRD
│   Architect           │ → Design
│   Project Manager     │ → Tasks
│   Engineer            │ → Code
└───────────────────────┘
        ↓
Complete Repository
```

**输出**：User Stories, Competitive Analysis, Data Structures, APIs, Documentation

**学术认可**：[ICLR 2024 Oral Presentation](https://openreview.net/forum?id=VtmBAGCN7o) (Top 1.2%)

**适用场景**：从需求到完整代码库的端到端生成

**来源**: [MetaGPT GitHub](https://github.com/FoundationAgents/MetaGPT), [MetaGPT Paper](https://arxiv.org/abs/2308.00352)

---

### 2.8 OpenAI Codex

**GitHub**: https://github.com/openai/codex
**Type**: Cloud Agent + CLI

**架构**：
- 云端沙盒执行（无网络访问）
- 基于 codex-1 (o3 优化版)
- MCP Server 模式
- AGENTS.md 自定义指令

**Multi-Agent 模式**：
```
Project Manager Agent
        ↓
┌───────┬───────┬───────┐
│Design │Frontend│Backend│
└───────┴───────┴───────┘
        ↓
    Tester Agent
```

**适用场景**：企业级安全隔离的代码生成

**来源**: [OpenAI Codex Documentation](https://developers.openai.com/codex/), [Codex CLI GitHub](https://github.com/openai/codex)

---

### 2.9 IDE/Editor Tools (补充说明)

以下工具在报告其他部分有涉及，此处提供集中参考：

#### Claude Code
- **Type**: Terminal-based AI Agent
- **Provider**: Anthropic
- **Key Feature**: CLAUDE.md 项目配置, MCP 协议集成
- **Workflow**: 适合探索性开发和复杂推理任务
- **Documentation**: [Claude Code Docs](https://docs.anthropic.com/claude-code)

#### Cursor
- **Type**: AI-Native IDE (VS Code fork)
- **Key Feature**: `.cursor/rules/` 项目规则, 内联补全 + Chat
- **Workflow**: 适合日常编码和快速迭代
- **Documentation**: [Cursor Docs](https://docs.cursor.com/)
- **Community**: [Awesome CursorRules](https://github.com/PatrickJS/awesome-cursorrules)

#### GitHub Copilot
- **Type**: IDE Extension
- **Key Feature**: 内联代码补全, Chat, PR 描述生成
- **Workflow**: 适合速度优先的重复性编码
- **Documentation**: [GitHub Copilot Docs](https://docs.github.com/copilot)

---

## Part 3: Architecture Patterns (架构模式)

### 3.1 Spec-First Pipeline

```
┌─────────────────────────────────────────────────────┐
│                  Human Input                        │
└───────────────────────┬─────────────────────────────┘
                        ↓
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   Specify   │→ │    Plan     │→ │    Tasks    │
│  (What/Why) │  │   (How)     │  │  (Actions)  │
└─────────────┘  └─────────────┘  └─────────────┘
        ↑              ↑               ↑
    Human          Human           Human
    Review         Review          Review
                        ↓
┌─────────────────────────────────────────────────────┐
│               AI Agent Execution                     │
│  • Parallel tasks marked [P]                        │
│  • Tests written before implementation              │
│  • Incremental commits                              │
└─────────────────────────────────────────────────────┘
```

### 3.2 Multi-Agent Assembly Line

```
┌──────────────────────────────────────────────────────┐
│                    Orchestrator                       │
│  • Routes tasks to specialized agents                │
│  • Manages state and handoffs                        │
│  • Validates outputs before proceeding               │
└────────────────────────┬─────────────────────────────┘
                         ↓
    ┌────────────┬───────────────┬────────────┐
    ↓            ↓               ↓            ↓
┌───────┐  ┌──────────┐  ┌──────────┐  ┌───────┐
│  PM   │  │ Architect│  │Developer │  │  QA   │
└───────┘  └──────────┘  └──────────┘  └───────┘
    │            │               │            │
    ↓            ↓               ↓            ↓
┌───────┐  ┌──────────┐  ┌──────────┐  ┌───────┐
│  PRD  │  │  Design  │  │   Code   │  │ Tests │
└───────┘  └──────────┘  └──────────┘  └───────┘
```

### 3.3 TDD Feedback Loop

```
          ┌─────────────────────────────────┐
          │    1. Write Failing Test        │
          │    (Human describes behavior)   │
          └───────────────┬─────────────────┘
                          ↓
          ┌─────────────────────────────────┐
          │    2. AI Generates Code         │
          │    (Implementation to pass)     │
          └───────────────┬─────────────────┘
                          ↓
          ┌─────────────────────────────────┐
          │    3. Run Tests                 │
          └───────────────┬─────────────────┘
                    ┌─────┴─────┐
                 Pass          Fail
                    ↓            ↓
          ┌────────────┐  ┌────────────┐
          │ 4. Refactor│  │ Retry Gen  │
          │ (optional) │  │            │
          └─────┬──────┘  └─────┬──────┘
                ↓               ↓
          ┌─────────────────────────────────┐
          │    5. Next Test                 │
          └─────────────────────────────────┘
```

### 3.4 Hybrid Approach (推荐)

```
┌────────────────────────────────────────────────────┐
│  Phase 1: Specification (Human-Led)                │
│  • Define requirements (Spec-Kit /specify)         │
│  • Human approval gates                            │
└────────────────────────┬───────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────┐
│  Phase 2: Planning (AI-Assisted)                   │
│  • Technical design (Spec-Kit /plan)               │
│  • Human review and refinement                     │
└────────────────────────┬───────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────┐
│  Phase 3: Task Breakdown                           │
│  • Actionable tasks (/tasks)                       │
│  • Parallel markers [P]                            │
│  • Test-first ordering                             │
└────────────────────────┬───────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────┐
│  Phase 4: Implementation (TDD Loop)                │
│  • Write test → Generate code → Validate           │
│  • Incremental commits                             │
│  • CI integration                                  │
└────────────────────────┬───────────────────────────┘
                         ↓
┌────────────────────────────────────────────────────┐
│  Phase 5: Review & Validation                      │
│  • Self-review / Independent review                │
│  • Integration tests                               │
│  • Documentation update                            │
└────────────────────────────────────────────────────┘
```

---

## Part 4: Recommendations (建议)

### 4.1 For Your Custom Workflow

基于调研，为你搭建自己的 AI 工作流提供以下建议：

#### 推荐架构

```
Your Custom Workflow
├── 1. Specification Layer
│   ├── Use: Spec-Kit patterns or BMAD templates
│   ├── Output: spec.md, plan.md, tasks.md
│   └── Tool: /specify, /plan, /tasks commands
│
├── 2. Execution Layer
│   ├── Use: TDD pattern (test → generate → validate)
│   ├── Tool: Claude Code / Aider for implementation
│   └── Integration: Git auto-commit on success
│
├── 3. Orchestration Layer (optional)
│   ├── Use: LangGraph for complex multi-step workflows
│   ├── Or: CrewAI for role-based collaboration
│   └── State management: Checkpoints, resumable
│
└── 4. Review Layer
    ├── Use: Your self-review skill!
    ├── Independent validation (Codex)
    └── Evidence collection and traceability
```

#### 具体建议

1. **从 Spec-Kit 模式开始**
   - 采用 `/specify → /plan → /tasks` 工作流
   - 创建 `.specify/` 目录结构
   - Agent-agnostic，可与 Claude Code 配合

2. **整合 TDD 实践**
   - 任务分解时标记需要测试的项
   - 先写测试再实现
   - 使用测试作为 AI 的精确 prompt

3. **利用你现有的 Self-Review Skill**
   - 执行后调用独立 Reviewer (Codex)
   - 保持证据链和可追溯性
   - 迭代改进直到 PASS

4. **考虑引入 Multi-Agent**（进阶）
   - 对于复杂任务，可参考 BMAD 的 Agent 角色
   - 使用 LangGraph 编排多步骤工作流

### 4.2 Tool Selection Guide

| 场景 | 推荐工具 |
|------|----------|
| 规范化你的 AI 编程 | Spec-Kit + Claude Code |
| 需要完整 IDE | Kiro |
| 复杂敏捷项目 | BMAD-METHOD |
| 终端爱好者 | Aider |
| 多Agent编排 | LangGraph / CrewAI |
| 端到端自动生成 | MetaGPT |

---

## Part 5: Sources (信息来源)

### Official Documentation
- [GitHub Spec-Kit Blog](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)
- [Kiro Official Site](https://kiro.dev/)
- [BMAD-METHOD GitHub](https://github.com/bmad-code-org/BMAD-METHOD)
- [Aider Documentation](https://aider.chat/docs/)
- [LangGraph Documentation](https://www.langchain.com/langgraph)
- [CrewAI Documentation](https://docs.crewai.com/)
- [MetaGPT GitHub](https://github.com/FoundationAgents/MetaGPT)
- [OpenAI Codex](https://developers.openai.com/codex/)

### Research Papers
- [TDD for LLM Code Generation (ASE 2024)](https://dl.acm.org/doi/10.1145/3691620.3695527)
- [WebApp1K Benchmark (arXiv)](https://arxiv.org/abs/2505.09027)
- [MetaGPT (ICLR 2024 Oral)](https://openreview.net/forum?id=VtmBAGCN7o)

### Community Resources
- [Tweag Agentic Coding Handbook - TDD](https://tweag.github.io/agentic-coding-handbook/WORKFLOW_TDD/)
- [Martin Fowler - SDD Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [Red Hat - Spec-Driven Quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [Cursor Best Practices](https://github.com/digitalchild/cursor-best-practices)
- [Awesome CursorRules](https://github.com/PatrickJS/awesome-cursorrules)

---

## Appendix: Quick Start Checklist

- [ ] 创建 `.specify/` 或类似的规范目录
- [ ] 定义项目 constitution (原则和约束)
- [ ] 采用 Specify → Plan → Tasks 工作流
- [ ] 集成 TDD 实践（测试先行）
- [ ] 配置 Git 自动提交
- [ ] 设置 Self-Review 检查点
- [ ] 文档化你的 Agent 规则 (CLAUDE.md / .cursorrules)

---

*Report generated by Self-Review Skill | 2026-01-12*
