# Unity MCP 工具速查表

> 基于 CoplayDev/unity-mcp v9.4.4

## 场景与对象管理

| 工具 | 描述 | 常用参数 |
|------|------|----------|
| `manage_gameobject` | 创建/修改/删除/复制 GameObject | action, name, primitiveType, position, rotation, scale |
| `manage_scene` | 加载/保存/创建场景 | action, sceneName, scenePath |
| `manage_components` | 添加/移除/配置组件 | action, gameObjectName, componentType, properties |
| `find_gameobjects` | 按名称/Tag/Layer/组件查询对象 | searchType, value |
| `manage_prefabs` | 创建/实例化/修改预制体 | action, prefabPath, instanceName |

## 资产管线

| 工具 | 描述 | 常用参数 |
|------|------|----------|
| `manage_asset` | 导入/创建/修改/删除资产 | action, assetPath, assetType |
| `manage_material` | 创建和配置材质 | action, materialName, shader, color, properties |
| `manage_texture` | 导入和修改贴图 | action, texturePath, settings |
| `manage_shader` | 着色器操作 | action, shaderName |
| `manage_vfx` | Visual Effect Graph 操作 | action, vfxName |

## 代码与脚本

| 工具 | 描述 | 常用参数 |
|------|------|----------|
| `manage_script` | 创建/读取/修改 C# 脚本 | action, scriptPath, content |
| `create_script` | 生成新 MonoBehaviour | scriptName, namespace, methods |
| `validate_script` | 检查编译错误 | scriptPath |
| `apply_text_edits` | 精确代码修改 | filePath, edits |

## 编辑器与自动化

| 工具 | 描述 | 常用参数 |
|------|------|----------|
| `manage_editor` | 控制编辑器状态/Play Mode/选择 | action |
| `execute_menu_item` | 触发任意 Unity 菜单命令 | menuPath |
| `batch_execute` | 批量执行多个操作（10-100x 加速） | operations[] |
| `run_tests` | 执行单元测试/集成测试 | testAssembly, filter |
| `read_console` | 读取控制台日志和错误 | logType, count |
| `refresh_unity` | 强制刷新资产数据库 | - |

## 数据

| 工具 | 描述 | 常用参数 |
|------|------|----------|
| `manage_scriptable_object` | 创建和修改 ScriptableObject | action, soType, properties |

## 资源（Resources）

| 资源 | 描述 |
|------|------|
| `unity_instances` | 列出运行中的 Unity Editor 实例 |
| `menu_items` | 可用的 Unity 菜单命令 |
| `editor_state` | 当前编辑器状态（Play Mode、选中对象等） |
| `project_info` | 项目设置和配置 |
| `prefab_api` | Prefab 操作参考 |

## 性能提示

- **3 个以上操作必须用 `batch_execute`**，减少 HTTP 开销
- 查询对象优先用 `find_gameobjects`，而非遍历层级
- 大型场景操作建议分批处理
- 长时间操作（资产导入）是异步的，需等待完成
