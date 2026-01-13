#!/bin/bash
# Validate an improvement proposal before deployment
# Usage: ./validate-improvement.sh <skill-dir> <proposal-file>

set -e

SKILL_DIR="$1"
PROPOSAL_FILE="$2"

if [ -z "$SKILL_DIR" ] || [ -z "$PROPOSAL_FILE" ]; then
    echo "Usage: ./validate-improvement.sh <skill-dir> <proposal-file>"
    echo ""
    echo "Arguments:"
    echo "  skill-dir     Path to skill directory"
    echo "  proposal-file Path to improvement proposal"
    echo ""
    echo "Example:"
    echo "  ./validate-improvement.sh ./skills/my-skill .evolution/improvements/2026-01-13-proposal.md"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill directory not found: $SKILL_DIR"
    exit 1
fi

if [ ! -f "$PROPOSAL_FILE" ]; then
    echo "Error: Proposal file not found: $PROPOSAL_FILE"
    exit 1
fi

EVOLUTION_DIR="$SKILL_DIR/.evolution"
CONFIG_FILE="$EVOLUTION_DIR/config.yaml"
SCRIPT_DIR="$(dirname "$0")"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Improvement Validation                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Skill: $(basename "$SKILL_DIR")"
echo "Proposal: $PROPOSAL_FILE"
echo ""

VALIDATION_PASSED=true
GATES_PASSED=0
GATES_TOTAL=5

# Gate 1: Syntax Validation
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Gate 1: Syntax Validation                                       │"
echo "├─────────────────────────────────────────────────────────────────┤"

if "$SCRIPT_DIR/validate-skill.sh" "$SKILL_DIR" > /dev/null 2>&1; then
    echo "│ ✅ SKILL.md syntax is valid                                     │"
    ((GATES_PASSED++))
else
    echo "│ ❌ SKILL.md syntax validation failed                            │"
    VALIDATION_PASSED=false
fi
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Gate 2: Core Rules Protection
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Gate 2: Core Rules Protection                                   │"
echo "├─────────────────────────────────────────────────────────────────┤"

# Check if config requires preserving core rules
PRESERVE_CORE_RULES="true"
if [ -f "$CONFIG_FILE" ]; then
    PRESERVE_VALUE=$(grep "preserve_core_rules:" "$CONFIG_FILE" | awk '{print $2}' | tr -d ' ')
    if [ "$PRESERVE_VALUE" = "false" ]; then
        PRESERVE_CORE_RULES="false"
    fi
fi

if [ "$PRESERVE_CORE_RULES" = "true" ]; then
    # Check if proposal modifies Core Rules section specifically
    # Look for diff blocks that add/remove lines in Core Rules context
    CORE_RULES_MODIFIED=false

    # Check if there's a Core Rules diff section with actual changes (not template placeholders)
    if grep -A 10 "## Core Rules" "$PROPOSAL_FILE" 2>/dev/null | grep -E "^\+[^+]" | grep -v "\[New Rule\]" | grep -v "\[Description" > /dev/null 2>&1; then
        CORE_RULES_MODIFIED=true
    fi

    if [ "$CORE_RULES_MODIFIED" = true ]; then
        echo "│ ⚠️  Proposal modifies Core Rules (protected by config)          │"
        echo "│    Set preserve_core_rules: false to allow Core Rules changes   │"
        VALIDATION_PASSED=false
    else
        echo "│ ✅ Core Rules section is protected                              │"
        ((GATES_PASSED++))
    fi
else
    echo "│ ℹ️  Core Rules protection disabled                               │"
    ((GATES_PASSED++))
fi
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Gate 3: Weekly Change Limit
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Gate 3: Weekly Change Limit                                     │"
echo "├─────────────────────────────────────────────────────────────────┤"

# Get max changes with safe default
MAX_CHANGES=5
if [ -f "$CONFIG_FILE" ]; then
    MAX_VALUE=$(grep "max_auto_changes_per_week:" "$CONFIG_FILE" | awk '{print $2}' | tr -d ' ')
    if [[ "$MAX_VALUE" =~ ^[0-9]+$ ]]; then
        MAX_CHANGES="$MAX_VALUE"
    fi
fi

CHANGELOG="$EVOLUTION_DIR/changelog.md"

if [ -f "$CHANGELOG" ]; then
    # Count changes in last 7 days (iterate through all 7 days)
    RECENT_CHANGES=0
    for i in $(seq 0 6); do
        if [[ "$OSTYPE" == "darwin"* ]]; then
            CHECK_DATE=$(date -v-${i}d +%Y-%m-%d 2>/dev/null)
        else
            CHECK_DATE=$(date -d "$i days ago" +%Y-%m-%d 2>/dev/null)
        fi
        if [ -n "$CHECK_DATE" ]; then
            DAY_COUNT=$(grep -c "| $CHECK_DATE |" "$CHANGELOG" 2>/dev/null || echo "0")
            RECENT_CHANGES=$((RECENT_CHANGES + DAY_COUNT))
        fi
    done

    if [ "$RECENT_CHANGES" -ge "$MAX_CHANGES" ]; then
        echo "│ ❌ Weekly change limit reached ($RECENT_CHANGES/$MAX_CHANGES)             │"
        VALIDATION_PASSED=false
    else
        echo "│ ✅ Within weekly change limit ($RECENT_CHANGES/$MAX_CHANGES)              │"
        ((GATES_PASSED++))
    fi
else
    echo "│ ✅ No previous changes recorded                                  │"
    ((GATES_PASSED++))
fi
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Gate 4: Regression Check
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Gate 4: Regression Check                                        │"
echo "├─────────────────────────────────────────────────────────────────┤"

REQUIRE_REGRESSION=$(grep "require_regression:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}' || echo "true")

if [ "$REQUIRE_REGRESSION" = "true" ]; then
    # Check if there are recorded successes to compare against
    METRICS_LOG="$EVOLUTION_DIR/metrics/execution-log.jsonl"
    if [ -f "$METRICS_LOG" ]; then
        SUCCESS_COUNT=$(grep -c '"status":"success"' "$METRICS_LOG" 2>/dev/null || echo "0")
        if [ "$SUCCESS_COUNT" -gt 0 ]; then
            echo "│ ✅ Baseline exists ($SUCCESS_COUNT successful executions)           │"
            ((GATES_PASSED++))
        else
            echo "│ ⚠️  No successful executions to compare against               │"
            ((GATES_PASSED++))
        fi
    else
        echo "│ ℹ️  No execution history - regression check skipped             │"
        ((GATES_PASSED++))
    fi
else
    echo "│ ℹ️  Regression check disabled                                    │"
    ((GATES_PASSED++))
fi
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Gate 5: Human Approval Check
echo "┌─────────────────────────────────────────────────────────────────┐"
echo "│ Gate 5: Human Approval                                          │"
echo "├─────────────────────────────────────────────────────────────────┤"

REQUIRE_HUMAN=$(grep "require_human_approval:" "$CONFIG_FILE" 2>/dev/null | awk '{print $2}' || echo "false")

if [ "$REQUIRE_HUMAN" = "true" ]; then
    # Check if proposal is marked as approved
    if grep -q "\[x\] Human reviewed" "$PROPOSAL_FILE"; then
        echo "│ ✅ Human approval obtained                                      │"
        ((GATES_PASSED++))
    else
        echo "│ ❌ Human approval required but not obtained                     │"
        echo "│    Mark '- [x] Human reviewed' in proposal to approve           │"
        VALIDATION_PASSED=false
    fi
else
    echo "│ ℹ️  Human approval not required                                  │"
    ((GATES_PASSED++))
fi
echo "└─────────────────────────────────────────────────────────────────┘"
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Validation Summary                                ║"
echo "╠════════════════════════════════════════════════════════════════╣"
printf "║ Gates Passed: %d/%d                                             ║\n" "$GATES_PASSED" "$GATES_TOTAL"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ "$VALIDATION_PASSED" = true ]; then
    echo "✅ VALIDATION PASSED"
    echo ""
    echo "Ready to deploy:"
    echo "  ./scripts/deploy-improvement.sh $SKILL_DIR $PROPOSAL_FILE"
    exit 0
else
    echo "❌ VALIDATION FAILED"
    echo ""
    echo "Fix the issues above and re-run validation."
    exit 1
fi
