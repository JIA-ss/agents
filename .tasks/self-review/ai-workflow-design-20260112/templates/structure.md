# Project Directory Structure Template

本文档定义项目的标准目录结构。

---

## Standard Structure

```
{project-root}/
│
├── .agent/                          # AI 工作流配置
│   ├── config.yaml                  # 工作流配置
│   ├── constitution.md              # 项目原则
│   ├── specs/                       # 功能规范
│   │   └── {feature-id}/
│   │       ├── spec.md
│   │       ├── plan.md
│   │       └── tasks.md
│   ├── templates/                   # 文档模板
│   └── hooks/                       # 钩子脚本 (可选)
│
├── .tasks/                          # 任务执行记录
│   └── self-review/
│       └── {task-name}/
│
├── src/                             # 源代码
│   ├── {module}/                    # 功能模块
│   ├── types/                       # 类型定义
│   ├── utils/                       # 工具函数
│   └── constants/                   # 常量
│
├── tests/                           # 测试代码
│   ├── unit/                        # 单元测试
│   ├── integration/                 # 集成测试
│   └── e2e/                         # 端到端测试
│
├── docs/                            # 文档 (可选)
│
├── CLAUDE.md                        # Claude Code 配置
├── README.md                        # 项目说明
└── {config files}                   # 构建/Lint 配置
```

---

## Stack-Specific Variations

### TypeScript/Node.js

```
project/
├── src/
│   ├── components/          # React 组件
│   ├── hooks/               # React Hooks
│   ├── services/            # 业务逻辑
│   ├── types/               # TypeScript 类型
│   └── utils/               # 工具函数
├── tests/
├── package.json
└── tsconfig.json
```

### Python

```
project/
├── src/{package}/           # 主包
│   ├── __init__.py
│   ├── models/
│   ├── services/
│   └── utils/
├── tests/
│   ├── conftest.py
│   └── test_*.py
├── pyproject.toml
└── requirements.txt
```

### Go

```
project/
├── cmd/                     # 入口点
│   └── main.go
├── internal/                # 内部包
│   ├── handler/
│   ├── service/
│   └── repository/
├── pkg/                     # 公共包
├── tests/
└── go.mod
```

---

## Quick Setup Script

```bash
#!/bin/bash
# init-agent-workflow.sh

# 创建 .agent 目录结构
mkdir -p .agent/{specs,templates,hooks}

# 创建配置文件
cat > .agent/config.yaml << 'EOF'
version: "1.0"
project:
  name: "my-project"
  type: "web-app"
  language: "typescript"
# ... (从 templates/config.yaml 复制完整内容)
EOF

# 创建 constitution
touch .agent/constitution.md

# 创建 CLAUDE.md
touch CLAUDE.md

# 创建 .tasks 目录
mkdir -p .tasks/self-review

echo "AI Workflow initialized in .agent/"
```

---

*Template version: 1.0*
