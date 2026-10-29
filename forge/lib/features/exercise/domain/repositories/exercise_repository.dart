import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ExerciseRepository {
  Future<Either<AppException, List<Exercise>>> getExercises();
}
