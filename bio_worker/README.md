# bio_worker

Background worker that consumes Redis Streams and performs async processing tasks for Bio AI.

Responsibilities:

- Consume health metric stream `ingest:health` and persist to MongoDB time-series collection.
- Run archival jobs (move to cold storage) and rehydration triggers (future work).

Quickstart (dev)

```bash
cd bio_worker
docker-compose up --build
# Worker will connect to local redis & mongo
```

Environment

- REDIS_URL (default: redis://redis:6379/0)
- MONGODB_URI (default: mongodb://mongo:27017)
- MONGO_DB_NAME

Testing

```bash
pip install -r requirements.txt
pytest -q
```
