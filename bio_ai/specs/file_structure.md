lib/
├── app/ # App entry & composition root (wires DI, router, theme)
│ ├── app.dart # Root widget (MaterialApp.router, theme, localization)
│ ├── bootstrap.dart # Init sequence (Hive init, error handling, flavors)
│ ├── di/ # Dependency Injection (Riverpod providers or get_it)
│ │ └── injectors.dart # Registers repos, usecases, sensors (scoped per feature)
│ └── router/ # GoRouter config + auth/onboarding guards
│ └── app_router.dart
│
├── core/ # Shared across features (no feature-specific code)
│ ├── constants/ # app_colors.dart, strings.dart, api_endpoints.dart
│ ├── errors/ # exceptions.dart, failures.dart
│ ├── network/ # api_client.dart (Dio + interceptors), connectivity.dart
│ ├── platform_services/ # Hardware/sensor abstractions (small files for efficiency)
│ │ ├── sensors/ # gyro_service.dart (sensors_plus for pitch/angle)
│ │ ├── location/ # gps_service.dart (geolocator for restaurant geo-fence)
│ │ ├── bluetooth/ # ble_service.dart (flutter_blue_plus for wearables)
│ │ ├── flashlight/ # torch_service.dart (torch_light for camera flash)
│ │ └── device/ # device_info.dart (biometrics, platform channels)
│ ├── security/ # auth_token_handler.dart, biometric_auth.dart
│ ├── theme/ # app_theme.dart, text_styles.dart (design system tokens)
│ ├── utils/ # formatters.dart, validators.dart, logger.dart, extensions.dart
│ ├── widgets/ # Shared UI: app_button.dart, loading_overlay.dart, error_view.dart
│ └── local_storage/ # hive_adapters.dart, local_db.dart (Hive for offline data)
│
├── features/ # Feature modules (one per bounded context; scalable & isolated)
│ ├── auth/ # Login, biometrics, token refresh, SSO
│ │ ├── data/
│ │ │ ├── datasources/ # auth_remote_ds.dart (BFF API), auth_local_ds.dart (Hive tokens)
│ │ │ ├── models/ # auth_response_model.dart (json_serializable)
│ │ │ └── repositories/ # auth_repo_impl.dart
│ │ ├── domain/
│ │ │ ├── entities/ # user_entity.dart
│ │ │ ├── repositories/ # auth_repo.dart (abstract)
│ │ │ └── usecases/ # login_usecase.dart, enable_biometrics_usecase.dart
│ │ └── presentation/
│ │ ├── providers/ # auth_provider.dart (Riverpod; small state files)
│ │ ├── screens/ # login_screen.dart, biometric_setup_screen.dart
│ │ └── widgets/ # auth_form.dart, social_buttons.dart (feature-specific)
│ │
│ ├── dashboard/ # Bio-Hub: rings, bio-vitals, hydration, AI suggestions
│ │ ├── data/ # datasources (BFF sync, local Hive cache)
│ │ ├── domain/ # entities (bio_state), usecases (calculate_energy_score)
│ │ └── presentation/ # providers (dashboard_provider), screens (dashboard_screen), widgets (dual_ring_tracker)
│ │
│ ├── vision/ # Dragunov Camera: gyro-guided capture, offline queue, flash
│ │ ├── data/ # datasources (camera_remote_ds for S3 upload, local_ds for offline)
│ │ ├── domain/ # entities (scan_result), usecases (capture_photo_usecase, process_depth_map)
│ │ └── presentation/ # providers (camera_provider), screens (camera_screen), widgets (sniper_overlay, capture_button)
│ │
│ ├── planner/ # Adaptive Planner: pantry, leftovers, restaurant coach
│ │ ├── data/ # datasources (inventory_remote, leftovers_local)
│ │ ├── domain/ # entities (recipe, leftover), usecases (generate_recipe_usecase)
│ │ └── presentation/ # providers (planner_provider), screens (pantry_screen, leftovers_screen, eat_out_screen), widgets (recipe_card)
│ │
│ ├── analytics/ # Insights: energy score graphs, correlations
│ │ ├── data/ # datasources (health_metrics_remote)
│ │ ├── domain/ # entities (insight), usecases (compute_correlation_usecase)
│ │ └── presentation/ # providers (analytics_provider), screens (analytics_screen), widgets (energy_chart)
│ │
│ ├── profile/ # Settings: goals, devices, fasting config
│ │ ├── data/ # datasources (profile_remote)
│ │ ├── domain/ # entities (bio_profile), usecases (update_goal_usecase)
│ │ └── presentation/ # providers (profile_provider), screens (profile_screen, device_management_screen), widgets (goal_selector)
│ │
│ └── splash/ # Onboarding, version check, deep links
│ ├── data/
│ ├── domain/
│ └── presentation/
│
├── generated/ # Auto-generated: json_serializable, riverpod generators, etc.
│
└── main.dart # Thin entry: bootstrap(); runApp(App());
