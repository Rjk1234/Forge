import 'package:equatable/equatable.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();
}

/// Initial load, tab re-entry and Retry all use this event.
final class StatsLoadRequested extends StatsEvent {
  const StatsLoadRequested();

  @override
  List<Object?> get props => [];
}
