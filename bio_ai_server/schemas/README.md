# Schema files

This folder contains canonical JSON schema + mock data for DB, frontend, backend, and API contracts.

## Canonical (use these)

- `db.json` — merged DB collections + mock data, including scalable `device_data` metrics.
- `frontend.json` — merged frontend component shapes + per-page fixtures (Dashboard/Planner/etc).
- `api.json` — merged API contract (endpoints, auth, errors, pagination, webhook + realtime notes).
- `backend.json` — backend design overview that maps modules to DB collections + API endpoints.

## Legacy / reference

These are kept for historical reference and are superseded by the canonical files above:

- `db_schema.json`
- `db_schema_expanded.json`
- `frontend_schema.json`
- `frontend_pages.json`
- `backend_api_schema.json`
- `backend_api_expanded.json`

## Notes

- Scalable wearable/health data: store any new metric as a new `device_data.metric` key with timeseries `dataPoints`.
- Frontend is organized by page unit in `frontend.json` (fixtures are designed for mock/dev).
