import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/theme/app_theme.dart';
import 'package:forge/features/workout_plan/domain/entities/plan_exercise.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_exercise_detail_card.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';

Widget _wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

PlanExercise _weighted({
  String name = 'Bench Press',
  int sets = 4,
  int reps = 8,
  double weight = 60.0,
  int rest = 90,
}) => PlanExercise(
  exerciseId: 'ex-w',
  exerciseName: name,
  type: ExerciseType.weighted,
  targetSets: sets,
  restPeriodSec: rest,
  targetRepetitions: reps,
  targetWeight: weight,
);

PlanExercise _timeBased({
  String name = 'Plank',
  int sets = 3,
  int durationSec = 75,
  int rest = 60,
}) => PlanExercise(
  exerciseId: 'ex-t',
  exerciseName: name,
  type: ExerciseType.timeBased,
  targetSets: sets,
  restPeriodSec: rest,
  targetDurationSec: durationSec,
);

PlanExercise _bodyweight({
  String name = 'Push-ups',
  int sets = 3,
  int reps = 15,
  int rest = 45,
}) => PlanExercise(
  exerciseId: 'ex-b',
  exerciseName: name,
  type: ExerciseType.bodyweight,
  targetSets: sets,
  restPeriodSec: rest,
  targetRepetitions: reps,
);

void main() {
  group('PlanExerciseDetailCard', () {
    group('weighted exercise', () {
      testWidgets('shows exercise name and Weighted badge', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _weighted())),
        );
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text(l10n.exerciseTypeBadgeWeighted), findsOneWidget);
      });

      testWidgets('shows Sets, Reps, Weight field boxes in first row', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(
            PlanExerciseDetailCard(
              exercise: _weighted(sets: 4, reps: 8, weight: 60),
            ),
          ),
        );
        expect(find.text(l10n.setsLabel), findsOneWidget);
        expect(find.text(l10n.repsLabel), findsOneWidget);
        expect(find.text(l10n.planDetailWeightLabel), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.text('60 kg'), findsOneWidget);
      });

      testWidgets('shows Rest in a separate full-width row', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _weighted(rest: 90))),
        );
        expect(find.text(l10n.planDetailRestLabel), findsOneWidget);
        expect(find.text('90s'), findsOneWidget);
      });

      testWidgets('formats decimal weight with one decimal place', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _weighted(weight: 62.5))),
        );
        expect(find.text('62.5 kg'), findsOneWidget);
      });

      testWidgets('no TextEditingController — all fields are read-only', (
        tester,
      ) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _weighted())),
        );
        expect(find.byType(TextField), findsNothing);
        expect(find.byType(EditableText), findsNothing);
      });
    });

    group('time-based exercise', () {
      testWidgets('shows exercise name and Time-Based badge', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _timeBased())),
        );
        expect(find.text('Plank'), findsOneWidget);
        expect(find.text(l10n.exerciseTypeBadgeTimeBased), findsOneWidget);
      });

      testWidgets('shows Sets, Duration, Rest in a single row', (tester) async {
        await tester.pumpWidget(
          _wrap(
            PlanExerciseDetailCard(
              exercise: _timeBased(sets: 3, durationSec: 75, rest: 60),
            ),
          ),
        );
        expect(find.text(l10n.setsLabel), findsOneWidget);
        expect(find.text(l10n.durationLabel), findsOneWidget);
        expect(find.text(l10n.planDetailRestLabel), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('01:15'), findsOneWidget);
        expect(find.text('60s'), findsOneWidget);
      });

      testWidgets('formats 0 seconds as 00:00', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _timeBased(durationSec: 0))),
        );
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('formats 90 seconds as 01:30', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _timeBased(durationSec: 90))),
        );
        expect(find.text('01:30'), findsOneWidget);
      });

      testWidgets('no Weight field box', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _timeBased())),
        );
        expect(find.text(l10n.planDetailWeightLabel), findsNothing);
      });
    });

    group('bodyweight exercise', () {
      testWidgets('shows exercise name and Bodyweight badge', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _bodyweight())),
        );
        expect(find.text('Push-ups'), findsOneWidget);
        expect(find.text(l10n.exerciseTypeBadgeBodyweight), findsOneWidget);
      });

      testWidgets('shows Sets, Reps, Rest in a single row', (tester) async {
        await tester.pumpWidget(
          _wrap(
            PlanExerciseDetailCard(
              exercise: _bodyweight(sets: 3, reps: 15, rest: 45),
            ),
          ),
        );
        expect(find.text(l10n.setsLabel), findsOneWidget);
        expect(find.text(l10n.repsLabel), findsOneWidget);
        expect(find.text(l10n.planDetailRestLabel), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('15'), findsOneWidget);
        expect(find.text('45s'), findsOneWidget);
      });

      testWidgets('no Weight field box', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _bodyweight())),
        );
        expect(find.text(l10n.planDetailWeightLabel), findsNothing);
      });

      testWidgets('no Duration field box', (tester) async {
        await tester.pumpWidget(
          _wrap(PlanExerciseDetailCard(exercise: _bodyweight())),
        );
        expect(find.text(l10n.durationLabel), findsNothing);
      });
    });

    group('unavailable exercise', () {
      testWidgets('shows placeholder name when exerciseName is empty', (
        tester,
      ) async {
        const ex = PlanExercise(
          exerciseId: 'ex-gone',
          exerciseName: '',
          type: ExerciseType.bodyweight,
          targetSets: 2,
          restPeriodSec: 30,
          targetRepetitions: 10,
        );
        await tester.pumpWidget(
          _wrap(const PlanExerciseDetailCard(exercise: ex)),
        );
        expect(find.text(l10n.exerciseUnavailableName), findsOneWidget);
      });

      testWidgets(
        'shows placeholder name when exerciseName is whitespace only',
        (tester) async {
          const ex = PlanExercise(
            exerciseId: 'ex-gone',
            exerciseName: '   ',
            type: ExerciseType.weighted,
            targetSets: 3,
            restPeriodSec: 60,
            targetRepetitions: 5,
            targetWeight: 40.0,
          );
          await tester.pumpWidget(
            _wrap(const PlanExerciseDetailCard(exercise: ex)),
          );
          expect(find.text(l10n.exerciseUnavailableName), findsOneWidget);
        },
      );
    });
  });
}
