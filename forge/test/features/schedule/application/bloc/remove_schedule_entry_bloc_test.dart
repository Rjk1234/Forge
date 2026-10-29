import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_event.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_state.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/remove_schedule_entry_usecase.dart';
import 'package:fpdart/fpdart.dart';

// ---------------------------------------------------------------------------
// Fake use case via fake repository
// ---------------------------------------------------------------------------

class _FakeRepository implements ScheduleRepository {
  _FakeRepository({required this.removeResult});

  final Future<Either<AppException, void>> Function(int weekday) removeResult;

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      removeResult(weekday);

  @override
  Future<Either<AppException, Never>> getWeeklySchedule() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, Never>> loadAssignmentContext(String planId) =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => throw UnimplementedError();
}

RemoveScheduleEntryBloc _makeBloc(
  Future<Either<AppException, void>> Function(int) removeResult,
) => RemoveScheduleEntryBloc(
  removeScheduleEntry: RemoveScheduleEntryUseCase(
    repository: _FakeRepository(removeResult: removeResult),
  ),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('RemoveScheduleEntryBloc', () {
    test('initial state is RemoveScheduleEntryConfirmation', () {
      final bloc = _makeBloc((_) async => const Right(null));
      expect(bloc.state, isA<RemoveScheduleEntryConfirmation>());
      bloc.close();
    });

    blocTest<RemoveScheduleEntryBloc, RemoveScheduleEntryState>(
      'success — emits [Removing, Success]',
      build: () => _makeBloc((_) async => const Right(null)),
      act: (bloc) => bloc.add(const RemoveScheduleEntryConfirmed(weekday: 3)),
      expect: () => [
        isA<RemoveScheduleEntryRemoving>(),
        isA<RemoveScheduleEntrySuccess>(),
      ],
    );

    blocTest<RemoveScheduleEntryBloc, RemoveScheduleEntryState>(
      'failure — emits [Removing, Failure] with message',
      build: () => _makeBloc(
        (_) async =>
            Left(CacheException(message: "Couldn't remove this entry")),
      ),
      act: (bloc) => bloc.add(const RemoveScheduleEntryConfirmed(weekday: 5)),
      expect: () => [
        isA<RemoveScheduleEntryRemoving>(),
        isA<RemoveScheduleEntryFailure>(),
      ],
    );

    blocTest<RemoveScheduleEntryBloc, RemoveScheduleEntryState>(
      'different weekday — emits [Removing, Success] for weekday 7',
      build: () => _makeBloc((_) async => const Right(null)),
      act: (bloc) => bloc.add(const RemoveScheduleEntryConfirmed(weekday: 7)),
      expect: () => [
        isA<RemoveScheduleEntryRemoving>(),
        isA<RemoveScheduleEntrySuccess>(),
      ],
    );
  });
}
