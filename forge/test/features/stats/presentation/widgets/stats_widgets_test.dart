import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/stats/domain/entities/exercise_stat_row.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';
import 'package:forge/features/stats/presentation/widgets/exercise_stat_card.dart';
import 'package:forge/features/stats/presentation/widgets/stats_empty_state.dart';
import 'package:forge/features/stats/presentation/widgets/stats_tile_grid.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('StatsTileGrid', () {
    testWidgets('populated values are formatted', (tester) async {
      await tester.pumpWidget(
        _host(
          const StatsTileGrid(
            stats: StatsData(
              totalWorkoutsCompleted: 27,
              totalVolumeKg: 48320,
              totalDurationSec: 17 * 3600 + 24 * 60,
              avgDurationSec: 42 * 60,
            ),
          ),
        ),
      );

      expect(find.text('27'), findsOneWidget);
      expect(find.text('48,320 kg'), findsOneWidget);
      expect(find.text('17h 24m'), findsOneWidget);
      expect(find.text('42 min'), findsOneWidget);
    });

    testWidgets('an average of an hour or more uses hours and minutes', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StatsTileGrid(
            stats: StatsData(
              totalWorkoutsCompleted: 1,
              totalVolumeKg: 0,
              totalDurationSec: 3900,
              avgDurationSec: 3900,
            ),
          ),
        ),
      );

      expect(find.text('1h 5m'), findsNWidgets(2));
    });

    testWidgets('a sub-minute average is shown in seconds', (tester) async {
      await tester.pumpWidget(
        _host(
          const StatsTileGrid(
            stats: StatsData(
              totalWorkoutsCompleted: 1,
              totalVolumeKg: 10,
              totalDurationSec: 45,
              avgDurationSec: 45,
            ),
          ),
        ),
      );

      expect(find.text('45 s'), findsNWidgets(2));
    });

    testWidgets('empty state shows placeholders and dims the tiles', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const StatsTileGrid(
            stats: StatsData(
              totalWorkoutsCompleted: 0,
              totalVolumeKg: 0,
              totalDurationSec: 0,
              avgDurationSec: null,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
      expect(find.text('0 kg'), findsOneWidget);
      expect(find.text('0 s'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      final opacities = tester.widgetList<Opacity>(find.byType(Opacity));
      expect(opacities.every((o) => o.opacity == 0.55), isTrue);
    });
  });

  group('ExerciseStatCard', () {
    ExerciseStatRow row(ExerciseType type) => ExerciseStatRow(
      exerciseName: 'Thing',
      type: type,
      sessionCount: 18,
      bestWeight: 65,
      bestReps: 12,
      bestDurationSec: 70,
    );

    testWidgets('weighted shows best weight', (tester) async {
      await tester.pumpWidget(
        _host(ExerciseStatCard(row: row(ExerciseType.weighted))),
      );
      expect(find.text('18 sessions'), findsOneWidget);
      expect(find.text('65 kg'), findsOneWidget);
      expect(find.text('Best weight'), findsOneWidget);
    });

    testWidgets('time-based shows MM:SS best time', (tester) async {
      await tester.pumpWidget(
        _host(ExerciseStatCard(row: row(ExerciseType.timeBased))),
      );
      expect(find.text('01:10'), findsOneWidget);
      expect(find.text('Best time'), findsOneWidget);
    });

    testWidgets('bodyweight shows best reps', (tester) async {
      await tester.pumpWidget(
        _host(ExerciseStatCard(row: row(ExerciseType.bodyweight))),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Best reps'), findsOneWidget);
    });

    testWidgets('one session is singular and long names are ellipsised', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ExerciseStatCard(
            row: ExerciseStatRow(
              exerciseName: 'Very long name ' * 10,
              type: ExerciseType.weighted,
              sessionCount: 1,
              bestWeight: 62.5,
              bestReps: 0,
              bestDurationSec: 0,
            ),
          ),
        ),
      );

      expect(find.text('1 session'), findsOneWidget);
      expect(find.text('62.5 kg'), findsOneWidget);
      final name = tester.widget<Text>(find.textContaining('Very long'));
      expect(name.overflow, TextOverflow.ellipsis);
      expect(name.maxLines, 1);
    });
  });

  testWidgets('StatsEmptyState CTA meets the touch target and fires', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _host(StatsEmptyState(onStartWorkout: () => taps++)),
    );

    expect(find.text('No stats yet'), findsOneWidget);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(44),
    );

    await tester.tap(find.text('Start a Workout'));
    expect(taps, 1);
  });
}
