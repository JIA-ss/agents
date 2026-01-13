# SPECIFY Phase Design Document

> **Task ID**: specify-phase-design-20260113
> **Date**: 2026-01-13
> **Status**: PASS (Reviewed by Codex, 4 rounds)
> **Depends On**: specify-phase-research-20260113

---

## 1. Overview

### 1.1 SPECIFY 阶段定位

```
用户需求 (模糊) ──→ [SPECIFY] ──→ spec.md (结构化)
                       │
                       ├── CAPTURE (捕获)
                       ├── CLARIFY (澄清)
                       ├── STRUCTURE (结构化)
                       └── VALIDATE (验证)
```

**核心目标**: 将模糊的用户需求转化为 AI 可执行的结构化规范

### 1.2 设计原则

| 原则 | 说明 |
|------|------|
| **渐进式** | 每个子阶段产出可验证的中间产物 |
| **可追溯** | 需求 → 规范 → 验收标准全程可追溯 |
| **可中断** | 任何子阶段可暂停、恢复 |
| **可验证** | 每个阶段有明确的验收标准 |

---

## 2. 子阶段架构设计

### 2.1 四阶段模型

```
┌─────────────────────────────────────────────────────────────────────┐
│                        SPECIFY Phase                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │ CAPTURE  │ ─→ │ CLARIFY  │ ─→ │ STRUCTURE│ ─→ │ VALIDATE │      │
│  │  捕获    │    │  澄清    │    │  结构化  │    │  验证    │      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘      │
│       │              │               │               │              │
│       ▼              ▼               ▼               ▼              │
│   raw-notes.md   clarified.md    spec.md        spec.md            │
│   (原始笔记)     (澄清记录)     (草稿)         (定稿)              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### 2.2 各阶段详细定义

#### 2.2.1 CAPTURE (捕获阶段)

**职责**: 收集和理解原始需求

**递归分解**:
```
CAPTURE
├── C1: Context Gathering (上下文收集)
│   ├── 项目背景
│   ├── 现有系统状态
│   └── 相关文档/代码
│
├── C2: Stakeholder Identification (利益相关者识别)
│   ├── 用户角色
│   ├── 影响范围
│   └── 决策者
│
└── C3: Raw Requirements Extraction (原始需求提取)
    ├── 功能性需求
    ├── 非功能性需求
    └── 约束条件
```

**输入**:
| 输入项 | 来源 | 必需 |
|--------|------|------|
| 用户请求 | 用户输入 | 是 |
| 项目上下文 | CLAUDE.md, constitution.md | 否 |
| 历史需求 | .agent/specs/ | 否 |

**输出**:
```yaml
# .agent/specs/{feature}/capture/raw-notes.md
type: capture_output
sections:
  - context_summary      # 上下文摘要
  - stakeholders         # 利益相关者列表
  - raw_requirements     # 原始需求列表
  - initial_constraints  # 初始约束
  - open_questions       # 待澄清问题
metrics:
  - open_questions_count # 待澄清问题数量
  - ambiguity_score      # 模糊度评分 (0=清晰, >0=需澄清)
  - ambiguity_detected   # 布尔值: ambiguity_score > 0
```

**子阶段验收标准**:
- [ ] 上下文信息已收集完整
- [ ] 所有用户角色已识别
- [ ] 原始需求已列出（无论是否清晰）
- [ ] 待澄清问题已标记

---

#### 2.2.2 CLARIFY (澄清阶段)

**职责**: 消除模糊性，确认假设

**递归分解**:
```
CLARIFY
├── CL1: Ambiguity Detection (模糊检测)
│   ├── 模糊词汇识别 ("快速", "简单", "友好")
│   ├── 隐含假设识别
│   └── 缺失信息识别
│
├── CL2: Question Generation (问题生成)
│   ├── 优先级排序
│   ├── 问题分类 (必要/可选)
│   └── 默认值建议
│
└── CL3: Clarification Resolution (澄清解决)
    ├── 用户确认
    ├── 假设记录
    └── 决策日志
```

**输入**:
| 输入项 | 来源 | 必需 |
|--------|------|------|
| raw-notes.md | CAPTURE 输出 | 是 |
| 项目约束 | constitution.md | 否 |

**输出**:
```yaml
# .agent/specs/{feature}/clarify/clarified.md
type: clarify_output
sections:
  - resolved_questions    # 已解决的问题
  - confirmed_assumptions # 已确认的假设
  - decisions_log         # 决策日志
  - remaining_ambiguities # 剩余模糊点（接受风险）
```

**子阶段验收标准**:
- [ ] 所有模糊词汇已量化或移除
- [ ] 关键假设已与用户确认
- [ ] 决策有记录可追溯
- [ ] 剩余风险已明确接受

---

#### 2.2.3 STRUCTURE (结构化阶段)

**职责**: 将澄清后的需求转化为标准格式

**递归分解**:
```
STRUCTURE
├── S1: User Story Composition (用户故事编写)
│   ├── 故事模板填充
│   ├── INVEST 原则检查
│   └── 故事拆分（如需要）
│
├── S2: Acceptance Criteria Definition (验收标准定义)
│   ├── 每个故事的 AC
│   ├── 正向/负向场景
│   └── 边界条件
│
├── S3: Requirements Classification (需求分类)
│   ├── 功能需求 (FR)
│   ├── 非功能需求 (NFR)
│   └── 优先级标记 (Must/Should/Could)
│
└── S4: Scope Definition (范围定义)
    ├── 明确包含项
    ├── 明确排除项
    └── 依赖识别
```

**输入**:
| 输入项 | 来源 | 必需 |
|--------|------|------|
| clarified.md | CLARIFY 输出 | 是 |
| spec 模板 | .agent/templates/spec.md | 是 |
| 项目标准 | constitution.md | 否 |

**输出**:
```yaml
# .agent/specs/{feature}/spec.md (草稿)
type: structure_output
status: draft
sections:
  - overview
  - problem_statement
  - user_stories[]
  - functional_requirements[]
  - non_functional_requirements[]
  - constraints_and_assumptions
  - out_of_scope
  - open_questions
```

**子阶段验收标准**:
- [ ] 所有用户故事符合 INVEST 原则
- [ ] 每个故事有 3-7 个验收标准
- [ ] NFR 均可量化
- [ ] 范围边界清晰

---

#### 2.2.4 VALIDATE (验证阶段)

**职责**: 人工审批，确保规范可执行

**递归分解**:
```
VALIDATE
├── V1: Completeness Check (完整性检查)
│   ├── 模板必填项检查
│   ├── 引用完整性
│   └── 覆盖度分析
│
├── V2: Consistency Check (一致性检查)
│   ├── 需求间冲突检测
│   ├── 与项目约束一致性
│   └── 术语一致性
│
├── V3: Feasibility Check (可行性检查)
│   ├── 技术可行性
│   ├── 资源可行性
│   └── 时间约束
│
└── V4: Stakeholder Approval (利益相关者审批)
    ├── 规范展示
    ├── 反馈收集
    └── 签字确认
```

**输入**:
| 输入项 | 来源 | 必需 |
|--------|------|------|
| spec.md (草稿) | STRUCTURE 输出 | 是 |
| Validation Checklist | 内置 | 是 |

**输出**:
```yaml
# .agent/specs/{feature}/spec.md (定稿)
type: validate_output
status: approved | rejected | needs_revision
sections:
  - (继承 STRUCTURE 输出)
  - acceptance_checklist  # 新增：验收清单
metadata:
  approved_by: {user}
  approved_at: {timestamp}
  version: 1.0
```

**子阶段验收标准**:
- [ ] 完整性检查通过
- [ ] 无冲突需求
- [ ] 用户已审批签字
- [ ] spec.md 状态标记为 approved

---

## 3. spec.md 模板设计

### 3.1 模板与子阶段映射

```
spec.md 章节                    填充阶段          更新阶段
─────────────────────────────────────────────────────────────
Header (元数据)                 CAPTURE           VALIDATE
1. Overview                     CAPTURE           STRUCTURE
2. Problem Statement            CAPTURE           CLARIFY
3. User Stories                 STRUCTURE         VALIDATE
4. Functional Requirements      STRUCTURE         VALIDATE
5. Non-Functional Requirements  STRUCTURE         VALIDATE
6. Constraints & Assumptions    CAPTURE           CLARIFY
7. Out of Scope                 CLARIFY           STRUCTURE
8. Open Questions               CAPTURE           → 逐步减少
9. Acceptance Checklist         VALIDATE          VALIDATE
```

### 3.2 完整模板

```markdown
# Feature Specification: {feature-name}

> **Spec ID**: {project}-{feature}-{date}
> **Status**: draft | in_review | approved | superseded
> **Version**: {major}.{minor}
> **Author**: {author}
> **Approved By**: {approver} (if approved)
> **Last Updated**: {timestamp}

---

## 1. Overview

{一句话描述功能和价值}

**Target Users**: {目标用户角色列表}

**Success Metrics**:
- {可量化的成功指标 1}
- {可量化的成功指标 2}

---

## 2. Problem Statement

### 2.1 Current State
{当前状态描述}

### 2.2 Pain Points
- {痛点 1}
- {痛点 2}

### 2.3 Desired Outcome
{期望达成的结果}

---

## 3. User Stories

### US-1: {故事标题}

**Priority**: Must | Should | Could

```
As a {user role},
I want to {action},
So that I can {benefit}.
```

**Acceptance Criteria**:
- [ ] AC-1.1: {验收标准 - 正向场景}
- [ ] AC-1.2: {验收标准 - 正向场景}
- [ ] AC-1.3: {验收标准 - 负向场景}
- [ ] AC-1.4: {验收标准 - 边界条件}

**Notes**: {补充说明}

---

### US-2: {故事标题}
...

---

## 4. Functional Requirements

| ID | Requirement | Priority | Linked US |
|----|-------------|----------|-----------|
| FR-1 | {需求描述} | Must | US-1 |
| FR-2 | {需求描述} | Should | US-1, US-2 |
| FR-3 | {需求描述} | Could | US-3 |

---

## 5. Non-Functional Requirements

| ID | Type | Requirement | Verification |
|----|------|-------------|--------------|
| NFR-1 | Performance | API P95 < 200ms | Load test |
| NFR-2 | Security | JWT auth required | Security audit |
| NFR-3 | Reliability | 99.9% uptime | Monitoring |
| NFR-4 | Scalability | Support 10K concurrent | Stress test |

---

## 6. Constraints & Assumptions

### 6.1 Constraints
| Type | Description | Source |
|------|-------------|--------|
| Technical | 必须使用现有认证系统 | Architecture |
| Business | 不能修改现有 API 接口 | Compatibility |
| Resource | 无额外基础设施预算 | Budget |

### 6.2 Assumptions
| ID | Assumption | Risk if Wrong | Validated |
|----|------------|---------------|-----------|
| A-1 | 用户已有有效账户 | 需新增注册流程 | Yes |
| A-2 | 网络延迟 < 100ms | 需增加超时处理 | No |

---

## 7. Out of Scope

以下内容明确不在本次需求范围内：

- {排除项 1} - 原因: {原因}
- {排除项 2} - 原因: {原因}
- {排除项 3} - 原因: {原因}

---

## 8. Open Questions

| ID | Question | Owner | Status | Resolution |
|----|----------|-------|--------|------------|
| Q-1 | {问题描述} | {负责人} | Open/Resolved | {解决方案} |

---

## 9. Acceptance Checklist

### 9.1 Completeness
- [ ] All user stories have acceptance criteria
- [ ] All FRs linked to user stories
- [ ] All NFRs have verification methods
- [ ] All assumptions validated or risk-accepted

### 9.2 Quality
- [ ] No ambiguous terms remain
- [ ] No conflicting requirements
- [ ] All open questions resolved or risk-accepted

### 9.3 Approval
- [ ] Technical review completed
- [ ] Stakeholder review completed
- [ ] Final approval obtained

---

## Appendix

### A. Glossary
| Term | Definition |
|------|------------|
| {术语} | {定义} |

### B. References
- {参考文档 1}
- {参考文档 2}

### C. Change History
| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | {date} | {author} | Initial draft |
| 1.0 | {date} | {author} | Approved version |

---

*Generated by /specify skill*
```

### 3.3 模板变体（按规模）

| 规模 | 使用场景 | 省略章节 | 必需章节 |
|------|----------|----------|----------|
| **Mini** | 简单 bug fix, 小改动 | 2 (Problem), 4 (FR), 5 (NFR), 6 (Constraints), 8 (Questions), Appendix | 1 (Overview), 3 (US+AC), 7 (Out of Scope), 9 (Checklist) |
| **Standard** | 中等功能 | Appendix A (Glossary) | 1-7, 9 (Checklist) |
| **Full** | 大型功能/新项目 | 无 | 全部章节 (1-9, Appendix A-C) |

**重要**:
- 验证规则按模式自适应，见 4.3 节
- 章节编号对应 spec.md 模板中的章节号
- 必需章节 = 验证时检查的章节

---

## 4. 验收标准和 Checklist

### 4.1 阶段性验收标准

#### CAPTURE 阶段验收
```yaml
capture_acceptance:
  required:
    - context_documented: true
    - stakeholders_identified: true
    - raw_requirements_listed: true
  quality:
    # 条件性：仅当检测到模糊点时要求
    - open_questions_count: ">= 1"
      condition: "ambiguity_detected == true"
```

#### CLARIFY 阶段验收
```yaml
clarify_acceptance:
  required:
    - ambiguous_terms_resolved: true
    - assumptions_confirmed: true
    - decisions_logged: true
  quality:
    # 条件性：仅当有待澄清问题时要求
    - open_questions_reduced: true
      condition: "capture.open_questions_count > 0"
  # 对于无模糊性的请求，可跳过 CLARIFY 阶段
  # ambiguity_score 由 CAPTURE 阶段自动检测并输出到 raw-notes.md
  skip_condition: "capture.open_questions_count == 0 AND capture.ambiguity_score == 0"

# CAPTURE 阶段输出的 ambiguity_score 计算规则:
# - 每个模糊词汇 (快速/简单/友好等) +1
# - 每个未定义的缩写 +1
# - 每个缺失边界条件 +1
# - ambiguity_score == 0 表示需求已足够清晰
```

#### STRUCTURE 阶段验收
```yaml
structure_acceptance:
  required:
    - user_stories_count: ">= 1"
    - each_story_has_ac: true
    - priorities_assigned: true
  quality:
    - invest_check_passed: true
    - ac_count_per_story: "3-7"
    - nfr_quantified: true
```

#### VALIDATE 阶段验收
```yaml
validate_acceptance:
  required:
    - completeness_check: passed
    - consistency_check: passed
    - stakeholder_approved: true
  quality:
    - open_questions_count: 0  # 或已接受风险
    - spec_status: approved
```

### 4.2 最终验收 Checklist

```markdown
## SPECIFY Phase Final Checklist

### Content Quality
- [ ] **CQ-1**: Overview 清晰表达功能价值
- [ ] **CQ-2**: Problem Statement 有具体痛点
- [ ] **CQ-3**: User Stories 符合 As a/I want/So that 格式
- [ ] **CQ-4**: 每个 US 有 3-7 个 AC
- [ ] **CQ-5**: AC 包含正向、负向、边界场景
- [ ] **CQ-6**: FR 与 US 有明确映射
- [ ] **CQ-7**: NFR 全部可量化
- [ ] **CQ-8**: 约束和假设有来源标注

### Completeness
- [ ] **CP-1**: 所有模板必填字段已填写
- [ ] **CP-2**: 无 TODO 或占位符残留
- [ ] **CP-3**: Out of Scope 明确定义
- [ ] **CP-4**: Open Questions 为空或已接受风险

### Consistency
- [ ] **CS-1**: 术语使用一致
- [ ] **CS-2**: 需求间无冲突
- [ ] **CS-3**: 与 constitution.md 一致
- [ ] **CS-4**: 优先级分布合理 (Must < 60%)

### Traceability
- [ ] **TR-1**: 需求 → AC 可追溯
- [ ] **TR-2**: 假设 → 决策可追溯
- [ ] **TR-3**: 变更历史完整

### Approval
- [ ] **AP-1**: spec.md status = approved
- [ ] **AP-2**: approved_by 已填写
- [ ] **AP-3**: 版本号为 1.0+
```

### 4.3 自动化验证点

```yaml
# .agent/config.yaml 中的 SPECIFY 验证配置
specify:
  validation:
    # 按模式定义必需章节 (使用 spec.md 章节编号)
    # 章节映射: 1=overview, 2=problem_statement, 3=user_stories (含AC),
    #           4=functional_requirements, 5=non_functional_requirements,
    #           6=constraints_and_assumptions, 7=out_of_scope, 8=open_questions,
    #           9=acceptance_checklist, A=glossary, B=references, C=change_history
    #
    # 注意: 必须与 3.3 节模板变体表格保持一致
    required_sections:
      # Mini: 1, 3, 7, 9 (省略 2, 4, 5, 6, 8, Appendix)
      mini: [1_overview, 3_user_stories, 7_out_of_scope, 9_acceptance_checklist]
      # Standard: 1-7, 9 (省略 8, Appendix A)
      standard: [1_overview, 2_problem_statement, 3_user_stories, 4_functional_requirements,
                 5_non_functional_requirements, 6_constraints_and_assumptions,
                 7_out_of_scope, 9_acceptance_checklist]
      # Full: 全部
      full: [all]

    auto_checks:
      - name: template_completeness
        rule: "no empty required fields (mode-aware)"
        severity: BLOCKER
        modes: [mini, standard, full]

      - name: user_story_format
        rule: "matches 'As a .* I want .* So that .*'"
        severity: MAJOR
        modes: [mini, standard, full]

      - name: ac_count
        rule: "3 <= count <= 7 per US"
        severity: MINOR
        modes: [mini, standard, full]

      - name: nfr_quantified
        rule: "contains number or percentage"
        severity: MAJOR
        modes: [standard, full]  # Mini 模式不检查 NFR

      - name: constraints_documented
        rule: "6_constraints_and_assumptions section not empty"
        severity: MAJOR
        modes: [standard, full]  # Mini 模式不检查

      - name: change_history_complete
        rule: "change history has entries"
        severity: MINOR
        modes: [full]  # 仅 Full 模式检查

      - name: no_ambiguous_terms
        rule: "not contains ['快速', '简单', '友好', 'fast', 'simple', 'easy']"
        severity: MAJOR
        modes: [mini, standard, full]

      - name: priority_distribution
        rule: "Must <= 60%"
        severity: MINOR
        modes: [standard, full]
```

### 4.4 模式感知的 Checklist

```yaml
# Checklist 项按模式启用
checklist_by_mode:
  mini:
    enabled: [CQ-1, CQ-3, CQ-4, CQ-5, CP-1, CP-2, CP-3, CS-1, CS-2, AP-1, AP-2]
    disabled: [CQ-2, CQ-6, CQ-7, CQ-8, CP-4, CS-3, CS-4, TR-1, TR-2, TR-3, AP-3]

  standard:
    enabled: [CQ-1, CQ-2, CQ-3, CQ-4, CQ-5, CQ-6, CQ-7, CQ-8, CP-1, CP-2, CP-3, CP-4,
              CS-1, CS-2, CS-3, CS-4, TR-1, TR-2, AP-1, AP-2, AP-3]
    disabled: [TR-3]  # Change History 可选

  full:
    enabled: [all]
    disabled: []
```

---

## 5. Skill 交互设计

### 5.1 命令接口

```bash
# 基本用法
/specify {需求描述}

# 模板模式选项
/specify --mode={mini|standard|full} {需求描述}

# 交互模式选项
/specify --interactive {需求描述}    # 默认：每个子阶段暂停确认
/specify --guided {需求描述}         # AI 提供建议，用户选择
/specify --auto {需求描述}           # AI 做所有决策，仅最终确认

# 恢复/验证
/specify --resume {spec-id}          # 恢复之前的 SPECIFY 会话
/specify --validate {spec-id}        # 仅运行验证，不修改

# 子阶段单独执行
/specify capture {需求描述}
/specify clarify {spec-id}
/specify structure {spec-id}
/specify validate {spec-id}
```

**选项说明**:

| 选项 | 默认 | 说明 |
|------|------|------|
| `--mode` | standard | 模板规模：mini/standard/full |
| `--interactive` | 是 | 每个子阶段暂停等待用户确认 |
| `--guided` | 否 | AI 提供选项，用户选择 |
| `--auto` | 否 | AI 自动决策，仅最终审批 |
| `--resume` | - | 恢复指定 spec-id 的会话 |
| `--validate` | - | 仅验证现有 spec，不进入编辑流程 |

### 5.2 交互流程图

```
用户: /specify 添加用户登录功能
        │
        ▼
┌───────────────────────────────────────────────────────────────┐
│ CAPTURE 阶段                                                   │
├───────────────────────────────────────────────────────────────┤
│ AI: 让我先了解一些背景信息...                                   │
│                                                                │
│ [读取 CLAUDE.md, constitution.md]                              │
│ [扫描现有代码结构]                                              │
│                                                                │
│ AI: 我识别到以下上下文:                                         │
│ - 项目类型: Web 应用                                            │
│ - 现有认证: 无                                                  │
│ - 技术栈: React + Node.js                                       │
│                                                                │
│ AI: 关于登录功能，我有以下问题:                                 │
│ ┌─────────────────────────────────────────────────────────┐   │
│ │ Q1: 支持哪些登录方式?                                    │   │
│ │ [ ] 用户名/密码                                          │   │
│ │ [ ] OAuth (Google/GitHub)                               │   │
│ │ [ ] SSO                                                  │   │
│ └─────────────────────────────────────────────────────────┘   │
│                                                                │
│ 用户: 用户名/密码 + Google OAuth                                │
│                                                                │
│ [生成 raw-notes.md]                                            │
└───────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────┐
│ CLARIFY 阶段                                                   │
├───────────────────────────────────────────────────────────────┤
│ AI: 我检测到以下需要澄清的点:                                   │
│                                                                │
│ 1. 密码策略                                                    │
│    ┌─────────────────────────────────────────────────────┐    │
│    │ 密码最小长度应该是?                                  │    │
│    │ (•) 8 字符 (推荐)                                    │    │
│    │ ( ) 6 字符                                           │    │
│    │ ( ) 12 字符                                          │    │
│    │ ( ) 其他: ___                                        │    │
│    └─────────────────────────────────────────────────────┘    │
│                                                                │
│ 2. 登录失败处理                                                │
│    ┌─────────────────────────────────────────────────────┐    │
│    │ 连续失败多少次后锁定账户?                            │    │
│    │ (•) 5 次 (推荐)                                      │    │
│    │ ( ) 3 次                                             │    │
│    │ ( ) 不锁定                                           │    │
│    │ ( ) 其他: ___                                        │    │
│    └─────────────────────────────────────────────────────┘    │
│                                                                │
│ 用户: [选择选项或输入]                                         │
│                                                                │
│ AI: 我做了以下假设，请确认:                                     │
│ - [x] 使用 JWT 进行会话管理                                    │
│ - [x] Token 有效期 7 天                                        │
│ - [ ] 支持"记住我"功能                                         │
│                                                                │
│ 用户: 确认                                                     │
│                                                                │
│ [生成 clarified.md]                                            │
└───────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────┐
│ STRUCTURE 阶段                                                 │
├───────────────────────────────────────────────────────────────┤
│ AI: 正在将需求结构化为 spec.md...                               │
│                                                                │
│ [自动填充模板]                                                 │
│                                                                │
│ AI: 我生成了以下用户故事，请审核:                               │
│                                                                │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│ US-1: 用户密码登录 [Must]                                      │
│                                                                │
│ As a registered user,                                          │
│ I want to log in with email and password,                      │
│ So that I can access my account.                               │
│                                                                │
│ Acceptance Criteria:                                           │
│ - [ ] AC-1.1: 正确凭据 → 跳转首页                              │
│ - [ ] AC-1.2: 错误密码 → 显示错误消息                          │
│ - [ ] AC-1.3: 5次失败 → 账户锁定15分钟                         │
│ - [ ] AC-1.4: 空字段 → 显示验证错误                            │
│ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                │
│ [用户可编辑/确认]                                              │
│                                                                │
│ [生成 spec.md 草稿]                                            │
└───────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────┐
│ VALIDATE 阶段                                                  │
├───────────────────────────────────────────────────────────────┤
│ AI: 正在验证 spec.md...                                        │
│                                                                │
│ ✓ 完整性检查: PASSED                                           │
│   - 所有必填字段已填写                                         │
│   - 所有 US 有 AC                                              │
│                                                                │
│ ✓ 一致性检查: PASSED                                           │
│   - 无冲突需求                                                 │
│   - 术语一致                                                   │
│                                                                │
│ ⚠ 建议改进:                                                    │
│   - NFR-2 缺少具体数值 (响应时间)                               │
│                                                                │
│ AI: 请审核最终的 spec.md:                                       │
│ [显示完整 spec.md]                                             │
│                                                                │
│ ┌─────────────────────────────────────────────────────┐       │
│ │ [✓] 我已审核并批准此规范                            │       │
│ │ [ ] 需要修改                                        │       │
│ │ [ ] 取消                                            │       │
│ └─────────────────────────────────────────────────────┘       │
│                                                                │
│ 用户: [批准]                                                   │
│                                                                │
│ AI: ✅ spec.md 已保存到 .agent/specs/user-login/spec.md        │
│     状态: approved                                             │
│     下一步: 运行 /plan user-login 进入规划阶段                 │
└───────────────────────────────────────────────────────────────┘
```

### 5.3 状态管理

```yaml
# .agent/specs/{feature}/.state.yaml
spec_id: "myproject-user-login-20260113"
feature: user-login
current_phase: STRUCTURE  # CAPTURE | CLARIFY | STRUCTURE | VALIDATE | COMPLETED
started_at: "2026-01-13T10:00:00Z"
last_updated: "2026-01-13T10:30:00Z"

phases:
  CAPTURE:
    status: completed
    completed_at: "2026-01-13T10:10:00Z"
    output: capture/raw-notes.md

  CLARIFY:
    status: completed
    completed_at: "2026-01-13T10:20:00Z"
    output: clarify/clarified.md
    questions_asked: 5
    questions_resolved: 5

  STRUCTURE:
    status: in_progress
    output: spec.md
    user_stories_count: 3

  VALIDATE:
    status: pending

metadata:
  mode: standard  # mini | standard | full
  author: user
  resume_count: 0
```

### 5.4 交互模式

| 模式 | 触发条件 | 行为 |
|------|----------|------|
| **Interactive** | 默认 | 每个子阶段暂停等待用户确认 |
| **Guided** | 用户选择 | AI 提供建议，用户选择 |
| **Auto** | `--auto` 标志 | AI 做出所有决策，仅最终确认 |

### 5.5 错误处理

```yaml
error_handling:
  user_abort:
    action: save_state
    message: "进度已保存，使用 /specify --resume {spec-id} 继续"

  validation_failure:
    action: return_to_phase
    message: "验证失败，返回 {phase} 阶段修复"

  context_missing:
    action: prompt_user
    message: "缺少必要上下文，请提供 {missing_item}"
```

---

## 6. 数据流总览

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              DATA FLOW                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  用户输入                                                                │
│     │                                                                    │
│     ▼                                                                    │
│  ┌──────────┐    CLAUDE.md              .agent/specs/{feature}/          │
│  │ /specify │ ← constitution.md    ─→  ├── capture/                      │
│  │          │   .agent/templates/       │   └── raw-notes.md             │
│  └──────────┘                           ├── clarify/                     │
│       │                                 │   └── clarified.md             │
│       ▼                                 ├── spec.md (定稿)               │
│  ┌──────────┐                           └── .state.yaml                  │
│  │ CAPTURE  │ ──────────────────────→  raw-notes.md                      │
│  └──────────┘                                │                           │
│       │                                      ▼                           │
│       ▼                                                                  │
│  ┌──────────┐                                                            │
│  │ CLARIFY  │ ←── raw-notes.md ────→  clarified.md                       │
│  └──────────┘     用户反馈                   │                           │
│       │                                      ▼                           │
│       ▼                                                                  │
│  ┌──────────┐                                                            │
│  │STRUCTURE │ ←── clarified.md ───→  spec.md (草稿)                      │
│  └──────────┘     spec 模板                  │                           │
│       │                                      ▼                           │
│       ▼                                                                  │
│  ┌──────────┐                                                            │
│  │ VALIDATE │ ←── spec.md (草稿) ─→  spec.md (定稿)                      │
│  └──────────┘     validation rules           │                           │
│       │                                      ▼                           │
│       ▼                                                                  │
│  输出: .agent/specs/{feature}/spec.md (status: approved)                 │
│                                                                          │
│  ──────────────────────────────────────────────────────────────────────  │
│                                                                          │
│  下一阶段: /plan {feature} → 读取 spec.md                                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 7. 与工作流框架的集成

### 7.1 与 5 阶段模型的关系

```
Framework Phase    Skill Command    Output
─────────────────────────────────────────────────────────
SPECIFY           /specify          .agent/specs/{f}/spec.md
    │
    ▼ (checkpoint: after_specify)
PLAN              /plan             .agent/specs/{f}/plan.md
    │
    ▼ (checkpoint: after_plan)
TASK              /tasks            .tasks/{task-id}/
    │
    ▼ (checkpoint: after_tasks)
IMPLEMENT         (manual/auto)     代码变更
    │
    ▼
REVIEW            /self-review      审查报告
```

### 7.2 配置集成

```yaml
# .agent/config.yaml
workflow:
  phases:
    specify:
      enabled: true
      skill: /specify
      mode: standard  # mini | standard | full
      checkpoints:
        after_capture: false  # 内部检查点
        after_clarify: false
        after_structure: false
        after_validate: true  # 外部检查点（人工审批）
      validation:
        auto_checks: true
        severity_threshold: MAJOR
```

---

*Document Version: 1.0 | 2026-01-13*
