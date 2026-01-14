#!/bin/bash
# 验证 spec.md 完整性和质量
# 用法: ./validate-spec.sh <spec-file> [mode]

set -e

SPEC_FILE="${1:?用法: validate-spec.sh <spec-file> [mode]}"
MODE="${2:-standard}"

if [ ! -f "$SPEC_FILE" ]; then
    echo "错误: 文件未找到: $SPEC_FILE"
    exit 1
fi

echo "验证中: $SPEC_FILE (模式: $MODE)"
echo "================================================"

ERRORS=0
WARNINGS=0

# 检查禁止的模糊词汇（与 SKILL.md 和 phase-details.md 一致）
# 英文词汇
FORBIDDEN_EN="fast|quick|simple|easy|user-friendly|intuitive|robust|scalable"
# 中文词汇
FORBIDDEN_CN="快速|简单|容易|友好|直观|健壮|可扩展"
FORBIDDEN_TERMS="$FORBIDDEN_EN|$FORBIDDEN_CN"

if grep -iE "$FORBIDDEN_TERMS" "$SPEC_FILE" > /dev/null 2>&1; then
    # 排除包含数字的行（可能已量化）
    AMBIGUOUS_LINES=$(grep -inE "$FORBIDDEN_TERMS" "$SPEC_FILE" | grep -v "[0-9]" || true)
    if [ -n "$AMBIGUOUS_LINES" ]; then
        echo "[错误] 发现未量化的模糊词汇:"
        echo "$AMBIGUOUS_LINES" | head -5
        ((ERRORS++))
    fi
fi

# 检查占位符文本
if grep -E "\{[^}]+\}|TODO|TBD|FIXME" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[错误] 发现占位符文本:"
    grep -nE "\{[^}]+\}|TODO|TBD|FIXME" "$SPEC_FILE" | head -5
    ((ERRORS++))
fi

# 检查用户故事格式（支持中英文多行格式）
# 必须包含三个部分: As a / I want to / So that 或 作为 / 我想要 / 以便
US_VALID=false

# 方法 1: 英文多行格式
if grep -Pzo "As a [^\n]+,?\s*\nI want to [^\n]+,?\s*\nSo that" "$SPEC_FILE" > /dev/null 2>&1; then
    US_VALID=true
fi

# 方法 2: 英文单行格式
if [ "$US_VALID" = false ]; then
    if grep -E "As a .+, I want to .+, So that" "$SPEC_FILE" > /dev/null 2>&1; then
        US_VALID=true
    fi
fi

# 方法 3: 英文代码块格式
if [ "$US_VALID" = false ]; then
    US_BLOCK=$(grep -A3 "As a " "$SPEC_FILE" 2>/dev/null || true)
    if echo "$US_BLOCK" | grep -q "I want to" && echo "$US_BLOCK" | grep -q "So that"; then
        US_VALID=true
    fi
fi

# 方法 4: 中文多行格式
if [ "$US_VALID" = false ]; then
    if grep -Pzo "作为 [^\n]+,?\s*\n我想要 [^\n]+,?\s*\n以便" "$SPEC_FILE" > /dev/null 2>&1; then
        US_VALID=true
    fi
fi

# 方法 5: 中文单行格式
if [ "$US_VALID" = false ]; then
    if grep -E "作为.+，我想要.+，以便" "$SPEC_FILE" > /dev/null 2>&1; then
        US_VALID=true
    fi
fi

# 方法 6: 中文代码块格式
if [ "$US_VALID" = false ]; then
    US_BLOCK_CN=$(grep -A3 "作为 " "$SPEC_FILE" 2>/dev/null || true)
    if echo "$US_BLOCK_CN" | grep -q "我想要" && echo "$US_BLOCK_CN" | grep -q "以便"; then
        US_VALID=true
    fi
fi

if [ "$US_VALID" = false ]; then
    echo "[错误] 未找到有效的用户故事格式"
    echo "  预期格式（英文）: As a {role}, I want to {action}, So that I can {benefit}."
    echo "  预期格式（中文）: 作为 {角色}，我想要 {动作}，以便 {收益}。"
    echo "  三个部分都是必需的。"
    ((ERRORS++))
fi

# 检查每个故事的验收标准数量（推荐 3-7 个）
US_COUNT=0
AC_COUNT=0

# 计算用户故事数量
if grep -c "### US-[0-9]" "$SPEC_FILE" > /dev/null 2>&1; then
    US_COUNT=$(grep -c "### US-[0-9]" "$SPEC_FILE")
fi
if [ "$US_COUNT" -eq 0 ]; then
    US_COUNT=1  # 假设至少有一个故事
fi

# 计算验收标准数量
if grep -c "\- \[ \] AC-" "$SPEC_FILE" > /dev/null 2>&1; then
    AC_COUNT=$(grep -c "\- \[ \] AC-" "$SPEC_FILE")
fi
if [ "$AC_COUNT" -eq 0 ]; then
    # 尝试其他格式
    if grep -c "AC-[0-9]" "$SPEC_FILE" > /dev/null 2>&1; then
        AC_COUNT=$(grep -c "AC-[0-9]" "$SPEC_FILE")
    fi
fi

if [ "$US_COUNT" -gt 0 ] && [ "$AC_COUNT" -gt 0 ]; then
    AVG_AC=$((AC_COUNT / US_COUNT))
    if [ "$AVG_AC" -lt 3 ]; then
        echo "[警告] 每个故事的平均 AC 数量 ($AVG_AC) 低于推荐值 (3-7)"
        ((WARNINGS++))
    elif [ "$AVG_AC" -gt 7 ]; then
        echo "[警告] 每个故事的平均 AC 数量 ($AVG_AC) 超过推荐值 (3-7)"
        ((WARNINGS++))
    else
        echo "[信息] 每个故事的 AC 数量: $AVG_AC（在 3-7 范围内）"
    fi
elif [ "$AC_COUNT" -eq 0 ]; then
    echo "[警告] 未找到验收标准"
    ((WARNINGS++))
fi

# 模式特定检查
case "$MODE" in
    mini)
        # 仅检查章节 1, 3, 7, 9
        for section in "## 1. Overview" "## 3. User Stories" "## 7. Out of Scope" "## 9. Acceptance Checklist"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                # 也检查中文章节标题
                section_cn=$(echo "$section" | sed 's/Overview/概述/; s/User Stories/用户故事/; s/Out of Scope/范围外/; s/Acceptance Checklist/验收清单/')
                if ! grep -F "$section_cn" "$SPEC_FILE" > /dev/null 2>&1; then
                    echo "[错误] 缺少必需章节: $section"
                    ((ERRORS++))
                fi
            fi
        done
        ;;
    standard)
        # 检查章节 1-7, 9
        for section in "## 1. Overview" "## 2. Problem Statement" "## 3. User Stories" "## 4. Functional Requirements" "## 5. Non-Functional Requirements" "## 6. Constraints" "## 7. Out of Scope" "## 9. Acceptance Checklist"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                # 也检查中文章节标题
                section_cn=$(echo "$section" | sed 's/Overview/概述/; s/Problem Statement/问题陈述/; s/User Stories/用户故事/; s/Functional Requirements/功能性需求/; s/Non-Functional Requirements/非功能性需求/; s/Constraints/约束条件/; s/Out of Scope/范围外/; s/Acceptance Checklist/验收清单/')
                if ! grep -F "$section_cn" "$SPEC_FILE" > /dev/null 2>&1; then
                    echo "[错误] 缺少必需章节: $section"
                    ((ERRORS++))
                fi
            fi
        done
        # 检查 NFR 是否量化
        NFR_SECTION=$(sed -n '/## 5. Non-Functional/,/## 6\./p' "$SPEC_FILE" 2>/dev/null || true)
        if [ -n "$NFR_SECTION" ]; then
            NFR_WITHOUT_NUMBERS=$(echo "$NFR_SECTION" | grep -E "Performance|Reliability|Scalability|Security|性能|可靠性|可扩展性|安全" | grep -v "[0-9%]" || true)
            if [ -n "$NFR_WITHOUT_NUMBERS" ]; then
                echo "[警告] 部分 NFR 可能未量化:"
                echo "$NFR_WITHOUT_NUMBERS" | head -3
                ((WARNINGS++))
            fi
        fi
        ;;
    full)
        # 检查所有章节包括附录
        for section in "## 1. Overview" "## 2. Problem Statement" "## 3. User Stories" "## 4. Functional Requirements" "## 5. Non-Functional Requirements" "## 6. Constraints" "## 7. Out of Scope" "## 8. Open Questions" "## 9. Acceptance Checklist" "### A. Glossary" "### B. References" "### C. Change History"; do
            if ! grep -F "$section" "$SPEC_FILE" > /dev/null 2>&1; then
                # 也检查中文章节标题
                section_cn=$(echo "$section" | sed 's/Overview/概述/; s/Problem Statement/问题陈述/; s/User Stories/用户故事/; s/Functional Requirements/功能性需求/; s/Non-Functional Requirements/非功能性需求/; s/Constraints/约束条件/; s/Out of Scope/范围外/; s/Open Questions/待解决问题/; s/Acceptance Checklist/验收清单/; s/Glossary/术语表/; s/References/参考文献/; s/Change History/变更历史/')
                if ! grep -F "$section_cn" "$SPEC_FILE" > /dev/null 2>&1; then
                    echo "[错误] 缺少必需章节: $section"
                    ((ERRORS++))
                fi
            fi
        done
        ;;
esac

# 检查状态
if grep -E "Status.*approved|状态.*已批准" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[信息] Spec 状态: 已批准"
elif grep -E "Status.*draft|状态.*草稿" "$SPEC_FILE" > /dev/null 2>&1; then
    echo "[信息] Spec 状态: 草稿（尚未批准）"
fi

echo "================================================"
echo "验证完成: $ERRORS 个错误, $WARNINGS 个警告"

if [ "$ERRORS" -gt 0 ]; then
    echo "结果: 失败"
    exit 1
else
    echo "结果: 通过"
    exit 0
fi
