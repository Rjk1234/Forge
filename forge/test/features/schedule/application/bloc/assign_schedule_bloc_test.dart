import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_state.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/load_assignment_context_usecase.dart';
import 'package:forge/features/schedule/domain/usecases/save_schedule_assignment_usecase.dart';
import 'package:fpdart/fpdart.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepository implements ScheduleRepository {
  _FakeRepository({
    Either<AppException, ScheduleFormContext>? loadResult,
    List<Either<AppException, void>>? saveResults,
  }) : _loadResult =
           loadResult ??
           const Right(
             ScheduleFormContext(
               planId: 'p1',
               planName: 'Push Day',
               currentDays: {},
               occupiedDays: {},
             ),
           ),
       _saveResults = saveResults ?? [const Right(null)];

  final Either<AppException, ScheduleFormContext> _loadResult;
  final List<Either<AppException, void>> _saveResults;
  int saveCallCount = 0;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) async => _loadResult;

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) async {
    final result =
        _saveResults[saveCallCount.clamp(0, _saveResults.length - 1)];
    saveCallCount++;
    return result;
  }

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AssignScheduleBloc _bloc({
  Either<AppException, ScheduleFormContext>? loadResult,
  List<Either<AppException, void>>? saveResults,
}) {
  final repo = _FakeRepository(
    loadResult: loadResult,
    saveResults: saveResults,
  );
  return AssignScheduleBloc(
    loadAssignmentContext: LoadAssignmentContextUseCase(repository: repo),
    saveScheduleAssignment: SaveScheduleAssignmentUseCase(repository: repo),
  );
}

const _readyState = AssignScheduleReady(
  planId: 'p1',
  planName: 'Push Day',
  originalDays: {1, 3},
  selectedDays: {1, 3},
  occupiedDays: {2: 'Pull Day'},
  conflicts: {},
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssignScheduleBloc', () {
    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'new assignment path — Ready with empty selectedDays',
      build: () => _bloc(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      ),
      act: (bloc) => bloc.add(const AssignScheduleInitialized('p1')),
      expect: () => [
        isA<AssignScheduleLoading>(),
        isA<AssignScheduleReady>()
            .having((s) => s.selectedDays, 'selectedDays', isEmpty)
            .having((s) => s.canSave, 'canSave', isFalse),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'edit path, pre-filled — Ready with selectedDays = currentDays',
      build: () => _bloc(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: 'Push Day',
            currentDays: {1, 3},
            occupiedDays: {},
          ),
        ),
      ),
      act: (bloc) => bloc.add(const AssignScheduleInitialized('p1')),
      expect: () => [
        isA<AssignScheduleLoading>(),
        isA<AssignScheduleReady>()
            .having((s) => s.selectedDays, 'selectedDays', {1, 3})
            .having((s) => s.canSave, 'canSave', isTrue),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'invalid plan — InvalidPlan(planId)',
      build: () => _bloc(
        loadResult: const Right(
          ScheduleFormContext(
            planId: 'p1',
            planName: null,
            currentDays: {},
            occupiedDays: {},
          ),
        ),
      ),
      act: (bloc) => bloc.add(const AssignScheduleInitialized('p1')),
      expect: () => [
        isA<AssignScheduleLoading>(),
        isA<AssignScheduleInvalidPlan>(),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'load failure — presented as InvalidPlan',
      build: () =>
          _bloc(loadResult: Left(CacheException(message: "Couldn't load"))),
      act: (bloc) => bloc.add(const AssignScheduleInitialized('p1')),
      expect: () => [
        isA<AssignScheduleLoading>(),
        isA<AssignScheduleInvalidPlan>(),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'toggle introduces conflict',
      build: () => _bloc(),
      seed: () => _readyState,
      act: (bloc) => bloc.add(const DayToggled(2)),
      expect: () => [
        isA<AssignScheduleReady>()
            .having((s) => s.conflicts, 'conflicts', {2: 'Pull Day'})
            .having((s) => s.canSave, 'canSave', isFalse),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'toggle clears conflict',
      build: () => _bloc(),
      seed: () => _readyState.copyWith(
        selectedDays: {1, 2, 3},
        conflicts: {2: 'Pull Day'},
      ),
      act: (bloc) => bloc.add(const DayToggled(2)),
      expect: () => [
        isA<AssignScheduleReady>()
            .having((s) => s.conflicts, 'conflicts', isEmpty)
            .having((s) => s.canSave, 'canSave', isTrue),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'save success — Saving then Saved',
      build: () => _bloc(saveResults: [const Right(null)]),
      seed: () => _readyState,
      act: (bloc) => bloc.add(const SaveRequested()),
      expect: () => [isA<AssignScheduleSaving>(), isA<AssignScheduleSaved>()],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'save failure then retry — Saving, SaveFailure, Saving, Saved',
      build: () => _bloc(
        saveResults: [
          Left(CacheException(message: "Couldn't save your schedule")),
          const Right(null),
        ],
      ),
      seed: () => _readyState,
      act: (bloc) async {
        bloc.add(const SaveRequested());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const RetrySaveRequested());
      },
      expect: () => [
        isA<AssignScheduleSaving>(),
        isA<AssignScheduleSaveFailure>(),
        isA<AssignScheduleSaving>(),
        isA<AssignScheduleSaved>(),
      ],
    );

    blocTest<AssignScheduleBloc, AssignScheduleState>(
      'save ignored when not canSave',
      build: () => _bloc(),
      seed: () => _readyState.copyWith(selectedDays: const {}),
      act: (bloc) => bloc.add(const SaveRequested()),
      expect: () => <AssignScheduleState>[],
    );
  });
}
