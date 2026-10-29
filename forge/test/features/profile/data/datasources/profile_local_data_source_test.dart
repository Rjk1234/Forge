import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/database/app_database.dart';
import 'package:forge/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:forge/features/profile/data/models/user_profile_record.dart';

void main() {
  late AppDatabase db;
  late ProfileLocalDataSourceImpl dataSource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProfileLocalDataSourceImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  UserProfileRecord profile({String name = 'Alex', double weight = 70.5}) =>
      UserProfileRecord(
        displayName: name,
        fitnessGoal: 'Strength',
        experienceLevel: 'Beginner',
        heightCm: 180.5,
        weightKg: weight,
        createdAt: DateTime(2026, 1, 1, 8),
        updatedAt: DateTime(2026, 1, 2, 9),
      );

  test('returns null when no profile is stored', () async {
    expect(await dataSource.getProfile(), isNull);
  });

  test('save then read returns the same values', () async {
    final saved = profile();
    await dataSource.saveProfile(saved);

    final loaded = await dataSource.getProfile();

    expect(loaded, isNotNull);
    expect(loaded!.displayName, saved.displayName);
    expect(loaded.fitnessGoal, saved.fitnessGoal);
    expect(loaded.experienceLevel, saved.experienceLevel);
    expect(loaded.heightCm, saved.heightCm);
    expect(loaded.weightKg, saved.weightKg);
    expect(loaded.createdAt, saved.createdAt);
    expect(loaded.updatedAt, saved.updatedAt);
  });

  test('a second save replaces the profile and keeps a single row', () async {
    await dataSource.saveProfile(profile());
    await dataSource.saveProfile(profile(name: 'Sam', weight: 80));

    final loaded = await dataSource.getProfile();
    final rows = await db.select(db.userProfiles).get();

    expect(loaded!.displayName, 'Sam');
    expect(loaded.weightKg, 80);
    expect(rows, hasLength(1));
    expect(rows.single.id, kProfileKey);
  });
}
