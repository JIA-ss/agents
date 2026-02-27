#!/usr/bin/env bash
# deploy-agents.sh — 将 agents/ 目录下的所有 agent 部署到 ~/.claude/agents/
# 用法: ./bin/deploy-agents.sh

set -e

AGENTS_DIR="$(cd "$(dirname "$0")/../agents" && pwd)"
TARGET_DIR="$HOME/.claude/agents"

mkdir -p "$TARGET_DIR"

echo "📦 部署 agents 到 $TARGET_DIR ..."
echo ""

count=0
for agent_file in "$AGENTS_DIR"/*.md; do
  agent_name="$(basename "$agent_file")"
  cp "$agent_file" "$TARGET_DIR/$agent_name"
  echo "  ✅ $agent_name"
  count=$((count + 1))
done

echo ""
echo "✨ 已部署 $count 个 agent"
echo ""
echo "当前已部署的 agents:"
ls "$TARGET_DIR"/*.md 2>/dev/null | xargs -I{} basename {}
