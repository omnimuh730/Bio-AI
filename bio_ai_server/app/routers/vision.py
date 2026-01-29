from fastapi import APIRouter, File, UploadFile, Form
from fastapi import HTTPException
import os
from ..config import UPLOAD_DIR
from threading import Thread
import subprocess
import shutil
import sys

router = APIRouter()

os.makedirs(UPLOAD_DIR, exist_ok=True)


def _run_detection_script(image_path: str):
    """Attempt to run the detection script in the server models folder, fallback to demos folder."""
    # Prefer server-local script if present
    server_script = os.path.join(os.path.dirname(__file__), '..', '..', 'detect_food.py')
    server_script = os.path.abspath(server_script)
    demo_script = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'demos', 'local-detection', 'detect_food.py'))

    script_to_run = None
    if os.path.exists(server_script):
        script_to_run = server_script
    elif os.path.exists(demo_script):
        script_to_run = demo_script

    if script_to_run is None:
        print("[vision] No detection script found (server or demos). Skipping processing.")
        return

    # Ensure models are available in server models dir if present - otherwise demos will use its own models
    try:
        cwd = os.path.dirname(script_to_run)
        print(f"[vision] Running detection script: {script_to_run} on image: {image_path}")
        proc = subprocess.run(
            [sys.executable, script_to_run, "--image", image_path],
            cwd=cwd,
            capture_output=True,
            text=True,
        )
        log_path = f"{image_path}.log"
        with open(log_path, "w", encoding="utf-8") as lf:
            lf.write("--- STDOUT ---\n")
            lf.write(proc.stdout or "")
            lf.write("\n--- STDERR ---\n")
            lf.write(proc.stderr or "")
        if proc.returncode != 0:
            print(f"[vision] Detection script failed (see log: {log_path})")
        else:
            print(f"[vision] Processing complete for: {image_path}")
    except subprocess.CalledProcessError as e:
        print(f"[vision] Detection script failed: {e}")
    except Exception as e:
        print(f"[vision] Error running detection: {e}")


@router.post("/upload")
async def upload_vision(file: UploadFile = File(...), pitch: float = Form(...)):
    """Handle image uploads for the vision pipeline. Saves file locally (stub) and triggers async processing."""
    try:
        out_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(out_path, "wb") as f:
            content = await file.read()
            f.write(content)

        # Trigger background processing
        t = Thread(target=_run_detection_script, args=(out_path,), daemon=True)
        t.start()

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    # In production: push S3, trigger lambda, etc.
    return {"status": "processing_started", "file": out_path}


@router.get("/health")
def vision_health():
    """Return basic health information about vision ML dependencies and model files."""
    deps = {}
    # Check Python imports
    try:
        import cv2  # noqa: F401
        deps['cv2'] = True
    except Exception:
        deps['cv2'] = False
    try:
        import torch  # noqa: F401
        deps['torch'] = True
    except Exception:
        deps['torch'] = False
    try:
        from ultralytics import SAM  # noqa: F401
        deps['ultralytics'] = True
    except Exception:
        deps['ultralytics'] = False

    # Check for model files in server models dir and demos
    server_models = os.path.join(os.path.dirname(__file__), '..', '..', 'models')
    demo_models = os.path.join(os.path.dirname(__file__), '..', '..', '..', 'demos', 'local-detection')
    found_models = []
    for d in (server_models, demo_models):
        if os.path.exists(d):
            for fn in os.listdir(d):
                if fn.lower().endswith('.pt'):
                    found_models.append(os.path.join(d, fn))

    return {
        'ok': True,
        'dependencies': deps,
        'models': found_models,
    }


@router.get('/logs')
def list_logs():
    """List recent log files (detection logs and installer log)."""
    logs = []
    # search uploads for .log (detection) and root for start_install.log
    uploads_dir = os.path.abspath(UPLOAD_DIR)
    if os.path.exists(uploads_dir):
        for fn in os.listdir(uploads_dir):
            if fn.lower().endswith('.log'):
                path = os.path.join(uploads_dir, fn)
                logs.append({'name': fn, 'path': path, 'mtime': os.path.getmtime(path)})
    # include installer log if present
    root_log = os.path.join(os.path.dirname(__file__), '..', '..', 'start_install.log')
    if os.path.exists(root_log):
        logs.append({'name': os.path.basename(root_log), 'path': root_log, 'mtime': os.path.getmtime(root_log)})

    # sort by mtime desc
    logs.sort(key=lambda x: x['mtime'], reverse=True)
    return {'logs': [{'name': l['name'], 'mtime': l['mtime']} for l in logs]}


from fastapi.responses import FileResponse, PlainTextResponse


@router.get('/logs/{name}')
def get_log(name: str):
    """Return the log file content if it exists (sanitized against path traversal)."""
    # Disallow path traversal
    if '..' in name or name.startswith('/') or name.startswith('\\'):
        raise HTTPException(status_code=400, detail='Invalid log name')

    candidates = []
    uploads_dir = os.path.abspath(UPLOAD_DIR)
    if os.path.exists(uploads_dir):
        for fn in os.listdir(uploads_dir):
            if fn == name:
                candidates.append(os.path.join(uploads_dir, fn))

    root_log = os.path.join(os.path.dirname(__file__), '..', '..', name)
    if os.path.exists(root_log):
        candidates.append(root_log)

    if not candidates:
        raise HTTPException(status_code=404, detail='Log not found')

    # choose the first candidate
    path = os.path.abspath(candidates[0])
    return FileResponse(path, media_type='text/plain', filename=name)
