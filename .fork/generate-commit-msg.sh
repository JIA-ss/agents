#!/bin/bash

# Fork plugin: Auto-generate commit message using GitHub Copilot CLI
# Based on staged files following the project's commit convention

set -e

echo "========================================"
echo "AI Commit Message Generator (Copilot)"
echo "========================================"
echo ""

# Check copilot CLI
echo "📦 Checking GitHub Copilot CLI..."
if ! command -v copilot &> /dev/null; then
  echo "❌ Error: Copilot CLI not found."
  echo ""
  echo "Please install GitHub Copilot CLI first:"
  echo "  npm install -g @githubnext/github-copilot-cli"
  echo ""
  echo "Or use npx to run without installation:"
  echo "  npx @githubnext/github-copilot-cli"
  echo ""
  echo "Documentation: https://www.npmjs.com/package/@githubnext/github-copilot-cli"
  echo ""
  exit 1
fi

COPILOT_VERSION=$(copilot --version 2>&1 | head -1)
echo "✅ Copilot CLI found: $COPILOT_VERSION"
echo ""

# Check if there are staged changes
STAGED_FILES=$(git diff --cached --name-only)
if [ -z "$STAGED_FILES" ]; then
  echo "❌ Error: No staged files found."
  echo ""
  echo "Please stage your changes first:"
  echo "  git add <files>"
  echo "  # or"
  echo "  git add ."
  echo ""
  exit 1
fi

echo "📋 Staged files:"
echo "$STAGED_FILES" | sed 's/^/  - /'
echo ""

# Get the diff of staged changes (limit to avoid too long prompt)
STAGED_DIFF=$(git diff --cached | head -n 200)

# Count additions and deletions
STATS=$(git diff --cached --stat)

# Prepare the prompt for Copilot
PROMPT="Generate a git commit message following this exact format:

<type>: <summary>

what: <what was changed>

why: <why it was changed>

Where <type> must be one of: feat, fix, refactor, chore, perf, style, docs, test

Requirements:
- Use English only
- Be specific and concise
- Summary should be one clear line
- 'what' describes the technical changes
- 'why' explains the motivation
- Add blank lines between summary, what, and why sections

Staged files:
$STAGED_FILES

Diff stats:
$STATS

Code changes (partial):
$STAGED_DIFF

IMPORTANT: Wrap your output between these markers:
===COMMIT_START===
(your commit message here)
===COMMIT_END===

Generate ONLY the commit message in the format above, no extra explanation or markdown."

echo "🤖 Generating commit message with Copilot AI..."
echo ""

# Use copilot -p to generate the commit message
# --allow-all-tools: required for non-interactive mode
# Capture both stdout and stderr
COPILOT_OUTPUT=$(copilot -p "$PROMPT" --allow-all-tools 2>&1)
COPILOT_EXIT_CODE=$?

# Check if copilot command succeeded
if [ $COPILOT_EXIT_CODE -ne 0 ]; then
  echo "❌ Error: Copilot AI generation failed."
  echo ""
  echo "Copilot output:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$COPILOT_OUTPUT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Possible causes:"
  echo "  1. No active GitHub Copilot subscription"
  echo "     Solution: Subscribe at https://github.com/features/copilot"
  echo ""
  echo "  2. Network connectivity issues"
  echo "     Solution: Check your internet connection"
  echo ""
  echo "  3. Authentication expired"
  echo "     Solution: Run 'copilot auth' to re-authenticate"
  echo ""
  exit 1
fi

# Extract the commit message from copilot output
# Look for content between ===COMMIT_START=== and ===COMMIT_END===
# Remove leading spaces from each line, but keep blank lines
COMMIT_MSG=$(echo "$COPILOT_OUTPUT" | sed -n '/===COMMIT_START===/,/===COMMIT_END===/p' | sed '1d;$d' | sed 's/^[[:space:]]*//')

# If markers not found, try fallback: remove common Copilot CLI prefixes
if [ -z "$COMMIT_MSG" ]; then
  echo "⚠️  Markers not found, using fallback extraction..."
  COMMIT_MSG=$(echo "$COPILOT_OUTPUT" | grep -v "^●" | grep -v "^✓" | grep -v "^✗" | grep -v "^\$" | grep -v "^>" | grep -v "exited with" | sed 's/^[[:space:]]*//')
fi

# Clean up: remove leading/trailing blank lines
COMMIT_MSG=$(echo "$COMMIT_MSG" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' | sed -e '/./,$!d')

# Validate the message is not empty
if [ -z "$COMMIT_MSG" ]; then
  echo "❌ Error: Copilot returned an empty commit message."
  echo ""
  echo "Raw output:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "$COPILOT_OUTPUT"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Please try again or check your Copilot setup."
  exit 1
fi

# Validate format (should contain at least 'what:' and 'why:')
if ! echo "$COMMIT_MSG" | grep -q "what:"; then
  echo "⚠️  Warning: Generated message doesn't contain 'what:' field"
fi

if ! echo "$COMMIT_MSG" | grep -q "why:"; then
  echo "⚠️  Warning: Generated message doesn't contain 'why:' field"
fi

echo "✨ Generated Commit Message:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Commit directly with the generated message
echo "📝 Creating commit..."
echo ""

if git commit -m "$COMMIT_MSG"; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Commit created successfully!"
  echo ""
  echo "📋 Commit details:"
  git log -1 --pretty=format:"  Commit: %h%n  Author: %an <%ae>%n  Date:   %ad%n" --date=format:"%Y-%m-%d %H:%M:%S"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ Commit failed!"
  echo ""
  echo "💡 The commit message has been copied to clipboard."
  echo "   You can manually commit in Fork if needed."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
fi
