@echo off
REM This is a batch script to help with local setup and testing on Windows

echo.
echo ===============================================
echo Wallet API - Windows Setup Helper
echo ===============================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not in PATH
    exit /b 1
)

REM Check if Maven is installed
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Maven is not installed or not in PATH
    exit /b 1
)

echo [OK] Docker found
echo [OK] Maven found

echo.
echo Building the application...
mvn clean package

if %errorlevel% neq 0 (
    echo [ERROR] Build failed
    exit /b 1
)

echo [OK] Build successful

echo.
echo Starting Docker containers...
docker-compose up -d

if %errorlevel% neq 0 (
    echo [ERROR] Failed to start containers
    exit /b 1
)

echo [OK] Containers started

echo.
echo Waiting for services to be ready (30 seconds)...
timeout /t 30 /nobreak

echo.
echo Testing API health...
curl http://localhost:8080/actuator/health

echo.
echo ===============================================
echo Setup complete! API is ready at http://localhost:8080
echo ===============================================
