# Project Constitution

> 本文档定义项目的核心原则、约束和规范。
> AI Agent 在执行任务时必须遵守这些规则。

---

## 1. Project Identity

| 属性 | 值 |
|------|-----|
| **项目名称** | {project-name} |
| **项目类型** | {web-app / api / library / cli} |
| **主要语言** | {TypeScript / Python / Go / Rust} |
| **框架** | {React / Next.js / Express / FastAPI} |

---

## 2. Core Principles

### 2.1 代码质量

1. **可读性优先**: 代码是写给人看的，其次才是机器
2. **简单性**: 选择最简单的解决方案，除非有明确理由
3. **测试覆盖**: 所有业务逻辑必须有测试覆盖
4. **类型安全**: 充分利用类型系统，避免运行时错误

### 2.2 安全性

1. **无硬编码敏感信息**: 所有密钥、凭证使用环境变量
2. **输入验证**: 所有外部输入必须验证和清理
3. **最小权限**: 只请求必要的权限
4. **依赖审计**: 定期检查依赖安全性

### 2.3 可维护性

1. **单一职责**: 每个函数/类只做一件事
2. **模块化**: 高内聚，低耦合
3. **文档化**: 公共 API 必须有文档
4. **一致性**: 遵循项目既定模式

---

## 3. Constraints (硬性约束)

### 3.1 代码规模限制

| 约束 | 限制 | 说明 |
|------|------|------|
| 函数行数 | ≤ 50 行 | 超过则拆分 |
| 文件行数 | ≤ 300 行 | 超过则模块化 |
| 函数参数 | ≤ 4 个 | 超过使用对象参数 |
| 嵌套深度 | ≤ 3 层 | 超过则提取函数 |

### 3.2 类型约束

```typescript
// ❌ 禁止
function process(data: any) { ... }
const result = value as unknown as SomeType;

// ✅ 允许
function process(data: ValidatedInput) { ... }
const result = validateAndParse(value);
```

### 3.3 禁止模式

- ❌ 使用 `any` 类型
- ❌ 禁用 lint 规则 (`// eslint-disable`)
- ❌ 空的 catch 块
- ❌ 同步文件操作 (Node.js)
- ❌ 魔法数字/字符串
- ❌ 重复代码 (DRY)

---

## 4. Conventions (约定)

### 4.1 命名规范

| 类型 | 规范 | 示例 |
|------|------|------|
| 变量/函数 | camelCase | `getUserById` |
| 类/接口/类型 | PascalCase | `UserService` |
| 常量 | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| 文件 | kebab-case | `user-service.ts` |
| 组件文件 | PascalCase | `UserProfile.tsx` |

### 4.2 文件组织

```
src/
├── components/          # UI 组件
├── hooks/              # React Hooks
├── services/           # 业务逻辑
├── utils/              # 工具函数
├── types/              # 类型定义
└── constants/          # 常量

tests/                   # 测试文件 (推荐: 与 src 平级)
├── unit/               # 单元测试
├── integration/        # 集成测试
└── e2e/                # 端到端测试
```

**Note**: 测试目录约定为 `tests/`，与源码目录平级。

### 4.3 提交规范

使用 Conventional Commits:

```
<type>(<scope>): <subject>

<body>

<footer>
```

Types:
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 格式调整
- `refactor`: 重构
- `test`: 测试
- `chore`: 构建/工具

### 4.4 注释规范

```typescript
// ✅ 好的注释 - 解释为什么
// 使用指数退避，避免在服务恢复时造成惊群效应
const delay = Math.pow(2, retryCount) * 1000;

// ❌ 坏的注释 - 解释是什么
// 计算延迟时间
const delay = Math.pow(2, retryCount) * 1000;
```

---

## 5. Error Handling

### 5.1 错误分类

| 类型 | 处理方式 |
|------|----------|
| 预期错误 | 返回 Result/Option 类型 |
| 系统错误 | 抛出异常，上层捕获 |
| 致命错误 | 记录并安全终止 |

### 5.2 错误信息

```typescript
// ✅ 好的错误信息
throw new Error(`User ${userId} not found in organization ${orgId}`);

// ❌ 坏的错误信息
throw new Error('Not found');
```

---

## 6. Performance Guidelines

1. **避免 N+1 查询**: 使用批量查询
2. **合理缓存**: 对不变数据使用缓存
3. **懒加载**: 按需加载大型模块
4. **避免阻塞**: 使用异步操作

---

## 7. Review Checklist

提交前检查:

- [ ] 所有测试通过
- [ ] 无 lint 错误
- [ ] 无 TypeScript 错误
- [ ] 更新了相关文档
- [ ] 提交信息符合规范
- [ ] 无敏感信息泄露
- [ ] 代码符合项目约定

---

*Last updated: {date}*
