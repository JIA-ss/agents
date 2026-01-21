---
name: codex
description: 调用 OpenAI Codex CLI 进行代码分析、重构或自动化编辑。当用户要求运行 Codex CLI（codex exec, codex resume）或提及使用 OpenAI Codex 进行代码分析、重构或自动化编辑时使用。
---

# Codex

OpenAI Codex CLI 集成：PARSE → VALIDATE → EXECUTE → REPORT

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户输入，识别 Codex 命令类型（exec / resume）
2. 提取命令参数和提示词
3. 开始 Phase 1: PARSE

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: PARSE → 解析命令和参数
- [ ] Phase 2: VALIDATE → 验证环境和参数
- [ ] Phase 3: EXECUTE → 执行 Codex 命令
- [ ] Phase 4: REPORT → 输出执行结果
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| PARSE | 命令和参数已解析 | → VALIDATE |
| VALIDATE | 环境检查通过 | → EXECUTE |
| EXECUTE | 命令已执行 | → REPORT |
| REPORT | 结果已输出 | → 结束 |

---

## Phase 详情

### Phase 1: PARSE（解析命令）

**你必须：**
1. 识别命令类型：
   - `codex exec <prompt>` - 执行新任务
   - `codex resume` - 恢复上一会话
2. 提取提示词内容
3. 识别可选参数（-C 目录等）

**完成标志**: 命令和参数已解析

---

### Phase 2: VALIDATE（验证环境）

**你必须：**
1. 确认将使用的固定配置参数
2. 如指定目录（-C），验证目录存在

**固定配置（不可修改）**:
- Model: `gpt-5.2-codex`
- Reasoning: `xhigh`
- Sandbox: `danger-full-access`
- Mode: `--full-auto`

**完成标志**: 参数验证通过

---

### Phase 3: EXECUTE（执行命令）

**你必须：**
1. 组装完整命令
2. 使用 Bash 工具执行
3. 追加 `2>/dev/null` 抑制 thinking tokens

**命令模板**:
```bash
# 标准执行
codex exec -m gpt-5.2-codex --config model_reasoning_effort="xhigh" --sandbox danger-full-access --full-auto --skip-git-repo-check "prompt" 2>/dev/null

# 恢复会话
echo "prompt" | codex exec --skip-git-repo-check resume --last 2>/dev/null
```

**完成标志**: 命令已执行

---

### Phase 4: REPORT（输出结果）

**你必须：**
1. 格式化输出执行结果
2. 如有代码变更，展示关键 diff
3. 如有错误，提供排查建议
4. 告知用户可随时说 "codex resume" 恢复会话

**完成标志**: 结果已输出

---

## 命令参考

| 场景 | 命令 |
|------|------|
| 标准执行 | `codex exec -m gpt-5.2-codex --config model_reasoning_effort="xhigh" --sandbox danger-full-access --full-auto --skip-git-repo-check "prompt" 2>/dev/null` |
| 指定目录 | 添加 `-C <DIR>` |
| 恢复会话 | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` |

---

## 错误处理

- 命令非零退出 → 停止并报告，请求用户指示
- 部分结果/警告 → 汇总并通过 AskUserQuestion 询问下一步
