# Bio AI (Bio AI) – Copilot coding instructions

## Repo layout (monorepo)

- `bio_ai/`: Flutter mobile UI prototype (currently mock-data driven).
- `bio_ai_server/`: FastAPI “BFF” backend scaffold (SQLite dev DB).
- `demos/`: local CV experiments (not part of app runtime).

## Day-to-day workflows

### Flutter app (`bio_ai/`)

- Install deps: `flutter pub get`
- Run: `flutter run` (pick a device)
- Quality gates: `flutter test`, `flutter analyze`

### Backend (`bio_ai_server/`)

- Create env + install: `python -m venv .venv` → `.venv\Scripts\activate` → `pip install -r requirements.txt`
- Run dev server: `uvicorn app.main:app --reload --host 0.0.0.0 --port 8000`
- Base API prefix is `/api` (e.g. `GET /api/dashboard/state`).

## Backend architecture & conventions (FastAPI)

- App entry: `bio_ai_server/app/main.py` (startup calls `init_db()`; router mounted at `/api`).
- Routing: add endpoints under `bio_ai_server/app/routers/` and wire them in `bio_ai_server/app/routers/__init__.py`.
- Request/response schemas live in `bio_ai_server/app/schemas.py` (Pydantic v2 models).
- Persistence uses synchronous SQLAlchemy:
    - Engine/session in `bio_ai_server/app/database.py` (`get_session()` dependency).
    - ORM tables in `bio_ai_server/app/models.py`; tables are created via `Base.metadata.create_all()` on startup.
- Config is env-var driven in `bio_ai_server/app/config.py`:
    - `DATABASE_URL` (defaults to `sqlite:///.../bio_ai_server.db`)
    - `UPLOAD_DIR` (defaults to `.../uploads`)
    - `DEBUG`
- Note: “food log” and “leftovers consume” endpoints currently live under the `pantry` router (`POST /api/pantry/log`, `POST /api/pantry/leftovers/consume`).

## Flutter UI conventions

- Entry point: `bio_ai/lib/main.dart` → `DashboardScreen`.
- UI follows an atomic-ish structure: `bio_ai/lib/ui/{atoms,molecules,organisms,pages}`.
- Prototype data comes from `bio_ai/lib/data/mock_data.dart`; many widgets expect `Map<String, dynamic>` meal shapes.
- Shared styling constants live in `bio_ai/lib/core/constants/` (e.g., `AppColors`).

## Contracts & specs

- Canonical JSON contracts + fixtures are in `bio_ai_server/schemas/` (`api.json`, `frontend.json`, `backend.json`, `db.json`).
- Product/architecture docs are in `bio_ai/specs/` (helpful for intent; code may still be stubbed).

## Editing/formatting guardrails

- Don’t hand-edit generated folders (Flutter `build/`, iOS `ios/Flutter/ephemeral/`, etc.).
- For Dart, prefer `dart format`/`flutter format` output (don’t convert Dart files to tabs even if `.editorconfig` uses tabs).
