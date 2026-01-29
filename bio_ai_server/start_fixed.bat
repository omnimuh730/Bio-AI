@echo off
REM start_fixed.bat - Safe replacement for start.bat (use this if start.bat is corrupted)
REM Usage:
REM   start_fixed.bat           -> create venv & install base requirements
REM   start_fixed.bat ml        -> install base + ML deps (CPU PyTorch)
REM   start_fixed.bat ml-cuda   -> install base + ML deps + CUDA PyTorch (if CUDA drivers present)

setlocal enabledelayedexpansion

:: Create virtual environment if it does not exist
if not exist ".venv\Scripts\activate" (
    echo [start] Creating virtual environment .venv...
    python -m venv .venv
    if errorlevel 1 (
        echo [start] Failed to create virtual environment.
        exit /b 1
    )
) else (
    echo [start] Using existing .venv
)

:: Activate venv for this script session
call .venv\Scripts\activate
if errorlevel 1 (
    echo [start] Failed to activate virtual environment. Aborting.
    exit /b 1
)





















































exit /b 0
nendlocalecho     python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000echo [start] Setup finished. Activate the venv with: .venv\Scripts\activate and run the server:
n:done
necho [start] Base setup complete (no ML deps installed).)    goto :done    echo [start] ML CUDA install complete.    )        exit /b 1        echo [start] Failed to install CUDA PyTorch wheels.    if errorlevel 1 (    pip install --extra-index-url https://download.pytorch.org/whl/cu118 torch torchvision torchaudio    )        exit /b 1        echo [start] Failed to install core ML deps from requirements-ml.txt.    if errorlevel 1 (    pip install -r requirements-ml.txt    )        exit /b 1        echo [start] requirements-ml.txt not found; aborting.    if not exist requirements-ml.txt (    echo [start] Installing ML dependencies (CUDA PyTorch) - ensure CUDA drivers are installed on this machine.
nif /i "%1"=="ml-cuda" ()    goto :done    echo [start] ML CPU install complete.    )        exit /b 1        echo [start] Failed to install CPU PyTorch wheels.    if errorlevel 1 (    pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio    )        exit /b 1        echo [start] Failed to install core ML deps from requirements-ml.txt.    if errorlevel 1 (    pip install -r requirements-ml.txt    )        exit /b 1        echo [start] requirements-ml.txt not found; aborting.    if not exist requirements-ml.txt (    echo [start] Installing ML dependencies (CPU PyTorch) - this may take a while...if /i "%1"=="ml" (
n:: Handle optional ML installation modes)    exit /b 1    echo [start] Failed to install base requirements.if errorlevel 1 (pip install -r requirements.txt
necho [start] Installing base requirements from requirements.txt...pip install --upgrade pip setuptools wheelnecho [start] Upgrading pip, setuptools and wheel...