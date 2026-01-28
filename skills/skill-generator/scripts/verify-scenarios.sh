#!/bin/bash
# Verify all test scenarios in a skill's test spec
# Usage: ./verify-scenarios.sh <skill-dir> [--dry-run]

set -e

SKILL_DIR="$1"
DRY_RUN=false

if [ "$2" = "--dry-run" ]; then
    DRY_RUN=true
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_pass() { echo -e "${GREEN}PASS${NC}: $1"; }
log_fail() { echo -e "${RED}FAIL${NC}: $1"; }
log_warn() { echo -e "${YELLOW}WARN${NC}: $1"; }
log_scenario() { echo -e "${CYAN}SCENARIO${NC}: $1"; }

if [ -z "$SKILL_DIR" ]; then
    echo "Usage: ./verify-scenarios.sh <skill-dir> [--dry-run]"
    echo ""
    echo "Verifies that all test scenarios in test-spec.yaml are properly structured"
    echo "and can be executed."
    echo ""
    echo "Options:"
    echo "  --dry-run    Only check structure, don't simulate execution"
    exit 1
fi

TEST_SPEC="$SKILL_DIR/tests/test-spec.yaml"
if [ ! -f "$TEST_SPEC" ]; then
    TEST_SPEC="$SKILL_DIR/tests/test-spec.yml"
fi

if [ ! -f "$TEST_SPEC" ]; then
    log_fail "No test-spec.yaml found in $SKILL_DIR/tests/"
    exit 1
fi

echo ""
echo "========================================"
echo "  Scenario Verifier"
echo "========================================"
echo "Test Spec: $TEST_SPEC"
echo "Dry Run: $DRY_RUN"
echo "========================================"
echo ""

# Initialize counters
TOTAL_SCENARIOS=0
VALID_SCENARIOS=0
INVALID_SCENARIOS=0

# Read scenarios and verify each one
log_info "Reading test scenarios..."
echo ""

# Extract scenario blocks (simplified parsing)
in_scenario=false
current_id=""
current_name=""
current_type=""
current_query=""
has_expected=false

while IFS= read -r line; do
    # Detect scenario start
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*id: ]]; then
        # Process previous scenario if exists
        if [ -n "$current_id" ]; then
            ((TOTAL_SCENARIOS++))
            log_scenario "$current_id - $current_name"

            errors=0

            # Validate required fields
            if [ -z "$current_name" ]; then
                log_fail "  Missing 'name'"
                ((errors++))
            fi

            if [ -z "$current_type" ]; then
                log_fail "  Missing 'type'"
                ((errors++))
            elif [[ ! "$current_type" =~ ^(trigger|execution|edge|negative|error)$ ]]; then
                log_fail "  Invalid type: $current_type (expected: trigger|execution|edge|negative|error)"
                ((errors++))
            fi

            if [ -z "$current_query" ]; then
                log_fail "  Missing 'query'"
                ((errors++))
            fi

            if [ "$has_expected" = false ]; then
                log_fail "  Missing 'expected_behavior'"
                ((errors++))
            fi

            if [ $errors -eq 0 ]; then
                log_pass "  All required fields present"
                ((VALID_SCENARIOS++))
            else
                ((INVALID_SCENARIOS++))
            fi
            echo ""
        fi

        # Start new scenario
        current_id=$(echo "$line" | sed 's/.*id:[[:space:]]*//' | tr -d '"'"'" | tr -d '[:space:]')
        current_name=""
        current_type=""
        current_query=""
        has_expected=false
        in_scenario=true
    fi

    if [ "$in_scenario" = true ]; then
        # Extract name
        if [[ "$line" =~ ^[[:space:]]*name: ]]; then
            current_name=$(echo "$line" | sed 's/.*name:[[:space:]]*//' | tr -d '"'"'")
        fi

        # Extract type
        if [[ "$line" =~ ^[[:space:]]*type: ]]; then
            current_type=$(echo "$line" | sed 's/.*type:[[:space:]]*//' | tr -d '"'"'')
        fi

        # Extract query
        if [[ "$line" =~ ^[[:space:]]*query: ]]; then
            current_query=$(echo "$line" | sed 's/.*query:[[:space:]]*//' | tr -d '"'"'')
        fi

        # Check for expected_behavior
        if [[ "$line" =~ ^[[:space:]]*expected_behavior: ]]; then
            has_expected=true
        fi
    fi
done < "$TEST_SPEC"

# Process last scenario
if [ -n "$current_id" ]; then
    ((TOTAL_SCENARIOS++))
    log_scenario "$current_id - $current_name"

    errors=0

    if [ -z "$current_name" ]; then
        log_fail "  Missing 'name'"
        ((errors++))
    fi

    if [ -z "$current_type" ]; then
        log_fail "  Missing 'type'"
        ((errors++))
    fi

    if [ -z "$current_query" ]; then
        log_fail "  Missing 'query'"
        ((errors++))
    fi

    if [ "$has_expected" = false ]; then
        log_fail "  Missing 'expected_behavior'"
        ((errors++))
    fi

    if [ $errors -eq 0 ]; then
        log_pass "  All required fields present"
        ((VALID_SCENARIOS++))
    else
        ((INVALID_SCENARIOS++))
    fi
fi

echo ""
echo "========================================"
echo "  Verification Summary"
echo "========================================"
echo "Total Scenarios: $TOTAL_SCENARIOS"
echo -e "Valid:          ${GREEN}$VALID_SCENARIOS${NC}"
echo -e "Invalid:        ${RED}$INVALID_SCENARIOS${NC}"
echo "========================================"
echo ""

# Coverage check
log_info "Checking scenario coverage..."

TRIGGER_COUNT=$(grep -c 'type: "trigger"' "$TEST_SPEC" 2>/dev/null || echo "0")
EXEC_COUNT=$(grep -c 'type: "execution"' "$TEST_SPEC" 2>/dev/null || echo "0")
EDGE_COUNT=$(grep -c 'type: "edge"' "$TEST_SPEC" 2>/dev/null || echo "0")
NEGATIVE_COUNT=$(grep -c 'type: "negative"' "$TEST_SPEC" 2>/dev/null || echo "0")
ERROR_COUNT=$(grep -c 'type: "error"' "$TEST_SPEC" 2>/dev/null || echo "0")

echo ""
echo "Scenario Type Coverage:"
echo "  trigger:   $TRIGGER_COUNT $([ $TRIGGER_COUNT -gt 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}MISSING${NC}")"
echo "  execution: $EXEC_COUNT $([ $EXEC_COUNT -gt 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}MISSING${NC}")"
echo "  edge:      $EDGE_COUNT $([ $EDGE_COUNT -gt 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}MISSING${NC}")"
echo "  negative:  $NEGATIVE_COUNT $([ $NEGATIVE_COUNT -gt 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}MISSING${NC}")"
echo "  error:     $ERROR_COUNT $([ $ERROR_COUNT -gt 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${YELLOW}OPTIONAL${NC}")"
echo ""

# Recommendations
if [ $TOTAL_SCENARIOS -lt 3 ]; then
    log_warn "Recommendation: Add more scenarios (minimum 3 recommended)"
fi

if [ $TRIGGER_COUNT -eq 0 ]; then
    log_warn "Recommendation: Add trigger test to verify skill activation"
fi

if [ $NEGATIVE_COUNT -eq 0 ]; then
    log_warn "Recommendation: Add negative test to prevent false activation"
fi

# Exit code
if [ $INVALID_SCENARIOS -gt 0 ]; then
    log_fail "Some scenarios are invalid - fix before continuing"
    exit 1
else
    log_pass "All scenarios verified successfully"
    exit 0
fi
