import 'package:drift/drift.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/schedule/data/models/schedule_entry_record.dart';

abstract class ScheduleLocalDataSource {
  /// All weekly schedule entries (at most one per weekday).
  Future<List<ScheduleEntryRecord>> getAllEntries();

  /// The entry for [weekday] (1 = Monday … 7 = Sunday), or null.
  Future<ScheduleEntryRecord?> getEntryByWeekday(int weekday);

  /// Creates or replaces the entry for its weekday.
  Future<void> saveEntry(ScheduleEntryRecord entry);

  /// Removes the entry for [weekday], if any.
  Future<void> deleteEntry(int weekday);

  /// Saves a plan's weekday assignment atomically: entries for
  /// [removedWeekdays] are deleted and [savedWeekdays] are written, all in
  /// one transaction so a failure leaves the schedule unchanged.
  Future<void> replaceAssignment({
    required String planId,
    required String planName,
    required Set<int> removedWeekdays,
    required Set<int> savedWeekdays,
  });
}

class ScheduleLocalDataSourceImpl implements ScheduleLocalDataSource {
  ScheduleLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<ScheduleEntryRecord>> getAllEntries() async {
    final query = _database.select(_database.scheduleEntries)
      ..orderBy([(t) => OrderingTerm.asc(t.weekday)]);
    final rows = await query.get();
    return rows.map(_toRecord).toList();
  }

  @override
  Future<ScheduleEntryRecord?> getEntryByWeekday(int weekday) async {
    final query = _database.select(_database.scheduleEntries)
      ..where((t) => t.weekday.equals(weekday));
    final row = await query.getSingleOrNull();
    return row == null ? null : _toRecord(row);
  }

  @override
  Future<void> saveEntry(ScheduleEntryRecord entry) async {
    await _database
        .into(_database.scheduleEntries)
        .insertOnConflictUpdate(
          ScheduleEntriesCompanion.insert(
            weekday: Value(entry.weekday),
            planId: entry.planId,
            planName: entry.planName,
          ),
        );
  }

  @override
  Future<void> deleteEntry(int weekday) async {
    await (_database.delete(
      _database.scheduleEntries,
    )..where((t) => t.weekday.equals(weekday))).go();
  }

  @override
  Future<void> replaceAssignment({
    required String planId,
    required String planName,
    required Set<int> removedWeekdays,
    required Set<int> savedWeekdays,
  }) {
    return _database.transaction(() async {
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
    });
  }

  ScheduleEntryRecord _toRecord(ScheduleEntryRow row) => ScheduleEntryRecord(
    weekday: row.weekday,
    planId: row.planId,
    planName: row.planName,
  );
}
