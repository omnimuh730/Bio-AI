# Bio AI BFF (FastAPI) - Starter

This is a small FastAPI BFF scaffold for the Bio AI project.

Run locally:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Run with Docker (recommended for local testing):

- Copy `.env.example` to `.env` and adjust values as needed (e.g., `FATSECRET_CLIENT_ID`, `FATSECRET_CLIENT_SECRET`).

Dev (fast feedback, code mounts):

```bash
# Copy `.env.example` -> `.env` and set ENV=dev
# Then run with the dev profile to mount code and enable hot reload:
# POSIX
COMPOSE_PROFILES=dev docker compose up --build
# PowerShell
$Env:COMPOSE_PROFILES='dev'; docker compose up --build
```

Stage / Production (detached):

```bash
# staging
cp .env.stage .env    # or set ENV=stage in .env
docker compose up --build -d

# production
cp .env.prod .env     # or set ENV=prod in .env
docker compose up --build -d
```

The `dev` profile mounts your repository and runs `uvicorn` with `--reload`. For stage/prod, use the detached mode; ensure your `.env` is configured with production-ready MongoDB and secrets.

Staging / Production (single compose):

```bash
# staging
cp .env.stage .env    # or set ENV=stage in .env
docker compose up --build -d

# production
cp .env.prod .env     # or set ENV=prod in .env
docker compose up --build -d
```

Use the `COMPOSE_PROFILES=dev` environment variable for dev-only mounts (hot reload).

- The API will be available at `http://localhost:8000`.

Notes:

- `.env.dev`, `.env.stage`, and `.env.prod` are included as templates. **Do not** commit secrets — use your deployment platform's secret management for production.
- We recommend running **MongoDB 8.2.4** (or 8.0.0 if you need compatibility with older clusters). Configure `MONGODB_URI` to point at the team's MongoDB service (e.g. `bio_nexus`).
- This service integrates with other Bio AI services in the monorepo for a local full-stack development experience. Recommended local stack to bring up with Docker Compose:
    - `bio_storage` (S3/MinIO) — for file uploads and object lifecycle
    - `bio_nexus` (Mongo) — central data persistence (if you prefer using the project's central DB instead of the local one)
    - `bio_worker` / `bio_inference` — optional for processing/ML jobs

- In dev the app mounts your repository (hot-reload via uvicorn --reload). In stage/prod the service uses MongoDB and reads `.env.stage`/`.env.prod`.
- For production, ensure you replace the example DB credentials and configure backups, networking, and secret management.

```
.venv\Scripts\Activate.ps1; python -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Docker-first workflow (recommended):

This repository is Docker-first — use `docker compose` for running dev, stage, and production stacks. Copy `.env.example` → `.env` and set `ENV=dev|stage|prod`, then run:

```bash
# Development (hot reload, mounts code)
COMPOSE_PROFILES=dev docker compose up --build

# Stage / Production (detached)
docker compose up --build -d
```

## Build & run with Docker 🔧

Quick commands to build and run the service and full stacks.

- Build the Docker images (reads `docker-compose.yml`):

```bash
docker compose build
```

- Start the stack (dev profile mounts code for hot reload):

```bash
# Dev (hot reload)
COMPOSE_PROFILES=dev docker compose up --build

# Run detached (stage/prod)
docker compose up --build -d
```

- Rebuild an individual service image and restart only that service:

```bash
# Rebuild the app image and restart the service
docker compose build bio-ai-server && docker compose up -d bio-ai-server
```

- Run a multi-service full stack (example with `bio_storage` and `bio_nexus` in the monorepo):

```bash
# from the repo root (where other services live)
# bring up the server plus storage + nexus services for full-stack testing
docker compose -f docker-compose.yml -f ../bio_storage/docker-compose.yml -f ../bio_nexus/docker-compose.yml up --build
```

- Run one-off commands against the container (eg. run the CLI):

```bash
# Run a CLI inside the built image
docker compose run --rm bio-ai-server python -m app.cli --dry-run
```

---

These commands assume you have Docker and Docker Compose installed. If you need a one-liner for Windows PowerShell, set `COMPOSE_PROFILES` like this:

```powershell
$Env:COMPOSE_PROFILES='dev'; docker compose up --build
```

Optional: heavy ML dependencies for the vision demo

If you want to run `detect_food.py` locally outside Docker, there is a helper PowerShell script `scripts/setup_ml_env.ps1` that installs the necessary ML deps and model weights. However, we recommend running the ML-enabled pipeline inside a Docker image designed for ML workloads instead of using local batch helpers.

After the script finishes you can verify the environment with the health endpoint:

```bash
curl http://127.0.0.1:8000/api/vision/health
```

This returns a JSON object indicating whether `cv2`, `torch`, and `ultralytics` are importable and which model files were found on disk.

OpenAI integration

The detection pipeline can use OpenAI instead of the local Qwen model. To enable OpenAI, set `OPENAI_KEY` in your environment (we include an example in `.env.example`). The server will use the model `gpt-5-nano-2025-08-07` for cost-efficient Vision+NLP analysis if `OPENAI_KEY` is present.

If you prefer to keep running a local Qwen model, the legacy Qwen-based code is still present in the demos, but the server will prefer OpenAI when available.

Troubleshooting `cv2` import errors

If you see `ModuleNotFoundError: No module named 'cv2'` in the upload log, it means the OpenCV wheel was not installed into the active venv. Quick fixes:

- Activate the venv and install the wheel directly:

```powershell
.venv\Scripts\Activate.ps1
pip install --upgrade pip setuptools wheel
pip install opencv-python
# or for server-only environments (no GUI) you can use:
# pip install opencv-python-headless
```

- Or use the helper (installs recommended ML deps including OpenCV):

```powershell
start.bat ml
# or for CUDA-enabled PyTorch (if you have compatible GPU/drivers):
start.bat ml-cuda
```

If installation fails, copy the pip error output here and I’ll help diagnose the cause (missing wheel, network issue, or incompatible Python version).

APIs available (stubs):

- `POST /sync/batch`
- `GET /dashboard/state`
- `POST /vision/upload`
- `GET /recommendation/current`
- `POST /recommendation/swap`
- `POST /log/food`
- `POST /leftovers/consume`

This scaffold uses MongoDB for storage. The `bio_ai_server` service does **not** run its own MongoDB instance; instead it expects `MONGODB_URI` to point to the desired database (for example your central `bio_nexus` service or a managed cluster).

- To change the database endpoint, set `MONGODB_URI` and `MONGO_DB_NAME` in your `.env` or environment.
- For local full-stack testing, bring up `bio_nexus` (or `bio_storage` if you need an included Mongo) alongside this service using `docker compose -f ...` as shown above.
- For production, provide a managed MongoDB connection string and secure credentials via your platform's secret manager.
