verdict: NEEDS_IMPROVEMENT
confidence: 0.62
issues:
  - severity: MAJOR
    location: `.tasks/self-review/specify-phase-design-20260113/specify-phase-design.md:570`
    description: "Mode-aware required_sections use identifiers that do not align with the spec structure/template: acceptance_criteria/AC is not a top-level section (it is nested under User Stories) and constraints does not match the defined constraints_and_assumptions section, so validation can fail or skip required content."
  - severity: MINOR
    location: `.tasks/self-review/specify-phase-design-20260113/specify-phase-design.md:497`
    description: "CLARIFY skip_condition uses no_ambiguous_terms, but that field is not defined in phase outputs or acceptance criteria (only appears as an auto_check name), making the skip rule ambiguous."
