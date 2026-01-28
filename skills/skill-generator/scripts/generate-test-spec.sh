#!/bin/bash
# Generate test specification from skill requirements
# Usage: ./generate-test-spec.sh <skill-name> [output-dir]
#
# This script creates a test-spec.yaml template based on provided skill info.
# Following TDD principles, run this BEFORE writing SKILL.md

set -e

SKILL_NAME="$1"
OUTPUT_DIR="${2:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}INFO${NC}: $1"; }
log_pass() { echo -e "${GREEN}OK${NC}: $1"; }
log_warn() { echo -e "${YELLOW}WARN${NC}: $1"; }

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: ./generate-test-spec.sh <skill-name> [output-dir]"
    echo ""
    echo "Generates a test specification template for a new skill."
    echo "Following TDD: create tests BEFORE writing SKILL.md"
    echo ""
    echo "Examples:"
    echo "  ./generate-test-spec.sh pdf-processor"
    echo "  ./generate-test-spec.sh my-skill ./skills/my-skill"
    exit 1
fi

# Validate skill name
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}ERROR${NC}: Invalid skill name '$SKILL_NAME'"
    echo "Must contain only lowercase letters, numbers, and hyphens"
    exit 1
fi

# Create output directory if needed
TESTS_DIR="$OUTPUT_DIR/tests"
mkdir -p "$TESTS_DIR"

TEST_SPEC="$TESTS_DIR/test-spec.yaml"

if [ -f "$TEST_SPEC" ]; then
    log_warn "Test spec already exists: $TEST_SPEC"
    read -p "Overwrite? (y/N): " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

log_info "Generating test specification for: $SKILL_NAME"

# Generate the test spec
cat > "$TEST_SPEC" << EOF
# Test Specification for ${SKILL_NAME}
# Generated: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
#
# TDD Workflow:
# 1. Define test scenarios (this file)
# 2. Run verify-scenarios.sh to validate structure
# 3. Write SKILL.md to make tests pass
# 4. Run run-skill-tests.sh to verify

skill:
  name: "${SKILL_NAME}"
  description: "TODO: Add skill description"

# Test scenarios - define expected behavior BEFORE implementation
scenarios:
  #############################################
  # TRIGGER TESTS - Does skill activate correctly?
  #############################################
  - id: "trigger-basic"
    name: "Basic trigger test"
    type: "trigger"
    query: "TODO: Add user query that should trigger this skill"
    expected_behavior:
      - "Skill activates"
      - "TODO: Add expected behavior"

  - id: "trigger-chinese"
    name: "Chinese trigger test"
    type: "trigger"
    query: "TODO: Add Chinese query that should trigger this skill"
    expected_behavior:
      - "Skill activates with Chinese keywords"
      - "TODO: Add expected behavior"

  #############################################
  # EXECUTION TESTS - Does skill work correctly?
  #############################################
  - id: "exec-standard"
    name: "Standard execution"
    type: "execution"
    query: "TODO: Add typical user request"
    expected_behavior:
      - "TODO: Define expected behavior 1"
      - "TODO: Define expected behavior 2"
      - "TODO: Define expected output format"
    expected_output:
      format: "markdown"
      contains:
        - "TODO: expected content"

  #############################################
  # EDGE CASE TESTS - Does skill handle edge cases?
  #############################################
  - id: "edge-empty"
    name: "Empty/minimal input"
    type: "edge"
    query: "TODO: Minimal query with missing context"
    expected_behavior:
      - "Asks for clarification"
      - "Does not fail"

  - id: "edge-special-chars"
    name: "Special characters in input"
    type: "edge"
    query: "Request with <brackets> & \"quotes\""
    expected_behavior:
      - "Handles special characters"
      - "No parsing errors"

  #############################################
  # NEGATIVE TESTS - Does skill NOT activate incorrectly?
  #############################################
  - id: "negative-unrelated"
    name: "Unrelated request"
    type: "negative"
    query: "TODO: Completely unrelated request"
    expected_behavior:
      - "Skill does NOT activate"
      - "No false positive"

  #############################################
  # ERROR HANDLING TESTS - Does skill handle errors gracefully?
  #############################################
  - id: "error-invalid-input"
    name: "Invalid input handling"
    type: "error"
    query: "TODO: Request with invalid data"
    expected_behavior:
      - "Detects invalid input"
      - "Provides helpful error message"
      - "Suggests how to fix"

# Validation rules
validation:
  frontmatter:
    - rule: "name_format"
      pattern: "^[a-z0-9-]+\$"
      max_length: 64
    - rule: "description_required"
      min_length: 10
      max_length: 1024
    - rule: "no_forbidden_words"
      forbidden: ["anthropic", "claude"]

  content:
    - rule: "max_lines"
      limit: 500
    - rule: "required_sections"
      sections:
        - "执行流程"
        - "进度追踪"
    - rule: "no_xml_tags"

  references:
    - rule: "max_depth"
      depth: 1

# Performance expectations
performance:
  max_trigger_time_ms: 100
  max_execution_time_ms: 30000

# Test execution configuration
execution:
  models:
    - haiku
    - sonnet
  require_all_pass: true
  retry_on_failure: 1
EOF

log_pass "Generated: $TEST_SPEC"
echo ""
echo "Next steps:"
echo "  1. Edit $TEST_SPEC to define your test scenarios"
echo "  2. Run: ./scripts/verify-scenarios.sh $OUTPUT_DIR"
echo "  3. Write SKILL.md to make tests pass"
echo "  4. Run: ./scripts/run-skill-tests.sh $OUTPUT_DIR"
echo ""
log_info "Remember: Tests first, then implementation (TDD)"
