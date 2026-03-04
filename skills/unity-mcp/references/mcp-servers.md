# Unity MCP Server 对比与安装指南

## 推荐方案（按优先级）

### 1. CoplayDev/unity-mcp（首选）

- **Stars**: 5,800+ | **License**: MIT
- **兼容性**: Unity 2021.3 LTS ~ Unity 6
- **架构**: AI Client → Python MCP Server (uvx) → Unity C# Plugin (localhost:8080)
- **工具数**: 25+
- **官方文档**: https://docs.coplay.dev/coplay-mcp/claude-code-guide

**Unity Package 安装**:
```
Window > Package Manager > + > Add package from git URL...
https://github.com/CoplayDev/unity-mcp.git?path=/MCPForUnity#main
```

**Claude Code 注册**:
```bash
claude mcp add --scope user --transport stdio coplay-mcp \
  --env MCP_TOOL_TIMEOUT=720000 \
  -- uvx --python ">=3.11" coplay-mcp-server@latest
```

**启动**: Unity 中 `Window > MCP for Unity > Start Server`

### 2. IvanMurzak/Unity-MCP（备选，工具更丰富）

- **Stars**: 1,100+ | **License**: Apache 2.0
- **兼容性**: Unity 2022.3+（实测）
- **架构**: AI Client → ASP.NET Core MCP Server → Unity Plugin (SignalR, port 8080)
- **工具数**: 50+
- **特色**: 支持 Runtime 使用（游戏内 AI）

**Unity Package 安装**:
```bash
openupm add com.ivanmurzak.unity.mcp
```
或下载 .unitypackage 安装器

**Claude Code 注册**:
```bash
claude mcp add ai-game-developer <command>
# <command> 从 Unity Window/AI Game Developer - MCP 面板获取
```

**自定义工具示例**:
```csharp
[McpPluginTool("create_object", "Creates a new GameObject")]
public string CreateObject([Description("Object name")] string name)
{
    var go = new GameObject(name);
    return $"Created: {go.name}";
}
```

### 3. CoderGamester/mcp-unity（IDE 集成优秀）

- **Stars**: 824 | **License**: MIT
- **兼容性**: Unity 2022.3+
- **架构**: AI Client → Node.js MCP Server → Unity (WebSocket)

**安装**:
```
Window > Package Manager > + > Add package from git URL...
https://github.com/CoderGamester/mcp-unity.git
```

## 兼容性速查表

| Unity 版本 | CoplayDev | IvanMurzak | CoderGamester |
|-----------|-----------|------------|---------------|
| 2021.3 LTS | ✅ | ❌ | ❌ |
| 2022.3.x | ✅ | ✅ | ✅ |
| 2023.x | ✅ | ✅ | ✅ |
| Unity 6 | ✅ | ✅ | ✅ |

## 验证连接

```bash
# 检查 MCP 是否注册
claude mcp list

# 手动测试 MCP Server
uvx --from mcpforunityserver mcp-for-unity --transport http --port 8080

# 测试 Unity HTTP 端点
curl http://localhost:8080/mcp
```
