---
name: skill-generator
description: 根据用户需求自动生成符合 Claude Code Agent Skills 规范的 SKILL.md 文件，采用 TDD 方法确保所有用法可验证。当用户想要创建、设计或生成新 skill，需要 SKILL.md 格式帮助，或想要扩展 Claude 能力时使用。也响应 "创建 skill", "生成 skill", "设计 skill", "skill 模板"。
---

# Skill Generator (TDD Edition)

采用测试驱动开发：REQUIRE → PLAN → **TEST-DESIGN** → INIT → WRITE → **TEST-RUN** → ITERATE

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 解析用户需求，确定 skill 用途
2. 收集触发场景和示例
3. **强调 TDD 原则**：先写测试，再写实现
4. 开始 Phase 1: REQUIRE

### 📋 进度追踪 Checklist

**复制此清单并逐项完成：**

```
- [ ] Phase 1: REQUIRE → 收集需求和使用场景
- [ ] Phase 2: PLAN → 规划可复用内容
- [ ] Phase 3: TEST-DESIGN → 编写测试规范（TDD 核心）
- [ ] Phase 4: INIT → 创建目录结构
- [ ] Phase 5: WRITE → 编写 SKILL.md
- [ ] Phase 6: TEST-RUN → 运行测试验证
- [ ] Phase 7: ITERATE → 修复失败测试并优化
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| REQUIRE | 需求和场景已收集 | → PLAN |
| PLAN | 可复用内容已规划 | → TEST-DESIGN |
| TEST-DESIGN | test-spec.yaml 已创建并验证 | → INIT |
| INIT | 目录结构已创建 | → WRITE |
| WRITE | SKILL.md 已编写 | → TEST-RUN |
| TEST-RUN | 所有测试通过 | → ITERATE |
| ITERATE | 用户确认完成 | → 结束 |

---

## Phase 详情

### Phase 1: REQUIRE（收集需求）

**你必须：**
1. 询问 skill 用途和目标
2. 收集具体使用场景示例（至少 3 个）
3. 确定触发关键词（中英文）
4. 识别预期输出形式
5. 明确边界情况和错误处理需求

**关键问题**:
- "这个 skill 应该处理什么任务？"
- "给出 3 个用户请求的示例"
- "哪些请求不应该触发这个 skill？"
- "遇到错误时应该如何处理？"

**完成标志**: 需求、场景和边界情况已收集

---

### Phase 2: PLAN（规划内容）

**你必须：**
1. 识别可复用内容：
   - **Scripts**: 会被重复编写的代码
   - **References**: 按需加载的领域知识
   - **Assets**: 输出中使用的模板/图片
2. 确定工作流阶段
3. 规划目录结构
4. **规划测试类型覆盖**

**渐进式披露三层**:
| 层级 | 加载时机 | Token 预算 | 内容 |
|------|----------|------------|------|
| 1: 元数据 | 启动时 | ~100 | frontmatter |
| 2: 指令 | 触发时 | <5k | SKILL.md 正文 |
| 3: 资源 | 按需 | 无限制 | scripts/, references/, assets/ |

**完成标志**: 可复用内容和测试覆盖已规划

---

### Phase 3: TEST-DESIGN（编写测试规范 - TDD 核心）

**这是 TDD 的核心阶段，必须在编写 SKILL.md 之前完成！**

**你必须：**
1. 创建 `tests/test-spec.yaml` 文件
2. 定义以下测试场景（每类至少 1 个）：

| 测试类型 | 必须 | 目的 |
|----------|------|------|
| `trigger` | 是 | 验证正确触发 |
| `execution` | 是 | 验证核心功能 |
| `edge` | 是 | 验证边界情况 |
| `negative` | 是 | 验证不误触发 |
| `error` | 推荐 | 验证错误处理 |

3. 运行验证脚本确认测试规范完整
4. 用户确认测试场景覆盖需求

**测试规范模板**:
```yaml
skill:
  name: "your-skill-name"
  description: "Brief description"

scenarios:
  - id: "trigger-basic"
    name: "Basic trigger test"
    type: "trigger"
    query: "User query that should trigger"
    expected_behavior:
      - "Skill activates"
      - "Expected behavior"

  - id: "exec-standard"
    name: "Standard execution"
    type: "execution"
    query: "Typical user request"
    expected_behavior:
      - "Processes correctly"
      - "Produces expected output"

  - id: "edge-minimal"
    name: "Minimal input"
    type: "edge"
    query: "Incomplete request"
    expected_behavior:
      - "Handles gracefully"

  - id: "negative-unrelated"
    name: "Unrelated request"
    type: "negative"
    query: "Unrelated task"
    expected_behavior:
      - "Skill does NOT activate"
```

**验证命令**:
```bash
./scripts/verify-scenarios.sh <skill-dir>
```

**完成标志**: test-spec.yaml 已创建，verify-scenarios.sh 通过

---

### Phase 4: INIT（初始化结构）

**你必须：**
1. 创建 skill 目录：`{skill-name}/`
2. 创建子目录：
   - `tests/` - **必须，包含 test-spec.yaml**
   - `references/` - 领域文档（按需）
   - `scripts/` - 可执行代码（按需）
   - `assets/` - 模板和资源（按需）
3. 将 test-spec.yaml 放入 tests/ 目录
4. 创建空的 SKILL.md

**目录结构**:
```
skill-name/
├── SKILL.md
├── tests/
│   └── test-spec.yaml    # TDD: 测试规范
├── references/           # 按需
├── scripts/              # 按需
└── assets/               # 按需
```

**完成标志**: 目录结构已创建，test-spec.yaml 已就位

---

### Phase 5: WRITE（编写 SKILL.md）

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
3. **确保实现覆盖 test-spec.yaml 中定义的所有场景**

**关键格式**:
- 使用 "**你必须：**" 引导具体指令
- 每个 Phase 必须有 "**完成标志**"
- 使用表格和列表提高可读性

**TDD 检查点**: 编写时对照 test-spec.yaml，确保每个测试场景都有对应实现

**完成标志**: SKILL.md 已编写，覆盖所有测试场景

---

### Phase 6: TEST-RUN（运行测试验证）

**你必须：**
1. 运行结构验证：
   ```bash
   ./scripts/validate-skill.sh <skill-dir>
   ```
2. 运行测试场景验证：
   ```bash
   ./scripts/run-skill-tests.sh <skill-dir>
   ```
3. 记录测试结果

**测试检查清单**:
- [ ] Frontmatter 验证通过
- [ ] 内容结构验证通过
- [ ] 所有 trigger 测试通过
- [ ] 所有 execution 测试通过
- [ ] 所有 edge 测试通过
- [ ] 所有 negative 测试通过
- [ ] 错误处理测试通过（如有）

**如果测试失败**:
1. 记录失败原因
2. 返回 Phase 5 修复 SKILL.md
3. 重新运行测试
4. 重复直到所有测试通过

**完成标志**: 所有测试通过，无失败

---

### Phase 7: ITERATE（用户验收与优化）

**你必须：**
1. 向用户展示测试结果摘要
2. 在新会话中演示 skill 触发
3. 收集用户反馈
4. 如有问题，回到相应阶段修复
5. 更新测试规范以覆盖新发现的场景

**用户验收清单**:
- [ ] Skill 按预期触发
- [ ] 输出格式符合预期
- [ ] 边界情况处理正确
- [ ] 不会误触发
- [ ] 用户满意

**完成标志**: 用户确认完成，测试全部通过

---

## TDD 原则总结

### 为什么测试先行？

| 阶段 | 传统方式 | TDD 方式 |
|------|----------|----------|
| 设计 | 直接写代码 | 先定义期望行为 |
| 实现 | 边写边测 | 有明确目标 |
| 验收 | 手动测试 | 自动化验证 |
| 维护 | 改了可能坏 | 回归测试保护 |

### TDD 三步循环

```
RED → GREEN → REFACTOR
 │       │        │
 │       │        └── 优化代码，保持测试通过
 │       └── 编写最小实现让测试通过
 └── 编写失败的测试
```

---

## 规范约束

### Frontmatter 字段

| 字段 | 约束 | 示例 |
|------|------|------|
| `name` | ≤64 字符，仅 `a-z`、`0-9`、`-` | `pdf-processor` |
| `description` | ≤1024 字符，第三人称 | "Extracts text from PDFs..." |

### 测试覆盖要求

| 测试类型 | 最少数量 | 说明 |
|----------|----------|------|
| trigger | 2 | 包含中英文触发 |
| execution | 1 | 标准用例 |
| edge | 2 | 边界情况 |
| negative | 1 | 防误触发 |

---

## 质量清单

**测试规范 (Phase 3)**:
- [ ] test-spec.yaml 已创建
- [ ] 包含 trigger/execution/edge/negative 四类测试
- [ ] 每个场景有 id/name/type/query/expected_behavior
- [ ] verify-scenarios.sh 验证通过

**Frontmatter (Phase 5)**:
- [ ] name 符合命名规则
- [ ] description < 1024 字符
- [ ] description 包含 "what" 和 "when"
- [ ] 无第一人称代词

**内容 (Phase 5)**:
- [ ] SKILL.md < 500 行
- [ ] 包含 🚀 执行流程
- [ ] 包含 📋 进度追踪 Checklist
- [ ] 包含 ✅ 阶段完成验证表
- [ ] 每个 Phase 有 "你必须" 和 "完成标志"

**测试通过 (Phase 6)**:
- [ ] validate-skill.sh 通过
- [ ] run-skill-tests.sh 通过
- [ ] 所有场景验证通过

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| 规范参考 | [references/spec-reference.md](references/spec-reference.md) | 详细字段约束 |
| 最佳实践 | [references/best-practices.md](references/best-practices.md) | 测试和迭代指南 |
| SKILL 模板 | [templates/SKILL-template.md](templates/SKILL-template.md) | 快速开始 |
| **测试规范模板** | [templates/test-spec.yaml](templates/test-spec.yaml) | **TDD 测试模板** |

### 脚本工具

| 脚本 | 用途 |
|------|------|
| `scripts/generate-test-spec.sh` | 生成测试规范模板 |
| `scripts/verify-scenarios.sh` | 验证测试场景完整性 |
| `scripts/validate-skill.sh` | 验证 SKILL.md 规范 |
| `scripts/run-skill-tests.sh` | 运行完整测试套件 |
