import os
import logging
import json
import asyncio
from typing import Set
from fastapi import FastAPI, Request, BackgroundTasks
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import requests
from .observability import init_observability

app = FastAPI(title="bio_trace")

# Allow CORS for frontend development
origins = os.getenv("CORS_ORIGINS", "*")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[origins] if origins != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["*"],
)

# Initialize observability using environment variable (if present)
init_observability(app, otel_endpoint=os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT"))

# Simple in-memory client registry for Server-Sent Events
_clients: Set[asyncio.Queue] = set()


async def _sse_event_generator(queue: asyncio.Queue):
    try:
        while True:
            data = await queue.get()
            # SSE protocol: data: <json>\n\n
            yield f"data: {json.dumps(data)}\n\n"
    except asyncio.CancelledError:
        return


@app.get("/alerts/stream")
async def alerts_stream(request: Request):
    """SSE endpoint clients can connect to and receive alert payloads."""
    queue = asyncio.Queue()
    _clients.add(queue)

    async def generator():
        try:
            async for chunk in _sse_event_generator(queue):
                # If client disconnected, break
                if await request.is_disconnected():
                    break
                yield chunk.encode("utf-8")
        finally:
            try:
                _clients.discard(queue)
            except Exception:
                pass

    return StreamingResponse(generator(), media_type="text/event-stream")


@app.post("/alertmanager/webhook")
async def alertmanager_webhook(payload: dict, background_tasks: BackgroundTasks):
    """Receive Alertmanager webhook and broadcast to connected clients.

    Depending on the NOTIFICATION_MODE environment variable:
    - dev: only broadcast to the local clients
    - stage: broadcast + forward to mocked slack endpoint (STAGE_SLACK_URL)
    - prod: broadcast + forward to real Slack webhook (SLACK_WEBHOOK_URL)

    The endpoint returns 200 quickly and forwards Slack posts in background.
    """
    mode = os.getenv("NOTIFICATION_MODE", "dev")

    # Normalize payload to expected Alertmanager format
    alerts = payload.get("alerts") if isinstance(payload, dict) else None
    if alerts is None:
        # Accept arrays or nested structures too
        try:
            alerts = payload
        except Exception:
            alerts = []

    # Build a compact message for broadcasting
    messages = []
    for a in alerts:
        summary = a.get("annotations", {}).get("summary") or a.get("labels", {}).get("alertname")
        status = a.get("status") or payload.get("status") or "firing"
        msg = {
            "status": status,
            "summary": summary,
            "labels": a.get("labels", {}),
            "annotations": a.get("annotations", {}),
            "startsAt": a.get("startsAt"),
            "endsAt": a.get("endsAt")
        }
        messages.append(msg)

    # Broadcast to SSE clients
    for q in list(_clients):
        for m in messages:
            # put_nowait to avoid blocking
            try:
                q.put_nowait(m)
            except Exception:
                pass

    # Forward to Slack (background) if configured
    if mode in ("stage", "prod"):
        slack_url = os.getenv("SLACK_WEBHOOK_URL") if mode == "prod" else os.getenv("STAGE_SLACK_URL")
        if slack_url:
            background_tasks.add_task(_forward_to_slack, slack_url, messages)

    return JSONResponse({"status": "ok", "broadcasted": len(messages)})


def _forward_to_slack(webhook_url: str, messages: list):
    # Compose a simple Slack-compatible payload (text)
    for m in messages:
        text = f"[{m.get('status')}] {m.get('summary')} - labels={m.get('labels')}"
        try:
            r = requests.post(webhook_url, json={"text": text}, timeout=5)
            logging.getLogger(__name__).info("Slack forward: %s %s", r.status_code, r.text)
        except Exception as e:
            logging.getLogger(__name__).exception("Failed to forward to Slack: %s", e)


@app.get("/")
async def root():
    return {"status": "ok", "service": "bio_trace"}
