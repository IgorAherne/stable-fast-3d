@echo off
setlocal enabledelayedexpansion

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This script is not running with administrator privileges.
    echo Environment variables will be set for the current user only.
    set "ADMIN_RIGHTS=0"
) else (
    echo Running with administrator privileges.
    set "ADMIN_RIGHTS=1"
)

:: Set paths relative to the batch file location
set "SF3D_DIR=%~dp0"
set "PROJ_ROOT=!SF3D_DIR!.."
set "SYSTEM_DIR=!PROJ_ROOT!\stable-diffusion-webui-forge\system"
set "GIT_DIR=!SYSTEM_DIR!\git\bin"
set "PYTHON_DIR=!SYSTEM_DIR!\python"

:: Set Python path explicitly
set "PYTHON=!PYTHON_DIR!\python.exe"
echo Attempting to use Python from: !PYTHON!

:: Check if Python exists in the specified directory
if exist "!PYTHON!" (
    :: Check if Python is already in PATH
    python --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo Adding Python to Environment Variables...
        if !ADMIN_RIGHTS! equ 1 (
            setx PATH "!PYTHON_DIR!;%PATH%" /M
        ) else (
            setx PATH "!PYTHON_DIR!;%PATH%"
        )
        if !errorlevel! neq 0 (
            echo Failed to add Python to Environment Variables.
        ) else (
            set "PATH=!PYTHON_DIR!;!PATH!"
            echo Python added to Environment Variables.
        )
    ) else (
        echo Python is already in Environment Variables.
    )
) else (
    echo Python executable not found at: !PYTHON!
    echo Falling back to system Python...
    set "PYTHON=python"
)

:: Verify Python can be executed
echo Verifying Python installation...
"!PYTHON!" --version
if !errorlevel! neq 0 (
    echo Failed to execute Python. Make sure it's installed and in your PATH.
    exit /b 1
)
echo Python verification complete.

:: Set Git path explicitly
set "GIT=!GIT_DIR!\git.exe"
echo Attempting to use Git from: !GIT!

:: Check if Git exists in the specified directory
if exist "!GIT!" (
    :: Check if Git is already in PATH
    git --version >nul 2>&1
    if !errorlevel! neq 0 (
        echo Adding Git to Environment Variables...
        if !ADMIN_RIGHTS! equ 1 (
            setx PATH "!GIT_DIR!;%PATH%" /M
        ) else (
            setx PATH "!GIT_DIR!;%PATH%"
        )
        if !errorlevel! neq 0 (
            echo Failed to add Git to Environment Variables.
        ) else (
            set "PATH=!GIT_DIR!;!PATH!"
            echo Git added to Environment Variables.
        )
    ) else (
        echo Git is already in Environment Variables.
    )
) else (
    echo Git executable not found at: !GIT!
    echo Falling back to system Git...
    set "GIT=git"
)

:: Verify Git can be executed
echo Verifying Git installation...
"!GIT!" --version
if !errorlevel! neq 0 (
    echo Failed to execute Git. Make sure it's installed and in your PATH.
    exit /b 1
)
echo Git verification complete.

echo Python and Git verification complete. Continuing with the rest of the script...

:: Install virtualenv
"!PYTHON!" -m pip install virtualenv

:: Change to the stable-fast-3d directory
echo Changing directory to: !SF3D_DIR!
cd /d "!SF3D_DIR!"

:: Create and activate virtual environment
if not exist "venv" (
    echo Creating virtual environment...
    "!PYTHON!" -m virtualenv venv
)
call venv\Scripts\activate.bat
if defined VIRTUAL_ENV (
    echo Virtual environment is activated: !VIRTUAL_ENV!
) else (
    echo Virtual environment is not activated
    exit /b 1
)

:: Update PYTHON to point to the virtual environment's Python
set "PYTHON=!SF3D_DIR!venv\Scripts\python.exe"

:: Upgrade pip in the virtual environment
echo Upgrading pip in the virtual environment...
"!PYTHON!" -m pip install --upgrade pip

:: Update setuptools
echo Updating setuptools...
"!PYTHON!" -m pip install -U setuptools==69.5.1

:: Install PyTorch
echo Installing PyTorch...
"!PYTHON!" -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124
if !errorlevel! neq 0 (
    echo PyTorch installation failed. Error code: !errorlevel!
    pause
    exit /b 1
)

:: Install other requirements
echo Installing other requirements...
"!PYTHON!" -m pip install -r requirements.txt
"!PYTHON!" -m pip install -U "huggingface_hub[cli]"


:: Create a file to indicate successful installation
echo Installation completed successfully > "install_finalized.txt"
echo.
echo Setup complete. You can now use Stable-Fast-3D.

pause
