# Technical Plan: {feature-name}

> **Spec Reference**: .agent/specs/{feature-id}/spec.md
> **Status**: Draft | Review | Approved
> **Date**: {date}

---

## Technical Approach

### Summary

{技术方案的一句话总结}

### Solution Architecture

```
{架构图或组件关系}
```

### Key Components

| 组件 | 职责 | 技术选型 |
|------|------|----------|
| {组件1} | {职责} | {技术} |
| {组件2} | {职责} | {技术} |

## Architecture Decisions

### Decision 1: {决策标题}

- **Context**: {背景}
- **Options**:
  1. {选项1} - {优缺点}
  2. {选项2} - {优缺点}
- **Decision**: {最终决策}
- **Rationale**: {理由}

### Decision 2: {决策标题}

- **Context**: {背景}
- **Decision**: {最终决策}
- **Rationale**: {理由}

## Dependencies

### External Dependencies

| 依赖 | 版本 | 用途 | 风险 |
|------|------|------|------|
| {依赖1} | {版本} | {用途} | {风险等级} |

### Internal Dependencies

- {内部模块/服务依赖}

## Data Model

```typescript
// 核心数据结构
interface {Entity} {
  id: string;
  // ...
}
```

## API Design

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | /api/{resource} | {描述} |
| GET | /api/{resource}/{id} | {描述} |

## Testing Strategy

| 测试类型 | 覆盖范围 | 工具 |
|----------|----------|------|
| Unit | 核心逻辑 | Jest |
| Integration | API 端点 | Supertest |
| E2E | 关键流程 | Playwright |

## Risks

| 风险 | 影响 | 概率 | 缓解措施 |
|------|------|------|----------|
| {风险1} | High/Medium/Low | High/Medium/Low | {措施} |

## Milestones

| 里程碑 | 交付物 | 验收标准 |
|--------|--------|----------|
| M1 | {交付物} | {标准} |
| M2 | {交付物} | {标准} |

---

## Review Notes

{技术评审意见记录}

---

*Template version: 1.0*
