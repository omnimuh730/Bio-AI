import asyncio
import logging
from datetime import datetime, timezone, timedelta
from typing import Any
import boto3
from botocore.config import Config
from ..core.config import settings

logger = logging.getLogger("bio_worker.archive")


def _s3_client():
    # Use boto3 with explicit endpoint for MinIO in dev
    return boto3.client(
        "s3",
        endpoint_url=settings.s3_endpoint_url,
        aws_access_key_id=settings.s3_access_key,
        aws_secret_access_key=settings.s3_secret_key,
        region_name=settings.s3_region,
        config=Config(signature_version="s3v4"),
    )


async def archive_old_files(db):
    """Find files older than threshold and archive them to the archive bucket.
    - Copies object from hot bucket to archive prefix
    - Updates files_metadata: is_archived, archive_s3_key, archive_timestamp
    - Writes an entry to archive_log time-series collection
    - Deletes original object from hot bucket (optional; currently delete after successful copy)
    """
    s3 = _s3_client()
    threshold = datetime.now(timezone.utc) - timedelta(days=settings.archive_threshold_days)
    files_coll = db.get_collection("files_metadata")
    archive_log = db.get_collection("archive_log")

    cursor = files_coll.find({"upload_timestamp": {"$lte": threshold}, "is_archived": False})
    to_archive = await cursor.to_list(length=1000)
    if not to_archive:
        logger.info("No files to archive at this time")
        return {"archived": 0}

    archived_count = 0
    total_freed = 0
    archive_prefix = f"archive/{datetime.utcnow().strftime('%Y-%m-%d')}/"
    for f in to_archive:
        try:
            hot_key = f.get("s3_key")
            archive_key = archive_prefix + hot_key.split('/')[-1]
            # Copy
            s3.copy_object(Bucket=settings.s3_bucket_archive, CopySource={"Bucket": settings.s3_bucket_hot, "Key": hot_key}, Key=archive_key)
            # Delete original
            s3.delete_object(Bucket=settings.s3_bucket_hot, Key=hot_key)
            # Update metadata
            await files_coll.update_one({"_id": f["_id"]}, {"$set": {"is_archived": True, "archive_s3_key": archive_key, "archive_timestamp": datetime.utcnow()}})
            archived_count += 1
            total_freed += f.get("size_bytes", 0)
        except Exception as e:
            logger.exception("Failed to archive file %s: %s", f.get("_id"), e)

    # write archive log (time-series)
    await archive_log.insert_one({
        "timestamp": datetime.utcnow(),
        "metadata": {"operation": "archive"},
        "files_count": archived_count,
        "total_bytes_freed": total_freed,
        "s3_path_prefix": archive_prefix,
        "status": "success",
    })

    logger.info("Archived %d files, freed %d bytes", archived_count, total_freed)
    return {"archived": archived_count, "freed": total_freed}
