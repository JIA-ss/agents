# Codex Integration

## 调用模板

```bash
# 从文件读取 prompt，输出保存到文件
TASK_DIR=".tasks/self-review/${TASK_NAME}"
ROUND=1

# 使用环境变量或默认模型
CODEX_MODEL="${CODEX_MODEL:-gpt-5.2-codex}"

# 使用 -o 选项只输出最终的 agent 响应（不包含执行日志）
codex exec -m "$CODEX_MODEL" \
  --config model_reasoning_effort="xhigh" \
  --sandbox danger-full-access \
  --full-auto \
  --skip-git-repo-check \
  -o "${TASK_DIR}/reviews/round-${ROUND}/review-response.md" \
  "$(cat ${TASK_DIR}/reviews/round-${ROUND}/review-prompt.md)"
```

**重要**：使用 `-o` (--output-last-message) 选项而不是 shell 重定向 `>`，这样只会输出 agent 的最终响应，不包含执行日志和 thinking 过程。

## 为什么使用 Codex

1. **上下文隔离**：Codex 不共享当前会话上下文
2. **独立推理**：使用 xhigh reasoning effort 确保深度分析
3. **客观评估**：不受执行者思路影响
4. **文件化交互**：prompt 和 response 都以文件形式保存

## 配置参数

| 参数 | 默认值 | 环境变量 | 说明 |
|------|--------|----------|------|
| model | gpt-5.2-codex | `CODEX_MODEL` | Codex 模型 ID |
| reasoning_effort | xhigh | - | 最高推理强度 |
| sandbox | danger-full-access | - | 沙箱权限级别 |
| full-auto | enabled | - | 自动执行模式 |

## 模型版本说明

模型 ID 可能随 OpenAI 发布新版本而变化。建议：

1. **通过环境变量配置**：`export CODEX_MODEL=gpt-5.2-codex`
2. **查看可用模型**：`codex --list-models`
3. **更新频率**：每季度检查一次模型可用性

## 成本估算

| 模型 | 输入价格 | 输出价格 | 单轮估算 |
|------|----------|----------|----------|
| gpt-5.2-codex | 按 OpenAI 定价 | 按 OpenAI 定价 | ~$0.15-0.50 |

> 实际成本取决于任务复杂度和代码量。建议初次使用时监控成本。
