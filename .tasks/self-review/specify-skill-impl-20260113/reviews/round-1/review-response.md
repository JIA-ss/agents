verdict: NEEDS_IMPROVEMENT
confidence: 0.63

- MAJOR: `skills/specify/SKILL.md:82` Command interface omits `--interactive`, `--guided`, and `--auto`, which are required by the design spec.
- MAJOR: `skills/specify/scripts/validate-spec.sh:36` User story format check expects a single-line "As a ... I want ... So that" pattern, but templates/design use multi-line blocks, so valid specs will be flagged as errors.
- MINOR: `skills/specify/scripts/validate-spec.sh:43` AC count validation averages across all stories and uses a fragile `grep -c ... || echo 1` fallback, so it can miscompute and does not enforce 3–7 AC per story.
- MINOR: `skills/specify/references/phase-details.md:182` lists forbidden terms (e.g., quick/robust/scalable, 直观/健壮/可扩展) that are not enforced by `skills/specify/scripts/validate-spec.sh:22`.
