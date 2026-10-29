import 'package:flutter/material.dart';

import 'app/app.dart';
import 'bootstrap.dart';
import 'config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap(
    environment: Environment.production,
    baseUrl: 'https://api.example.com',
    enableLogging: false,
    enableCrashReporting: true,
    appBuilder: () => const App(),
  );
}
