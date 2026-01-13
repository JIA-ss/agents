# AI Workflow Framework Design

> **Version**: 1.0.0
> **Codename**: `agent-flow`
> **Date**: 2026-01-12

---

## 1. Design Philosophy

### 1.1 Core Principles

| 原则 | 说明 |
|------|------|
| **Spec-First** | 规范先行，代码是规范的实现 |
| **Test-Driven** | 测试即验证，测试驱动实现 |
| **Human-in-Loop** | 关键节点人工审批 |
| **Traceable** | 完整的任务链路追溯 |
| **Tool-Agnostic** | 支持多种 AI 工具 |
| **Stack-Flexible** | 模板可适配不同技术栈 |

### 1.2 Multi-Stack Support

本框架设计为**栈无关**的，但提供的默认模板以 TypeScript/Node.js 为示例。

**适配其他技术栈**:

| 技术栈 | 配置修改 |
|--------|----------|
| Python | `tools.test.command: "pytest"`, `tools.lint.command: "ruff check ."` |
| Go | `tools.test.command: "go test ./..."`, `tools.lint.command: "golangci-lint run"` |
| Rust | `tools.test.command: "cargo test"`, `tools.lint.command: "cargo clippy"` |
| Java | `tools.test.command: "mvn test"`, `tools.lint.command: "mvn checkstyle:check"` |

**模板定制**:
- 复制 `templates/` 目录为 `templates-{stack}/` (如 `templates-python/`)
- 修改示例代码和命令
- 在 `config.yaml` 中指定模板目录

### 1.3 Workflow Equation

```
Output = Workflow(Spec + Context + Feedback)

其中:
- Spec: 任务规范 (what & why)
- Context: 项目上下文 (CLAUDE.md, codebase)
- Feedback: 审查反馈 (self-review, human review)
```

---

## 2. Workflow Phases (5 阶段模型)

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI WORKFLOW                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │ SPECIFY  │ → │   PLAN   │ → │   TASK   │ → │ IMPLEMENT │  │
│  │ (规范)   │    │  (计划)  │    │  (分解)  │    │  (实现)   │  │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘  │
│       │               │               │               │         │
│       ↓               ↓               ↓               ↓         │
│   [Human]         [Human]         [Human]         [Tests]       │
│   Approve         Review          Review          Validate      │
│                                                                  │
│                                       ┌──────────┐              │
│                                       │  REVIEW  │←─────────────┤
│                                       │  (审查)  │              │
│                                       └────┬─────┘              │
│                                            │                    │
│                                      ┌─────┴─────┐              │
│                                      ↓           ↓              │
│                                   [PASS]    [IMPROVE]           │
│                                      │           │              │
│                                      ↓           └──→ IMPLEMENT │
│                                   DELIVER                       │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2.1 Phase Details

#### Phase 1: SPECIFY (规范)
**目的**: 定义"做什么"和"为什么"

**输入**: 用户需求、问题描述
**输出**: `spec.md`

**内容**:
- 功能描述
- 验收标准 (Acceptance Criteria)
- 约束条件
- 非功能需求

**检查点**: Human Approval

---

#### Phase 2: PLAN (计划)
**目的**: 定义"怎么做"

**输入**: `spec.md`
**输出**: `plan.md`

**内容**:
- 技术方案
- 架构决策
- 依赖分析
- 风险评估

**检查点**: Human Review

---

#### Phase 3: TASK (分解)
**目的**: 将计划分解为可执行任务

**输入**: `plan.md`
**输出**: `tasks.md`

**内容**:
- 任务列表 (带优先级)
- 并行标记 `[P]`
- 依赖关系
- 测试先行标记 `[T]`

**检查点**: Human Review

---

#### Phase 4: IMPLEMENT (实现)
**目的**: 执行任务，生成代码

**输入**: `tasks.md`, 当前任务
**输出**: Code changes, Tests

**流程**:
1. 读取任务
2. 若有 `[T]` 标记，先写测试
3. 实现代码
4. 运行测试
5. 提交 (atomic commit)

**检查点**: Tests Pass

---

#### Phase 5: REVIEW (审查)
**目的**: 独立验证实现质量

**输入**: Code changes, Evidence
**输出**: Review verdict

**机制**:
- 调用 `/self-review` skill
- Codex 独立审查
- 迭代改进直到 PASS

**检查点**: PASS / IMPROVE loop

---

## 3. Directory Structure

### 3.1 Project-Level Structure

```
project/
├── .agent/                          # AI 工作流配置根目录
│   ├── config.yaml                  # 全局配置
│   ├── constitution.md              # 项目原则和约束
│   │
│   ├── specs/                       # 规范目录
│   │   └── {feature-id}/
│   │       ├── spec.md              # 需求规范
│   │       ├── plan.md              # 技术计划
│   │       └── tasks.md             # 任务分解
│   │
│   ├── templates/                   # 模板目录
│   │   ├── spec.md                  # 规范模板
│   │   ├── plan.md                  # 计划模板
│   │   └── tasks.md                 # 任务模板
│   │
│   └── hooks/                       # 钩子脚本
│       ├── pre-implement.sh         # 实现前检查
│       └── post-implement.sh        # 实现后验证
│
├── .tasks/                          # 任务执行记录
│   └── self-review/                 # self-review 任务
│       └── {task-name}/
│           ├── 00-task-spec.md
│           ├── evidence/
│           ├── reviews/
│           └── final-report.md
│
├── CLAUDE.md                        # Claude Code 项目配置
└── ... (项目代码)
```

### 3.2 Feature Spec Structure

```
.agent/specs/{feature-id}/
├── spec.md                          # What & Why
│   ├── ## Overview
│   ├── ## Requirements
│   ├── ## Acceptance Criteria
│   └── ## Constraints
│
├── plan.md                          # How
│   ├── ## Technical Approach
│   ├── ## Architecture Decisions
│   ├── ## Dependencies
│   └── ## Risks
│
└── tasks.md                         # Actions
    ├── ## Task List
    │   ├── [ ] [T][P] Task 1 - Write tests for X
    │   ├── [ ] Task 2 - Implement X
    │   └── [ ] [P] Task 3 - Implement Y (parallel with 2)
    └── ## Notes
```

### 3.3 Task Markers

| 标记 | 含义 | 说明 |
|------|------|------|
| `[T]` | Test-First | 该任务需要先写测试 |
| `[P]` | Parallelizable | 可与其他 [P] 任务并行 |
| `[R]` | Requires Review | 完成后需要人工审查 |
| `[D]` | Documentation | 文档更新任务 |

---

## 4. Configuration Files

### 4.1 `.agent/config.yaml`

```yaml
# AI Workflow Configuration
version: "1.0"

# 工作流设置
workflow:
  # 阶段启用
  phases:
    specify: true
    plan: true
    tasks: true
    implement: true
    review: true

  # 人工审批点 (Full Mode 默认，Quick Mode 可全部设 false)
  checkpoints:
    after_specify: true      # 规范后需审批
    after_plan: true         # 计划后需审批
    after_tasks: true        # 任务分解后需审批 (Full Mode)

  # 自动化程度
  automation:
    auto_commit: true        # 自动提交
    auto_test: true          # 自动运行测试
    auto_lint: true          # 自动 lint

# 审查设置
review:
  engine: "codex"            # codex | claude | manual
  max_rounds: 3
  early_exit_confidence: 0.9

# TDD 设置
tdd:
  enabled: true
  test_first: "recommended"       # required | recommended | optional

# 工具配置 (与 templates/config.yaml 一致)
tools:
  test:
    command: "npm test"
    coverage: "npm test -- --coverage"
  lint:
    command: "npm run lint"
    fix: "npm run lint -- --fix"
  build:
    command: "npm run build"
```

### 4.2 `.agent/constitution.md`

```markdown
# Project Constitution

## Identity
- 项目名称: {project-name}
- 技术栈: {tech-stack}
- 团队规模: {team-size}

## Principles
1. **代码质量**: 所有代码必须有测试覆盖
2. **安全优先**: 不允许硬编码敏感信息
3. **简洁性**: 优先选择简单方案

## Constraints
- 不使用 any 类型 (TypeScript)
- 函数不超过 50 行
- 文件不超过 300 行

## Conventions
- 命名: camelCase for functions, PascalCase for classes
- 注释: 只注释 why, 不注释 what
- 提交: conventional commits 格式
```

### 4.3 `CLAUDE.md` (项目级)

```markdown
# CLAUDE.md

## Project Overview
{项目描述}

## Architecture
{架构说明}

## Development Commands
- `npm run dev` - Start development server
- `npm test` - Run tests
- `npm run build` - Production build

## AI Workflow
本项目使用 `.agent/` 目录管理 AI 工作流。

### 启动新功能
1. 创建规范: `/specify {feature-name}`
2. 制定计划: `/plan`
3. 分解任务: `/tasks`
4. 执行实现: 按 tasks.md 逐个实现
5. 审查验收: `/self-review`

### 目录约定
- `.agent/specs/` - 功能规范
- `.tasks/self-review/` - 审查记录

## Coding Standards
{参考 .agent/constitution.md}
```

---

## 5. Integration with Existing Skills

### 5.1 Skill Mapping

| 阶段 | 可用 Skill | 说明 |
|------|-----------|------|
| SPECIFY | `/task-planner` | 帮助分析和规划任务 |
| PLAN | `/research` | 技术调研支持 |
| TASK | `/parallel-task-planner` | 并行任务识别 |
| IMPLEMENT | `/codex` | 代码生成 |
| REVIEW | `/self-review` | 独立审查 |
| REVIEW | `/task-code-reviewer` | 任务代码审查 |

### 5.2 Workflow Commands

工作流命令分为两类：**现有 Skills** 和 **手动操作**。

#### 现有 Skills (可直接使用)

```bash
# 规划辅助
/task-planner               # 帮助分析和规划任务
/parallel-task-planner      # 识别并行任务机会
/research {topic}           # 技术调研

# 执行与审查
/codex {prompt}             # 代码生成
/self-review                # 独立审查
/task-code-reviewer         # 任务代码审查

# 文档
/doc-writer                 # 生成文档
```

#### 手动操作 (基于模板)

由于 `/specify`, `/plan`, `/tasks` 暂未作为独立 skill 实现，
当前采用**手动模板+AI辅助**的方式：

```bash
# Step 1: SPECIFY - 创建规范
mkdir -p .agent/specs/{feature-id}
# 复制模板并填写
cp .agent/templates/spec.md .agent/specs/{feature-id}/
# 使用 /task-planner 帮助分析需求

# Step 2: PLAN - 制定计划
cp .agent/templates/plan.md .agent/specs/{feature-id}/
# 使用 /research 进行技术调研

# Step 3: TASKS - 分解任务
cp .agent/templates/tasks.md .agent/specs/{feature-id}/
# 使用 /parallel-task-planner 识别并行机会
```

**Note**: 未来可将 `/specify`, `/plan`, `/tasks` 实现为独立 skills 以简化流程。

---

## 6. Quick Start Guide

### Step 1: 初始化项目

```bash
# 创建 .agent 目录结构
mkdir -p .agent/{specs,templates,hooks}

# 创建配置文件
touch .agent/config.yaml
touch .agent/constitution.md

# 创建 CLAUDE.md
touch CLAUDE.md
```

### Step 2: 创建第一个功能规范

```bash
# 创建功能目录
mkdir -p .agent/specs/feature-001-user-auth

# 编写规范
# 使用 /specify 命令或手动创建 spec.md
```

### Step 3: 执行工作流

```
1. /specify user-auth        → 输出 spec.md
2. /plan                     → 输出 plan.md
3. /tasks                    → 输出 tasks.md
4. 按 tasks.md 逐个实现
5. /self-review              → 独立审查
```

---

## 7. Workflow Variants

### 7.1 Quick Mode (快速模式)

适用于简单任务，跳过部分阶段：

```
需求 → TASK → IMPLEMENT → (light review)
```

配置:
```yaml
workflow:
  phases:
    specify: false
    plan: false
    tasks: true
    implement: true
    review: true  # light review only
```

### 7.2 Full Mode (完整模式)

适用于复杂功能：

```
需求 → SPECIFY → PLAN → TASK → IMPLEMENT → REVIEW → DELIVER
       ↑          ↑       ↑
    [审批]     [审批]  [审批]
```

### 7.3 Research Mode (研究模式)

适用于技术调研：

```
问题 → RESEARCH → REPORT → REVIEW
```

---

## 8. Appendix

### A. Template Files

参见 `.agent/templates/` 目录

### B. Hook Scripts

参见 `.agent/hooks/` 目录

### C. Migration Guide

从其他工作流迁移:
- Spec-Kit: 将 `.specify/` 重命名为 `.agent/specs/`
- BMAD: 导出 workflow YAML 到 `.agent/config.yaml`

---

*Design by Claude | Based on AI Workflow Research 2026-01-12*
