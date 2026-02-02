import io
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_upload_and_get_file(monkeypatch):
    # stub mongo collection with in-memory store so tests run without a running Mongo
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

    files = {"file": ("hello.txt", io.BytesIO(b"hello world"), "text/plain")}
    r = client.post("/api/v1/files", files=files)
    assert r.status_code == 201
    body = r.json()
    assert "id" in body
    file_id = body["id"]

    r2 = client.get(f"/api/v1/files/{file_id}")
    assert r2.status_code == 200
    body2 = r2.json()
    assert body2["id"] == file_id
    assert body2["filename"] == "hello.txt"
