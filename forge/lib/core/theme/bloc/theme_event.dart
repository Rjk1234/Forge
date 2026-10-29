import 'package:equatable/equatable.dart';

/// Base event for ThemeBloc
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// Initialize theme from persisted preferences
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

/// Toggle between light and dark mode
class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}
