@echo off
REM start.bat - Create venv, install base + ML dependencies, and run the server.
REM Usage:
REM   start.bat           -> install base + ML deps (default) and run server
REM   start.bat nocache   -> install base deps only (faster)
REM   start.bat ml-cuda   -> install ML deps and attempt CUDA PyTorch wheels (if CUDA drivers present)

setlocal enabledelayedexpansion
set LOGFILE=start_install.log
echo [start] Log: %LOGFILE%
echo --- START %DATE% %TIME% --- > %LOGFILE%

:: Create or reuse virtualenv
if not exist ".venv\Scripts\activate" (
    echo [start] Creating virtual environment .venv... >> %LOGFILE% 2>&1
    python -m venv .venv >> %LOGFILE% 2>&1
    if errorlevel 1 (
        echo [start] Failed to create virtual environment. See %LOGFILE% for details.
        exit /b 1
    )
) else (
    echo [start] Using existing .venv >> %LOGFILE% 2>&1
)

:: Activate venv for this script session
call .venv\Scripts\activate
if errorlevel 1 (
    echo [start] Failed to activate virtual environment. Aborting. >> %LOGFILE% 2>&1
    exit /b 1
)





















































:: By default install ML deps (opencv etc.) unless user passed 'nocache'
if /i "%1"=="nocache" (
    echo [start] Skipping ML dependencies (nocache requested) >> %LOGFILE% 2>&1
) else (
    echo [start] Installing ML requirements from requirements-ml.txt... >> %LOGFILE% 2>&1
    if not exist requirements-ml.txt (
        echo [start] requirements-ml.txt missing. Skipping ML deps. >> %LOGFILE% 2>&1
    ) else (
        pip install -r requirements-ml.txt >> %LOGFILE% 2>&1
        if errorlevel 1 (
            echo [start] Warning: ML pip install reported errors; check %LOGFILE% for details. Continuing. >> %LOGFILE% 2>&1
        )
    )

    if /i "%1"=="ml-cuda" (
        echo [start] Installing CUDA PyTorch wheels... >> %LOGFILE% 2>&1
        pip install --extra-index-url https://download.pytorch.org/whl/cu118 torch torchvision torchaudio >> %LOGFILE% 2>&1
        if errorlevel 1 (
            echo [start] CUDA PyTorch install failed; try 'start.bat' (CPU) instead. >> %LOGFILE% 2>&1
        )
    ) else (
        echo [start] Installing CPU PyTorch wheels... >> %LOGFILE% 2>&1
        pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio >> %LOGFILE% 2>&1
        if errorlevel 1 (
            echo [start] CPU PyTorch install failed; you may install manually. See %LOGFILE%. >> %LOGFILE% 2>&1
        )
    )
)

:: Ensure OpenCV available as a fallback (try headless if normal fails)
echo [start] Verifying OpenCV import... >> %LOGFILE% 2>&1
python -c "import importlib, sys; importlib.import_module('cv2'); print('cv2 ok')" >> %LOGFILE% 2>&1
if errorlevel 1 (
    echo [start] cv2 import failed; installing opencv-python-headless fallback... >> %LOGFILE% 2>&1
    pip install opencv-python-headless >> %LOGFILE% 2>&1
)

echo [start] Setup complete. Starting server... >> %LOGFILE% 2>&1
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 >> %LOGFILE% 2>&1

echo --- END %DATE% %TIME% --- >> %LOGFILE% 2>&1
endlocal
exit /b 0