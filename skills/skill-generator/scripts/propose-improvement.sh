#!/bin/bash
# Generate improvement proposal based on failure patterns
# Usage: ./propose-improvement.sh <skill-dir> [pattern-id]

set -e

SKILL_DIR="$1"
PATTERN_ID="${2:-}"

if [ -z "$SKILL_DIR" ]; then
    echo "Usage: ./propose-improvement.sh <skill-dir> [pattern-id]"
    echo ""
    echo "Arguments:"
    echo "  skill-dir   Path to skill directory"
    echo "  pattern-id  Optional: specific pattern to address"
    echo ""
    echo "Example:"
    echo "  ./propose-improvement.sh ./skills/my-skill"
    echo "  ./propose-improvement.sh ./skills/my-skill pattern-validation"
    exit 1
fi

EVOLUTION_DIR="$SKILL_DIR/.evolution"
PATTERNS_DIR="$EVOLUTION_DIR/patterns"
FAILURES_DIR="$EVOLUTION_DIR/failures"
IMPROVEMENTS_DIR="$EVOLUTION_DIR/improvements"

mkdir -p "$IMPROVEMENTS_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_PART=$(date -u +"%Y-%m-%d")
PROPOSAL_FILE="$IMPROVEMENTS_DIR/${DATE_PART}-proposal.md"

# Gather failure information
echo "Analyzing failures..."

# Count failures by type
declare -A ERROR_COUNTS
if [ -d "$FAILURES_DIR" ]; then
    for file in "$FAILURES_DIR"/*.md; do
        if [ -f "$file" ]; then
            # Extract error type from filename
            type=$(basename "$file" | sed 's/.*-\([^-]*\)\.md/\1/')
            ((ERROR_COUNTS[$type]++)) || ERROR_COUNTS[$type]=1
        fi
    done
fi

# Find top pattern
TOP_PATTERN=""
TOP_COUNT=0
for type in "${!ERROR_COUNTS[@]}"; do
    if [ "${ERROR_COUNTS[$type]}" -gt "$TOP_COUNT" ]; then
        TOP_COUNT="${ERROR_COUNTS[$type]}"
        TOP_PATTERN="$type"
    fi
done

if [ -n "$PATTERN_ID" ]; then
    TARGET_PATTERN=$(echo "$PATTERN_ID" | sed 's/pattern-//')
elif [ -n "$TOP_PATTERN" ]; then
    TARGET_PATTERN="$TOP_PATTERN"
else
    echo "No failure patterns found. Nothing to improve."
    exit 0
fi

echo "Target pattern: $TARGET_PATTERN (${ERROR_COUNTS[$TARGET_PATTERN]:-0} occurrences)"

# Read skill name from SKILL.md
SKILL_NAME=$(grep "^name:" "$SKILL_DIR/SKILL.md" | sed 's/name:[[:space:]]*//' | tr -d '"'"'" || echo "unknown")

# Generate proposal
cat > "$PROPOSAL_FILE" << EOF
# Improvement Proposal: $DATE_PART

## Metadata
- **Skill**: $SKILL_NAME
- **Generated**: $TIMESTAMP
- **Status**: pending

## Trigger
- **Type**: pattern_threshold
- **Pattern**: $TARGET_PATTERN
- **Occurrences**: ${ERROR_COUNTS[$TARGET_PATTERN]:-0}

## Failure Analysis

### Pattern Description
Recurring \`$TARGET_PATTERN\` errors detected during skill execution.

### Affected Executions
EOF

# List related failure files
if [ -d "$FAILURES_DIR" ]; then
    find "$FAILURES_DIR" -name "*-${TARGET_PATTERN}.md" -type f 2>/dev/null | head -5 | \
        while read file; do
            echo "- $(basename "$file")" >> "$PROPOSAL_FILE"
        done
fi

cat >> "$PROPOSAL_FILE" << EOF

### Root Cause Hypothesis
Based on the pattern analysis, the likely root cause is:
- [ ] Missing validation in Core Rules
- [ ] Unclear instructions in Workflow
- [ ] Edge case not covered in Output Requirements
- [ ] Script bug or limitation

## Proposed Changes

### Option A: SKILL.md Update
\`\`\`diff
## Core Rules

+ N. **[New Rule]** - [Description addressing $TARGET_PATTERN errors]
\`\`\`

### Option B: Script Enhancement
\`\`\`bash
# Add validation for $TARGET_PATTERN case
# [Specific code changes]
\`\`\`

### Option C: Reference Addition
Create new reference document with detailed guidance for handling $TARGET_PATTERN cases.

## Validation Plan

1. [ ] Run existing skill validator
2. [ ] Test with cases that previously failed
3. [ ] Verify no performance regression
4. [ ] Check no new failure patterns introduced

## Rollback Plan

If validation fails:
1. Revert SKILL.md to previous version
2. Document why proposed fix didn't work
3. Mark pattern for human review

## Approval

- [ ] Auto-validated (if enabled)
- [ ] Human reviewed
- [ ] Deployed

---

## Next Steps

1. Review this proposal
2. Choose appropriate option (A, B, or C)
3. Implement the change
4. Run validation:
   \`\`\`bash
   ./scripts/validate-improvement.sh $SKILL_DIR $PROPOSAL_FILE
   \`\`\`
5. Deploy if validation passes:
   \`\`\`bash
   ./scripts/deploy-improvement.sh $SKILL_DIR $PROPOSAL_FILE
   \`\`\`
EOF

echo ""
echo "Improvement proposal generated: $PROPOSAL_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the proposal: cat $PROPOSAL_FILE"
echo "  2. Edit to add specific fixes"
echo "  3. Validate: ./scripts/validate-improvement.sh $SKILL_DIR $PROPOSAL_FILE"
echo "  4. Deploy: ./scripts/deploy-improvement.sh $SKILL_DIR $PROPOSAL_FILE"
