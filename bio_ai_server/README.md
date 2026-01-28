# Bio AI BFF (FastAPI) - Starter

This is a small FastAPI BFF scaffold for the Bio AI project.

Run locally:

```bash
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

APIs available (stubs):

- `POST /sync/batch`
- `GET /dashboard/state`
- `POST /vision/upload`
- `GET /recommendation/current`
- `POST /recommendation/swap`
- `POST /log/food`
- `POST /leftovers/consume`

This scaffold uses SQLite + `sqlmodel` for local development. Replace with Postgres (asyncpg) for production.
