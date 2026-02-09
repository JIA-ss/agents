# Evidence: Render-Pipeline 项目 Skills 实例分析

- **来源**: `F:\Workspace\ZGame\master\ZGameClient\Packages\com.lilith.ip.render-pipeline\.claude\skills\` (17 个 Skills) + `CLAUDE.local.md`
- **搜索关键词**: N/A（本地文件系统分析）
- **证据等级**: B（真实项目实践验证）
- **关键发现**:

## 1. 项目 Skills 清单（17 个）

| # | Skill 名称 | Description 长度（字符） | 包含触发词 | 双语支持 |
|---|---|---|---|---|
| 1 | atmosphere-expert | ~450 | Yes (动词+名词) | 中+英 |
| 2 | cicd-manager | ~320 | Yes | 中+英 |
| 3 | fall-particle-height-mask | ~510 | Yes | 中+英 |
| 4 | fluid-simulation-expert | ~420 | Yes | 中+英 |
| 5 | fog-expert | ~380 | Yes | 中+英 |
| 6 | gi-expert | ~430 | Yes | 中+英 |
| 7 | lighting-shadow-expert | ~550 | Yes | 中+英 |
| 8 | litrp-framework-specialist | ~400 | Yes | 中+英 |
| 9 | postprocessing-expert | ~450 | Yes | 中+英 |
| 10 | reflection-system-expert | ~400 | Yes | 中+英 |
| 11 | shader-framework | ~420 | Yes | 中+英 |
| 12 | skill-auditor | ~280 | Yes | 中+英 |
| 13 | ssr-specialist | ~400 | Yes | 中+英 |
| 14 | taa-upscaler-expert | ~450 | Yes | 中+英 |
| 15 | tod-system | ~350 | Yes | 中+英 |
| 16 | volumetric-clouds-expert | ~350 | Yes | 中+英 |
| 17 | volumetric-fog-mask | ~380 | Yes | 中+英 |

**总 description 字符数估算**: ~6,940 字符

## 2. Description 写法模式分析

### 通用模式
所有 17 个 Skills 的 description 遵循一致的结构：

```
Use when the user asks to "[动词短语1]", "[动词短语2]", ...,
mentions "[名词/术语1]", "[名词/术语2]", ...,
or needs help with [领域描述].
Also responds to "[中文触发词1]", "[中文触发词2]", ...
```

### 分解为 4 个组成部分

1. **动作触发** (`Use when the user asks to`):
   - `"debug atmosphere"`, `"fix sky rendering"`, `"optimize LUT generation"`
   - 使用引号包裹的用户可能说的自然语言短语

2. **术语触发** (`mentions`):
   - `"atmosphere system"`, `"Rayleigh scattering"`, `"VXGIGridManager"`
   - 领域特定术语、类名、系统名

3. **领域描述** (`or needs help with`):
   - `"Lit Render Pipeline atmospheric scattering features"`
   - 较宽泛的领域描述，捕获边缘情况

4. **中文触发** (`Also responds to`):
   - `"调试大气"`, `"修复天空渲染"`, `"优化 LUT 生成"`
   - 对应英文触发词的中文翻译

### 示例：gi-expert 的 description 结构
```
Use when the user asks to
  "analyze GI system",          ← 动作触发（分析）
  "debug global illumination",  ← 动作触发（调试）
  "optimize SSGI",              ← 动作触发（优化）
  "configure VXGI",             ← 动作触发（配置）
  "setup hybrid tracing",       ← 动作触发（设置）
mentions
  "multi-grid",                 ← 术语触发
  "voxelization",               ← 术语触发
  "radiance",                   ← 术语触发
  "GI performance",             ← 术语触发
or needs help with
  Lit Render Pipeline global illumination implementation.  ← 领域描述
Also responds to
  "分析 GI 系统", "调试全局光照", "优化 SSGI", ...  ← 中文触发
```

## 3. CLAUDE.local.md 中的 Skill 索引策略

`CLAUDE.local.md` 文件包含了显式的 Skill 驱动开发流程：

```markdown
## 强制要求：Skill 驱动开发

每次开发/修复必须遵循此流程：
1. 定位 Skill -> 2. 阅读上下文 -> 3. 执行任务 -> 4. 智能 Skill Sync

| 步骤 | 操作 | 说明 |
|------|------|------|
| 定位 | 在 `.claude/skills/` 目录查找 | 按系统名称匹配，如 fog-expert、tod-system |
| 阅读 | 打开 `SKILL.md` | 了解架构、API、常见陷阱 |
| 执行 | 按 Skill 指导完成任务 | - |
| Sync | 智能判断是否更新 | 见下方规则 |
```

**关键发现**: 项目选择在 `CLAUDE.local.md` 中**强制要求 Claude 主动查找 Skill**，而不仅仅依赖自动匹配。这是一种**混合方案**：
- 自动匹配：靠 frontmatter description 的语义匹配
- 主动查找：通过 CLAUDE.local.md 中的指令让 Claude 主动到目录中定位

## 4. Skill 内容规模分析

| Skill | SKILL.md 行数 | 是否有 .evolution | 是否有 tests |
|---|---|---|---|
| gi-expert | ~608 | Yes | Unknown |
| atmosphere-expert | ~623 | Yes | Unknown |
| shader-framework | ~557 | Yes | Yes (tests/test-spec.yaml) |
| skill-auditor | ~187 | Yes | Unknown |

**观察**: 大多数 Skill 的 SKILL.md 接近或超过 500 行的建议上限。官方文档建议：
> "Keep SKILL.md under 500 lines. Move detailed reference material to separate files."

## 5. 字符预算计算

对于 17 个 Skills 的 description 总字符数约 6,940：
- 默认预算 = context window 的 2%
- Claude Opus 4.6 的 1M context: 2% = 20,000 字符
- Claude Sonnet 的 200K context: 2% = 4,000 字符
- 回退值: 16,000 字符

**结论**:
- 在 1M context 下 (如当前 Opus 4.6): 6,940 < 20,000，**所有 Skill description 均可加载**
- 在 200K context 下 (如 Sonnet): 6,940 > 4,000，**可能有 Skill 被排除**
- 使用回退值 16,000: 6,940 < 16,000，**足够**

## 6. Skill 同名冲突

当前项目 `ssr-specialist` 和 `reflection-system-expert` 存在领域重叠：
- ssr-specialist: "debug SSR", "optimize screen space reflection"
- reflection-system-expert: "configure SSR", "setup planar reflection"

两者都包含 "SSR" 关键词。根据官方文档，Claude 会根据语义理解选择更匹配的一个，但这种重叠可能导致不稳定匹配。
