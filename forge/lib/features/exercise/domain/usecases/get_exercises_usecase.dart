import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetExercisesUseCase {
  const GetExercisesUseCase({required this.repository});

  final ExerciseRepository repository;

  Future<Either<AppException, List<Exercise>>> call() =>
      repository.getExercises();
}
