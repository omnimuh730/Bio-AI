import uuid
from app.s3.client import s3_client
from app.models import get_files_collection
from app.schemas import FileMeta
from fastapi import UploadFile
import asyncio

async def upload_file(file_id: str, file: UploadFile) -> dict:
    key = f"{file_id}/{file.filename}"
    # ensure file at start
    file.file.seek(0)
    # upload to S3 hot bucket
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, s3_client.upload_fileobj, file.file, key, file.content_type)
    # write metadata to Mongo
    collection = get_files_collection()
    doc = {
        "_id": file_id,
        "filename": file.filename,
        "content_type": file.content_type,
        "key": key,
        "bucket": s3_client.hot_bucket,
        "archived": False,
    }
    await collection.insert_one(doc)
    return FileMeta(id=file_id, filename=file.filename, content_type=file.content_type, key=key, bucket=s3_client.hot_bucket).dict()

async def get_file(file_id: str) -> dict | None:
    collection = get_files_collection()
    doc = await collection.find_one({"_id": file_id})
    if not doc:
        return None
    doc["id"] = doc.pop("_id")
    return doc

async def archive_file(file_id: str) -> bool:
    collection = get_files_collection()
    doc = await collection.find_one({"_id": file_id})
    if not doc:
        return False
    key = doc["key"]
    # copy object to archive
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, s3_client.copy_to_archive, key)
    # delete hot object
    await loop.run_in_executor(None, s3_client.delete_object, s3_client.hot_bucket, key)
    await collection.update_one({"_id": file_id}, {"$set": {"archived": True}})
    return True