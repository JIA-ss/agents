---
description: 小红书内容创作全流程（v2）— 从热点调研到一键发布（RESEARCH→REVIEW₁→TOPIC→COPY→REVIEW₂→VISUAL→REVIEW₃→LAYOUT→REVIEW₄→PUBLISH），使用 Agent Team 并行执行，每阶段由专精 Agent 执行，独立 Review Agent 审核所有产出，不合格退回修改（最多3轮）
---

调用 `xhs-workflow` agent 执行小红书内容创作全流程（v2）。

该 agent 会：
1. 用 Agent Team **并行调研**热点（3 个并行 xhs-researcher worker，内置搜索→分析→扩展循环）
2. 调用 **xhs-reviewer 审核**调研报告（≥85分通过，否则退回补充搜索，最多3轮）
3. **自动选题**（评分选最优方案，无需人工决策，生成内容大纲）
4. 调用 **xhs-copywriter** 撰写文案（内置6维自评分，≥75分才提交审核）
5. 调用 **xhs-reviewer 审核**文案（≥85分通过，否则退回修改，最多3轮）
6. 用 Agent Team **并行生成配图**（3 个并行 xhs-visual worker，每张图内置5维评分循环）
7. 调用 **xhs-reviewer 审核**配图（≥85分通过，否则退回重新生成，最多3轮）
8. 调用 **xhs-layout** 规划排版（内置4维自评分，≥75分才提交审核）
9. 调用 **xhs-reviewer 审核**排版（≥85分通过，否则退回修改，最多3轮）
10. 按排版方案组装并**直接发布**（无需人工确认）

## 创作方向

$ARGUMENTS

---

> 需要 MCP 服务运行：
> - `xiaohongshu-mcp`：`cd ~/git_Proj/daily && ./bin/xiaohongshu-mcp`
> - `fal-ai`：需设置 `export FAL_KEY=your-key`（已配置则自动可用）
