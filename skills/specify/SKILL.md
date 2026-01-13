---
name: specify
description: Transforms vague user requirements into structured spec.md documents. Use when user wants to define features, write requirements, create specifications, or mentions "需求", "规范", "spec", "user story". Supports mini/standard/full modes.
---

# Specify Skill

## Overview

Converts ambiguous user requirements into AI-executable structured specifications through a 4-phase process: CAPTURE, CLARIFY, STRUCTURE, VALIDATE.

**Core Value**: Ensures requirements are complete, unambiguous, and traceable before implementation begins.

---

## Workflow

```
CAPTURE → CLARIFY → STRUCTURE → VALIDATE
  捕获      澄清      结构化      验证
    │         │          │          │
    ▼         ▼          ▼          ▼
raw-notes  clarified   spec.md   spec.md
   .md       .md       (draft)   (approved)
```

### Phase 1: CAPTURE

**Goal**: Collect and understand raw requirements

**Actions**:
1. Read project context (CLAUDE.md, constitution.md if exist)
2. Scan existing codebase structure
3. Identify stakeholders and user roles
4. Extract raw requirements (functional, non-functional, constraints)
5. Calculate ambiguity_score and list open questions

**Output**: `.agent/specs/{feature}/capture/raw-notes.md`

### Phase 2: CLARIFY

**Goal**: Eliminate ambiguity, confirm assumptions

**Actions**:
1. Detect ambiguous terms ("fast", "simple", "easy", "快速", "简单")
2. Generate clarification questions with recommended defaults
3. Use AskUserQuestion tool to resolve ambiguities
4. Record decisions and confirmed assumptions

**Skip Condition**: If ambiguity_score == 0 and no open questions

**Output**: `.agent/specs/{feature}/clarify/clarified.md`

### Phase 3: STRUCTURE

**Goal**: Convert clarified requirements to standard format

**Actions**:
1. Compose User Stories (As a/I want/So that format)
2. Apply INVEST principle check
3. Define 3-7 Acceptance Criteria per story
4. Classify requirements (FR/NFR) with priorities
5. Define scope boundaries (Out of Scope section)

**Output**: `.agent/specs/{feature}/spec.md` (draft)

### Phase 4: VALIDATE

**Goal**: Verify completeness, get user approval

**Actions**:
1. Run completeness check (all required sections filled)
2. Run consistency check (no conflicts, terminology consistent)
3. Run feasibility check (technical, resource, timeline constraints)
4. Show validation results and suggestions
5. Request user approval via AskUserQuestion
6. Update spec status to "approved"

**Output**: `.agent/specs/{feature}/spec.md` (approved)

---

## Commands

```bash
# Basic usage
/specify {requirement description}

# Template mode
/specify --mode=mini {description}     # Simple tasks
/specify --mode=standard {description} # Default, medium features
/specify --mode=full {description}     # Large features

# Interaction mode
/specify --interactive {description}   # Default: pause at each phase
/specify --guided {description}        # AI suggests, user chooses
/specify --auto {description}          # AI decides, final approval only

# Resume or validate
/specify --resume {spec-id}
/specify --validate {spec-id}

# Single phase
/specify capture {description}
/specify clarify {spec-id}
/specify structure {spec-id}
/specify validate {spec-id}
```

**Options**:

| Option | Default | Description |
|--------|---------|-------------|
| `--mode` | standard | Template size: mini/standard/full |
| `--interactive` | yes | Pause at each phase for confirmation |
| `--guided` | no | AI provides options, user selects |
| `--auto` | no | AI decides all, only final approval |

---

## Template Modes

| Mode | Required Sections | Use Case |
|------|-------------------|----------|
| **mini** | 1 (Overview), 3 (User Stories), 7 (Out of Scope), 9 (Checklist) | Bug fixes, small changes |
| **standard** | 1-7, 9 | Medium features (default) |
| **full** | All (1-9, Appendix A-C) | Large features, new projects |

---

## Output Structure

```
.agent/specs/{feature}/
├── capture/
│   └── raw-notes.md       # Phase 1 output
├── clarify/
│   └── clarified.md       # Phase 2 output
├── spec.md                # Final specification
└── .state.yaml            # Progress tracking
```

---

## Validation Rules

User stories must follow format:
```
As a {role}, I want to {action}, So that I can {benefit}.
```

Each story needs 3-7 acceptance criteria covering:
- Positive scenarios
- Negative scenarios
- Edge cases

NFRs must be quantifiable (e.g., "API P95 < 200ms", not "fast response").

Forbidden terms (unless quantified): fast, quick, simple, easy, user-friendly, intuitive, robust, scalable, 快速, 简单, 容易, 友好, 直观, 健壮, 可扩展

---

## State Management

Progress is saved to `.state.yaml`. If interrupted:
- Use `/specify --resume {spec-id}` to continue
- State includes: current phase, completed phases, outputs

---

## Integration

Output spec.md is consumed by:
- `/plan {feature}` - Creates technical plan
- `/tasks {feature}` - Generates task breakdown

---

## Resources

| Resource | Path | Purpose |
|----------|------|---------|
| Spec Template | [assets/spec-template.md](assets/spec-template.md) | Full spec.md template (standard/full modes) |
| Mini Template | [assets/spec-mini.md](assets/spec-mini.md) | Minimal spec template (mini mode) |
| Validation | [scripts/validate-spec.sh](scripts/validate-spec.sh) | Validates spec completeness |
| Phase Reference | [references/phase-details.md](references/phase-details.md) | Detailed phase documentation |

### Resource Usage

**Validation Script**:
```bash
./scripts/validate-spec.sh <spec-file> [mode]
# mode: mini | standard | full (default: standard)
# Returns: PASSED or FAILED with error details
```

**Template Selection**:
- `--mode=mini` → Use [spec-mini.md](assets/spec-mini.md)
- `--mode=standard` or `--mode=full` → Use [spec-template.md](assets/spec-template.md)

**Phase Reference**: Load [phase-details.md](references/phase-details.md) when needing:
- Detailed sub-task breakdown for each phase
- Output format examples (raw-notes.md, clarified.md)
- INVEST principle checklist for user stories
