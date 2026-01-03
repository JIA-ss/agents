---
name: self-review
description: Use when the user asks for "self-supervised execution", "iterative review", "auto-improve", "review loop", "quality assurance loop", mentions "self-correction", "independent review", or needs AI to execute tasks with self-review and improvement cycles. Also responds to "自我监督", "迭代审查", "自我修正", "质量循环", "自动改进".
---

# Self-Review Skill Guide

## Overview

自我监督自我修改的执行框架，通过独立Reviewer（Codex）对执行结果进行严格审查，形成"执行→审查→改进"的闭环，直到任务通过评估才交付。

**核心价值**：独立审查 + 信息隔离 + 理论驱动 + 迭代改进 + 质量保证

## Workflow (6 Phases)

```
┌─────────────────────────────────────────────────────────┐
│  Phase 1: Task Confirmation                             │
│  ├── 解析用户提示词                                      │
│  ├── 确认任务目标和边界                                   │
│  └── 输出: 任务规范文档                                   │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Phase 2: Task Execution                                │
│  ├── 执行任务                                            │
│  └── 输出: 执行结果 + 变更清单                            │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Phase 3: Independent Review (Codex)                    │
│  ├── 构建隔离式Review Prompt（见下方规则）                │
│  ├── 调用Codex进行独立审查                                │
│  └── 输出: 结构化Review报告                               │
└────────────────────────┬────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────┐
│  Phase 4: Review Analysis                               │
│  ├── 解析Review报告                                      │
│  ├── 分类问题（严重/中等/轻微）                           │
│  └── 判断: PASS / NEEDS_IMPROVEMENT / REJECTED          │
└────────────────────────┬────────────────────────────────┘
                         ▼
          ┌──────────────┴──────────────┐
          ▼                             ▼
    ┌──────────┐                 ┌──────────────┐
    │   PASS   │                 │ NEEDS_IMPROVE│
    └────┬─────┘                 │ / REJECTED   │
         │                       └──────┬───────┘
         ▼                              │
┌─────────────────┐                     ▼
│  Phase 6:       │       ┌─────────────────────────┐
│  Delivery       │       │  Phase 5: Improvement   │
│  结果交付        │       │  ├── 执行修复            │
└─────────────────┘       │  └── 回到 Phase 3       │
                          └─────────────────────────┘
```

## Review Information Isolation Rules

### 给Reviewer的输入（仅限）

| 信息类型 | 说明 | 示例 |
|---------|------|------|
| 原始问题描述 | 用户最初的任务需求 | "实现用户登录功能" |
| 最终结果 | 代码变更、文件列表 | git diff 输出 |
| 工程上下文 | 相关代码文件内容 | 被修改的文件 |

### 禁止传递给Reviewer的信息

| 禁止内容 | 原因 |
|---------|------|
| 执行思路 | 避免干扰Reviewer独立判断 |
| 中间过程 | Reviewer应只关注结果 |
| 自我评价 | 防止先入为主 |
| 方案解释 | Reviewer应自己分析意图 |

### Review Prompt Template

```
你是一个严格的代码审查者。现在需要你独立评估以下任务的执行结果。

## 原始任务
{task_description}

## 当前工程状态
{project_context}

## 变更内容
{git_diff_or_changes}

## 审查要求
1. **优先质疑方案**：首先判断整体方案是否正确，有无严重设计错误
2. **理论依据**：所有判断必须基于明确的理论/最佳实践，不可主观臆断
3. **独立思考**：不要假设执行者的意图，只基于代码和需求判断

## 输出格式
- VERDICT: PASS / NEEDS_IMPROVEMENT / REJECTED
- CRITICAL_ISSUES: [严重问题列表，立即指出]
- IMPROVEMENTS: [改进建议列表]
- REASONING: [判断依据，必须引用具体理论或最佳实践]
```

## Review Standards

### 评判维度

| 维度 | 权重 | 通过标准 |
|------|------|---------|
| 方案合理性 | 40% | 无严重设计缺陷 |
| 实现正确性 | 30% | 功能符合需求 |
| 代码质量 | 20% | 符合工程规范 |
| 安全性 | 10% | 无明显安全漏洞 |

### 判定标准

| 判定 | 条件 |
|------|------|
| **PASS** | 无严重问题，轻微问题<3个 |
| **NEEDS_IMPROVEMENT** | 无严重问题，但有中等问题需修复 |
| **REJECTED** | 存在严重设计错误，需重新设计 |

### Reviewer必须遵守的原则

1. **质疑优先**：先假设方案有问题，再验证是否正确
2. **理论为本**：每个评判必须有明确依据（设计原则/最佳实践/文档规范）
3. **禁止臆造**：不确定的内容标记为"需要验证"，不可编造
4. **严重问题立即指出**：发现方案级错误时，终止其他检查，直接 REJECTED

## Loop Control

### 最大循环次数
- 默认: 3次
- 超过3次未通过时，暂停并请求用户介入

### 循环退出条件
| 条件 | 动作 |
|------|------|
| PASS | 进入交付阶段 |
| 循环>=3次 | 暂停，汇报问题，请求用户决策 |
| REJECTED连续2次 | 暂停，建议重新评估需求 |

## Execution Commands

### 启动自我监督任务
```
/self-review 执行并审查: {任务描述}
```

### 手动触发Review
```
/self-review --review-only
```

### 强制交付（跳过Review）
```
/self-review --force-deliver
```

## Integration with Codex

使用Codex作为独立Reviewer的原因：
1. **上下文隔离**：Codex不共享当前会话上下文
2. **独立推理**：使用xhigh reasoning effort确保深度分析
3. **客观评估**：不受执行者思路影响

Codex Review调用模板：
```bash
codex exec -m gpt-5.2-codex --config model_reasoning_effort="xhigh" \
  --sandbox danger-full-access --full-auto --skip-git-repo-check \
  "$(cat <<'REVIEW_PROMPT'
{review_prompt_content}
REVIEW_PROMPT
)" 2>/dev/null
```

## Best Practices

1. **任务粒度**：将大任务拆分为可独立审查的小任务
2. **清晰边界**：在Phase 1明确定义成功标准
3. **保留记录**：每轮Review结果存档，便于追溯
4. **渐进改进**：每轮只修复最严重的问题
5. **用户透明**：每轮循环后向用户汇报进度

## Output Artifacts

### 每轮循环输出
1. 执行结果摘要
2. Review报告
3. 判定结果（PASS/NEEDS_IMPROVEMENT/REJECTED）
4. 下一步计划

### 最终交付物
1. 完成的代码/文档变更
2. Review历史记录
3. 最终通过的Review报告
