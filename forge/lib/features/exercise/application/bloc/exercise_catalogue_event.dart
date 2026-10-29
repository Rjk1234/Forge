import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

sealed class ExerciseCatalogueEvent extends Equatable {
  const ExerciseCatalogueEvent();
}

final class ExerciseCatalogueLoadRequested extends ExerciseCatalogueEvent {
  const ExerciseCatalogueLoadRequested();

  @override
  List<Object?> get props => [];
}

final class ExerciseCatalogueSearchChanged extends ExerciseCatalogueEvent {
  const ExerciseCatalogueSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ExerciseCatalogueFilterChanged extends ExerciseCatalogueEvent {
  const ExerciseCatalogueFilterChanged(this.type);

  final ExerciseType? type;

  @override
  List<Object?> get props => [type];
}
