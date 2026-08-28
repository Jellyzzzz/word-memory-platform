@echo off
setlocal

REM ============================================================
REM  word-memory-platform  stop script  (shut down Tomcat)
REM ============================================================

set "PROJECT_DIR=%~dp0"
set "CATALINA_HOME=%PROJECT_DIR%tomcat"

if exist "%CATALINA_HOME%\bin\shutdown.bat" (
    echo [INFO] Stopping Tomcat ...
    call "%CATALINA_HOME%\bin\shutdown.bat"
    %SystemRoot%\System32\timeout.exe /t 3 /nobreak >nul
) else (
    echo [ERROR] Tomcat not found at "%CATALINA_HOME%"
)

echo.
pause
