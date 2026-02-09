# 调研汇总索引

## 完成的调研

| # | 主题 | 目录 | Evidence 数 | 核心结论 |
|---|------|------|------------|----------|
| 1 | Claude Code Skill 发现与匹配机制 | `skill-discovery-mechanism/` | 2 | 无内置索引，纯语义匹配。推荐混合方案（高质量 description + CLAUDE.md 行为指令） |
| 2 | Skill 索引自动生成可行性 | `skill-index-autogen/` | 2 | 完全可行。推荐 Python 脚本，50-80 行代码，HTML 注释标记注入 |

## 关键发现汇总

### 发现 1: 匹配机制
- Claude Code **没有** 内置索引/检索机制
- 所有 Skill description 会话启动时全量注入 context
- 字符预算: context 的 2%（1M context = 20K chars，容纳 40+ Skills）
- 匹配质量完全取决于 description 文本质量 + Claude 语义理解

### 发现 2: 最优发现策略
- **方案 C（混合方案）**最优: 高质量 frontmatter + CLAUDE.md 行为指令
- 不需要维护完整索引表（description 已提供匹配信息）
- CLAUDE.md 中的"Skill 驱动开发"指令作为后备通道

### 发现 3: 索引自动生成
- Python 脚本可从 SKILL.md frontmatter 提取 name + description
- 正文中的 `# Title` 和 `## Overview` 更适合做索引摘要
- HTML 注释标记法 (`<!-- SKILL-INDEX-START/END -->`) 实现幂等注入
- 可集成到 pre-commit hook（仅在 SKILL.md 变更时触发）

### 发现 4: Description 编写规范
推荐模式:
```
Use when the user asks to "[动作1]", "[动作2]",
mentions "[术语1]", "[术语2]",
or needs help with [领域描述].
Also responds to "[中文触发词]".
```

## 对 Plan 阶段的设计输入

1. **Skill 发现架构**: 采用混合方案，不需要额外索引层
2. **CLAUDE.local.md 模板**: 包含"Skill 驱动开发"流程指令，不含完整索引表
3. **索引脚本**: 可选的辅助工具，自动生成供人类阅读的 Skill 列表
4. **SKILL.md 模板**: frontmatter description 需规范化模式
5. **Sync 规则**: 嵌入 CLAUDE.local.md（与现有实践一致）
