import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';

sealed class ExerciseCatalogueState extends Equatable {
  const ExerciseCatalogueState();
}

final class ExerciseCatalogueInitial extends ExerciseCatalogueState {
  const ExerciseCatalogueInitial();

  @override
  List<Object?> get props => [];
}

final class ExerciseCatalogueLoading extends ExerciseCatalogueState {
  const ExerciseCatalogueLoading();

  @override
  List<Object?> get props => [];
}

final class ExerciseCataloguePopulated extends ExerciseCatalogueState {
  const ExerciseCataloguePopulated({
    required this.displayedExercises,
    required this.query,
    required this.activeFilter,
  });

  final List<Exercise> displayedExercises;
  final String query;
  final ExerciseType? activeFilter;

  @override
  List<Object?> get props => [displayedExercises, query, activeFilter];
}

final class ExerciseCatalogueEmpty extends ExerciseCatalogueState {
  const ExerciseCatalogueEmpty({
    required this.query,
    required this.activeFilter,
  });

  final String query;
  final ExerciseType? activeFilter;

  @override
  List<Object?> get props => [query, activeFilter];
}

final class ExerciseCatalogueError extends ExerciseCatalogueState {
  const ExerciseCatalogueError();

  @override
  List<Object?> get props => [];
}
