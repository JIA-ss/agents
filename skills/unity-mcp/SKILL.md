---
name: unity-mcp
description: Unity game development assistant via MCP. Manages scenes, objects, scripts, materials, and assets through natural language. Use when user mentions "Unity", "Unity MCP", "game development in Unity", "create scene", "game object", "Unity debug", or wants to build/modify Unity projects with AI. Also responds to "Unity 开发", "游戏开发", "创建场景", "Unity 调试", "Unity 项目".
---

# Unity MCP - AI 驱动的 Unity 游戏开发助手

通过 Model Context Protocol 将 Claude Code 连接到 Unity Editor，实现自然语言驱动的游戏开发。

---

## 🚀 执行流程

**当此 skill 被触发时，你必须按以下流程执行：**

### 立即行动

1. 识别用户的 Unity 开发请求类型（搭建环境 / 场景操作 / 代码生成 / 调试修复 / 批量操作）
2. 检测 Unity MCP 配置状态
3. 根据请求类型进入对应 Phase

### 📋 进度追踪 Checklist

```
- [ ] Phase 1: DETECT → 检测 MCP 配置和 Unity 连接
- [ ] Phase 2: SETUP → 安装/配置 MCP（如需要）
- [ ] Phase 3: PLAN → 分析请求，规划 MCP 工具调用序列
- [ ] Phase 4: EXECUTE → 执行 MCP 工具调用
- [ ] Phase 5: VERIFY → 验证结果，读取控制台，迭代修复
```

### ✅ 阶段完成验证

| 阶段 | 完成条件 | 下一步 |
|------|----------|--------|
| DETECT | MCP 状态已确认 | → SETUP 或 PLAN |
| SETUP | MCP 已安装且连接 | → PLAN |
| PLAN | 工具调用序列已规划 | → EXECUTE |
| EXECUTE | 所有操作已执行 | → VERIFY |
| VERIFY | 结果确认无误 | → 完成 |

---

## Phase 详情

### Phase 1: DETECT（检测环境）

**你必须：**

1. 检查 Claude Code 中是否已注册 Unity MCP Server：
   ```bash
   claude mcp list 2>/dev/null | grep -i "unity\|coplay"
   ```

2. 根据检测结果分流：

| 状态 | 处理 |
|------|------|
| 已配置且连接 | ✅ 跳过 SETUP，进入 PLAN |
| 已配置但未连接 | ⚠️ 提示用户启动 Unity Editor 和 MCP Server |
| 未配置 | 🔧 进入 SETUP 引导安装 |

**完成标志**: MCP 配置状态已明确

---

### Phase 2: SETUP（环境搭建）

**仅在 MCP 未配置时执行。你必须：**

1. **确认 Unity 版本**：询问用户 Unity 版本，参考 [references/mcp-servers.md](references/mcp-servers.md) 确认兼容性

2. **推荐 MCP Server**（默认 CoplayDev）：

   **Step 1 - 安装 Unity Package**:
   ```
   Unity > Window > Package Manager > + > Add package from git URL...
   https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
   ```

   **Step 2 - 注册 MCP Server 到 Claude Code**:
   ```bash
   claude mcp add --scope user --transport stdio coplay-mcp \
     --env MCP_TOOL_TIMEOUT=720000 \
     -- uvx --python ">=3.11" coplay-mcp-server@latest
   ```

   **Step 3 - 启动 Server**:
   ```
   Unity > Window > MCP for Unity > Start Server
   ```

3. **验证连接**：
   ```bash
   claude mcp list | grep coplay
   ```

4. 如用户需要更丰富的工具集（50+），推荐 IvanMurzak/Unity-MCP 作为替代方案

**完成标志**: `claude mcp list` 显示 Unity MCP 已连接

---

### Phase 3: PLAN（规划操作）

**你必须：**

1. 解析用户请求，识别任务类型：

| 任务类型 | 关键词 | 主要工具 |
|----------|--------|----------|
| 对象创建 | 创建、添加、生成对象 | `manage_gameobject` |
| 组件配置 | 添加组件、设置属性 | `manage_components` |
| 脚本生成 | 写脚本、代码、控制器 | `manage_script`, `create_script` |
| 材质/视觉 | 材质、颜色、着色器 | `manage_material`, `manage_shader` |
| 场景管理 | 场景、关卡、加载 | `manage_scene` |
| 预制体 | Prefab、预制体 | `manage_prefabs` |
| 调试修复 | 报错、调试、修复 | `read_console`, `manage_script` |
| 测试 | 测试、验证 | `run_tests` |
| 批量操作 | 所有、每个、批量 | `batch_execute` |

2. 规划 MCP 工具调用序列（参考 [references/workflows.md](references/workflows.md)）

3. **性能优化规则**：
   - 超过 3 个操作 → 必须使用 `batch_execute`
   - 需要查找对象 → 先 `find_gameobjects` 再操作
   - 修改代码后 → 调用 `refresh_unity` 触发编译

**完成标志**: 工具调用序列已规划，操作步骤清晰

---

### Phase 4: EXECUTE（执行操作）

**你必须：**

1. 按规划的序列调用 MCP 工具
2. 每个工具调用后检查返回结果
3. 遇到错误时立即处理（不继续后续调用）

**执行规则**:

- **单个对象操作** → 直接调用对应工具
- **多对象操作** → 使用 `batch_execute` 包装
- **脚本生成** → 生成完整的 C# MonoBehaviour，包含必要的 using 声明
- **组件添加** → 确认 GameObject 存在后再添加

**C# 脚本生成规范**:
```csharp
using UnityEngine;

public class ClassName : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] private float speed = 5f;

    void Update()
    {
        // 实现逻辑
    }
}
```

**错误处理**:

| 错误类型 | 处理方式 |
|----------|----------|
| 对象不存在 | 提示用户确认名称，或先创建 |
| 组件不存在 | 建议使用自定义脚本替代 |
| 编译错误 | 读取错误详情，修复代码 |
| 连接超时 | 提示检查 Unity Editor 和 MCP Server |
| 操作被拒绝 | 说明 Unity 限制，提供替代方案 |

**完成标志**: 所有操作执行完成，无未处理的错误

---

### Phase 5: VERIFY（验证结果）

**你必须：**

1. **读取控制台**：检查是否有新错误
   ```
   read_console → logType: "error", count: 10
   ```

2. **确认对象状态**：查询创建/修改的对象
   ```
   find_gameobjects → 验证对象存在且属性正确
   ```

3. **汇报结果**：

   ```
   ✅ Unity 操作完成

   已执行:
   - 创建 GameObject "Player" (Capsule)
   - 添加 CharacterController 组件
   - 生成 PlayerController.cs 脚本
   - 挂载脚本到 Player

   ⚠️ 注意事项:
   - 按 Play 测试时使用 WASD 移动，空格跳跃
   - 如需调整参数，可在 Inspector 中修改
   ```

4. **迭代修复**：如果控制台有错误
   - 读取错误详情
   - 定位问题脚本
   - 修复并重新编译
   - 再次验证

**完成标志**: 控制台无新错误，用户确认结果

---

## 约束

### 兼容性
- **Unity 版本**: 2021.3 LTS ~ Unity 6（CoplayDev）；2022.3+（IvanMurzak/CoderGamester）
- **前置依赖**: Python 3.10+（CoplayDev）或 .NET 9.0（IvanMurzak）或 Node.js 18+（CoderGamester）
- **仅限编辑器**: MCP 工具在 Unity Editor 中运行，不适用于运行时构建

### 工具使用规则
- 超过 3 个操作必须使用 `batch_execute`
- 查询对象优先使用 `find_gameobjects`，而非手动遍历
- 脚本修改后必须 `refresh_unity` 触发编译
- 长时间操作需等待异步完成

### 安全约束
- 不自动执行 `manage_editor` 的 Play/Pause 操作（需用户确认）
- 不删除场景中未指定的对象
- 脚本修改前先读取原始内容再应用编辑

---

## 资源

| 资源 | 路径 | 用途 |
|------|------|------|
| MCP Server 对比 | [references/mcp-servers.md](references/mcp-servers.md) | 选择和安装 MCP Server |
| 工具速查表 | [references/tools-reference.md](references/tools-reference.md) | 查找可用 MCP 工具 |
| 工作流模式 | [references/workflows.md](references/workflows.md) | 常见操作的工具调用序列 |
