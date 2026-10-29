import 'package:flutter/material.dart';

import 'app/app.dart';
import 'bootstrap.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await bootstrap(
    environment: Environment.development,
    baseUrl: 'https://dev-api.example.com',
    enableLogging: true,
    enableCrashReporting: false,
    appBuilder: () => const App(),
  );
}
