# SPECIFY Phase Research Report

> **Task ID**: specify-phase-research-20260113
> **Date**: 2026-01-13
> **Status**: PASS (Reviewed by Codex, 2 rounds)

---

## Executive Summary

本调研旨在为 AI 工作流框架的 SPECIFY (需求澄清) 阶段提供最佳实践指导。核心发现：

1. **SPECIFY 的核心目标**: 捕获 "什么" 和 "为什么"，有意排除 "怎么做"
2. **AI 时代的变化**: 从 "写给人看的文档" 变为 "AI 可执行的规范"
3. **关键成功因素**: 结构化、可验证、可追溯

---

## Part 1: Traditional Requirements Best Practices

### 1.0 Requirements Analysis Methodology Overview

**需求分析的核心方法论**:

| 方法 | 描述 | 适用场景 |
|------|------|----------|
| **瀑布式** | 前期完整定义所有需求 | 需求稳定的大型项目 |
| **敏捷迭代** | 渐进式细化，每迭代交付 | 需求变化快的项目 |
| **用户中心设计** | 从用户任务和目标出发 | 用户体验敏感产品 |
| **领域驱动设计** | 与领域专家协作建模 | 复杂业务逻辑系统 |

**需求分析的关键活动**:
1. **需求获取 (Elicitation)** - 通过访谈、观察、原型等收集需求
2. **需求分析 (Analysis)** - 识别冲突、优先级排序、可行性评估
3. **需求规范 (Specification)** - 文档化为结构化格式
4. **需求验证 (Validation)** - 与利益相关者确认

**来源**: [IEEE 830 - Software Requirements Specification](https://standards.ieee.org/standard/830-1998.html), [BABOK Guide](https://www.iiba.org/career-resources/a-business-analysis-professionals-foundation-for-success/babok/)

### 1.1 User Stories

**标准格式**:
```
As a [user role],
I want to [perform some action],
So that I can [achieve some benefit].
```

**INVEST 原则**:
| 原则 | 说明 |
|------|------|
| **I**ndependent | 故事独立，可单独实现 |
| **N**egotiable | 可协商，不是合同 |
| **V**aluable | 对用户有价值 |
| **E**stimable | 可估算工作量 |
| **S**mall | 足够小，可在一个迭代完成 |
| **T**estable | 可测试验证 |

**来源**: [Requirements vs User Stories - TechTarget](https://www.techtarget.com/searchsoftwarequality/tip/Requirements-vs-user-stories-in-software-development)

### 1.2 Acceptance Criteria

**两种格式**:

#### Rule-Based (规则式)
```markdown
Acceptance Criteria:
1. Email must be valid format (xxx@xxx.xxx)
2. Password must be at least 8 characters
3. Password must contain at least one number
4. Form shows error message for invalid inputs
```

#### Scenario-Based (场景式 - Gherkin/BDD)
```gherkin
Scenario: Successful login
  Given a registered user on the login page
  When they enter valid credentials
  Then they are redirected to the dashboard
  And a success message is displayed
```

**最佳实践**:
- 每个用户故事应有 3-7 个验收标准 (来源: [Atlassian - Acceptance Criteria](https://www.atlassian.com/agile/project-management/acceptance-criteria))
- 使用可测量的语言 (避免 "快速"、"简单")
- 包含正向和负向场景

**来源**: [Software Requirements Specification Guide](https://aqua-cloud.io/how-write-effective-software-requirements-specification/), [Atlassian - Acceptance Criteria](https://www.atlassian.com/agile/project-management/acceptance-criteria)

### 1.3 Non-Functional Requirements (NFR)

**常被忽视但关键**:

| 类型 | 差的写法 | 好的写法 |
|------|----------|----------|
| 性能 | "系统必须快" | "API 响应时间 < 200ms，P99" |
| 可用性 | "系统必须可靠" | "可用性 99.9%，月停机 < 43 分钟" |
| 安全 | "系统必须安全" | "所有 API 需 JWT 认证，敏感数据 AES-256 加密" |

**来源**: [Red Hat - Spec-Driven Development](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)

---

## Part 2: AI-Era SPECIFY Best Practices

### 2.1 Spec-Driven Development (SDD) 核心理念

**为什么需要 SDD**:
> "AI coding agents are most effective when given clear structure and guidance. Handing them a vague instruction like 'refactor this module' can result in unpredictable outcomes."
> — [JetBrains Junie Blog](https://blog.jetbrains.com/junie/2025/10/how-to-use-a-spec-driven-approach-for-coding-with-ai/)

**SDD 工作流**:
```
Constitution → Specify → Clarify → Plan → Tasks → Implement
```

**Spec 的核心价值**:
- 人类定义 "什么" (功能目标) 和 "怎么做的规则" (标准、架构)
- AI 处理繁重工作 (代码生成)
- Spec 成为 "单一事实来源"

**来源**: [GitHub Blog - Spec-Driven Development](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/)

### 2.2 Context Engineering

**定义**:
> "Prompt engineering was about cleverly phrasing a question; context engineering is about constructing an entire information environment so the AI can solve the problem reliably."
> — [The New Skill in AI is Context Engineering](https://www.philschmid.de/context-engineering)

**结构化上下文的组成**:

| 组件 | 说明 |
|------|------|
| User Prompt | 当前任务或问题 |
| State/History | 短期记忆（当前对话） |
| Long-Term Memory | 持久知识（历史对话） |
| Retrieved Info | RAG 检索的外部知识 |
| Available Tools | AI 可调用的工具定义 |
| Structured Output | 输出格式定义 |

**Anthropic 最佳实践**:
- 使用 XML 标签或 Markdown 标题划分区域
- 将 context 视为有限资源，每个 token 都消耗 "注意力预算"
- 使用压缩、笔记、子代理等技术管理长上下文

**来源**: [Anthropic - Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)

### 2.3 Prompt Engineering for Requirements

**需求表达的 Prompt 设计原则**:

| 原则 | 差的示例 | 好的示例 |
|------|----------|----------|
| **具体化** | "让登录更好" | "添加 OAuth2 登录支持 Google 账号" |
| **结构化** | 一大段描述 | 分为目标、约束、验收标准 |
| **可量化** | "响应要快" | "API 响应 P95 < 200ms" |
| **边界明确** | "处理错误" | "网络超时显示重试按钮；认证失败跳转登录" |

**需求 Prompt 的关键要素**:
```markdown
## Task Context
{背景信息和现状}

## Goal
{具体目标，使用动词开头}

## Constraints
- 技术约束: {如框架、依赖}
- 业务约束: {如时间、合规}

## Acceptance Criteria
- [ ] {可验证的条件 1}
- [ ] {可验证的条件 2}

## Out of Scope
- {明确排除的内容}
```

**为什么需要区分 Prompt Engineering 和 Context Engineering**:
- Prompt Engineering: 关注单个请求的措辞技巧
- Context Engineering: 关注整个信息环境的构建
- 在 SPECIFY 阶段，两者都重要：Prompt 技巧用于与 AI 交互获取需求，Context 工程用于组织最终规范

**来源**: [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering), [Anthropic Prompt Design](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering)

### 2.4 Clarify Stage (澄清阶段)

**目的**: 消除需求和范围的模糊性

**检查点**:
- [ ] 缺失的约束或假设?
- [ ] 冲突的需求?
- [ ] 边界情况是否需要确认或排除?

**黄金标准**:
> "Your specification should be detailed enough that another developer could implement it without asking clarifying questions."
> — [Zencoder - SDD Guide](https://docs.zencoder.ai/user-guides/tutorials/spec-driven-development-guide)

**来源**: [Zencoder - SDD Guide](https://docs.zencoder.ai/user-guides/tutorials/spec-driven-development-guide), [AI Native Dev - 10 Things About Specs](https://ainativedev.io/news/spec-driven-development-10-things-you-need-to-know-about-specs)

---

## Part 3: Tool Analysis

### 3.1 GitHub Spec-Kit `/specify`

**命令目的**: 创建功能规范，捕获 "什么" 和 "为什么"

**输出结构** (`spec.md`):
- User Stories (用户视角的功能描述)
- Functional Requirements (详细行为期望)
- Review & Acceptance Checklist (验证标准)

**关键原则**:
> "Be as explicit as possible about what you are trying to build and why. Do not focus on the tech stack at this point."

**来源**: [GitHub Spec-Kit Repository](https://github.com/github/spec-kit)

### 3.2 Kiro IDE Requirements Phase

**三阶段工作流**:
1. **Requirements** - 使用 EARS 格式的用户故事和验收标准
2. **Design** - 技术架构和实现方式
3. **Tasks** - 自动跟踪的实现步骤

**EARS (Easy Approach to Requirements Syntax)**:
```
While [condition], the [system] shall [action].
When [trigger], the [system] shall [action].
Where [feature], the [system] shall [action].
```

**最佳实践**:
- 为大型项目创建多个聚焦的规范
- 将规范存储在项目仓库中
- 使用 MCP 集成导入已有需求

**来源**: [Kiro - Best Practices](https://kiro.dev/docs/specs/best-practices/), [Kiro - First Project](https://kiro.dev/docs/getting-started/first-project/)

### 3.3 BMAD-METHOD Analyst Agent

**工作流**:
```
Analyst Agent → project_brief.md
PM Agent → prd.md (依赖 project_brief)
```

**Analyst Agent 职责**:
- 从用户需求中提取核心问题
- 识别利益相关者
- 定义成功标准
- 输出项目简报

**来源**: [BMAD-METHOD GitHub](https://github.com/bmad-code-org/BMAD-METHOD)

---

## Part 4: SPECIFY Phase Design Recommendations

### 4.1 SPECIFY 阶段定位

```
┌─────────────────────────────────────────────────────────────┐
│                     SPECIFY 阶段                            │
├─────────────────────────────────────────────────────────────┤
│  输入: 用户需求 (模糊的想法、问题描述)                        │
│                                                             │
│  核心活动:                                                   │
│  1. 需求捕获 - 理解 "什么" 和 "为什么"                       │
│  2. 需求澄清 - 消除模糊性，确认假设                          │
│  3. 需求结构化 - 转换为 AI 可执行的格式                      │
│                                                             │
│  输出: spec.md (结构化规范文档)                              │
│                                                             │
│  检查点: Human Approval (人工确认)                           │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 SPECIFY 子阶段

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│ CAPTURE │ → │ CLARIFY │ → │ STRUCTURE│ → │ VALIDATE│
│  捕获   │     │  澄清   │     │  结构化 │     │  验证   │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
    │               │               │               │
    ↓               ↓               ↓               ↓
理解原始需求     消除模糊性     转为标准格式    人工审批
```

### 4.3 spec.md 模板结构

```markdown
# Feature Specification: {feature-name}

## 1. Overview
{一句话描述功能和价值}

## 2. Problem Statement
{要解决的问题，当前痛点}

## 3. User Stories
### US-1: {故事标题}
As a [user role],
I want to [action],
So that I can [benefit].

**Acceptance Criteria**:
- [ ] AC-1: ...
- [ ] AC-2: ...

### US-2: ...

## 4. Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1 | ... | Must |
| FR-2 | ... | Should |

## 5. Non-Functional Requirements
| ID | Type | Requirement |
|----|------|-------------|
| NFR-1 | Performance | API < 200ms |
| NFR-2 | Security | JWT auth required |

## 6. Constraints & Assumptions
### Constraints
- ...

### Assumptions
- ...

## 7. Out of Scope
- ...

## 8. Open Questions
- [ ] ...

## 9. Acceptance Checklist
- [ ] All user stories have acceptance criteria
- [ ] NFRs are measurable
- [ ] No conflicting requirements
- [ ] Stakeholder approved
```

### 4.4 Clarify Checklist

执行 SPECIFY 时应确认：

**需求完整性**:
- [ ] 所有用户角色已识别?
- [ ] 正向和负向场景已覆盖?
- [ ] 边界情况已考虑?

**需求清晰度**:
- [ ] 无模糊词汇 ("快速"、"简单"、"友好")?
- [ ] 所有缩写已定义?
- [ ] 术语表已建立?

**需求一致性**:
- [ ] 无冲突的需求?
- [ ] 优先级已明确?
- [ ] 依赖关系已识别?

**可测试性**:
- [ ] 每个需求可验证?
- [ ] 验收标准可量化?

---

## Part 5: Sources

### Official Documentation
- [GitHub Spec-Kit](https://github.com/github/spec-kit)
- [Kiro IDE Docs](https://kiro.dev/docs/)
- [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)

### Research Articles
- [Anthropic - Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [JetBrains - Spec-Driven Approach](https://blog.jetbrains.com/junie/2025/10/how-to-use-a-spec-driven-approach-for-coding-with-ai/)
- [Red Hat - SDD Improves AI Quality](https://developers.redhat.com/articles/2025/10/22/how-spec-driven-development-improves-ai-coding-quality)
- [The New Skill is Context Engineering](https://www.philschmid.de/context-engineering)

### Community Resources
- [Martin Fowler - SDD Tools](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html)
- [AI Native Dev - 10 Things About Specs](https://ainativedev.io/news/spec-driven-development-10-things-you-need-to-know-about-specs)
- [Zencoder - SDD Guide](https://docs.zencoder.ai/user-guides/tutorials/spec-driven-development-guide)

---

*Report generated by Self-Review Skill | 2026-01-13*
