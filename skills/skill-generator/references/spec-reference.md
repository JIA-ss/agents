# Agent Skills Specification Reference

Complete technical specification for Claude Code skills based on official Anthropic documentation.

---

## Table of Contents

1. [Frontmatter Specification](#frontmatter-specification)
2. [Directory Structure](#directory-structure)
3. [Content Guidelines](#content-guidelines)
4. [Runtime Environment](#runtime-environment)
5. [Forbidden Patterns](#forbidden-patterns)

---

## Frontmatter Specification

### name Field

| Attribute | Value |
|-----------|-------|
| Required | Yes |
| Max length | 64 characters |
| Allowed chars | `a-z`, `0-9`, `-` (lowercase only) |
| Format | kebab-case |
| Reserved words | Cannot contain "anthropic", "claude" |

**Examples**:
- Good: `pdf-processor`, `code-analyzer`, `task-planner`
- Bad: `PDFProcessor` (uppercase), `my_skill` (underscore), `claude-helper` (reserved word)

### description Field

| Attribute | Value |
|-----------|-------|
| Required | Yes |
| Max length | 1024 characters |
| Min length | Non-empty |
| Grammar | Third person only |
| Forbidden | XML tags, first-person pronouns |

**Structure requirements**:
1. WHAT it does - Functionality description
2. WHEN to use - Specific triggers and contexts

**Pattern**:
```
[Functionality description]. Use when [trigger conditions]. Also responds to "[中文关键词]".
```

**Examples**:

Good:
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction. Also responds to "处理 PDF", "提取文本".
```

Bad:
```yaml
description: Helps with documents  # Too vague, missing "when to use"
description: I can help you process files  # First person prohibited
description: A useful skill  # Doesn't describe what it does
```

---

## Directory Structure

### Standard Layout

```
skill-name/
├── SKILL.md              # Required: Main instructions
├── references/           # Optional: Domain documentation
│   └── *.md              # Loaded on-demand
├── scripts/              # Optional: Executable code
│   └── *.py, *.sh        # Run without loading source
└── assets/               # Optional: Output resources
    └── templates/, images/
```

### File Categories

| Directory | Purpose | Loaded Into Context? |
|-----------|---------|---------------------|
| SKILL.md | Main instructions | Yes, when triggered |
| references/ | Detailed docs | On-demand |
| scripts/ | Executable code | No (only output) |
| assets/ | Templates, images | No |

### DO NOT Include

- README.md (separate from SKILL.md)
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- Any other auxiliary documentation

---

## Content Guidelines

### Progressive Disclosure Levels

| Level | Budget | Content | When Loaded |
|-------|--------|---------|-------------|
| 1 | ~100 tokens | Frontmatter | Always |
| 2 | <5k tokens | SKILL.md body | On trigger |
| 3 | Unlimited | References/scripts | As needed |

### SKILL.md Size Limits

| Metric | Limit | Action if Exceeded |
|--------|-------|-------------------|
| Total lines | <500 | Move to references/ |
| Mermaid nodes | ≤15 | Simplify diagram |
| Reference depth | 1 level | Flatten structure |

### Recommended Sections

1. **Overview** - What, why, core value proposition
2. **Workflow** - Step-by-step process with clear phases
3. **Core Rules** - Constraints, requirements, boundaries
4. **Output Requirements** - Expected format specifications
5. **Best Practices** - Usage guidance and tips
6. **Additional Resources** - Links to references/scripts

### Reference File Guidelines

For files >100 lines, include table of contents at top:

```markdown
# Reference Title

## Table of Contents
- [Section 1](#section-1)
- [Section 2](#section-2)
- [Section 3](#section-3)

---

## Section 1
...
```

---

## Runtime Environment

### Platform Capabilities

| Platform | Network | Package Install | Notes |
|----------|---------|-----------------|-------|
| Claude.ai | Depends on settings | npm/PyPI available | Check user permissions |
| Claude API | No | No | Pre-installed packages only |
| Claude Code | Full access | Recommend local only | Avoid system modifications |

### Script Recommendations

1. **Test before shipping** - Actually run scripts
2. **Handle errors** - Provide clear error messages
3. **Document dependencies** - List required packages
4. **Use forward slashes** - Even on Windows

---

## Forbidden Patterns

### In name Field

- Uppercase letters
- Underscores
- Spaces
- Reserved words: "anthropic", "claude"
- XML tags

### In description Field

- First-person pronouns ("I", "me", "my")
- Second-person pronouns starting sentences ("You can...")
- XML tags
- Vague language without specific triggers

### In Content

- Windows-style paths (`\`)
- Time-sensitive information ("As of 2024...")
- Deeply nested references (>1 level)
- Inconsistent terminology
- Excessive documentation files

### Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `my_skill` | Underscore in name | Use `my-skill` |
| `I can help you...` | First person | Use "Processes files..." |
| `references/a/b.md` | Nested reference | Flatten to `references/b.md` |
| `scripts\helper.py` | Windows path | Use `scripts/helper.py` |
