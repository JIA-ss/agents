#!/bin/bash
# validate-self-review.sh
# 验证 self-review 任务目录的完整性

TASK_DIR=".tasks/self-review/${1}"

if [ -z "$1" ]; then
    echo "Usage: validate.sh <task-name>"
    exit 1
fi

echo "=== Structure Validation ==="
[ -f "$TASK_DIR/00-task-spec.md" ] || { echo "Missing: 00-task-spec.md"; exit 1; }
[ -f "$TASK_DIR/evidence/execution-manifest.json" ] || { echo "Missing: execution-manifest.json"; exit 1; }
[ -f "$TASK_DIR/final-report.md" ] || { echo "Missing: final-report.md"; exit 1; }

echo "=== Task Spec Validation ==="
grep -q "^## Task ID" "$TASK_DIR/00-task-spec.md" || { echo "Missing: Task ID section"; exit 1; }
grep -q "^## Success Criteria" "$TASK_DIR/00-task-spec.md" || { echo "Missing: Success Criteria"; exit 1; }

echo "=== Manifest Validation ==="
jq -e '.task_id and .commit_hash and .timestamp' "$TASK_DIR/evidence/execution-manifest.json" > /dev/null || { echo "Invalid manifest"; exit 1; }

echo "=== Final Report Validation ==="
grep -q "^## Task Summary" "$TASK_DIR/final-report.md" || { echo "Missing: Task Summary"; exit 1; }
grep -q "^## Review History" "$TASK_DIR/final-report.md" || { echo "Missing: Review History"; exit 1; }
grep -q "Final Verdict.*PASS" "$TASK_DIR/final-report.md" || { echo "Missing: PASS verdict"; exit 1; }

echo "=== All Validations Passed ==="
