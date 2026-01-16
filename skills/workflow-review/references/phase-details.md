# 阶段详情文档

> 本文档包含 workflow-review 各阶段的详细子任务、代码示例和错误处理。

---

## 1. COLLECT 阶段

### 1.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 1.1.1 | 验证 implement 目录存在 | 验证结果 |
| 1.1.2 | 读取 implement 日志 | implement-log.md |
| 1.1.3 | 运行测试 | test-results.txt |
| 1.1.4 | 运行 lint | lint-results.txt |
| 1.1.5 | 生成覆盖率报告 | coverage-report.txt |
| 1.1.6 | 生成代码变更 diff | changes.diff |
| 1.1.7 | 初始化状态文件 | .state.yaml |

### 1.2 代码示例

```python
def collect_evidence(feature_path):
    """
    收集审查证据
    """
    implement_dir = f".workflow/{feature_path}/implement"
    review_dir = f".workflow/{feature_path}/review"
    evidence_dir = f"{review_dir}/evidence"

    # 1. 验证 implement 目录
    if not exists(implement_dir):
        raise Error("implement 目录不存在，请先执行 workflow-implement")

    # 2. 创建目录结构
    mkdir(evidence_dir)

    # 3. 读取 implement 日志
    copy(f"{implement_dir}/implement-report.md", f"{evidence_dir}/implement-log.md")

    # 4. 运行测试
    test_result = run_tests()
    write(f"{evidence_dir}/test-results.txt", test_result)

    # 5. 运行 lint
    lint_result = run_lint()
    write(f"{evidence_dir}/lint-results.txt", lint_result)

    # 6. 生成覆盖率
    if has_coverage_tool():
        coverage = run_coverage()
        write(f"{evidence_dir}/coverage-report.txt", coverage)

    # 7. 生成 diff
    diff = generate_diff()
    write(f"{evidence_dir}/changes.diff", diff)

    return evidence_dir
```

### 1.3 测试运行策略

```python
def run_tests():
    """
    运行项目测试，支持多种测试框架
    """
    # 检测测试框架
    if exists("package.json"):
        if has_script("test"):
            return bash("npm test")
    elif exists("pytest.ini") or exists("setup.py"):
        return bash("pytest --tb=short")
    elif exists("go.mod"):
        return bash("go test ./...")

    # 未检测到测试框架
    return {"warning": "未检测到测试框架", "skipped": True}
```

### 1.4 错误处理

| 错误 | 处理方式 |
|------|----------|
| implement 目录不存在 | 中止流程，提示用户 |
| 测试命令失败 | 记录警告，继续收集其他证据 |
| lint 工具不存在 | 记录警告，跳过 lint 收集 |
| 覆盖率工具不存在 | 记录警告，跳过覆盖率收集 |

---

## 2. ANALYZE 阶段

### 2.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 2.1.1 | 解析测试结果 | 测试统计 |
| 2.1.2 | 解析 lint 结果 | lint 统计 |
| 2.1.3 | 代码质量分析 | 质量评分 |
| 2.1.4 | 规范合规检查 | 合规评分 |
| 2.1.5 | 安全检查 | 安全评分 |
| 2.1.6 | 性能检查 | 性能评分 |
| 2.1.7 | 生成维度报告 | dimension-report.md |

### 2.2 代码示例

```python
def analyze_evidence(evidence_dir, spec_path):
    """
    多维度分析证据
    """
    results = {}

    # 1. 代码质量
    results["code_quality"] = analyze_code_quality(evidence_dir)

    # 2. 测试覆盖
    results["test_coverage"] = analyze_test_coverage(evidence_dir)

    # 3. 规范合规
    results["spec_compliance"] = analyze_spec_compliance(evidence_dir, spec_path)

    # 4. 安全检查
    results["security"] = analyze_security(evidence_dir)

    # 5. 性能检查
    results["performance"] = analyze_performance(evidence_dir)

    # 生成报告
    report = generate_dimension_report(results)
    write("analysis/dimension-report.md", report)

    return results
```

### 2.3 维度分析详情

#### 代码质量分析

```python
def analyze_code_quality(evidence_dir):
    """
    分析代码质量
    """
    issues = []

    # 解析 lint 结果
    lint_result = parse_lint_results(f"{evidence_dir}/lint-results.txt")
    issues.extend(categorize_lint_issues(lint_result))

    # 检查复杂度
    diff = read(f"{evidence_dir}/changes.diff")
    complexity_issues = check_complexity(diff)
    issues.extend(complexity_issues)

    # 计算得分
    score = calculate_score(issues)

    return {
        "score": score,
        "issues": issues,
        "passed": len([i for i in issues if i.severity in ["BLOCKER", "CRITICAL"]]) == 0
    }
```

#### 安全检查

```python
def analyze_security(evidence_dir):
    """
    安全检查
    """
    issues = []
    diff = read(f"{evidence_dir}/changes.diff")

    # 检查硬编码密钥
    secret_patterns = [
        r"password\s*=\s*['\"][^'\"]+['\"]",
        r"api_key\s*=\s*['\"][^'\"]+['\"]",
        r"secret\s*=\s*['\"][^'\"]+['\"]",
    ]
    for pattern in secret_patterns:
        matches = regex_search(diff, pattern)
        for match in matches:
            issues.append({
                "severity": "BLOCKER",
                "type": "hardcoded_secret",
                "message": f"可能的硬编码密钥: {match.group()[:20]}...",
                "line": match.line
            })

    # 检查 SQL 注入
    sql_patterns = [
        r"execute\([^)]*\+[^)]*\)",
        r"query\([^)]*\+[^)]*\)",
    ]
    # ... 类似检查

    return {
        "score": 1.0 if not issues else 0.5,
        "issues": issues,
        "passed": len([i for i in issues if i.severity == "BLOCKER"]) == 0
    }
```

---

## 3. REVIEW 阶段

### 3.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 3.1.1 | 构建证据包 | review-prompt.md |
| 3.1.2 | 启动独立 Agent | Agent ID |
| 3.1.3 | 等待审查完成 | review-response.md |

### 3.2 独立审查 Prompt 模板

```markdown
# 独立代码审查

请审查以下代码实现，从五个维度进行评估。

## 证据

### 测试结果
{test_results}

### Lint 结果
{lint_results}

### 覆盖率
{coverage_report}

### 代码变更
{changes_diff}

### 规范摘要
{spec_summary}

## 审查维度

1. **代码质量**: 检查代码规范、异味、复杂度（圈复杂度 ≤15）
2. **测试覆盖**: 检查通过率（需 100%）和覆盖率（需 ≥80%）
3. **规范合规**: 检查是否符合 spec.md 验收标准
4. **安全检查**: 检查硬编码密钥、SQL 注入、XSS
5. **性能检查**: 检查 O(n²) 循环、资源泄露

## 输出格式

请输出结构化审查报告，包含：
- 每个维度的评分和问题列表
- 问题严重程度：BLOCKER/CRITICAL/MAJOR/MINOR
- 综合判定建议
```

### 3.3 代码示例

```python
def invoke_independent_review(evidence_dir, analysis_results):
    """
    调用独立审查 Agent
    """
    # 构建证据包
    evidence_pack = build_evidence_pack(evidence_dir)

    # 构建 prompt
    prompt = render_review_prompt(evidence_pack, analysis_results)
    write("reviews/round-{N}/review-prompt.md", prompt)

    # 启动独立 Agent
    agent_result = task(
        type="general-purpose",
        prompt=prompt,
        description="独立代码审查"
    )

    # 保存结果
    write("reviews/round-{N}/review-response.md", agent_result)

    return parse_review_response(agent_result)
```

---

## 4. VERDICT 阶段

### 4.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 4.1.1 | 解析审查结果 | 问题列表 |
| 4.1.2 | 分类问题严重程度 | 分类统计 |
| 4.1.3 | 计算判定 | PASS/NEEDS_FIX/REJECTED |
| 4.1.4 | 更新状态 | .state.yaml |

### 4.2 判定算法

```python
def make_verdict(review_result, current_round, max_rounds=3):
    """
    根据审查结果计算判定
    """
    issues = review_result.issues
    tests_passed = review_result.tests_passed

    # 统计问题数量
    blocker_count = count_by_severity(issues, "BLOCKER")
    critical_count = count_by_severity(issues, "CRITICAL")
    major_count = count_by_severity(issues, "MAJOR")
    minor_count = count_by_severity(issues, "MINOR")

    # 判定逻辑
    if blocker_count > 0 or critical_count > 2 or not tests_passed:
        return "REJECTED"

    if current_round >= max_rounds:
        return "REJECTED"

    if critical_count > 0 or major_count > 5:
        return "NEEDS_FIX"

    return "PASS"
```

---

## 5. IMPROVE 阶段

### 5.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 5.1.1 | 识别失败任务 | 任务列表 |
| 5.1.2 | 分析问题根因 | 根因分析 |
| 5.1.3 | 生成修复指令 | fix-instructions.md |
| 5.1.4 | 调用 workflow-implement | 执行结果 |
| 5.1.5 | 记录改进日志 | fix-log.md |

### 5.2 代码示例

```python
def trigger_improvement(verdict_result, feature_path):
    """
    触发改进流程
    """
    # 1. 识别需要修复的任务
    failed_tasks = identify_failed_tasks(verdict_result)

    # 2. 生成修复指令
    fix_instructions = generate_fix_instructions(failed_tasks)
    write(f"improvements/round-{N}/fix-instructions.md", fix_instructions)

    # 3. 调用 workflow-implement
    implement_result = invoke_workflow_implement(
        feature_path,
        tasks=failed_tasks,
        mode="retry"
    )

    # 4. 记录改进日志
    fix_log = generate_fix_log(failed_tasks, implement_result)
    write(f"improvements/round-{N}/fix-log.md", fix_log)

    # 5. 触发重新审查
    return trigger_review_collect(feature_path)
```

---

## 6. REPORT 阶段

### 6.1 子任务列表

| 子任务 | 描述 | 输出 |
|--------|------|------|
| 6.1.1 | 汇总审查历史 | 历史记录 |
| 6.1.2 | 统计问题修复 | 修复统计 |
| 6.1.3 | 生成最终状态 | 状态摘要 |
| 6.1.4 | 生成建议 | 建议列表 |
| 6.1.5 | 渲染报告 | final-report.md |

### 6.2 代码示例

```python
def generate_final_report(state, evidence_dir):
    """
    生成最终审查报告
    """
    # 读取模板
    template = read("assets/report-template.md")

    # 收集数据
    data = {
        "feature": state.feature,
        "timestamp": now(),
        "verdict": "PASS",
        "total_rounds": len(state.reviews),
        "confidence": calculate_confidence(state.reviews),
        # ... 其他数据
    }

    # 渲染报告
    report = render_template(template, data)

    # 写入文件
    write("final-report.md", report)

    return report
```

---

## 7. 状态文件格式

详见 [assets/state-template.yaml](../assets/state-template.yaml)

---

*Reference document for workflow-review phase details | v1.0.0*
