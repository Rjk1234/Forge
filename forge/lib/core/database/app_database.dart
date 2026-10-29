import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:forge/core/database/tables/actual_sets.dart';
import 'package:forge/core/database/tables/exercises.dart';
import 'package:forge/core/database/tables/plan_exercises.dart';
import 'package:forge/core/database/tables/schedule_entries.dart';
import 'package:forge/core/database/tables/session_exercises.dart';
import 'package:forge/core/database/tables/user_profiles.dart';
import 'package:forge/core/database/tables/workout_plans.dart';
import 'package:forge/core/database/tables/workout_sessions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Name of the SQLite file inside the application documents directory.
const String kDatabaseFileName = 'forge.sqlite';

/// Key of the single row in the profile table.
const int kProfileKey = 0;

@DriftDatabase(
  tables: [
    UserProfiles,
    Exercises,
    WorkoutPlans,
    PlanExercises,
    ScheduleEntries,
    WorkoutSessions,
    SessionExercises,
    ActualSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openOnDevice());

  /// In-memory or custom executor, used by tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openOnDevice() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, kDatabaseFileName));
    return NativeDatabase.createInBackground(file);
  });
}
