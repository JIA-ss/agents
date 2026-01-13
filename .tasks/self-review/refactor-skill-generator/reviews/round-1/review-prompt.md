# Review Request: Skill Generator Refactoring

## Task Summary

Refactor the `skill-generator` skill to comply with official Anthropic Agent Skills specification based on comprehensive research.

## Files to Review

1. `skills/skill-generator/SKILL.md` - Main skill file
2. `skills/skill-generator/references/spec-reference.md` - Specification reference
3. `skills/skill-generator/references/best-practices.md` - Best practices guide
4. `skills/skill-generator/scripts/init-skill.sh` - Initialization script
5. `skills/skill-generator/scripts/validate-skill.sh` - Validation script
6. `skills/skill-generator/templates/SKILL-template.md` - Starter template

## Verification Steps

Please verify:

1. **Frontmatter Compliance**
   - [ ] `name` field present and valid (a-z, 0-9, - only, max 64 chars)
   - [ ] `description` field present and valid (max 1024 chars, third person)
   - [ ] Description includes "what it does" AND "when to use"
   - [ ] No reserved words in name (anthropic, claude)

2. **Progressive Disclosure Architecture**
   - [ ] SKILL.md < 500 lines
   - [ ] Detailed content in references/
   - [ ] Scripts provide executable functionality
   - [ ] Reference depth is 1 level (no nesting)

3. **Content Quality**
   - [ ] Overview explains core value
   - [ ] Workflow has clear steps
   - [ ] Constraints documented accurately
   - [ ] No time-sensitive information
   - [ ] Consistent terminology

4. **Scripts Functionality**
   - [ ] init-skill.sh creates valid structure
   - [ ] validate-skill.sh checks all constraints
   - [ ] Scripts have proper error handling
   - [ ] Scripts are documented

## Expected Output Format

```yaml
VERIFICATION:
  frontmatter_compliance: PASS/FAIL
  progressive_disclosure: PASS/FAIL
  content_quality: PASS/FAIL
  scripts_functionality: PASS/FAIL

VERDICT: PASS / NEEDS_IMPROVEMENT / REJECTED

CONFIDENCE: 0.0-1.0

BLOCKER_ISSUES:
  - [list any blockers]

CRITICAL_ISSUES:
  - [list any critical issues]

MAJOR_ISSUES:
  - [list any major issues]

MINOR_ISSUES:
  - [list any minor issues]

RECOMMENDATIONS:
  - [list recommendations]
```
