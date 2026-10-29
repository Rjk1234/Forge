import 'package:drift/drift.dart';

/// Single-row table holding the local user's profile (id is always 0).
@DataClassName('UserProfileRow')
class UserProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get displayName => text()();
  TextColumn get fitnessGoal => text()();
  TextColumn get experienceLevel => text()();
  RealColumn get heightCm => real()();
  RealColumn get weightKg => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
