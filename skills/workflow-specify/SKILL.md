---
name: workflow-specify
description: 将模糊的用户需求转化为结构化的 spec.md 规范文档。当用户想要定义功能、编写需求、创建规范，或提到"需求"、"规范"、"spec"、"用户故事"时使用。支持 mini/standard/full 三种模式。也响应 "workflow specify"、"工作流规范"。
---

# Workflow Specify

将模糊需求转化为 AI 可执行的结构化规范：CAPTURE → CLARIFY → STRUCTURE → REVIEW → VALIDATE

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户输入，提取 feature 名称和需求描述
2. 确定模式: mini（默认）/ standard / full
3. 创建目录: `.workflow/{feature}/specify/`
4. 开始 Phase 1: CAPTURE

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: CAPTURE → 输出: capture/raw-notes.md
- [ ] Phase 2: CLARIFY → 输出: clarify/clarified.md（可跳过）
- [ ] Phase 3: STRUCTURE → 输出: spec.md（草稿）
- [ ] Phase 4: REVIEW → 输出: reviews/round-{N}/review-response.md
- [ ] Phase 5: VALIDATE → 输出: spec.md（status: approved）
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| CAPTURE | `capture/raw-notes.md` 存在 | → CLARIFY |
| CLARIFY | `clarify/clarified.md` 存在 或 ambiguity_score=0 | → STRUCTURE |
| STRUCTURE | `spec.md` 存在且包含用户故事 | → REVIEW |
| REVIEW | 判定为 PASS | → VALIDATE |
| VALIDATE | 用户批准，status: approved | → 结束 |

---

## Phase 详情

### Phase 1: CAPTURE（捕获）

**你必须：**
1. 读取项目上下文（CLAUDE.md, constitution.md 如存在）
2. 扫描现有代码库结构
3. 识别利益相关者和用户角色
4. 提取原始需求（FR、NFR、约束）
5. 计算 ambiguity_score，列出待澄清问题
6. 创建 `capture/raw-notes.md`

**完成标志**: `capture/raw-notes.md` 存在

---

### Phase 2: CLARIFY（澄清）

**跳过条件**: ambiguity_score == 0 且无待澄清问题

**你必须：**
1. 检测模糊词汇（"快速"、"简单"、"友好"等）
2. 使用 AskUserQuestion 解决歧义
3. 记录已确认的假设和决策
4. 创建 `clarify/clarified.md`

**完成标志**: `clarify/clarified.md` 存在 或 跳过

---

### Phase 3: STRUCTURE（结构化）

**你必须：**
1. 根据模式选择模板:
   - mini → [assets/spec-mini.md](assets/spec-mini.md)
   - standard/full → [assets/spec-template.md](assets/spec-template.md)
2. 编写用户故事（As a/I want/So that 格式）
3. 为每个故事定义 3-7 个验收标准
4. 定义范围边界（Out of Scope）
5. 创建 `spec.md`（草稿）

**完成标志**: `spec.md` 存在且包含至少 1 个用户故事

---

### Phase 4: REVIEW（审查）

**你必须：**
1. 使用 Task 工具启动独立审查 Agent（信息隔离）
2. 审查内容: 用户故事格式、验收标准覆盖度、NFR 可量化、无模糊词
3. 创建 `reviews/round-{N}/review-response.md`
4. 判定: PASS → VALIDATE，NEEDS_IMPROVEMENT → 修改后重新审查

**判定规则**:
- **PASS**: 无 MAJOR/CRITICAL 问题
- **NEEDS_IMPROVEMENT**: 有 MAJOR 但无 CRITICAL（最多 3 轮）
- **REJECTED**: 有 CRITICAL 或结构严重缺失

**完成标志**: 判定为 PASS

---

### Phase 5: VALIDATE（验证）

**你必须：**
1. 运行完整性检查（必填章节已填写）
2. 通过 AskUserQuestion 请求用户批准
3. 更新 spec.md frontmatter: `status: approved`
4. 更新 `.state.yaml`

**完成标志**: spec.md 状态为 approved

---

## 目录结构

```
.workflow/{feature}/specify/
├── capture/
│   └── raw-notes.md
├── clarify/
│   └── clarified.md
├── reviews/
│   └── round-{N}/
│       └── review-response.md
├── spec.md
└── .state.yaml
```

---

## 模式对比

| 模式 | 必需章节 | 适用场景 |
|------|----------|----------|
| mini | 概述、用户故事、范围外、清单 | Bug 修复、小改动 |
| standard | 1-7、9 | 中等功能（默认） |
| full | 全部（1-9、附录 A-C） | 大型功能 |

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 完整模板 | [assets/spec-template.md](assets/spec-template.md) | standard/full 模式 |
| 精简模板 | [assets/spec-mini.md](assets/spec-mini.md) | mini 模式 |
| 阶段详情 | [references/phase-details.md](references/phase-details.md) | 详细子任务 |

---

## 集成

**输出**: 供 `/workflow-plan` 使用的 `spec.md`（已批准）
