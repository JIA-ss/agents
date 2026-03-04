# Unity MCP 常见工作流模式

## 1. 角色创建工作流

```
用户: "创建一个带物理的玩家角色"

步骤:
1. manage_gameobject → 创建 "Player" (Capsule)
2. manage_components → 添加 CharacterController
3. manage_components → 添加 CapsuleCollider
4. manage_script → 生成 PlayerController.cs
5. manage_components → 挂载 PlayerController 脚本
```

**PlayerController 模板要点**:
- WASD/方向键移动
- 空格跳跃 + 重力
- CharacterController.Move()
- 可配置 moveSpeed、jumpForce、gravity

## 2. 关卡搭建工作流

```
用户: "搭建一个平台跳跃关卡"

步骤:
1. manage_scene → 创建/加载场景
2. batch_execute → 批量创建平台对象 (位置递增)
3. batch_execute → 批量创建材质并应用
4. manage_gameobject → 创建终点触发器
5. manage_script → 生成 LevelComplete 触发脚本
6. manage_components → 配置 Collider.isTrigger
```

## 3. 批量操作工作流

```
用户: "给所有敌人加上血量组件"

步骤:
1. find_gameobjects → 查询 Tag="Enemy" 的所有对象
2. batch_execute → 对每个对象:
   - 添加 HealthComponent
   - 设置属性 { maxHealth: 100, currentHealth: 100 }
3. 返回修改数量报告
```

**batch_execute 格式**:
```json
{
  "operations": [
    { "tool": "manage_components", "args": { "action": "add", "gameObjectName": "Enemy1", "componentType": "HealthComponent" } },
    { "tool": "manage_components", "args": { "action": "add", "gameObjectName": "Enemy2", "componentType": "HealthComponent" } }
  ]
}
```

## 4. 调试工作流

```
用户: "控制台报错了"

步骤:
1. read_console → 获取错误日志 (logType: "error")
2. 分析错误信息 → 定位问题文件和行号
3. manage_script → 读取问题脚本 (action: "read")
4. manage_script → 修复代码 (action: "write")
5. refresh_unity → 触发重新编译
6. read_console → 验证错误已消除
```

## 5. 材质/视觉工作流

```
用户: "创建一套发光材质"

步骤:
1. manage_material → 创建材质 (shader: "Standard")
2. 设置 emission 属性启用发光
3. 设置颜色和强度
4. manage_gameobject → 应用到目标对象
```

## 6. 测试工作流

```
用户: "运行所有单元测试"

步骤:
1. run_tests → 执行测试 (testAssembly: "EditMode"/"PlayMode")
2. 等待测试完成
3. 解析结果 → 通过/失败数量
4. 对失败测试 → 读取错误详情
5. 可选: manage_script → 修复失败的测试
```

## 7. 项目初始化工作流

```
用户: "初始化一个新的 3D 项目"

步骤:
1. manage_scene → 创建主场景
2. manage_gameobject → 设置基础灯光 (Directional Light)
3. manage_gameobject → 设置主摄像机
4. manage_gameobject → 创建地面平面
5. manage_material → 创建默认地面材质
6. manage_script → 创建 GameManager.cs
```

## 工具选择决策树

```
用户请求
 ├── 创建/修改对象 → manage_gameobject
 ├── 添加/配置组件 → manage_components
 ├── 查找对象 → find_gameobjects
 ├── 写/读代码 → manage_script
 ├── 创建材质 → manage_material
 ├── 多个操作 → batch_execute (包装上述工具)
 ├── 调试问题 → read_console + manage_script
 ├── 运行测试 → run_tests
 └── 菜单操作 → execute_menu_item
```
