#!/bin/bash
# Initialize a new skill directory with standard structure
# Usage: ./init-skill.sh <skill-name> [output-dir] [--with-evolution]

set -e

SKILL_NAME=""
OUTPUT_DIR="."
WITH_EVOLUTION=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --with-evolution)
            WITH_EVOLUTION=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            if [ -z "$SKILL_NAME" ]; then
                SKILL_NAME="$1"
            else
                OUTPUT_DIR="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$SKILL_NAME" ]; then
    echo "Usage: ./init-skill.sh <skill-name> [output-dir] [--with-evolution]"
    echo ""
    echo "Arguments:"
    echo "  skill-name       Name of the skill (lowercase, hyphens only)"
    echo "  output-dir       Directory to create skill in (default: current dir)"
    echo "  --with-evolution Enable self-iteration capability"
    echo ""
    echo "Example:"
    echo "  ./init-skill.sh pdf-processor"
    echo "  ./init-skill.sh code-analyzer ./skills"
    echo "  ./init-skill.sh my-skill --with-evolution"
    exit 1
fi

# Validate skill name
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo "Error: Skill name must only contain lowercase letters, numbers, and hyphens"
    exit 1
fi

if [[ ${#SKILL_NAME} -gt 64 ]]; then
    echo "Error: Skill name must be 64 characters or less"
    exit 1
fi

if [[ "$SKILL_NAME" == *"anthropic"* ]] || [[ "$SKILL_NAME" == *"claude"* ]]; then
    echo "Error: Skill name cannot contain 'anthropic' or 'claude'"
    exit 1
fi

SKILL_DIR="$OUTPUT_DIR/$SKILL_NAME"

if [ -d "$SKILL_DIR" ]; then
    echo "Error: Directory $SKILL_DIR already exists"
    exit 1
fi

echo "Creating skill: $SKILL_NAME"
echo "Location: $SKILL_DIR"
if [ "$WITH_EVOLUTION" = true ]; then
    echo "Self-iteration: ENABLED"
fi
echo ""

# Create directory structure (TDD: tests/ is required)
mkdir -p "$SKILL_DIR"/{references,scripts,assets,tests}

# Create evolution directory if requested
if [ "$WITH_EVOLUTION" = true ]; then
    mkdir -p "$SKILL_DIR/.evolution"/{failures,patterns,improvements,metrics}

    # Create evolution config
    cat > "$SKILL_DIR/.evolution/config.yaml" << 'EVOLUTION_CONFIG'
# Skill Self-Iteration Configuration

evolution:
  enabled: true

  # Automatic improvement triggers
  triggers:
    consecutive_failures: 3        # Trigger after N consecutive failures
    same_error_pattern: 5          # Trigger when same error occurs N times
    performance_regression: 0.1    # Trigger on 10% performance drop

  # Validation requirements
  validation:
    require_tests: true            # Must pass existing tests
    require_regression: true       # Must not introduce regressions
    require_human_approval: false  # Auto-deploy if validation passes

  # Safety limits
  limits:
    max_auto_changes_per_week: 5   # Prevent runaway evolution
    rollback_on_failure: true      # Auto-rollback failed improvements
    preserve_core_rules: true      # Never auto-modify Core Rules section

  # Notification settings
  notifications:
    on_trigger: true               # Notify when trigger threshold reached
    on_proposal: true              # Notify when proposal generated
    on_deployment: true            # Notify when improvement deployed
EVOLUTION_CONFIG

    # Create changelog
    cat > "$SKILL_DIR/.evolution/changelog.md" << CHANGELOG
# Evolution Changelog

## History

| Date | Type | Description |
|------|------|-------------|
| $(date +%Y-%m-%d) | init | Skill created with self-iteration enabled |
CHANGELOG
fi

# Create SKILL.md template
if [ "$WITH_EVOLUTION" = true ]; then
    cat > "$SKILL_DIR/SKILL.md" << 'TEMPLATE'
---
name: SKILL_NAME_PLACEHOLDER
description: [What it does]. Use when [specific triggers]. Also responds to "[中文关键词]".
---

# SKILL_NAME_PLACEHOLDER Guide

## Overview

[1-2 sentences explaining what this skill does and its core value]

## Workflow

### Step 1: [First Phase]

[Description]

### Step 2: [Second Phase]

[Description]

---

## Core Rules

1. **[Rule 1]** - [Description]
2. **[Rule 2]** - [Description]

---

## Output Requirements

[Expected output format]

---

## Best Practices

1. [Practice 1]
2. [Practice 2]

---

## Self-Iteration

This skill supports automatic improvement based on execution feedback.

### Recording Outcomes
After using this skill, record the outcome:
```bash
./scripts/record-outcome.sh . <success|failure> "[details]"
```

### Analyzing Failures
Review accumulated failures and patterns:
```bash
./scripts/analyze-trends.sh .
```

### Proposing Improvements
Generate improvement proposal based on patterns:
```bash
./scripts/propose-improvement.sh . [pattern-id]
```

### Configuration
See `.evolution/config.yaml` for trigger thresholds and validation settings.

---

## Additional Resources

| Resource | Path | When to Use |
|----------|------|-------------|
| Reference | [references/](references/) | Domain documentation |
| Scripts | [scripts/](scripts/) | Utility scripts |
| Evolution Config | [.evolution/config.yaml](.evolution/config.yaml) | Adjust self-iteration settings |
TEMPLATE
else
    cat > "$SKILL_DIR/SKILL.md" << 'TEMPLATE'
---
name: SKILL_NAME_PLACEHOLDER
description: [What it does]. Use when [specific triggers]. Also responds to "[中文关键词]".
---

# SKILL_NAME_PLACEHOLDER Guide

## Overview

[1-2 sentences explaining what this skill does and its core value]

## Workflow

### Step 1: [First Phase]

[Description]

### Step 2: [Second Phase]

[Description]

---

## Core Rules

1. **[Rule 1]** - [Description]
2. **[Rule 2]** - [Description]

---

## Output Requirements

[Expected output format]

---

## Best Practices

1. [Practice 1]
2. [Practice 2]

---

## Additional Resources

| Resource | Path | Content |
|----------|------|---------|
| Reference | [references/](references/) | Domain documentation |
| Scripts | [scripts/](scripts/) | Utility scripts |
TEMPLATE
fi

# Replace placeholder with actual skill name (cross-platform compatible)
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/SKILL.md"
else
    sed -i "s/SKILL_NAME_PLACEHOLDER/$SKILL_NAME/g" "$SKILL_DIR/SKILL.md"
fi

# Create .gitkeep files for empty directories
touch "$SKILL_DIR/references/.gitkeep"
touch "$SKILL_DIR/scripts/.gitkeep"
touch "$SKILL_DIR/assets/.gitkeep"

# Create TDD test-spec.yaml template
cat > "$SKILL_DIR/tests/test-spec.yaml" << EOF
# Test Specification for $SKILL_NAME
# TDD: Define tests BEFORE writing SKILL.md

skill:
  name: "$SKILL_NAME"
  description: "TODO: Add description"

scenarios:
  # Trigger tests - verify skill activates correctly
  - id: "trigger-basic"
    name: "Basic trigger"
    type: "trigger"
    query: "TODO: User query that should trigger this skill"
    expected_behavior:
      - "Skill activates"
      - "TODO: Add expected behavior"

  # Execution tests - verify core functionality
  - id: "exec-standard"
    name: "Standard execution"
    type: "execution"
    query: "TODO: Typical user request"
    expected_behavior:
      - "TODO: Expected behavior"

  # Edge case tests
  - id: "edge-minimal"
    name: "Minimal input"
    type: "edge"
    query: "TODO: Incomplete request"
    expected_behavior:
      - "Handles gracefully"

  # Negative tests - verify no false activation
  - id: "negative-unrelated"
    name: "Unrelated request"
    type: "negative"
    query: "TODO: Unrelated task"
    expected_behavior:
      - "Skill does NOT activate"

validation:
  frontmatter:
    - rule: "name_format"
      pattern: "^[a-z0-9-]+\$"
    - rule: "description_required"
      max_length: 1024
  content:
    - rule: "max_lines"
      limit: 500
EOF

echo "Created skill directory structure:"
echo ""
find "$SKILL_DIR" -type f | sort | sed 's/^/  /'
echo ""
echo "Next steps (TDD workflow):"
echo "  1. Edit $SKILL_DIR/tests/test-spec.yaml (define tests FIRST)"
echo "  2. Run: ./scripts/verify-scenarios.sh $SKILL_DIR"
echo "  3. Edit $SKILL_DIR/SKILL.md (make tests pass)"
echo "  4. Add references to references/"
echo "  5. Add scripts to scripts/"
echo "  6. Run: ./scripts/validate-skill.sh $SKILL_DIR"
echo "  7. Run: ./scripts/run-skill-tests.sh $SKILL_DIR"
if [ "$WITH_EVOLUTION" = true ]; then
    echo "  8. Use record-outcome.sh after executions to enable self-iteration"
fi
