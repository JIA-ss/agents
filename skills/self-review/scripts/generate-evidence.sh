#!/bin/bash
# generate-evidence.sh
# 生成 self-review 任务的证据包
#
# 使用方式:
#   ./generate-evidence.sh <task-name> [test-command] [lint-command]
#
# 示例:
#   ./generate-evidence.sh fix-bug-20260103 "npm test" "npm run lint"
#   ./generate-evidence.sh my-task "pytest" "ruff check ."

TASK_NAME="$1"
TEST_CMD="${2:-echo 'No test command specified'}"
LINT_CMD="${3:-echo 'No lint command specified'}"
TASK_DIR=".tasks/self-review/${TASK_NAME}"
EVIDENCE_DIR="$TASK_DIR/evidence"

if [ -z "$TASK_NAME" ]; then
    echo "Usage: generate-evidence.sh <task-name> [test-command] [lint-command]"
    echo ""
    echo "Examples:"
    echo "  ./generate-evidence.sh fix-bug-20260103 'npm test' 'npm run lint'"
    echo "  ./generate-evidence.sh my-task 'pytest' 'ruff check .'"
    exit 1
fi

mkdir -p "$EVIDENCE_DIR"
echo "=== Generating Evidence Package ==="

# 0. Get git info
COMMIT_HASH=$(git rev-parse HEAD)
BASE_COMMIT=$(git merge-base HEAD main 2>/dev/null || echo 'N/A')

# 1. Execution Manifest
cat > "$EVIDENCE_DIR/execution-manifest.json" << MANIFEST
{
  "task_id": "${TASK_NAME}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "commit_hash": "${COMMIT_HASH}",
  "base_commit": "${BASE_COMMIT}",
  "commands_executed": [
    "${TEST_CMD}",
    "${LINT_CMD}"
  ],
  "tool_versions": {
    "node": "$(node --version 2>/dev/null || echo 'N/A')",
    "python": "$(python3 --version 2>/dev/null || echo 'N/A')"
  }
}
MANIFEST
echo "✓ execution-manifest.json"

# 2. Test Results
echo "=== Running Tests ==="
eval "$TEST_CMD" 2>&1 | tee "$EVIDENCE_DIR/test-results.txt"
TEST_EXIT=$?
echo "EXIT_CODE: $TEST_EXIT" >> "$EVIDENCE_DIR/test-results.txt"
echo "✓ test-results.txt"

# 3. Lint Results
echo "=== Running Lint ==="
eval "$LINT_CMD" 2>&1 | tee "$EVIDENCE_DIR/lint-results.txt"
LINT_EXIT=$?
echo "EXIT_CODE: $LINT_EXIT" >> "$EVIDENCE_DIR/lint-results.txt"
echo "✓ lint-results.txt"

# 4. Requirement Mapping (from task-spec if exists)
echo "=== Generating Requirement Mapping ==="
TASK_SPEC="$TASK_DIR/00-task-spec.md"
cat > "$EVIDENCE_DIR/requirement-mapping.md" << MAPPING
# Requirement Mapping

## Task Reference
- Task ID: ${TASK_NAME}
- Task Spec: [00-task-spec.md](../00-task-spec.md)

## Changed Files
\`\`\`
$(git diff --name-only ${BASE_COMMIT}..${COMMIT_HASH} 2>/dev/null || echo "Unable to determine changed files")
\`\`\`

## Requirement to Code Mapping

| Requirement | File(s) | Status |
|-------------|---------|--------|
| (Fill in from task-spec) | (Changed files) | (Pending verification) |

## Notes
- This is an auto-generated template
- Executor should fill in the mapping details
- Reviewer will verify the mapping accuracy
MAPPING
echo "✓ requirement-mapping.md"

echo ""
echo "=== Evidence Package Summary ==="
echo "Location: $EVIDENCE_DIR"
echo "Files generated:"
ls -la "$EVIDENCE_DIR"
echo ""
echo "Test exit code: $TEST_EXIT"
echo "Lint exit code: $LINT_EXIT"
echo ""
echo "Note: Reviewer will independently verify git state using commit_hash"
