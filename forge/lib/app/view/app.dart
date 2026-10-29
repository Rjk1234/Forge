import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/routes/app_routes.dart';
import '../../l10n/l10n.dart';
import '../../core/services/theme_persistence_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/bloc/theme_bloc.dart';
import '../../core/theme/bloc/theme_event.dart';
import '../../core/theme/bloc/theme_state.dart';
import '../get_it_setup.dart';

/// Main application widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (context) =>
          ThemeBloc(persistenceService: getIt<ThemePersistenceService>())
            ..add(const ThemeInitialized()),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          ThemeMode themeMode = ThemeMode.dark;

          if (themeState is ThemeChanged) {
            themeMode = themeState.currentMode;
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => context.l10n.appTitle,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
