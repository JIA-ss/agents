# Phase Details Reference

## Table of Contents
- [Phase 1: CAPTURE](#phase-1-capture)
- [Phase 2: CLARIFY](#phase-2-clarify)
- [Phase 3: STRUCTURE](#phase-3-structure)
- [Phase 4: VALIDATE](#phase-4-validate)
- [Ambiguity Detection](#ambiguity-detection)
- [INVEST Principle](#invest-principle)

---

## Phase 1: CAPTURE

### Sub-tasks

1. **Context Gathering (C1)**
   - Read CLAUDE.md if exists
   - Read constitution.md if exists
   - Scan project structure
   - Identify tech stack

2. **Stakeholder Identification (C2)**
   - List user roles
   - Identify decision makers
   - Map impact scope

3. **Requirements Extraction (C3)**
   - Functional requirements
   - Non-functional requirements
   - Constraints

### Output Format: raw-notes.md

```markdown
# Raw Notes: {feature}

## Context
{Project background, tech stack, existing state}

## Stakeholders
- {Role 1}: {Description}
- {Role 2}: {Description}

## Raw Requirements
### Functional
- {Requirement 1}
- {Requirement 2}

### Non-Functional
- {Requirement 1}

### Constraints
- {Constraint 1}

## Open Questions
- [ ] Q1: {Question}
- [ ] Q2: {Question}

## Metrics
- open_questions_count: {N}
- ambiguity_score: {N}
```

---

## Phase 2: CLARIFY

### Sub-tasks

1. **Ambiguity Detection (CL1)**
   - Scan for vague terms
   - Identify hidden assumptions
   - Find missing information

2. **Question Generation (CL2)**
   - Prioritize questions
   - Provide default recommendations
   - Categorize as required/optional

3. **Resolution (CL3)**
   - Use AskUserQuestion tool
   - Record decisions
   - Log assumptions

### Skip Condition

Skip CLARIFY phase when:
- `ambiguity_score == 0`
- `open_questions_count == 0`

### Output Format: clarified.md

```markdown
# Clarification Record: {feature}

## Resolved Questions
| Q | Answer | Source |
|---|--------|--------|
| {Question} | {Answer} | User/Assumption |

## Confirmed Assumptions
- [x] {Assumption 1} - Confirmed by user
- [x] {Assumption 2} - Accepted risk

## Decisions Log
| Decision | Rationale | Date |
|----------|-----------|------|
| {Decision} | {Why} | {Date} |

## Remaining Ambiguities
- {Item} - Risk accepted: {reason}
```

---

## Phase 3: STRUCTURE

### Sub-tasks

1. **User Story Composition (S1)**
   - Apply As a/I want/So that format
   - Check INVEST principles
   - Split large stories

2. **Acceptance Criteria (S2)**
   - 3-7 criteria per story
   - Include positive, negative, edge cases
   - Make testable

3. **Requirements Classification (S3)**
   - FR with Must/Should/Could priority
   - NFR with verification method
   - Link to user stories

4. **Scope Definition (S4)**
   - Explicit inclusions
   - Explicit exclusions
   - Dependencies

### Template Selection

| Mode | Sections to Fill |
|------|------------------|
| mini | 1, 3, 7, 9 |
| standard | 1-7, 9 |
| full | 1-9, Appendix |

---

## Phase 4: VALIDATE

### Validation Checks

1. **Completeness Check (V1)**
   - All required sections filled
   - No placeholder text remaining
   - No TODO markers

2. **Consistency Check (V2)**
   - No conflicting requirements
   - Consistent terminology
   - Priority distribution (Must < 60%)

3. **Quality Check (V3)**
   - No ambiguous terms
   - NFRs quantified
   - ACs testable

### Approval Flow

1. Display validation results
2. Show suggestions for improvement
3. Ask user to approve/modify/cancel
4. Update status to "approved"
5. Record approver and timestamp

---

## Ambiguity Detection

### Forbidden Terms

English: fast, quick, simple, easy, user-friendly, intuitive, robust, scalable (without numbers)

Chinese: 快速, 简单, 容易, 友好, 直观, 健壮, 可扩展 (without numbers)

### Ambiguity Score Calculation

```
score = 0
for term in forbidden_terms:
    if term in text:
        score += 1
for undefined_acronym in text:
    score += 1
for missing_boundary in requirements:
    score += 1
```

---

## INVEST Principle

| Letter | Meaning | Check |
|--------|---------|-------|
| **I** | Independent | Can be implemented alone? |
| **N** | Negotiable | Room for discussion? |
| **V** | Valuable | Delivers user value? |
| **E** | Estimable | Can estimate effort? |
| **S** | Small | Fits in one iteration? |
| **T** | Testable | Has clear acceptance criteria? |

### Checklist

- [ ] Story does not depend on other stories
- [ ] Implementation approach is flexible
- [ ] Business value is clear
- [ ] Team can estimate effort
- [ ] Small enough for one sprint
- [ ] Acceptance criteria are testable
