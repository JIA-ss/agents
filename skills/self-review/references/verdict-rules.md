# 判定规则详细说明

## 严重程度定义

| 级别 | 定义 | 示例 |
|------|------|------|
| **BLOCKER** | 阻止合并 | 安全漏洞、测试失败、编译错误 |
| **CRITICAL** | 影响核心功能 | 逻辑错误、数据丢失、功能缺失 |
| **MAJOR** | 影响可维护性 | 代码异味、复杂度过高、缺少文档 |
| **MINOR** | 可选优化 | 命名建议、注释改进、格式调整 |

## 判定规则

```yaml
PASS:
  conditions:
    - blocker_count == 0
    - critical_count == 0
    - major_count <= 5
  action: 进入 Phase 6 Delivery

NEEDS_IMPROVEMENT:
  conditions:
    - blocker_count == 0
    - critical_count IN [1, 2] OR major_count > 5
  action: 进入 Phase 5 Improvement，然后回到 Phase 2

REJECTED:
  conditions:
    - blocker_count > 0
    - OR critical_count > 2
    - OR tests_passed == false
    - OR git_is_dirty == true
  action: 停止流程，通知用户
```

## 循环控制

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| max_rounds | 3 | 最大审查轮次 |
| consecutive_reject_limit | 2 | 连续 REJECTED 次数限制 |
| early_exit_confidence | 0.9 | 早期退出置信度阈值 |

## 早期退出机制

当满足以下条件时，可提前退出审查循环：

```yaml
early_exit_conditions:
  - reviewer_confidence >= 0.9
  - blocker_count == 0
  - critical_count == 0
  - major_count <= 2
```
