# CLAUDE.local.md

全程使用中文交流。

## 项目概述

**ecommerce-api** - 电商平台后端 API 服务。技术栈：Node.js + Express + MySQL。
- `src/routes/` - API 路由定义
- `src/controllers/` - 业务控制器
- `src/models/` - 数据模型（Sequelize ORM）
- `src/middlewares/` - 中间件（认证、限流、错误处理）
- `src/services/` - 业务逻辑服务层

## Skill 驱动开发（强制）

**每次开发/修复必须遵循此流程：**

```
1. 定位 Skill → 2. 阅读上下文 → 3. 执行任务 → 4. 智能 Sync
```

### Skill 目录

路径：`.claude/skills/`

### 开发流程

| 步骤 | 操作 | 说明 |
|------|------|------|
| 定位 | 在 `.claude/skills/` 查找 | 按系统名称匹配 |
| 阅读 | 打开 `SKILL.md` | 了解架构、API、常见陷阱 |
| 执行 | 按 Skill 指导完成任务 | - |
| Sync | 智能判断是否更新 | 见下方规则 |

### 智能 Sync 规则

代码修改后，基于变更类型判断是否更新 Skill：

| 变更类型 | Sync | 说明 |
|----------|------|------|
| API 签名变化（方法名/参数/返回值） | 必须 | 影响使用方式 |
| 新增公开参数/属性 | 必须 | 新增可配置项 |
| 删除/重命名功能 | 必须 | 影响使用方式 |
| 默认值修改 | 必须 | 影响默认行为 |
| 环境变量/配置项变化 | 必须 | 影响部署方式 |
| Bug 修复（内部逻辑） | 跳过 | 不影响外部接口 |
| 性能优化（无 API 变化） | 跳过 | 不影响使用方式 |
| 注释/格式调整 | 跳过 | 无功能变化 |
| 不确定 | 询问 | 列出变更摘要请用户决策 |

更新 Skill 时：修改 `SKILL.md` + `.evolution/changelog.md`

### Sync 冲突处理

- **冲突检测**：依赖 Git 原生合并冲突机制
- **冲突提示**：提示用户先解决 Git 冲突
- **合并策略**：以最新代码变更为准；矛盾时人工裁决

### 废弃 Skill 检测

当加载标记 `deprecated: true` 的 Skill 时：
1. 提示"此 Skill 已废弃"
2. 读取 `superseded-by` 字段，指向替代 Skill
3. 自动加载替代 Skill 继续任务

### 无对应 Skill 时

- **可独立成 Skill**：执行 `/skill-generator` 生成新 Skill
- **通用/跨系统任务**：归入框架 Skill（如 `express-framework`）
- **Skill 内容过时**：优先更新 Skill，再继续任务

## 全局约束

- 代码规范：ESLint + Prettier，遵循 Airbnb JavaScript 风格指南
- Node.js 版本：>= 18 LTS，使用 ES Modules（`type: "module"`）
- Git 提交格式：`feat/fix/refactor/chore: <summary>`
- 证据驱动：技术方案须有理论依据，不确定时明确说明
- 安全要求：所有用户输入必须参数化查询，禁止 SQL 拼接；密码使用 bcrypt 哈希；JWT 过期时间不超过 24h
- 错误处理：所有 async 函数必须有 try-catch 或统一错误中间件处理
- 环境变量：敏感信息（数据库密码、密钥等）必须通过 `.env` 文件管理，禁止硬编码

## Skill 索引

<!-- SKILL-INDEX-START -->
| Skill | 路径 | 说明 |
|-------|------|------|
| payment-system | `.claude/skills/payment-system/` | 支付系统 |
<!-- SKILL-INDEX-END -->
