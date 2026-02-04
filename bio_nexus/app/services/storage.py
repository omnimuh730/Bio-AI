import uuid
from app.s3.client import s3_client
from app.db.mongodb import get_db
from fastapi import UploadFile
import asyncio

async def generate_upload_credentials(filename: str, content_type: str, use_case: str) -> dict:
    """Generate presigned upload URL and create pending metadata entry."""
    file_id = str(uuid.uuid4())
    key = f"{use_case}/{file_id}/{filename}"
    
    # Generate presigned URL
    upload_url = s3_client.generate_presigned_upload_url(key, content_type, expires_in=300)
    
    # Create pending metadata entry
    db = await get_db()
    collection = db["files"]
    doc = {
        "_id": file_id,
        "filename": filename,
        "content_type": content_type,
        "key": key,
        "bucket": s3_client.hot_bucket,
        "archived": False,
        "status": "pending",
        "use_case": use_case,
    }
    await collection.insert_one(doc)
    
    return {
        "upload_url": upload_url,
        "file_id": file_id,
        "key": key
    }

async def upload_file(file_id: str, file: UploadFile) -> dict:
    """Direct upload to S3 via service (legacy)."""
    key = f"{file_id}/{file.filename}"
    # ensure file at start
    file.file.seek(0)
    # upload to S3 hot bucket
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, s3_client.upload_fileobj, file.file, key, file.content_type)
    # write metadata to Mongo
    db = await get_db()
    collection = db["files"]
    doc = {
        "_id": file_id,
        "filename": file.filename,
        "content_type": file.content_type,
        "key": key,
        "bucket": s3_client.hot_bucket,
        "archived": False,
        "status": "uploaded",
    }
    await collection.insert_one(doc)
    return {
        "id": file_id,
        "filename": file.filename,
        "content_type": file.content_type,
        "key": key,
        "bucket": s3_client.hot_bucket
    }

async def get_file(file_id: str) -> dict | None:
    """Get file metadata."""
    db = await get_db()
    collection = db["files"]
    doc = await collection.find_one({"_id": file_id})
    if not doc:
        return None
    doc["id"] = doc.pop("_id")
    return doc

async def generate_download_url(file_id: str) -> dict | None:
    """Generate a presigned download URL for a file."""
    db = await get_db()
    collection = db["files"]
    doc = await collection.find_one({"_id": file_id})
    if not doc:
        return None
    
    key = doc["key"]
    download_url = s3_client.generate_presigned_download_url(key, expires_in=3600)
    
    return {
        "file_id": file_id,
        "download_url": download_url,
        "filename": doc.get("filename"),
        "content_type": doc.get("content_type")
    }

async def archive_file(file_id: str) -> bool:
    """Move file from hot to archive bucket."""
    db = await get_db()
    collection = db["files"]
    doc = await collection.find_one({"_id": file_id})
    if not doc:
        return False
    key = doc["key"]
    # copy object to archive
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, s3_client.copy_to_archive, key)
    # delete hot object
    await loop.run_in_executor(None, s3_client.delete_object, s3_client.hot_bucket, key)
    await collection.update_one({"_id": file_id}, {"$set": {"archived": True, "bucket": s3_client.archive_bucket}})
    return True
