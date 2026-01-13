# Code Snippets and Implementation References

本文档收集了各项目的关键代码片段和实现参考。

---

## 1. GitHub Spec-Kit

### Directory Structure (from README)
```
.specify/
├── memory/
│   └── constitution.md    # Project principles
├── specs/
│   └── [feature-number]/
│       ├── spec.md        # Requirements specification
│       ├── plan.md        # Technical implementation plan
│       ├── tasks.md       # Task breakdown
│       └── contracts/     # API specifications
├── scripts/               # Automation utilities
└── templates/             # Reusable document formats
```
**Source**: [github/spec-kit - Directory Structure](https://github.com/github/spec-kit#directory-structure)

### Slash Commands

Spec-Kit supports both short and full command formats:

```markdown
# Short format (recommended)
/specify    - Capture functional requirements
/plan       - Create technical implementation roadmap
/tasks      - Break plan into actionable tasks

# Full namespaced format
/speckit.specify    - Same as /specify
/speckit.plan       - Same as /plan
/speckit.tasks      - Same as /tasks
/speckit.implement  - Execute implementation
```

**Note**: The short format (`/specify`, `/plan`, `/tasks`) is commonly used in documentation, while the full namespaced format (`/speckit.*`) is the formal CLI syntax.

**Source**: [spec-kit/spec-driven.md](https://github.com/github/spec-kit/blob/main/spec-driven.md), [GitHub Blog Announcement](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)

---

## 2. AWS Kiro

### Spec Structure (3-Phase)
```yaml
# Requirements Phase
requirements:
  - description: User can sign up with email
    acceptance_criteria:
      - Email validation
      - Confirmation email sent

# Design Phase
design:
  components:
    - name: AuthService
      responsibilities: [validation, token_generation]

# Tasks Phase
tasks:
  - id: T1
    description: Create AuthService class
    depends_on: []
```
**Source**: [Kiro Documentation - Specs](https://kiro.dev/docs/specs/)

### Agent Hooks Example
```json
// .kiro/hooks/on-file-save.json
{
  "trigger": "file:save",
  "pattern": "*.ts",
  "action": "lint-and-format"
}
```
**Source**: [Kiro - Agent Hooks](https://kiro.dev/docs/hooks/)

---

## 3. BMAD-METHOD

### Agent Definition (YAML)
```yaml
# agents/architect.yaml
name: Architect
role: System Designer
responsibilities:
  - Define technical architecture
  - Select technology stack
  - Document design decisions
triggers:
  - on: PRD_COMPLETE
    action: CREATE_SYSTEM_DESIGN
```
**Source**: [BMAD-METHOD - Agent Structure](https://github.com/bmad-code-org/BMAD-METHOD#agent-structure)

### Workflow Definition
```yaml
# workflows/greenfield.yaml
name: Greenfield Project
phases:
  - name: analysis
    agent: analyst
    output: project_brief.md
  - name: requirements
    agent: pm
    depends_on: [analysis]
    output: prd.md
  - name: architecture
    agent: architect
    depends_on: [requirements]
    output: system_design.md
```
**Source**: [BMAD-METHOD/workflows](https://github.com/bmad-code-org/BMAD-METHOD/tree/main/workflows)

---

## 4. Aider

### Basic Usage
```bash
# Start aider with Claude
$ aider --model claude-3-opus

# Add files to context
> /add src/auth.py tests/test_auth.py

# Request changes
> Add email validation to the signup function

# Aider auto-commits with meaningful messages
[main abc1234] Add email validation using regex pattern
```
**Source**: [Aider Documentation - Usage](https://aider.chat/docs/usage.html)

### TDD Workflow
```bash
$ aider --model claude-3-opus

> /add tests/test_calculator.py
> Write a failing test for a divide function that raises ZeroDivisionError

# Aider creates test
[commit] Add test for divide function zero division

> Now implement the divide function to pass the test
> /add src/calculator.py

# Aider implements and runs tests
[commit] Implement divide function with zero check
```
**Source**: [Aider - Test-Driven Development](https://aider.chat/docs/tdd.html)

---

## 5. LangGraph

### State Graph Definition
```python
from typing import TypedDict
from langgraph.graph import StateGraph, START, END

class State(TypedDict):
    messages: list
    current_step: str

def agent_node(state: State) -> State:
    # Process and return updated state
    return {"messages": state["messages"] + ["processed"]}

# Build graph
graph = StateGraph(State)
graph.add_node("agent", agent_node)
graph.add_edge(START, "agent")
graph.add_edge("agent", END)

# Compile and run
app = graph.compile()
result = app.invoke({"messages": [], "current_step": "start"})
```
**Source**: [LangGraph - Quick Start](https://github.com/langchain-ai/langgraph#quick-start)

### Conditional Branching
```python
def should_continue(state: State) -> str:
    if state["current_step"] == "done":
        return "end"
    return "continue"

graph.add_conditional_edges(
    "agent",
    should_continue,
    {"continue": "agent", "end": END}
)
```
**Source**: [LangGraph - Conditional Edges](https://langchain-ai.github.io/langgraph/how-tos/branching/)

---

## 6. CrewAI

### Agent Definition
```python
from crewai import Agent
from crewai_tools import SerperDevTool

researcher = Agent(
    role="Senior Research Analyst",
    goal="Uncover cutting-edge developments",
    backstory="Expert at finding and synthesizing information",
    tools=[SerperDevTool()],
    verbose=True
)
```
**Source**: [CrewAI - Agents](https://docs.crewai.com/concepts/agents)

### Crew with Tasks
```python
from crewai import Crew, Task, Process

research_task = Task(
    description="Research latest AI frameworks",
    expected_output="Detailed report on top 5 frameworks",
    agent=researcher
)

crew = Crew(
    agents=[researcher, writer],
    tasks=[research_task, write_task],
    process=Process.sequential,
    verbose=True
)

result = crew.kickoff()
```
**Source**: [CrewAI - Getting Started](https://docs.crewai.com/quickstart)

### YAML Configuration (agents.yaml)
```yaml
# agents.yaml - Agent definition in YAML format
researcher:
  role: Senior Research Analyst
  goal: Uncover cutting-edge developments in AI
  backstory: >
    You are a seasoned researcher with a keen eye for emerging trends.
    Your expertise lies in synthesizing complex information.
  tools:
    - SerperDevTool
  verbose: true

writer:
  role: Technical Writer
  goal: Create comprehensive reports from research findings
  backstory: >
    You excel at transforming raw research into polished documents.
  verbose: true
```
**Source**: [CrewAI - YAML Configuration](https://docs.crewai.com/concepts/agents#yaml-configuration)

### Tasks YAML Configuration (tasks.yaml)
```yaml
# tasks.yaml - Task definition in YAML format
research_task:
  description: Research latest developments in AI frameworks
  expected_output: A detailed report covering top 5 frameworks
  agent: researcher

writing_task:
  description: Create a summary document from research
  expected_output: A well-formatted markdown report
  agent: writer
  depends_on:
    - research_task
```
**Source**: [CrewAI - Tasks YAML](https://docs.crewai.com/concepts/tasks#yaml-configuration)

### Flow Definition
```python
from crewai.flow.flow import Flow, start, listen

class ResearchFlow(Flow):
    @start()
    def gather_data(self):
        return {"data": "raw data"}

    @listen(gather_data)
    def analyze(self, data):
        return {"analysis": "processed"}
```
**Source**: [CrewAI - Flows](https://docs.crewai.com/concepts/flows)

---

## 7. MetaGPT

### One-Line Project Generation
```python
from metagpt.software_company import SoftwareCompany

company = SoftwareCompany()
company.hire([ProductManager(), Architect(), Engineer()])
company.start_project("Create a snake game with high scores")
await company.run()
```
**Source**: [MetaGPT - Quick Start](https://github.com/FoundationAgents/MetaGPT#quick-start)

### Role Definition
```python
from metagpt.roles import Role
from metagpt.actions import WriteCode

class Developer(Role):
    name: str = "Developer"
    profile: str = "Software Engineer"

    def __init__(self):
        super().__init__()
        self.set_actions([WriteCode])
```
**Source**: [MetaGPT - Custom Roles](https://github.com/FoundationAgents/MetaGPT/blob/main/docs/tutorial.md)

---

## 8. OpenAI Codex

### CLI Execution
```bash
# Standard execution
codex exec "Refactor the auth module to use async/await"

# With specific model
codex exec -m gpt-5.1-codex-max "Add comprehensive error handling"
```
**Source**: [OpenAI Codex CLI](https://github.com/openai/codex#usage)

### AGENTS.md Configuration
```markdown
# AGENTS.md

## Coding Standards
- Use TypeScript strict mode
- Follow ESLint airbnb config
- Write tests for all public functions

## Project Structure
- `/src` - Source code
- `/tests` - Test files
- `/docs` - Documentation

## Naming Conventions
- camelCase for functions
- PascalCase for classes
- UPPER_SNAKE_CASE for constants
```
**Source**: [OpenAI Codex - AGENTS.md](https://developers.openai.com/codex/guides/agents-md/)

---

## 9. Cursor Rules

### Project Rules (.mdc format)
```markdown
<!-- .cursor/rules/typescript.mdc -->
---
description: TypeScript coding standards
globs: ["**/*.ts", "**/*.tsx"]
---

# TypeScript Rules

- Use strict TypeScript mode
- Prefer interfaces over types for objects
- Use `const` by default, `let` when mutation needed
- Never use `any` - use `unknown` and narrow
```
**Source**: [Cursor - Rules for AI](https://docs.cursor.com/context/rules-for-ai)

### Nested Configuration
```
project/
├── .cursor/rules/
│   └── global.mdc           # Project-wide rules
├── frontend/
│   └── .cursor/rules/
│       └── react.mdc        # React-specific rules
└── backend/
    └── .cursor/rules/
        └── express.mdc      # Express-specific rules
```
**Source**: [Cursor Best Practices](https://github.com/digitalchild/cursor-best-practices)

---

## 10. Claude Code

### CLAUDE.md Configuration
```markdown
# CLAUDE.md

## Project Overview
E-commerce platform with React frontend and Node.js backend.

## Architecture
- Frontend: React + Redux + TypeScript
- Backend: Express + PostgreSQL
- Auth: JWT tokens

## Development Commands
- `npm run dev` - Start development server
- `npm test` - Run tests
- `npm run build` - Production build

## Conventions
- Use async/await for all async operations
- Error messages should be user-friendly
- All API endpoints must have OpenAPI docs
```
**Source**: [Claude Code Documentation](https://docs.anthropic.com/claude-code/claude-md)

### MCP Integration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"]
    }
  }
}
```
**Source**: [Claude Code - MCP Servers](https://docs.anthropic.com/claude-code/mcp)

---

*Note: Code snippets are sourced from official documentation and repositories. Some examples are simplified for clarity.*
