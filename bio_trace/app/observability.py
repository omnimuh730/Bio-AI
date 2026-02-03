import logging
import os
from pythonjsonlogger import jsonlogger
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from prometheus_client import Counter
from prometheus_client import make_asgi_app


class TraceIdFilter(logging.Filter):
    def filter(self, record):
        try:
            span = trace.get_current_span()
            ctx = span.get_span_context()
            trace_id = format(ctx.trace_id, '032x') if ctx and ctx.trace_id else None
        except Exception:
            trace_id = None
        record.trace_id = trace_id
        return True


def init_observability(app, otel_endpoint=None, metrics_path="/metrics"):
    """Initialise tracing, metrics and structured logging for a FastAPI app.

    - If `otel_endpoint` is provided, an OTLP exporter will be configured.
    - A Prometheus metrics ASGI app is mounted at `metrics_path`.
    - A JSON logger is configured and a TraceIdFilter adds trace_id to logs when available.
    """
    # Logging: JSON with trace id injection
    handler = logging.StreamHandler()
    fmt = jsonlogger.JsonFormatter('%(asctime)s %(levelname)s %(name)s %(message)s %(trace_id)s')
    handler.setFormatter(fmt)
    logger = logging.getLogger()
    logger.setLevel(os.getenv("LOG_LEVEL", "INFO"))
    # Avoid duplicate handlers when reloading during development
    if not any(isinstance(h, logging.StreamHandler) for h in logger.handlers):
        logger.addHandler(handler)
    logger.addFilter(TraceIdFilter())

    # Tracing (optional)
    if otel_endpoint:
        trace.set_tracer_provider(TracerProvider())
        exporter = OTLPSpanExporter(endpoint=otel_endpoint)
        span_processor = BatchSpanProcessor(exporter)
        trace.get_tracer_provider().add_span_processor(span_processor)

    # Instrument FastAPI
    try:
        FastAPIInstrumentor.instrument_app(app)
    except Exception:
        # If instrumentation fails, keep the app running without tracing
        logging.getLogger(__name__).warning("FastAPI instrumentation could not be applied")

    # Metrics
    app.state.requests_counter = Counter("bio_trace_requests_total", "Total requests")
    app.state.errors_counter = Counter("bio_trace_errors_total", "Total 5xx responses")
    metrics_app = make_asgi_app()
    app.mount(metrics_path, metrics_app)
