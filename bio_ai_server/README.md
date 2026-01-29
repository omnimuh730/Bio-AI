# Bio AI BFF (FastAPI) - Starter

This is a small FastAPI BFF scaffold for the Bio AI project.

Run locally:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

```
.venv\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Quick helper (Windows):

```powershell
# This batch creates/activates venv and installs requirements. Pass an optional mode:
#   start.bat           -> base requirements
#   start.bat ml        -> installs CPU ML deps (opencv, ultralytics, transformers, CPU torch)
#   start.bat ml-cuda   -> installs ML deps + CUDA PyTorch wheels (if you have CUDA drivers)
# If your start.bat is corrupted on Windows, use the safe fallback `start_fixed.bat` instead.
.
# Usage from repo root (bio_ai_server):
start.bat
start.bat ml
start.bat ml-cuda
# or, if start.bat fails:
start_fixed.bat
start_fixed.bat ml
start_fixed.bat ml-cuda
```

Optional: install heavy ML dependencies for the vision demo

If you want the server to run `detect_food.py` (the demo segmentation + analysis pipeline) you should install the extra ML dependencies and model weights. There are two helpers on Windows:

- `start_win.bat` — a simple, pure-batch installer + runner (recommended):

```powershell
# From repo root: bio_ai_server
# Install base + ML deps and start server
start_win.bat
# Install without ML deps (faster)
start_win.bat nocache
# Attempt CUDA PyTorch wheels
start_win.bat ml-cuda
```

- `scripts\setup_ml_env.ps1` — PowerShell script that installs the same deps (gives you more verbose logging and an option to request CUDA wheels):

```powershell
# From repo root: bio_ai_server
.\scripts\setup_ml_env.ps1        # installs CPU-only PyTorch by default
# or
.\scripts\setup_ml_env.ps1 -UseCuda  # attempt CUDA-enabled wheels (only if you have drivers/CUDA)
```

After the script finishes you can verify the environment with the health endpoint:

```bash
curl http://127.0.0.1:8000/api/vision/health
```

This returns a JSON object indicating whether `cv2`, `torch`, and `ultralytics` are importable and which model files were found on disk.

OpenAI integration

The detection pipeline can use OpenAI instead of the local Qwen model. To enable OpenAI, set `OPENAI_KEY` in your environment (we include an example in `.env.example`). The server will use the model `gpt-5-nano-2025-08-07` for cost-efficient Vision+NLP analysis if `OPENAI_KEY` is present.

If you prefer to keep running a local Qwen model, the legacy Qwen-based code is still present in the demos, but the server will prefer OpenAI when available.

Troubleshooting `cv2` import errors

If you see `ModuleNotFoundError: No module named 'cv2'` in the upload log, it means the OpenCV wheel was not installed into the active venv. Quick fixes:

- Activate the venv and install the wheel directly:

```powershell
.venv\Scripts\Activate.ps1
pip install --upgrade pip setuptools wheel
pip install opencv-python
# or for server-only environments (no GUI) you can use:
# pip install opencv-python-headless
```

- Or use the helper (installs recommended ML deps including OpenCV):

```powershell
start.bat ml
# or for CUDA-enabled PyTorch (if you have compatible GPU/drivers):
start.bat ml-cuda
```

If installation fails, copy the pip error output here and I’ll help diagnose the cause (missing wheel, network issue, or incompatible Python version).

APIs available (stubs):

- `POST /sync/batch`
- `GET /dashboard/state`
- `POST /vision/upload`
- `GET /recommendation/current`
- `POST /recommendation/swap`
- `POST /log/food`
- `POST /leftovers/consume`

This scaffold uses SQLite + `sqlmodel` for local development. Replace with Postgres (asyncpg) for production.
