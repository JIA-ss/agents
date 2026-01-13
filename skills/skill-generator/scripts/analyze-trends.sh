#!/bin/bash
# Analyze skill execution trends and identify patterns
# Usage: ./analyze-trends.sh <skill-dir> [--days N]

set -e

SKILL_DIR="$1"
DAYS=7

# Parse arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --days)
            DAYS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$SKILL_DIR" ]; then
    echo "Usage: ./analyze-trends.sh <skill-dir> [--days N]"
    echo ""
    echo "Arguments:"
    echo "  skill-dir  Path to skill directory"
    echo "  --days N   Number of days to analyze (default: 7)"
    echo ""
    echo "Example:"
    echo "  ./analyze-trends.sh ./skills/my-skill --days 14"
    exit 1
fi

EVOLUTION_DIR="$SKILL_DIR/.evolution"
METRICS_DIR="$EVOLUTION_DIR/metrics"
PATTERNS_DIR="$EVOLUTION_DIR/patterns"
LOG_FILE="$METRICS_DIR/execution-log.jsonl"

if [ ! -f "$LOG_FILE" ]; then
    echo "No execution data found. Record outcomes first with record-outcome.sh"
    exit 0
fi

# Create patterns directory if not exists
mkdir -p "$PATTERNS_DIR"

# Calculate date threshold
if [[ "$OSTYPE" == "darwin"* ]]; then
    THRESHOLD_DATE=$(date -v-${DAYS}d +"%Y-%m-%d")
else
    THRESHOLD_DATE=$(date -d "$DAYS days ago" +"%Y-%m-%d")
fi

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Skill Execution Trend Analysis                    ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Skill: $(basename "$SKILL_DIR")"
echo "Period: Last $DAYS days (since $THRESHOLD_DATE)"
echo ""

# Count totals
TOTAL=$(wc -l < "$LOG_FILE" | tr -d ' ')
SUCCESS=$(grep -c '"status":"success"' "$LOG_FILE" || echo "0")
FAILURE=$(grep -c '"status":"failure"' "$LOG_FILE" || echo "0")

if [ "$TOTAL" -eq 0 ]; then
    echo "No executions recorded."
    exit 0
fi

SUCCESS_RATE=$(echo "scale=1; $SUCCESS * 100 / $TOTAL" | bc)
FAILURE_RATE=$(echo "scale=1; $FAILURE * 100 / $TOTAL" | bc)

echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Execution Summary                                               │"
echo "├─────────────────────────────────────────────────────────────────┤"
printf "│ Total: %-5s │ Success: %-5s (%s%%) │ Failure: %-5s (%s%%)    │\n" "$TOTAL" "$SUCCESS" "$SUCCESS_RATE" "$FAILURE" "$FAILURE_RATE"
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Analyze error patterns
if [ "$FAILURE" -gt 0 ]; then
    echo "┌─────────────────────────────────────────────────────────────────┐"
    echo "│ Error Pattern Analysis                                          │"
    echo "├─────────────────────────────────────────────────────────────────┤"

    # Count by error type
    echo "│ Error Type         │ Count │ Percentage                        │"
    echo "├────────────────────┼───────┼───────────────────────────────────┤"

    # Extract and count error types
    grep '"status":"failure"' "$LOG_FILE" | \
        sed 's/.*"error_type":"\([^"]*\)".*/\1/' | \
        sort | uniq -c | sort -rn | \
        while read count type; do
            pct=$(echo "scale=1; $count * 100 / $FAILURE" | bc)
            printf "│ %-18s │ %5s │ %5s%%                              │\n" "$type" "$count" "$pct"

            # Check if pattern file exists
            PATTERN_FILE="$PATTERNS_DIR/pattern-${type}.md"
            if [ ! -f "$PATTERN_FILE" ] && [ "$count" -ge 3 ]; then
                # Create pattern file
                cat > "$PATTERN_FILE" << EOF
# Pattern: $type

## Description
Recurring $type errors detected in skill execution.

## Occurrences
$count occurrences in the last $DAYS days

## Analysis Required
- [ ] Review failure records in failures/
- [ ] Identify root cause
- [ ] Propose fix to SKILL.md or scripts

## Recommended Action
Run: ./scripts/propose-improvement.sh $SKILL_DIR pattern-${type}
EOF
            fi
        done

    echo "└────────────────────┴───────┴───────────────────────────────────┘"
    echo ""

    # List patterns that need attention
    PATTERNS_NEEDING_ATTENTION=$(find "$PATTERNS_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$PATTERNS_NEEDING_ATTENTION" -gt 0 ]; then
        echo "┌─────────────────────────────────────────────────────────────────┐"
        echo "│ Patterns Requiring Attention                                    │"
        echo "├─────────────────────────────────────────────────────────────────┤"
        find "$PATTERNS_DIR" -name "*.md" -type f -exec basename {} .md \; | \
            while read pattern; do
                printf "│ • %-61s │\n" "$pattern"
            done
        echo "└─────────────────────────────────────────────────────────────────┘"
        echo ""
    fi
fi

# Recommendations
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Recommendations                                                 │"
echo "├─────────────────────────────────────────────────────────────────┤"

if [ "$FAILURE_RATE" = "0" ] || [ "$FAILURE_RATE" = "0.0" ]; then
    printf "│ ✅ %-60s │\n" "No failures detected. Skill performing well."
elif (( $(echo "$FAILURE_RATE > 20" | bc -l) )); then
    printf "│ ⚠️  %-60s │\n" "High failure rate (>20%). Immediate review recommended."
    printf "│    %-60s │\n" "Run: ./scripts/propose-improvement.sh $SKILL_DIR"
elif (( $(echo "$FAILURE_RATE > 10" | bc -l) )); then
    printf "│ 🔍 %-60s │\n" "Moderate failure rate. Review top error patterns."
else
    printf "│ ℹ️  %-60s │\n" "Low failure rate. Monitor for pattern accumulation."
fi

echo "└─────────────────────────────────────────────────────────────────┘"
