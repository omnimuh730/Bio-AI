from fastapi import APIRouter, UploadFile, File, HTTPException
from uuid import uuid4
from app.services.storage import upload_file, archive_file, get_file, generate_upload_credentials
from pydantic import BaseModel

router = APIRouter()

class PresignedUploadRequest(BaseModel):
    filename: str
    content_type: str
    use_case: str = "vision_scan"

class PresignedUploadResponse(BaseModel):
    upload_url: str
    file_id: str
    key: str

@router.post("/storage/sign-upload", response_model=PresignedUploadResponse)
async def generate_upload_url(request: PresignedUploadRequest):
    """Generate a presigned URL for direct client upload to S3."""
    try:
        result = await generate_upload_credentials(
            filename=request.filename,
            content_type=request.content_type,
            use_case=request.use_case
        )
        return result
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))

@router.post("/storage/files", status_code=201)
async def upload(file: UploadFile = File(...)):
    """Upload a file to the hot bucket and create metadata (legacy endpoint)."""
    file_id = str(uuid4())
    try:
        meta = await upload_file(file_id=file_id, file=file)
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))
    return meta

@router.post("/storage/files/{file_id}/archive")
async def archive(file_id: str):
    """Archive a file from hot to cold storage."""
    res = await archive_file(file_id)
    if not res:
        raise HTTPException(status_code=404, detail="file not found or archive failed")
    return {"ok": True}

@router.get("/storage/files/{file_id}")
async def get_file_endpoint(file_id: str):
    """Get file metadata and download URL."""
    result = await get_file(file_id)
    if not result:
        raise HTTPException(status_code=404, detail="not found")
    return result

@router.get("/storage/files/{file_id}/download-url")
async def get_download_url(file_id: str):
    """Get a presigned download URL for a file."""
    from app.services.storage import generate_download_url
    result = await generate_download_url(file_id)
    if not result:
        raise HTTPException(status_code=404, detail="file not found")
    return result
