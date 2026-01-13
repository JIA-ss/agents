# Round 1 Review Fixes

## MAJOR Issues Fixed

### 1. Template Variants vs Validation Rules Mismatch
**Issue**: Mini/Standard templates omit sections (NFR, Constraints, Change History) but validation rules and checklists still require them.

**Fix**:
1. Updated section 3.3 to add "必需章节" column clarifying what each mode requires
2. Added section 4.3 with mode-aware validation configuration:
   - `required_sections` defines per-mode mandatory sections
   - Each auto_check now has `modes` array specifying which modes it applies to
3. Added section 4.4 "模式感知的 Checklist" mapping checklist items to modes

## MINOR Issues Fixed

### 1. Undocumented Interaction Mode Flags
**Issue**: `--auto` flag and guided mode mentioned but not documented in command interface.

**Fix**: Expanded section 5.1 命令接口:
- Added explicit `--interactive`, `--guided`, `--auto` flag documentation
- Added options table with defaults and descriptions
- Clarified that `--interactive` is the default behavior

### 2. Overly Strict CAPTURE/CLARIFY Acceptance Criteria
**Issue**: Hard requirements for open questions could block unambiguous requests.

**Fix**: Updated sections 4.1:
- CAPTURE: Added `condition: "ambiguity_detected == true"` for open_questions requirement
- CLARIFY: Added `condition` for open_questions_reduced
- CLARIFY: Added `skip_condition` allowing bypass when no ambiguity detected

---

## Round 2 Fixes

### MAJOR: Section Identifier Mismatch
**Issue**: `required_sections` used identifiers like `acceptance_criteria` and `constraints` that don't match spec.md structure.

**Fix**:
1. Added section mapping comment in 4.3
2. Changed identifiers to match spec.md: `1_overview`, `3_user_stories`, `6_constraints_and_assumptions`, etc.
3. Updated `constraints_documented` rule to use `6_constraints_and_assumptions`

### MINOR: Undefined skip_condition Field
**Issue**: `no_ambiguous_terms` in skip_condition not defined in phase outputs.

**Fix**:
1. Changed skip_condition to use `capture.ambiguity_score == 0`
2. Added `ambiguity_score` to CAPTURE output metrics
3. Added calculation rules comment explaining how ambiguity_score is computed
4. Added `ambiguity_detected` boolean derived from ambiguity_score

---

## Round 3 Fixes

### MAJOR: Template vs Validation Mismatch (再次)
**Issue**: Section 3.3 template variants table and section 4.3 required_sections still had inconsistencies:
- 3.3 listed different sections than 4.3 for mini mode (missing Acceptance Checklist in 3.3)
- Naming conventions were inconsistent

**Fix**:
1. Rewrote section 3.3 table using explicit chapter numbers:
   - Mini: 1 (Overview), 3 (US+AC), 7 (Out of Scope), 9 (Checklist)
   - Standard: 1-7, 9 (Checklist)
   - Full: All (1-9, Appendix A-C)
2. Added note in 4.3 to maintain consistency with 3.3
3. Added inline comments in required_sections explaining the mapping

---
*Fixed: 2026-01-13*
