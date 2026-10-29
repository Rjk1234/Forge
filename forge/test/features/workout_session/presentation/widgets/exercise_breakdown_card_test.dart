import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/presentation/widgets/exercise_breakdown_card.dart';
import 'package:forge/l10n/l10n.dart';

Widget _host(SessionExercise exercise) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: ExerciseBreakdownCard(exercise: exercise)),
);

void main() {
  testWidgets('the set count excludes skipped sets', (tester) async {
    await tester.pumpWidget(
      _host(
        const SessionExercise(
          exerciseId: 'bench',
          exerciseName: 'Bench Press',
          type: ExerciseType.weighted,
          actualSets: [
            ActualSet(repetitions: 8, weight: 60),
            ActualSet(skipped: true),
            ActualSet(skipped: true),
          ],
        ),
      ),
    );

    expect(find.text('1 set'), findsOneWidget);
    expect(find.text('3 sets'), findsNothing);
  });
}
