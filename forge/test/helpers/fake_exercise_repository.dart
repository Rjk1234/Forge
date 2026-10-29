import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fpdart/fpdart.dart';

/// An [ExerciseRepository] serving a fixed catalogue (or a failure).
class FakeExerciseRepository implements ExerciseRepository {
  const FakeExerciseRepository(this.catalogue, {this.failure});

  final List<Exercise> catalogue;
  final AppException? failure;

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() async {
    final error = failure;
    return error == null ? Right(catalogue) : Left(error);
  }
}
