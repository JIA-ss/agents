# Evidence: Claude Code Official Skills Documentation

- **来源**: https://code.claude.com/docs/en/skills
- **搜索关键词**: Claude Code Skills discovery matching mechanism frontmatter description
- **证据等级**: A（官方文档）
- **关键发现**:

## 1. Skill 发现机制

### 文件系统扫描
Claude Code 通过文件系统扫描发现 Skills，按以下优先级层级：
- Enterprise > Personal (`~/.claude/skills/`) > Project (`.claude/skills/`) > Plugin
- 同名 Skill 按优先级覆盖
- 支持 `--add-dir` 额外目录自动发现
- 嵌套目录自动发现：编辑 `packages/frontend/` 时自动查找 `packages/frontend/.claude/skills/`

### 发现时机
- **会话启动时**扫描所有 Skills 目录
- `--add-dir` 的 Skills 支持**实时变更检测**（live change detection）
- Subagent 不继承父会话 Skills，必须在 `skills` 字段显式声明

## 2. Description 字段的关键作用

### 原文描述
> "The `description` helps Claude decide when to load it automatically."
> "Every skill needs a `SKILL.md` file with two parts: YAML frontmatter (between `---` markers) that tells Claude when to use the skill, and markdown content with instructions Claude follows when the skill is invoked."

### 上下文加载机制
文档明确指出：
> "In a regular session, skill descriptions are loaded into context so Claude knows what's available, but full skill content only loads when invoked."

#### 加载规则表

| Frontmatter 配置 | 用户可调用 | Claude 可调用 | 何时加载到上下文 |
|---|---|---|---|
| (默认) | Yes | Yes | Description 始终在上下文中，完整 Skill 仅在调用时加载 |
| `disable-model-invocation: true` | Yes | No | Description 不在上下文中，完整 Skill 仅用户调用时加载 |
| `user-invocable: false` | No | Yes | Description 始终在上下文中，完整 Skill 仅调用时加载 |

### 字符预算限制
文档明确提到：
> "Skill descriptions are loaded into context so Claude knows what's available. If you have many skills, they may exceed the character budget. The budget scales dynamically at 2% of the context window, with a fallback of 16,000 characters."

- 预算 = 上下文窗口的 2%
- 回退值 = 16,000 字符
- 可通过 `SLASH_COMMAND_TOOL_CHAR_BUDGET` 环境变量覆盖
- 超出预算时 Skill 会被排除（可通过 `/context` 查看警告）

## 3. 匹配机制分析

### 非索引机制 - 纯语义匹配
文档没有提及任何"索引"、"向量搜索"或"嵌入"机制。匹配完全依赖：
1. Skill `description` 文本被注入到 Claude 的 system prompt / context 中
2. Claude 模型自身的语义理解能力进行匹配
3. 用户输入与 description 的语义相似度由模型判断

### Skill 工具调用
Skills 通过名为 `Skill` 的工具被调用。Claude 看到所有可用 Skill 的 description 列表后，通过 tool_use 调用匹配的 Skill。

### 触发诊断建议
文档提供了 Skill 不触发时的排查步骤：
1. 检查 description 是否包含用户自然会说的关键词
2. 验证 Skill 是否出现在 "What skills are available?" 的回答中
3. 尝试换个说法匹配 description
4. 使用 `/skill-name` 直接调用

### 过度触发的解决方案
1. 让 description 更具体
2. 添加 `disable-model-invocation: true` 限制为手动调用

## 4. Frontmatter 完整字段参考

| 字段 | 必填 | 描述 |
|---|---|---|
| `name` | No | 小写字母、数字、连字符，最长 64 字符 |
| `description` | Recommended | Skill 做什么以及何时使用。Claude 用此决定何时应用 |
| `argument-hint` | No | 自动补全时显示的参数提示 |
| `disable-model-invocation` | No | `true` 阻止 Claude 自动加载 |
| `user-invocable` | No | `false` 隐藏于 `/` 菜单 |
| `allowed-tools` | No | 活跃时允许的工具 |
| `model` | No | 使用的模型 |
| `context` | No | `fork` 在子代理中运行 |
| `agent` | No | `context: fork` 时的子代理类型 |
| `hooks` | No | Skill 生命周期钩子 |

## 5. 与 Subagent 的关系

Subagent 配置中的 `skills` 字段允许预加载 Skills：
> "The full content of each skill is injected into the subagent's context, not just made available for invocation."

这意味着 Subagent 模式下是**全量注入**而非按需发现。
