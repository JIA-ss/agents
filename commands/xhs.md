---
description: 小红书内容创作全流程 - 从热点调研到一键发布（RESEARCH→TOPIC→COPY→VISUAL→REVIEW→PUBLISH），使用 Agent Team 并行执行，每阶段内置自迭代优化循环
---

调用 `xhs-workflow` agent 执行小红书内容创作全流程。

该 agent 会：
1. 用 Agent Team 并行调研热点（3 个并行 research worker）
2. 自动选题（评分选最优方案，无需人工决策）
3. 撰写文案（内置草稿→评分→修改迭代循环，≥75分才定稿）
4. 并行生成配图（3-5 个并行 visual worker，每张图内置生成→评估→修正循环）
5. 强制质量审核 + 自动修正平台限制（标题≤20字、正文≤1000字等）
6. 直接发布（无需人工确认）

## 创作方向

$ARGUMENTS

---

> 需要 MCP 服务运行：
> - `xiaohongshu-mcp`：`cd ~/git_Proj/daily && ./bin/xiaohongshu-mcp`
> - `fal-ai`：需设置 `export FAL_KEY=your-key`（已配置则自动可用）
