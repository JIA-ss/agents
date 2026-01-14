# 阶段详细文档

## 阶段概览

| 阶段 | 名称 | 目标 | 输出 |
|------|------|------|------|
| 1 | ANALYZE | 解析 spec.md，提取技术决策点 | analysis.md |
| 2 | RESEARCH | 调研技术方案、最佳实践 | research.md |
| 3 | REVIEW-1 | 审查分析和调研是否充分 | review-response.md |
| 4 | PLAN | 生成技术计划 plan.md | plan.md (draft) |
| 5 | REVIEW-2 | 审查设计质量和完整性 | review-response.md |
| 6 | VALIDATE | 获取用户最终批准 | plan.md (approved) |

---

## ANALYZE 阶段详细

### 输入

- `.workflow/{feature}/specify/spec.md`（状态必须为 approved）
- 项目上下文文件（CLAUDE.md, constitution.md，如果存在）

### 子任务

1. **读取 spec.md**
   - 解析 frontmatter（状态、版本）
   - 提取各章节内容

2. **提取功能需求 (FR)**
   - 列出所有 FR ID 和描述
   - 识别技术影响（影响哪些模块）
   - 标记是否需要调研

3. **提取非功能需求 (NFR)**
   - 列出所有 NFR ID 和描述
   - 识别约束类型（性能/安全/可用性）
   - 记录量化指标

4. **识别技术约束**
   - 从 spec.md 约束章节提取
   - 从 constitution.md 提取（如存在）
   - 识别隐含约束

5. **标记待决策点**
   - 技术选型决策
   - 架构模式决策
   - 依赖选择决策

6. **识别调研主题**
   - 根据待决策点生成调研主题
   - 设置优先级（P0/P1/P2）

7. **分析现有代码库**（如适用）
   - 识别相关模块
   - 发现可复用组件
   - 列出需要修改的文件

### 输出格式

参见 [assets/analysis-template.md](../assets/analysis-template.md)

---

## RESEARCH 阶段详细

### 输入

- `analyze/analysis.md`
- 调研主题列表

### 子任务

1. **执行技术调研**
   - 使用 WebSearch 搜索技术资料
   - 使用 WebFetch 获取文档内容
   - 使用 Task (Explore) 分析代码库

2. **对比技术方案**
   - 至少对比 2 个方案
   - 列出优缺点
   - 给出推荐度评分

3. **评估依赖**
   - 检查维护状态
   - 查看最近更新时间
   - 评估风险等级

4. **收集最佳实践**
   - 从官方文档提取
   - 从社区经验提取

5. **形成结论**
   - 解决待决策点
   - 给出技术选型建议

### 超时配置

```yaml
research:
  stage_timeout: 300  # 5 分钟
  single_search_timeout: 30  # 单次搜索 30 秒
  max_sources: 10  # 最多引用 10 个来源
```

### 输出格式

参见 [assets/research-template.md](../assets/research-template.md)

---

## REVIEW-1 阶段详细

### 输入

- `analyze/analysis.md`
- `research/research.md`
- `../specify/spec.md`（用于验证覆盖度）

### 审查方法

1. 使用 Task 工具启动独立审查 Agent
2. 传入审查清单和待审查文件
3. 收集审查结果

### 审查清单

参见 [review-checklist.md](review-checklist.md) 的 REVIEW-1 部分

### 判定逻辑

```python
def review_1_verdict(analysis, research, spec):
    # 计算覆盖度
    fr_coverage = len(analyzed_frs) / len(spec_frs)
    nfr_coverage = len(analyzed_nfrs) / len(spec_nfrs)

    # 检查调研完整性
    research_complete = all(
        topic.has_conclusion and len(topic.sources) >= 1
        for topic in research.topics
    )

    if fr_coverage < 0.95:
        return "NEEDS_ANALYZE", "FR 覆盖度不足"
    if nfr_coverage < 0.95:
        return "NEEDS_ANALYZE", "NFR 覆盖度不足"
    if not research_complete:
        return "NEEDS_RESEARCH", "调研不完整"

    return "PASS", None
```

---

## PLAN 阶段详细

### 输入

- `analyze/analysis.md`
- `research/research.md`
- 项目上下文

### 子任务

1. **设计系统架构**
   - 定义主要模块
   - 确定模块间关系
   - 绘制 Mermaid 架构图

2. **确定技术选型**
   - 基于调研结论选择
   - 记录选型理由
   - 提供备选方案

3. **分析依赖**
   - 内部模块依赖
   - 外部包依赖（含版本）

4. **评估风险**
   - 识别 3-5 个关键风险
   - 评估可能性和影响
   - 制定缓解策略

5. **记录架构决策**
   - 为关键决策创建 ADR
   - 关联到相关需求

6. **建立追溯性映射**
   - 模块 → FR 映射
   - ADR → FR/NFR 映射

### 输出格式

参见 [assets/plan-template.md](../assets/plan-template.md)

---

## REVIEW-2 阶段详细

### 输入

- `plan.md`（草稿）
- `research/research.md`
- `../specify/spec.md`

### 审查方法

1. 使用 Task 工具启动独立审查 Agent
2. 传入审查清单和待审查文件
3. 收集审查结果

### 审查清单

参见 [review-checklist.md](review-checklist.md) 的 REVIEW-2 部分

### 判定逻辑

```python
def review_2_verdict(plan, research, spec):
    # 检查架构完整性
    modules_complete = all(
        module.has_responsibility and len(module.responsibility) <= 50
        for module in plan.modules
    )

    # 检查技术选型与调研一致性
    selections_consistent = all(
        selection.choice in research.recommendations
        for selection in plan.tech_selections
    )

    # 计算覆盖度
    coverage = len(plan.covered_frs) / len(spec.frs)

    if not selections_consistent:
        return "NEEDS_RESEARCH", "技术选型与调研结论不一致"
    if coverage < 0.95:
        return "NEEDS_PLAN", "需求覆盖度不足"
    if not modules_complete:
        return "NEEDS_PLAN", "模块职责描述不完整"

    return "PASS", None
```

---

## VALIDATE 阶段详细

### 输入

- `plan.md`（已审查）
- 审查报告

### 子任务

1. **完整性检查**
   - 所有必填章节已填写
   - 格式符合模板要求

2. **覆盖度检查**
   - 验证 FR 覆盖度
   - 验证 NFR 覆盖度

3. **展示摘要**
   - 架构设计摘要
   - 技术选型摘要
   - 风险评估摘要

4. **请求批准**
   - 使用 AskUserQuestion 工具
   - 提供批准/修改选项

5. **更新状态**
   - 将 plan.md 状态更新为 approved
   - 更新 .state.yaml

---

## 回退规则详细

### REVIEW-1 回退

| 判定 | 回退到 | 后续路径 |
|------|--------|----------|
| NEEDS_ANALYZE | ANALYZE | ANALYZE → RESEARCH → REVIEW-1 |
| NEEDS_RESEARCH | RESEARCH | RESEARCH → REVIEW-1 |

### REVIEW-2 回退

| 判定 | 回退到 | 后续路径 |
|------|--------|----------|
| NEEDS_PLAN | PLAN | PLAN → REVIEW-2 |
| NEEDS_RESEARCH | RESEARCH | RESEARCH → REVIEW-1 → PLAN → REVIEW-2 |

---

## 状态文件格式

```yaml
feature: {feature-id}
version: 2.0.0
phase: analyze | research | review-1 | plan | review-2 | validate
status: in_progress | completed | failed

completed_phases:
  analyze:
    completed_at: "2026-01-14T10:00:00Z"
    output: analyze/analysis.md
  research:
    completed_at: "2026-01-14T11:00:00Z"
    output: research/research.md

reviews:
  review-1:
    current_round: 1
    max_rounds: 3
    history:
      - round: 1
        verdict: PASS
        confidence: 0.92
  review-2:
    current_round: 1
    max_rounds: 3
    history: []

rollbacks:
  - from: review-1
    to: research
    reason: "技术选型调研不足"
    timestamp: "2026-01-14T12:00:00Z"
```

---

*Reference for workflow-plan phases*
