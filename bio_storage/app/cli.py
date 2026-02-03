import argparse
import asyncio
from datetime import datetime, timedelta
from app.models import get_files_collection
from app.s3.client import s3_client
from app.core.config import settings

async def reconcile(dry_run: bool = False):
    collection = get_files_collection()
    # find files that are older than archive_threshold_days
    cutoff = datetime.utcnow() - timedelta(days=settings.archive_threshold_days)
    cursor = collection.find({"archived": False})
    count = 0
    async for doc in cursor:
        # naive approach: if object exists in hot and old, archive it
        # For demo, we don't store created_at; assume TTL based on key parse (not ideal)
        # We'll archive all unarchived objects when running reconcile in this prototype
        key = doc.get("key")
        file_id = doc.get("_id")
        if not key:
            continue
        count += 1
        if dry_run:
            print(f"Would archive {file_id} ({key})")
            continue
        try:
            s3_client.copy_to_archive(key)
            s3_client.delete_object(s3_client.hot_bucket, key)
            await collection.update_one({"_id": file_id}, {"$set": {"archived": True}})
            print(f"Archived {file_id}")
        except Exception as exc:
            print(f"Failed to archive {file_id}: {exc}")
    print(f"Reconcile scanned {count} files")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    asyncio.run(reconcile(dry_run=args.dry_run))