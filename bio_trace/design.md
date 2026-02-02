flowchart TD
%% ==========================================
%% STYLING
%% ==========================================
classDef app fill:#1e1e1e,stroke:#00e676,stroke-width:2px,color:#fff
classDef infra fill:#2d3436,stroke:#74b9ff,stroke-width:2px,color:#fff
classDef otel fill:#e17055,stroke:#fff,stroke-width:2px,color:#fff
classDef db fill:#636e72,stroke:#fff,stroke-width:1px,color:#fff
classDef ui fill:#0984e3,stroke:#fff,stroke-width:2px,color:#fff
classDef alert fill:#d63031,stroke:#fff,stroke-width:2px,color:#fff

    %% ==========================================
    %% 1. TELEMETRY GENERATION (THE SOURCES)
    %% ==========================================
    subgraph GEN [Telemetry Generation Layer]
        direction TB

        MOBILE(Mobile App <br/>Flutter SDK):::app
        BFF(BFF Service <br/>FastAPI):::app
        NEXUS(Bio-Nexus DAL <br/>FastAPI):::app
        AI_ENGINE(AI Vision Engine <br/>Python/GPU):::app

        DB_ATLAS(MongoDB Atlas <br/>System Metrics):::infra
        AWS_INFRA(AWS Lambda/ECS <br/>CloudWatch):::infra
    end

    %% ==========================================
    %% 2. COLLECTION LAYER (THE PIPELINE)
    %% ==========================================
    subgraph COL [OpenTelemetry Collector Service]
        direction TB
        OTEL_COL(<b>OTel Collector</b><br/>Receivers: OTLP/gRPC<br/>Processors: Batch, Sample, Redact):::otel
    end

    %% ==========================================
    %% 3. STORAGE LAYER (THE BACKENDS)
    %% ==========================================
    subgraph STORE [Observability Backends]
        direction TB

        LOKI[(<b>Loki</b><br/>Logs Storage<br/>Structured JSON)]:::db
        PROM[(<b>Prometheus/Mimir</b><br/>Metrics Storage<br/>Time-Series)]:::db
        TEMPO[(<b>Tempo</b><br/>Traces Storage<br/>Distributed Spans)]:::db
    end

    %% ==========================================
    %% 4. VISUALIZATION & ALERTING
    %% ==========================================
    subgraph VIS [Visualization & Action]
        direction TB

        GRAFANA(<b>Grafana Dashboards</b><br/>Unified View):::ui
        ALERT_MGR(<b>Alert Manager</b><br/>Rule Evaluation):::alert

        PAGER(PagerDuty <br/>Critical P1):::alert
        SLACK(Slack <br/>Warning P2):::alert
    end

    %% ==========================================
    %% DATA FLOW CONNECTIONS
    %% ==========================================

    %% 1. Trace Context Propagation (The "W3C Trace ID" flow)
    MOBILE -- "HTTP Header: traceparent" --> BFF
    BFF -- "HTTP Header: traceparent" --> NEXUS
    NEXUS -- "Internal Context" --> AI_ENGINE

    %% 2. Sending Telemetry to Collector (OTLP Protocol)
    MOBILE -- "Spans, Crashes, RUM" --> OTEL_COL
    BFF -- "RED Metrics, API Traces" --> OTEL_COL
    NEXUS -- "DB Query Spans, Custom Logs" --> OTEL_COL
    AI_ENGINE -- "GPU Stats, Model Drift, Latency" --> OTEL_COL
    DB_ATLAS -- "Disk IOPS, Connections" --> OTEL_COL
    AWS_INFRA -- "CPU, RAM, Network" --> OTEL_COL

    %% 3. Collector Processing to Backends
    OTEL_COL -- "Ship Logs" --> LOKI
    OTEL_COL -- "Ship Metrics" --> PROM
    OTEL_COL -- "Ship Traces" --> TEMPO

    %% 4. Visualization Reading from Backends
    GRAFANA <--> LOKI
    GRAFANA <--> PROM
    GRAFANA <--> TEMPO

    %% 5. Alerting Flow
    PROM -- "Trigger Rule (e.g., Latency > 2s)" --> ALERT_MGR
    LOKI -- "Trigger Rule (e.g., Error Rate > 5%)" --> ALERT_MGR

    ALERT_MGR -- "Wake Up Engineer" --> PAGER
    ALERT_MGR -- "Notify Channel" --> SLACK

    %% ==========================================
    %% DETAILED NOTES
    %% ==========================================
    note_traces[Trace Lifecycle:<br/>1. User Taps 'Scan'<br/>2. Mobile Gen ID: abc-123<br/>3. BFF adds Span: 'Auth'<br/>4. Nexus adds Span: 'Mongo Insert'<br/>5. AI adds Span: 'Inference']

    note_metrics[Key Metrics:<br/>- GPU_VRAM_Usage<br/>- API_Request_Rate_Per_Sec<br/>- P99_Latency_ms<br/>- Confidence_Score_Drift]

    note_traces -.- TEMPO
    note_metrics -.- PROM
