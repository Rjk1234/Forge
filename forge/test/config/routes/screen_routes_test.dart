import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/exercise/presentation/screens/exercise_catalogue_screen.dart';
import 'package:forge/features/personal_bests/presentation/screens/personal_bests_screen.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_session/presentation/screens/workout_history_detail_screen.dart';

void main() {
  test('nested screen routes are composed from their parent route', () {
    expect(WorkoutPlansScreen.routePath, '/plans');
    expect(PlanDetailScreen.routePath, '/plans/:planId');
    expect(CreateEditWorkoutPlanScreen.createRoutePath, '/plans/create');
    expect(CreateEditWorkoutPlanScreen.editRoutePath, '/plans/:planId/edit');
    expect(ExerciseCatalogueScreen.routePath, '/plans/exercises');
    expect(AssignScheduleScreen.routePath, '/plans/:planId/schedule');
    expect(WorkoutPreStartScreen.routePath, '/plans/:planId/start');
    expect(WorkoutHistoryDetailScreen.routePath, '/history/detail');
    expect(PersonalBestsScreen.routePath, '/stats/personal-bests');
  });

  test('every path parameter in a route path uses the shared key', () {
    for (final path in [
      PlanDetailScreen.routePath,
      CreateEditWorkoutPlanScreen.editRoutePath,
      AssignScheduleScreen.routePath,
      WorkoutPreStartScreen.routePath,
    ]) {
      expect(path, contains(':${PlanDetailScreen.planIdParam}'));
    }
  });
}
