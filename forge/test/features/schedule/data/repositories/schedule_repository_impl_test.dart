import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/exceptions/app_exception.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/schedule/data/repositories/schedule_repository_impl.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';

// ---------------------------------------------------------------------------
// Fake data sources
// ---------------------------------------------------------------------------

class _FakeScheduleDataSource implements ScheduleLocalDataSource {
  _FakeScheduleDataSource({List<ScheduleEntryRecord>? entries})
    : _entries = entries ?? [];

  final List<ScheduleEntryRecord> _entries;
  final List<int> deletedWeekdays = [];
  final List<int> savedWeekdays = [];
  bool throwOnCall = false;
  bool throwSaveOnCall = false;

  @override
  Future<List<ScheduleEntryRecord>> getAllEntries() async {
    if (throwOnCall) throw Exception('database error');
    return List.of(_entries);
  }

  @override
  Future<ScheduleEntryRecord?> getEntryByWeekday(int weekday) async =>
      _entries.where((e) => e.weekday == weekday).firstOrNull;

  @override
  Future<void> saveEntry(ScheduleEntryRecord entry) async {
    if (throwSaveOnCall) throw Exception('database error');
    savedWeekdays.add(entry.weekday);
  }

  @override
  Future<void> deleteEntry(int weekday) async {
    if (throwSaveOnCall) throw Exception('database error');
    deletedWeekdays.add(weekday);
    _entries.removeWhere((e) => e.weekday == weekday);
  }

  @override
  Future<void> replaceAssignment({
    required String planId,
    required String planName,
    required Set<int> removedWeekdays,
    required Set<int> savedWeekdays,
  }) async {
    for (final weekday in removedWeekdays) {
      await deleteEntry(weekday);
    }
    for (final weekday in savedWeekdays) {
      await saveEntry(
        ScheduleEntryRecord(
          weekday: weekday,
          planId: planId,
          planName: planName,
        ),
      );
    }
  }
}

class _FakePlanDataSource implements WorkoutPlanLocalDataSource {
  _FakePlanDataSource({Map<String, WorkoutPlanRecord>? plans})
    : _plans = plans ?? {};

  final Map<String, WorkoutPlanRecord> _plans;

  @override
  Future<List<WorkoutPlanRecord>> getAllPlans() async => _plans.values.toList();

  @override
  Future<WorkoutPlanRecord?> getPlanById(String planId) async => _plans[planId];

  @override
  Future<void> savePlan(WorkoutPlanRecord model) async {}

  @override
  Future<void> deletePlan(String planId) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ScheduleEntryRecord _entry(int weekday, String planId, String planName) =>
    ScheduleEntryRecord(weekday: weekday, planId: planId, planName: planName);

WorkoutPlanRecord _plan(String planId, String name) => WorkoutPlanRecord(
  planId: planId,
  name: name,
  planExercises: [],
  createdAt: DateTime(2026, 1, 1),
  updatedAt: DateTime(2026, 1, 1),
);

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ScheduleRepositoryImpl', () {
    test(
      'all-resolve — 7 days built; days with entries have assignedPlan',
      () async {
        final scheduleDs = _FakeScheduleDataSource(
          entries: [_entry(1, 'p1', 'Push Day'), _entry(3, 'p2', 'Pull Day')],
        );
        final planDs = _FakePlanDataSource(
          plans: {'p1': _plan('p1', 'Push Day'), 'p2': _plan('p2', 'Pull Day')},
        );

        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: planDs,
        );

        final result = await repo.getWeeklySchedule();

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (schedule) {
          expect(schedule.days.length, 7);
          expect(schedule.days[0].weekday, 1);
          expect(schedule.days[0].assignedPlan?.planId, 'p1');
          expect(schedule.days[0].assignedPlan?.planName, 'Push Day');
          expect(schedule.days[0].assignedPlan?.recurrenceLabel, 'Weekly');
          expect(schedule.days[1].assignedPlan, isNull);
          expect(schedule.days[2].assignedPlan?.planId, 'p2');
          expect(schedule.days[6].weekday, 7);
        });
      },
    );

    test(
      'orphaned entry — plan missing → day is a rest day and nothing is deleted',
      () async {
        final scheduleDs = _FakeScheduleDataSource(
          entries: [_entry(2, 'ghost', 'Ghost Plan')],
        );
        final planDs = _FakePlanDataSource(plans: {});

        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: planDs,
        );

        final result = await repo.getWeeklySchedule();

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (schedule) {
          expect(schedule.days[1].assignedPlan, isNull);
        });
        expect(scheduleDs.deletedWeekdays, isEmpty);
      },
    );

    test('no-entries — all 7 days are rest days', () async {
      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: _FakeScheduleDataSource(),
        planDataSource: _FakePlanDataSource(),
      );

      final result = await repo.getWeeklySchedule();

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (schedule) {
        expect(schedule.days.length, 7);
        expect(schedule.days.every((d) => d.assignedPlan == null), isTrue);
      });
    });

    test('data source throws → returns Left(CacheException)', () async {
      final scheduleDs = _FakeScheduleDataSource()..throwOnCall = true;

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: _FakePlanDataSource(),
      );

      final result = await repo.getWeeklySchedule();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheException>()),
        (_) => fail('Expected Left'),
      );
    });

    test(
      'today-resolution — isToday is true for the current weekday only',
      () async {
        final today = DateTime.now().weekday;

        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: _FakeScheduleDataSource(),
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.getWeeklySchedule();

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (schedule) {
          final todayDays = schedule.days.where((d) => d.isToday).toList();
          expect(todayDays.length, 1);
          expect(todayDays.first.weekday, today);
        });
      },
    );

    test(
      'date field — each day has the correct date for this ISO week',
      () async {
        final now = DateTime.now();
        final mondayOfThisWeek = now.subtract(Duration(days: now.weekday - 1));
        final expectedMonday = DateTime(
          mondayOfThisWeek.year,
          mondayOfThisWeek.month,
          mondayOfThisWeek.day,
        );

        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: _FakeScheduleDataSource(),
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.getWeeklySchedule();

        result.fold((_) {}, (schedule) {
          expect(schedule.days.first.date, expectedMonday);
          expect(
            schedule.days.last.date,
            expectedMonday.add(const Duration(days: 6)),
          );
        });
      },
    );

    test('assignedPlan recurrenceLabel is always "Weekly"', () async {
      final scheduleDs = _FakeScheduleDataSource(
        entries: [_entry(5, 'p5', 'Leg Day')],
      );
      final planDs = _FakePlanDataSource(plans: {'p5': _plan('p5', 'Leg Day')});

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: planDs,
      );

      final result = await repo.getWeeklySchedule();

      result.fold((_) {}, (schedule) {
        final friday = schedule.days.firstWhere((d) => d.weekday == 5);
        expect(friday.assignedPlan?.recurrenceLabel, 'Weekly');
      });
    });
  });

  group('ScheduleRepositoryImpl.loadAssignmentContext', () {
    test('new plan, no existing days — currentDays empty', () async {
      final planDs = _FakePlanDataSource(
        plans: {'p1': _plan('p1', 'Push Day')},
      );
      final scheduleDs = _FakeScheduleDataSource(
        entries: [_entry(2, 'p2', 'Pull Day')],
      );

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: planDs,
      );

      final result = await repo.loadAssignmentContext('p1');

      expect(result.isRight(), isTrue);
      result.fold((_) {}, (ctx) {
        expect(ctx.planName, 'Push Day');
        expect(ctx.currentDays, isEmpty);
        expect(ctx.occupiedDays, {2: 'Pull Day'});
      });
    });

    test('occupiedDays use the occupying plan\'s current name', () async {
      final planDs = _FakePlanDataSource(
        plans: {
          'p1': _plan('p1', 'Push Day'),
          'p2': _plan('p2', 'Pull Day v2'),
        },
      );
      final scheduleDs = _FakeScheduleDataSource(
        entries: [_entry(2, 'p2', 'Pull Day')],
      );

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: planDs,
      );

      final result = await repo.loadAssignmentContext('p1');

      result.fold((_) {}, (ctx) {
        expect(ctx.occupiedDays, {2: 'Pull Day v2'});
      });
    });

    test('existing assignment — currentDays reflects owned weekdays', () async {
      final planDs = _FakePlanDataSource(
        plans: {'p1': _plan('p1', 'Push Day')},
      );
      final scheduleDs = _FakeScheduleDataSource(
        entries: [
          _entry(1, 'p1', 'Push Day'),
          _entry(3, 'p1', 'Push Day'),
          _entry(5, 'p1', 'Push Day'),
        ],
      );

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: planDs,
      );

      final result = await repo.loadAssignmentContext('p1');

      result.fold((_) {}, (ctx) {
        expect(ctx.currentDays, {1, 3, 5});
      });
    });

    test(
      'self-exclusion — occupiedDays never contains the plan\'s own days',
      () async {
        final planDs = _FakePlanDataSource(
          plans: {'p1': _plan('p1', 'Push Day')},
        );
        final scheduleDs = _FakeScheduleDataSource(
          entries: [_entry(1, 'p1', 'Push Day'), _entry(2, 'p2', 'Pull Day')],
        );

        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: planDs,
        );

        final result = await repo.loadAssignmentContext('p1');

        result.fold((_) {}, (ctx) {
          expect(ctx.occupiedDays.containsKey(1), isFalse);
          expect(ctx.occupiedDays, {2: 'Pull Day'});
        });
      },
    );

    test(
      'invalid plan — returns Right with planName null, not a Left',
      () async {
        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: _FakeScheduleDataSource(),
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.loadAssignmentContext('missing');

        expect(result.isRight(), isTrue);
        result.fold((_) {}, (ctx) {
          expect(ctx.planName, isNull);
          expect(ctx.currentDays, isEmpty);
          expect(ctx.occupiedDays, isEmpty);
        });
      },
    );

    test('data source throws — returns Left(CacheException)', () async {
      final planDs = _FakePlanDataSource(
        plans: {'p1': _plan('p1', 'Push Day')},
      );
      final scheduleDs = _FakeScheduleDataSource()..throwOnCall = true;

      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: planDs,
      );

      final result = await repo.loadAssignmentContext('p1');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<CacheException>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('ScheduleRepositoryImpl.removeEntry', () {
    test('success — deleteEntry called with weekday, returns Right', () async {
      final scheduleDs = _FakeScheduleDataSource(
        entries: [_entry(3, 'p1', 'Push Day')],
      );
      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: _FakePlanDataSource(),
      );

      final result = await repo.removeEntry(3);

      expect(result.isRight(), isTrue);
      expect(scheduleDs.deletedWeekdays, contains(3));
    });

    test(
      'already-absent key — deleteEntry still called, returns Right',
      () async {
        final scheduleDs = _FakeScheduleDataSource();
        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.removeEntry(5);

        expect(result.isRight(), isTrue);
        expect(scheduleDs.deletedWeekdays, contains(5));
      },
    );

    test(
      'data source throws — returns Left(CacheException), no exception propagates',
      () async {
        final scheduleDs = _FakeScheduleDataSource()..throwSaveOnCall = true;
        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.removeEntry(2);

        expect(result.isLeft(), isTrue);
        result.fold((failure) {
          expect(failure, isA<CacheException>());
          expect(failure.message, "Couldn't remove this entry");
        }, (_) => fail('Expected Left'));
      },
    );
  });

  group('ScheduleRepositoryImpl.saveAssignment', () {
    test(
      'pure addition — saveEntry called, deleteEntry never called',
      () async {
        final scheduleDs = _FakeScheduleDataSource();
        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.saveAssignment(
          planId: 'p1',
          planName: 'Push Day',
          previousWeekdays: const {},
          newWeekdays: const {2, 4},
        );

        expect(result.isRight(), isTrue);
        expect(scheduleDs.savedWeekdays, containsAll([2, 4]));
        expect(scheduleDs.deletedWeekdays, isEmpty);
      },
    );

    test('pure removal — deleteEntry called, saveEntry never called', () async {
      final scheduleDs = _FakeScheduleDataSource();
      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: _FakePlanDataSource(),
      );

      final result = await repo.saveAssignment(
        planId: 'p1',
        planName: 'Push Day',
        previousWeekdays: const {2, 4},
        newWeekdays: const {},
      );

      expect(result.isRight(), isTrue);
      expect(scheduleDs.deletedWeekdays, containsAll([2, 4]));
      expect(scheduleDs.savedWeekdays, isEmpty);
    });

    test('mixed diff — delete(1), save(3), save(5)', () async {
      final scheduleDs = _FakeScheduleDataSource();
      final repo = ScheduleRepositoryImpl(
        scheduleDataSource: scheduleDs,
        planDataSource: _FakePlanDataSource(),
      );

      final result = await repo.saveAssignment(
        planId: 'p1',
        planName: 'Push Day',
        previousWeekdays: const {1, 3},
        newWeekdays: const {3, 5},
      );

      expect(result.isRight(), isTrue);
      expect(scheduleDs.deletedWeekdays, [1]);
      expect(scheduleDs.savedWeekdays, containsAll([3, 5]));
    });

    test(
      'data source throws — returns Left(CacheException), no exception propagates',
      () async {
        final scheduleDs = _FakeScheduleDataSource()..throwSaveOnCall = true;
        final repo = ScheduleRepositoryImpl(
          scheduleDataSource: scheduleDs,
          planDataSource: _FakePlanDataSource(),
        );

        final result = await repo.saveAssignment(
          planId: 'p1',
          planName: 'Push Day',
          previousWeekdays: const {},
          newWeekdays: const {2},
        );

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<CacheException>()),
          (_) => fail('Expected Left'),
        );
      },
    );
  });
}
