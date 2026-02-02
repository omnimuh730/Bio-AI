classDiagram
direction TB

    %% ==========================================
    %% 1. ENTRY POINTS & SECURITY
    %% ==========================================
    namespace Entry_Layer {
        class API_Gateway {
            <<FastAPI App>>
            +Middleware_CORS()
            +Middleware_GZip()
            +Middleware_OTel_Tracing()
        }

        class Auth_Guard {
            <<Middleware>>
            -Public_Key_Cache
            +validate_jwt(token)
            +extract_user_context()
        }
    }

    %% ==========================================
    %% 2. AGGREGATION LOGIC (THE "GLUE")
    %% ==========================================
    namespace Orchestration_Layer {
        class Dashboard_Aggregator {
            <<Service>>
            +get_home_screen_data()
            %% Fetches Profile + Food Logs + Health Metrics + Daily Plan
            %% Merges into single JSON response
        }

        class Vision_Orchestrator {
            <<Service>>
            +handle_image_upload()
            %% Uploads to S3 -> Triggers Inference -> Returns "Processing" status
        }

        class Health_Sync_Manager {
            <<Service>>
            +process_batch_metrics()
            %% Validates data -> Pushes to Worker Queue -> Updates Cache
        }
    }

    %% ==========================================
    %% 3. INFRASTRUCTURE ADAPTERS (OUTBOUND)
    %% ==========================================
    namespace Adapters {
        class Nexus_Client {
            <<gRPC / HTTP>>
            +get_user_profile()
            +get_food_logs_today()
            +upsert_health_metrics()
        }

        class Inference_Client {
            <<Async HTTP>>
            +request_meal_recommendation()
            +get_vision_result()
        }

        class Worker_Producer {
            <<Redis Streams / SQS>>
            +enqueue_job("calc_energy_score")
            +enqueue_job("normalize_health_data")
        }

        class Cache_Manager {
            <<Redis Client>>
            +get_dashboard_json(user_id)
            +set_dashboard_json(user_id, data, ttl=300s)
        }
    }

    %% ==========================================
    %% 4. EXTERNAL DEPENDENCIES (FROM MONOREPO)
    %% ==========================================
    class Bio_Auth {
        <<Service>>
        +JWKS_Endpoint
    }

    class Bio_Nexus {
        <<Service>>
        +Database (Postgres)
    }

    class Bio_Inference {
        <<Service>>
        +GPU_Cluster
    }

    class Bio_Worker {
        <<Service>>
        +Background_Jobs
    }

    class Redis_Cache {
        <<Infrastructure>>
        +Hot Data
    }

    %% ==========================================
    %% 5. DATA FLOW & RELATIONSHIPS
    %% ==========================================

    %% Entry
    API_Gateway --> Auth_Guard : 1. Verify Request
    Auth_Guard ..> Bio_Auth : Fetches Public Key (Once/Hour)
    API_Gateway --> Dashboard_Aggregator : 2. Route Request
    API_Gateway --> Vision_Orchestrator : 2. Route Request
    API_Gateway --> Health_Sync_Manager : 2. Route Request

    %% Aggregation Flows
    Dashboard_Aggregator --> Cache_Manager : Check Redis First
    Dashboard_Aggregator --> Nexus_Client : If Miss then Fetch Data
    Dashboard_Aggregator --> Inference_Client : If Miss then Get Plan

    %% Vision Flow
    Vision_Orchestrator --> Bio_Inference : Triggers GPU Task
    Vision_Orchestrator --> Worker_Producer : Queues "Post-Process"

    %% Write Flow (Optimization)
    Health_Sync_Manager --> Worker_Producer : Offload Heavy Writes
    Health_Sync_Manager --> Cache_Manager : Update UI State Immediately

    %% Infrastructure Connections
    Adapters --> Redis_Cache : Read/Write
    Adapters --> Bio_Nexus : CRUD Operations
    Adapters --> Bio_Worker : Async Tasks

    %% Notes
    note for Dashboard_Aggregator - Aggregator Pattern:<br>1 Mobile Request = 1 BFF Response.<br>Prevents 'Chatty' Mobile Apps."
    note for Worker_Producer "Write-Behind Pattern:<br>Health data is acknowledged immediately,<br>but processed asynchronously to save battery."
    note for Auth_Guard "Stateless Verification:<br>Verifies RS256 Signature locally.<br>No network call to Bio_Auth."
