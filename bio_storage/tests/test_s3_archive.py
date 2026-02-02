import io
import pytest
from moto import mock_s3
import boto3
from app.s3.client import s3_client
from app.services.storage import upload_file, archive_file, get_file
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

@mock_s3
def test_upload_and_archive(monkeypatch):
    # configure a real boto3 client to point to moto
    s3 = boto3.client('s3', region_name='us-east-1')
    # create buckets in moto
    s3.create_bucket(Bucket=s3_client.hot_bucket)
    s3.create_bucket(Bucket=s3_client.archive_bucket)

    # Monkeypatch an in-memory Mongo collection so we don't need a running Mongo for moto test
    class InMemoryCollection:
        def __init__(self):
            self.store = {}
        async def insert_one(self, doc):
            self.store[doc['_id']] = doc
            return None
        async def find_one(self, filter):
            return self.store.get(filter.get('_id'))
        async def update_one(self, filter, update):
            doc = self.store.get(filter.get('_id'))
            if doc and '$set' in update:
                doc.update(update['$set'])
            return None

    import app.models as models
    monkeypatch.setattr(models, 'get_files_collection', lambda: InMemoryCollection())

    files = {"file": ("pic.jpg", io.BytesIO(b"imagedata"), "image/jpeg")}
    r = client.post("/api/v1/files", files=files)
    assert r.status_code == 201
    body = r.json()
    file_id = body["id"]

    # Archive using the API
    r2 = client.post(f"/api/v1/files/{file_id}/archive")
    assert r2.status_code == 200
    # object should be in archive bucket now
    archived = s3.list_objects_v2(Bucket=s3_client.archive_bucket)
    keys = [o['Key'] for o in archived.get('Contents', [])]
    assert any(k.startswith(file_id) for k in keys)
