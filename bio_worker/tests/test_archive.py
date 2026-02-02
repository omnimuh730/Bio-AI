import pytest
from moto import mock_s3
import boto3
from datetime import datetime, timedelta
import asyncio

from app.services.archive_manager import archive_old_files

@pytest.mark.asyncio
@mock_s3
async def test_archive_old_files(monkeypatch):
    # Create mock s3
    s3 = boto3.client("s3", region_name="us-east-1")
    s3.create_bucket(Bucket="bio-ai-hot")
    s3.create_bucket(Bucket="bio-ai-archive")
    # Put a fake object
    s3.put_object(Bucket="bio-ai-hot", Key="hot/file1.jpg", Body=b"content")

    class FakeColl:
        def __init__(self, docs):
            self.docs = docs
        async def find(self, q):
            class C:
                def __init__(self, docs):
                    self.docs = docs
                async def to_list(self, length):
                    return self.docs
            return C(self.docs)
        async def update_one(self, q, u):
            return None

    class FakeDB:
        def get_collection(self, name):
            if name == "files_metadata":
                # file older than threshold
                doc = {"_id": "1", "s3_key": "hot/file1.jpg", "upload_timestamp": datetime.utcnow() - timedelta(days=40), "size_bytes": 100}
                return FakeColl([doc])
            if name == "archive_log":
                class L:
                    async def insert_one(self, doc):
                        return None
                return L()

    result = await archive_old_files(FakeDB())
    assert result["archived"] == 1