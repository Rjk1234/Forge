import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/theme_persistence_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// Manages light/dark theme mode and persists the user's choice
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemePersistenceService persistenceService;

  ThemeBloc({required this.persistenceService}) : super(const ThemeInitial()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeToggled>(_onThemeToggled);
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    final ThemeMode savedMode = persistenceService.loadThemeMode();
    emit(ThemeChanged(currentMode: savedMode));
  }

  Future<void> _onThemeToggled(
    ThemeToggled event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeChanged) {
      final current = (state as ThemeChanged).currentMode;
      final next = current == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      await persistenceService.saveThemeMode(next);
      emit(ThemeChanged(currentMode: next));
    }
  }
}
