#!/bin/bash

# Claude Code Agents - Add Frontmatter Tool (macOS/Linux)
# 自动为 agents/ 目录下缺少 frontmatter 的 .md 文件添加 YAML frontmatter
# 使用方法: chmod +x add-frontmatter.sh && ./add-frontmatter.sh

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo " Claude Code Agents - Add Frontmatter Tool"
echo "========================================"
echo ""

# 定义目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../agents"

# 检查源目录
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}[ERROR]${NC} 源文件目录不存在: $SOURCE_DIR"
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} 扫描目录: $SOURCE_DIR"
echo ""

# 统计变量
total_files=0
updated_files=0
skipped_files=0

# 遍历所有 .md 文件
for file in "$SOURCE_DIR"/*.md; do
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        continue
    fi

    filename=$(basename "$file")
    ((total_files++))

    echo -e "${BLUE}[SCAN]${NC} 检查文件: $filename"

    # 读取第一行
    first_line=$(head -n 1 "$file")

    # 检查是否已有 frontmatter
    if [ "$first_line" == "---" ]; then
        echo -e "${YELLOW}[SKIP]${NC} 文件已包含 frontmatter: $filename"
        ((skipped_files++))
        echo ""
        continue
    fi

    # 提取 agent 名称（去掉 .md 后缀）
    agent_name="${filename%.md}"

    # 提取描述（从第一个 # 标题或概述段落）
    description=""
    # 尝试从第一个 # 标题提取
    title_line=$(grep -m 1 "^# " "$file" 2>/dev/null || echo "")
    if [ -n "$title_line" ]; then
        # 去掉 "# " 前缀
        description="${title_line#\# }"
    fi

    # 如果没找到标题，使用默认描述
    if [ -z "$description" ]; then
        description="$agent_name agent"
    fi

    # 创建备份
    backup_file="$file.bak"
    cp "$file" "$backup_file"
    echo -e "${YELLOW}[BACKUP]${NC} 已创建备份: ${filename}.bak"

    # 创建临时文件with frontmatter
    temp_file=$(mktemp)

    # 写入 frontmatter
    cat > "$temp_file" << EOF
---
name: $agent_name
description: $description
model: sonnet
---

EOF

    # 追加原文件内容
    cat "$file" >> "$temp_file"

    # 替换原文件
    mv "$temp_file" "$file"

    echo -e "${GREEN}[SUCCESS]${NC} 已添加 frontmatter: $filename"
    echo -e "  ${BLUE}→${NC} name: $agent_name"
    echo -e "  ${BLUE}→${NC} description: $description"
    echo -e "  ${BLUE}→${NC} model: sonnet"
    ((updated_files++))
    echo ""
done

# 显示统计结果
echo "========================================"
echo -e "${BLUE}[统计]${NC} 处理完成"
echo "----------------------------------------"
echo -e "  总文件数: $total_files"
echo -e "  已更新: ${GREEN}$updated_files${NC}"
echo -e "  已跳过: ${YELLOW}$skipped_files${NC}"
echo "========================================"
echo ""

if [ $updated_files -gt 0 ]; then
    echo -e "${YELLOW}[提示]${NC} 备份文件已保存为 .md.bak"
    echo -e "${YELLOW}[提示]${NC} 请检查更新后的文件，确认 description 是否正确"
    echo -e "${YELLOW}[提示]${NC} 如需恢复，可以使用备份文件"
    echo ""
    echo -e "${BLUE}[下一步]${NC} 运行 ./deploy-macos.sh 部署更新后的 agents"
fi

echo ""
