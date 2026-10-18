@echo off
REM ==============================================================================
REM NanoGPT Workshop - Environment Setup (Windows)
REM Minimal CPU-only setup using NumPy and PyTorch (Python 3.13)
REM ==============================================================================
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo === [1/4] Detecting Python 3.13 ===
set USE_UV=0
where uv >nul 2>&1
if %ERRORLEVEL% equ 0 (
    set USE_UV=1
    for /f "tokens=*" %%i in ('uv --version') do echo [+] Found uv: %%i
) else (
    echo [!] uv not found. Falling back to standard python / pip tooling.
)

set PYTHON_CMD=
where py >nul 2>&1
if %ERRORLEVEL% equ 0 (
    py -3.13 -c "import sys; sys.exit(0)" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        set PYTHON_CMD=py -3.13
    )
)

if "!PYTHON_CMD!"=="" (
    where python >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        python -c "import sys; sys.exit(0 if sys.version_info[:2] == (3, 13) else 1)" >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            set PYTHON_CMD=python
        )
    )
)

if not "!PYTHON_CMD!"=="" (
    for /f "tokens=*" %%i in ('!PYTHON_CMD! --version') do echo [+] Detected local Python: %%i
)

echo === [2/4] Creating Virtual Environment (.venv) ===
if %USE_UV% equ 1 (
    echo [+] Creating virtual environment with uv for Python 3.13...
    if not "!PYTHON_CMD!"=="" (
        uv venv --python "!PYTHON_CMD!" .venv
    ) else (
        uv venv --python 3.13 .venv
    )
    if %ERRORLEVEL% neq 0 (
        echo [-] Failed to create .venv with uv.
        exit /b 1
    )
) else (
    if "!PYTHON_CMD!"=="" (
        echo [-] Error: Python 3.13 is required but neither 'python (3.13)' nor 'uv' was found.
        echo     Please install Python 3.13 or uv (https://docs.astral.sh/uv/).
        exit /b 1
    )
    echo [+] Creating virtual environment using !PYTHON_CMD! -m venv .venv...
    !PYTHON_CMD! -m venv .venv
    if %ERRORLEVEL% neq 0 (
        echo [-] Failed to create .venv.
        exit /b 1
    )
)

echo === [3/4] Activating Virtual Environment ===
call .venv\Scripts\activate.bat
if %ERRORLEVEL% neq 0 (
    echo [-] Failed to activate virtual environment.
    exit /b 1
)

for /f "tokens=*" %%i in ('python --version') do echo [+] Active Python: %%i

echo === [4/4] Installing CPU Dependencies ===
echo [+] Installing from requirements.txt for Windows...
if %USE_UV% equ 1 (
    uv pip install -r requirements.txt
) else (
    python -m pip install --upgrade pip
    python -m pip install -r requirements.txt
)
if %ERRORLEVEL% neq 0 (
    echo [-] Installation failed.
    exit /b 1
)

echo.
echo === Environment Setup Completed Successfully! ===
echo To activate manually in your terminal, run:
echo     .venv\Scripts\activate.bat
