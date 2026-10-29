import 'package:flutter/material.dart';

import 'app/app.dart';
import 'bootstrap.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.example.com',
    enableLogging: true,
    enableCrashReporting: true,
    appBuilder: () => const App(),
  );
}
