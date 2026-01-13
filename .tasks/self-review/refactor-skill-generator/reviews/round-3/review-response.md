# Review Response - Round 3 (Deep Review)

## Reviewer: Codex (gpt-5.2-codex, xhigh reasoning)

## Findings by Severity

### BLOCKER
- None

### CRITICAL
- None

### MAJOR

1. **Template Inconsistency**
   - Location: `templates/SKILL-template.md:1` vs `scripts/init-skill.sh:53`
   - Issue: Two competing "canonical" templates with differences:
     - Workflow step count differs
     - Core rules count differs
     - Output example block differs
     - Additional Resources rows differ
   - Impact: Inconsistent skills depending on entry point used

2. **Line Limit Warning vs Error**
   - Location: `scripts/validate-skill.sh:128`
   - Issue: `<500` line limit treated as WARNING, not ERROR
   - Reference: `references/spec-reference.md:112` says it's a limit
   - Impact: Spec-violating skill can "PASS WITH WARNINGS"

### MINOR

1. **XML Tag Detection Incomplete**
   - Location: `scripts/validate-skill.sh:110`
   - Issue: Won't catch tags with attributes (e.g., `<tag attr="x">`)
   - Impact: Some forbidden XML could slip through

2. **macOS Compatibility**
   - Location: `scripts/init-skill.sh:106`
   - Issue: `sed -i` without `''` fails on macOS
   - Impact: Cross-platform portability issue

## Verdict

**NEEDS_IMPROVEMENT** (confidence: 0.62)

## Required Actions

### Priority 1: Template Consistency
- Unify `templates/SKILL-template.md` and `init-skill.sh` generated template
- Choose one canonical structure

### Priority 2: Line Limit Enforcement
- Consider making `>500` lines an ERROR instead of WARNING
- OR document why it's acceptable as warning

### Priority 3: Cross-Platform Scripts
- Fix `sed -i` for macOS compatibility
- Improve XML tag regex for attribute cases
