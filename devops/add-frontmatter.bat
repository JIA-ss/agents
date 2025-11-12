@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  Claude Code Agents - Add Frontmatter Tool
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

echo [INFO] 扫描目录: %SOURCE_DIR%
echo.

REM 统计变量
set "total_files=0"
set "updated_files=0"
set "skipped_files=0"

REM 遍历所有 .md 文件
for %%f in ("%SOURCE_DIR%\*.md") do (
    set /a total_files+=1
    set "filename=%%~nxf"
    set "filepath=%%f"
    set "agent_name=%%~nf"

    echo [SCAN] 检查文件: !filename!

    REM 读取第一行
    set "first_line="
    for /f "usebackq delims=" %%a in ("%%f") do (
        set "first_line=%%a"
        goto :check_frontmatter
    )

    :check_frontmatter
    REM 检查是否已有 frontmatter
    if "!first_line!"=="---" (
        echo [SKIP] 文件已包含 frontmatter: !filename!
        set /a skipped_files+=1
        echo.
        goto :next_file
    )

    REM 提取描述（从第一个 # 标题）
    set "description="
    for /f "usebackq tokens=* delims=" %%a in ("%%f") do (
        set "line=%%a"
        if "!line:~0,2!"=="# " (
            set "description=!line:~2!"
            goto :found_title
        )
    )

    :found_title
    REM 如果没找到标题，使用默认描述
    if "!description!"=="" (
        set "description=!agent_name! agent"
    )

    REM 创建备份
    copy /Y "%%f" "%%f.bak" >nul
    echo [BACKUP] 已创建备份: !filename!.bak

    REM 创建临时文件
    set "temp_file=%TEMP%\frontmatter_temp_!random!.md"

    REM 写入 frontmatter 到临时文件
    (
        echo ---
        echo name: !agent_name!
        echo description: !description!
        echo model: sonnet
        echo ---
        echo.
    ) > "!temp_file!"

    REM 追加原文件内容
    type "%%f" >> "!temp_file!"

    REM 替换原文件
    copy /Y "!temp_file!" "%%f" >nul
    del "!temp_file!"

    echo [SUCCESS] 已添加 frontmatter: !filename!
    echo   ^→ name: !agent_name!
    echo   ^→ description: !description!
    echo   ^→ model: sonnet
    set /a updated_files+=1
    echo.

    :next_file
)

REM 显示统计结果
echo ========================================
echo [统计] 处理完成
echo ----------------------------------------
echo   总文件数: %total_files%
echo   已更新: %updated_files%
echo   已跳过: %skipped_files%
echo ========================================
echo.

if %updated_files% gtr 0 (
    echo [提示] 备份文件已保存为 .md.bak
    echo [提示] 请检查更新后的文件，确认 description 是否正确
    echo [提示] 如需恢复，可以使用备份文件
    echo.
    echo [下一步] 运行 deploy-windows.bat 部署更新后的 agents
)

echo.
pause
