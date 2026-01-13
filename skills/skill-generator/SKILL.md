---
name: skill-generator
description: Creates new Claude Code skills following official Agent Skills specification. Generates SKILL.md files with Progressive Disclosure architecture. Use when users want to create, design, or generate a new skill, need help with SKILL.md format, or want to extend Claude's capabilities. Also responds to "创建 skill", "生成 skill", "设计 skill", "skill 模板".
---

# Skill Generator Guide

## Overview

Meta-level skill for creating well-structured Claude Code skills that follow Anthropic's official Agent Skills specification. Generates SKILL.md files with proper Progressive Disclosure architecture.

## Core Principle: Progressive Disclosure

Skills use a three-level loading system to optimize context usage:

| Level | When Loaded | Token Budget | Content |
|-------|-------------|--------------|---------|
| **1: Metadata** | Always (at startup) | ~100 tokens | `name` + `description` in frontmatter |
| **2: Instructions** | When skill triggers | <5k tokens | SKILL.md body |
| **3: Resources** | As needed by Claude | Unlimited | scripts/, references/, assets/ |

**Key insight**: You can install many skills without context penalty. Claude only loads what's needed.

---

## Workflow (6 Steps)

### Step 1: Understand Requirements

Gather concrete examples of how the skill will be used:
- "What tasks should this skill handle?"
- "Give examples of user requests that should trigger it"
- "What would a user say to activate this skill?"

### Step 2: Plan Reusable Contents

For each example, identify:
- **Scripts** - Code that would be repeatedly rewritten
- **References** - Domain knowledge to load as needed
- **Assets** - Templates, images used in output

### Step 3: Initialize Skill

**Option A: Use init script (recommended)**
```bash
./scripts/init-skill.sh <skill-name>
```

**Option B: Copy template manually**
```bash
cp templates/SKILL-template.md <skill-name>/SKILL.md
# Then replace SKILL_NAME_PLACEHOLDER with actual name
```

Creates:
```
skill-name/
├── SKILL.md          # Main file (required)
├── references/       # Domain docs (optional)
├── scripts/          # Executable code (optional)
└── assets/           # Output resources (optional)
```

### Step 4: Write SKILL.md

**Frontmatter (required)**:
```yaml
---
name: skill-name
description: What it does. Use when [specific triggers]. Also responds to "中文关键词".
---
```

**Body sections** (customize based on skill type):
- Overview - What, why, core value
- Workflow - Step-by-step process
- Core Rules - Constraints and requirements
- Output Requirements - Expected format
- Best Practices - Usage guidance

> **Need detailed constraints?** See [references/spec-reference.md](references/spec-reference.md) for complete field specifications.

### Step 5: Validate

```bash
./scripts/validate-skill.sh <skill-dir>
```

Checks: frontmatter format, name conventions, description quality, file structure.

### Step 6: Iterate

Test with fresh Claude instance → Observe behavior → Refine → Repeat.

> **Need iteration guidance?** See [references/best-practices.md](references/best-practices.md) for testing methodology and common pitfalls.

---

## Specification Constraints

### Frontmatter Fields

| Field | Constraint | Example |
|-------|------------|---------|
| `name` | max 64 chars, only `a-z`, `0-9`, `-` | `pdf-processor` |
| `description` | max 1024 chars, third person only | "Extracts text from PDFs. Use when..." |

**Forbidden in name**: "anthropic", "claude"
**Forbidden everywhere**: XML tags

### Content Limits

| Metric | Limit | Rationale |
|--------|-------|-----------|
| SKILL.md lines | <500 | Move details to references/ |
| Reference depth | 1 level | No nested references |
| Mermaid nodes | ≤15 | Keep diagrams simple |

### Description Requirements

Must include BOTH:
1. **What it does** - Functionality description
2. **When to use** - Specific triggers and contexts

**Good**: "Extract text and tables from PDFs. Use when working with PDF files or when user mentions forms, document extraction."

**Bad**: "Helps with documents" (too vague)

---

## Degrees of Freedom

Match specificity to task fragility:

| Freedom | When to Use | Format |
|---------|-------------|--------|
| **High** | Multiple valid approaches | Prose guidelines |
| **Medium** | Preferred pattern exists | Pseudocode with params |
| **Low** | Operations fragile | Specific scripts |

---

## Quality Checklist

Before finalizing, verify:

**Frontmatter**:
- [ ] `name` follows naming rules
- [ ] `description` under 1024 chars
- [ ] `description` includes "what" AND "when"
- [ ] No first-person pronouns

**Content**:
- [ ] SKILL.md < 500 lines
- [ ] Overview explains core value
- [ ] Workflow has clear steps
- [ ] References only 1 level deep
- [ ] No time-sensitive information
- [ ] Consistent terminology

**Resources**:
- [ ] Scripts tested and working
- [ ] References have table of contents (if >100 lines)
- [ ] Forward slashes in all paths

---

## Self-Iteration Support

Generated skills can include self-iteration capability for autonomous improvement.

### Enable Self-Iteration

Add `--with-evolution` flag when initializing:
```bash
./scripts/init-skill.sh <skill-name> --with-evolution
```

This creates `.evolution/` directory with:
- `config.yaml` - Trigger thresholds and validation settings
- `failures/` - Failure case library
- `patterns/` - Identified error patterns
- `improvements/` - Proposed improvements
- `metrics/` - Execution logs

### Self-Iteration Workflow

```
Record Outcome → Analyze Trends → Propose Improvement → Validate → Deploy
```

1. **Record**: `./scripts/record-outcome.sh <skill-dir> <status> [details]`
2. **Analyze**: `./scripts/analyze-trends.sh <skill-dir>`
3. **Propose**: `./scripts/propose-improvement.sh <skill-dir>`
4. **Validate**: `./scripts/validate-improvement.sh <skill-dir> <proposal-file>`
5. **Deploy**: `./scripts/deploy-improvement.sh <skill-dir> <proposal-file>`

> **Detailed guide**: See [references/self-iteration-guide.md](references/self-iteration-guide.md) for complete self-iteration architecture.

---

## Additional Resources

| Resource | Path | When to Use |
|----------|------|-------------|
| **Spec Reference** | [references/spec-reference.md](references/spec-reference.md) | When you need exact field constraints, forbidden patterns, or runtime environment details |
| **Best Practices** | [references/best-practices.md](references/best-practices.md) | When iterating on a skill, testing across models, or troubleshooting common pitfalls |
| **Self-Iteration Guide** | [references/self-iteration-guide.md](references/self-iteration-guide.md) | When designing skills that can analyze failures and self-improve |
| **Skill Template** | [templates/SKILL-template.md](templates/SKILL-template.md) | When manually creating a skill without using init script |
| **Evolution Config Template** | [templates/evolution/config.yaml](templates/evolution/config.yaml) | When manually adding self-iteration to existing skill |
| **Init Script** | [scripts/init-skill.sh](scripts/init-skill.sh) | When starting a new skill - creates directory structure and SKILL.md |
| **Validation** | [scripts/validate-skill.sh](scripts/validate-skill.sh) | After writing SKILL.md - checks spec compliance before deployment |
| **Record Outcome** | [scripts/record-outcome.sh](scripts/record-outcome.sh) | After each skill execution - records success/failure for analysis |
| **Analyze Trends** | [scripts/analyze-trends.sh](scripts/analyze-trends.sh) | Periodically - identifies failure patterns and improvement opportunities |
| **Propose Improvement** | [scripts/propose-improvement.sh](scripts/propose-improvement.sh) | When patterns reach threshold - generates improvement proposal |
| **Validate Improvement** | [scripts/validate-improvement.sh](scripts/validate-improvement.sh) | Before deploying - validates proposal against 5 safety gates |
| **Deploy Improvement** | [scripts/deploy-improvement.sh](scripts/deploy-improvement.sh) | After validation passes - deploys improvement with backup |
