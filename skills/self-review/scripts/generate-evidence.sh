#!/bin/bash
# generate-evidence.sh
# 生成 self-review 任务的证据包

TASK_NAME="$1"
TASK_DIR=".tasks/self-review/${TASK_NAME}/evidence"

if [ -z "$TASK_NAME" ]; then
    echo "Usage: generate-evidence.sh <task-name>"
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

echo "Evidence package generated at: $TASK_DIR"
