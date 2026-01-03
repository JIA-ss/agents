# Evidence Package Specification

## 证据分类原则

证据分为两类，确保审查独立性：

| 类型 | 获取方 | 原因 |
|------|--------|------|
| **Reviewer 自行获取** | Codex | 避免 Executor 篡改，确保真实性 |
| **Executor 必须提供** | Claude | 执行结果只有 Executor 知道 |

## Reviewer 自行获取的证据

| 证据 | 命令 | 说明 |
|------|------|------|
| Git Diff | `git diff {base_commit}..{target_commit}` | 代码变更内容 |
| Git State | `git status --porcelain` | 检查是否 dirty |
| Git Log | `git log --oneline -5` | 最近提交记录 |
| 文件内容 | `cat {file}` | 直接读取相关代码 |

**Reviewer 必须验证**：
```bash
# 1. 验证 commit 匹配
current_commit=$(git rev-parse HEAD)
if [ "$current_commit" != "{executor_claimed_commit}" ]; then
  echo "REJECTED: Commit mismatch"
fi

# 2. 验证代码干净
if [ -n "$(git status --porcelain)" ]; then
  echo "REJECTED: Working directory is dirty"
fi
```

## Executor 必须提供的证据

| 文件 | 格式 | 说明 |
|------|------|------|
| `execution-manifest.json` | JSON | 执行清单（命令、时间、版本） |
| `test-results.txt` | Text | 测试执行的完整输出 |
| `lint-results.txt` | Text | Lint 检查的完整输出 |
| `requirement-mapping.md` | Markdown | 需求-代码映射 |

## Optional Evidence

| 文件 | 触发条件 |
|------|----------|
| `coverage-report.txt` | 有测试覆盖率工具 |
| `security-scan.txt` | 涉及安全相关变更 |
