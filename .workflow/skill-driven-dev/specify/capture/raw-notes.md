# Raw Notes - Skill 驱动开发模式

## 用户原始需求

> 我想要在公司搭建一套基于 skill 开发的模式，在工程中，使用 CLAUDE.local.md 来作为总纲，然后每个特性分配一个 skill，日常开发中，任何改动都要与相关 skill 对应，每一个特性改动完成都要反馈回 skill 中以不断迭代该 skill

## 项目上下文

### 现有体系（render-pipeline 项目）

**CLAUDE.local.md 已定义：**
- Skill 驱动开发流程：定位 Skill → 阅读上下文 → 执行任务 → 智能 Skill Sync
- 智能 Skill Sync 规则（基于变更类型判断是否更新 Skill）
- 证据驱动原则
- Git 提交规范

**已有 Skills（~15+）：**
- atmosphere-expert, cicd-manager, fluid-simulation-expert, fog-expert
- gi-expert, lighting-shadow-expert, litrp-framework-specialist
- postprocessing-expert, reflection-system-expert, shader-framework
- ssr-specialist, taa-upscaler-expert, tod-system
- volumetric-fog-mask, fall-particle-height-mask

**每个 Skill 包含：**
- `SKILL.md`：frontmatter（name, description）、Overview、Workflow、Core Rules、Best Practices、Common Issues、Reference Files
- `.evolution/`：config.yaml、changelog.md、patterns/、failures/、improvements/、metrics/
- `tests/test-spec.yaml`
- Self-iteration 脚本（record-outcome、analyze-trends、propose-improvement）

### 现有不足/痛点（推断）

1. 当前体系仅在 render-pipeline 一个项目中运行，未标准化
2. Skill 创建缺少标准化流程指导（需人工判断结构）
3. Skill 与代码变更的关联靠开发者自觉
4. 反馈回 Skill 的时机和内容缺少规范
5. 新项目/新团队接入缺少"搭建指南"
6. Skill 的质量评估和生命周期管理尚无体系

## 利益相关者

| 角色 | 关注点 |
|------|--------|
| 开发者（AI 辅助） | 快速定位 Skill、获得上下文指导、减少重复犯错 |
| 技术负责人 | 知识沉淀、团队知识传承、代码质量 |
| 新成员 | 快速上手、理解系统架构和约定 |
| AI Agent（Claude） | 精准理解项目约束、避免常见错误、持续学习 |

## 功能需求（FR）

### FR-1: CLAUDE.local.md 总纲规范
- 定义 CLAUDE.local.md 作为项目 AI 开发总纲的标准结构
- 包含 Skill 驱动开发流程、Skill 注册表、全局约束

### FR-2: Skill 标准格式
- 定义 SKILL.md 的标准模板和必选/可选章节
- 定义 .evolution/ 目录结构和自迭代机制
- 定义 tests/ 目录和质量验证

### FR-3: Skill 与改动关联机制
- 所有代码改动必须关联到至少一个 Skill
- 无对应 Skill 时的处理流程（创建新 Skill 或归入框架 Skill）

### FR-4: Skill 反馈回写机制
- 改动完成后何时更新 Skill（智能 Sync 规则）
- 更新内容规范（哪些章节需要更新）
- changelog 记录格式

### FR-5: 新项目接入流程
- 从零搭建 Skill 体系的步骤
- 特性识别和 Skill 拆分指南
- CLAUDE.local.md 初始化模板

### FR-6: Skill 生命周期管理
- Skill 的创建、更新、废弃、合并流程
- 质量评估和审计机制

## 非功能需求（NFR）

### NFR-1: 低摩擦
- Skill 流程不应给开发者增加显著额外工作量
- 智能 Sync 规则应自动判断，非强制每次更新

### NFR-2: 可扩展
- 适用于不同技术栈（不限于 Unity/C#/HLSL）
- 适用于不同项目规模

### NFR-3: 渐进式采纳
- 团队可以从最小集开始，逐步完善
- 不要求一步到位

## 约束条件

- 必须基于 Claude Code 的 Skills 机制（SKILL.md frontmatter 格式）
- 必须兼容 .claude/ 目录结构
- 必须支持 Git 版本控制
- 现有 render-pipeline 项目的体系应作为参考实现

## 待澄清问题

1. **适用范围**：仅渲染管线项目，还是公司所有项目？
2. **团队规模**：多少人使用 Claude Code？是否所有人都用？
3. **强制程度**：Skill 关联是强制执行（CI 检查）还是自觉遵守？
4. **现有痛点**：当前体系运行中最大的痛点是什么？
5. **渐进策略**：希望一步到位还是分阶段推进？

## Ambiguity Score: 3/10

主要不确定项：适用范围、强制程度、现有痛点优先级
