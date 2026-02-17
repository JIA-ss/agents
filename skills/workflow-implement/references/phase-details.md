# 阶段详细说明

> 本文档包含 workflow-implement 各阶段的完整子任务、代码示例和判定规则。

---

## 目录

1. [LOAD 阶段](#1-load-阶段)
2. [PLAN 阶段](#2-plan-阶段)
3. [EXECUTE 阶段](#3-execute-阶段)
4. [REVIEW 阶段](#4-review-阶段)
5. [COMMIT 阶段](#5-commit-阶段)
6. [REPORT 阶段](#6-report-阶段)

---

## 1. LOAD 阶段

### 1.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 1.1 | 验证 tasks.md 存在 | 文件路径 | 布尔值 |
| 1.2 | 验证 tasks.md 状态为 approved | frontmatter | 布尔值 |
| 1.3 | 解析 frontmatter | tasks.md | 元信息对象 |
| 1.4 | 解析任务列表 | tasks.md 内容 | 任务数组 |
| 1.5 | 提取依赖关系 | 任务数组 | 依赖映射 |
| 1.6 | 构建 DAG | 依赖映射 | DAG 结构 |
| 1.7 | 检测循环依赖 | DAG | 布尔值 + 循环路径 |
| 1.8 | 初始化状态文件 | 任务列表 | .state.yaml |

### 1.2 任务解析格式

**输入格式** (tasks.md):
```markdown
| ID | 任务 | 优先级 | 估时 | 依赖 | 标记 | 模块 | 状态 |
|----|------|--------|------|------|------|------|------|
| T1.1 | 任务标题 | P0 | 1h | - | [P] | MODULE | [ ] |
| T1.2 | 任务标题 | P1 | 2h | T1.1 | [T][P] | MODULE | [ ] |
```

**解析结果**:
```python
{
    "id": "T1.1",
    "title": "任务标题",
    "priority": "P0",
    "estimate": "1h",
    "dependencies": [],
    "markers": ["P"],
    "module": "MODULE",
    "status": "pending"
}
```

### 1.3 循环依赖检测

```python
def detect_cycle(dag):
    visited = set()
    rec_stack = set()
    path = []

    def dfs(node):
        visited.add(node)
        rec_stack.add(node)
        path.append(node)

        for neighbor in dag.get(node, []):
            if neighbor not in visited:
                if dfs(neighbor):
                    return True
            elif neighbor in rec_stack:
                cycle_start = path.index(neighbor)
                raise CycleDetected(path[cycle_start:])

        path.pop()
        rec_stack.remove(node)
        return False

    for node in dag:
        if node not in visited:
            dfs(node)
```

### 1.4 错误处理

| 错误码 | 错误类型 | 处理方式 |
|--------|----------|----------|
| E001 | tasks.md 不存在 | 中止，提示正确路径 |
| E002 | 状态非 approved | 中止，提示先运行 workflow-task |
| E003 | 循环依赖 | 中止，显示循环路径 |
| E004 | 无效的任务格式 | 中止，显示解析错误 |

---

## 2. PLAN 阶段

### 2.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 2.1 | 拓扑排序 | DAG | 有序任务列表 |
| 2.2 | 识别并行批次 | DAG + 有序列表 | 批次数组 |
| 2.3 | 计算关键路径 | DAG + 估时 | 关键路径列表 |
| 2.4 | 生成执行计划 | 批次 + 关键路径 | 执行计划对象 |

### 2.2 拓扑排序算法

```python
def topological_sort(dag):
    in_degree = {node: 0 for node in dag}
    for node in dag:
        for neighbor in dag[node]:
            in_degree[neighbor] += 1

    queue = [node for node in in_degree if in_degree[node] == 0]
    result = []

    while queue:
        node = queue.pop(0)
        result.append(node)
        for neighbor in dag.get(node, []):
            in_degree[neighbor] -= 1
            if in_degree[neighbor] == 0:
                queue.append(neighbor)

    return result
```

### 2.3 并行批次划分

```python
def identify_batches(dag, sorted_tasks):
    batches = []
    assigned = set()

    while len(assigned) < len(sorted_tasks):
        batch = []
        for task in sorted_tasks:
            if task in assigned:
                continue
            deps = dag.get_dependencies(task)
            if all(d in assigned for d in deps):
                batch.append(task)

        batches.append(batch)
        assigned.update(batch)

    return batches
```

### 2.4 关键路径计算

```python
def calculate_critical_path(dag, estimates):
    # 计算每个任务的最早开始时间和最晚开始时间
    earliest = {}
    latest = {}

    # 前向遍历计算 earliest
    for task in topological_sort(dag):
        deps = dag.get_dependencies(task)
        if not deps:
            earliest[task] = 0
        else:
            earliest[task] = max(
                earliest[d] + estimates[d] for d in deps
            )

    # 后向遍历计算 latest
    total_time = max(earliest[t] + estimates[t] for t in dag)
    for task in reversed(topological_sort(dag)):
        successors = dag.get_successors(task)
        if not successors:
            latest[task] = total_time - estimates[task]
        else:
            latest[task] = min(
                latest[s] - estimates[task] for s in successors
            )

    # 关键路径: earliest == latest 的任务
    critical_path = [t for t in dag if earliest[t] == latest[t]]
    return critical_path
```

---

## 3. EXECUTE 阶段

### 3.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 3.1 | 获取当前批次 | 执行计划 + 状态 | 任务列表 |
| 3.2 | 分类任务 | 任务列表 | 并行/顺序分组 |
| 3.3 | 执行并行任务 | 并行任务组 | 执行结果 |
| 3.4 | 执行顺序任务 | 顺序任务列表 | 执行结果 |
| 3.5 | 执行 TDD 任务 | [T] 标记任务 | 执行结果 |
| 3.6 | 更新状态 | 执行结果 | .state.yaml |
| 3.7 | 记录日志 | 执行过程 | logs/ |
| 3.8 | 记录审计账本 | 外部命令执行 | audit/ledger.jsonl |

> 执行任何外部命令时，必须使用：
> `python skills/workflow-implement/scripts/workflow_audit.py run --state .workflow/{feature}/implement/audit/state.json ...`

### 3.2 TDD 执行详细流程

```python
def execute_tdd_task(task):
    """
    TDD 五步循环
    """
    # 步骤 1: 编写测试
    test_file = write_test(task)
    log(f"[TDD] 测试文件已创建: {test_file}")

    # 步骤 2: 验证红灯
    result = run_tests(test_file)
    if result.passed:
        raise TDDError(
            "测试应该失败但通过了。"
            "请检查测试是否正确验证了未实现的功能。"
        )
    log(f"[TDD] 红灯验证通过: {result.failed_count} 个测试失败")

    # 步骤 3: 编写实现
    impl_file = implement_code(task)
    log(f"[TDD] 实现代码已创建: {impl_file}")

    # 步骤 4: 验证绿灯
    result = run_tests(test_file)
    if not result.passed:
        return TaskResult(
            status="failed",
            error=f"测试未通过: {result.failed_tests}"
        )
    log(f"[TDD] 绿灯验证通过: {result.passed_count} 个测试通过")

    # 步骤 5: 可选重构
    if should_refactor(task):
        refactor_code(task)
        result = run_tests(test_file)
        if not result.passed:
            rollback_refactor(task)
            log("[TDD] 重构后测试失败，已回滚")

    return TaskResult(status="completed")
```

### 3.3 并行执行实现

```python
def execute_parallel_tasks(tasks, max_concurrent=5):
    """
    使用 Task 工具并行执行任务
    """
    results = {}
    pending = list(tasks)

    while pending:
        batch = pending[:max_concurrent]
        pending = pending[max_concurrent:]

        # 并行启动
        agents = []
        for task in batch:
            agent = Task(
                prompt=build_task_prompt(task),
                subagent_type="general-purpose",
                description=f"实现 {task.id}"
            )
            agents.append((task.id, agent))

        # 等待完成
        for task_id, agent in agents:
            result = agent.wait()
            results[task_id] = parse_result(result)

    return results
```

### 3.4 失败处理详细规则

| 优先级 | 失败类型 | 处理方式 | 后续任务 |
|--------|----------|----------|----------|
| P0 | 任何失败 | 立即中止 | 全部取消 |
| P1 | 任何失败 | 立即中止 | 全部取消 |
| P2 | 临时错误 | 重试 3 次 | 等待重试结果 |
| P2 | 永久错误 | 跳过 | 依赖任务也跳过 |
| P3 | 任何失败 | 跳过 | 继续执行 |

### 3.5 重试策略实现

```python
def execute_with_retry(task, max_attempts=3):
    """
    带重试的任务执行
    """
    for attempt in range(max_attempts):
        try:
            result = execute_task(task)
            return result
        except TemporaryError as e:
            if attempt < max_attempts - 1:
                wait_time = 2 ** attempt  # 指数退避
                log(f"临时错误，{wait_time}秒后重试: {e}")
                time.sleep(wait_time)
            else:
                raise

def is_temporary_error(error):
    """判断是否为临时错误"""
    temporary_types = [
        "NetworkTimeout",
        "ResourceLocked",
        "ServiceUnavailable",
        "RateLimitExceeded"
    ]
    return type(error).__name__ in temporary_types
```

---

## 4. REVIEW 阶段

### 4.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 4.1 | 运行测试套件 | 变更文件 | 测试结果 |
| 4.2 | 运行 Lint 检查 | 变更文件 | Lint 结果 |
| 4.3 | 计算任务完成率 | 任务状态 | 完成率 |
| 4.4 | 生成审查报告 | 检查结果 | 审查报告 |
| 4.5 | 判定结果 | 审查报告 | PASS/NEEDS_FIX/REJECTED |

### 4.2 检查项详细说明

#### 测试通过率检查

```python
def check_tests():
    result = run_all_tests()
    return {
        "passed": result.passed_count == result.total_count,
        "pass_rate": result.passed_count / result.total_count * 100,
        "failed_tests": result.failed_tests,
        "threshold": 100  # 必须 100% 通过
    }
```

#### Lint 检查

```python
def check_lint():
    result = run_linter()
    return {
        "passed": result.error_count == 0,
        "errors": result.errors,
        "warnings": result.warnings,
        "threshold": 0  # 必须 0 个错误
    }
```

#### 任务完成率检查

```python
def check_completion(tasks):
    completed = sum(1 for t in tasks if t.status == "completed")
    total = len(tasks)

    # 按优先级加权
    p0_p1 = [t for t in tasks if t.priority in ["P0", "P1"]]
    p0_p1_completed = sum(1 for t in p0_p1 if t.status == "completed")

    return {
        "total_rate": completed / total * 100,
        "critical_rate": p0_p1_completed / len(p0_p1) * 100 if p0_p1 else 100,
        "passed": p0_p1_completed == len(p0_p1)  # 关键任务必须全部完成
    }
```

### 4.3 判定逻辑

```python
def determine_verdict(checks, review_round, max_rounds=3):
    # 关键任务失败 -> REJECTED
    if not checks["completion"]["passed"]:
        return "REJECTED"

    # 测试或 Lint 不通过
    if not checks["tests"]["passed"] or not checks["lint"]["passed"]:
        if review_round >= max_rounds:
            return "REJECTED"
        return "NEEDS_FIX"

    return "PASS"
```

### 4.4 审查报告格式

```markdown
# 审查报告 - Round {N}

## 判定: {PASS/NEEDS_FIX/REJECTED}

## 检查结果

| 检查项 | 结果 | 详情 |
|--------|------|------|
| 测试通过率 | {rate}% | {passed}/{total} 通过 |
| Lint 错误 | {count} | {errors} |
| 任务完成率 | {rate}% | {completed}/{total} 完成 |

## 问题列表 (如有)

| # | 类型 | 任务 | 描述 |
|---|------|------|------|
| 1 | test_failure | T2.1 | 2 个测试失败 |

## 建议修复

1. 修复 T2.1 的测试失败问题
2. ...
```

---

## 5. COMMIT 阶段

### 5.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 5.1 | 检测变更文件 | 任务 ID | 文件列表 |
| 5.2 | 关联任务和文件 | 变更文件 | 任务-文件映射 |
| 5.3 | 生成 commit message | 任务信息 | message 字符串 |
| 5.4 | 执行 git commit | 文件 + message | commit SHA |
| 5.5 | 记录到 commit-log | commit 信息 | commit-log.md |

### 5.2 Commit Message 生成

```python
def generate_commit_message(task):
    """
    生成符合格式的 commit message
    """
    title = f"task({task.id}): {task.title}"

    body_lines = []
    if task.description:
        body_lines.append(f"- {task.description}")
    if task.related_us:
        body_lines.append(f"- 关联需求: {task.related_us}")

    body = "\n".join(body_lines)

    return f"{title}\n\n{body}"
```

### 5.3 Git 操作

```python
def commit_task(task, files):
    """
    为任务创建 git commit
    """
    if not files:
        log(f"任务 {task.id} 无文件变更，跳过提交")
        return None

    try:
        # Stage 文件
        for file in files:
            run_command(f"git add {file}")

        # 生成 message
        message = generate_commit_message(task)

        # 提交
        result = run_command(f'git commit -m "{message}"')
        sha = parse_commit_sha(result)

        return sha
    except GitError as e:
        log(f"Git 提交失败: {e}")
        return None  # 不阻塞流程
```

---

## 6. REPORT 阶段

### 6.1 子任务列表

| # | 子任务 | 输入 | 输出 |
|---|--------|------|------|
| 6.1 | 汇总执行结果 | .state.yaml | 统计数据 |
| 6.2 | 生成任务详情表 | 任务状态 | Markdown 表格 |
| 6.3 | 生成审查摘要 | 审查历史 | 摘要文本 |
| 6.4 | 生成后续建议 | 执行状态 | 建议列表 |
| 6.5 | 写入报告文件 | 所有内容 | implement-report.md |

### 6.2 报告模板

```markdown
# workflow-implement 执行报告

> **Feature**: {feature-id}
> **执行时间**: {start_time} - {end_time}
> **总耗时**: {duration}

---

## 执行摘要

| 指标 | 值 |
|------|-----|
| 总任务数 | {total} |
| 已完成 | {completed} |
| 已跳过 | {skipped} |
| 失败 | {failed} |
| 完成率 | {rate}% |

---

## 任务详情

| ID | 任务 | 状态 | 耗时 | Commit |
|----|------|------|------|--------|
| T1.1 | {title} | {status} | {duration} | {sha} |

---

## 审查结果

- **审查轮次**: {rounds}
- **最终判定**: {verdict}
- **测试通过率**: {test_rate}%
- **Lint 状态**: {lint_status}

---

## 提交统计

| 指标 | 值 |
|------|-----|
| 总提交数 | {commits} |
| 新增文件 | {added} |
| 修改文件 | {modified} |
| 删除文件 | {deleted} |

---

## 后续步骤

- [ ] 使用 `/workflow-review` 进行深度代码审查
- [ ] 合并到主分支
- [ ] 更新相关文档

---

*Generated by workflow-implement REPORT phase | {date}*
```

---

*Generated by skill-generator | 2026-01-16*
