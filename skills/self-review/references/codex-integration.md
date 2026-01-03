# Codex Integration

## 调用模板

```bash
# 从文件读取 prompt，输出保存到文件
TASK_DIR=".tasks/self-review/${TASK_NAME}"
ROUND=1

codex exec -m gpt-5.2-codex \
  --config model_reasoning_effort="xhigh" \
  --sandbox danger-full-access \
  --full-auto \
  --skip-git-repo-check \
  "$(cat ${TASK_DIR}/reviews/round-${ROUND}/review-prompt.md)" \
  > "${TASK_DIR}/reviews/round-${ROUND}/review-response.md" 2>/dev/null
```

## 为什么使用 Codex

1. **上下文隔离**：Codex 不共享当前会话上下文
2. **独立推理**：使用 xhigh reasoning effort 确保深度分析
3. **客观评估**：不受执行者思路影响
4. **文件化交互**：prompt 和 response 都以文件形式保存

## 配置参数

| 参数 | 值 | 说明 |
|------|-----|------|
| model | gpt-5.2-codex | 使用 Codex 模型 |
| reasoning_effort | xhigh | 最高推理强度 |
| sandbox | danger-full-access | 完全访问权限 |
| full-auto | enabled | 自动执行模式 |
