---
name: skill-generator
description: 根据用户需求自动生成符合 Claude Code Agent Skills 规范的 SKILL.md 文件，支持渐进式披露架构。当用户想要创建、设计或生成新 skill，需要 SKILL.md 格式帮助，或想要扩展 Claude 能力时使用。也响应 "创建 skill", "生成 skill", "设计 skill", "skill 模板"。
---

# Skill Generator

Skill 创建向导：REQUIRE → PLAN → INIT → WRITE → VALIDATE → ITERATE

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户需求，确定 skill 用途
2. 收集触发场景和示例
3. 开始 Phase 1: REQUIRE

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: REQUIRE → 收集需求和使用场景
- [ ] Phase 2: PLAN → 规划可复用内容
- [ ] Phase 3: INIT → 创建目录结构
- [ ] Phase 4: WRITE → 编写 SKILL.md
- [ ] Phase 5: VALIDATE → 验证规范合规
- [ ] Phase 6: ITERATE → 测试和优化
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| REQUIRE | 需求和场景已收集 | → PLAN |
| PLAN | 可复用内容已规划 | → INIT |
| INIT | 目录结构已创建 | → WRITE |
| WRITE | SKILL.md 已编写 | → VALIDATE |
| VALIDATE | 验证通过 | → ITERATE |
| ITERATE | 用户确认完成 | → 结束 |

---

## Phase 详情

### Phase 1: REQUIRE（收集需求）

**你必须：**
1. 询问 skill 用途和目标
2. 收集具体使用场景示例
3. 确定触发关键词（中英文）
4. 识别预期输出形式

**关键问题**:
- "这个 skill 应该处理什么任务？"
- "给出用户请求的示例"
- "用户会说什么来激活它？"

**完成标志**: 需求和场景已收集

---

### Phase 2: PLAN（规划内容）

**你必须：**
1. 识别可复用内容：
   - **Scripts**: 会被重复编写的代码
   - **References**: 按需加载的领域知识
   - **Assets**: 输出中使用的模板/图片
2. 确定工作流阶段
3. 规划目录结构

**渐进式披露三层**:
| 层级 | 加载时机 | Token 预算 | 内容 |
|------|----------|------------|------|
| 1: 元数据 | 启动时 | ~100 | frontmatter |
| 2: 指令 | 触发时 | <5k | SKILL.md 正文 |
| 3: 资源 | 按需 | 无限制 | scripts/, references/, assets/ |

**完成标志**: 可复用内容已规划

---

### Phase 3: INIT（初始化结构）

**你必须：**
1. 创建 skill 目录：`{skill-name}/`
2. 创建子目录（按需）：
   - `references/` - 领域文档
   - `scripts/` - 可执行代码
   - `assets/` - 模板和资源
3. 创建空的 SKILL.md

**完成标志**: 目录结构已创建

---

### Phase 4: WRITE（编写 SKILL.md）

**你必须：**
1. 编写 frontmatter：
   ```yaml
   ---
   name: skill-name
   description: 功能描述。Use when [触发条件]。Also responds to "中文关键词"。
   ---
   ```
2. 编写正文结构：
   - 🚀 执行流程（必须）
   - 📋 进度追踪 Checklist（必须）
   - ✅ 阶段完成验证表（必须）
   - Phase 详情（必须）
   - 约束/资源（按需）

**关键格式**:
- 使用 "**你必须：**" 引导具体指令
- 每个 Phase 必须有 "**完成标志**"
- 使用表格和列表提高可读性

**完成标志**: SKILL.md 已编写

---

### Phase 5: VALIDATE（验证规范）

**你必须：**
1. 检查 frontmatter：
   - name: ≤64 字符，仅 `a-z`、`0-9`、`-`
   - description: ≤1024 字符，第三人称
   - 禁止包含 "anthropic"、"claude"
2. 检查内容：
   - SKILL.md < 500 行
   - 包含执行流程和 Checklist
   - references 仅 1 层深度
   - 无 XML 标签

**完成标志**: 验证通过

---

### Phase 6: ITERATE（测试优化）

**你必须：**
1. 在新会话中测试 skill 触发
2. 观察执行行为
3. 收集用户反馈
4. 优化并重新验证

**完成标志**: 用户确认完成

---

## 规范约束

### Frontmatter 字段

| 字段 | 约束 | 示例 |
|------|------|------|
| `name` | ≤64 字符，仅 `a-z`、`0-9`、`-` | `pdf-processor` |
| `description` | ≤1024 字符，第三人称 | "Extracts text from PDFs..." |

### Description 要求

必须包含：
1. **功能描述** - 做什么
2. **触发条件** - 何时使用

**正确**: "Extract text from PDFs. Use when working with PDF files..."
**错误**: "Helps with documents"（太模糊）

---

## 质量清单

**Frontmatter**:
- [ ] name 符合命名规则
- [ ] description < 1024 字符
- [ ] description 包含 "what" 和 "when"
- [ ] 无第一人称代词

**内容**:
- [ ] SKILL.md < 500 行
- [ ] 包含 🚀 执行流程
- [ ] 包含 📋 进度追踪 Checklist
- [ ] 包含 ✅ 阶段完成验证表
- [ ] 每个 Phase 有 "你必须" 和 "完成标志"

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 规范参考 | [references/spec-reference.md](references/spec-reference.md) | 详细字段约束 |
| 最佳实践 | [references/best-practices.md](references/best-practices.md) | 测试和迭代指南 |
| 模板 | [templates/SKILL-template.md](templates/SKILL-template.md) | 快速开始 |
