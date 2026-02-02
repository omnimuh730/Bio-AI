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

Tests:

- `pytest` (integration tests use moto for S3 mock)
