---
name: codex
description: 调用 OpenAI Codex CLI 进行代码分析、重构或自动化编辑。当用户要求运行 Codex CLI（codex exec / codex resume / codex review）或提及使用 Codex 进行代码审查、重构、自动化编辑时使用。
---

# Codex

用 Codex CLI 做一次性非交互任务：**PARSE → VALIDATE → EXECUTE → REPORT**。

> 目标：让调用方“有响应”。不要用 `2>/dev/null` 吞输出；优先用 `-o/--output-last-message` 把最终回复落盘，再读出来回传。

---

## ✅ Checklist（逐项完成）

```
- [ ] Phase 1: PARSE → 解析命令和参数
- [ ] Phase 2: VALIDATE → 验证环境/目录/参数
- [ ] Phase 3: EXECUTE → 执行 Codex 命令（建议 PTY + 可后台）
- [ ] Phase 4: REPORT → 输出结果（必要时附关键 diff/文件路径）
```

---

## Phase 1: PARSE（解析命令）

你必须：
1) 识别用户意图：
   - 新任务：`codex exec "<prompt>"`
   - 恢复：`codex resume --last`（或用户指定会话 id）
   - 仓库审查：`codex exec review`（可选）
2) 提取可选参数：
   - 工作目录：`-C/--cd <DIR>`（或由调用方传入）
   - 输出文件：`-o <FILE>`（建议总是使用）

完成标志：命令、prompt、工作目录都明确。

---

## Phase 2: VALIDATE（验证环境）

你必须：
1) 如果指定目录（-C/--cd），验证目录存在。
2) 确认 codex 可执行：`codex --version`。
3) **Git 仓库要求**：Codex 默认要求在 git 仓库内运行。
   - 优先：在目标 repo 里运行（例如本机 `C:\Users\sunjiashuai\agents`）。
   - 仅在确实需要时才用 `--skip-git-repo-check`（否则容易让运行范围变大，不利于可控）。

建议默认参数（可按场景调整，不要强行“不可修改”）：
- Model: `gpt-5.2-codex`（或使用用户/环境默认）
- Sandbox:
  - 常规：`--full-auto`（等价于自动审批 + `--sandbox workspace-write`）
  - 高风险/需要全盘访问才用：`--sandbox danger-full-access`（需明确理由）

完成标志：目录/参数检查通过，能开始执行。

---

## Phase 3: EXECUTE（执行命令）

关键要求：
- **不要用** `2>/dev/null`（可能导致“没有任何输出”，调用方以为无响应）。
- **优先使用** `-o/--output-last-message <FILE>`：只保存最终回答，既干净又稳定。
- 在需要更稳定交互输出时（尤其长任务），用 **PTY** 运行。

命令模板（推荐）：

```bash
# 标准执行：把最终答复写到文件
codex exec --full-auto -m gpt-5.2-codex -o "<OUT_FILE>" "<PROMPT>"

# 指定工作目录
codex exec --full-auto -C "<DIR>" -m gpt-5.2-codex -o "<OUT_FILE>" "<PROMPT>"

# 恢复最近会话
codex resume --last
```

执行后：
- 读取 `<OUT_FILE>` 内容并回传（REPORT）。
- 如果命令失败：保留 stderr/stdout，用于排错，不要吞。

完成标志：命令已执行，且能拿到最终输出（stdout 或 OUT_FILE）。

---

## Phase 4: REPORT（输出结果）

你必须：
1) 返回 Codex 的最终回答（优先来自 `-o` 输出文件）。
2) 如果产生代码变更：摘要 + 关键 diff（或指出变更文件列表/路径）。
3) 如果报错或卡住：给出可操作的排查建议（例如：是否需要 PTY、是否在 git repo、是否需要延长超时/改后台执行）。
4) 提醒用户可用：`codex resume --last` 继续。

---

## 常见“无响应”原因（优先排查）

1) `2>/dev/null` 把错误/进度/输出吞掉了（最常见）
2) 未使用 `-o`，而调用方只采集了最终消息（导致看起来空）
3) 运行目录不是 git repo，Codex 直接拒绝/退出
4) 长任务被执行器超时切断（需要后台 + process 跟踪）
5) 交互型输出在非 PTY 环境表现异常（建议 pty:true）
