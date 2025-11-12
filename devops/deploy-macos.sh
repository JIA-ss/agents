#!/bin/bash

# Claude Code Agents 部署工具 (macOS/Linux)
# 使用方法: chmod +x deploy-macos.sh && ./deploy-macos.sh

set -e

echo "========================================"
echo " Claude Code Agents 部署工具 (macOS/Linux)"
echo "========================================"
echo ""

# 定义目标目录
AGENT_DIR="$HOME/.claude/agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../agents"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "[1/4] 检测目标目录..."
if [ ! -d "$AGENT_DIR" ]; then
    echo -e "${YELLOW}[INFO]${NC} 目标目录不存在，正在创建: $AGENT_DIR"
    mkdir -p "$AGENT_DIR"
    echo -e "${GREEN}[SUCCESS]${NC} 目录创建成功"
else
    echo -e "${YELLOW}[INFO]${NC} 目标目录已存在: $AGENT_DIR"
fi
echo ""

echo "[2/4] 检查源文件目录..."
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}[ERROR]${NC} 源文件目录不存在: $SOURCE_DIR"
    echo -e "${RED}[ERROR]${NC} 请确保在项目根目录下执行此脚本"
    exit 1
fi
echo -e "${YELLOW}[INFO]${NC} 源文件目录: $SOURCE_DIR"
echo ""

echo "[3/4] 复制 agent 文件..."
file_count=0
if ls "$SOURCE_DIR"/*.md 1> /dev/null 2>&1; then
    for file in "$SOURCE_DIR"/*.md; do
        filename=$(basename "$file")
        echo -e "${YELLOW}[COPY]${NC} $filename"
        cp -f "$file" "$AGENT_DIR/"
        ((file_count++))
    done
else
    echo -e "${YELLOW}[WARNING]${NC} 没有找到任何 .md 文件"
fi
echo ""

echo "[4/4] 部署结果..."
if [ $file_count -eq 0 ]; then
    echo -e "${YELLOW}[WARNING]${NC} 没有找到任何 .md 文件"
    echo -e "${YELLOW}[INFO]${NC} 请确保 agents/ 目录下有 agent 文件"
else
    echo -e "${GREEN}[SUCCESS]${NC} 成功部署 $file_count 个 agent 文件"
    echo ""
    echo "已部署的文件列表:"
    echo "----------------------------------------"
    ls -1 "$AGENT_DIR"/*.md 2>/dev/null | xargs -n1 basename || echo "无文件"
    echo "----------------------------------------"
fi
echo ""

echo -e "${GREEN}[SUCCESS]${NC} 部署完成！"
echo -e "${YELLOW}[INFO]${NC} 部署路径: $AGENT_DIR"
echo ""
echo -e "${YELLOW}[提示]${NC} 请重启 Claude Code 以加载新的 agent 配置"
echo ""
