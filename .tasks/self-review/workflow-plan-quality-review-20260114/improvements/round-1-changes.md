# Round 1 改进记录

> **日期**: 2026-01-14
> **修复问题数**: 7 MAJOR

---

## 修复的问题

### M1 & M2: 资源表格添加"何时使用"列

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**:
- 将资源表格的"用途"列改为"何时使用"
- 为每个资源添加明确的使用时机说明

**Before**:
```markdown
| 资源 | 路径 | 用途 |
|------|------|------|
| 计划模板 | ... | plan.md 模板 |
```

**After**:
```markdown
| 资源 | 路径 | 何时使用 |
|------|------|----------|
| 计划模板 | ... | PLAN 阶段生成 plan.md 时 |
```

---

### M3: 各阶段添加明确的输入说明

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**: 为阶段 1-6 添加"输入"段落，明确每个阶段需要的输入文件

**示例**:
```markdown
### 阶段 2: RESEARCH（技术调研）

**输入**:
- `.workflow/{feature}/plan/analyze/analysis.md`
- analysis.md 中标记的调研主题列表
```

---

### M4: RESEARCH 添加完成标准

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**: 在 RESEARCH 阶段添加"完成标准"子章节

```markdown
**完成标准**:
- 所有 P0 调研主题都有明确结论
- 每个调研主题至少有 1 个可靠来源
- 技术方案对比完整（列出优缺点）
```

---

### M5: 审查清单引用说明

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**: 在 REVIEW-1 和 REVIEW-2 阶段添加引导到完整清单的提示

```markdown
> **完整清单**: 参见 [references/review-checklist.md](references/review-checklist.md) 的 REVIEW-1 部分
```

---

### M6: 正文添加引导到 references 的内联提示

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**:
1. 各阶段添加模板引用提示：`> **模板**: 使用 [assets/xxx-template.md]...`
2. REVIEW 阶段添加清单引用提示

---

### M7: 状态文件格式说明

**修改文件**: `skills/workflow-plan/SKILL.md`

**修改内容**: 在输出结构章节添加 `.state.yaml` 格式简要说明和详细格式引用

```markdown
**.state.yaml 格式**（简化）:
```yaml
feature: {feature-id}
version: 2.0.0
phase: analyze | research | review-1 | plan | review-2 | validate
status: in_progress | completed | failed
```

> **完整格式**: 参见 [references/phase-details.md]...
```

---

## 文件行数变化

- `SKILL.md`: 272 行 → ~325 行 (仍 < 500 行)

---

*Improvement record for self-review | 2026-01-14*
