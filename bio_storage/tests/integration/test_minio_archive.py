import io
import pytest
import boto3
from fastapi.testclient import TestClient
from app.main import app
from app.s3.client import s3_client

client = TestClient(app)

def create_minio_buckets():
    s3 = boto3.client('s3', endpoint_url='http://127.0.0.1:9000', aws_access_key_id='minioadmin', aws_secret_access_key='minioadmin', region_name='us-east-1')
    try:
        s3.create_bucket(Bucket=s3_client.hot_bucket)
    except Exception:
        pass
    try:
        s3.create_bucket(Bucket=s3_client.archive_bucket)
    except Exception:
        pass

@pytest.mark.integration
def test_upload_and_archive_minio():
    # Ensure buckets exist on MinIO
    create_minio_buckets()

    files = {"file": ("pic.jpg", io.BytesIO(b"imagedata"), "image/jpeg")}
    r = client.post("/api/v1/files", files=files)
    assert r.status_code == 201
    body = r.json()
    file_id = body["id"]

    # Archive using the API
    r2 = client.post(f"/api/v1/files/{file_id}/archive")
    assert r2.status_code == 200

    # object should be in archive bucket now
    s3 = boto3.client('s3', endpoint_url='http://127.0.0.1:9000', aws_access_key_id='minioadmin', aws_secret_access_key='minioadmin', region_name='us-east-1')
    archived = s3.list_objects_v2(Bucket=s3_client.archive_bucket)
    keys = [o['Key'] for o in archived.get('Contents', [])]
    assert any(k.startswith(file_id) for k in keys)

    # verify metadata archived in Mongo (via API)
    r3 = client.get(f"/api/v1/files/{file_id}")
    assert r3.status_code == 200
    assert r3.json().get('archived') is True
