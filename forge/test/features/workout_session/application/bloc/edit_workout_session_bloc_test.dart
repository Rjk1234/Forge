import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/edit_workout_session_state.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';
import 'package:forge/features/workout_session/application/use_cases/get_workout_history_detail_use_case.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/domain/usecases/update_workout_session_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetDetail extends Mock implements GetWorkoutHistoryDetailUseCase {}

class _MockUpdate extends Mock implements UpdateWorkoutSessionUseCase {}

final _session = WorkoutSession(
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
      actualSets: [
        ActualSet(repetitions: 5, weight: 60),
        ActualSet(skipped: true),
      ],
    ),
    SessionExercise(
      exerciseId: 'plank',
      exerciseName: 'Plank',
      type: ExerciseType.timeBased,
      actualSets: [ActualSet(durationSec: 45)],
    ),
  ],
);

EditWorkoutSessionFieldChanged _change(
  EditSetField field,
  String value, {
  int exercise = 0,
  int set = 0,
}) => EditWorkoutSessionFieldChanged(
  exerciseIndex: exercise,
  setIndex: set,
  field: field,
  value: value,
);

void main() {
  late _MockGetDetail getDetail;
  late _MockUpdate update;

  setUpAll(() => registerFallbackValue(_session));

  setUp(() {
    getDetail = _MockGetDetail();
    update = _MockUpdate();
    when(() => getDetail('s1')).thenAnswer((_) async => Right(_session));
  });

  EditWorkoutSessionBloc build() =>
      EditWorkoutSessionBloc(getDetail: getDetail, updateSession: update);

  Future<EditWorkoutSessionBloc> loaded() async {
    final bloc = build()..add(const EditWorkoutSessionLoaded(sessionId: 's1'));
    await bloc.stream.firstWhere((s) => s is EditWorkoutSessionReady);
    return bloc;
  }

  group('load', () {
    blocTest<EditWorkoutSessionBloc, EditWorkoutSessionState>(
      'emits loading then a ready form built from the session',
      build: build,
      act: (bloc) => bloc.add(const EditWorkoutSessionLoaded(sessionId: 's1')),
      verify: (bloc) {
        final state = bloc.state as EditWorkoutSessionReady;
        expect(state.exercises.map((e) => e.exerciseName), ['Bench', 'Plank']);
        final sets = state.exercises.first.sets;
        expect(sets.first.repsText, '5');
        expect(sets.first.weightText, '60');
        expect(sets.last.skipped, isTrue);
        expect(state.exercises.last.sets.single.durationText, '45');
      },
    );

    blocTest<EditWorkoutSessionBloc, EditWorkoutSessionState>(
      'emits a load error when the session cannot be read',
      setUp: () => when(
        () => getDetail('s1'),
      ).thenAnswer((_) async => Left(CacheException(message: 'gone'))),
      build: build,
      act: (bloc) => bloc.add(const EditWorkoutSessionLoaded(sessionId: 's1')),
      expect: () => const [
        EditWorkoutSessionLoading(),
        EditWorkoutSessionLoadError(),
      ],
    );
  });

  group('editing', () {
    test('an invalid reps value flags only that field', () async {
      final bloc = await loaded();

      bloc.add(_change(EditSetField.reps, '0'));
      final state =
          await bloc.stream.firstWhere((s) => s is EditWorkoutSessionReady)
              as EditWorkoutSessionReady;

      expect(state.exercises.first.sets.first.invalidFields, {
        EditSetField.reps,
      });
      await bloc.close();
    });

    test('correcting a flagged field clears its error', () async {
      final bloc = await loaded();

      bloc
        ..add(_change(EditSetField.weight, '5000'))
        ..add(_change(EditSetField.weight, '62.5'));
      await bloc.stream.take(2).last;

      final set =
          (bloc.state as EditWorkoutSessionReady).exercises.first.sets.first;
      expect(set.invalidFields, isEmpty);
      expect(set.weightText, '62.5');
      await bloc.close();
    });

    test('skipping a set clears its errors and is reversible', () async {
      final bloc = await loaded();

      bloc
        ..add(_change(EditSetField.reps, ''))
        ..add(
          const EditWorkoutSessionSkipToggled(
            exerciseIndex: 0,
            setIndex: 0,
            skipped: true,
          ),
        );
      await bloc.stream.take(2).last;

      final set =
          (bloc.state as EditWorkoutSessionReady).exercises.first.sets.first;
      expect(set.skipped, isTrue);
      expect(set.invalidFields, isEmpty);
      await bloc.close();
    });
  });

  group('save', () {
    test('invalid fields block the save', () async {
      final bloc = await loaded();
      bloc.add(_change(EditSetField.reps, ''));
      await bloc.stream.first;

      bloc.add(const EditWorkoutSessionSaveRequested());
      await pumpEventQueue();

      verifyNever(() => update(any()));
      expect(bloc.state, isA<EditWorkoutSessionReady>());
      await bloc.close();
    });

    test('skipping every set shows the no-valid-set error', () async {
      final bloc = await loaded();
      bloc
        ..add(
          const EditWorkoutSessionSkipToggled(
            exerciseIndex: 0,
            setIndex: 0,
            skipped: true,
          ),
        )
        ..add(
          const EditWorkoutSessionSkipToggled(
            exerciseIndex: 1,
            setIndex: 0,
            skipped: true,
          ),
        );
      await bloc.stream.take(2).last;

      bloc.add(const EditWorkoutSessionSaveRequested());
      await bloc.stream.first;

      verifyNever(() => update(any()));
      expect((bloc.state as EditWorkoutSessionReady).hasNoValidSet, isTrue);
      await bloc.close();
    });

    test('a valid edit saves the updated session and emits saved', () async {
      when(() => update(any())).thenAnswer((_) async => const Right(null));
      final bloc = await loaded();
      bloc.add(_change(EditSetField.reps, '8'));
      await bloc.stream.first;

      bloc.add(const EditWorkoutSessionSaveRequested());
      await bloc.stream.firstWhere((s) => s is EditWorkoutSessionSaved);

      final saved =
          verify(() => update(captureAny())).captured.single as WorkoutSession;
      expect(saved.sessionId, 's1');
      expect(saved.sessionDurationSec, 3600);
      final sets = saved.sessionExercises.first.actualSets;
      expect(sets.first, const ActualSet(repetitions: 8, weight: 60));
      expect(sets.last.skipped, isTrue);
      await bloc.close();
    });

    test('a failed save keeps the form and can be retried', () async {
      var calls = 0;
      when(() => update(any())).thenAnswer((_) async {
        calls++;
        return calls == 1
            ? Left<AppException, void>(CacheException(message: 'disk'))
            : const Right<AppException, void>(null);
      });
      final bloc = await loaded();

      bloc.add(const EditWorkoutSessionSaveRequested());
      await bloc.stream.firstWhere((s) => s is EditWorkoutSessionSaveFailure);
      bloc.add(const EditWorkoutSessionSaveRequested());
      await bloc.stream.firstWhere((s) => s is EditWorkoutSessionSaved);

      expect(calls, 2);
      await bloc.close();
    });
  });
}
