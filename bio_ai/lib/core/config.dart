// App-wide runtime configuration

/// Set your FatSecret API access token here if you want to use FatSecret
/// Example: const String fatSecretAccessToken = 'eyJhbGciOiJ...';
/// Keep empty to use TheMealDB fallback.
const String fatSecretAccessToken = '';

/// Backend base URL (use 10.0.2.2 for Android emulator -> host machine)
const String backendBaseUrl = 'http://10.0.2.2:8000';

// --- Runtime environment switches ---
// Use --dart-define=APP_ENV=dev|stage|prod when running the app to switch
// Use --dart-define=STREAMING_BASE_URL=http://host:port to configure the streaming mock server

enum AppEnvironment { dev, stage, prod }

class AppConfig {
  static const String _env = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );
  static AppEnvironment get environment {
    switch (_env) {
      case 'dev':
        return AppEnvironment.dev;
      case 'stage':
        return AppEnvironment.stage;
      default:
        return AppEnvironment.prod;
    }
  }

  static const String streamingBaseUrl = String.fromEnvironment(
    'STREAMING_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static bool get isDevOrStage =>
      environment == AppEnvironment.dev || environment == AppEnvironment.stage;
}
