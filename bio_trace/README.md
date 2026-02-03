# bio_trace

Minimal observability/monitoring starter service for the Bio AI project.

Features

- FastAPI service with OpenTelemetry (OTLP) support
- Prometheus metrics mounted at `/metrics`
- Structured JSON logs with trace_id included when available

Run locally

1. Install deps: `pip install -r requirements.txt`
2. Run: `uvicorn bio_trace.app.main:app --reload --port 8080`
3. Visit `http://localhost:8080/` and `http://localhost:8080/metrics`

Configuration

- `OTEL_EXPORTER_OTLP_ENDPOINT` - optional OTLP endpoint for traces
- `LOG_LEVEL` - log level (default INFO)

Tests

- `pytest -q`

Observability stack (local)

1. From the `bio_trace` directory run:

    ```bash
    docker-compose up --build -d
    ```

2. Local endpoints:
    - Grafana: http://localhost:3000 (admin/admin)
    - Prometheus: http://localhost:9090
    - Jaeger UI: http://localhost:16686
    - Loki API: http://localhost:3100

Notes:

- The compose stack includes an OpenTelemetry Collector that receives OTLP traces and logs from the app and forwards traces to Jaeger and logs to Loki. Prometheus scrapes `/metrics` from the `bio_trace` service.
- A sample Grafana dashboard is provisioned at startup (`bio_trace - Requests`).
- A sample Prometheus alert (`NoRequestsForBioTrace`) fires if no requests are detected for 10 minutes.
