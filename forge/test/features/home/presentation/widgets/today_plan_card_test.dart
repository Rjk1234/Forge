import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/home/domain/entities/today_workout.dart';
import 'package:forge/features/home/presentation/widgets/today_plan_card.dart';
import 'package:forge/l10n/l10n.dart';

Widget _host({required bool isCompletedToday, required VoidCallback onStart}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: TodayPlanCard(
            workout: TodayWorkout(
              planId: 'p1',
              planName: 'Push Day',
              exerciseCount: 0,
              dominantType: ExerciseType.weighted,
              estimatedMinutes: 40,
              isCompletedToday: isCompletedToday,
            ),
            onStart: onStart,
          ),
        ),
      ),
    );

void main() {
  testWidgets('a pending workout offers the filled Start button', (
    tester,
  ) async {
    await tester.pumpWidget(_host(isCompletedToday: false, onStart: () {}));

    expect(find.text("Start today's workout"), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.text('Do it again'), findsNothing);
    expect(find.text('PLANNED FOR TODAY · ~40 MIN'), findsOneWidget);
  });

  testWidgets('a finished workout shows Done today and a quieter Do it again', (
    tester,
  ) async {
    var started = 0;
    await tester.pumpWidget(
      _host(isCompletedToday: true, onStart: () => started++),
    );

    expect(find.text('DONE TODAY'), findsOneWidget);
    expect(find.text("Start today's workout"), findsNothing);
    expect(find.byType(FilledButton), findsNothing);

    await tester.tap(find.text('Do it again'));
    expect(started, 1);
  });
}
