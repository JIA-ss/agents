# Round 1 Review Fixes

## MAJOR Issues Fixed

### 1. Missing Interaction Mode Options
**Issue**: Command interface omitted `--interactive`, `--guided`, `--auto` options required by design.
**Fix**: Added interaction mode section to Commands with all three options and options table.

### 2. User Story Validation Logic
**Issue**: Script expected single-line pattern but templates use multi-line blocks.
**Fix**: Updated validate-spec.sh with:
- Multi-line pattern matching using `grep -Pzo`
- Fallback to single-line pattern
- Final fallback checking `As a` followed by `I want to` on next lines

## MINOR Issues Fixed

### 1. AC Count Logic Improvement
**Issue**: Fragile fallback `|| echo 1` could miscompute.
**Fix**:
- Separate checks for US count and AC count
- Only calculate average if both are > 0
- Added info message when within range

### 2. Forbidden Terms Synchronization
**Issue**: phase-details.md documented terms not enforced by script.
**Fix**:
- Updated validate-spec.sh to include all forbidden terms (EN + CN)
- Updated SKILL.md forbidden terms list to match
- Added "(unless quantified)" note to clarify exception

---

## Round 2 Fixes

### MINOR: AC Count Logic
**Issue**: `grep -c ... || echo 0` can emit `0` twice on no-match.
**Fix**:
- Initialize counts to 0 before grep
- Use conditional check before grep -c
- Only run arithmetic if counts are valid

### MINOR: User Story Validation Too Permissive
**Issue**: Fallback accepted "As a / I want to" without requiring "So that".
**Fix**:
- All three methods now require "So that" presence
- Method 3 explicitly checks for both "I want to" AND "So that"
- Added explicit error message stating all three parts required

---
*Fixed: 2026-01-13*
