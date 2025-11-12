@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  Claude Code Agents 部署工具 (Windows)
echo ========================================
echo.

REM 定义目标目录
set "AGENT_DIR=%USERPROFILE%\.claude\agents"
set "SOURCE_DIR=%~dp0..\agents"

echo [1/4] 检测目标目录...
if not exist "%AGENT_DIR%" (
    echo [INFO] 目标目录不存在，正在创建: %AGENT_DIR%
    mkdir "%AGENT_DIR%"
    if !errorlevel! neq 0 (
        echo [ERROR] 创建目录失败！
        pause
        exit /b 1
    )
    echo [SUCCESS] 目录创建成功
) else (
    echo [INFO] 目标目录已存在: %AGENT_DIR%
)
echo.

echo [2/4] 检查源文件目录...
if not exist "%SOURCE_DIR%" (
    echo [ERROR] 源文件目录不存在: %SOURCE_DIR%
    echo [ERROR] 请确保在项目根目录下执行此脚本
    pause
    exit /b 1
)
echo [INFO] 源文件目录: %SOURCE_DIR%
echo.

echo [3/4] 复制 agent 文件...
set "file_count=0"
for %%f in ("%SOURCE_DIR%\*.md") do (
    echo [COPY] %%~nxf
    copy /Y "%%f" "%AGENT_DIR%\" >nul
    if !errorlevel! equ 0 (
        set /a file_count+=1
    ) else (
        echo [WARNING] 复制失败: %%~nxf
    )
)
echo.

echo [4/4] 部署结果...
if %file_count% equ 0 (
    echo [WARNING] 没有找到任何 .md 文件
    echo [INFO] 请确保 agents/ 目录下有 agent 文件
) else (
    echo [SUCCESS] 成功部署 %file_count% 个 agent 文件
    echo.
    echo 已部署的文件列表:
    echo ----------------------------------------
    dir /b "%AGENT_DIR%\*.md"
    echo ----------------------------------------
)
echo.

echo [SUCCESS] 部署完成！
echo [INFO] 部署路径: %AGENT_DIR%
echo.
echo [提示] 请重启 Claude Code 以加载新的 agent 配置
echo.

pause
