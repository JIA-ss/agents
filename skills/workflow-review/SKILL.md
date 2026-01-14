---
name: workflow-review
description: 独立审查代码实现质量。使用独立 Agent 进行审查，支持迭代改进直到通过。当用户想要"审查代码"、"质量检查"、"代码评审"时使用。也响应 "workflow review"、"工作流审查"。
---

# Review Skill 指南

## 概述

使用独立 Agent 对代码实现进行审查，形成"执行→审查→改进"的闭环，确保代码质量。

**核心价值**：独立审查 + 信息隔离 + 迭代改进 + 质量保证

---

## 工作流程

```
收集证据 → 独立审查 → 分析结果 → 改进/交付
    │           │           │          │
    ▼           ▼           ▼          ▼
evidence/  review-response  verdict   final-report
```

### 阶段 1: 证据收集

**动作**:
1. 读取 `.workflow/{feature}/implement/logs/`
2. 收集代码变更
3. 运行测试和 lint
4. 生成证据包

### 阶段 2: 独立审查

**动作**:
1. 使用 Task 工具启动独立审查 Agent
2. 审查代码质量、测试覆盖、规范合规
3. 生成审查报告

### 阶段 3: 结果分析

**动作**:
1. 解析审查报告
2. 分类问题严重程度
3. 判定结果（PASS/NEEDS_IMPROVEMENT/REJECTED）

### 阶段 4: 改进/交付

**动作**:
- **PASS**: 生成最终报告，完成工作流
- **NEEDS_IMPROVEMENT**: 返回实现阶段修复
- **REJECTED**: 中止并提示用户

**输出**: `.workflow/{feature}/review/`

---

## 命令

```bash
# 基本用法
/workflow-review {feature}

# 仅审查不改进
/workflow:review --check-only {feature}

# 恢复审查
/workflow:review --resume {feature}
```

---

## 输出结构

```
.workflow/{feature}/review/
├── evidence/
│   ├── test-results.txt
│   ├── lint-results.txt
│   └── changes.diff
├── reviews/
│   └── round-{N}/
│       ├── review-prompt.md
│       └── review-response.md
└── final-report.md
```

---

## 审查清单

1. **代码质量**
   - 代码符合项目规范
   - 无明显的代码异味
   - 适当的错误处理

2. **测试覆盖**
   - 所有新功能有测试
   - 测试通过率 100%
   - 覆盖正向/负向/边界场景

3. **规范合规**
   - 实现符合 spec.md 需求
   - 满足所有验收标准
   - 无遗漏功能

---

## 严重程度定义

| 级别 | 定义 | 处理 |
|------|------|------|
| **BLOCKER** | 阻止合并（安全漏洞、测试失败） | 必须修复 |
| **CRITICAL** | 影响核心功能 | >2个则 REJECTED |
| **MAJOR** | 影响可维护性 | >5个则 NEEDS_IMPROVEMENT |
| **MINOR** | 可选优化 | 不影响判定 |

---

## 判定规则

```yaml
PASS:
  - blocker_count == 0
  - critical_count == 0
  - major_count <= 5

NEEDS_IMPROVEMENT:
  - blocker_count == 0
  - critical_count IN [1, 2] OR major_count > 5

REJECTED:
  - blocker_count > 0 OR critical_count > 2
  - OR tests_passed == false
```

---

## 循环控制

| 配置 | 默认值 | 说明 |
|------|--------|------|
| max_rounds | 3 | 最大审查轮次 |
| consecutive_reject_limit | 2 | 连续 REJECTED 次数限制 |
| early_exit_confidence | 0.9 | 早期退出置信度阈值 |

---

## 最终报告模板

```markdown
# 审查报告: {feature}

## 概要
- **判定**: PASS
- **审查轮次**: 2
- **置信度**: 0.95

## 审查历史

### Round 1
- 判定: NEEDS_IMPROVEMENT
- 问题: 3 MAJOR, 2 MINOR
- 修复: 已修复 3 MAJOR

### Round 2
- 判定: PASS
- 问题: 0 MAJOR, 1 MINOR

## 最终状态
- 测试: 全部通过 (42/42)
- Lint: 无错误
- 覆盖率: 85%

## 建议
{可选的改进建议}
```

---

## 集成

- **输入**: `/workflow-implement` 生成的代码变更
- **输出**: 审查报告，工作流结束

---

*待完整实现*
