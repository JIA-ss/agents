# Evidence-2: 脚本可行性分析证据

## 解析 YAML Frontmatter 的技术方案

### 方案 A: Bash 脚本（sed/awk）

**原理**：YAML frontmatter 以 `---` 开头和结尾，结构极其简单（仅 name + description 两个字段），可用文本处理工具直接提取。

**可行性验证**：

```bash
# 提取 frontmatter 中的 name 字段
sed -n '/^---$/,/^---$/p' SKILL.md | grep '^name:' | sed 's/^name: //'

# 提取 description 字段（单行模式）
sed -n '/^---$/,/^---$/p' SKILL.md | grep '^description:' | sed 's/^description: //'
```

**优势**：
- 零依赖，任何类 Unix 环境（包括 Git Bash on Windows）都可运行
- 脚本简短（30-50 行即可完成）
- 执行速度极快（17 个文件 < 1 秒）

**劣势**：
- description 字段可能包含引号、冒号等特殊字符，sed 处理需要小心
- 多行 description（YAML 折叠字符串 `>` 或 `|`）不容易处理
- Windows 原生环境兼容性差（需要 Git Bash 或 WSL）
- 维护性较低，正则表达式晦涩

**风险评估**：
- 当前所有 17 个 SKILL.md 的 description 均为单行，无折叠/块引用语法
- 实际风险低，但未来新增 Skill 可能使用多行 description

### 方案 B: Python 脚本

**原理**：使用 Python 标准库或 `pyyaml` 解析 frontmatter。

**可行性验证**：

```python
import os, re, yaml  # pyyaml 需安装

def parse_frontmatter(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if match:
        return yaml.safe_load(match.group(1))
    return None
```

**替代方案（无第三方依赖）**：

```python
import os, re

def parse_frontmatter_simple(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    match = re.match(r'^---\s*\n(.*?)\n---\s*\n', content, re.DOTALL)
    if not match:
        return None
    result = {}
    for line in match.group(1).strip().split('\n'):
        if ':' in line:
            key, val = line.split(':', 1)
            result[key.strip()] = val.strip()
    return result
```

**优势**：
- 健壮的 YAML 解析（pyyaml 方案）
- 易维护，代码可读性高
- 跨平台兼容（Windows/macOS/Linux）
- 容易扩展（提取 Overview、生成 Markdown 表格等）
- 丰富的字符串处理能力

**劣势**：
- 需要 Python 环境（项目中未必已安装）
- pyyaml 需要额外安装（但可用纯正则替代）
- 相比 bash 略显 "重量级"

**风险评估**：
- Python 3 在开发者机器上几乎普遍存在
- 即使不用 pyyaml，纯正则方案也足够可靠（因为 frontmatter 格式极简）

### 方案 C: Node.js 脚本

**原理**：使用 `gray-matter` npm 包或正则表达式解析。

```javascript
const fs = require('fs');
const matter = require('gray-matter');

const file = fs.readFileSync('SKILL.md', 'utf8');
const { data } = matter(file);
console.log(data.name, data.description);
```

**优势**：
- gray-matter 是成熟的 frontmatter 解析库
- 如果项目本身使用 Node.js 则零额外成本

**劣势**：
- 需要 Node.js + npm install
- 对于非 JS 项目引入不必要的依赖
- 当前项目（Unity 渲染管线）与 Node.js 无关

**结论**：不推荐此方案。

## 索引注入 CLAUDE.local.md 的技术方案

### 标记注入法

在 CLAUDE.local.md 中设置标记行，脚本只替换标记之间的内容：

```markdown
<!-- SKILL-INDEX-START -->
（自动生成的索引内容）
<!-- SKILL-INDEX-END -->
```

**Bash 实现**：
```bash
sed -i '/<!-- SKILL-INDEX-START -->/,/<!-- SKILL-INDEX-END -->/c\<!-- SKILL-INDEX-START -->\n'"$INDEX_CONTENT"'\n<!-- SKILL-INDEX-END -->' CLAUDE.local.md
```

**Python 实现**：
```python
import re
content = open('CLAUDE.local.md', 'r').read()
new_content = re.sub(
    r'<!-- SKILL-INDEX-START -->.*?<!-- SKILL-INDEX-END -->',
    f'<!-- SKILL-INDEX-START -->\n{index}\n<!-- SKILL-INDEX-END -->',
    content, flags=re.DOTALL
)
open('CLAUDE.local.md', 'w').write(new_content)
```

**关键特性**：
- 不破坏标记区域外的内容
- 幂等操作（多次运行结果一致）
- HTML 注释不会在 Markdown 渲染中显示

### 追加法（简单场景）

直接将索引追加到文件末尾。不推荐，因为每次运行会重复追加。

## 执行时机分析

| 时机 | 触发方式 | 适用场景 | 优劣 |
|------|----------|----------|------|
| 手动执行 | 开发者运行脚本 | 开发期间、代码审查后 | 简单可控，但容易遗忘 |
| Git pre-commit hook | `.git/hooks/pre-commit` 或 husky | 每次提交自动更新 | 自动化程度高，但增加提交延迟 |
| Git post-merge hook | `.git/hooks/post-merge` | 拉取代码后自动更新 | 适合协作场景 |
| CI/CD Pipeline | GitLab CI stage | 合并到主分支时 | 最可靠，但反馈延迟 |
| 文件监听 | `inotifywait`/`watchdog` | 开发期间实时更新 | 过于激进，资源消耗 |

**推荐**：
1. **主要方式**：手动执行（开发者在新增/修改 Skill 后主动运行）
2. **辅助方式**：Git pre-commit hook（自动检测 `.claude/skills/` 下有变更时执行）

## 索引格式比较

### Markdown 表格

```markdown
| Skill | 描述 |
|-------|------|
| `gi-expert` | GI Expert Guide - 全局光照系统专家 |
| `fog-expert` | Fog Expert Guide - 雾效系统专家 |
```

**优势**：对 Claude 可读性极佳，结构清晰
**劣势**：描述过长时表格变形

### Markdown 列表

```markdown
- **gi-expert**: GI Expert Guide - 全局光照系统专家，精通 SSGI、VXGI 和 Hybrid 混合追踪技术
- **fog-expert**: Fog Expert Guide - 雾效系统专家，精通三种雾效类型
```

**优势**：描述可以更长，不受表格宽度限制
**劣势**：结构性弱于表格

### YAML 块

```yaml
skills:
  - name: gi-expert
    title: GI Expert Guide
    summary: 全局光照系统专家
  - name: fog-expert
    title: Fog Expert Guide
    summary: 雾效系统专家
```

**优势**：结构化，易于程序处理
**劣势**：在 CLAUDE.local.md 中嵌入 YAML 块不太自然

**推荐**：Markdown 表格，因为 CLAUDE.local.md 本身是 Markdown 格式，表格提供最佳的结构化阅读体验。
