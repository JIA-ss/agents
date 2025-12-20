#!/bin/bash

# Claude Code & Codex Skills 部署工具 (macOS/Linux)
# 使用方法: chmod +x deploy-macos.sh && ./deploy-macos.sh

set -e

echo "========================================"
echo " Skills 部署工具 (macOS/Linux)"
echo " 支持: Claude Code + Codex CLI"
echo "========================================"
echo ""

# 定义目标目录
CLAUDE_SKILL_DIR="$HOME/.claude/skills"
CODEX_SKILL_DIR="$HOME/.codex/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../skills"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 部署到指定目录的函数
deploy_to_dir() {
    local target_dir="$1"
    local env_name="$2"
    local file_count=0

    echo -e "${BLUE}[$env_name]${NC} 检测目标目录..."
    if [ ! -d "$target_dir" ]; then
        echo -e "${YELLOW}[INFO]${NC} 目标目录不存在，正在创建: $target_dir"
        mkdir -p "$target_dir"
        echo -e "${GREEN}[SUCCESS]${NC} 目录创建成功"
    else
        echo -e "${YELLOW}[INFO]${NC} 目标目录已存在: $target_dir"
    fi

    echo -e "${BLUE}[$env_name]${NC} 复制 skill 文件..."
    for skill_dir in "$SOURCE_DIR"/*/; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            if [ -f "$skill_dir/SKILL.md" ]; then
                # 创建目标子目录
                mkdir -p "$target_dir/$skill_name"
                # 复制 SKILL.md
                cp -f "$skill_dir/SKILL.md" "$target_dir/$skill_name/"
                echo -e "${YELLOW}[COPY]${NC} $skill_name/SKILL.md"
                file_count=$((file_count + 1))
            fi
        fi
    done

    if [ $file_count -eq 0 ]; then
        echo -e "${YELLOW}[WARNING]${NC} 没有找到任何 SKILL.md 文件"
    else
        echo -e "${GREEN}[SUCCESS]${NC} $env_name: 成功部署 $file_count 个 skill 文件"
    fi
    echo ""
}

echo "[1/4] 检查源文件目录..."
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}[ERROR]${NC} 源文件目录不存在: $SOURCE_DIR"
    echo -e "${RED}[ERROR]${NC} 请确保在项目根目录下执行此脚本"
    exit 1
fi
echo -e "${YELLOW}[INFO]${NC} 源文件目录: $SOURCE_DIR"
echo ""

echo "[2/4] 部署到 Claude Code..."
deploy_to_dir "$CLAUDE_SKILL_DIR" "Claude Code"

echo "[3/4] 部署到 Codex CLI..."
deploy_to_dir "$CODEX_SKILL_DIR" "Codex"

echo "[4/4] 部署结果汇总..."
echo "========================================"
echo -e "${GREEN}[SUCCESS]${NC} 部署完成！"
echo ""
echo "部署路径:"
echo -e "  ${BLUE}Claude Code${NC}: $CLAUDE_SKILL_DIR"
echo -e "  ${BLUE}Codex CLI${NC}:   $CODEX_SKILL_DIR"
echo ""
echo "已部署的 skills 列表:"
echo "----------------------------------------"
for dir in "$CLAUDE_SKILL_DIR"/*/; do
    if [ -f "$dir/SKILL.md" ]; then
        echo "  $(basename "$dir")"
    fi
done
echo "----------------------------------------"
echo ""
echo -e "${YELLOW}[提示]${NC} 请重启 Claude Code / Codex 以加载新的 skill 配置"
echo -e "${YELLOW}[提示]${NC} Codex 启用 skills: codex --enable skills"
echo ""
