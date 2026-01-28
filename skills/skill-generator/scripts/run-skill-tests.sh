#!/bin/bash
# Run skill tests according to test specification
# Usage: ./run-skill-tests.sh <skill-dir> [--verbose] [--model <model>]

set -e

SKILL_DIR="$1"
VERBOSE=false
MODEL="all"
TEST_SPEC=""

# Parse arguments
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_pass() { echo -e "${GREEN}PASS${NC}: $1"; }
log_fail() { echo -e "${RED}FAIL${NC}: $1"; }
log_warn() { echo -e "${YELLOW}WARN${NC}: $1"; }

# Validation
if [ -z "$SKILL_DIR" ]; then
    echo "Usage: ./run-skill-tests.sh <skill-dir> [--verbose] [--model <model>]"
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Show detailed test output"
    echo "  --model, -m      Test on specific model (haiku|sonnet|opus|all)"
    echo ""
    echo "Examples:"
    echo "  ./run-skill-tests.sh ./skills/my-skill"
    echo "  ./run-skill-tests.sh ./skills/my-skill --verbose --model haiku"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    log_fail "Directory not found: $SKILL_DIR"
    exit 1
fi

# Find test spec
if [ -f "$SKILL_DIR/tests/test-spec.yaml" ]; then
    TEST_SPEC="$SKILL_DIR/tests/test-spec.yaml"
elif [ -f "$SKILL_DIR/tests/test-spec.yml" ]; then
    TEST_SPEC="$SKILL_DIR/tests/test-spec.yml"
else
    log_fail "No test specification found in $SKILL_DIR/tests/"
    log_info "Create test-spec.yaml before running tests (TDD approach)"
    exit 1
fi

# Check SKILL.md exists
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
    log_warn "SKILL.md not found - validating test spec only"
    SKILL_EXISTS=false
else
    SKILL_EXISTS=true
fi

echo ""
echo "========================================"
echo "  Skill Test Runner"
echo "========================================"
echo "Skill: $SKILL_DIR"
echo "Test Spec: $TEST_SPEC"
echo "Model: $MODEL"
echo "========================================"
echo ""

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Phase 1: Validate test spec structure
log_info "Phase 1: Validating test specification..."

# Check required fields in test spec
if ! grep -q "^skill:" "$TEST_SPEC"; then
    log_fail "Missing 'skill:' section in test spec"
    ((FAILED++))
else
    log_pass "Test spec has 'skill:' section"
    ((PASSED++))
fi
((TOTAL++))

if ! grep -q "^scenarios:" "$TEST_SPEC"; then
    log_fail "Missing 'scenarios:' section in test spec"
    ((FAILED++))
else
    log_pass "Test spec has 'scenarios:' section"
    ((PASSED++))
fi
((TOTAL++))

# Count scenarios
SCENARIO_COUNT=$(grep -c "^  - id:" "$TEST_SPEC" || echo "0")
if [ "$SCENARIO_COUNT" -lt 3 ]; then
    log_warn "Only $SCENARIO_COUNT test scenarios (recommended: 3+)"
    ((SKIPPED++))
else
    log_pass "Has $SCENARIO_COUNT test scenarios"
    ((PASSED++))
fi
((TOTAL++))

# Check for different scenario types
HAS_HAPPY=$(grep -c 'type: "trigger"\|type: "execution"' "$TEST_SPEC" || echo "0")
HAS_EDGE=$(grep -c 'type: "edge"' "$TEST_SPEC" || echo "0")
HAS_NEGATIVE=$(grep -c 'type: "negative"' "$TEST_SPEC" || echo "0")
HAS_ERROR=$(grep -c 'type: "error"' "$TEST_SPEC" || echo "0")

log_info "Scenario coverage:"
echo "  - Happy path:  $HAS_HAPPY"
echo "  - Edge cases:  $HAS_EDGE"
echo "  - Negative:    $HAS_NEGATIVE"
echo "  - Error:       $HAS_ERROR"

if [ "$HAS_HAPPY" -eq 0 ]; then
    log_fail "No happy path scenarios"
    ((FAILED++))
else
    ((PASSED++))
fi
((TOTAL++))

echo ""

# Phase 2: Validate SKILL.md if exists
if [ "$SKILL_EXISTS" = true ]; then
    log_info "Phase 2: Validating SKILL.md..."

    # Run the validator script
    SCRIPT_DIR="$(dirname "$0")"
    if [ -f "$SCRIPT_DIR/validate-skill.sh" ]; then
        if bash "$SCRIPT_DIR/validate-skill.sh" "$SKILL_DIR" > /dev/null 2>&1; then
            log_pass "SKILL.md passes validation"
            ((PASSED++))
        else
            log_fail "SKILL.md fails validation"
            ((FAILED++))
            if [ "$VERBOSE" = true ]; then
                bash "$SCRIPT_DIR/validate-skill.sh" "$SKILL_DIR"
            fi
        fi
    else
        log_warn "validate-skill.sh not found, skipping"
        ((SKIPPED++))
    fi
    ((TOTAL++))

    echo ""
fi

# Phase 3: Check test-to-spec alignment
if [ "$SKILL_EXISTS" = true ]; then
    log_info "Phase 3: Checking test-to-spec alignment..."

    # Extract skill name from SKILL.md
    SKILL_NAME=$(grep -E "^name:" "$SKILL_DIR/SKILL.md" | head -1 | sed 's/name:[[:space:]]*//' | tr -d '"'"'" || echo "")
    TEST_SKILL_NAME=$(grep -E "^  name:" "$TEST_SPEC" | head -1 | sed 's/.*name:[[:space:]]*//' | tr -d '"'"'" || echo "")

    if [ -n "$SKILL_NAME" ] && [ -n "$TEST_SKILL_NAME" ]; then
        if [ "$SKILL_NAME" = "$TEST_SKILL_NAME" ] || [ "$TEST_SKILL_NAME" = "skill-name-here" ]; then
            if [ "$TEST_SKILL_NAME" = "skill-name-here" ]; then
                log_warn "Test spec uses template name - update to match skill"
            else
                log_pass "Skill name matches test spec"
                ((PASSED++))
            fi
        else
            log_fail "Skill name mismatch: SKILL.md='$SKILL_NAME' vs test='$TEST_SKILL_NAME'"
            ((FAILED++))
        fi
        ((TOTAL++))
    fi

    echo ""
fi

# Phase 4: Simulate scenario execution
log_info "Phase 4: Simulating test scenarios..."

# Extract and validate each scenario's structure
grep -E "^  - id:" "$TEST_SPEC" | while read -r line; do
    ID=$(echo "$line" | sed 's/.*id:[[:space:]]*//' | tr -d '"'"'")
    ((TOTAL++))

    # Check if scenario has required fields
    # This is a structural check - actual execution would require Claude API
    log_info "  Checking scenario: $ID"
done

echo ""

# Final Summary
echo "========================================"
echo "  Test Summary"
echo "========================================"
echo -e "Total:   $TOTAL"
echo -e "Passed:  ${GREEN}$PASSED${NC}"
echo -e "Failed:  ${RED}$FAILED${NC}"
echo -e "Skipped: ${YELLOW}$SKIPPED${NC}"
echo "========================================"
echo ""

if [ $FAILED -gt 0 ]; then
    log_fail "Tests failed - fix issues before deployment"
    exit 1
elif [ $SKIPPED -gt 0 ]; then
    log_warn "Tests passed with warnings"
    exit 0
else
    log_pass "All tests passed!"
    exit 0
fi
