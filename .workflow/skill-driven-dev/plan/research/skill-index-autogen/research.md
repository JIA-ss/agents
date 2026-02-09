# Skill 索引自动生成可行性调研报告

## 1. SCOPE - 调研范围

### 调研目标
评估通过脚本自动扫描 `.claude/skills/` 目录，提取 SKILL.md frontmatter 信息，生成 Skill 索引并注入 CLAUDE.local.md 的可行性。

### 调研边界
- **输入**：`.claude/skills/*/SKILL.md` 文件集合（当前 17 个）
- **输出**：Markdown 格式的索引表，注入 CLAUDE.local.md 的指定位置
- **环境**：Windows 10/11 开发机，Git Bash / Python 3 可用
- **约束**：不依赖 Node.js 或其他非标准运行时

### 核心问题
1. SKILL.md frontmatter 格式是否足够规范、可机器解析？
2. 用 Bash 和 Python 分别实现的复杂度和可靠性如何？
3. 生成的索引应采用什么格式？
4. 如何安全注入到 CLAUDE.local.md 而不破坏已有内容？
5. 脚本应在什么时机运行？

---

## 2. GATHER - 收集的资料

### 2.1 SKILL.md 实际格式（evidence-1）

通过读取全部 17 个 SKILL.md，确认：

- **frontmatter 结构**：所有文件统一使用 `---` 分隔的 YAML frontmatter
- **字段**：仅有 `name`（kebab-case 字符串）和 `description`（单行长文本）两个字段
- **name 与目录名关系**：17/17 完全一致
- **description 格式**：遵循 `Use when the user asks to ... Also responds to ...` 模式
- **正文结构**：均包含 `# 标题` 和 `## Overview` 段落，可提取人类友好的摘要

### 2.2 CLAUDE.local.md 现有内容

`CLAUDE.local.md` 已存在，包含：
- 项目概述
- Skill 驱动开发流程说明
- 智能 Skill Sync 规则
- Git 提交规范

当前文件中**没有** Skill 索引，仅有文字描述"在 `.claude/skills/` 目录查找"。

### 2.3 YAML Frontmatter 解析方案（evidence-2）

| 维度 | Bash (sed/awk) | Python (正则) | Python (pyyaml) | Node.js (gray-matter) |
|------|----------------|---------------|-----------------|----------------------|
| 依赖 | 无 | Python 3 | Python 3 + pyyaml | Node.js + npm |
| 可靠性 | 中 | 高 | 极高 | 极高 |
| 跨平台 | 需 Git Bash | 好 | 好 | 好 |
| 维护性 | 低 | 高 | 高 | 中 |
| 扩展性 | 低 | 高 | 高 | 高 |
| 开发量 | ~30 行 | ~50 行 | ~50 行 | ~40 行 |

---

## 3. ANALYZE - 方案分析

### 方案 A: Bash 脚本

**实现思路**：

```bash
#!/bin/bash
# generate-skill-index.sh

SKILLS_DIR=".claude/skills"
OUTPUT_FILE="CLAUDE.local.md"

INDEX="| Skill | 描述 |\n|-------|------|\n"

for dir in "$SKILLS_DIR"/*/; do
    skill_file="$dir/SKILL.md"
    [ -f "$skill_file" ] || continue

    # 提取 name
    name=$(sed -n '/^---$/,/^---$/{ /^name:/{ s/^name: *//; p; } }' "$skill_file")

    # 提取正文第一个 # 标题作为显示名
    title=$(grep -m1 '^# ' "$skill_file" | sed 's/^# //')

    # 提取 Overview 第一句话作为简短描述
    summary=$(sed -n '/^## Overview$/,/^##/{/^## Overview$/d; /^##/d; /^$/d; p;}' "$skill_file" \
              | head -3 | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-80)

    INDEX+="| \`$name\` | $title - $summary... |\n"
done

# 注入到 CLAUDE.local.md（标记替换法）
if grep -q '<!-- SKILL-INDEX-START -->' "$OUTPUT_FILE"; then
    # 替换已有索引
    sed -i '/<!-- SKILL-INDEX-START -->/,/<!-- SKILL-INDEX-END -->/c\
<!-- SKILL-INDEX-START -->\n'"$(echo -e "$INDEX")"'\n<!-- SKILL-INDEX-END -->' "$OUTPUT_FILE"
else
    # 首次添加，追加到文件末尾
    echo -e "\n<!-- SKILL-INDEX-START -->\n$INDEX\n<!-- SKILL-INDEX-END -->" >> "$OUTPUT_FILE"
fi
```

**优势**：
- 零运行时依赖
- 与 Git hooks 天然集成
- 开发者熟悉的 shell 工具链

**劣势**：
- sed 在 Windows Git Bash 中行为可能与 Linux 不一致（换行符 CR/LF 问题）
- 多行替换逻辑脆弱，调试困难
- 特殊字符（`|`、`` ` ``、`\`）在 sed 中需要转义
- Overview 提取逻辑不够精确
- 不同 sed 版本（GNU vs BSD/macOS）语法差异

**风险**：
- **中等风险**：CR/LF 和 sed 版本差异可能导致脚本在不同开发者机器上行为不一致
- **低风险**：当前 frontmatter 格式极简，解析本身不会出问题

### 方案 B: Python 脚本

**实现思路**：

```python
#!/usr/bin/env python3
"""generate-skill-index.py - 自动生成 Skill 索引并注入 CLAUDE.local.md"""

import os
import re
import glob

def parse_skill(filepath):
    """解析 SKILL.md，提取 frontmatter 和 Overview。"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取 frontmatter
    fm_match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if not fm_match:
        return None

    fm = {}
    for line in fm_match.group(1).strip().split('\n'):
        if ':' in line:
            key, val = line.split(':', 1)
            fm[key.strip()] = val.strip()

    # 提取正文第一个 # 标题
    title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
    fm['title'] = title_match.group(1) if title_match else fm.get('name', '')

    # 提取 Overview 段落的前两句
    ov_match = re.search(
        r'^## Overview\s*\n\n(.+?)(?:\n\n|\n##)', content, re.MULTILINE | re.DOTALL
    )
    if ov_match:
        overview = ov_match.group(1).replace('\n', ' ').strip()
        # 取前 100 个字符
        fm['summary'] = overview[:100] + ('...' if len(overview) > 100 else '')
    else:
        fm['summary'] = ''

    return fm


def generate_index(skills_dir):
    """扫描目录，生成 Markdown 表格索引。"""
    skills = []
    for skill_md in sorted(glob.glob(os.path.join(skills_dir, '*/SKILL.md'))):
        info = parse_skill(skill_md)
        if info:
            skills.append(info)

    lines = [
        '### Skill 索引（自动生成）\n',
        '| Skill 名称 | 标题 | 简介 |',
        '|------------|------|------|',
    ]
    for s in skills:
        lines.append(f'| `{s["name"]}` | {s["title"]} | {s["summary"]} |')

    lines.append(f'\n> 共 {len(skills)} 个 Skill，'
                 f'自动扫描自 `.claude/skills/` 目录')

    return '\n'.join(lines)


def inject_index(target_file, index_content):
    """将索引注入 CLAUDE.local.md 的标记位置。"""
    start_marker = '<!-- SKILL-INDEX-START -->'
    end_marker = '<!-- SKILL-INDEX-END -->'

    with open(target_file, 'r', encoding='utf-8') as f:
        content = f.read()

    block = f'{start_marker}\n{index_content}\n{end_marker}'

    if start_marker in content:
        # 替换已有索引
        content = re.sub(
            rf'{re.escape(start_marker)}.*?{re.escape(end_marker)}',
            block, content, flags=re.DOTALL
        )
    else:
        # 首次添加
        content += f'\n\n{block}\n'

    with open(target_file, 'w', encoding='utf-8') as f:
        f.write(content)


if __name__ == '__main__':
    import sys
    skills_dir = sys.argv[1] if len(sys.argv) > 1 else '.claude/skills'
    target = sys.argv[2] if len(sys.argv) > 2 else 'CLAUDE.local.md'

    index = generate_index(skills_dir)
    inject_index(target, index)
    print(f'Skill 索引已更新到 {target}')
```

**优势**：
- 跨平台一致性（Python 3 在 Windows/macOS/Linux 行为一致）
- 正则解析 frontmatter 可靠，能正确处理特殊字符
- 容易扩展：未来可添加 category、tags 等字段解析
- 代码可读性高，团队易维护
- UTF-8 编码处理原生支持（中文 description）
- 容易添加校验逻辑（name 与目录名一致性检查等）

**劣势**：
- 需要 Python 3 环境
- 相比 Bash 脚本略显 "重量级"

**风险**：
- **极低风险**：Python 3 在开发者机器上几乎普遍可用
- **无依赖风险**：使用纯标准库（os, re, glob），不需要 pip install

---

## 4. COMPARE - 方案对比

| 评估维度 | 方案 A: Bash | 方案 B: Python | 胜出 |
|----------|-------------|----------------|------|
| **依赖** | 无（Git Bash） | Python 3（标准库） | Bash 略优 |
| **跨平台** | Git Bash 必需，macOS sed 不同 | 完全一致 | **Python** |
| **可靠性** | 中（特殊字符/换行问题） | 高（正则 + UTF-8） | **Python** |
| **可读性** | 低（sed/awk 正则晦涩） | 高（结构化代码） | **Python** |
| **可扩展性** | 低（添加字段需重写解析） | 高（字典结构天然扩展） | **Python** |
| **维护成本** | 中高 | 低 | **Python** |
| **开发速度** | 快（30 行） | 中（50-80 行） | Bash 略优 |
| **Git Hook 集成** | 直接使用 | 需 python3 调用 | 持平 |
| **团队接受度** | 中（shell 技能差异大） | 高（Python 普及率高） | **Python** |

**综合评分**：
- 方案 A (Bash): 6/10
- 方案 B (Python): 9/10

---

## 5. RECOMMEND - 推荐方案

### 推荐：方案 B - Python 脚本

**理由**：
1. **可靠性是第一优先级**：索引生成脚本作为开发基础设施，必须在所有开发者机器上一致工作。Python 在跨平台一致性上远优于 Bash（尤其在 Windows 环境下 sed 行为差异是常见痛点）。
2. **中文内容处理**：SKILL.md 的 description 和 Overview 包含大量中文，Python 的 UTF-8 处理原生且可靠。
3. **扩展性**：未来可能需要提取更多字段（如 version、tags），Python 字典结构天然支持。
4. **零外部依赖**：纯标准库实现（os, re, glob, sys），不需要 pip install。

### 具体设计方案

#### 脚本文件
- 路径：`.claude/scripts/generate-skill-index.py`
- 语言：Python 3.6+（无第三方依赖）
- 入口：`python3 .claude/scripts/generate-skill-index.py [skills_dir] [target_file]`

#### 提取字段
从每个 SKILL.md 提取：

| 字段 | 来源 | 用途 |
|------|------|------|
| `name` | frontmatter `name:` | 索引主键、Skill 命令名 |
| `title` | 正文第一个 `# 标题` | 人类友好的显示名 |
| `summary` | `## Overview` 段落前 100 字符 | 简短功能描述 |
| `description` | frontmatter `description:` | 完整触发词（可选，用于调试） |

#### 索引格式
推荐 Markdown 表格，嵌入 CLAUDE.local.md：

```markdown
<!-- SKILL-INDEX-START -->
### Skill 索引（自动生成）

| Skill 名称 | 标题 | 简介 |
|------------|------|------|
| `atmosphere-expert` | Atmosphere Expert Guide | Lit Render Pipeline 大气散射系统专家，专注于物理大气模型、LUT 生成、天空渲染与体积雾耦合... |
| `cicd-manager` | CI/CD Manager Guide | Unity 渲染管线项目的 CI/CD 流水线管理专家，专注于 GitLab CI/CD 自动化、版本发布管理... |
| `fog-expert` | Fog Expert Guide | Lit Render Pipeline 雾效系统专家，精通三种雾效类型的实现、配置和优化... |
| ... | ... | ... |

> 共 17 个 Skill，自动扫描自 `.claude/skills/` 目录
<!-- SKILL-INDEX-END -->
```

**选择表格而非列表的理由**：
- 三列结构（名称/标题/简介）信息密度最高
- Claude 读取 CLAUDE.local.md 时，表格格式提供清晰的结构化上下文
- 便于快速定位目标 Skill

#### 注入策略
- 使用 HTML 注释标记 `<!-- SKILL-INDEX-START -->` / `<!-- SKILL-INDEX-END -->`
- 标记之间的内容每次完全替换（幂等操作）
- 标记不影响 Markdown 渲染

#### 推荐运行时机

**主要方式：手动运行**

```bash
# 在项目根目录执行
python3 .claude/scripts/generate-skill-index.py
```

适用于：新增 Skill、修改 Skill frontmatter、定期审计后。

**辅助方式：Git pre-commit hook（可选）**

```bash
# .git/hooks/pre-commit 中添加
if git diff --cached --name-only | grep -q '\.claude/skills/.*/SKILL\.md'; then
    python3 .claude/scripts/generate-skill-index.py
    git add CLAUDE.local.md
fi
```

仅在 SKILL.md 有变更时触发，避免不必要的执行。

#### 校验功能（可选扩展）

脚本可附带校验功能：
- 检查 name 与目录名一致性
- 检查 description 长度（< 1024 字符）
- 检查 name 格式（kebab-case）
- 输出校验报告

### 结论

Skill 索引自动生成**完全可行**，技术风险极低。推荐使用 Python 脚本实现，预计开发工作量约 50-80 行代码，半小时内可完成。核心要素：

1. 纯 Python 标准库，零外部依赖
2. 正则提取 frontmatter + Overview 摘要
3. Markdown 表格格式输出
4. HTML 注释标记注入法，保护 CLAUDE.local.md 已有内容
5. 手动运行为主，Git hook 为辅
