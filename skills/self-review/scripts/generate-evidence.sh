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
TASK_DIR=".tasks/self-review/${TASK_NAME}/evidence"

if [ -z "$TASK_NAME" ]; then
    echo "Usage: generate-evidence.sh <task-name> [test-command] [lint-command]"
    echo ""
    echo "Examples:"
    echo "  ./generate-evidence.sh fix-bug-20260103 'npm test' 'npm run lint'"
    echo "  ./generate-evidence.sh my-task 'pytest' 'ruff check .'"
    exit 1
fi

mkdir -p "$TASK_DIR"
echo "=== Generating Evidence Package ==="

# 1. Execution Manifest
cat > "$TASK_DIR/execution-manifest.json" << MANIFEST
{
  "task_id": "${TASK_NAME}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "commit_hash": "$(git rev-parse HEAD)",
  "base_commit": "$(git merge-base HEAD main 2>/dev/null || echo 'N/A')",
  "commands_executed": [],
  "tool_versions": {
    "node": "$(node --version 2>/dev/null || echo 'N/A')",
    "python": "$(python3 --version 2>/dev/null || echo 'N/A')"
  }
}
MANIFEST
echo "✓ execution-manifest.json"

# 2. Test Results
echo "=== Running Tests ==="
eval "$TEST_CMD" 2>&1 | tee "$TASK_DIR/test-results.txt"
echo "EXIT_CODE: $?" >> "$TASK_DIR/test-results.txt"
echo "✓ test-results.txt"

# 3. Lint Results
echo "=== Running Lint ==="
eval "$LINT_CMD" 2>&1 | tee "$TASK_DIR/lint-results.txt"
echo "EXIT_CODE: $?" >> "$TASK_DIR/lint-results.txt"
echo "✓ lint-results.txt"

echo ""
echo "Evidence package generated at: $TASK_DIR"
echo "Note: Reviewer will independently verify git state using commit_hash"
