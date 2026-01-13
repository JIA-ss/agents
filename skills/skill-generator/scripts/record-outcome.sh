#!/bin/bash
# Record skill execution outcome for self-iteration analysis
# Usage: ./record-outcome.sh <skill-dir> <status> [options]
#
# Options:
#   --input       User input/request that triggered the skill
#   --expected    Expected outcome or behavior
#   --actual      Actual outcome or result
#   --error-class Explicit error classification (execution|reasoning)
#   --details     Additional details about the outcome

set -e

SKILL_DIR=""
STATUS=""
DETAILS=""
INPUT=""
EXPECTED=""
ACTUAL=""
ERROR_CLASS=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --input)
            INPUT="$2"
            shift 2
            ;;
        --expected)
            EXPECTED="$2"
            shift 2
            ;;
        --actual)
            ACTUAL="$2"
            shift 2
            ;;
        --error-class)
            ERROR_CLASS="$2"
            shift 2
            ;;
        --details)
            DETAILS="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$SKILL_DIR" ]; then
                SKILL_DIR="$1"
            elif [ -z "$STATUS" ]; then
                STATUS="$1"
            else
                # Legacy: third positional arg is details
                DETAILS="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$SKILL_DIR" ] || [ -z "$STATUS" ]; then
    echo "Usage: ./record-outcome.sh <skill-dir> <status> [options]"
    echo ""
    echo "Arguments:"
    echo "  skill-dir  Path to skill directory"
    echo "  status     Outcome status: success | failure"
    echo ""
    echo "Options:"
    echo "  --input       User input/request that triggered the skill"
    echo "  --expected    Expected outcome or behavior"
    echo "  --actual      Actual outcome or result"
    echo "  --error-class Error classification: execution | reasoning"
    echo "  --details     Additional details about the outcome"
    echo ""
    echo "Examples:"
    echo "  # Simple usage (backwards compatible):"
    echo "  ./record-outcome.sh ./skills/my-skill success 'Completed in 2.3s'"
    echo "  ./record-outcome.sh ./skills/my-skill failure 'ValidationError: missing field'"
    echo ""
    echo "  # Full decision chain recording:"
    echo "  ./record-outcome.sh ./skills/my-skill failure \\"
    echo "    --input 'Generate PDF report' \\"
    echo "    --expected 'PDF file created with charts' \\"
    echo "    --actual 'Error: matplotlib not installed' \\"
    echo "    --error-class execution \\"
    echo "    --details 'Missing dependency in environment'"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory not found: $SKILL_DIR"
    exit 1
fi

# Validate status
if [[ "$STATUS" != "success" && "$STATUS" != "failure" ]]; then
    echo "Error: Status must be 'success' or 'failure'"
    exit 1
fi

# Validate error-class if provided
if [[ -n "$ERROR_CLASS" ]] && [[ "$ERROR_CLASS" != "execution" && "$ERROR_CLASS" != "reasoning" ]]; then
    echo "Error: --error-class must be 'execution' or 'reasoning'"
    echo "  execution: Runtime errors, missing dependencies, permission issues"
    echo "  reasoning: Wrong approach, incorrect output, misunderstood requirements"
    exit 1
fi

# Create evolution directory if not exists
EVOLUTION_DIR="$SKILL_DIR/.evolution"
METRICS_DIR="$EVOLUTION_DIR/metrics"
FAILURES_DIR="$EVOLUTION_DIR/failures"

mkdir -p "$METRICS_DIR" "$FAILURES_DIR"

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_PART=$(date -u +"%Y-%m-%d")

# Determine error type from details (improved heuristics)
ERROR_TYPE="unknown"
if [[ "$STATUS" == "failure" ]]; then
    # Check explicit error class first
    if [[ -n "$ERROR_CLASS" ]]; then
        ERROR_TYPE="$ERROR_CLASS"
    # Then try heuristic detection from details
    elif [[ "$DETAILS" == *"Validation"* ]] || [[ "$DETAILS" == *"ValidationError"* ]]; then
        ERROR_TYPE="validation"
    elif [[ "$DETAILS" == *"Timeout"* ]] || [[ "$DETAILS" == *"timed out"* ]]; then
        ERROR_TYPE="timeout"
    elif [[ "$DETAILS" == *"Permission"* ]] || [[ "$DETAILS" == *"Access denied"* ]]; then
        ERROR_TYPE="permission"
    elif [[ "$DETAILS" == *"NotFound"* ]] || [[ "$DETAILS" == *"not found"* ]] || [[ "$DETAILS" == *"does not exist"* ]]; then
        ERROR_TYPE="not_found"
    elif [[ "$DETAILS" == *"import"* ]] || [[ "$DETAILS" == *"dependency"* ]] || [[ "$DETAILS" == *"not installed"* ]]; then
        ERROR_TYPE="execution"
    elif [[ "$DETAILS" == *"wrong"* ]] || [[ "$DETAILS" == *"incorrect"* ]] || [[ "$DETAILS" == *"misunderstood"* ]]; then
        ERROR_TYPE="reasoning"
    fi
fi

# Escape JSON strings
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

DETAILS_ESC=$(escape_json "$DETAILS")
INPUT_ESC=$(escape_json "$INPUT")
EXPECTED_ESC=$(escape_json "$EXPECTED")
ACTUAL_ESC=$(escape_json "$ACTUAL")

# Append to execution log with full decision chain
LOG_FILE="$METRICS_DIR/execution-log.jsonl"
LOG_ENTRY="{\"timestamp\":\"$TIMESTAMP\",\"status\":\"$STATUS\",\"error_type\":\"$ERROR_TYPE\""

# Add error_class if explicitly provided (for structured analytics)
if [[ -n "$ERROR_CLASS" ]]; then
    LOG_ENTRY="$LOG_ENTRY,\"error_class\":\"$ERROR_CLASS\""
fi

# Add decision chain fields if provided
if [[ -n "$INPUT" ]]; then
    LOG_ENTRY="$LOG_ENTRY,\"input\":\"$INPUT_ESC\""
fi
if [[ -n "$EXPECTED" ]]; then
    LOG_ENTRY="$LOG_ENTRY,\"expected\":\"$EXPECTED_ESC\""
fi
if [[ -n "$ACTUAL" ]]; then
    LOG_ENTRY="$LOG_ENTRY,\"actual\":\"$ACTUAL_ESC\""
fi
if [[ -n "$DETAILS" ]]; then
    LOG_ENTRY="$LOG_ENTRY,\"details\":\"$DETAILS_ESC\""
fi

LOG_ENTRY="$LOG_ENTRY}"
echo "$LOG_ENTRY" >> "$LOG_FILE"

# If failure, create failure record
if [[ "$STATUS" == "failure" ]]; then
    FAILURE_FILE="$FAILURES_DIR/${DATE_PART}-$(date +%H%M%S)-${ERROR_TYPE}.md"

    cat > "$FAILURE_FILE" << EOF
# Failure Record: $TIMESTAMP

## Decision Chain

### Input
${INPUT:-[Not recorded]}

### Expected Outcome
${EXPECTED:-[Not recorded]}

### Actual Outcome
${ACTUAL:-[Not recorded]}

## Context
- **Timestamp**: $TIMESTAMP
- **Error Type**: $ERROR_TYPE
- **Error Class**: ${ERROR_CLASS:-[auto-detected]}
- **Details**: ${DETAILS:-[No details provided]}

## Error Classification
- **Type**: $ERROR_TYPE
- **Class**: ${ERROR_CLASS:-unknown} (execution = runtime/environment, reasoning = logic/approach)
- **Severity**: TBD
- **Reproducible**: unknown

## Root Cause Analysis
[To be analyzed]

## Proposed Fix
- [ ] SKILL.md update needed
- [ ] Script fix needed
- [ ] Reference update needed
- [ ] New validation rule needed

## Related Patterns
- Pattern ID: [if matches existing pattern]
EOF

    echo "Failure recorded: $FAILURE_FILE"
fi

echo "Outcome recorded: $STATUS at $TIMESTAMP"

# Update changelog for significant events
CHANGELOG="$EVOLUTION_DIR/changelog.md"
if [[ "$STATUS" == "failure" ]] && [ -f "$CHANGELOG" ]; then
    echo "| $DATE_PART | failure | $ERROR_TYPE: ${DETAILS:0:50}... |" >> "$CHANGELOG"
fi

# Check if improvement trigger threshold reached
if [[ "$STATUS" == "failure" ]]; then
    # Count recent failures (last 24 hours)
    RECENT_FAILURES=$(grep -c "\"status\":\"failure\"" "$LOG_FILE" 2>/dev/null | tail -1 || echo "0")

    # Check config for threshold
    CONFIG_FILE="$EVOLUTION_DIR/config.yaml"
    if [ -f "$CONFIG_FILE" ]; then
        THRESHOLD=$(grep "consecutive_failures:" "$CONFIG_FILE" | awk '{print $2}' || echo "3")
    else
        THRESHOLD=3
    fi

    if [ "$RECENT_FAILURES" -ge "$THRESHOLD" ]; then
        echo ""
        echo "⚠️  Improvement trigger threshold reached ($RECENT_FAILURES failures)"
        echo "   Run: ./scripts/analyze-trends.sh $SKILL_DIR"
    fi
fi
