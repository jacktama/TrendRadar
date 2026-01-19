@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

title TrendRadar 配置编辑器部署工具

:: 颜色定义
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E" echo on') do (
  set "DEL=%%a"
)
call :ColoredEcho 0b "==========================================="
echo    TrendRadar 配置编辑器部署管理工具
call :ColoredEcho 0b "==========================================="
echo.

:menu
echo 1) 部署配置编辑器
echo 2) 重启TrendRadar服务 (修改配置后执行)
echo 3) 重启配置编辑器
echo 4) 停止配置编辑器
echo 5) 查看服务状态
echo 6) 退出
echo.
set /p choice=请选择操作 (1-6): 

if "!choice!"=="1" goto deploy
if "!choice!"=="2" goto restart_trendradar
if "!choice!"=="3" goto restart_config_editor
if "!choice!"=="4" goto stop_config_editor
if "!choice!"=="5" goto show_status
if "!choice!"=="6" goto exit_script

echo 无效的选择，请输入1-6之间的数字
pause
goto menu

:deploy
echo 开始部署配置编辑器...
cd /d "%~dp0docker"
docker-compose -f docker-compose-config-editor.yml up -d --build
if !errorlevel! equ 0 (
    echo 配置编辑器已成功部署！
    echo 访问地址: http://localhost:5000
    echo 配置编辑器允许您通过Web界面编辑项目的配置文件
) else (
    echo 配置编辑器部署失败
)
cd /d "%~dp0"
pause
goto menu

:restart_trendradar
echo 正在重启TrendRadar服务...
docker-compose -f docker\docker-compose-build.yml down
docker-compose -f docker\docker-compose-build.yml up -d
if !errorlevel! equ 0 (
    echo TrendRadar服务已成功重启！
) else (
    echo TrendRadar服务重启失败
)
pause
goto menu

:restart_config_editor
echo 正在重启配置编辑器...
cd /d "%~dp0docker"
docker-compose -f docker-compose-config-editor.yml restart
if !errorlevel! equ 0 (
    echo 配置编辑器已成功重启！
) else (
    echo 配置编辑器重启失败
)
cd /d "%~dp0"
pause
goto menu

:stop_config_editor
echo 正在停止配置编辑器...
cd /d "%~dp0docker"
docker-compose -f docker-compose-config-editor.yml down
echo 配置编辑器已停止
cd /d "%~dp0"
pause
goto menu

:show_status
echo 当前容器状态:
docker ps ^| findstr trendradar
pause
goto menu

:exit_script
echo 退出管理工具
exit /b

:: 彩色输出函数
:ColoredEcho
set "text=%~2"
set /p ".=<NUL" /DEV:NULL
set /a "color=%~1 & 0xF, bg=%~1 >> 4 & 0xF"
echo %text%
goto :EOF