@echo off
:: Set working directory to the directory where this script is located
cd /d "%~dp0"

title PocketVerse Launcher
echo ===================================================
echo             PocketVerse Launcher
echo ===================================================
echo.

:: Check if Python is installed
where python >nul 2>nul
if %errorlevel% neq 0 (
    where py >nul 2>nul
    if %errorlevel% neq 0 (
        echo [ERROR] Python not found in PATH. Please install Python and try again.
        pause
        exit /b 1
    ) else (
        set PYTHON_CMD=py
    )
) else (
    set PYTHON_CMD=python
)

:: Check if Node is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Node.js not found in PATH. Please install Node.js and try again.
    pause
    exit /b 1
)

:: Check for backend .env
if not exist "backend\.env" (
    echo [INFO] backend\.env not found. Copying from .env.example...
    copy "backend\.env.example" "backend\.env"
    echo [WARNING] Please edit backend\.env to add your OPENAI_API_KEY.
)

:: Check for backend virtual environment
if not exist "backend\venv" (
    echo [INFO] Creating Python virtual environment in backend\venv...
    "%PYTHON_CMD%" -m venv backend\venv
    if errorlevel 1 (
        echo [ERROR] Failed to create Python virtual environment.
        pause
        exit /b 1
    )
    echo [INFO] Installing backend dependencies...
    "backend\venv\Scripts\pip" install -r backend\requirements.txt
    if errorlevel 1 (
        echo [ERROR] Failed to install backend dependencies.
        pause
        exit /b 1
    )
) else (
    echo [INFO] Backend virtual environment already exists.
)

:: Check for frontend node_modules
if not exist "frontend\node_modules" (
    echo [INFO] Installing frontend dependencies...
    cd frontend
    call npm install
    if errorlevel 1 (
        echo [ERROR] Failed to install frontend dependencies.
        cd ..
        pause
        exit /b 1
    )
    cd ..
) else (
    echo [INFO] Frontend node_modules already exists.
)

echo.
echo [INFO] Starting Backend on port 8000 in a new window...
start "PocketVerse Backend" cmd /k "cd backend && venv\Scripts\python -m uvicorn app.main:app --reload --port 8000"

echo [INFO] Starting Frontend on port 5173 in a new window...
start "PocketVerse Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo [INFO] Waiting for servers to initialize...
timeout /t 5 /nobreak >nul

echo [INFO] Opening PocketVerse in your default browser...
start http://localhost:5173

echo.
echo ===================================================
echo PocketVerse is running!
echo Backend: http://localhost:8000
echo Frontend: http://localhost:5173
echo ===================================================
echo Keep this window open or press any key to close.
pause
