# Review Analysis Template

```markdown
# Review Analysis - Round {N}

## Verdict
**{PASS / NEEDS_IMPROVEMENT / REJECTED}**

## Issue Summary
| Severity | Count | Action |
|----------|-------|--------|
| BLOCKER  | {n}   | Must fix immediately |
| CRITICAL | {n}   | Must fix before merge |
| MAJOR    | {n}   | Should fix |
| MINOR    | {n}   | Optional (non-blocking) |

## Issues Detail

### BLOCKER
1. {issue_description}
   - Location: {file:line}
   - Reason: {reason}

### CRITICAL
1. {issue_description}

### MAJOR
1. {issue_description}

### MINOR (non-blocking)
1. {issue_description}

## Decision
Based on verdict rules:
- blocker_count = {n} (threshold: 0)
- critical_count = {n} (threshold: 2)
- major_count = {n} (threshold: 5)

**Result: {VERDICT}**

## Next Steps
{improvement_plan_or_delivery}
```
