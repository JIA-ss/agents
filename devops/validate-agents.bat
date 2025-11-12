@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  Claude Code Agents - Validation Tool
echo ========================================
echo.

REM 定义目录
set "SOURCE_DIR=%~dp0..\agents"

REM 检查源目录
if not exist "%SOURCE_DIR%" (
    echo [ERROR] 源文件目录不存在: %SOURCE_DIR%
    pause
    exit /b 1
)

echo [INFO] 验证目录: %SOURCE_DIR%
echo.

REM 统计变量
set "total_files=0"
set "passed_files=0"
set "failed_files=0"
set "failed_list="

REM 遍历所有 .md 文件
for %%f in ("%SOURCE_DIR%\*.md") do (
    set /a total_files+=1
    set "filename=%%~nxf"
    set "filepath=%%f"
    set "errors_found=0"

    echo [CHECK] 验证文件: !filename!

    REM 检查 1: 文件名格式（小写-连字符.md）
    echo !filename! | findstr /R /C:"^[a-z0-9][a-z0-9-]*\.md$" >nul
    if errorlevel 1 (
        echo   ✗ 文件名不符合规范（应为小写-连字符.md）
        set "errors_found=1"
    ) else (
        echo   ✓ 文件名格式正确
    )

    REM 检查 2: Frontmatter 存在性
    set "first_line="
    for /f "usebackq delims=" %%a in ("%%f") do (
        set "first_line=%%a"
        goto :check_frontmatter_%%f
    )

    :check_frontmatter_%%f
    if not "!first_line!"=="---" (
        echo   ✗ 缺少 YAML frontmatter（第一行应为 ---）
        set "errors_found=1"
    ) else (
        echo   ✓ 包含 frontmatter

        REM 检查 3: Frontmatter 必需字段
        findstr /C:"name:" "%%f" >nul
        if errorlevel 1 (
            echo   ✗ Frontmatter 缺少 'name' 字段
            set "errors_found=1"
        ) else (
            echo   ✓ 包含 'name' 字段
        )

        findstr /C:"description:" "%%f" >nul
        if errorlevel 1 (
            echo   ✗ Frontmatter 缺少 'description' 字段
            set "errors_found=1"
        ) else (
            echo   ✓ 包含 'description' 字段
        )

        findstr /C:"model:" "%%f" >nul
        if errorlevel 1 (
            echo   ✗ Frontmatter 缺少 'model' 字段
            set "errors_found=1"
        ) else (
            echo   ✓ 包含 'model' 字段
        )
    )

    REM 检查 4: 必需章节
    findstr /C:"## 概述" "%%f" >nul
    if errorlevel 1 (
        echo   ⚠ 缺少 '## 概述' 章节（推荐）
    ) else (
        echo   ✓ 包含 '## 概述' 章节
    )

    findstr /C:"## 核心能力" "%%f" >nul
    if errorlevel 1 (
        echo   ⚠ 缺少 '## 核心能力架构' 章节（推荐）
    ) else (
        echo   ✓ 包含 '## 核心能力架构' 章节
    )

    findstr /C:"## 工作流程" "%%f" >nul
    if errorlevel 1 (
        echo   ⚠ 缺少 '## 工作流程' 章节（推荐）
    ) else (
        echo   ✓ 包含 '## 工作流程' 章节
    )

    REM 检查 5: Mermaid 图表
    find /C "```mermaid" "%%f" >nul
    if errorlevel 1 (
        echo   ⚠ 未找到 Mermaid 图表（推荐至少包含 2 个）
    ) else (
        echo   ✓ 包含 Mermaid 图表
    )

    echo.

    REM 统计结果
    if "!errors_found!"=="0" (
        set /a passed_files+=1
    ) else (
        set /a failed_files+=1
        set "failed_list=!failed_list! !filename!"
    )
)

REM 显示统计结果
echo ========================================
echo [统计] 验证完成
echo ----------------------------------------
echo   总文件数: %total_files%
echo   通过: %passed_files%
echo   失败: %failed_files%
echo ========================================
echo.

if %failed_files% gtr 0 (
    echo [失败文件列表]
    for %%e in (%failed_list%) do (
        echo   ✗ %%e
    )
    echo.
    echo [建议] 运行 add-frontmatter.bat 自动添加 frontmatter
    echo [文档] 参考 AGENT_SPEC.md 了解完整规范
    pause
    exit /b 1
) else (
    echo [SUCCESS] 所有 agent 文件都符合规范！
    echo [下一步] 运行 deploy-windows.bat 部署 agents
    pause
    exit /b 0
)
