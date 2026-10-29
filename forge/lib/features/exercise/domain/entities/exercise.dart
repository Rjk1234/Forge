import 'package:equatable/equatable.dart';
import 'package:forge/core/enums/exercise_type.dart';

class Exercise extends Equatable {
  const Exercise({required this.id, required this.name, required this.type});

  final String id;
  final String name;
  final ExerciseType type;

  @override
  List<Object> get props => [id, name, type];
}
