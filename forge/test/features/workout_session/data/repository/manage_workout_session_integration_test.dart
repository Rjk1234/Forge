import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/repositories/exercise_repository.dart';
import 'package:forge/features/workout_session/data/datasources/workout_session_local_data_source.dart';
import 'package:forge/features/workout_session/data/repositories/workout_session_repository_impl.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/usecases/delete_workout_session_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/save_workout_session_usecase.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:forge/core/exceptions/app_exception.dart';

class _MockExerciseRepository extends Mock implements ExerciseRepository {}

void main() {
  late AppDatabase db;
  late WorkoutSessionRepositoryImpl repository;
  late SaveWorkoutSessionUseCase save;
  late UpdateWorkoutSessionUseCase update;
  late DeleteWorkoutSessionUseCase delete;

  final session = WorkoutSession(
    sessionId: 's1',
    planId: 'p1',
    planName: 'Push',
    completedAt: DateTime(2026, 9, 7, 19),
    startedAt: DateTime(2026, 9, 7, 18),
    sessionDurationSec: 3600,
    sessionExercises: const [
      SessionExercise(
        exerciseId: 'bench',
        exerciseName: 'Bench',
        type: ExerciseType.weighted,
        actualSets: [ActualSet(repetitions: 5, weight: 60)],
      ),
    ],
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = WorkoutSessionRepositoryImpl(
      dataSource: WorkoutSessionLocalDataSourceImpl(db),
    );
    final exercises = _MockExerciseRepository();
    when(() => exercises.getExercises()).thenAnswer(
      (_) async => const Right<AppException, List<Exercise>>([
        Exercise(id: 'bench', name: 'Bench', type: ExerciseType.weighted),
      ]),
    );
    save = SaveWorkoutSessionUseCase(
      repository: repository,
      exerciseRepository: exercises,
    );
    update = UpdateWorkoutSessionUseCase(
      repository: repository,
      saveSession: save,
    );
    delete = DeleteWorkoutSessionUseCase(repository);
    await save(session);
  });

  tearDown(() => db.close());

  Future<WorkoutSession?> stored() async =>
      (await repository.getSessionById('s1')).getOrElse((_) => null);

  test('update replaces the stored sets and keeps identity', () async {
    final edited = WorkoutSession(
      sessionId: 's1',
      planId: 'p1',
      planName: 'Push',
      completedAt: session.completedAt,
      startedAt: session.startedAt,
      sessionDurationSec: 3600,
      sessionExercises: const [
        SessionExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          type: ExerciseType.weighted,
          actualSets: [
            ActualSet(repetitions: 8, weight: 62.5),
            ActualSet(skipped: true),
          ],
        ),
      ],
    );

    expect((await update(edited)).isRight(), isTrue);

    final loaded = await stored();
    final sets = loaded!.sessionExercises.single.actualSets;
    expect(sets.map((s) => s.repetitions), [8, null]);
    expect(sets.first.weight, 62.5);
    expect(sets.last.skipped, isTrue);
    expect(loaded.startedAt, session.startedAt);
    expect(loaded.sessionDurationSec, 3600);
    expect((await repository.getAllSessions()).getOrElse((_) => []).length, 1);
  });

  test('an invalid update leaves the stored session untouched', () async {
    final invalid = WorkoutSession(
      sessionId: 's1',
      planId: 'p1',
      planName: 'Push',
      completedAt: session.completedAt,
      startedAt: session.startedAt,
      sessionDurationSec: 3600,
      sessionExercises: const [
        SessionExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench',
          type: ExerciseType.weighted,
          actualSets: [ActualSet(skipped: true)],
        ),
      ],
    );

    expect((await update(invalid)).isLeft(), isTrue);
    expect(await stored(), session);
  });

  test('delete removes the stored session', () async {
    expect((await delete('s1')).isRight(), isTrue);

    expect(await stored(), isNull);
    expect(
      (await repository.getAllSessions()).getOrElse((_) => [session]),
      isEmpty,
    );
  });
}
