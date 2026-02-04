# bio_nexus

Unified FastAPI microservice that provides data persistence, storage, and query capabilities for Bio AI. Uses MongoDB (Motor) as the primary datastore for time-series metrics, vision results, global food catalog, user profiles, and file metadata. Integrates S3-compatible storage for binary assets (images, depth maps).

**Merged Functionality:**

- **Data Storage:** Time-series metrics, food logs, user profiles, vision results
- **File Storage:** Direct-to-cloud uploads via presigned URLs, file archival, metadata tracking
- **Vector Search:** Semantic search over food embeddings and image vectors

Run locally (development)

- The `dev` environment uses mock data, local services, and hot-reload. Services communicate via `localhost`/internal docker network.
- Fill `.env` with MONGODB_URI, MONGO_DB_NAME, and S3 credentials (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, BUCKET_HOT, BUCKET_ARCHIVE)
- Start local stack (docker)

```bash
cd bio_nexus
docker-compose up --build
# service available at http://localhost:8000 (ENV=dev)
```

Run in Kubernetes (staging/prod)

- Create secret with your MongoDB connection string:

```bash
kubectl create secret generic mongo-secret --from-literal=uri='mongodb+srv://<user>:<pass>@cluster.mongodb.net/bio_nexus_db'
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/service.yaml
```

Or use Helm:

```bash
helm install bio-nexus ./helm -f ./helm/values.yaml --set image.repository=your-registry/bio-nexus --set env.MONGODB_URI='mongodb+srv://...'
```

Notes:

- For dev, `scripts/init_mongo.py` bootstraps collections & indexes.
- Use `ENV=dev|stage|prod` to change running mode.

APIs:

**Data & Metrics:**

- POST /api/v1/metrics/batch
- POST /api/v1/vision/result
- POST /api/v1/food_logs
- POST /api/v1/foods/search
- POST /api/v1/foods/lookup_barcode
- GET /api/v1/users/{id}

**Storage (merged from bio_storage):**

- POST /api/v1/storage/sign-upload — Generate presigned upload URL
- GET /api/v1/storage/files/{file_id} — Get file metadata
- GET /api/v1/storage/files/{file_id}/download-url — Get presigned download URL
- POST /api/v1/storage/files/{file_id}/archive — Archive file to cold storage
- POST /api/v1/storage/files — Direct upload (legacy)

Notes:

- Vector search in `/foods/search` includes a fallback naive in-memory cosine similarity for development if MongoDB Vector Search is not available.
