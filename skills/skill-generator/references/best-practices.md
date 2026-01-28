# Skill Development Best Practices

Guidance for creating, testing, and iterating on Claude Code skills using TDD methodology.

---

## Table of Contents

1. [TDD Workflow](#tdd-workflow)
2. [Test Specification Design](#test-specification-design)
3. [Development Workflow](#development-workflow)
4. [Evaluation-Driven Development](#evaluation-driven-development)
5. [Iteration Strategies](#iteration-strategies)
6. [Testing Methodology](#testing-methodology)
7. [Common Pitfalls](#common-pitfalls)

---

## TDD Workflow

### The Core Principle

**Write tests BEFORE implementation. Always.**

```
1. Define expected behavior (test-spec.yaml)
2. Verify test spec is complete
3. Write SKILL.md to make tests pass
4. Run tests
5. Fix failures, repeat until all pass
```

### TDD Development Cycle

```
┌─────────────┐
│ 1. REQUIRE  │ ── Collect requirements and scenarios
└─────┬───────┘
      ▼
┌─────────────┐
│ 2. PLAN     │ ── Plan content and test coverage
└─────┬───────┘
      ▼
┌──────────────────┐
│ 3. TEST-DESIGN   │ ── Write test-spec.yaml FIRST (RED)
└─────┬────────────┘
      ▼
┌─────────────┐
│ 4. INIT     │ ── Create directory with tests/
└─────┬───────┘
      ▼
┌─────────────┐
│ 5. WRITE    │ ── Write SKILL.md (GREEN)
└─────┬───────┘
      ▼
┌──────────────────┐
│ 6. TEST-RUN      │ ── Run all tests
└─────┬────────────┘
      │
      ▼ Pass?
     / \
   No   Yes
   │     │
   │     ▼
   │  ┌─────────────┐
   │  │ 7. ITERATE  │ ── User acceptance
   │  └─────────────┘
   │
   └──► Back to WRITE (fix issues)
```

### Why TDD for Skills?

| Benefit | Explanation |
|---------|-------------|
| Clear requirements | Tests define expected behavior upfront |
| Prevents scope creep | Implementation targets specific scenarios |
| Regression protection | Changes don't break existing functionality |
| Documentation | Tests serve as usage examples |
| Confidence | Know your skill works before shipping |

---

## Test Specification Design

### Required Test Types

Every skill MUST have these test types:

| Type | Purpose | Minimum Count |
|------|---------|---------------|
| `trigger` | Verify skill activates correctly | 2 (CN + EN) |
| `execution` | Verify core functionality works | 1 |
| `edge` | Verify boundary conditions | 2 |
| `negative` | Verify no false activation | 1 |
| `error` | Verify error handling | Optional |

### Good Test Scenario Structure

```yaml
- id: "unique-identifier"
  name: "Human readable name"
  type: "trigger|execution|edge|negative|error"
  query: "Exact user input to test"
  expected_behavior:
    - "Specific, verifiable behavior 1"
    - "Specific, verifiable behavior 2"
  expected_output:  # optional
    format: "markdown"
    contains:
      - "expected content"
    not_contains:
      - "error"
```

### Test Coverage Guidelines

**Trigger Tests:**
- Include both Chinese and English triggers
- Test all documented trigger phrases
- Test variations and synonyms

**Execution Tests:**
- Cover the main use case
- Test complete workflow
- Verify output format

**Edge Tests:**
- Minimal input
- Special characters
- Boundary values
- Unusual but valid requests

**Negative Tests:**
- Similar but unrelated requests
- Requests that should use different skills
- Ambiguous requests

---

## Development Workflow

### Recommended Process

```
1. Complete task WITHOUT skill (with Claude A)
   └── Note context you repeatedly provide

2. Identify reusable patterns
   └── Extract domain knowledge from conversation

3. Have Claude A create the skill
   └── "Based on our work, create a skill for this"

4. Trim content
   └── "Remove unnecessary explanations - Claude knows this"

5. Test with Claude B (fresh instance)
   └── Observe: Does it find right info? Apply rules correctly?

6. Refine based on observations
   └── Return to Claude A, improve, test with B again

7. LOOP until satisfied
```

### Why Two Claude Instances?

- **Claude A** has conversation context, may fill gaps unconsciously
- **Claude B** only has the skill, reveals missing information
- Testing with B exposes what's truly in the skill vs implied

---

## Evaluation-Driven Development

### Core Principle

**Create evaluations BEFORE writing documentation**

### Evaluation Structure

```json
{
  "skills": ["your-skill-name"],
  "query": "User request that should trigger skill",
  "files": ["test-files/sample.ext"],
  "expected_behavior": [
    "Behavior 1 that should occur",
    "Behavior 2 that should occur",
    "Specific output or action expected"
  ]
}
```

### Development Flow

1. **Identify gaps** - Run task without skill, note failures
2. **Create evals** - Build 3+ test scenarios covering edge cases
3. **Establish baseline** - Measure performance without skill
4. **Write minimal instructions** - Add just enough to pass evals
5. **Iterate** - Run evals, compare to baseline, refine

### Example Evaluation Set

```json
[
  {
    "query": "Extract all text from report.pdf",
    "expected_behavior": ["Uses pdfplumber", "Extracts from all pages", "Preserves formatting"]
  },
  {
    "query": "Fill out the form in application.pdf",
    "expected_behavior": ["Identifies form fields", "Fills values", "Validates output"]
  },
  {
    "query": "Merge these three PDFs into one",
    "expected_behavior": ["Reads all files", "Maintains order", "Creates valid output"]
  }
]
```

---

## Iteration Strategies

### Observing Claude's Behavior

Watch for these signals:

| Observation | Diagnosis | Action |
|-------------|-----------|--------|
| Unexpected exploration | Structure not intuitive | Reorganize sections |
| Misses references | Links not clear enough | Add explicit guidance |
| Over-relies on one section | Content is key | Consider moving to SKILL.md |
| Ignores content | Not relevant or unclear | Remove or rewrite |

### What to Add vs Remove

**Add when**:
- Claude repeatedly makes same mistake
- Task requires domain knowledge Claude lacks
- Specific format or pattern is required

**Remove when**:
- Claude already knows this (common knowledge)
- Explanation is redundant
- Content is never referenced

### Feedback Loop Pattern

For quality-critical tasks, embed verification:

```markdown
## Edit Process

1. Make changes to file
2. **Validate immediately**: `python scripts/validate.py output/`
3. If validation fails:
   - Review error message
   - Fix issues
   - Validate again
4. **Only proceed when validation passes**
5. Continue to next step
```

---

## Testing Methodology

### Multi-Model Testing

Test on all model tiers to ensure skill works across capabilities:

| Model | Question to Answer |
|-------|--------------------|
| **Haiku** | Does skill provide enough guidance? |
| **Sonnet** | Is skill clear and efficient? |
| **Opus** | Does skill avoid over-explaining? |

### Test Scenarios

1. **Happy path** - Standard use case
2. **Edge cases** - Unusual inputs
3. **Error handling** - Invalid inputs
4. **Trigger accuracy** - Does skill activate when expected?
5. **Non-trigger** - Does skill stay inactive when not relevant?

### Testing Checklist

- [ ] Tested with fresh Claude instance (no prior context)
- [ ] Tested trigger phrases activate skill
- [ ] Tested unrelated phrases don't activate
- [ ] Tested on Haiku, Sonnet, Opus
- [ ] Tested error handling paths
- [ ] Gathered feedback from other users (if applicable)

---

## Common Pitfalls

### Pitfall 1: Over-Explaining

**Problem**: Adding context Claude already knows

**Example**:
```markdown
# Bad
PDF (Portable Document Format) is a file format developed by Adobe...

# Good
Use pdfplumber for text extraction:
[code example]
```

**Fix**: Assume Claude is smart. Only add what it doesn't know.

### Pitfall 2: Too Many Options

**Problem**: Offering choices without guidance

**Example**:
```markdown
# Bad
You can use pdfplumber, PyPDF2, or pdf2image...

# Good
Use pdfplumber for text extraction (default).
For image-heavy PDFs, use pdf2image instead.
```

**Fix**: Provide defaults with escape hatches.

### Pitfall 3: Vague Triggers

**Problem**: Description doesn't specify when to activate

**Example**:
```yaml
# Bad
description: Helps with document processing

# Good
description: Extract text and tables from PDFs. Use when working with .pdf files or when user mentions PDF extraction, form filling, or document merging.
```

**Fix**: Include specific triggers and contexts.

### Pitfall 4: Time-Sensitive Content

**Problem**: Information that becomes stale

**Example**:
```markdown
# Bad
As of January 2024, the latest version is...

# Good
Check the official documentation for current version information.
```

**Fix**: Reference documentation for time-sensitive info.

### Pitfall 5: Inconsistent Terminology

**Problem**: Using different terms for same concept

**Example**:
```markdown
# Bad
"task", "job", "operation" used interchangeably

# Good
Consistently use "task" throughout
```

**Fix**: Define terms once and use consistently.

---

## Quality Checklist Summary

Before shipping, verify:

### Frontmatter
- [ ] `name` follows naming rules (a-z, 0-9, -)
- [ ] `description` < 1024 chars
- [ ] `description` has "what" AND "when"
- [ ] Third person only

### Content
- [ ] SKILL.md < 500 lines
- [ ] No time-sensitive info
- [ ] Consistent terminology
- [ ] Examples are concrete
- [ ] References 1 level deep

### Testing
- [ ] At least 3 evaluations
- [ ] Tested on Haiku/Sonnet/Opus
- [ ] Tested with fresh instance
- [ ] Trigger accuracy verified
