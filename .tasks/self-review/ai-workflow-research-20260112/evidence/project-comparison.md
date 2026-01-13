# AI Programming Workflow Projects Comparison

## Quick Reference Matrix

| Project | Type | Open Source | Language | Key Differentiator |
|---------|------|-------------|----------|-------------------|
| [GitHub Spec-Kit](https://github.com/github/spec-kit) | Toolkit | MIT | Any | Agent-agnostic spec workflow |
| [AWS Kiro](https://github.com/kirodotdev/Kiro) | IDE | Yes (Code OSS base) | Any | Full IDE with agent hooks |
| [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD) | Framework | MIT | Any | 21 specialized agents, scale-adaptive |
| [Aider](https://github.com/Aider-AI/aider) | CLI Tool | Apache 2.0 | Python | Git-integrated pair programming |
| [LangGraph](https://github.com/langchain-ai/langgraph) | Library | MIT | Python | Stateful graph orchestration |
| [CrewAI](https://github.com/crewAIInc/crewAI) | Framework | MIT | Python | Role-based agent crews |
| [MetaGPT](https://github.com/FoundationAgents/MetaGPT) | Framework | MIT | Python | SOP-driven software company |
| [OpenAI Codex](https://github.com/openai/codex) | Cloud+CLI | MIT (CLI) | Any | Sandboxed cloud execution |

## Detailed Comparison

### 1. Spec-Driven Tools

#### GitHub Spec-Kit
```
Workflow: /specify → /plan → /tasks → implement
Directory: .specify/{memory, specs, scripts, templates}
Strengths: Agent-agnostic, lightweight, official GitHub support
Use Case: Adding structured specs to any AI coding workflow
```

#### AWS Kiro
```
Workflow: Requirements → Design → Tasks (3-phase specs)
Features: Agent hooks, steering rules, MCP integration
Strengths: Full IDE experience, event-driven automation
Use Case: Teams wanting an integrated spec-driven IDE
```

#### BMAD-METHOD
```
Workflow: Quick Flow (5min) → BMad Method (15min) → Enterprise (30min)
Agents: 21+ specialized (PM, Architect, Scrum Master, etc.)
Strengths: Scale-adaptive, comprehensive agent library
Use Case: Complex projects needing formal agile structure
```

### 2. TDD-Focused Tools

#### Aider
```
Pattern: Write test → Generate code → Validate → Refactor
Integration: Deep Git integration, auto-commits
Strengths: SWE-Bench leading scores, mature tool
Use Case: Developers preferring terminal workflows
```

#### TDD with AI (General Pattern)
```
1. Human writes test describing behavior
2. AI generates implementation to pass test
3. Tests validate correctness
4. Iterate incrementally
Benefits: Tests act as precise prompts, reduce hallucination
```

### 3. Multi-Agent Orchestration

#### LangGraph
```
Architecture: Directed graph (nodes = agents, edges = flow)
State: TypedDict shared across nodes
Features: Persistence, human-in-loop, time-travel debugging
Use Case: Complex stateful agent workflows
```

#### CrewAI
```
Architecture: Crews (autonomous teams) + Flows (controlled pipelines)
Roles: Researcher, Analyst, Manager, Worker
Features: Task delegation, tool assignment, process types
Use Case: Role-based collaborative automation
```

#### MetaGPT
```
Architecture: SOP-encoded multi-agent company
Roles: Product Manager, Architect, Project Manager, Engineer
Output: Full repo from one-line requirement
Use Case: End-to-end software generation
```

### 4. IDE/Editor Integrations

| Tool | Base | Key Feature |
|------|------|-------------|
| Cursor | VS Code fork | .cursor/rules/, AI-native UI |
| Kiro | Code OSS | Specs + Hooks + Steering |
| Copilot | Extension | Inline completion, Chat |
| Claude Code | Terminal | CLAUDE.md context, MCP |

## Architecture Patterns

### Pattern 1: Spec-First Pipeline
```
┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐
│ Specify │ → │  Plan   │ → │  Tasks  │ → │Implement│
└─────────┘   └─────────┘   └─────────┘   └─────────┘
     ↑             ↑             ↑             ↑
  Human        Human         Human        AI Agent
  Input        Review        Review
```

### Pattern 2: Multi-Agent Pipeline
```
┌────────────┐
│ Requirement│
└─────┬──────┘
      ↓
┌─────────────────────────────────────┐
│           Orchestrator              │
├─────────┬─────────┬────────┬────────┤
│   PM    │Architect│ Dev    │  QA    │
└─────────┴─────────┴────────┴────────┘
      ↓
┌────────────┐
│   Output   │
│ (PRD+Code) │
└────────────┘
```

### Pattern 3: TDD Feedback Loop
```
┌──────────────┐
│ Write Test   │←─────────────┐
└──────┬───────┘              │
       ↓                      │
┌──────────────┐              │
│ AI Generate  │              │
└──────┬───────┘              │
       ↓                      │
┌──────────────┐    Fail      │
│ Run Tests    │──────────────┘
└──────┬───────┘
       │ Pass
       ↓
┌──────────────┐
│ Next Feature │
└──────────────┘
```

## Recommendations by Use Case

| Use Case | Recommended Tools |
|----------|-------------------|
| 个人开发者快速原型 | Aider + TDD pattern |
| 团队规范化开发 | Spec-Kit + Cursor/Claude |
| 复杂企业项目 | BMAD-METHOD + Kiro |
| 多Agent自动化 | LangGraph or CrewAI |
| 全自动代码生成 | MetaGPT |
| 研究和实验 | Claude Code + custom workflow |
