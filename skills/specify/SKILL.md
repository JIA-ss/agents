---
name: specify
description: 将模糊的用户需求转化为结构化的 spec.md 规范文档。当用户想要定义功能、编写需求、创建规范，或提到"需求"、"规范"、"spec"、"用户故事"时使用。支持 mini/standard/full 三种模式。
---

# Specify Skill 指南

## 概述

通过 5 阶段流程将模糊的用户需求转化为 AI 可执行的结构化规范：CAPTURE（捕获）→ CLARIFY（澄清）→ STRUCTURE（结构化）→ REVIEW（审查）→ VALIDATE（验证）。

**核心价值**：确保需求在实现前是完整的、无歧义的、可追溯的。

---

## 工作流程

```
CAPTURE → CLARIFY → STRUCTURE → REVIEW → VALIDATE
  捕获      澄清      结构化      审查      验证
    │         │          │          │         │
    ▼         ▼          ▼          ▼         ▼
raw-notes  clarified   spec.md   spec.md   spec.md
   .md       .md       (草稿)    (已审查)  (已批准)
```

### 阶段 1: CAPTURE（捕获）

**目标**: 收集和理解原始需求

**动作**:
1. 读取项目上下文（CLAUDE.md, constitution.md 如果存在）
2. 扫描现有代码库结构
3. 识别利益相关者和用户角色
4. 提取原始需求（功能性、非功能性、约束条件）
5. 计算 ambiguity_score 并列出待澄清问题

**输出**: `.agent/specs/{feature}/capture/raw-notes.md`

### 阶段 2: CLARIFY（澄清）

**目标**: 消除歧义，确认假设

**动作**:
1. 检测模糊词汇（"快速"、"简单"、"友好"、"fast"、"simple"）
2. 生成澄清问题并提供推荐默认值
3. 使用 AskUserQuestion 工具解决歧义
4. 记录决策和已确认的假设

**跳过条件**: 如果 ambiguity_score == 0 且无待澄清问题

**输出**: `.agent/specs/{feature}/clarify/clarified.md`

### 阶段 3: STRUCTURE（结构化）

**目标**: 将澄清后的需求转化为标准格式

**动作**:
1. 编写用户故事（As a/I want/So that 格式）
2. 应用 INVEST 原则检查
3. 为每个故事定义 3-7 个验收标准
4. 对需求进行分类（FR/NFR）并设置优先级
5. 定义范围边界（Out of Scope 章节）

**输出**: `.agent/specs/{feature}/spec.md`（草稿）

### 阶段 4: REVIEW（审查）

**目标**: 独立审查，确保规范质量

**动作**:
1. 使用 Task 工具启动独立审查 Agent（信息隔离）
2. 审查 Agent 检查规范完整性和一致性
3. 生成审查报告（PASS/NEEDS_IMPROVEMENT/REJECTED）
4. 如果 NEEDS_IMPROVEMENT，返回 STRUCTURE 阶段修复
5. 记录审查结果到 `reviews/round-{N}/`

**独立上下文**: 审查 Agent 通过 Task 工具调用，拥有独立的上下文，不会污染当前对话。

**审查清单**:
- 用户故事格式是否正确
- 验收标准是否覆盖正向/负向/边界场景
- NFR 是否可量化
- 是否存在模糊词汇
- 需求间是否存在冲突

**输出**: `.agent/specs/{feature}/reviews/round-{N}/review-response.md`

### 阶段 5: VALIDATE（验证）

**目标**: 最终验证，获取用户批准

**动作**:
1. 运行完整性检查（所有必填章节已填写）
2. 运行一致性检查（无冲突、术语一致）
3. 运行可行性检查（技术、资源、时间约束）
4. 展示验证结果和建议
5. 通过 AskUserQuestion 请求用户批准
6. 更新 spec 状态为 "approved"

**输出**: `.agent/specs/{feature}/spec.md`（已批准）

---

## 命令

```bash
# 基本用法
/specify {需求描述}

# 模板模式
/specify --mode=mini {描述}     # 简单任务
/specify --mode=standard {描述} # 默认，中等功能
/specify --mode=full {描述}     # 大型功能

# 交互模式
/specify --interactive {描述}   # 默认：每阶段暂停确认
/specify --guided {描述}        # AI 提供建议，用户选择
/specify --auto {描述}          # AI 决策，仅最终批准

# 恢复或验证
/specify --resume {spec-id}
/specify --validate {spec-id}

# 单阶段执行
/specify capture {描述}
/specify clarify {spec-id}
/specify structure {spec-id}
/specify review {spec-id}
/specify validate {spec-id}
```

**选项**:

| 选项 | 默认值 | 说明 |
|------|--------|------|
| `--mode` | standard | 模板规模：mini/standard/full |
| `--interactive` | 是 | 每阶段暂停等待用户确认 |
| `--guided` | 否 | AI 提供选项，用户选择 |
| `--auto` | 否 | AI 做所有决策，仅最终批准 |

---

## 模板模式

| 模式 | 必需章节 | 适用场景 |
|------|----------|----------|
| **mini** | 1（概述）、3（用户故事）、7（范围外）、9（清单） | Bug 修复、小改动 |
| **standard** | 1-7、9 | 中等功能（默认） |
| **full** | 全部（1-9、附录 A-C） | 大型功能、新项目 |

---

## 输出结构

```
.agent/specs/{feature}/
├── capture/
│   └── raw-notes.md       # 阶段 1 输出
├── clarify/
│   └── clarified.md       # 阶段 2 输出
├── reviews/
│   └── round-{N}/         # 阶段 4 审查记录
│       ├── review-prompt.md
│       └── review-response.md
├── spec.md                # 最终规范
└── .state.yaml            # 进度跟踪
```

---

## 验证规则

用户故事必须遵循格式：
```
作为 {角色}，
我想要 {动作}，
以便 {收益}。
```

每个故事需要 3-7 个验收标准，覆盖：
- 正向场景
- 负向场景
- 边界条件

NFR 必须可量化（如"API P95 < 200ms"，而非"快速响应"）。

禁止词汇（除非量化）：快速、简单、容易、友好、直观、健壮、可扩展、fast、quick、simple、easy、user-friendly、intuitive、robust、scalable

---

## 状态管理

进度保存到 `.state.yaml`。如果中断：
- 使用 `/specify --resume {spec-id}` 继续
- 状态包含：当前阶段、已完成阶段、输出文件

---

## 集成

输出的 spec.md 被以下 skill 使用：
- `/plan {feature}` - 创建技术计划
- `/tasks {feature}` - 生成任务分解

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 完整模板 | [assets/spec-template.md](assets/spec-template.md) | standard/full 模式的 spec.md 模板 |
| 精简模板 | [assets/spec-mini.md](assets/spec-mini.md) | mini 模式的 spec.md 模板 |
| 验证脚本 | [scripts/validate-spec.sh](scripts/validate-spec.sh) | 验证 spec 完整性 |
| 阶段参考 | [references/phase-details.md](references/phase-details.md) | 详细阶段文档 |

### 资源使用

**验证脚本**:
```bash
./scripts/validate-spec.sh <spec-file> [mode]
# mode: mini | standard | full（默认：standard）
# 返回：PASSED 或 FAILED（带错误详情）
```

**模板选择**:
- `--mode=mini` → 使用 [spec-mini.md](assets/spec-mini.md)
- `--mode=standard` 或 `--mode=full` → 使用 [spec-template.md](assets/spec-template.md)

**阶段参考**: 当需要以下内容时加载 [phase-details.md](references/phase-details.md)：
- 各阶段的详细子任务分解
- 输出格式示例（raw-notes.md、clarified.md）
- 用户故事的 INVEST 原则清单
- REVIEW 阶段的审查清单

---

## REVIEW 阶段详细说明

REVIEW 阶段使用独立 Agent 进行审查，确保信息隔离：

```python
# 伪代码示例
review_prompt = f"""
请审查以下 spec.md 规范文档：

{spec_content}

审查清单：
1. 用户故事格式是否正确（As a/I want/So that）
2. 每个故事是否有 3-7 个验收标准
3. 验收标准是否覆盖正向/负向/边界场景
4. NFR 是否可量化
5. 是否存在禁止的模糊词汇
6. 需求间是否存在冲突
7. 范围边界是否清晰

请返回审查结果（PASS/NEEDS_IMPROVEMENT/REJECTED）和具体问题列表。
"""

# 使用 Task 工具启动独立 Agent
Task(
    prompt=review_prompt,
    subagent_type="general-purpose",
    description="审查 spec.md"
)
```

**审查判定规则**:

| 判定 | 条件 |
|------|------|
| **PASS** | 无 MAJOR/CRITICAL 问题 |
| **NEEDS_IMPROVEMENT** | 有 MAJOR 问题但无 CRITICAL |
| **REJECTED** | 有 CRITICAL 问题或结构严重缺失 |
