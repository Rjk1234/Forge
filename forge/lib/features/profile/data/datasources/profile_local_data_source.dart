import 'package:drift/drift.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/profile/data/models/user_profile_record.dart';

abstract class ProfileLocalDataSource {
  /// Returns the stored profile, or null if not yet created.
  Future<UserProfileRecord?> getProfile();

  /// Saves (creates or replaces) the single profile record.
  Future<void> saveProfile(UserProfileRecord model);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl(this._database);

  final AppDatabase _database;

  @override
  Future<UserProfileRecord?> getProfile() async {
    final query = _database.select(_database.userProfiles)
      ..where((t) => t.id.equals(kProfileKey));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return UserProfileRecord(
      displayName: row.displayName,
      fitnessGoal: row.fitnessGoal,
      experienceLevel: row.experienceLevel,
      heightCm: row.heightCm,
      weightKg: row.weightKg,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> saveProfile(UserProfileRecord model) async {
    await _database
        .into(_database.userProfiles)
        .insertOnConflictUpdate(
          UserProfilesCompanion.insert(
            id: const Value(kProfileKey),
            displayName: model.displayName,
            fitnessGoal: model.fitnessGoal,
            experienceLevel: model.experienceLevel,
            heightCm: model.heightCm,
            weightKg: model.weightKg,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt,
          ),
        );
  }
}
