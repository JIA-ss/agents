#!/bin/bash

# Claude Code & Codex 统一部署工具 (macOS/Linux)
# 使用软连接方式部署 skills / agents / commands
# 使用方法: chmod +x deploy-macos.sh && ./deploy-macos.sh

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN} Skills / Agents / Commands 部署工具${NC}"
echo -e "${CYAN} 模式: 软连接 (symlink)${NC}"
echo -e "${CYAN} 支持: Claude Code + Codex CLI${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# 需要部署的资源目录
RESOURCES=("skills" "agents" "commands")

# 目标环境
declare -A TARGETS
TARGETS[claude]="$HOME/.claude"
TARGETS[codex]="$HOME/.codex"

# 统计
total_links=0
total_skipped=0
total_errors=0

# 创建软连接的函数
create_symlink() {
    local source_dir="$1"
    local target_link="$2"
    local resource_name="$3"
    local env_name="$4"

    # 源目录不存在则跳过
    if [ ! -d "$source_dir" ]; then
        echo -e "  ${YELLOW}[SKIP]${NC} 源目录不存在: $source_dir"
        total_skipped=$((total_skipped + 1))
        return
    fi

    # 目标已经是正确的软连接
    if [ -L "$target_link" ]; then
        local current_target
        current_target=$(readlink -f "$target_link" 2>/dev/null || readlink "$target_link")
        local expected_target
        expected_target=$(cd "$source_dir" && pwd)
        if [ "$current_target" = "$expected_target" ]; then
            echo -e "  ${GREEN}[OK]${NC}   $resource_name -> 已是正确的软连接"
            total_skipped=$((total_skipped + 1))
            return
        else
            echo -e "  ${YELLOW}[FIX]${NC}  $resource_name -> 软连接目标不正确，正在修复..."
            rm "$target_link"
        fi
    fi

    # 目标是普通目录，备份后替换
    if [ -d "$target_link" ] && [ ! -L "$target_link" ]; then
        local backup_name="${target_link}.backup-$(date +%Y%m%d-%H%M%S)"
        echo -e "  ${YELLOW}[BAK]${NC}  $resource_name -> 备份现有目录到 $(basename "$backup_name")"
        mv "$target_link" "$backup_name"
    fi

    # 创建软连接
    ln -s "$source_dir" "$target_link"
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}[LINK]${NC} $resource_name -> $source_dir"
        total_links=$((total_links + 1))
    else
        echo -e "  ${RED}[ERR]${NC}  $resource_name -> 创建软连接失败"
        total_errors=$((total_errors + 1))
    fi
}

# 检查源目录
echo -e "${BLUE}[1/3] 检查源文件目录${NC}"
echo -e "  仓库路径: $REPO_DIR"
for res in "${RESOURCES[@]}"; do
    if [ -d "$REPO_DIR/$res" ]; then
        local_count=$(find "$REPO_DIR/$res" -maxdepth 1 -name "*.md" -o -type d | wc -l)
        echo -e "  ${GREEN}[OK]${NC}   $res/ 目录存在"
    else
        echo -e "  ${YELLOW}[WARN]${NC} $res/ 目录不存在，将跳过"
    fi
done
echo ""

# 部署到各环境
step=2
for env_key in claude codex; do
    target_base="${TARGETS[$env_key]}"
    env_display="Claude Code"
    [ "$env_key" = "codex" ] && env_display="Codex CLI"

    echo -e "${BLUE}[$step/3] 部署到 $env_display ($target_base)${NC}"

    # 确保目标基础目录存在
    if [ ! -d "$target_base" ]; then
        echo -e "  ${YELLOW}[INFO]${NC} 创建目录: $target_base"
        mkdir -p "$target_base"
    fi

    for res in "${RESOURCES[@]}"; do
        create_symlink "$REPO_DIR/$res" "$target_base/$res" "$res" "$env_display"
    done
    echo ""
    step=$((step + 1))
done

# 部署结果汇总
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}[DONE] 部署完成！${NC}"
echo ""
echo "  新建软连接: $total_links"
echo "  已存在/跳过: $total_skipped"
[ $total_errors -gt 0 ] && echo -e "  ${RED}错误: $total_errors${NC}"
echo ""

echo "软连接状态:"
echo "----------------------------------------"
for env_key in claude codex; do
    target_base="${TARGETS[$env_key]}"
    env_display="Claude Code"
    [ "$env_key" = "codex" ] && env_display="Codex CLI"
    echo -e "  ${BLUE}$env_display${NC}:"
    for res in "${RESOURCES[@]}"; do
        if [ -L "$target_base/$res" ]; then
            link_target=$(readlink "$target_base/$res")
            echo -e "    ${GREEN}$res${NC} -> $link_target"
        elif [ -d "$target_base/$res" ]; then
            echo -e "    ${YELLOW}$res${NC} (普通目录，非软连接)"
        else
            echo -e "    ${RED}$res${NC} (不存在)"
        fi
    done
done
echo "----------------------------------------"
echo ""

echo "已部署的资源:"
echo "----------------------------------------"
for res in "${RESOURCES[@]}"; do
    if [ -d "$REPO_DIR/$res" ]; then
        echo -e "  ${CYAN}$res/${NC}:"
        case "$res" in
            skills)
                for dir in "$REPO_DIR/$res"/*/; do
                    [ -f "$dir/SKILL.md" ] && echo "    $(basename "$dir")"
                done
                ;;
            agents|commands)
                for f in "$REPO_DIR/$res"/*.md; do
                    [ -f "$f" ] && echo "    $(basename "$f" .md)"
                done
                ;;
        esac
    fi
done
echo "----------------------------------------"
echo ""
echo -e "${YELLOW}[提示]${NC} 软连接模式下，修改仓库中的文件会立即生效，无需重新部署"
echo -e "${YELLOW}[提示]${NC} 重启 Claude Code / Codex 以加载变更"
echo ""
