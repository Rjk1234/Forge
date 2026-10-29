import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';

/// Sessions from one calendar month, newest first, under a display label.
class HistoryMonthGroup extends Equatable {
  const HistoryMonthGroup({required this.label, required this.sessions});

  final String label;
  final List<WorkoutSession> sessions;

  @override
  List<Object?> get props => [label, sessions];
}
