import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/workout_plan.dart';
import 'package:forge/features/workout_session/presentation/widgets/up_next_card.dart';
import 'package:forge/l10n/l10n.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

const _weighted = PlanExercise(
  exerciseId: 'a',
  exerciseName: 'Barbell Bench Press',
  type: ExerciseType.weighted,
  targetSets: 4,
  restPeriodSec: 60,
  targetRepetitions: 8,
  targetWeight: 60,
);

void main() {
  group('UpNextCard.targetText', () {
    test('weighted shows reps and whole-number weight', () {
      expect(UpNextCard.targetText(_weighted, l10n), 'Target: 8 reps · 60 kg');
    });

    test('weighted keeps a fractional weight', () {
      const fractional = PlanExercise(
        exerciseId: 'a',
        exerciseName: 'Curl',
        type: ExerciseType.weighted,
        targetSets: 3,
        restPeriodSec: 60,
        targetRepetitions: 10,
        targetWeight: 12.5,
      );
      expect(
        UpNextCard.targetText(fractional, l10n),
        'Target: 10 reps · 12.5 kg',
      );
    });

    test('bodyweight omits the weight segment', () {
      const bodyweight = PlanExercise(
        exerciseId: 'b',
        exerciseName: 'Push-Up',
        type: ExerciseType.bodyweight,
        targetSets: 2,
        restPeriodSec: 60,
        targetRepetitions: 15,
      );
      expect(UpNextCard.targetText(bodyweight, l10n), 'Target: 15 reps');
    });

    test('time-based shows seconds', () {
      const timeBased = PlanExercise(
        exerciseId: 'c',
        exerciseName: 'Plank',
        type: ExerciseType.timeBased,
        targetSets: 2,
        restPeriodSec: 30,
        targetDurationSec: 45,
      );
      expect(UpNextCard.targetText(timeBased, l10n), 'Target: 45s');
    });
  });

  testWidgets('renders label, exercise with set position and target', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: UpNextCard(exercise: _weighted, setNumber: 3)),
      ),
    );

    expect(find.text('UP NEXT'), findsOneWidget);
    expect(find.text('Barbell Bench Press — Set 3 of 4'), findsOneWidget);
    expect(find.text('Target: 8 reps · 60 kg'), findsOneWidget);
  });
}
