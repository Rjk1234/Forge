import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/presentation/widgets/set_pill.dart';
import 'package:forge/l10n/l10n.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

void main() {
  group('SetPill.labelFor', () {
    test('weighted shows reps×weight', () {
      expect(
        SetPill.labelFor(
          const ActualSet(repetitions: 8, weight: 60),
          ExerciseType.weighted,
          l10n,
        ),
        '8×60kg',
      );
    });

    test('weighted shows a dash when the weight is missing', () {
      expect(
        SetPill.labelFor(
          const ActualSet(repetitions: 8),
          ExerciseType.weighted,
          l10n,
        ),
        '8×—kg',
      );
    });

    test('weighted keeps a fractional weight', () {
      expect(
        SetPill.labelFor(
          const ActualSet(repetitions: 10, weight: 12.5),
          ExerciseType.weighted,
          l10n,
        ),
        '10×12.5kg',
      );
    });

    test('bodyweight shows reps', () {
      expect(
        SetPill.labelFor(
          const ActualSet(repetitions: 15),
          ExerciseType.bodyweight,
          l10n,
        ),
        '15 reps',
      );
    });

    test('time-based shows MM:SS', () {
      expect(
        SetPill.labelFor(
          const ActualSet(durationSec: 45),
          ExerciseType.timeBased,
          l10n,
        ),
        '00:45',
      );
    });

    test('skipped overrides the type format', () {
      expect(
        SetPill.labelFor(
          const ActualSet(skipped: true),
          ExerciseType.weighted,
          l10n,
        ),
        'Skipped',
      );
    });
  });

  testWidgets('skipped pill is struck through', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SetPill(
            set: ActualSet(skipped: true),
            exerciseType: ExerciseType.weighted,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Skipped'));
    expect(text.style?.decoration, TextDecoration.lineThrough);
  });
}
