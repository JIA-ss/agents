# Skill Self-Iteration Guide

How to design skills that can analyze their own failures, propose improvements, and evolve over time.

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [Evolution Directory Structure](#evolution-directory-structure)
3. [Feedback Loop Mechanism](#feedback-loop-mechanism)
4. [Failure Analysis Patterns](#failure-analysis-patterns)
5. [Improvement Workflow](#improvement-workflow)
6. [Validation Gates](#validation-gates)
7. [Integration with SKILL.md](#integration-with-skillmd)

---

## Core Concepts

### The Self-Iteration Loop

```
Execute Task → Record Outcome → Analyze Failures → Generate Improvement → Validate → Deploy
      ↑                                                                              │
      └──────────────────────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Record Complete Decision Chains** - Capture full execution traces, not just inputs/outputs
2. **Separate Error Types** - Distinguish execution errors (API failures) from reasoning errors (flawed logic)
3. **Verify Before Adopt** - Only accept improvements that pass validation gates
4. **Preserve Goal Alignment** - Maintain immutable core objectives while allowing tactical improvements

---

## Evolution Directory Structure

Add `.evolution/` to your skill directory:

```
skill-name/
├── SKILL.md
├── references/
├── scripts/
└── .evolution/                    # Self-iteration data
    ├── config.yaml                # Evolution settings
    ├── failures/                  # Failure case library
    │   └── {timestamp}-{type}.md  # Individual failure records
    ├── patterns/                  # Identified error patterns
    │   └── {pattern-id}.md        # Pattern analysis
    ├── improvements/              # Proposed improvements
    │   └── {timestamp}-proposal.md
    ├── metrics/                   # Execution metrics
    │   └── execution-log.jsonl    # Append-only log
    └── changelog.md               # Improvement history
```

### config.yaml Schema

```yaml
# .evolution/config.yaml
evolution:
  enabled: true

  # Automatic improvement triggers
  triggers:
    consecutive_failures: 3        # Trigger after N consecutive failures
    same_error_pattern: 5          # Trigger when same error occurs N times
    performance_regression: 0.1    # Trigger on 10% performance drop

  # Validation requirements
  validation:
    require_tests: true            # Must pass existing tests
    require_regression: true       # Must not introduce regressions
    require_human_approval: false  # Auto-deploy if validation passes

  # Safety limits
  limits:
    max_auto_changes_per_week: 5   # Prevent runaway evolution
    rollback_on_failure: true      # Auto-rollback failed improvements
```

---

## Feedback Loop Mechanism

### Recording Execution Outcomes

After each skill execution, record the outcome:

```bash
# Simple usage (backwards compatible)
./scripts/record-outcome.sh <skill-dir> <status> [details]
./scripts/record-outcome.sh my-skill success "Task completed in 2.3s"
./scripts/record-outcome.sh my-skill failure "ValidationError: missing field"

# Full decision chain recording (recommended for failures)
./scripts/record-outcome.sh my-skill failure \
  --input "Generate PDF report from data.csv" \
  --expected "PDF file created with charts and tables" \
  --actual "Error: matplotlib not installed" \
  --error-class execution \
  --details "Missing dependency in environment"
```

### Error Classes

| Class | Description | Examples |
|-------|-------------|----------|
| `execution` | Runtime/environment issues | Missing deps, permissions, timeouts |
| `reasoning` | Logic/approach problems | Wrong output, misunderstood requirements |

The script auto-detects error types from details but explicit `--error-class` is preferred for accuracy.

### Outcome Record Format

```jsonl
{"timestamp":"2026-01-13T10:00:00Z","status":"success","details":"Task completed"}
{"timestamp":"2026-01-13T10:05:00Z","status":"failure","error_type":"validation","details":"Missing required field: name"}
{"timestamp":"2026-01-13T10:10:00Z","status":"failure","error_type":"execution","input":"Generate PDF","expected":"PDF with charts","actual":"matplotlib not installed","details":"Missing dependency"}
```

### Analyzing Trends

```bash
# scripts/analyze-trends.sh <skill-name> [--days N]
./scripts/analyze-trends.sh my-skill --days 7
```

Output:
```
Execution Summary (Last 7 days):
  Total: 45 | Success: 38 (84%) | Failure: 7 (16%)

Top Error Patterns:
  1. ValidationError (4 occurrences) - PATTERN_001
  2. TimeoutError (2 occurrences) - PATTERN_002
  3. Unknown (1 occurrence)

Recommendation: Review PATTERN_001 for potential SKILL.md improvement
```

---

## Failure Analysis Patterns

### Failure Record Template

```markdown
# Failure Record: {timestamp}

## Context
- **Task**: [What was being attempted]
- **Input**: [Relevant input data]
- **Expected**: [Expected outcome]
- **Actual**: [What actually happened]

## Error Classification
- **Type**: execution | reasoning | validation | timeout
- **Severity**: blocker | critical | major | minor
- **Reproducible**: yes | no | unknown

## Root Cause Analysis
[Analysis of why the failure occurred]

## Proposed Fix
- [ ] SKILL.md update needed
- [ ] Script fix needed
- [ ] Reference update needed
- [ ] New validation rule needed

## Related Patterns
- Pattern ID: [if matches existing pattern]
```

### Pattern Identification

When multiple failures share characteristics:

```markdown
# Pattern: PATTERN_001

## Description
ValidationError when processing inputs with special characters

## Occurrences
- 2026-01-10: failure-001.md
- 2026-01-11: failure-003.md
- 2026-01-12: failure-007.md
- 2026-01-13: failure-009.md

## Root Cause
SKILL.md Core Rules section doesn't specify input sanitization

## Recommended Fix
Add to Core Rules:
> Sanitize all user inputs before processing. Escape special characters: < > & " '

## Impact Assessment
- Affected: ~15% of executions
- Severity: MAJOR
- Auto-fixable: YES
```

---

## Improvement Workflow

### Phase 1: Trigger Detection

```yaml
# Automatic triggers (from config.yaml)
trigger_conditions:
  - consecutive_failures >= triggers.consecutive_failures
  - pattern_occurrences >= triggers.same_error_pattern
  - success_rate < (baseline - triggers.performance_regression)
```

### Phase 2: Improvement Generation

When triggered, generate improvement proposal:

```markdown
# Improvement Proposal: {timestamp}

## Trigger
- Type: pattern_threshold
- Pattern: PATTERN_001
- Occurrences: 5

## Analysis
Based on 5 failures matching PATTERN_001, the skill lacks input validation guidance.

## Proposed Changes

### SKILL.md Changes
```diff
## Core Rules

+ 3. **Input Validation** - Sanitize all user inputs before processing. Escape special characters.
```

### Script Changes
None required.

### Reference Changes
None required.

## Validation Plan
1. Run existing test suite
2. Test with edge cases that triggered failures
3. Measure execution time (must not regress >5%)

## Rollback Plan
If validation fails, revert SKILL.md to previous version.
```

### Phase 3: Validation

```bash
# scripts/validate-improvement.sh <skill-name> <proposal-file>
./scripts/validate-improvement.sh my-skill improvements/2026-01-13-proposal.md
```

Validation checks:
1. ✅ Syntax validation (SKILL.md still valid)
2. ✅ Existing tests pass
3. ✅ New edge cases pass
4. ✅ Performance not regressed
5. ✅ No new failures introduced

### Phase 4: Deployment

If validation passes:
```bash
# scripts/deploy-improvement.sh <skill-name> <proposal-file>
./scripts/deploy-improvement.sh my-skill improvements/2026-01-13-proposal.md
```

Actions:
1. Apply changes to SKILL.md/scripts/references
2. Record in changelog.md
3. Reset failure counters for addressed patterns
4. Notify user of changes (if configured)

---

## Validation Gates

### Gate 1: Syntax Validation

```bash
# Must pass skill validator
./scripts/validate-skill.sh <skill-dir>
```

### Gate 2: Regression Testing

```yaml
# Test against known good cases
regression_tests:
  - input: "standard case"
    expected: "success"
  - input: "edge case 1"
    expected: "success"
```

### Gate 3: Failure Case Testing

```yaml
# Test against cases that previously failed
failure_tests:
  - source: failures/2026-01-10-001.md
    expected: "success"  # Should now succeed
```

### Gate 4: Performance Check

```yaml
performance_baseline:
  avg_duration_ms: 2500
  max_duration_ms: 5000

performance_threshold:
  max_regression: 0.05  # 5% slower is acceptable
```

### Gate 5: Human Approval (Optional)

```yaml
# For major changes, require human review
human_approval:
  required_for:
    - core_rules_change
    - workflow_change
    - output_format_change
  not_required_for:
    - typo_fix
    - minor_clarification
    - example_addition
```

---

## Integration with SKILL.md

Add this section to skills that support self-iteration:

```markdown
## Self-Iteration

This skill supports automatic improvement based on execution feedback.

### Recording Outcomes
After using this skill, record the outcome:
```bash
./scripts/record-outcome.sh {skill-name} <success|failure> "[details]"
```

### Analyzing Failures
Review accumulated failures and patterns:
```bash
./scripts/analyze-trends.sh {skill-name}
```

### Proposing Improvements
Generate improvement proposal based on patterns:
```bash
./scripts/propose-improvement.sh {skill-name} <pattern-id>
```

### Configuration
See `.evolution/config.yaml` for trigger thresholds and validation settings.
```

---

## Best Practices Checklist

### Design Phase
- [ ] Define clear Core Rules that can be validated
- [ ] Include measurable success criteria
- [ ] Specify expected output format precisely

### Implementation Phase
- [ ] Add record-outcome.sh integration points
- [ ] Define baseline performance metrics
- [ ] Create initial regression test cases

### Operation Phase
- [ ] Review weekly trend reports
- [ ] Investigate patterns with >3 occurrences
- [ ] Validate improvements before deployment
- [ ] Maintain changelog for all changes

### Safety
- [ ] Set reasonable auto-change limits
- [ ] Enable rollback on failure
- [ ] Preserve immutable core objectives
- [ ] Monitor for goal drift
