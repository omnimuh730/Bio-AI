from fastapi import APIRouter, UploadFile, File, HTTPException
from uuid import uuid4
from app.services.storage import upload_file, archive_file, get_file

router = APIRouter()

@router.post("/files", status_code=201)
async def upload(file: UploadFile = File(...)):
    """Upload a file to the hot bucket and create metadata."""
    file_id = str(uuid4())
    try:
        meta = await upload_file(file_id=file_id, file=file)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
    return meta

@router.post("/files/{file_id}/archive")
async def archive(file_id: str):
    res = await archive_file(file_id)
    if not res:
        raise HTTPException(status_code=404, detail="file not found or archive failed")
    return {"ok": True}

@router.get("/files/{file_id}")
async def get_file_endpoint(file_id: str):
    result = await get_file(file_id)
    if not result:
        raise HTTPException(status_code=404, detail="not found")
    return result
