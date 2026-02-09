---
name: character-controller
description: >
  角色控制器系统专家，负责角色移动、跳跃、状态机和物理交互的完整实现。
  Use when the user asks to "implement character movement", "debug player controller",
  "optimize character physics", "configure jump parameters", "fix movement bugs",
  mentions "CharacterController", "PlayerMovement", "StateMachine", "GroundCheck",
  or needs help with player character locomotion and state management.
  Also responds to "实现角色移动", "调试角色控制器", "优化角色物理", "配置跳跃参数", "修复移动问题".
related-skills: [camera-system, animation-system, input-system]
deprecated: false
superseded-by: ""
---

# Character Controller 角色控制器指南

## Overview

角色控制器系统专家，精通角色运动学、有限状态机和 Unity 物理系统。负责管理玩家角色的移动、跳跃、地面检测、状态切换及物理交互。

**核心能力**：
- **运动控制**：实现地面移动、空中控制、斜坡处理、速度曲线
- **状态管理**：基于有限状态机的角色状态管理（Idle/Walk/Run/Jump/Fall/Land）
- **物理交互**：地面检测、碰撞响应、重力模拟、Coyote Time
- **参数调优**：提供可视化参数调整和运行时 Debug 工具

**核心职责**：
- 诊断和解决角色移动异常（穿墙、抖动、卡顿）
- 优化角色控制器性能（物理检测频率、状态机开销）
- 配置和调整移动参数（速度、加速度、跳跃高度）
- 指导角色控制器新特性实现（滑墙、二段跳、冲刺）

## Core Rules

### 规则 1: 使用 CharacterController 组件而非 Rigidbody 进行角色移动

**角色移动必须使用 CharacterController.Move()，不要用 Rigidbody 控制主角：**
```csharp
// !! 错误：使用 Rigidbody 移动角色
_rigidbody.velocity = new Vector3(moveX, _rigidbody.velocity.y, moveZ);

// >> 正确：使用 CharacterController.Move()
Vector3 motion = new Vector3(moveX, _verticalVelocity, moveZ);
_characterController.Move(motion * Time.deltaTime);
```

### 规则 2: 地面检测必须使用 SphereCast 而非单点 Raycast

**地面检测需要考虑边缘情况，使用 SphereCast 提高可靠性：**
```csharp
// !! 错误：单点 Raycast 容易漏检边缘
bool isGrounded = Physics.Raycast(transform.position, Vector3.down, 0.1f);

// >> 正确：SphereCast 覆盖更大范围，配合 GroundCheck 点位
bool isGrounded = Physics.SphereCast(
    _groundCheckPoint.position,
    _groundCheckRadius,
    Vector3.down,
    out _,
    _groundCheckDistance,
    _groundLayer
);
```

### 规则 3: 移动逻辑放在 FixedUpdate，输入采集放在 Update

**物理相关的移动计算必须在 FixedUpdate 中执行：**
```csharp
// !! 错误：在 Update 中处理物理移动
void Update()
{
    _moveInput = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
    _characterController.Move(_moveInput * _speed * Time.deltaTime); // 帧率依赖
}

// >> 正确：输入在 Update，移动在 FixedUpdate
void Update()
{
    _moveInput = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
    if (Input.GetButtonDown("Jump")) _jumpRequested = true;
}

void FixedUpdate()
{
    Vector3 motion = CalculateMotion(_moveInput);
    _characterController.Move(motion * Time.fixedDeltaTime);
}
```

### 规则 4: 状态机必须使用枚举 + switch，禁止布尔标志组合

**角色状态必须用有限状态机管理，避免布尔标志组合爆炸：**
```csharp
// !! 错误：布尔标志组合
if (_isJumping && !_isGrounded && !_isDashing && _isFalling) { ... }

// >> 正确：枚举状态机
public enum CharacterState { Idle, Walk, Run, Jump, Fall, Land, Dash }

private CharacterState _currentState;

void UpdateState()
{
    switch (_currentState)
    {
        case CharacterState.Idle:
            if (_moveInput.magnitude > 0.1f) TransitionTo(CharacterState.Walk);
            if (_jumpRequested && _isGrounded) TransitionTo(CharacterState.Jump);
            break;
        case CharacterState.Jump:
            if (_verticalVelocity < 0) TransitionTo(CharacterState.Fall);
            break;
        // ...
    }
}
```

### 规则 5: 跳跃必须实现 Coyote Time 和 Jump Buffer

**为了手感优化，跳跃系统必须包含容错机制：**
```csharp
// Coyote Time: 离开地面后短暂允许跳跃
private float _coyoteTimeCounter;
private const float CoyoteTimeDuration = 0.15f;

// Jump Buffer: 落地前提前按跳跃也能触发
private float _jumpBufferCounter;
private const float JumpBufferDuration = 0.1f;

void UpdateJump()
{
    if (_isGrounded) _coyoteTimeCounter = CoyoteTimeDuration;
    else _coyoteTimeCounter -= Time.deltaTime;

    if (_jumpRequested) _jumpBufferCounter = JumpBufferDuration;
    else _jumpBufferCounter -= Time.deltaTime;

    bool canJump = _coyoteTimeCounter > 0f && _jumpBufferCounter > 0f;
    if (canJump)
    {
        _verticalVelocity = Mathf.Sqrt(_jumpHeight * -2f * _gravity);
        _coyoteTimeCounter = 0f;
        _jumpBufferCounter = 0f;
    }
}
```

## Reference Files

**核心实现**：
```
Assets/Scripts/Character/
├── PlayerController.cs              # 角色控制器主逻辑
├── CharacterStateMachine.cs         # 状态机框架
├── States/
│   ├── IdleState.cs                 # 静止状态
│   ├── MoveState.cs                 # 移动状态（Walk/Run）
│   ├── JumpState.cs                 # 跳跃状态
│   ├── FallState.cs                 # 下落状态
│   └── LandState.cs                 # 着陆状态
├── GroundChecker.cs                 # 地面检测组件
└── CharacterConfig.cs               # 角色参数配置 ScriptableObject
```

**配置文件**：
```
Assets/Config/Character/
├── DefaultCharacterConfig.asset     # 默认角色参数配置
└── DebugCharacterConfig.asset       # 调试用角色参数配置
```

**测试文件**：
```
Assets/Tests/Character/
├── GroundCheckTests.cs              # 地面检测单元测试
├── StateMachineTests.cs             # 状态机转换测试
└── MovementIntegrationTests.cs      # 移动集成测试
```

## Workflow

### 1. 移动问题诊断流程

**Step 1: 确认问题现象**
```
检查点：
- 问题是否与特定状态相关（仅在跳跃/移动时出现）
- 问题是否与帧率相关（不同设备表现不一致）
- 问题是否与地形相关（斜坡/台阶/特定碰撞体）
```

**Step 2: 检查物理配置**
```
- CharacterController 的 Skin Width 是否为 Radius 的 10%
- Ground Check 层级是否正确配置（排除角色自身层级）
- Slope Limit 和 Step Offset 是否合理
```

**Step 3: 运行时调试**
```
- 开启 Gizmos 查看 GroundCheck 范围
- 检查状态机日志确认状态切换是否正常
- 使用 Debug.DrawRay 可视化移动方向和法线
```

### 2. 参数调优流程

**识别角色类型 --> 选择参数预设 --> 微调 --> 测试验证**

#### 角色类型参数映射

| 角色类型 | 移动速度 | 跳跃高度 | 重力倍率 |
|----------|----------|----------|----------|
| **轻型角色** | 8-12 | 2.5-3.5 | 2.0 |
| **标准角色** | 5-8 | 1.5-2.5 | 2.5 |
| **重型角色** | 3-5 | 1.0-1.5 | 3.0 |

#### 关键参数说明

**移动参数：**
```csharp
_moveSpeed (6.0f)            // 基础移动速度
_sprintMultiplier (1.5f)     // 冲刺速度倍率
_acceleration (10.0f)        // 加速度
_deceleration (15.0f)        // 减速度（大于加速度手感更灵敏）
_airControl (0.3f)           // 空中控制系数（0-1）
```

**跳跃参数：**
```csharp
_jumpHeight (2.0f)           // 跳跃高度（米）
_gravity (-20.0f)            // 重力加速度
_fallMultiplier (2.5f)       // 下落加速倍率
_coyoteTime (0.15f)          // 土狼时间（秒）
_jumpBuffer (0.1f)           // 跳跃缓冲（秒）
```

## Best Practices

### 实践 1: 使用 ScriptableObject 管理角色参数

**将角色参数抽取为 ScriptableObject，方便策划调整和多角色复用：**
```csharp
[CreateAssetMenu(fileName = "CharacterConfig", menuName = "Game/Character Config")]
public class CharacterConfig : ScriptableObject
{
    [Header("移动")]
    public float MoveSpeed = 6f;
    public float SprintMultiplier = 1.5f;

    [Header("跳跃")]
    public float JumpHeight = 2f;
    public float Gravity = -20f;

    [Header("地面检测")]
    public float GroundCheckRadius = 0.3f;
    public LayerMask GroundLayer;
}
```

### 实践 2: 实现可视化调试工具

**为角色控制器添加 Gizmos 和运行时 UI 调试面板：**
```csharp
void OnDrawGizmosSelected()
{
    // 地面检测范围
    Gizmos.color = _isGrounded ? Color.green : Color.red;
    Gizmos.DrawWireSphere(_groundCheckPoint.position, _groundCheckRadius);

    // 移动方向
    Gizmos.color = Color.blue;
    Gizmos.DrawRay(transform.position, _moveDirection * 2f);
}
```

### 实践 3: 斜坡处理需投影速度到坡面法线

**在斜坡上移动时，将移动方向投影到坡面以避免弹跳：**
```csharp
Vector3 AdjustVelocityToSlope(Vector3 velocity)
{
    if (Physics.Raycast(transform.position, Vector3.down, out RaycastHit hit, 1.5f))
    {
        Quaternion slopeRotation = Quaternion.FromToRotation(Vector3.up, hit.normal);
        Vector3 adjusted = slopeRotation * velocity;
        if (adjusted.y < 0) return adjusted;
    }
    return velocity;
}
```

## Common Issues

### Issue 1: 角色在斜坡上滑动或抖动

**症状**：角色站在斜坡上时缓慢滑落，或在斜坡边缘反复抖动。

**诊断步骤**：
```
1. 检查 CharacterController.slopeLimit 是否过小
2. 检查重力是否在着地时仍持续累加
3. 检查是否在斜坡上正确投影了移动方向
```

**解决方案**：
```csharp
// 着地时重置垂直速度，防止重力累加
if (_isGrounded && _verticalVelocity < 0)
{
    _verticalVelocity = -2f; // 小负值保持贴地
}
```

### Issue 2: 角色穿墙或穿过碰撞体

**症状**：角色在高速移动或特定角度时穿过墙壁或其他碰撞体。

**可能原因**：
```
1. CharacterController.skinWidth 过小 → 增大到 Radius 的 10%
2. 移动速度过大导致单帧穿越 → 限制最大速度或分步移动
3. 碰撞体网格不合理 → 检查碰撞体设置
```

### Issue 3: 跳跃手感不佳（太飘或太硬）

**症状**：跳跃后角色在空中停留太久或下落太快，手感不自然。

**排查清单**：
```
1. 检查 _gravity 值（推荐 -20 到 -30）
2. 检查 _fallMultiplier 是否实现（下落时加速重力）
3. 检查是否实现了可变跳跃高度（松开跳跃键提前下落）
4. 检查 _jumpHeight 与 _gravity 的比例是否合理
```

---

**最后更新**: 2026-02-09
**版本**: 1.0
**维护者**: MyGameProject 团队
