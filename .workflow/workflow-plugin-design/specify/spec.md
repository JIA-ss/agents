# Workflow Plugin 设计规范

> **功能 ID**: workflow-plugin-design
> **状态**: draft
> **创建时间**: 2026-01-14
> **版本**: 1.0.0

---

## 1. 概述

### 1.1 背景

现有 AI 工作流框架设计了 5 阶段模型（SPECIFY → PLAN → TASK → IMPLEMENT → REVIEW），但：
- 当前采用独立 skills（`/specify`, `/plan` 等）分散实现
- 目录结构使用 `.agent/specs/{feature}/`
- 缺乏统一入口和命名空间隔离

### 1.2 目标

将整个工作流重构为 **Claude Code Plugin**，实现：
1. **统一入口**: 使用 `/workflow:specify`、`/workflow:plan` 等完全限定名语法
2. **新目录结构**: `.workflow/{feature}/{stage}/` 按阶段组织
3. **Plugin 打包**: 所有 skills 整合到单一 Plugin 中

### 1.3 范围

| 范围内 | 范围外 |
|--------|--------|
| 创建 workflow Plugin 结构 | 修改现有独立 skills |
| 实现 5 个阶段 skills | MCP 服务器集成（后续迭代） |
| 新目录结构 `.workflow/` | IDE 集成 |
| 中文文档 | 多语言支持 |
| 迁移现有 /specify 功能 | 保留 .agent/ 目录兼容 |

---

## 2. 利益相关者

| 角色 | 关注点 |
|------|--------|
| 开发者 | 统一命令入口，清晰的阶段划分 |
| 项目管理 | 功能可追溯，进度可视化 |
| AI 工具 | 命名空间隔离，避免冲突 |

---

## 3. 用户故事

### US-01: Plugin 统一入口

```
作为 开发者，
我想要 使用 /workflow:xxx 格式调用所有工作流阶段，
以便 有统一的命令入口和清晰的命名空间。
```

**验收标准**:
- AC-01.1: 支持 `/workflow:specify {描述}` 调用需求规范阶段
- AC-01.2: 支持 `/workflow:plan {feature}` 调用技术计划阶段
- AC-01.3: 支持 `/workflow:task {feature}` 调用任务分解阶段
- AC-01.4: 支持 `/workflow:implement {feature}` 调用实现阶段
- AC-01.5: 支持 `/workflow:review {feature}` 调用审查阶段
- AC-01.6: 仅使用完全限定名，不支持简化名（避免命名冲突）

### US-02: 按阶段目录组织

```
作为 开发者，
我想要 每个工作流阶段的输出保存到独立目录，
以便 清晰追踪各阶段产出。
```

**验收标准**:
- AC-02.1: SPECIFY 阶段输出到 `.workflow/{feature}/specify/`
- AC-02.2: PLAN 阶段输出到 `.workflow/{feature}/plan/`
- AC-02.3: TASK 阶段输出到 `.workflow/{feature}/task/`
- AC-02.4: IMPLEMENT 阶段输出到 `.workflow/{feature}/implement/`
- AC-02.5: REVIEW 阶段输出到 `.workflow/{feature}/review/`
- AC-02.6: 全局状态追踪保存到 `.workflow/{feature}/.state.yaml`

### US-03: 阶段间数据流转

```
作为 开发者，
我想要 各阶段自动识别上一阶段的输出，
以便 无缝衔接整个工作流。
```

**验收标准**:
- AC-03.1: `/workflow:plan` 自动读取 `specify/spec.md`
- AC-03.2: `/workflow:task` 自动读取 `plan/plan.md`
- AC-03.3: `/workflow:implement` 自动读取 `task/tasks.md`
- AC-03.4: `/workflow:review` 自动读取 `implement/` 目录内容
- AC-03.5: 找不到上阶段输出时，提示用户并显示可用 feature 列表

### US-04: 工作流配置

```
作为 开发者，
我想要 通过配置文件自定义工作流行为，
以便 适配不同项目需求。
```

**验收标准**:
- AC-04.1: 支持 `.workflow/config.yaml` 全局配置
- AC-04.2: 可配置启用/禁用特定阶段
- AC-04.3: 可配置各阶段的人工审批点
- AC-04.4: 可配置技术栈相关命令（test, lint, build）

### US-05: 错误恢复

```
作为 开发者，
我想要 在任务执行失败时能够恢复和重试，
以便 不需要从头开始整个工作流。
```

**验收标准**:
- AC-05.1: 支持 `/workflow:xxx --resume {feature}` 继续执行
- AC-05.2: 失败日志保存到对应阶段目录
- AC-05.3: 连续失败 3 次后中止并提示用户
- AC-05.4: 状态文件记录每个阶段的完成状态

---

## 4. 功能需求

### 4.1 Plugin 结构

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-PL01 | 创建 `.claude-plugin/plugin.json` | P0 |
| FR-PL02 | 将 5 个阶段 skills 放入 `skills/` 目录 | P0 |
| FR-PL03 | 支持完全限定名 `/workflow:xxx` | P0 |

### 4.2 /workflow:specify Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-SP01 | 迁移现有 /specify 的全部功能 | P0 |
| FR-SP02 | 输出到 `.workflow/{feature}/specify/` | P0 |
| FR-SP03 | 5 阶段流程: CAPTURE→CLARIFY→STRUCTURE→REVIEW→VALIDATE | P0 |
| FR-SP04 | 中文支持 | P0 |

### 4.3 /workflow:plan Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-PN01 | 读取 `specify/spec.md` | P0 |
| FR-PN02 | 生成技术方案（架构、技术选型） | P0 |
| FR-PN03 | 记录架构决策（ADR 格式） | P0 |
| FR-PN04 | 使用 Mermaid 生成架构图 | P0 |
| FR-PN05 | 输出到 `.workflow/{feature}/plan/` | P0 |

### 4.4 /workflow:task Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-TK01 | 读取 `plan/plan.md` | P0 |
| FR-TK02 | 生成任务列表（带优先级） | P0 |
| FR-TK03 | 标识任务依赖关系和并行标记 [P] | P0 |
| FR-TK04 | 使用 Mermaid 生成 DAG 图 | P0 |
| FR-TK05 | 输出到 `.workflow/{feature}/task/` | P0 |

### 4.5 /workflow:implement Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-IM01 | 读取 `task/tasks.md` | P0 |
| FR-IM02 | 按拓扑顺序执行任务 | P0 |
| FR-IM03 | TDD 模式支持（[T] 任务先写测试） | P0 |
| FR-IM04 | 更新 tasks.md 中的任务状态 | P0 |
| FR-IM05 | 输出到 `.workflow/{feature}/implement/` | P0 |

### 4.6 /workflow:review Skill

| 需求 ID | 描述 | 优先级 |
|---------|------|--------|
| FR-RV01 | 整合现有 /self-review 功能 | P0 |
| FR-RV02 | 使用独立 Agent 进行审查 | P0 |
| FR-RV03 | 支持 PASS/NEEDS_IMPROVEMENT/REJECTED 判定 | P0 |
| FR-RV04 | 输出到 `.workflow/{feature}/review/` | P0 |

---

## 5. 非功能需求

| NFR ID | 描述 | 指标 |
|--------|------|------|
| NFR-01 | 每个 SKILL.md 不超过 500 行 | <500 行 |
| NFR-02 | 使用 Progressive Disclosure 架构 | Level 1: <100 tokens, Level 2: <5k tokens |
| NFR-03 | 断点恢复 | 95% 情况恢复时间 < 5秒，准确率 99.9% |
| NFR-04 | 命名空间隔离 | 与其他 plugins 无冲突 |
| NFR-05 | 技术栈无关 | 默认命令可通过配置覆盖 |

---

## 6. 技术约束

### 6.1 Plugin 目录结构

```
workflow-plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin 元数据
├── skills/
│   ├── specify/
│   │   ├── SKILL.md
│   │   ├── assets/
│   │   ├── references/
│   │   └── scripts/
│   ├── plan/
│   │   └── SKILL.md
│   ├── task/
│   │   └── SKILL.md
│   ├── implement/
│   │   └── SKILL.md
│   └── review/
│       └── SKILL.md
├── templates/                 # 共享模板
│   ├── config.yaml
│   └── constitution.md
└── README.md
```

### 6.2 项目输出目录结构

```
.workflow/
├── config.yaml               # 全局配置
├── {feature-1}/
│   ├── .state.yaml          # 状态追踪
│   ├── specify/
│   │   ├── capture/
│   │   ├── clarify/
│   │   ├── reviews/
│   │   └── spec.md
│   ├── plan/
│   │   └── plan.md
│   ├── task/
│   │   └── tasks.md
│   ├── implement/
│   │   └── logs/
│   └── review/
│       ├── reviews/
│       └── final-report.md
└── {feature-2}/
    └── ...
```

### 6.3 plugin.json 规范

```json
{
  "name": "workflow",
  "version": "1.0.0",
  "description": "AI-driven development workflow: specify → plan → task → implement → review",
  "author": "Your Name",
  "skills": "./skills/",
  "keywords": ["workflow", "specify", "plan", "implement", "review"]
}
```

### 6.4 命令调用方式

| 调用方式 | 示例 | 说明 |
|----------|------|------|
| 完全限定名 | `/workflow:specify {描述}` | 标准调用方式 |
| 带 feature | `/workflow:plan user-auth` | 指定功能 ID |
| 恢复执行 | `/workflow:implement --resume user-auth` | 从断点继续 |
| 验证输入 | `/workflow:plan --validate user-auth` | 仅验证不执行 |

---

## 7. 范围外

| 明确排除 | 原因 |
|----------|------|
| MCP 服务器集成 | 后续迭代 |
| IDE 插件开发 | 超出当前范围 |
| 保留 .agent/ 目录兼容 | 新架构，清理旧结构 |
| 多 Plugin 协作 | 单一 workflow plugin 足够 |

---

## 8. 依赖关系

### 8.1 内部依赖

| 依赖项 | 类型 | 说明 |
|--------|------|------|
| Claude Code Plugin 系统 | 平台 | 完全限定名语法支持 |
| Task 工具 | 功能 | 独立 Agent 审查 |
| TodoWrite 工具 | 功能 | 任务进度追踪 |

### 8.2 外部依赖

| 依赖项 | 版本 | 用途 |
|--------|------|------|
| Mermaid | 任意 | 图表渲染 |
| Git | 任意 | 版本控制 |

---

## 9. 验收清单

- [ ] Plugin 结构创建完成
  - [ ] plugin.json 配置正确
  - [ ] 5 个 skill 目录结构完整
- [ ] /workflow:specify 实现完成
  - [ ] 迁移现有功能
  - [ ] 输出到新目录结构
- [ ] /workflow:plan 实现完成
  - [ ] 读取 spec.md 并生成 plan.md
  - [ ] 包含架构图
- [ ] /workflow:task 实现完成
  - [ ] 读取 plan.md 并生成 tasks.md
  - [ ] 包含 DAG 图
- [ ] /workflow:implement 实现完成
  - [ ] 按拓扑顺序执行
  - [ ] 支持 TDD 模式
- [ ] /workflow:review 实现完成
  - [ ] 独立 Agent 审查
  - [ ] 迭代改进机制
- [ ] 集成测试
  - [ ] 完整流程: specify → plan → task → implement → review
  - [ ] 各阶段可独立执行
  - [ ] 断点恢复功能

---

## 附录 A: 决策记录

| 决策 ID | 决策 | 理由 | 日期 |
|---------|------|------|------|
| D-01 | 使用 Plugin 架构 | 支持完全限定名语法 `/workflow:xxx` | 2026-01-14 |
| D-02 | 新目录 `.workflow/` | 用户要求，更清晰的阶段组织 | 2026-01-14 |
| D-03 | 按阶段分子目录 | 用户要求 `.workflow/{feature}/{stage}/` | 2026-01-14 |
| D-04 | 全中文文档 | 与现有 /specify 保持一致 | 2026-01-14 |

---

## 附录 B: 迁移计划

### 从现有结构迁移

| 旧路径 | 新路径 |
|--------|--------|
| `skills/specify/` | `workflow-plugin/skills/specify/` |
| `.agent/specs/{feature}/` | `.workflow/{feature}/` |
| `.agent/config.yaml` | `.workflow/config.yaml` |

### 迁移步骤

1. 创建 `workflow-plugin/` 目录结构
2. 迁移现有 `/specify` skill
3. 实现新的 `/plan`, `/task`, `/implement`, `/review` skills
4. 更新目录输出路径
5. 测试完整工作流

---

*Generated by /specify STRUCTURE phase*
