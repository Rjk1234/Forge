import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/presentation/widgets/pre_start_loaded_view.dart';
import 'package:forge/features/workout_session/presentation/screens/active_workout_screen.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

final _plan = WorkoutPlanDetail(
  id: 'p1',
  name: 'Push Day',
  createdAt: DateTime(2026, 9),
  exercises: const [
    PlanExercise(
      exerciseId: 'bench',
      exerciseName: 'Bench',
      type: ExerciseType.weighted,
      targetSets: 3,
      restPeriodSec: 60,
      targetRepetitions: 8,
      targetWeight: 60,
    ),
  ],
);

Widget _host({required bool isCompletedToday}) => MaterialApp.router(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => PreStartLoadedView(
          plan: _plan,
          scheduledWeekday: null,
          isScheduledForToday: false,
          planId: 'p1',
          isCompletedToday: isCompletedToday,
        ),
      ),
      GoRoute(
        path: ActiveWorkoutScreen.routePath,
        builder: (_, _) => const Scaffold(body: Text('active workout')),
      ),
    ],
  ),
);

void main() {
  testWidgets('a plan not done today starts straight away', (tester) async {
    await tester.pumpWidget(_host(isCompletedToday: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin Workout'));
    await tester.pumpAndSettle();

    expect(find.text('Already done today'), findsNothing);
    expect(find.text('active workout'), findsOneWidget);
  });

  testWidgets('a plan done today asks first and Go back stays put', (
    tester,
  ) async {
    await tester.pumpWidget(_host(isCompletedToday: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin Workout'));
    await tester.pumpAndSettle();
    expect(find.text('Already done today'), findsOneWidget);
    expect(find.textContaining('Push Day today'), findsOneWidget);

    await tester.tap(find.text('Go back'));
    await tester.pumpAndSettle();

    expect(find.text('active workout'), findsNothing);
    expect(find.text('Begin Workout'), findsOneWidget);
  });

  testWidgets('Start anyway opens a new workout', (tester) async {
    await tester.pumpWidget(_host(isCompletedToday: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin Workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start anyway'));
    await tester.pumpAndSettle();

    expect(find.text('active workout'), findsOneWidget);
  });
}
