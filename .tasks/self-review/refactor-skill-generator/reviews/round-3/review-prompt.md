# Deep Review Request: Skill Generator Compliance

## Review Focus Areas

### 1. Best Practices Compliance
- Progressive Disclosure architecture
- Frontmatter format
- Content organization
- Reference structure

### 2. Description Clarity and Length
- Current: 346 characters
- Limit: 1024 characters
- Check: "what" + "when" coverage

### 3. References Format and Usage Guidance
- spec-reference.md (201 lines) - has TOC?
- best-practices.md (279 lines) - has TOC?
- Usage guidance in SKILL.md?

### 4. Scripts Logic and Documentation
- init-skill.sh - logic correct?
- validate-skill.sh - all checks valid?
- When/how to call documented in SKILL.md?

### 5. Template Correctness
- SKILL-template.md structure
- Placeholder format
- init-skill.sh generated template consistency

## Verification Checklist

```yaml
best_practices:
  - progressive_disclosure: check
  - frontmatter_format: check
  - content_limits: check
  - reference_depth: check

description:
  - length_ok: check
  - what_included: check
  - when_included: check
  - third_person: check

references:
  - toc_present: check (>100 lines need TOC)
  - format_consistent: check
  - usage_guidance_in_skill: check

scripts:
  - logic_correct: check
  - error_handling: check
  - when_to_call_documented: check
  - how_to_call_documented: check

template:
  - structure_valid: check
  - placeholders_clear: check
  - init_script_consistency: check
```
