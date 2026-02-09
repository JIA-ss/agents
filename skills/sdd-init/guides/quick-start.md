# Quick Start: 快速搭建 Skill 驱动开发体系

从零开始，1 小时内完成首个 Skill 的创建和验证。

---

## 前置条件

- [x] 已安装 [Claude Code](https://code.claude.com)
- [x] 项目已使用 Git 版本控制
- [x] Python 3.6+（可选，用于索引生成脚本）

---

## 步骤 1: 创建 CLAUDE.local.md（5 分钟）

**推荐方式**：在项目目录下运行 `/sdd-init`，交互式自动完成。

**手动方式**：从 `sdd-init` skill 目录复制模板：

```bash
cp <sdd-init-skill-path>/templates/CLAUDE.local.template.md <你的项目>/CLAUDE.local.md
```

> `<sdd-init-skill-path>` 通常为 `~/.claude/skills/sdd-init` 或项目内 `.claude/skills/sdd-init`

**必须填写的占位符**：
- `{项目名称}` → 你的项目名
- `{项目简介}` → 一句话描述
- `{技术栈}` → 如 "Python + FastAPI + PostgreSQL"
- `{模块路径}` → 项目核心模块目录
- `{框架Skill名称}` → 你的第一个 Skill 名称

其他章节（Skill 驱动开发流程、Sync 规则）已预填，无需修改。

**如果复制失败**：直接参考 `sdd-init/templates/CLAUDE.local.template.md` 的内容手动创建文件。核心是保留"Skill 驱动开发（强制）"整个章节。

---

## 步骤 2: 识别第一个特性（10 分钟）

选择项目中**最常被修改、最需要知识沉淀**的模块作为第一个 Skill。

**快速判断方法**（详见 `guides/feature-identification.md`）：

> 想一下你最近一个月改得最多的模块是什么？
> 那个模块名就是你的第一个 Skill。

**示例**：
- Web 后端 → `payment-system`（支付系统）
- 游戏项目 → `character-controller`（角色控制器）
- 数据项目 → `etl-processor`（ETL 处理）

**如果无明确模块边界**：创建一个 `{项目名}-framework` 作为框架级 Skill，把整体架构知识放进去。后续按需拆分。

---

## 步骤 3: 创建第一个 Skill（20 分钟）

```bash
# 创建 Skill 目录
mkdir -p <你的项目>/.claude/skills/<skill-name>

# 复制模板
cp <sdd-init-skill-path>/templates/SKILL.template.md <你的项目>/.claude/skills/<skill-name>/SKILL.md
```

**填写 SKILL.md 的最小集**（仅需完成 3 个必选章节）：

### 1. Frontmatter
```yaml
---
name: payment-system
description: >
  支付系统专家。Use when the user asks to "debug payment",
  "fix callback", mentions "PaymentService", "RefundService".
  Also responds to "调试支付", "修复回调".
---
```

### 2. Overview（3-5 句话）
描述这个系统做什么、核心能力是什么。

### 3. Core Rules（3-5 条）
写下开发这个模块最容易犯的错误。格式：`错误做法 → 正确做法`。

### 4. Reference Files
列出核心文件路径。

**删除所有不需要的可选章节和注释**，保持简洁。

---

## 步骤 4: 测试 Skill 发现（5 分钟）

1. 在项目目录下启动 Claude Code
2. 输入与 Skill 相关的问题，例如："帮我看看支付回调的问题"
3. 观察 Claude 是否自动加载了你的 Skill 内容

**如果没有触发**：
- 检查 SKILL.md 是否位于 `.claude/skills/<name>/SKILL.md`
- 检查 frontmatter 的 `description` 是否包含你使用的关键词
- 尝试直接使用 `/<skill-name>` 手动触发
- 运行 `What skills are available?` 确认 Skill 被识别

---

## 步骤 5: [可选] 生成 Skill 索引（5 分钟）

```bash
python <sdd-init-skill-path>/scripts/generate-skill-index.py \
  <你的项目>/.claude/skills \
  <你的项目>/CLAUDE.local.md
```

这会在 CLAUDE.local.md 的 `<!-- SKILL-INDEX-START -->` 标记处自动生成索引表。

---

## 后续步骤

- **添加更多 Skill**：重复步骤 2-4，逐步覆盖更多模块
- **完善 Skill 内容**：在实际使用中发现 AI 需要更多上下文时，补充可选章节
- **运行健康报告**：`python <sdd-init-skill-path>/scripts/generate-health-report.py <skills-dir>`
- **了解生命周期管理**：阅读 sdd-init skill 内的 `guides/skill-lifecycle.md`

---

## 常见问题

**Q: 应该一次性创建多少个 Skill？**
A: 从 1 个开始。用了一周后再考虑拆分第二个。参考：小项目 1-3 个，中项目 5-10 个。

**Q: SKILL.md 应该写多长？**
A: 必选部分建议 100-200 行。官方建议整体不超过 500 行。过长的参考资料移到 `references/` 目录。

**Q: 改了代码一定要同步 Skill 吗？**
A: 不一定。只有外部接口变化（API 签名、参数、默认值等）才需要同步。内部 Bug 修复和性能优化可跳过。详见 CLAUDE.local.md 中的 Sync 规则表。

**Q: 没有 Python 环境怎么办？**
A: 索引脚本和健康报告是可选工具。核心功能（CLAUDE.local.md + SKILL.md）不依赖任何脚本，可以完全手动维护。
