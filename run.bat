@echo off
setlocal

REM ============================================================
REM  word-memory-platform  one-click runner
REM  Build -> deploy WAR -> start Tomcat -> open browser
REM
REM  Prereqs (all already configured on this machine):
REM    - MySQL 8  (Windows service "MySQL80")
REM    - JDK 17+   (JAVA_HOME)
REM    - Maven     (MAVEN_HOME, or on PATH)
REM ============================================================

REM -- project dir = this script's directory --
set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

REM -- Java: JDK 17+ required. Use JAVA_HOME if set, else fall back --
if "%JAVA_HOME%"=="" set "JAVA_HOME=C:\Program Files\BellSoft\LibericaJDK-21"
if not exist "%JAVA_HOME%\bin\java.exe" (
    echo [ERROR] JDK not found at "%JAVA_HOME%"
    echo         Please set JAVA_HOME to a JDK 17+ installation.
    goto :end
)
set "JRE_HOME=%JAVA_HOME%"

REM -- Tomcat lives inside the project (tomcat/) --
set "CATALINA_HOME=%PROJECT_DIR%tomcat"
if not exist "%CATALINA_HOME%\bin\catalina.bat" (
    echo [ERROR] Tomcat not found at "%CATALINA_HOME%"
    goto :end
)

REM -- MySQL service (change the name if yours differs) --
set "MYSQL_SERVICE=MySQL80"
sc query "%MYSQL_SERVICE%" | findstr /i "RUNNING" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Starting MySQL service "%MYSQL_SERVICE%" ...
    net start "%MYSQL_SERVICE%" >nul 2>&1
)

REM -- Maven: prefer MAVEN_HOME, then a known path, then PATH --
set "MVN=%MAVEN_HOME%\bin\mvn.cmd"
if not exist "%MVN%" set "MVN=C:\Users\28206\tools\apache-maven-3.9.16\bin\mvn.cmd"
if not exist "%MVN%" set "MVN=mvn.cmd"

echo [INFO] Building WAR (mvn clean package) ...
call "%MVN%" -q clean package
if errorlevel 1 (
    echo [ERROR] Build failed. See output above.
    goto :end
)

REM -- stop old Tomcat if it is already running --
if exist "%CATALINA_HOME%\bin\shutdown.bat" (
    call "%CATALINA_HOME%\bin\shutdown.bat" >nul 2>&1
    %SystemRoot%\System32\timeout.exe /t 3 /nobreak >nul
)

REM -- deploy the freshly built WAR --
copy /y "%PROJECT_DIR%target\word-memory-platform.war" "%CATALINA_HOME%\webapps\" >nul
echo [INFO] WAR deployed.

REM -- start Tomcat --
echo [INFO] Starting Tomcat ...
call "%CATALINA_HOME%\bin\startup.bat"

echo [INFO] Waiting for Tomcat to start ...
%SystemRoot%\System32\timeout.exe /t 8 /nobreak >nul

REM -- open the app in the default browser --
start "" "http://localhost:8080/word-memory-platform/login"

echo.
echo ==========================================================
echo  App should be running at:
echo    http://localhost:8080/word-memory-platform/login
echo  (MySQL service: %MYSQL_SERVICE%)
echo ==========================================================

:end
echo.
pause
