---
name: codex
description: 调用 OpenAI Codex CLI 进行代码分析、重构或自动化编辑。当用户要求运行 Codex CLI（codex exec / codex resume / codex review）或提及使用 Codex 进行代码审查、重构、自动化编辑时使用。
---

# Codex

用 OpenAI Codex CLI 做一次性非交互任务：**PARSE → VALIDATE → EXECUTE → REPORT**。

> 目标：无头模式执行代码任务，使用 `-o` 输出结果，自动收集并返回。

---

## ✅ Checklist（逐项完成）

```
- [ ] Phase 1: PARSE → 解析命令和参数
- [ ] Phase 2: VALIDATE → 验证环境/目录/参数
- [ ] Phase 3: EXECUTE → 执行 Codex 命令（无头模式）
- [ ] Phase 4: REPORT → 输出结果（必要时附关键 diff/文件路径）
```

---

## Phase 1: PARSE（解析命令）

你必须：
1) 识别用户意图：
   - 代码审查：`codex exec review`
   - 新任务：`codex exec "<prompt>"`
   - 恢复会话：`codex resume --last`
2) 提取可选参数：
   - 工作目录：`-C/--cd <DIR>`
   - 输出文件：`-o <FILE>`（建议总是使用）
   - 模型选择：`-m/--model <model-name>`（见下方模型列表）
3) **如果用户未指定模型**，使用默认模型 `gpt-5.2-codex`。
   > 注意：`gpt-5.2-codex-high` 和 `gpt-5.2-codex-xhigh` 需要 OpenAI Pro 账户。

**完成标志**：命令、prompt、工作目录、模型都明确。

---

## Phase 2: VALIDATE（验证环境）

你必须：
1) 如果指定目录（-C/--cd），验证目录存在。
2) 确认 codex 可执行：`codex --version`
3) **Git 仓库要求**：Codex 默认要求在 git 仓库内运行。
   - 优先在目标 repo 里运行
   - 仅在确实需要时才用 `--skip-git-repo-check`

**默认参数建议**（可按场景调整）：
- 无头模式：`exec --full-auto`
- 输出文件：`-o <OUT_FILE>`（必须使用）

**权限控制选项**：
| 选项 | 作用 |
|------|------|
| `--full-auto` | 自动审批 + workspace-write（推荐） |
| `--sandbox read-only` | 只读模式 |
| `--sandbox workspace-write` | 允许写工作区 |
| `--sandbox danger-full-access` | 完全访问（危险，需明确理由） |

**完成标志**：目录/参数检查通过，能开始执行。

---

## Phase 3: EXECUTE（执行命令）

关键要求：
- **必须使用** `-o/--output-last-message <FILE>` 保存最终回答。
- **必须使用** `--full-auto` 进入无头模式。
- **不要用** `2>/dev/null`（会吞掉输出）。
- **使用 PowerShell** 执行命令（Windows 环境）。

### 命令模板

**代码审查**：
```bash
# 审查当前仓库
codex exec review --full-auto -o "<OUT_FILE>"
```

**一般任务**：
```bash
# 执行任务
codex exec --full-auto -o "<OUT_FILE>" "<PROMPT>"

# 指定工作目录
codex exec --full-auto -C "<DIR>" -o "<OUT_FILE>" "<PROMPT>"
```

**恢复会话**：
```bash
codex resume --last
```

执行后：
- 读取 `<OUT_FILE>` 内容并回传（REPORT）。
- 如果命令失败：保留 stderr/stdout，用于排错。

**完成标志**：命令已执行，且能拿到输出结果。

---

## Phase 4: REPORT（输出结果）

你必须：
1) 返回 Codex 的最终回答（来自 `-o` 输出文件）。
2) 如果产生代码变更：摘要 + 关键 diff（或变更文件列表）。
3) 如果报错或卡住：给出可操作的排查建议。
4) 提醒用户可用：`codex resume --last` 继续。

---

## 常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 无头模式卡住 | 缺少 `--full-auto` | 添加 `--full-auto` |
| 输出为空 | 未使用 `-o` | 添加 `-o <OUT_FILE>` |
| 目录拒绝 | 不在 git repo | 使用 `--skip-git-repo-check`（谨慎） |
| 超时 | 长任务 | 使用后台执行 + 延长超时 |
| 命令未找到 | codex 未安装 | 运行 `npm install -g @openai/codex` |

---

## 模型选择

**可用模型列表：**

| 模型 | `-m` 参数 | 账户要求 | 特点 |
|------|-----------|----------|------|
| GPT-5.2 Codex | `gpt-5.2-codex` | ChatGPT Plus | 代码专用模型（默认） |
| GPT-5.2 Codex High | `gpt-5.2-codex-high` | OpenAI Pro | 高性能版本 |
| GPT-5.2 Codex XHigh | `gpt-5.2-codex-xhigh` | OpenAI Pro | 超高性能版本 |

> **注意**：ChatGPT Plus 账户只能使用默认的 `gpt-5.2-codex` 模型。High 和 XHigh 版本需要 OpenAI Pro 账户。

**使用示例：**

```bash
# 使用默认模型（ChatGPT Plus 账户）
codex exec --full-auto -o result.md "<PROMPT>"

# 使用 High 版本（需要 Pro 账户）
codex exec review --full-auto -m gpt-5.2-codex-high -o review.md
```

---

## 典型用例

### 1. 代码审查（Code Review）

```bash
# 审查当前仓库
codex exec review --full-auto -o review.md
```

### 2. Bug 修复

```bash
codex exec --full-auto -o fix.md "fix the null pointer in auth.js"
```

### 3. 代码重构

```bash
codex exec --full-auto -o refactor.md "refactor UserService to use DI"
```

### 4. 恢复会话

```bash
codex resume --last
```
