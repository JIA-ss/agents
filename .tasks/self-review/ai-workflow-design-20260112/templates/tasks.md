# Task Breakdown: {feature-name}

> **Spec**: .agent/specs/{feature-id}/spec.md
> **Plan**: .agent/specs/{feature-id}/plan.md
> **Date**: {date}

---

## Task Legend

| 标记 | 含义 |
|------|------|
| `[T]` | Test-First: 先写测试 |
| `[P]` | Parallelizable: 可并行 |
| `[R]` | Requires Review: 需人工审查 |
| `[D]` | Documentation: 文档任务 |

---

## Task List

### Phase 1: Foundation

- [ ] **T1** `[T]` Write unit tests for {core-module}
  - File: `tests/{module}.test.ts`
  - Coverage: {要测试的函数/类}

- [ ] **T2** Implement {core-module}
  - Depends on: T1
  - Files: `src/{module}.ts`
  - AC: Tests pass

### Phase 2: Implementation

- [ ] **T3** `[T][P]` Write tests for {feature-A}
  - File: `tests/{feature-a}.test.ts`

- [ ] **T4** `[T][P]` Write tests for {feature-B}
  - File: `tests/{feature-b}.test.ts`

- [ ] **T5** Implement {feature-A}
  - Depends on: T2, T3
  - Files: `src/{feature-a}.ts`

- [ ] **T6** Implement {feature-B}
  - Depends on: T2, T4
  - Files: `src/{feature-b}.ts`

### Phase 3: Integration

- [ ] **T7** `[R]` Integration testing
  - Depends on: T5, T6
  - Run: `npm run test:integration`

- [ ] **T8** `[D]` Update documentation
  - Files: `docs/{feature}.md`, `README.md`

### Phase 4: Finalization

- [ ] **T9** Code cleanup and refactoring
  - Review: TODOs, console.logs, dead code

- [ ] **T10** Final review submission
  - Command: `/self-review`

---

## Dependency Graph

```
T1 ──→ T2 ──┬──→ T5 ──┬──→ T7 ──→ T9 ──→ T10
            │         │
T3 ─────────┘         │
            │         │
T4 ──────────→ T6 ────┘
                      │
T8 ───────────────────┘
```

## Parallel Execution Plan

| 批次 | 任务 | 预计时间 |
|------|------|----------|
| Batch 1 | T1 | - |
| Batch 2 | T2 | - |
| Batch 3 | T3, T4 | - |
| Batch 4 | T5, T6 | - |
| Batch 5 | T7, T8 | - |
| Batch 6 | T9, T10 | - |

---

## Progress

| 任务 | 状态 | 完成时间 | 备注 |
|------|------|----------|------|
| T1 | ⬜ Pending | | |
| T2 | ⬜ Pending | | |
| ... | | | |

---

## Notes

{执行过程中的备注}

---

*Template version: 1.0*
