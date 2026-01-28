---
name: copilot
description: 调用 GitHub Copilot CLI 进行代码审查、问题修复或自动化编辑。当用户要求运行 Copilot CLI（copilot -p / copilot --resume / copilot /review）或提及使用 Copilot 进行代码审查、问题修复、自动化编辑时使用。Also responds to "copilot review", "copilot 审查"。
---

# Copilot

用 GitHub Copilot CLI 做一次性非交互任务：**PARSE → VALIDATE → EXECUTE → REPORT**。

> 目标：无头模式（`-p/--prompt`）执行代码审查或任务，自动收集输出并返回结果。

---

## ✅ Checklist（逐项完成）

```
- [ ] Phase 1: PARSE → 解析命令和参数
- [ ] Phase 2: VALIDATE → 验证环境/目录/参数
- [ ] Phase 3: EXECUTE → 执行 Copilot 命令（无头模式）
- [ ] Phase 4: REPORT → 输出结果（必要时附关键 diff/文件路径）
```

---

## Phase 1: PARSE（解析命令）

你必须：
1) 识别用户意图：
   - 代码审查：`copilot -p "/review"` 或 `copilot -p "review the code changes"`
   - 新任务：`copilot -p "<prompt>"`
   - 恢复会话：`copilot --continue` 或 `copilot --resume [sessionId]`
2) 提取可选参数：
   - 工作目录：任务执行的目标目录
   - 权限控制：`--allow-all-tools` / `--allow-tool` / `--deny-tool`
   - 输出选项：`-s/--silent`（仅输出响应）、`--share`（保存为 markdown）
   - 模型选择：`--model <model-name>`（见下方模型列表）
3) **如果用户未指定模型**，询问用户选择：
   - claude-opus-4.5（Anthropic 旗舰）
   - claude-sonnet-4.5（Anthropic 平衡，默认）
   - gpt-5.2（OpenAI 高性能）
   - gemini-3-pro-preview（Google 专业版）

**完成标志**：命令、prompt、工作目录都明确。

---

## Phase 2: VALIDATE（验证环境）

你必须：
1) 如果指定目录，验证目录存在。
2) 确认 copilot 可执行：
   - **Windows 环境**：`copilot --version`（PowerShell 或 cmd）
   - **其他环境**：`copilot --version`
3) **Git 仓库建议**：Copilot 在 git 仓库内运行效果更佳（可访问 git 上下文）。

**默认参数建议**（可按场景调整）：
- 无头模式：`-p "<prompt>"` + `--allow-all-tools`（或 `--yolo`）
- 安静模式：`-s/--silent`（仅输出响应，适合脚本集成）
- 保存会话：`--share <path>`（保存为 markdown）

**权限控制选项**：
| 选项 | 作用 |
|------|------|
| `--allow-all-tools` | 允许所有工具自动执行（无头模式必需） |
| `--allow-all` / `--yolo` | 允许所有权限（工具+路径+URL） |
| `--allow-tool 'write'` | 允许文件编辑 |
| `--allow-tool 'shell(git:*)'` | 允许所有 git 命令 |
| `--deny-tool 'shell(rm)'` | 禁止 rm 命令 |

**完成标志**：目录/参数检查通过，能开始执行。

---

## Phase 3: EXECUTE（执行命令）

关键要求：
- **必须使用** `-p/--prompt` 进入无头模式（非交互式执行）。
- **必须使用** `--allow-all-tools` 或 `--yolo`（否则无头模式会因权限问题卡住）。
- **建议使用** `-s/--silent` 获取干净输出。
- **可选使用** `--share <file.md>` 保存完整会话。

### 命令模板

**代码审查（推荐）**：
```bash
# 审查当前目录的代码变更（使用默认模型）
copilot -p "/review" --allow-all-tools -s

# 审查并保存报告（指定 GPT-5.2）
copilot -p "/review" --model gpt-5.2 --allow-all-tools --share review-report.md

# 深度审查（使用 Opus 4.5）
copilot -p "/review" --model claude-opus-4.5 --allow-all-tools -s
```

**一般任务**：
```bash
# 执行任务（允许所有工具，默认模型）
copilot -p "<PROMPT>" --allow-all-tools -s

# 使用 GPT-5.2
copilot -p "<PROMPT>" --model gpt-5.2 --yolo -s

# 使用 Gemini 3 Pro
copilot -p "<PROMPT>" --model gemini-3-pro-preview --allow-all-tools -s
```

**恢复会话**：
```bash
# 恢复最近会话
copilot --continue

# 恢复指定会话
copilot --resume <sessionId>
```

**Windows 特殊情况**：
如果 `copilot` 命令无输出，尝试：
```powershell
# PowerShell
copilot -p "<PROMPT>" --allow-all-tools -s
```

执行后：
- 收集 stdout 输出并回传（REPORT）。
- 如果使用 `--share`：读取生成的 markdown 文件。
- 如果命令失败：保留 stderr/stdout，用于排错。

**完成标志**：命令已执行，且能拿到输出结果。

---

## Phase 4: REPORT（输出结果）

你必须：
1) 返回 Copilot 的审查结果或任务响应。
2) 如果产生代码变更：摘要 + 关键 diff（或指出变更文件列表/路径）。
3) 如果报错或卡住：给出可操作的排查建议。
4) 提醒用户可用：`copilot --continue` 继续最近会话。

---

## 常见问题排查

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 无头模式卡住 | 缺少 `--allow-all-tools` | 添加 `--allow-all-tools` 或 `--yolo` |
| 无输出 | 未使用 `-s` 且输出被截断 | 添加 `-s/--silent` 或 `--share` |
| 权限拒绝 | 工具未授权 | 使用 `--allow-tool` 授权特定工具 |
| 会话中断 | 网络或超时 | 使用 `copilot --continue` 恢复 |
| 找不到命令 | copilot 未安装或不在 PATH | 运行 `npm install -g @anthropic-ai/copilot` 或参考 [GitHub Copilot CLI](https://github.com/github/copilot-cli) |

---

## 模型选择

**可用模型列表：**

| 模型 | `--model` 参数 | 特点 |
|------|----------------|------|
| GPT-5.2 | `gpt-5.2` | OpenAI 高性能模型 |
| GPT-5.2 Codex | `gpt-5.2-codex` | OpenAI 代码专用模型 |
| Opus 4.5 | `claude-opus-4.5` | Anthropic 旗舰模型，深度分析能力强 |
| Sonnet 4.5 | `claude-sonnet-4.5` | Anthropic 平衡模型（默认） |
| Gemini 3 Pro | `gemini-3-pro-preview` | Google 专业版预览 |
| 默认 | 不指定 | Copilot 默认模型 |

**使用示例：**

```bash
# 使用 GPT-5.2 进行代码审查
copilot -p "/review" --model gpt-5.2 --allow-all-tools -s

# 使用 Opus 4.5 进行深度分析
copilot -p "analyze the architecture of this codebase" --model claude-opus-4.5 --allow-all-tools -s

# 使用 Gemini 3 Pro
copilot -p "explain this code" --model gemini-3-pro-preview --allow-all-tools -s
```

---

## 典型用例

### 1. 代码审查（Code Review）

```bash
# 审查 staged 变更
copilot -p "/review" --allow-all-tools -s

# 审查特定文件
copilot -p "review src/main.ts for potential bugs" --allow-all-tools -s

# 审查并生成报告
copilot -p "/review" --allow-all-tools --share code-review.md
```

### 2. Bug 修复

```bash
copilot -p "fix the null pointer exception in auth.js" --yolo -s
```

### 3. 代码重构

```bash
copilot -p "refactor the UserService class to use dependency injection" --yolo -s
```

### 4. 自动化测试

```bash
copilot -p "write unit tests for the PaymentProcessor class" --allow-tool 'write' -s
```
