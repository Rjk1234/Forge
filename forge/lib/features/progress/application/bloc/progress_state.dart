import 'package:equatable/equatable.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';

sealed class ProgressState extends Equatable {
  const ProgressState();
}

final class ProgressInitial extends ProgressState {
  const ProgressInitial();

  @override
  List<Object?> get props => [];
}

final class ProgressLoading extends ProgressState {
  const ProgressLoading();

  @override
  List<Object?> get props => [];
}

/// [exercises] is empty when no workout has been logged yet.
final class ProgressLoaded extends ProgressState {
  const ProgressLoaded({
    required this.exercises,
    required this.selectedExerciseName,
  });

  final List<ExerciseProgressData> exercises;
  final String selectedExerciseName;

  @override
  List<Object?> get props => [exercises, selectedExerciseName];
}

final class ProgressError extends ProgressState {
  const ProgressError();

  @override
  List<Object?> get props => [];
}
