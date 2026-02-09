# Evidence-1: SKILL.md Frontmatter 实际格式分析

## 数据来源

从 `F:\Workspace\ZGame\master\ZGameClient\Packages\com.lilith.ip.render-pipeline\.claude\skills\` 目录中读取了全部 17 个 SKILL.md 文件的 frontmatter。

## Frontmatter 格式统计

### 字段结构

所有 17 个 SKILL.md 的 frontmatter **格式完全一致**，仅包含两个字段：

```yaml
---
name: <kebab-case-name>
description: <长文本描述>
---
```

无任何文件包含额外字段（如 version、tags、category、author 等）。

### name 字段特征

| Skill 目录名 | frontmatter name | 一致性 |
|---|---|---|
| atmosphere-expert | atmosphere-expert | 一致 |
| cicd-manager | cicd-manager | 一致 |
| fall-particle-height-mask | fall-particle-height-mask | 一致 |
| fluid-simulation-expert | fluid-simulation-expert | 一致 |
| fog-expert | fog-expert | 一致 |
| gi-expert | gi-expert | 一致 |
| lighting-shadow-expert | lighting-shadow-expert | 一致 |
| litrp-framework-specialist | litrp-framework-specialist | 一致 |
| postprocessing-expert | postprocessing-expert | 一致 |
| reflection-system-expert | reflection-system-expert | 一致 |
| shader-framework | shader-framework | 一致 |
| skill-auditor | skill-auditor | 一致 |
| ssr-specialist | ssr-specialist | 一致 |
| taa-upscaler-expert | taa-upscaler-expert | 一致 |
| tod-system | tod-system | 一致 |
| volumetric-clouds-expert | volumetric-clouds-expert | 一致 |
| volumetric-fog-mask | volumetric-fog-mask | 一致 |

**结论**：name 字段与目录名完全一致，均为 kebab-case 格式。

### description 字段特征

**格式模式**：所有 description 均遵循固定模式：

```
Use when the user asks to "<触发短语1>", "<触发短语2>", ..., mentions "<关键词1>", "<关键词2>", ..., or needs help with <描述>. Also responds to "<中文触发词1>", "<中文触发词2>", ...
```

**变体**：
- skill-auditor 在开头添加了中文角色说明："元级 Skill 审计工具，检查项目中所有 Skill 的正确性、时效性和规范性。"
- volumetric-clouds-expert 在开头添加了中文角色说明："Lit Render Pipeline 体积云系统专家，..."

**长度统计**（字符数）：
- 最短：~200 字符 (volumetric-fog-mask)
- 最长：~600 字符 (gi-expert, fall-particle-height-mask)
- 平均：~350 字符

### 正文结构特征

虽然 frontmatter 只有两个字段，SKILL.md 正文的第一级标题(`# ...`)提供了 skill 的人类友好名称：

| name | 正文标题 |
|---|---|
| gi-expert | GI Expert Guide |
| atmosphere-expert | Atmosphere Expert Guide |
| cicd-manager | CI/CD Manager Guide |
| fog-expert | Fog Expert Guide |
| shader-framework | Shader Framework Expert Guide |
| skill-auditor | Skill Auditor |
| tod-system | TOD System Expert Guide |
| volumetric-clouds-expert | 体积云系统专家 |

**结论**：正文标题可作为索引中的 "显示名称"。

### Overview 段落

所有 SKILL.md 在 `## Overview` 段落中包含 1-3 句核心能力描述，可作为索引中的摘要信息。

## 关键发现

1. **格式高度统一**：frontmatter 只有 `name` + `description`，100% 一致
2. **name 与目录名对应**：可以只扫描目录名即获取 name，但读取 frontmatter 可做校验
3. **description 内容丰富但冗长**：包含触发词列表，不适合直接作为索引摘要
4. **正文第一标题 + Overview 段落**：更适合提取为索引摘要
5. **无 version/category 等元数据**：索引字段只能来自 name 和 description
