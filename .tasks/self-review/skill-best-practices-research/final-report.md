# Claude Code Skill 最佳实践研究报告

## Executive Summary

本报告基于 Anthropic 官方文档、Agent Skills 规范和实际 skill 实现进行深度调研，总结了 Claude Code Skill 的设计原则、规范限制和自我迭代策略。

---

## 1. 官方设计原则 (Official Design Principles)

### 1.1 核心设计理念

根据 Anthropic 官方文档，Skill 的核心设计遵循以下原则：

#### **Progressive Disclosure（渐进披露）**

这是 Agent Skills 最核心的设计原则，实现三级加载机制：

| 级别 | 加载时机 | Token 消耗 | 内容 |
|------|----------|------------|------|
| **Level 1: Metadata** | 启动时（始终） | ~100 tokens/skill | YAML frontmatter 中的 name 和 description |
| **Level 2: Instructions** | Skill 被触发时 | <5k tokens | SKILL.md 主体内容 |
| **Level 3: Resources** | 按需加载 | 有效无限 | 脚本、参考文档、资源文件 |

**设计意义**：
- 可以安装大量 skills 而不产生上下文惩罚
- Claude 只加载当前任务需要的内容
- 脚本执行时只返回输出，代码本身不占用上下文

#### **Concise is Key（简洁至上）**

官方强调上下文窗口是"公共资源"，与系统提示、对话历史、其他 Skills 共享。

**默认假设**：Claude 已经非常聪明，只添加 Claude 尚不知道的上下文。

**Good vs Bad 示例**：

```markdown
# Good (约 50 tokens)
## Extract PDF text
Use pdfplumber for text extraction:
[简洁代码示例]

# Bad (约 150 tokens)
## Extract PDF text
PDF (Portable Document Format) files are a common file format...
[过度解释 PDF 是什么]
```

#### **Set Appropriate Degrees of Freedom（设定适当的自由度）**

根据任务的脆弱性匹配具体程度：

| 自由度 | 使用场景 | 示例 |
|--------|----------|------|
| **高** | 多种方法有效、依赖上下文 | 代码审查流程 |
| **中** | 有首选模式、允许变化 | 带参数的脚本 |
| **低** | 操作脆弱、需要一致性 | 数据库迁移 |

---

### 1.2 标准 Skill 结构

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/ - 可执行代码 (Python/Bash/etc.)
    ├── references/ - 按需加载的参考文档
    └── assets/ - 输出中使用的文件 (模板、图标、字体等)
```

**官方推荐的 SKILL.md 模板**：

```yaml
---
name: my-skill-name
description: A clear description of what this skill does and when to use it
---

# My Skill Name

[Instructions that Claude will follow when this skill is active]

## Examples
- Example usage 1
- Example usage 2

## Guidelines
- Guideline 1
- Guideline 2
```

---

## 2. 规范与限制 (Specifications & Constraints)

### 2.1 Frontmatter 字段规范

#### **name 字段**
| 规则 | 说明 |
|------|------|
| 最大长度 | 64 字符 |
| 允许字符 | 小写字母、数字、连字符 |
| 禁止内容 | XML 标签 |
| 保留词 | 不能包含 "anthropic"、"claude" |
| 命名风格 | 推荐动名词形式 (gerund)：`processing-pdfs`、`analyzing-spreadsheets` |

#### **description 字段**
| 规则 | 说明 |
|------|------|
| 最大长度 | 1024 字符 |
| 最小长度 | 非空 |
| 禁止内容 | XML 标签 |
| 语法要求 | **必须使用第三人称**（避免 "I can help you" 或 "You can use this"） |
| 内容要求 | 包含 "做什么" AND "何时使用" |

**Good description 示例**：
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad description 示例**：
```yaml
description: Helps with documents  # 太模糊
description: I can help you process Excel files  # 不应使用第一人称
```

### 2.2 内容限制

| 限制项 | 官方建议 | 说明 |
|--------|----------|------|
| **SKILL.md 行数** | <500 行 | 超过则应拆分到独立文件 |
| **引用深度** | 1 层 | 所有引用文件直接从 SKILL.md 链接，避免嵌套引用 |
| **Mermaid 图表节点** | ≤15 个 | 避免过于复杂的图表 |
| **任务粒度** | 30分钟 - 8小时 | 对于 task-planner 类 skill |
| **分解深度** | 2-4 层 | 避免过度拆分 |

### 2.3 文件组织规范

#### **应该包含的**
- scripts/ - 确定性、可重复的代码
- references/ - 按需加载的详细文档
- assets/ - 模板、图标等不加载到上下文的资源

#### **不应该包含的**
- README.md（额外的）
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- 其他冗余文档

### 2.4 路径规范

| 规则 | Good | Bad |
|------|------|-----|
| 路径分隔符 | `scripts/helper.py` | `scripts\helper.py` |
| 文件命名 | `form_validation_rules.md` | `doc2.md` |

**永远使用正斜杠**，即使在 Windows 上。

### 2.5 运行时环境限制

| 平台 | 网络访问 | 包安装 | 说明 |
|------|----------|--------|------|
| **Claude.ai** | 取决于用户/管理员设置 | 可从 npm/PyPI 安装 | - |
| **Claude API** | 无 | 无运行时安装 | 只能使用预装包 |
| **Claude Code** | 完全访问 | 建议只本地安装 | 避免干扰用户系统 |

---

## 3. 自我迭代设计模式 (Self-Iteration Patterns)

### 3.1 官方推荐的迭代开发流程

根据官方最佳实践文档，Skill 应该通过以下流程持续改进：

```
┌─────────────────────────────────────────────────────────────┐
│                   Skill 迭代开发流程                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. 与 Claude A 完成任务（无 Skill）                         │
│     └── 注意你反复提供的上下文信息                            │
│              │                                              │
│              ▼                                              │
│  2. 识别可复用模式                                           │
│     └── 从自然对话中提取领域知识                              │
│              │                                              │
│              ▼                                              │
│  3. 让 Claude A 创建 Skill                                  │
│     └── "基于我们的工作创建一个 Skill"                        │
│              │                                              │
│              ▼                                              │
│  4. 精简内容                                                │
│     └── "移除不必要的解释 - Claude 已经知道这些"              │
│              │                                              │
│              ▼                                              │
│  5. 与 Claude B 测试 Skill（新实例）                         │
│     └── 观察行为：是否找到正确信息？是否正确应用规则？           │
│              │                                              │
│              ▼                                              │
│  6. 根据观察优化                                             │
│     └── 返回 Claude A 改进，再用 Claude B 测试                │
│              │                                              │
│              └────────────────► 循环                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 评估驱动开发

官方强调：**先创建评估，再编写文档**

```json
// 评估结构示例
{
  "skills": ["pdf-processing"],
  "query": "Extract all text from this PDF file and save it to output.txt",
  "files": ["test-files/document.pdf"],
  "expected_behavior": [
    "Successfully reads the PDF file using an appropriate PDF processing library",
    "Extracts text content from all pages without missing any pages",
    "Saves the extracted text to output.txt in a clear, readable format"
  ]
}
```

**评估驱动流程**：
1. **识别差距** - 无 Skill 运行任务，记录失败点
2. **创建评估** - 构建 3 个测试场景
3. **建立基线** - 测量无 Skill 时的表现
4. **编写最小指令** - 只添加足够的内容通过评估
5. **迭代** - 执行评估、对比基线、优化

### 3.3 反馈循环模式

**通用验证模式**：

```
执行操作 → 验证 → 发现错误 → 修复 → 重新验证 → 继续
```

**代码示例（文档编辑）**：

```markdown
## Document editing process

1. Make your edits to `word/document.xml`
2. **Validate immediately**: `python ooxml/scripts/validate.py unpacked_dir/`
3. If validation fails:
   - Review the error message carefully
   - Fix the issues in the XML
   - Run validation again
4. **Only proceed when validation passes**
5. Rebuild: `python ooxml/scripts/pack.py unpacked_dir/ output.docx`
```

### 3.4 设计支持自我迭代的 Skill 架构

基于研究，推荐以下架构设计：

```
skill-name/
├── SKILL.md                    # 主文件：概览 + 工作流 + 规则
├── references/
│   ├── domain-knowledge.md     # 领域知识（可独立更新）
│   ├── api-reference.md        # API 参考（易于扩展）
│   └── examples.md             # 示例集（持续积累）
├── scripts/
│   ├── validate.py             # 验证脚本（提供反馈）
│   └── analyze.py              # 分析脚本（收集改进数据）
└── templates/
    └── output-template.md      # 输出模板（可迭代优化）
```

**关键设计点**：

1. **分离关注点**
   - SKILL.md 保持精简（<500 行）
   - 详细内容放 references/
   - 模板和规则独立文件

2. **内置验证机制**
   - 提供验证脚本 validate.py
   - 脚本输出详细错误信息
   - 支持迭代修正

3. **渐进式引用**
   - SKILL.md 作为入口点
   - 根据任务按需加载详细内容
   - 大型参考文件包含目录（>100 行）

4. **避免的模式**
   - 不要提供过多选项（提供默认值 + 逃生舱）
   - 不要包含时间敏感信息
   - 不要使用不一致的术语

### 3.5 检查清单：支持自我迭代的 Skill

```markdown
## 核心质量
- [ ] description 具体且包含关键词
- [ ] description 包含 "做什么" 和 "何时使用"
- [ ] SKILL.md 主体 <500 行
- [ ] 额外细节在独立文件中
- [ ] 无时间敏感信息
- [ ] 术语一致
- [ ] 示例具体而非抽象
- [ ] 文件引用只有一层深度
- [ ] 适当使用渐进披露
- [ ] 工作流步骤清晰

## 代码和脚本
- [ ] 脚本解决问题而非推给 Claude
- [ ] 错误处理明确且有帮助
- [ ] 无"巫毒常量"（所有值有理由）
- [ ] 所需包列在指令中并验证可用
- [ ] 脚本有清晰文档
- [ ] 无 Windows 风格路径
- [ ] 关键操作有验证/确认步骤
- [ ] 质量关键任务包含反馈循环

## 测试
- [ ] 至少创建 3 个评估
- [ ] 在 Haiku、Sonnet、Opus 上测试
- [ ] 在真实使用场景中测试
- [ ] 整合团队反馈（如适用）
```

---

## 4. 最佳实践总结

### 4.1 创建新 Skill 的推荐流程

```
1. 无 Skill 完成任务 → 识别重复提供的上下文
2. 规划可复用内容 → scripts/references/assets
3. 初始化 Skill 目录 → 使用模板
4. 编写 SKILL.md → frontmatter + 主体
5. 添加引用资源 → 按需加载的详细内容
6. 测试脚本 → 实际运行验证
7. 删除不必要文件 → 保持精简
8. 验证和打包 → 检查规范合规性
```

### 4.2 Skill 迭代的最佳实践

1. **观察 Claude 如何导航 Skill**
   - 意外的探索路径？→ 结构不够直观
   - 错过引用？→ 链接需要更明确
   - 过度依赖某些部分？→ 考虑移到 SKILL.md
   - 忽略内容？→ 可能不必要或信号不明确

2. **多模型测试**
   - Haiku（快速、经济）：Skill 是否提供足够指导？
   - Sonnet（平衡）：Skill 是否清晰高效？
   - Opus（强推理）：Skill 是否避免过度解释？

3. **团队反馈收集**
   - Skill 是否按预期激活？
   - 指令是否清晰？
   - 缺少什么？

---

## 5. 参考资源

### 官方文档
- [Agent Skills Overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
- [Skill Authoring Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
- [Agent Skills Specification](https://agentskills.io)

### 官方仓库
- [anthropics/skills](https://github.com/anthropics/skills) - 官方 Skill 示例和规范

### 博客文章
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Equipping Agents for the Real World with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

---

## Appendix: 规范速查表

### Frontmatter 规范
```yaml
---
name: skill-name          # 必需，max 64 chars，只允许 a-z, 0-9, -
description: |            # 必需，max 1024 chars，第三人称
  What it does. Use when [triggers]. Also responds to "中文关键词".
---
```

### 内容限制
- SKILL.md: <500 行
- 引用深度: 1 层
- Mermaid 节点: ≤15 个

### Token 预算
- Level 1 (Metadata): ~100 tokens/skill
- Level 2 (Instructions): <5k tokens
- Level 3 (Resources): 有效无限

### 禁止内容
- name 中的保留词: "anthropic", "claude"
- XML 标签
- Windows 风格路径
- 时间敏感信息
- 不一致的术语
