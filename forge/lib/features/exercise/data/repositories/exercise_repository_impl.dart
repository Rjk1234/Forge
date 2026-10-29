import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/core/logger/app_logger.dart';
import 'package:forge/features/exercise/data/datasources/exercise_local_data_source.dart';
import 'package:forge/features/exercise/data/mappers/exercise_mapper.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:fpdart/fpdart.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  const ExerciseRepositoryImpl({required this.dataSource});

  final ExerciseLocalDataSource dataSource;

  @override
  Future<Either<AppException, List<Exercise>>> getExercises() async {
    try {
      final models = await dataSource.getAllExercises();
      return Right(models.map(ExerciseMapper.fromRecord).toList());
    } catch (e, stackTrace) {
      AppLogger.error('Failed to read exercise catalogue', e, stackTrace);
      return Left(
        CacheException(
          message: "Couldn't load the exercise catalogue",
          originalException: e,
        ),
      );
    }
  }
}
