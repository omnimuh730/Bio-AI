@echo off
REM start_win.bat - Clean Windows installer and server runner for bio_ai_server
REM Usage: start_win.bat [nocache|ml-cuda]























































exit /b 0
necho --- END %DATE% %TIME% --- >> %LOGFILE% 2>&1python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 >> %LOGFILE% 2>&1
necho [start] Starting uvicorn server... >> %LOGFILE% 2>&1)  pip install opencv-python-headless >> %LOGFILE% 2>&1  echo [start] cv2 import failed; attempting opencv-python-headless >> %LOGFILE% 2>&1if errorlevel 1 (python -c "import importlib; importlib.import_module('cv2'); print('cv2 ok')" >> %LOGFILE% 2>&1
necho [start] Verifying cv2 import... >> %LOGFILE% 2>&1)  )    pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio >> %LOGFILE% 2>&1    echo [start] Installing CPU PyTorch wheels... >> %LOGFILE% 2>&1  ) else (    pip install --extra-index-url https://download.pytorch.org/whl/cu118 torch torchvision torchaudio >> %LOGFILE% 2>&1    echo [start] Installing CUDA PyTorch wheels... >> %LOGFILE% 2>&1  if /i "%1"=="ml-cuda" (  )    echo [start] requirements-ml.txt not found; skipping ML dependencies >> %LOGFILE% 2>&1  ) else (    )      echo [start] ML requirements returned errors; see %LOGFILE% >> %LOGFILE% 2>&1    if errorlevel 1 (    pip install -r requirements-ml.txt >> %LOGFILE% 2>&1    echo [start] Installing ML requirements... >> %LOGFILE% 2>&1  if exist requirements-ml.txt () else (  echo [start] Skipping ML deps (nocache) >> %LOGFILE% 2>&1
nif /i "%1"=="nocache" ()  exit /b 1  echo [start] Failed to install base requirements; check %LOGFILE% >> %LOGFILE% 2>&1if errorlevel 1 (pip install -r requirements.txt >> %LOGFILE% 2>&1
necho [start] Installing base requirements... >> %LOGFILE% 2>&1pip install --upgrade pip setuptools wheel >> %LOGFILE% 2>&1
necho [start] Upgrading pip... >> %LOGFILE% 2>&1)  exit /b 1  echo [start] Failed to activate venv. See %LOGFILE% >> %LOGFILE% 2>&1if errorlevel 1 (call .venv\Scripts\activate
n:: Activate)  )    exit /b 1    echo [start] Failed to create venv. See %LOGFILE% >> %LOGFILE% 2>&1  if errorlevel 1 (  python -m venv .venv >> %LOGFILE% 2>&1  echo [start] Creating .venv... >> %LOGFILE% 2>&1if not exist ".venv\Scripts\activate" (:: create venv if missingecho [start] Using venv .venv >> %LOGFILE% 2>&1nset LOGFILE=start_install.log
necho --- START %DATE% %TIME% --- > %LOGFILE%