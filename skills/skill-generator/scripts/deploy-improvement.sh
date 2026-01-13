#!/bin/bash
# Deploy a validated improvement proposal
# Usage: ./deploy-improvement.sh <skill-dir> <proposal-file>

set -e

SKILL_DIR="$1"
PROPOSAL_FILE="$2"

if [ -z "$SKILL_DIR" ] || [ -z "$PROPOSAL_FILE" ]; then
    echo "Usage: ./deploy-improvement.sh <skill-dir> <proposal-file>"
    echo ""
    echo "Arguments:"
    echo "  skill-dir     Path to skill directory"
    echo "  proposal-file Path to improvement proposal"
    echo ""
    echo "Example:"
    echo "  ./deploy-improvement.sh ./skills/my-skill .evolution/improvements/2026-01-13-proposal.md"
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
CHANGELOG="$EVOLUTION_DIR/changelog.md"
SCRIPT_DIR="$(dirname "$0")"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Deploying Improvement                             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Run validation first
echo "Running validation..."
if ! "$SCRIPT_DIR/validate-improvement.sh" "$SKILL_DIR" "$PROPOSAL_FILE"; then
    echo ""
    echo "❌ Deployment aborted: validation failed"
    exit 1
fi

echo ""
echo "Validation passed. Proceeding with deployment..."
echo ""

# Create backup before changes
BACKUP_DIR="$EVOLUTION_DIR/backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$SKILL_DIR/SKILL.md" "$BACKUP_DIR/SKILL.md.bak"
echo "Created backup: $BACKUP_DIR/SKILL.md.bak"

# Extract proposal metadata (handles both "- **Pattern**:" and "**Pattern**:" formats)
PATTERN=$(grep -E "^\s*-?\s*\*\*Pattern\*\*:" "$PROPOSAL_FILE" | sed 's/.*\*\*Pattern\*\*:[[:space:]]*//' || echo "unknown")
if [ -z "$PATTERN" ]; then
    PATTERN="unknown"
fi
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DATE_PART=$(date +%Y-%m-%d)

# Mark proposal as deployed
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's/\*\*Status\*\*: pending/**Status**: deployed/' "$PROPOSAL_FILE"
    sed -i '' "s/- \[ \] Deployed/- [x] Deployed ($DATE_PART)/" "$PROPOSAL_FILE"
else
    sed -i 's/\*\*Status\*\*: pending/**Status**: deployed/' "$PROPOSAL_FILE"
    sed -i "s/- \[ \] Deployed/- [x] Deployed ($DATE_PART)/" "$PROPOSAL_FILE"
fi

# Update changelog
echo "| $DATE_PART | improvement | Applied proposal addressing $PATTERN |" >> "$CHANGELOG"

# Reset failure counters for addressed pattern
FAILURES_DIR="$EVOLUTION_DIR/failures"
PATTERNS_DIR="$EVOLUTION_DIR/patterns"

# Archive addressed failures
ARCHIVE_DIR="$EVOLUTION_DIR/archive/$(date +%Y%m%d)"
mkdir -p "$ARCHIVE_DIR"

if [ -d "$FAILURES_DIR" ]; then
    # Move related failure files to archive
    find "$FAILURES_DIR" -name "*-${PATTERN}.md" -type f -exec mv {} "$ARCHIVE_DIR/" \; 2>/dev/null || true
    echo "Archived failure records for pattern: $PATTERN"
fi

# Archive pattern file
if [ -f "$PATTERNS_DIR/pattern-${PATTERN}.md" ]; then
    mv "$PATTERNS_DIR/pattern-${PATTERN}.md" "$ARCHIVE_DIR/" 2>/dev/null || true
    echo "Archived pattern file: pattern-${PATTERN}.md"
fi

# Record deployment in metrics
METRICS_LOG="$EVOLUTION_DIR/metrics/execution-log.jsonl"
echo "{\"timestamp\":\"$TIMESTAMP\",\"status\":\"deployment\",\"error_type\":\"none\",\"details\":\"Deployed improvement for $PATTERN\"}" >> "$METRICS_LOG"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              Deployment Complete                               ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║ ✅ Proposal marked as deployed                                  ║"
echo "║ ✅ Changelog updated                                            ║"
echo "║ ✅ Failure records archived                                     ║"
echo "║ ✅ Backup created                                               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "NOTE: The actual SKILL.md changes must be applied manually."
echo "      Review the proposal and apply the changes from 'Proposed Changes' section."
echo ""
echo "To rollback if issues arise:"
echo "  cp $BACKUP_DIR/SKILL.md.bak $SKILL_DIR/SKILL.md"
