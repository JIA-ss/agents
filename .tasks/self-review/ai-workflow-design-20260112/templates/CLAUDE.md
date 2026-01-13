# CLAUDE.md

> AI Agent 项目配置文件

---

## Project Overview

**{project-name}** - {一句话描述}

{详细描述项目的目的、功能和目标用户}

## Tech Stack

| 层级 | 技术 |
|------|------|
| Frontend | {React / Vue / Next.js} |
| Backend | {Node.js / Python / Go} |
| Database | {PostgreSQL / MongoDB / Redis} |
| Infrastructure | {Docker / K8s / AWS} |

## Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Client    │ ──→ │   API       │ ──→ │  Database   │
│  (React)    │     │  (Express)  │     │ (PostgreSQL)│
└─────────────┘     └─────────────┘     └─────────────┘
```

{或者更详细的架构说明}

## Development Commands

```bash
# 安装依赖
npm install

# 开发模式
npm run dev

# 运行测试
npm test

# 运行测试 (watch mode)
npm test -- --watch

# Lint
npm run lint

# 类型检查
npm run typecheck

# 构建
npm run build
```

## Project Structure

```
src/
├── components/     # UI 组件
├── pages/          # 页面组件
├── hooks/          # React Hooks
├── services/       # API 服务
├── utils/          # 工具函数
├── types/          # TypeScript 类型
└── constants/      # 常量定义
```

## AI Workflow

本项目使用 `.agent/` 目录管理 AI 编程工作流。

### 启动新功能开发

```bash
# 1. 创建功能规范
# 在 .agent/specs/{feature-id}/ 创建 spec.md

# 2. 制定技术计划
# 创建 plan.md

# 3. 分解任务
# 创建 tasks.md

# 4. 按任务实现
# 遵循 tasks.md 中的顺序和依赖

# 5. 提交审查
/self-review
```

### 目录约定

- `.agent/specs/` - 功能规范文档
- `.agent/config.yaml` - 工作流配置
- `.agent/constitution.md` - 项目原则
- `.tasks/self-review/` - 审查记录

## Coding Standards

详见 `.agent/constitution.md`

### Quick Reference

- **命名**: camelCase (函数), PascalCase (类)
- **文件**: kebab-case.ts
- **提交**: Conventional Commits
- **测试**: 与源文件同名 `.test.ts`

### 禁止项

- 使用 `any` 类型
- 禁用 lint 规则
- 硬编码敏感信息
- 空的 catch 块

## Environment Variables

```bash
# .env.example
DATABASE_URL=postgresql://...
API_KEY=your-api-key
NODE_ENV=development
```

## Common Tasks

### 添加新 API 端点

1. 在 `src/routes/` 添加路由
2. 在 `src/services/` 添加业务逻辑
3. 在 `src/types/` 添加类型定义
4. 在 `tests/` 添加测试

### 添加新组件

1. 在 `src/components/` 创建组件
2. 编写 Stories (Storybook)
3. 编写测试

## Troubleshooting

### 常见问题

**Q: 测试失败**
```bash
# 清理并重新安装
rm -rf node_modules
npm install
npm test
```

**Q: 类型错误**
```bash
# 重新生成类型
npm run typecheck
```

---

*Last updated: {date}*
