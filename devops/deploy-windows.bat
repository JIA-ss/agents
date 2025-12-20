@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  Skills 部署工具 (Windows)
echo  支持: Claude Code + Codex CLI
echo ========================================
echo.

REM 定义目标目录
set "CLAUDE_SKILL_DIR=%USERPROFILE%\.claude\skills"
set "CODEX_SKILL_DIR=%USERPROFILE%\.codex\skills"
set "SOURCE_DIR=%~dp0..\skills"

echo [1/5] 检查源文件目录...
if not exist "%SOURCE_DIR%" (
    echo [ERROR] 源文件目录不存在: %SOURCE_DIR%
    echo [ERROR] 请确保在项目根目录下执行此脚本
    pause
    exit /b 1
)
echo [INFO] 源文件目录: %SOURCE_DIR%
echo.

echo [2/5] 部署到 Claude Code...
if not exist "%CLAUDE_SKILL_DIR%" (
    echo [INFO] 目标目录不存在，正在创建: %CLAUDE_SKILL_DIR%
    mkdir "%CLAUDE_SKILL_DIR%"
    if !errorlevel! neq 0 (
        echo [ERROR] 创建目录失败！
        pause
        exit /b 1
    )
    echo [SUCCESS] 目录创建成功
) else (
    echo [INFO] 目标目录已存在: %CLAUDE_SKILL_DIR%
)

set "claude_count=0"
for /d %%d in ("%SOURCE_DIR%\*") do (
    if exist "%%d\SKILL.md" (
        set "skill_name=%%~nxd"
        if not exist "%CLAUDE_SKILL_DIR%\!skill_name!" mkdir "%CLAUDE_SKILL_DIR%\!skill_name!"
        echo [COPY] !skill_name!\SKILL.md
        copy /Y "%%d\SKILL.md" "%CLAUDE_SKILL_DIR%\!skill_name!\" >nul
        if !errorlevel! equ 0 (
            set /a claude_count+=1
        ) else (
            echo [WARNING] 复制失败: !skill_name!\SKILL.md
        )
    )
)
echo [SUCCESS] Claude Code: 成功部署 %claude_count% 个 skill 文件
echo.

echo [3/5] 部署到 Codex CLI...
if not exist "%CODEX_SKILL_DIR%" (
    echo [INFO] 目标目录不存在，正在创建: %CODEX_SKILL_DIR%
    mkdir "%CODEX_SKILL_DIR%"
    if !errorlevel! neq 0 (
        echo [ERROR] 创建目录失败！
        pause
        exit /b 1
    )
    echo [SUCCESS] 目录创建成功
) else (
    echo [INFO] 目标目录已存在: %CODEX_SKILL_DIR%
)

set "codex_count=0"
for /d %%d in ("%SOURCE_DIR%\*") do (
    if exist "%%d\SKILL.md" (
        set "skill_name=%%~nxd"
        if not exist "%CODEX_SKILL_DIR%\!skill_name!" mkdir "%CODEX_SKILL_DIR%\!skill_name!"
        echo [COPY] !skill_name!\SKILL.md
        copy /Y "%%d\SKILL.md" "%CODEX_SKILL_DIR%\!skill_name!\" >nul
        if !errorlevel! equ 0 (
            set /a codex_count+=1
        ) else (
            echo [WARNING] 复制失败: !skill_name!\SKILL.md
        )
    )
)
echo [SUCCESS] Codex: 成功部署 %codex_count% 个 skill 文件
echo.

echo [4/5] 部署结果汇总...
echo ========================================
echo [SUCCESS] 部署完成！
echo.
echo 部署路径:
echo   Claude Code: %CLAUDE_SKILL_DIR%
echo   Codex CLI:   %CODEX_SKILL_DIR%
echo.

echo [5/5] 已部署的 skills 列表:
echo ----------------------------------------
for /d %%d in ("%CLAUDE_SKILL_DIR%\*") do (
    if exist "%%d\SKILL.md" (
        echo   %%~nxd
    )
)
echo ----------------------------------------
echo.

echo [提示] 请重启 Claude Code / Codex 以加载新的 skill 配置
echo [提示] Codex 启用 skills: codex --enable skills
echo.

pause
