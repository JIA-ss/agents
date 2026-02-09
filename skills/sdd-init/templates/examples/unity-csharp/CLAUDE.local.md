# CLAUDE.local.md

全程使用中文交流。

## 项目概述

**MyGameProject** - Unity 3D 动作游戏项目。技术栈：Unity 2022 + C#。
- `Assets/Scripts/` - 游戏逻辑脚本
- `Assets/Shaders/` - 自定义着色器
- `Assets/Prefabs/` - 预制体资源
- `Assets/Scenes/` - 游戏场景

## Skill 驱动开发（强制）

**每次开发/修复必须遵循此流程：**

```
1. 定位 Skill → 2. 阅读上下文 → 3. 执行任务 → 4. 智能 Sync → 5. 执行反馈
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
| Shader/配置关键字变化 | 必须 | 影响配置方式 |
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
- **通用/跨系统任务**：归入框架 Skill（如 `unity-framework`）
- **Skill 内容过时**：优先更新 Skill，再继续任务

## 全局约束

- 代码规范：遵循 Unity C# 编码规范，使用 PascalCase 命名公开成员，camelCase 命名私有成员，`_` 前缀命名私有字段
- Unity 版本：Unity 2022 LTS，脚本后端使用 IL2CPP
- Git 提交格式：`feat/fix/refactor/chore: <summary>`
- 证据驱动：技术方案须有理论依据，不确定时明确说明
- 性能要求：目标帧率 60fps，Draw Call 控制在 200 以内
- 禁止使用 `GameObject.Find()` 在运行时查找对象，应通过引用或依赖注入获取

## Skill 索引

<!-- SKILL-INDEX-START -->
| Skill | 路径 | 说明 |
|-------|------|------|
| character-controller | `.claude/skills/character-controller/` | 角色控制器系统 |
<!-- SKILL-INDEX-END -->
