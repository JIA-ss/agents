@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo  Skills / Agents / Commands 部署工具
echo  模式: 软连接 (symlink)
echo  支持: Claude Code + Codex CLI
echo ========================================
echo.

REM 定义源目录（仓库根目录）
set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR%.."

REM 定义目标环境
set "CLAUDE_BASE=%USERPROFILE%\.claude"
set "CODEX_BASE=%USERPROFILE%\.codex"

REM 需要部署的资源
set "RESOURCES=skills agents commands"

set "total_links=0"
set "total_skipped=0"
set "total_errors=0"

echo [1/3] 检查源文件目录...
echo   仓库路径: %REPO_DIR%
for %%R in (%RESOURCES%) do (
    if exist "%REPO_DIR%\%%R\" (
        echo   [OK]   %%R\ 目录存在
    ) else (
        echo   [WARN] %%R\ 目录不存在，将跳过
    )
)
echo.

echo [2/3] 部署到 Claude Code (%CLAUDE_BASE%)...
if not exist "%CLAUDE_BASE%" mkdir "%CLAUDE_BASE%"
for %%R in (%RESOURCES%) do (
    call :create_symlink "%REPO_DIR%\%%R" "%CLAUDE_BASE%\%%R" "%%R" "Claude Code"
)
echo.

echo [3/3] 部署到 Codex CLI (%CODEX_BASE%)...
if not exist "%CODEX_BASE%" mkdir "%CODEX_BASE%"
for %%R in (%RESOURCES%) do (
    call :create_symlink "%REPO_DIR%\%%R" "%CODEX_BASE%\%%R" "%%R" "Codex CLI"
)
echo.

echo ========================================
echo [DONE] 部署完成！
echo.
echo   新建软连接: %total_links%
echo   已存在/跳过: %total_skipped%
if %total_errors% gtr 0 echo   错误: %total_errors%
echo.

echo 软连接状态:
echo ----------------------------------------
echo   Claude Code:
for %%R in (%RESOURCES%) do (
    if exist "%CLAUDE_BASE%\%%R\" (
        REM 检查是否为软连接
        fsutil reparsepoint query "%CLAUDE_BASE%\%%R" >nul 2>&1
        if !errorlevel! equ 0 (
            echo     %%R -^> [symlink]
        ) else (
            echo     %%R [普通目录]
        )
    ) else (
        echo     %%R [不存在]
    )
)
echo   Codex CLI:
for %%R in (%RESOURCES%) do (
    if exist "%CODEX_BASE%\%%R\" (
        fsutil reparsepoint query "%CODEX_BASE%\%%R" >nul 2>&1
        if !errorlevel! equ 0 (
            echo     %%R -^> [symlink]
        ) else (
            echo     %%R [普通目录]
        )
    ) else (
        echo     %%R [不存在]
    )
)
echo ----------------------------------------
echo.

echo 已部署的资源:
echo ----------------------------------------
for %%R in (%RESOURCES%) do (
    if exist "%REPO_DIR%\%%R\" (
        echo   %%R/:
        if "%%R"=="skills" (
            for /d %%D in ("%REPO_DIR%\%%R\*") do (
                if exist "%%D\SKILL.md" echo     %%~nxD
            )
        ) else (
            for %%F in ("%REPO_DIR%\%%R\*.md") do (
                echo     %%~nF
            )
        )
    )
)
echo ----------------------------------------
echo.
echo [提示] 软连接模式下，修改仓库中的文件会立即生效，无需重新部署
echo [提示] 重启 Claude Code / Codex 以加载变更
echo [提示] Windows 创建软连接可能需要管理员权限或开发者模式
echo.

pause
exit /b 0

REM ========== 子程序: 创建软连接 ==========
:create_symlink
set "source_dir=%~1"
set "target_link=%~2"
set "res_name=%~3"
set "env_name=%~4"

REM 源目录不存在则跳过
if not exist "%source_dir%\" (
    echo   [SKIP] %res_name% - 源目录不存在
    set /a total_skipped+=1
    goto :eof
)

REM 检查目标是否已经是软连接（junction）
if exist "%target_link%\" (
    fsutil reparsepoint query "%target_link%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [OK]   %res_name% -^> 已是软连接
        set /a total_skipped+=1
        goto :eof
    )

    REM 目标是普通目录，备份
    set "backup_name=%target_link%.backup-%date:~0,4%%date:~5,2%%date:~8,2%"
    echo   [BAK]  %res_name% -^> 备份现有目录
    move "%target_link%" "!backup_name!" >nul 2>&1
)

REM 创建 junction（不需要管理员权限）
mklink /J "%target_link%" "%source_dir%" >nul 2>&1
if !errorlevel! equ 0 (
    echo   [LINK] %res_name% -^> %source_dir%
    set /a total_links+=1
) else (
    REM junction 失败，尝试 symlink（需要管理员权限或开发者模式）
    mklink /D "%target_link%" "%source_dir%" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   [LINK] %res_name% -^> %source_dir% (symlink)
        set /a total_links+=1
    ) else (
        echo   [ERR]  %res_name% -^> 创建软连接失败，请以管理员权限运行
        set /a total_errors+=1
    )
)
goto :eof
