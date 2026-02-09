# Research Report: Claude Code Skill Discovery & Matching Mechanism

## 1. SCOPE - 调研范围和评估维度

### 调研问题
1. Claude Code Skills 的 frontmatter `description` 字段如何被用于匹配用户查询？
2. Claude Code 是否有内置的 Skill 索引机制？还是纯依赖 description 字段的语义匹配？
3. CLAUDE.md 或 CLAUDE.local.md 中写入 Skill 注册表是否有助于提高 AI 的匹配准确率？
4. 如果项目有 15+ 个 Skills，AI 是否会在每次对话开始时加载所有 Skills 的 frontmatter？
5. 最佳实践：如何编写 description 字段以获得最高匹配准确率？

### 评估维度
- **机制透明度**: 官方文档对发现/匹配机制的描述程度
- **可扩展性**: 当 Skill 数量增多时的行为
- **匹配准确率**: 不同写法对匹配效果的影响
- **上下文成本**: Skill description 对 context window 的消耗

---

## 2. GATHER - 收集的资料索引

| # | 来源 | 类型 | 关键内容 |
|---|---|---|---|
| 1 | [Claude Code Skills 官方文档](https://code.claude.com/docs/en/skills) | 官方文档 (A) | Skill 生命周期、frontmatter 字段、发现机制、字符预算 |
| 2 | [Claude Code Memory 官方文档](https://code.claude.com/docs/en/memory) | 官方文档 (A) | CLAUDE.md 加载层级、Rules 文件 |
| 3 | [Claude Code Subagents 官方文档](https://code.claude.com/docs/en/sub-agents) | 官方文档 (A) | Subagent 中 Skills 预加载机制 |
| 4 | [Claude Code Interactive Mode 文档](https://code.claude.com/docs/en/interactive-mode) | 官方文档 (A) | `/` 命令交互、Skill 触发方式 |
| 5 | render-pipeline 项目 17 个 SKILL.md | 本地项目 (B) | 实际 description 写法模式 |
| 6 | render-pipeline CLAUDE.local.md | 本地项目 (B) | Skill 驱动开发流程 |
| 7 | 当前会话系统提示 | 运行时分析 (B) | Skill 工具定义和调用方式 |

---

## 3. ANALYZE - 分析发现

### 3.1 Skill 发现机制 - 完整生命周期

```
[Session Start]
       |
       v
[文件系统扫描] -----> 扫描所有 Skills 目录
       |                  Enterprise > Personal > Project > Plugin
       |                  嵌套 .claude/skills/ 自动发现
       |                  --add-dir 额外目录
       v
[Description 提取] --> 从每个 SKILL.md 提取 frontmatter
       |                  跳过 disable-model-invocation: true
       |                  如无 description，使用 markdown 首段
       v
[注入 System Prompt] -> 所有 Description 注入到 Claude 上下文
       |                  受字符预算限制 (2% context / 16K fallback)
       |                  以 Skill 工具的可用选项列表形式呈现
       v
[用户输入] ---------> Claude 模型语义理解
       |                  对比用户输入 vs 所有 Description
       |                  判断是否需要调用某个 Skill
       v
[Skill 调用] -------> 通过 Skill tool_use 调用
       |                  完整 SKILL.md 内容加载到上下文
       v
[执行指令] ---------> Claude 按 SKILL.md 内容执行
```

### 3.2 核心发现：没有索引/检索机制

**关键结论**：Claude Code **没有** 任何形式的索引机制（无向量搜索、无关键词索引、无 embedding）。

匹配完全依赖以下机制链：

1. **Description 文本直接注入** Claude 的 context window
2. **Claude 模型自身的语义理解**能力判断匹配度
3. **Skill tool** 作为一个可用工具，Claude 决定是否调用

这意味着：
- 匹配质量完全取决于 description 文本的质量
- 匹配准确率受限于 Claude 模型的语义理解能力
- 没有额外的 retrieval layer

### 3.3 字符预算约束

| 上下文窗口大小 | 2% 预算 | 16K 回退 | 实际预算 |
|---|---|---|---|
| 1M (Opus 4.6) | 20,000 chars | 16,000 chars | 20,000 chars |
| 200K (Sonnet) | 4,000 chars | 16,000 chars | 16,000 chars (fallback) |
| 128K (Haiku) | 2,560 chars | 16,000 chars | 16,000 chars (fallback) |

**当前项目情况**：17 个 Skills，总 description 约 6,940 字符。
- Opus 4.6 (1M): 安全（6,940 < 20,000）
- Sonnet/Haiku (fallback 16K): 安全（6,940 < 16,000）
- 如果每个 Skill description 平均 1,000 字符，最多支持 16-20 个 Skills（在 fallback 下）

### 3.4 CLAUDE.md Skill 注册表的实际效果

render-pipeline 项目在 `CLAUDE.local.md` 中实现了一个**隐式的 Skill 注册表**：

```markdown
## 强制要求：Skill 驱动开发
每次开发/修复必须遵循此流程：
1. 定位 Skill -> 在 .claude/skills/ 目录查找，按系统名称匹配
```

**这种做法的效果**：
- 不是通过改变发现机制来提高匹配率
- 而是通过改变 Claude 的**行为模式**：强制 Claude 主动去查找 Skill
- 即使 description 匹配失败，CLAUDE.md 中的指令也会驱动 Claude 去目录中手动搜索
- 相当于增加了一个**后备发现通道**

### 3.5 15+ Skills 时的加载行为

**答案确认**：是的，Claude Code 在每次对话开始时加载**所有** Skills 的 description（除了标记了 `disable-model-invocation: true` 的）。

这不是"按需加载"description——是**全量预加载 description、按需加载完整内容**。

加载顺序：
1. 会话启动 -> 扫描所有 Skills 目录
2. 提取所有 description -> 检查字符预算
3. 在预算内的 description 全部注入 context
4. 超出预算的 Skill 被排除（`/context` 可查看警告）

---

## 4. COMPARE - 方案对比

### 方案 A：纯 Frontmatter 匹配（Claude Code 默认）

**原理**：仅依赖 SKILL.md 的 frontmatter description 字段

| 优点 | 缺点 |
|---|---|
| 零配置，开箱即用 | description 过长可能超出字符预算 |
| 标准化，遵循 Agent Skills 开放标准 | 语义重叠的 Skills 可能误匹配 |
| Claude 语义理解能力强 | 用户用词不精确时可能匹配失败 |
| 无额外维护成本 | 无法提供额外的匹配上下文 |

**适用场景**：Skills 数量少（<10），领域分界清晰

### 方案 B：CLAUDE.md 显式索引

**原理**：在 CLAUDE.md/CLAUDE.local.md 中写入 Skill 注册表和查找指令

示例：
```markdown
## Skill 索引
| 系统 | Skill | 触发关键词 |
|------|-------|-----------|
| GI | gi-expert | GI, SSGI, VXGI, 全局光照 |
| 雾效 | fog-expert | fog, 体积雾, VBuffer |
...

规则：收到用户任务后，先查阅此表确定最匹配的 Skill
```

| 优点 | 缺点 |
|---|---|
| 提供额外的匹配上下文 | 需要手动维护索引表 |
| 可以包含使用场景说明 | 索引表本身消耗 context |
| 解决 description 匹配不到的情况 | 可能与 description 冲突 |
| 可以定义查找优先级 | 增加项目复杂度 |

**适用场景**：Skills 数量多（>10），领域有重叠

### 方案 C：混合方案（推荐）

**原理**：高质量 Frontmatter + CLAUDE.md 行为指令 + 轻量索引

这是 render-pipeline 项目实际采用的方案：
1. **每个 Skill** 有精心编写的 description（含英中双语触发词）
2. **CLAUDE.local.md** 包含"Skill 驱动开发"的行为指令
3. **不维护完整索引表**，但指明目录位置供 Claude 自行查找

| 优点 | 缺点 |
|---|---|
| 双重保障：自动匹配 + 主动查找 | CLAUDE.md 指令消耗部分 context |
| description 仍是主要匹配通道 | 需要在 CLAUDE.md 中写清楚流程 |
| 即使匹配失败也有后备通道 | 首次查找可能比自动匹配慢 |
| 维护成本适中 | 需要团队理解并遵循 |
| 支持大量 Skills (15+) | - |

**适用场景**：中大型项目，多 Skills，多开发者

### 三方案对比总结

| 维度 | 方案 A: 纯 Frontmatter | 方案 B: CLAUDE.md 索引 | 方案 C: 混合方案 |
|---|---|---|---|
| **匹配准确率** | 中等 | 高 | 高 |
| **维护成本** | 低 | 高 | 中 |
| **Context 消耗** | 低（仅 description） | 中（description + 索引表） | 中低（description + 行为指令） |
| **扩展性** | 受字符预算限制 | 索引表也消耗 context | 较好 |
| **标准兼容** | 完全兼容 | 非标准 | 兼容 |
| **后备能力** | 无 | 有 | 有 |
| **适合 Skill 数量** | <10 | 10-30 | 10-30+ |

---

## 5. RECOMMEND - 推荐结论

### 5.1 核心结论

1. **Claude Code 没有内置索引机制**。匹配完全依赖 description 文本注入 context + Claude 模型语义理解。

2. **Description 字段是唯一的自动匹配通道**。写好 description 是提高匹配率的最直接方式。

3. **CLAUDE.md 中的 Skill 指令有效**，但其作用是改变 Claude 的行为模式（主动查找），而非改变发现机制本身。

4. **15+ Skills 在当前模型下可以全量加载 description**。Opus 4.6 的 1M context 下 2% 预算 = 20,000 字符，足以容纳 40+ 个 Skills 的 description。

5. **推荐采用混合方案 (方案 C)**，即 render-pipeline 项目当前的做法。

### 5.2 Description 编写最佳实践

基于官方文档和 render-pipeline 实践，推荐以下 description 编写模式：

#### 结构模板
```yaml
description: >
  [一句话功能概述]。
  Use when the user asks to "[动作1]", "[动作2]", "[动作3]",
  mentions "[术语1]", "[术语2]", "[术语3]",
  or needs help with [领域描述]。
  Also responds to "[中文触发词1]", "[中文触发词2]".
```

#### 编写规则

1. **包含用户自然语言**：用引号包裹用户可能说的完整短语
   - 好: `"debug volumetric fog"`, `"优化体积雾"`
   - 差: `volumetric fog debugging and optimization support`

2. **覆盖多种意图动词**：
   - 调试类: debug, fix, troubleshoot, diagnose
   - 配置类: configure, setup, adjust, tune
   - 优化类: optimize, improve, enhance
   - 分析类: analyze, review, inspect

3. **包含领域术语和类名**：
   - 技术术语: `"SSGI"`, `"VBuffer"`, `"Rayleigh scattering"`
   - 代码实体: `"EnvironmentManager"`, `"VXGIGridManager"`

4. **双语支持**（如果用户使用中文）：
   - 在 `Also responds to` 后添加中文触发词
   - 中文触发词对应英文关键动作

5. **长度控制**：
   - 单个 description 建议 200-500 字符
   - 总量不超过字符预算（使用 `/context` 检查）

6. **避免过度重叠**：
   - 不同 Skill 的 description 中避免出现相同的高频触发词
   - 如 `ssr-specialist` 和 `reflection-system-expert` 都包含 "SSR"，应通过动词区分

#### 反模式

- 太短: `"Handles GI stuff"` -- Claude 无法准确匹配
- 太宽泛: `"Use for any rendering question"` -- 会频繁误触发
- 缺少动词: `"GI system, SSGI, VXGI"` -- 只有名词无法匹配动作意图
- 纯英文（中文用户项目）: 缺少中文触发词降低中文查询匹配率

### 5.3 CLAUDE.md 增强策略

推荐在 `CLAUDE.md` 或 `CLAUDE.local.md` 中添加以下内容（不需要完整索引表）：

```markdown
## Skill 驱动开发

每次收到开发/调试/优化任务时：
1. 先判断是否有匹配的 Skill（查看 `.claude/skills/` 目录）
2. 如果有，先阅读对应 SKILL.md 再执行任务
3. 如果无法确定，优先查阅 `litrp-framework-specialist`（总览 Skill）

Skill 目录: `.claude/skills/`
```

**不推荐**维护完整的 Skill 注册表，原因：
- description 已提供匹配信息
- 注册表需要与 Skills 同步维护
- 行为指令足以弥补自动匹配的不足

### 5.4 扩展性建议

当 Skills 数量超过 20 个时：
1. 使用 `/context` 检查是否有被排除的 Skill
2. 考虑设置 `SLASH_COMMAND_TOOL_CHAR_BUDGET` 环境变量增大预算
3. 将纯工具类 Skill（如 `skill-auditor`）标记为 `disable-model-invocation: true`，减少 description 占用
4. 精简低频 Skill 的 description 长度
5. 考虑合并领域重叠度高的 Skills

### 5.5 监控与诊断

- 使用 `/context` 命令查看 Skill 加载状态和是否有被排除的 Skill
- 如果 Skill 不触发，按官方 troubleshooting 步骤排查
- 定期运行 `/skill-auditor` 检查 description 质量
- 观察 Claude 的 Skill tool_use 调用日志判断匹配准确率
