import 'package:flutter/material.dart';

import 'app/get_it_setup.dart';
import 'config/app_config.dart';
import 'core/services/exercise_seed_service.dart';

/// Bootstrap the application — called from each main_*.dart entry point.
///
/// Order:
///   1. AppConfig   — environment + feature flags
///   2. GetIt       — dependency injection (registers the AppDatabase)
///   3. Catalogue   — seed the exercise catalogue
///   4. runApp
Future<void> bootstrap({
  required Environment environment,
  required String baseUrl,
  required bool enableLogging,
  required bool enableCrashReporting,
  required Widget Function() appBuilder,
}) async {
  // 1. Configuration
  AppConfig.initialize(
    environment: environment,
    baseUrl: baseUrl,
    enableLogging: enableLogging,
    enableCrashReporting: enableCrashReporting,
  );

  // 2. Dependency injection (registers the local database)
  await setupGetIt();

  // 3. Exercise catalogue (needs the DI-provided data source)
  await getIt<ExerciseSeedService>().syncCatalogue();

  // 4. Run
  runApp(appBuilder());
}
