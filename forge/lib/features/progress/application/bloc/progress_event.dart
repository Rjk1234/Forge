import 'package:equatable/equatable.dart';

sealed class ProgressEvent extends Equatable {
  const ProgressEvent();
}

final class ProgressLoadRequested extends ProgressEvent {
  const ProgressLoadRequested();

  @override
  List<Object?> get props => [];
}

final class ProgressExerciseSelected extends ProgressEvent {
  const ProgressExerciseSelected({required this.exerciseName});

  final String exerciseName;

  @override
  List<Object?> get props => [exerciseName];
}
