import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/week_schedule_state.dart';
import 'package:forge/features/schedule/domain/entities/schedule_day.dart';
import 'package:forge/features/schedule/domain/entities/schedule_form_context.dart';
import 'package:forge/features/schedule/domain/entities/weekly_schedule.dart';
import 'package:forge/features/schedule/domain/repositories/schedule_repository.dart';
import 'package:forge/features/schedule/domain/usecases/get_weekly_schedule_usecase.dart';
import 'package:fpdart/fpdart.dart';

// ---------------------------------------------------------------------------
// Fake repository
// ---------------------------------------------------------------------------

class _FakeRepository implements ScheduleRepository {
  _FakeRepository(this.response);

  final Either<AppException, WeeklySchedule> Function() response;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() async =>
      response();

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

class _SlowRepository implements ScheduleRepository {
  _SlowRepository({required this.delay});

  final Duration delay;

  @override
  Future<Either<AppException, WeeklySchedule>> getWeeklySchedule() async {
    await Future<void>.delayed(delay);
    return Right(_scheduleWithPlan());
  }

  @override
  Future<Either<AppException, ScheduleFormContext>> loadAssignmentContext(
    String planId,
  ) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> saveAssignment({
    required String planId,
    required String planName,
    required Set<int> previousWeekdays,
    required Set<int> newWeekdays,
  }) => throw UnimplementedError();

  @override
  Future<Either<AppException, void>> removeEntry(int weekday) =>
      throw UnimplementedError();
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

WeeklySchedule _scheduleWithPlan() {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  return WeeklySchedule(
    days: List.generate(
      7,
      (i) => ScheduleDay(
        weekday: i + 1,
        date: monday.add(Duration(days: i)),
        isToday: (i + 1) == now.weekday,
        assignedPlan: i == 0
            ? const ScheduledPlanRef(
                planId: 'p1',
                planName: 'Push Day',
                recurrenceLabel: 'Weekly',
              )
            : null,
      ),
    ),
  );
}

WeeklySchedule _allRestSchedule() {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  return WeeklySchedule(
    days: List.generate(
      7,
      (i) => ScheduleDay(
        weekday: i + 1,
        date: monday.add(Duration(days: i)),
        isToday: (i + 1) == now.weekday,
      ),
    ),
  );
}

WeekScheduleBloc _makeBloc(Either<AppException, WeeklySchedule> result) =>
    WeekScheduleBloc(
      getWeeklySchedule: GetWeeklyScheduleUseCase(
        repository: _FakeRepository(() => result),
      ),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('WeekScheduleBloc', () {
    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'WeekScheduleRequested → Loading then Populated when schedule has plans',
      build: () => _makeBloc(Right(_scheduleWithPlan())),
      act: (bloc) => bloc.add(const WeekScheduleRequested()),
      expect: () => [isA<WeekScheduleLoading>(), isA<WeekSchedulePopulated>()],
    );

    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'WeekScheduleRequested → Loading then Empty when all days are rest',
      build: () => _makeBloc(Right(_allRestSchedule())),
      act: (bloc) => bloc.add(const WeekScheduleRequested()),
      expect: () => [isA<WeekScheduleLoading>(), isA<WeekScheduleEmpty>()],
    );

    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'WeekScheduleRequested → Loading then Error on failure',
      build: () => _makeBloc(Left(CacheException(message: "Couldn't load"))),
      act: (bloc) => bloc.add(const WeekScheduleRequested()),
      expect: () => [isA<WeekScheduleLoading>(), isA<WeekScheduleError>()],
    );

    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'WeekScheduleRetried recovers from Error to Populated',
      build: () {
        var callCount = 0;
        return WeekScheduleBloc(
          getWeeklySchedule: GetWeeklyScheduleUseCase(
            repository: _FakeRepository(() {
              callCount++;
              if (callCount == 1) {
                return Left(CacheException(message: 'fail'));
              }
              return Right(_scheduleWithPlan());
            }),
          ),
        );
      },
      act: (bloc) async {
        bloc.add(const WeekScheduleRequested());
        await Future<void>.delayed(const Duration(milliseconds: 50));
        bloc.add(const WeekScheduleRetried());
      },
      expect: () => [
        isA<WeekScheduleLoading>(),
        isA<WeekScheduleError>(),
        isA<WeekScheduleLoading>(),
        isA<WeekSchedulePopulated>(),
      ],
    );

    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'WeekScheduleRetried is ignored while already Loading',
      build: () => WeekScheduleBloc(
        getWeeklySchedule: GetWeeklyScheduleUseCase(
          repository: _SlowRepository(delay: const Duration(milliseconds: 50)),
        ),
      ),
      act: (bloc) async {
        bloc.add(const WeekScheduleRequested());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const WeekScheduleRetried()); // ignored — still loading
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [isA<WeekScheduleLoading>(), isA<WeekSchedulePopulated>()],
    );

    blocTest<WeekScheduleBloc, WeekScheduleState>(
      'Populated state carries the schedule returned by use case',
      build: () => _makeBloc(Right(_scheduleWithPlan())),
      act: (bloc) => bloc.add(const WeekScheduleRequested()),
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<WeekSchedulePopulated>());
        if (state is WeekSchedulePopulated) {
          expect(state.schedule.days.length, 7);
          expect(state.schedule.days.first.assignedPlan?.planId, 'p1');
        }
      },
    );
  });
}
