from fastapi.testclient import TestClient
from bio_trace.app.main import app

client = TestClient(app)


def test_root():
    r = client.get("/")
    assert r.status_code == 200
    assert r.json().get("status") == "ok"


def test_metrics():
    # Hit root to increment the counter then check metrics
    client.get("/")
    r = client.get("/metrics")
    assert r.status_code == 200
    assert "bio_trace_requests_total" in r.text
    assert "bio_trace_errors_total" in r.text
