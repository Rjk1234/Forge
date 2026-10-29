import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base state for ThemeBloc
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

/// Before persistence is loaded
class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

/// Active theme state carrying the current [ThemeMode]
class ThemeChanged extends ThemeState {
  final ThemeMode currentMode;

  const ThemeChanged({required this.currentMode});

  ThemeChanged copyWith({ThemeMode? currentMode}) {
    return ThemeChanged(currentMode: currentMode ?? this.currentMode);
  }

  @override
  List<Object> get props => [currentMode];
}
