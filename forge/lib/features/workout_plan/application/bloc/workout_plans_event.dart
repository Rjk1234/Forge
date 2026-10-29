import 'package:equatable/equatable.dart';

sealed class WorkoutPlansEvent extends Equatable {
  const WorkoutPlansEvent();
}

final class WorkoutPlansLoadRequested extends WorkoutPlansEvent {
  const WorkoutPlansLoadRequested();

  @override
  List<Object> get props => [];
}
