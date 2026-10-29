import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/personal_bests/application/use_cases/get_personal_bests_use_case.dart';
import 'package:forge/features/personal_bests/domain/entities/personal_best_record.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/repositories/workout_session_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements WorkoutSessionRepository {}

SessionExercise _exercise(
  String name,
  ExerciseType type,
  List<ActualSet> sets, {
  String? id,
}) => SessionExercise(
  exerciseId: id ?? name,
  exerciseName: name,
  type: type,
  actualSets: sets,
);

WorkoutSession _session(
  DateTime completedAt,
  List<SessionExercise> exercises,
) => WorkoutSession(
  sessionId: completedAt.toIso8601String(),
  planId: 'p',
  planName: 'Plan',
  completedAt: completedAt,
  startedAt: completedAt,
  sessionDurationSec: 3600,
  sessionExercises: exercises,
);

void main() {
  late _MockRepository repository;
  late GetPersonalBestsUseCase useCase;

  setUp(() {
    repository = _MockRepository();
    useCase = GetPersonalBestsUseCase(repository);
  });

  Future<List<PersonalBestRecord>> run(List<WorkoutSession> sessions) async {
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Right(sessions));
    return (await useCase()).getOrElse((_) => throw StateError('failed'));
  }

  final aug = DateTime(2026, 8, 31);
  final sep = DateTime(2026, 9, 7);

  test('no sessions gives no records', () async {
    expect(await run([]), isEmpty);
  });

  test('sets that are all skipped give no record', () async {
    final records = await run([
      _session(aug, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 100, skipped: true),
        ]),
      ]),
    ]);

    expect(records, isEmpty);
  });

  test(
    'picks the best per type with the date of the session that set it',
    () async {
      final records = await run([
        _session(aug, [
          _exercise('Bench', ExerciseType.weighted, [
            const ActualSet(repetitions: 5, weight: 65),
          ]),
          _exercise('Plank', ExerciseType.timeBased, [
            const ActualSet(durationSec: 70),
          ]),
          _exercise('Push-Ups', ExerciseType.bodyweight, [
            const ActualSet(repetitions: 18),
          ]),
        ]),
        _session(sep, [
          _exercise('Bench', ExerciseType.weighted, [
            const ActualSet(repetitions: 5, weight: 60),
            const ActualSet(repetitions: 5, weight: 90, skipped: true),
          ]),
          _exercise('Plank', ExerciseType.timeBased, [
            const ActualSet(durationSec: 45),
          ]),
          _exercise('Push-Ups', ExerciseType.bodyweight, [
            const ActualSet(repetitions: 12),
          ]),
        ]),
      ]);

      final bench = records.firstWhere((r) => r.exerciseName == 'Bench');
      expect(bench.bestWeight, 65);
      expect(bench.bestDate, aug);
      expect(bench.bestDurationSec, isNull);
      expect(
        records.firstWhere((r) => r.exerciseName == 'Plank').bestDurationSec,
        70,
      );
      expect(
        records.firstWhere((r) => r.exerciseName == 'Push-Ups').bestReps,
        18,
      );
    },
  );

  test('a tie goes to the more recent session', () async {
    final records = await run([
      _session(sep, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 65),
        ]),
      ]),
      _session(aug, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 65),
        ]),
      ]),
    ]);

    expect(records.single.bestDate, sep);
  });

  test('records are sorted alphabetically', () async {
    final records = await run([
      _session(aug, [
        _exercise('Squat', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 100),
        ]),
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 60),
        ]),
        _exercise('Row', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 50),
        ]),
      ]),
    ]);

    expect(records.map((r) => r.exerciseName), ['Bench', 'Row', 'Squat']);
  });

  test('the same exercise id with another type is a separate record', () async {
    final records = await run([
      _session(aug, [
        _exercise('Plank', ExerciseType.timeBased, [
          const ActualSet(durationSec: 60),
        ], id: 'plank'),
      ]),
      _session(sep, [
        _exercise('Plank', ExerciseType.bodyweight, [
          const ActualSet(repetitions: 10),
        ], id: 'plank'),
      ]),
    ]);

    expect(records, hasLength(2));
  });

  test('a read failure propagates', () async {
    when(
      () => repository.getAllSessions(),
    ).thenAnswer((_) async => Left(CacheException(message: 'boom')));

    expect((await useCase()).isLeft(), isTrue);
  });

  test('a weighted set without reps or weight is not a best', () async {
    final records = await run([
      _session(aug, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(weight: 100),
          const ActualSet(repetitions: 5),
        ]),
      ]),
    ]);

    expect(records, isEmpty);
  });

  test('a renamed exercise keeps one record under the latest name', () async {
    final records = await run([
      _session(aug, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 60),
        ], id: 'bench'),
      ]),
      _session(sep, [
        _exercise('Bench Press', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 50),
        ], id: 'bench'),
      ]),
    ]);

    expect(records, hasLength(1));
    expect(records.single.exerciseName, 'Bench Press');
    expect(records.single.bestWeight, 60);
    expect(records.single.bestDate, aug);
  });

  test(
    'equal bests resolve to the later session whatever the input order',
    () async {
      final first = _session(aug, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 5, weight: 60),
        ]),
      ]);
      final second = _session(sep, [
        _exercise('Bench', ExerciseType.weighted, [
          const ActualSet(repetitions: 3, weight: 60),
        ]),
      ]);

      expect((await run([first, second])).single.bestDate, sep);
      expect((await run([second, first])).single.bestDate, sep);
    },
  );
}
