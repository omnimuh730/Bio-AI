from fastapi import APIRouter, File, UploadFile, Form
from fastapi import HTTPException
import os
from ..config import UPLOAD_DIR

router = APIRouter()

os.makedirs(UPLOAD_DIR, exist_ok=True)


@router.post("/upload")
async def upload_vision(file: UploadFile = File(...), pitch: float = Form(...)):
    """Handle image uploads for the vision pipeline. Saves file locally (stub)."""
    try:
        out_path = os.path.join(UPLOAD_DIR, file.filename)
        with open(out_path, "wb") as f:
            content = await file.read()
            f.write(content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    # In production: push S3, trigger lambda, etc.
    return {"status": "pending_confirmation", "file": out_path}
