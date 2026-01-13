#!/bin/bash
# Validates spec.md completeness and quality
# Usage: ./validate-spec.sh <spec-file> [mode]

set -e

SPEC_FILE="${1:?Usage: validate-spec.sh <spec-file> [mode]}"
MODE="${2:-standard}"

if [ ! -f "$SPEC_FILE" ]; then
    echo "Error: File not found: $SPEC_FILE"
    exit 1
fi

echo "Validating: $SPEC_FILE (mode: $MODE)"
echo "================================================"

ERRORS=0
WARNINGS=0

# Check for forbidden ambiguous terms (matches SKILL.md and phase-details.md)
# English terms
FORBIDDEN_EN="fast|quick|simple|easy|user-friendly|intuitive|robust|scalable"
# Chinese terms
FORBIDDEN_CN="快速|简单|容易|友好|直观|健壮|可扩展"
FORBIDDEN_TERMS="$FORBIDDEN_EN|$FORBIDDEN_CN"

if grep -iE "$FORBIDDEN_TERMS" "$SPEC_FILE" > /dev/null 2>&1; then
    # Exclude lines that have numbers (likely quantified)
    AMBIGUOUS_LINES=$(grep -inE "$FORBIDDEN_TERMS" "$SPEC_FILE" | grep -v "[0-9]" || true)
    if [ -n "$AMBIGUOUS_LINES" ]; then
        echo "[ERROR] Ambiguous terms found (without quantification):"
        echo "$AMBIGUOUS_LINES" | head -5
        ((ERRORS++))
    fi
fi

# Check for placeholder text
if grep -E "\{[^}]+\}|TODO|TBD|FIXME" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[ERROR] Placeholder text found:"
    grep -nE "\{[^}]+\}|TODO|TBD|FIXME" "$SPEC_FILE" | head -5
    ((ERRORS++))
fi

# Check User Story format (supports multi-line blocks)
# Must have all three parts: As a / I want to / So that
US_VALID=false

# Method 1: Multi-line pattern with grep -Pzo
if grep -Pzo "As a [^\n]+,?\s*\nI want to [^\n]+,?\s*\nSo that" "$SPEC_FILE" > /dev/null 2>&1; then
    US_VALID=true
fi

# Method 2: Single-line format
if [ "$US_VALID" = false ]; then
    if grep -E "As a .+, I want to .+, So that" "$SPEC_FILE" > /dev/null 2>&1; then
        US_VALID=true
    fi
fi

# Method 3: Check code block format (all three lines present)
if [ "$US_VALID" = false ]; then
    # Extract lines after "As a" and check for both "I want to" and "So that"
    US_BLOCK=$(grep -A3 "As a " "$SPEC_FILE" 2>/dev/null || true)
    if echo "$US_BLOCK" | grep -q "I want to" && echo "$US_BLOCK" | grep -q "So that"; then
        US_VALID=true
    fi
fi

if [ "$US_VALID" = false ]; then
    echo "[ERROR] No valid User Story format found"
    echo "  Expected: As a {role}, I want to {action}, So that I can {benefit}."
    echo "  All three parts (As a / I want to / So that) are required."
    ((ERRORS++))
fi

# Check Acceptance Criteria count per story (3-7 recommended)
US_COUNT=0
AC_COUNT=0

# Count user stories
if grep -c "### US-[0-9]" "$SPEC_FILE" > /dev/null 2>&1; then
    US_COUNT=$(grep -c "### US-[0-9]" "$SPEC_FILE")
fi
if [ "$US_COUNT" -eq 0 ]; then
    US_COUNT=1  # Assume at least one story if file exists
fi

# Count acceptance criteria
if grep -c "\- \[ \] AC-" "$SPEC_FILE" > /dev/null 2>&1; then
    AC_COUNT=$(grep -c "\- \[ \] AC-" "$SPEC_FILE")
fi
if [ "$AC_COUNT" -eq 0 ]; then
    # Try alternate format
    if grep -c "AC-[0-9]" "$SPEC_FILE" > /dev/null 2>&1; then
        AC_COUNT=$(grep -c "AC-[0-9]" "$SPEC_FILE")
    fi
fi

if [ "$US_COUNT" -gt 0 ] && [ "$AC_COUNT" -gt 0 ]; then
    AVG_AC=$((AC_COUNT / US_COUNT))
    if [ "$AVG_AC" -lt 3 ]; then
        echo "[WARNING] Average AC per story ($AVG_AC) is below recommended (3-7)"
        ((WARNINGS++))
    elif [ "$AVG_AC" -gt 7 ]; then
        echo "[WARNING] Average AC per story ($AVG_AC) exceeds recommended (3-7)"
        ((WARNINGS++))
    else
        echo "[INFO] AC per story: $AVG_AC (within 3-7 range)"
    fi
elif [ "$AC_COUNT" -eq 0 ]; then
    echo "[WARNING] No acceptance criteria found"
    ((WARNINGS++))
fi

# Mode-specific checks
case "$MODE" in
    mini)
        # Only check sections 1, 3, 7, 9
        for section in "## 1. Overview" "## 3. User Stories" "## 7. Out of Scope" "## 9. Acceptance Checklist"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                echo "[ERROR] Missing required section: $section"
                ((ERRORS++))
            fi
        done
        ;;
    standard)
        # Check sections 1-7, 9
        for section in "## 1. Overview" "## 2. Problem Statement" "## 3. User Stories" "## 4. Functional Requirements" "## 5. Non-Functional Requirements" "## 6. Constraints" "## 7. Out of Scope" "## 9. Acceptance Checklist"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                echo "[ERROR] Missing required section: $section"
                ((ERRORS++))
            fi
        done
        # Check NFRs have numbers (quantified)
        NFR_SECTION=$(sed -n '/## 5. Non-Functional/,/## 6\./p' "$SPEC_FILE" 2>/dev/null || true)
        if [ -n "$NFR_SECTION" ]; then
            NFR_WITHOUT_NUMBERS=$(echo "$NFR_SECTION" | grep -E "Performance|Reliability|Scalability|Security" | grep -v "[0-9%]" || true)
            if [ -n "$NFR_WITHOUT_NUMBERS" ]; then
                echo "[WARNING] Some NFRs may not be quantified:"
                echo "$NFR_WITHOUT_NUMBERS" | head -3
                ((WARNINGS++))
            fi
        fi
        ;;
    full)
        # Check all sections including appendix
        for section in "## 1. Overview" "## 2. Problem Statement" "## 3. User Stories" "## 4. Functional Requirements" "## 5. Non-Functional Requirements" "## 6. Constraints" "## 7. Out of Scope" "## 8. Open Questions" "## 9. Acceptance Checklist" "### A. Glossary" "### B. References" "### C. Change History"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                echo "[ERROR] Missing required section: $section"
                ((ERRORS++))
            fi
        done
        ;;
esac

# Check status
if grep -E "Status.*approved" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[INFO] Spec status: approved"
elif grep -E "Status.*draft" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[INFO] Spec status: draft (not yet approved)"
fi

echo "================================================"
echo "Validation complete: $ERRORS errors, $WARNINGS warnings"

if [ "$ERRORS" -gt 0 ]; then
    echo "Result: FAILED"
    exit 1
else
    echo "Result: PASSED"
    exit 0
fi
