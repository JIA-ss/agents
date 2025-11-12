# Fork 自定义命令 - AI 生成 Commit Message

## 📋 功能介绍

在 Fork Git 客户端中右键点击仓库，选择 "🤖 AI Commit Message (Copilot)"，自动：

- ✅ 使用 **GitHub Copilot** 分析 staged 文件的实际代码变更
- ✅ 生成符合项目规范的 commit message（英文）
- ✅ 自动执行 `git commit`，一键完成提交
- ✅ 支持跨平台：Windows / macOS / Linux
- ✅ 完全非交互式，适配 Fork 环境

## 🎯 Commit 格式规范

本工具生成的 commit message 遵循以下格式：

```
<type>: <summary>

what: <what was changed>

why: <why it was changed>
```

### Type 类型

| Type | 说明 | 示例 |
|------|------|------|
| `feat` | 新功能 | feat: add user authentication |
| `fix` | Bug 修复 | fix: resolve memory leak in parser |
| `refactor` | 重构 | refactor: simplify error handling |
| `chore` | 杂项（构建、配置等）| chore: update dependencies |
| `perf` | 性能优化 | perf: optimize database queries |
| `style` | 代码格式（不影响逻辑）| style: format code with prettier |
| `docs` | 文档 | docs: update API documentation |
| `test` | 测试 | test: add unit tests for auth module |

## 🚀 快速开始

### 前置要求

1. **Git Bash**（Windows 自带）/ Terminal（macOS/Linux）
2. **GitHub Copilot CLI**（必需）
   ```bash
   npm install -g @githubnext/github-copilot-cli
   ```
3. **GitHub Copilot 订阅**（约 $10/月）

### 1. 安装 GitHub Copilot CLI

#### 方法 1：使用 npm（推荐）

```bash
npm install -g @githubnext/github-copilot-cli
```

#### 方法 2：使用 brew（macOS）

```bash
brew install github-copilot-cli
```

#### 首次登录

安装后首次使用需要认证：

```bash
# 测试安装
copilot --version

# 首次使用会提示登录
copilot -p "test"
# 按照提示完成 GitHub 登录
```

### 2. 使用方法

**在 Fork 中：**

1. 使用 `git add` 暂存你的修改
   - 在 Fork 中：勾选要提交的文件
   - 或命令行：`git add <files>`
2. 右键点击仓库（任意位置）
3. 选择 **"🤖 AI Commit Message (Copilot)"**
4. 点击 **"生成"**
5. ✅ AI 自动分析并创建 commit

**在命令行中：**

```bash
# 1. 暂存文件
git add .

# 2. 直接运行脚本
bash .fork/generate-commit-msg.sh
```

## ⚙️ AI 分析内容

AI 会基于以下信息生成 commit message：

1. **Staged Files**：已暂存的文件列表
2. **Diff Statistics**：变更统计（插入/删除行数）
3. **Code Changes**：实际代码 diff 内容（前 200 行）

## 📊 使用场景

### 场景 1: 单个功能提交

**暂存的改动**：
```diff
+ src/auth/login.js        (新增 50 行)
+ src/auth/middleware.js   (新增 30 行)
```

**AI 生成的 commit**：
```
feat: add user login authentication

what: implemented JWT-based authentication with login endpoint and middleware

why: to secure the application and manage user sessions
```

### 场景 2: Bug 修复

**暂存的改动**：
```diff
M src/utils/parser.js      (修改 15 行)
M tests/parser.test.js     (新增 20 行)
```

**AI 生成的 commit**：
```
fix: resolve memory leak in parser

what: fixed memory leak by properly disposing parser instances after use

why: to prevent memory accumulation and improve application stability
```

### 场景 3: 重构

**暂存的改动**：
```diff
M src/api/user.js          (修改 80 行)
D src/api/user-old.js      (删除文件)
```

**AI 生成的 commit**：
```
refactor: simplify user API implementation

what: consolidated user API methods and removed deprecated code

why: to improve code maintainability and reduce complexity
```

## 🔧 工作流程

```
┌─────────────────────────────────────┐
│  1. 用户在 Fork 中暂存文件 (git add) │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  2. 选择 "🤖 AI Commit Message"     │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  3. 脚本检查 staged 文件             │
│     - 如果没有 → 提示错误            │
│     - 如果有 → 继续                  │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  4. 收集信息                         │
│     - 文件列表                       │
│     - Diff 统计                      │
│     - 代码变更（前 200 行）          │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  5. 调用 GitHub Copilot CLI         │
│     copilot -p "$PROMPT"            │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  6. 解析 AI 响应                     │
│     提取 ===COMMIT_START=== 之间     │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  7. 验证格式                         │
│     - 包含 "what:" → ✓               │
│     - 包含 "why:" → ✓                │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  8. 执行 git commit                  │
│     git commit -m "$COMMIT_MSG"     │
└─────────────┬───────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  9. ✅ 完成！显示 commit 信息        │
└─────────────────────────────────────┘
```

## 🔧 故障排除

### 问题 1: No staged files

**症状**：
```
❌ Error: No staged files found.

Please stage your changes first:
  git add <files>
```

**解决方案**：
在运行命令前先暂存文件：
- **在 Fork 中**：勾选要提交的文件
- **命令行**：`git add <files>` 或 `git add .`

### 问题 2: Copilot CLI not found

**症状**：
```
❌ Error: Copilot CLI not found.
```

**解决方案**：
```bash
# 安装 Copilot CLI
npm install -g @githubnext/github-copilot-cli

# 验证安装
copilot --version
```

### 问题 3: Copilot 未登录

**症状**：
```
❌ Error: Copilot AI generation failed.
Possible causes:
  1. No active GitHub Copilot subscription
```

**解决方案**：
```bash
# 测试并登录
copilot -p "test"

# 按照提示完成 GitHub 登录
```

### 问题 4: AI 返回空消息

**症状**：
```
❌ Error: Copilot returned an empty commit message.
```

**解决方案**：
1. 检查网络连接
2. 验证 Copilot 订阅状态
3. 查看原始输出中的错误信息
4. 尝试重新运行

### 问题 5: 格式验证警告

**症状**：
```
⚠️  Warning: Generated message doesn't contain 'what:' field
⚠️  Warning: Generated message doesn't contain 'why:' field
```

**说明**：
- 这是警告而非错误，commit 仍会创建
- AI 偶尔可能生成略有不同的格式
- 生成的内容质量通常仍然很好

**改进建议**：
- 确保暂存的改动清晰、聚焦
- 避免一次提交太多不相关的文件

### 问题 6: Commit 失败

**症状**：
```
❌ Commit failed!
```

**解决方案**：
1. 检查 git 配置：
   ```bash
   git config user.name
   git config user.email
   ```
2. 确保在 git 仓库中
3. 检查是否有 pre-commit hooks 失败
4. 查看详细的错误信息

## 💡 最佳实践

### 1. 保持提交聚焦

**✅ 推荐**：
```bash
# 一次只提交相关的改动
git add src/auth/login.js src/auth/middleware.js
```

**❌ 避免**：
```bash
# 避免一次提交太多不相关的文件
git add .  # 50+ 个文件，功能不相关
```

### 2. 提供清晰的代码变更

**✅ 推荐**：
- 清晰的函数/变量命名
- 适当的代码注释
- 逻辑清晰的改动

AI 能更好地理解清晰的代码变更！

### 3. 分步提交

对于大型功能，考虑分多个 commit：

```bash
# Commit 1: 基础结构
git add src/auth/types.js
bash .fork/generate-commit-msg.sh

# Commit 2: 核心实现
git add src/auth/login.js
bash .fork/generate-commit-msg.sh

# Commit 3: 测试
git add tests/auth.test.js
bash .fork/generate-commit-msg.sh
```

### 4. 验证生成的消息

虽然 AI 通常生成高质量的消息，但建议：
1. 查看生成的 commit message
2. 如果不满意，可以：
   - `git commit --amend` 修改
   - 或使用 `git reset --soft HEAD~1` 撤销后重试

## 🎯 AI 生成示例

### 示例 1: 新功能

**输入**：
```
Staged files:
  - src/components/LoginForm.tsx (new)
  - src/hooks/useAuth.ts (new)

Diff stats:
  2 files changed, 150 insertions(+)

Code changes:
+ export function LoginForm() {
+   const { login } = useAuth();
+   const handleSubmit = async (e) => {
+     ...
+   }
+ }
```

**输出**：
```
feat: add login form component with authentication hook

what: created LoginForm component and useAuth hook for user authentication

why: to provide users with a secure login interface and manage authentication state
```

### 示例 2: Bug 修复

**输入**：
```
Staged files:
  - src/utils/dateParser.ts

Diff stats:
  1 file changed, 5 insertions(+), 3 deletions(-)

Code changes:
- return new Date(dateString);
+ return new Date(dateString.replace(/\s/g, ''));
```

**输出**：
```
fix: handle whitespace in date string parsing

what: added whitespace trimming before parsing date strings

why: to prevent date parsing errors when input contains extra whitespace
```

### 示例 3: 重构

**输入**：
```
Staged files:
  - src/api/client.ts

Diff stats:
  1 file changed, 80 insertions(+), 120 deletions(-)

Code changes:
- async function fetchUserData() { ... }
- async function fetchUserProfile() { ... }
+ async function fetchUser(endpoint: string) { ... }
```

**输出**：
```
refactor: consolidate user API fetch methods

what: merged multiple fetch functions into a single generic fetchUser method

why: to reduce code duplication and improve maintainability
```

## 🎓 常见问题 FAQ

**Q: 必须使用 AI 生成吗？**
A: 不是！你可以继续使用 Fork 的正常 commit 流程手动输入 message。

**Q: AI 生成需要多久？**
A: 通常 5-15 秒。

**Q: 可以修改生成的 commit message 吗？**
A: 提交后可以使用 `git commit --amend` 修改。

**Q: 支持中文 commit message 吗？**
A: 当前版本生成英文 message，符合项目规范。

**Q: 需要付费吗？**
A: 需要 GitHub Copilot 订阅（约 $10/月）。

**Q: 一次可以提交多少文件？**
A: 没有限制，但建议保持 commit 聚焦（通常 1-10 个相关文件）。

**Q: AI 如何理解我的代码？**
A: AI 分析：
- 文件名和路径
- Diff 统计
- 实际代码变更（前 200 行）
- 代码结构和命名

**Q: 生成的 message 质量如何？**
A: 通常很好，特别是当：
- 代码变更清晰
- 命名规范
- 逻辑聚焦

**Q: 可以自定义格式吗？**
A: 可以！编辑 `.fork/generate-commit-msg.sh` 中的 `PROMPT` 部分，修改期望的格式。

**Q: 如果 AI 生成失败怎么办？**
A: 脚本会显示详细错误信息。你可以：
1. 查看错误原因并修复
2. 或使用 Fork 的正常 commit 流程手动输入

## 📝 技术细节

### AI Prompt 结构

脚本向 Copilot 发送的 prompt 包含：

```
Generate a git commit message following this exact format:

<type>: <summary>

what: <what was changed>

why: <why it was changed>

Where <type> must be one of: feat, fix, refactor, chore, perf, style, docs, test

Staged files:
[文件列表]

Diff stats:
[统计信息]

Code changes (partial):
[实际代码变更，前200行]

IMPORTANT: Wrap your output between these markers:
===COMMIT_START===
(your commit message here)
===COMMIT_END===
```

### 响应解析

脚本解析 AI 响应：

1. 提取 `===COMMIT_START===` 和 `===COMMIT_END===` 之间的内容
2. 如果没有标记，尝试 fallback 提取（移除 Copilot CLI 提示符）
3. 清理前后空白
4. 验证是否包含 `what:` 和 `why:` 字段（警告但不阻止）

### 输出格式

成功后显示：

```
✨ Generated Commit Message:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
feat: add user authentication

what: implemented JWT-based authentication

why: to secure the application
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 Creating commit...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Commit created successfully!

📋 Commit details:
  Commit: abc1234
  Author: Your Name <your.email@example.com>
  Date:   2025-01-15 10:30:45
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🤝 贡献

如需修改或改进：

1. **修改 commit 生成逻辑**: 编辑 `.fork/generate-commit-msg.sh`
2. **修改格式规范**: 修改脚本中的 `PROMPT` 变量
3. **更新文档**: 编辑 `.fork/AI-Commit.md`
4. 测试后提交（可以用本工具生成 commit message！）

---

**Happy Committing with AI! 🤖✨**

Made with ❤️ for productivity | Powered by GitHub Copilot
