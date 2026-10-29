/// Environment enum
enum Environment { development, staging, production }

/// Central application configuration
class AppConfig {
  static late AppConfig _instance;

  final Environment environment;
  final String baseUrl;
  final bool enableLogging;
  final bool enableCrashReporting;

  AppConfig({
    required this.environment,
    required this.baseUrl,
    required this.enableLogging,
    required this.enableCrashReporting,
  });

  /// Initialize the singleton instance
  static void initialize({
    required Environment environment,
    required String baseUrl,
    required bool enableLogging,
    required bool enableCrashReporting,
  }) {
    _instance = AppConfig(
      environment: environment,
      baseUrl: baseUrl,
      enableLogging: enableLogging,
      enableCrashReporting: enableCrashReporting,
    );
  }

  /// Get the singleton instance
  static AppConfig get instance => _instance;

  /// Check if running in development
  bool get isDevelopment => environment == Environment.development;

  /// Check if running in staging
  bool get isStaging => environment == Environment.staging;

  /// Check if running in production
  bool get isProduction => environment == Environment.production;
}
