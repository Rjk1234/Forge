import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/schedule/data/datasources/schedule_local_data_source.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';
import 'package:forge/features/workout_plan/data/datasources/workout_plan_local_data_source.dart';
import 'package:forge/features/workout_plan/data/models/workout_plan_record.dart';

void main() {
  late AppDatabase db;
  late ScheduleLocalDataSourceImpl dataSource;
  late WorkoutPlanLocalDataSourceImpl planDataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ScheduleLocalDataSourceImpl(db);
    planDataSource = WorkoutPlanLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  final created = DateTime(2026, 1, 1);

  /// Entries reference a plan, so the plan row has to exist first.
  Future<void> seed(int weekday, String planId, [String? name]) async {
    await planDataSource.savePlan(
      WorkoutPlanRecord(
        planId: planId,
        name: 'Plan $planId',
        planExercises: const [],
        createdAt: created,
        updatedAt: created,
      ),
    );
    await dataSource.saveEntry(
      ScheduleEntryRecord(
        weekday: weekday,
        planId: planId,
        planName: name ?? 'Name $planId',
      ),
    );
  }

  test('empty database has no entries', () async {
    expect(await dataSource.getAllEntries(), isEmpty);
    expect(await dataSource.getEntryByWeekday(1), isNull);
  });

  test('save then get by weekday returns the entry', () async {
    await seed(3, 'p1', 'Legs');

    final loaded = await dataSource.getEntryByWeekday(3);

    expect(loaded!.weekday, 3);
    expect(loaded.planId, 'p1');
    expect(loaded.planName, 'Legs');
    expect(await dataSource.getEntryByWeekday(4), isNull);
  });

  test('getAllEntries is ordered by weekday', () async {
    await seed(5, 'a');
    await seed(1, 'b');
    await seed(7, 'c');

    final all = await dataSource.getAllEntries();

    expect(all.map((e) => e.weekday), [1, 5, 7]);
  });

  test('saving the same weekday replaces the entry', () async {
    await seed(2, 'old');
    await seed(2, 'new');

    final all = await dataSource.getAllEntries();

    expect(all, hasLength(1));
    expect(all.single.planId, 'new');
  });

  test('deleteEntry removes only that weekday', () async {
    await seed(1, 'a');
    await seed(2, 'b');

    await dataSource.deleteEntry(1);

    expect((await dataSource.getAllEntries()).map((e) => e.weekday), [2]);
  });

  test('deleteEntry on an empty weekday is a no-op', () async {
    await seed(1, 'a');

    await dataSource.deleteEntry(6);

    expect(await dataSource.getAllEntries(), hasLength(1));
  });

  test('deleting a plan removes only that plan entries', () async {
    await seed(1, 'a');
    await seed(3, 'b');
    await dataSource.saveEntry(
      const ScheduleEntryRecord(weekday: 5, planId: 'a', planName: 'Name a'),
    );

    await planDataSource.deletePlan('a');

    final all = await dataSource.getAllEntries();
    expect(all.map((e) => e.weekday), [3]);
    expect(all.single.planId, 'b');
  });

  test('replaceAssignment removes and writes days in one step', () async {
    await seed(1, 'a');
    await seed(2, 'a');

    await dataSource.replaceAssignment(
      planId: 'a',
      planName: 'Plan a',
      removedWeekdays: {1},
      savedWeekdays: {2, 4},
    );

    final all = await dataSource.getAllEntries();
    expect(all.map((e) => e.weekday), [2, 4]);
  });

  test('replaceAssignment leaves the schedule unchanged on failure', () async {
    await seed(1, 'a');

    await expectLater(
      dataSource.replaceAssignment(
        planId: 'a',
        planName: 'Plan a',
        removedWeekdays: {1},
        savedWeekdays: {9},
      ),
      throwsA(anything),
    );

    expect((await dataSource.getAllEntries()).map((e) => e.weekday), [1]);
  });

  test('an entry for a weekday outside 1-7 is rejected', () async {
    await expectLater(seed(8, 'a'), throwsA(anything));
  });
}
