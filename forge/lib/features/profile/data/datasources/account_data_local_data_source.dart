import 'package:forge/core/database/app_database.dart';

abstract class AccountDataLocalDataSource {
  /// Removes every user-owned row in one transaction.
  Future<void> clearUserData();
}

class AccountDataLocalDataSourceImpl implements AccountDataLocalDataSource {
  AccountDataLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> clearUserData() {
    return _database.transaction(() async {
      // Children first, so the delete order never depends on cascades.
      await _database.delete(_database.actualSets).go();
      await _database.delete(_database.sessionExercises).go();
      await _database.delete(_database.workoutSessions).go();
      await _database.delete(_database.scheduleEntries).go();
      await _database.delete(_database.planExercises).go();
      await _database.delete(_database.workoutPlans).go();
      await _database.delete(_database.userProfiles).go();
    });
  }
}
