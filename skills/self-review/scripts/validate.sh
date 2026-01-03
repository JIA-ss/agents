#!/bin/bash
# validate-self-review.sh
# 验证 self-review 任务目录的完整性
#
# 使用方式:
#   ./validate.sh <task-name> [--strict]
#
# 选项:
#   --strict  严格模式，要求所有审查轮次完整

TASK_DIR=".tasks/self-review/${1}"
STRICT_MODE=false

if [ -z "$1" ]; then
    echo "Usage: validate.sh <task-name> [--strict]"
    echo ""
    echo "Options:"
    echo "  --strict  Require all review rounds to be complete"
    exit 1
fi

if [ "$2" = "--strict" ]; then
    STRICT_MODE=true
fi

ERRORS=0

echo "=== Structure Validation ==="
[ -f "$TASK_DIR/00-task-spec.md" ] || { echo "❌ Missing: 00-task-spec.md"; ((ERRORS++)); }
[ -f "$TASK_DIR/evidence/execution-manifest.json" ] || { echo "❌ Missing: execution-manifest.json"; ((ERRORS++)); }
[ -f "$TASK_DIR/evidence/test-results.txt" ] || { echo "❌ Missing: test-results.txt"; ((ERRORS++)); }
[ -f "$TASK_DIR/evidence/lint-results.txt" ] || { echo "❌ Missing: lint-results.txt"; ((ERRORS++)); }
[ -f "$TASK_DIR/evidence/requirement-mapping.md" ] || { echo "⚠️  Missing: requirement-mapping.md (optional)"; }
[ -f "$TASK_DIR/final-report.md" ] || { echo "❌ Missing: final-report.md"; ((ERRORS++)); }

echo "=== Task Spec Validation ==="
grep -q "^## Task ID" "$TASK_DIR/00-task-spec.md" || { echo "❌ Missing: Task ID section"; ((ERRORS++)); }
grep -q "^## Success Criteria" "$TASK_DIR/00-task-spec.md" || { echo "❌ Missing: Success Criteria"; ((ERRORS++)); }

echo "=== Manifest Validation ==="
if [ -f "$TASK_DIR/evidence/execution-manifest.json" ]; then
    jq -e '.task_id and .commit_hash and .timestamp' "$TASK_DIR/evidence/execution-manifest.json" > /dev/null 2>&1 || { echo "❌ Invalid manifest: missing required fields"; ((ERRORS++)); }
fi

echo "=== Reviews Directory Validation ==="
REVIEW_DIRS=$(find "$TASK_DIR/reviews" -type d -name "round-*" 2>/dev/null | sort)
# Fix: Use wc -l with proper empty string handling
if [ -z "$REVIEW_DIRS" ]; then
    REVIEW_COUNT=0
else
    REVIEW_COUNT=$(echo "$REVIEW_DIRS" | wc -l | tr -d ' ')
fi

if [ "$REVIEW_COUNT" -eq 0 ]; then
    echo "⚠️  No review rounds found in reviews/"
else
    echo "Found $REVIEW_COUNT review round(s)"

    for ROUND_DIR in $REVIEW_DIRS; do
        ROUND_NAME=$(basename "$ROUND_DIR")
        echo "  Checking $ROUND_NAME..."

        # 验证审查轮次必需文件
        [ -f "$ROUND_DIR/review-prompt.md" ] || { echo "    ❌ Missing: $ROUND_NAME/review-prompt.md"; if $STRICT_MODE; then ((ERRORS++)); fi; }
        [ -f "$ROUND_DIR/review-response.md" ] || { echo "    ❌ Missing: $ROUND_NAME/review-response.md"; if $STRICT_MODE; then ((ERRORS++)); fi; }
        [ -f "$ROUND_DIR/review-analysis.md" ] || { echo "    ⚠️  Missing: $ROUND_NAME/review-analysis.md"; }

        # 验证 review-response 包含必需的输出格式
        if [ -f "$ROUND_DIR/review-response.md" ]; then
            grep -q "VERDICT:" "$ROUND_DIR/review-response.md" || { echo "    ⚠️  Missing VERDICT in $ROUND_NAME/review-response.md"; }
        fi
    done
fi

echo "=== Final Report Validation ==="
if [ -f "$TASK_DIR/final-report.md" ]; then
    grep -q "^## Task Summary" "$TASK_DIR/final-report.md" || { echo "❌ Missing: Task Summary"; ((ERRORS++)); }
    grep -q "^## Review History" "$TASK_DIR/final-report.md" || { echo "❌ Missing: Review History"; ((ERRORS++)); }
    grep -q "Final Verdict.*PASS" "$TASK_DIR/final-report.md" || { echo "❌ Missing: PASS verdict"; ((ERRORS++)); }
fi

echo ""
echo "=== Validation Summary ==="
if [ $ERRORS -eq 0 ]; then
    echo "✅ All validations passed"
    exit 0
else
    echo "❌ Found $ERRORS error(s)"
    exit 1
fi
