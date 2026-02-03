# bio_storage

Simple storage microservice for Bio AI.

Endpoints:

- POST /api/v1/files -> multipart upload (saves to hot S3 bucket and writes metadata to MongoDB)
- GET /api/v1/files/{file_id} -> returns metadata
- POST /api/v1/files/{file_id}/archive -> copy file from hot to archive bucket and mark archived

Run locally:

- Start Mongo and MinIO (or use local S3 compatible like MinIO)
- Fill `.env` from `.env.example`
- `uvicorn app.main:app --reload --host 0.0.0.0 --port 8080`

Run with Docker (recommended for local testing):

- Copy `.env.example` to `.env` and adjust any values if needed (access keys, bucket names).
- Start everything with Docker Compose:

```bash
docker compose up --build
```

- The API will be available at `http://localhost:8080` and MinIO Console at `http://localhost:9001`.

Notes:

- The compose file brings up `bio-storage`, `mongo`, and `minio` services. `bio-storage` reads configuration from the `.env` file (see `.env.example`).
- The service attempts to create the configured S3 buckets on startup (see `app.s3.client.S3Client.ensure_buckets()`).
- If you want to run the reconcile CLI once the stack is running:

```bash
docker compose run --rm bio-storage python -m app.cli --dry-run
```

Tests:

- `pytest` (integration tests use moto for S3 mock)
