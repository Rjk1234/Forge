import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/entities/session_exercise.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/widgets/history_card.dart';
import 'package:forge/l10n/l10n.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

WorkoutSession _session({
  DateTime? startedAt,
  int durationSec = 2280,
  List<SessionExercise>? exercises,
}) => WorkoutSession(
  sessionId: 's',
  planId: 'p',
  planName: 'Push Day — Upper Body',
  completedAt: DateTime(2026, 9, 7, 19),
  startedAt: startedAt ?? DateTime(2026, 9, 7, 18),
  sessionDurationSec: durationSec,
  sessionExercises:
      exercises ??
      const [
        SessionExercise(
          exerciseId: 'a',
          exerciseName: 'Bench',
          type: ExerciseType.bodyweight,
          actualSets: [
            ActualSet(repetitions: 8),
            ActualSet(repetitions: 8),
            ActualSet(skipped: true),
          ],
        ),
        SessionExercise(
          exerciseId: 'b',
          exerciseName: 'Row',
          type: ExerciseType.bodyweight,
          actualSets: [ActualSet(repetitions: 10)],
        ),
      ],
);

void main() {
  test('summary counts minutes, exercises and non-skipped sets', () {
    expect(
      HistoryCard.summaryLineFor(_session(), l10n),
      '38 min · 2 exercises · 3 sets',
    );
  });

  test('summary uses singular units', () {
    final session = _session(
      exercises: const [
        SessionExercise(
          exerciseId: 'a',
          exerciseName: 'Plank',
          type: ExerciseType.timeBased,
          actualSets: [ActualSet(durationSec: 30)],
        ),
      ],
    );
    expect(
      HistoryCard.summaryLineFor(session, l10n),
      '38 min · 1 exercise · 1 set',
    );
  });

  testWidgets('fromSession shows zero-padded day, uppercase weekday, name', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: HistoryCard.fromSession(
            session: _session(),
            l10n: l10n,
            onTap: () => taps++,
          ),
        ),
      ),
    );

    expect(find.text('07'), findsOneWidget);
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('Push Day — Upper Body'), findsOneWidget);

    await tester.tap(find.byType(HistoryCard));
    expect(taps, 1);
  });
}
