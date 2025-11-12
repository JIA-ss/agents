#!/bin/bash

# Claude Code Agents - Validate Agents Tool (macOS/Linux)
# 验证 agents/ 目录下的所有 .md 文件是否符合 AGENT_SPEC.md 规范
# 使用方法: chmod +x validate-agents.sh && ./validate-agents.sh

set -e

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================"
echo " Claude Code Agents - Validation Tool"
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

echo -e "${BLUE}[INFO]${NC} 验证目录: $SOURCE_DIR"
echo ""

# 统计变量
total_files=0
passed_files=0
failed_files=0
errors=()

# 验证单个文件
validate_file() {
    local file="$1"
    local filename=$(basename "$file")
    local errors_found=0

    echo -e "${BLUE}[CHECK]${NC} 验证文件: $filename"

    # 检查 1: 文件名格式（小写-连字符.md）
    if ! [[ "$filename" =~ ^[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
        echo -e "  ${RED}✗${NC} 文件名不符合规范（应为小写-连字符.md）"
        errors_found=1
    else
        echo -e "  ${GREEN}✓${NC} 文件名格式正确"
    fi

    # 检查 2: Frontmatter 存在性
    first_line=$(head -n 1 "$file")
    if [ "$first_line" != "---" ]; then
        echo -e "  ${RED}✗${NC} 缺少 YAML frontmatter（第一行应为 ---）"
        errors_found=1
    else
        echo -e "  ${GREEN}✓${NC} 包含 frontmatter"

        # 检查 3: Frontmatter 必需字段
        has_name=$(grep -c "^name:" "$file" || echo 0)
        has_desc=$(grep -c "^description:" "$file" || echo 0)
        has_model=$(grep -c "^model:" "$file" || echo 0)

        if [ "$has_name" -eq 0 ]; then
            echo -e "  ${RED}✗${NC} Frontmatter 缺少 'name' 字段"
            errors_found=1
        else
            echo -e "  ${GREEN}✓${NC} 包含 'name' 字段"
        fi

        if [ "$has_desc" -eq 0 ]; then
            echo -e "  ${RED}✗${NC} Frontmatter 缺少 'description' 字段"
            errors_found=1
        else
            echo -e "  ${GREEN}✓${NC} 包含 'description' 字段"
        fi

        if [ "$has_model" -eq 0 ]; then
            echo -e "  ${RED}✗${NC} Frontmatter 缺少 'model' 字段"
            errors_found=1
        else
            echo -e "  ${GREEN}✓${NC} 包含 'model' 字段"
        fi
    fi

    # 检查 4: 必需章节（概述、核心能力架构、工作流程、输出格式）
    has_overview=$(grep -c "^## 概述" "$file" || echo 0)
    has_arch=$(grep -c "^## 核心能力" "$file" || echo 0)
    has_workflow=$(grep -c "^## 工作流程" "$file" || echo 0)
    has_output=$(grep -c "^## 输出格式" "$file" || echo 0)

    if [ "$has_overview" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} 缺少 '## 概述' 章节（推荐）"
    else
        echo -e "  ${GREEN}✓${NC} 包含 '## 概述' 章节"
    fi

    if [ "$has_arch" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} 缺少 '## 核心能力架构' 章节（推荐）"
    else
        echo -e "  ${GREEN}✓${NC} 包含 '## 核心能力架构' 章节"
    fi

    if [ "$has_workflow" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} 缺少 '## 工作流程' 章节（推荐）"
    else
        echo -e "  ${GREEN}✓${NC} 包含 '## 工作流程' 章节"
    fi

    # 检查 5: Mermaid 图表
    mermaid_count=$(grep -c '```mermaid' "$file" || echo 0)
    if [ "$mermaid_count" -eq 0 ]; then
        echo -e "  ${YELLOW}⚠${NC} 未找到 Mermaid 图表（推荐至少包含 2 个）"
    elif [ "$mermaid_count" -lt 2 ]; then
        echo -e "  ${YELLOW}⚠${NC} 仅包含 $mermaid_count 个 Mermaid 图表（推荐至少 2 个）"
    else
        echo -e "  ${GREEN}✓${NC} 包含 $mermaid_count 个 Mermaid 图表"
    fi

    echo ""

    if [ "$errors_found" -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

# 遍历所有 .md 文件
for file in "$SOURCE_DIR"/*.md; do
    # 检查文件是否存在
    if [ ! -f "$file" ]; then
        continue
    fi

    ((total_files++))

    if validate_file "$file"; then
        ((passed_files++))
    else
        ((failed_files++))
        errors+=("$(basename "$file")")
    fi
done

# 显示统计结果
echo "========================================"
echo -e "${BLUE}[统计]${NC} 验证完成"
echo "----------------------------------------"
echo -e "  总文件数: $total_files"
echo -e "  通过: ${GREEN}$passed_files${NC}"
echo -e "  失败: ${RED}$failed_files${NC}"
echo "========================================"
echo ""

if [ "$failed_files" -gt 0 ]; then
    echo -e "${RED}[失败文件列表]${NC}"
    for error_file in "${errors[@]}"; do
        echo -e "  ${RED}✗${NC} $error_file"
    done
    echo ""
    echo -e "${YELLOW}[建议]${NC} 运行 ./add-frontmatter.sh 自动添加 frontmatter"
    echo -e "${YELLOW}[文档]${NC} 参考 AGENT_SPEC.md 了解完整规范"
    exit 1
else
    echo -e "${GREEN}[SUCCESS]${NC} 所有 agent 文件都符合规范！ 🎉"
    echo -e "${BLUE}[下一步]${NC} 运行 ./deploy-macos.sh 部署 agents"
    exit 0
fi
