import 'package:equatable/equatable.dart';
import 'package:forge/features/stats/domain/entities/exercise_stat_row.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';

sealed class StatsState extends Equatable {
  const StatsState();
}

final class StatsInitial extends StatsState {
  const StatsInitial();

  @override
  List<Object?> get props => [];
}

final class StatsLoading extends StatsState {
  const StatsLoading();

  @override
  List<Object?> get props => [];
}

/// [stats] with zero workouts means the empty state; not a separate state.
final class StatsLoaded extends StatsState {
  const StatsLoaded({required this.stats, required this.exercises});

  final StatsData stats;
  final List<ExerciseStatRow> exercises;

  @override
  List<Object?> get props => [stats, exercises];
}

final class StatsError extends StatsState {
  const StatsError();

  @override
  List<Object?> get props => [];
}
