# bio_nexus

Lightweight FastAPI microservice that provides data persistence and query capabilities for Bio AI. Uses MongoDB (Motor) as the primary datastore for time-series metrics, vision results, global food catalog, and user profiles.

Run locally (development)

- The `dev` environment uses mock data, local services, and hot-reload. Services communicate via `localhost`/internal docker network.
- Fill `.env` with MONGODB_URI and MONGO_DB_NAME, or use `docker-compose` (recommended)
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

- POST /api/v1/metrics/batch
- POST /api/v1/vision/result
- POST /api/v1/food_logs
- POST /api/v1/foods/search
- POST /api/v1/foods/lookup_barcode
- GET /api/v1/users/{id}

Notes:

- Vector search in `/foods/search` includes a fallback naive in-memory cosine similarity for development if MongoDB Vector Search is not available.
