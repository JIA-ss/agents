#!/bin/bash
# Validate a skill against Agent Skills specification
# Usage: ./validate-skill.sh <skill-dir>

set -e

SKILL_DIR="$1"
ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

error() {
    echo -e "${RED}ERROR${NC}: $1"
    ((ERRORS++))
}

warning() {
    echo -e "${YELLOW}WARNING${NC}: $1"
    ((WARNINGS++))
}

success() {
    echo -e "${GREEN}OK${NC}: $1"
}

if [ -z "$SKILL_DIR" ]; then
    echo "Usage: ./validate-skill.sh <skill-dir>"
    echo ""
    echo "Validates a skill directory against Agent Skills specification."
    echo ""
    echo "Example:"
    echo "  ./validate-skill.sh ./skills/pdf-processor"
    exit 1
fi

if [ ! -d "$SKILL_DIR" ]; then
    error "Directory not found: $SKILL_DIR"
    exit 1
fi

SKILL_MD="$SKILL_DIR/SKILL.md"

if [ ! -f "$SKILL_MD" ]; then
    error "SKILL.md not found in $SKILL_DIR"
    exit 1
fi

echo "Validating skill: $SKILL_DIR"
echo "================================"
echo ""

# Extract frontmatter
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SKILL_MD" | sed '1d;$d')

if [ -z "$FRONTMATTER" ]; then
    error "No YAML frontmatter found"
else
    success "YAML frontmatter present"
fi

# Check name field
NAME=$(echo "$FRONTMATTER" | grep -E "^name:" | sed 's/name:[[:space:]]*//' | tr -d '"'"'" || true)

if [ -z "$NAME" ]; then
    error "Missing 'name' field in frontmatter"
else
    # Validate name format
    if [[ ! "$NAME" =~ ^[a-z0-9-]+$ ]]; then
        error "Name '$NAME' contains invalid characters (only a-z, 0-9, - allowed)"
    elif [[ ${#NAME} -gt 64 ]]; then
        error "Name '$NAME' exceeds 64 characters"
    elif [[ "$NAME" == *"anthropic"* ]] || [[ "$NAME" == *"claude"* ]]; then
        error "Name '$NAME' contains reserved word (anthropic/claude)"
    else
        success "Name '$NAME' is valid"
    fi
fi

# Check description field
DESCRIPTION=$(echo "$FRONTMATTER" | grep -E "^description:" | sed 's/description:[[:space:]]*//' || true)

if [ -z "$DESCRIPTION" ]; then
    error "Missing 'description' field in frontmatter"
else
    DESC_LEN=${#DESCRIPTION}

    if [[ $DESC_LEN -gt 1024 ]]; then
        error "Description exceeds 1024 characters ($DESC_LEN chars)"
    else
        success "Description length OK ($DESC_LEN chars)"
    fi

    # Check for "when to use"
    if [[ "$DESCRIPTION" == *"Use when"* ]] || [[ "$DESCRIPTION" == *"when"* ]]; then
        success "Description includes trigger context"
    else
        warning "Description may be missing 'when to use' guidance"
    fi

    # Check for first person
    if [[ "$DESCRIPTION" =~ (^|[[:space:]])(I|me|my|I\'m|I\'ve)([[:space:]]|$) ]]; then
        error "Description contains first-person pronouns"
    fi

    # Check for XML tags (including tags with attributes)
    if [[ "$DESCRIPTION" =~ \<[a-zA-Z][a-zA-Z0-9]*([[:space:]][^>]*)?\> ]] || [[ "$DESCRIPTION" =~ \</[a-zA-Z][a-zA-Z0-9]*\> ]]; then
        error "Description contains XML tags (forbidden)"
    fi

    # Check for third-person grammar (basic heuristic: should not start with imperative verb)
    # Common imperative starts that indicate non-third-person
    FIRST_WORD=$(echo "$DESCRIPTION" | awk '{print $1}')
    IMPERATIVE_VERBS=("Create" "Build" "Generate" "Make" "Use" "Run" "Execute" "Help" "Assist" "Process" "Handle" "Manage" "Get" "Set" "Add" "Remove" "Delete" "Update" "Find" "Search")
    for verb in "${IMPERATIVE_VERBS[@]}"; do
        if [[ "$FIRST_WORD" == "$verb" ]]; then
            warning "Description may use imperative form ('$FIRST_WORD...') - prefer third person ('${FIRST_WORD}s...')"
            break
        fi
    done
fi

# Check line count
LINE_COUNT=$(wc -l < "$SKILL_MD")
if [[ $LINE_COUNT -gt 500 ]]; then
    warning "SKILL.md has $LINE_COUNT lines (recommended: <500)"
else
    success "SKILL.md line count OK ($LINE_COUNT lines)"
fi

# Check for Windows paths
if grep -q '\\' "$SKILL_MD"; then
    warning "SKILL.md may contain Windows-style paths (use forward slashes)"
fi

# Check for forbidden files
FORBIDDEN_FILES=("README.md" "INSTALLATION_GUIDE.md" "QUICK_REFERENCE.md" "CHANGELOG.md")
for file in "${FORBIDDEN_FILES[@]}"; do
    if [ -f "$SKILL_DIR/$file" ]; then
        warning "Found $file - consider removing (skill should be self-contained)"
    fi
done

# Check reference depth
if [ -d "$SKILL_DIR/references" ]; then
    NESTED=$(find "$SKILL_DIR/references" -mindepth 2 -type f 2>/dev/null | head -1)
    if [ -n "$NESTED" ]; then
        warning "Nested references found - keep references 1 level deep"
    else
        success "Reference structure OK"
    fi
fi

# Summary
echo ""
echo "================================"
echo "Validation Summary"
echo "================================"
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}FAILED${NC}: Fix errors before deploying"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}PASSED WITH WARNINGS${NC}: Review warnings"
    exit 0
else
    echo -e "${GREEN}PASSED${NC}: Skill is specification compliant"
    exit 0
fi
