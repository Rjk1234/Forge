import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/widgets/exercise_chip.dart';
import 'package:forge/features/progress/presentation/widgets/progress_chart_card.dart';
import 'package:forge/features/progress/presentation/widgets/progress_stat_tiles.dart';
import 'package:forge/features/progress/presentation/widgets/stat_tile.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: AppTheme.darkTheme,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

ExerciseProgressData _data({
  required ExerciseType type,
  required ExerciseMetrics latest,
  ExerciseMetrics? delta,
  List<double> values = const [55, 60, 65],
  int workoutSec = 0,
  int? workoutDeltaSec,
}) => ExerciseProgressData(
  exerciseName: 'Bench Press',
  type: type,
  totalValidSessions: values.length,
  sessionDataPoints: [
    for (var i = 0; i < values.length; i++)
      ProgressDataPoint(
        sessionIndex: i + 1,
        metricValue: values[i],
        date: DateTime(2026, 7, 28).add(Duration(days: 20 * i)),
        isLatest: i == values.length - 1,
      ),
  ],
  latestMetrics: latest,
  latestWorkoutDurationSec: workoutSec,
  workoutDurationDeltaSec: workoutDeltaSec,
  deltaMetrics: delta,
);

void main() {
  group('ProgressStatTiles', () {
    testWidgets('weighted shows value and signed deltas', (tester) async {
      await tester.pumpWidget(
        _host(
          ProgressStatTiles(
            exercise: _data(
              type: ExerciseType.weighted,
              latest: const WeightedMetrics(
                topWeight: 65,
                bestReps: 8,
                totalReps: 8,
                volume: 1820,
              ),
              delta: const WeightedMetrics(
                topWeight: 5,
                bestReps: -1,
                totalReps: -3,
                volume: 140,
              ),
            ),
          ),
        ),
      );

      expect(find.text('TOP WEIGHT'), findsOneWidget);
      expect(find.text('65 kg'), findsOneWidget);
      expect(find.text('+5 kg'), findsOneWidget);
      expect(find.text('1,820 kg'), findsOneWidget);
      expect(find.text('+140 kg'), findsOneWidget);
      expect(find.text('-1'), findsOneWidget);
      expect(find.text('TOTAL REPS'), findsOneWidget);
      expect(find.text('-3'), findsOneWidget);
    });

    testWidgets('the workout time tile shows duration and its change', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ProgressStatTiles(
            exercise: _data(
              type: ExerciseType.bodyweight,
              latest: const BodyweightMetrics(
                totalSets: 3,
                bestReps: 10,
                totalReps: 30,
              ),
              delta: const BodyweightMetrics(
                totalSets: 1,
                bestReps: 2,
                totalReps: 5,
              ),
              workoutSec: 2700,
              workoutDeltaSec: -300,
            ),
          ),
        ),
      );

      expect(find.text('WORKOUT TIME'), findsOneWidget);
      expect(find.text('45:00'), findsOneWidget);
      expect(find.text('-5:00'), findsOneWidget);
    });

    testWidgets('an unchanged metric is neutral, not lime', (tester) async {
      await tester.pumpWidget(
        _host(
          const StatTile(
            label: 'a',
            value: '1',
            delta: '+0',
            trend: DeltaTrend.none,
          ),
        ),
      );

      final color = tester.widget<Text>(find.text('+0')).style!.color!;
      final scheme = Theme.of(
        tester.element(find.byType(StatTile)),
      ).colorScheme;
      expect(color, scheme.onSurfaceVariant);
    });

    testWidgets('time-based uses durations and SETS', (tester) async {
      await tester.pumpWidget(
        _host(
          ProgressStatTiles(
            exercise: _data(
              type: ExerciseType.timeBased,
              latest: const TimedMetrics(
                bestDuration: 60,
                totalTime: 135,
                setCount: 3,
              ),
              delta: const TimedMetrics(
                bestDuration: 15,
                totalTime: 0,
                setCount: 0,
              ),
            ),
          ),
        ),
      );

      expect(find.text('BEST DURATION'), findsOneWidget);
      expect(find.text('1:00'), findsOneWidget);
      expect(find.text('2:15'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('+0:15'), findsOneWidget);
      expect(find.text('+0'), findsOneWidget);
    });

    testWidgets('bodyweight uses TOTAL SETS, BEST REPS, TOTAL REPS', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          ProgressStatTiles(
            exercise: _data(
              type: ExerciseType.bodyweight,
              latest: const BodyweightMetrics(
                totalSets: 3,
                bestReps: 15,
                totalReps: 41,
              ),
              delta: const BodyweightMetrics(
                totalSets: 0,
                bestReps: 1,
                totalReps: 4,
              ),
            ),
          ),
        ),
      );

      expect(find.text('TOTAL SETS'), findsOneWidget);
      expect(find.text('BEST REPS'), findsOneWidget);
      expect(find.text('TOTAL REPS'), findsOneWidget);
      expect(find.text('41'), findsOneWidget);
    });

    testWidgets('negative deltas use the danger color, others lime', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: [
              StatTile(
                label: 'a',
                value: '1',
                delta: '-1',
                trend: DeltaTrend.down,
              ),
              StatTile(
                label: 'b',
                value: '1',
                delta: '+1',
                trend: DeltaTrend.up,
              ),
            ],
          ),
        ),
      );

      Color colorOf(String text) =>
          tester.widget<Text>(find.text(text)).style!.color!;
      expect(colorOf('-1'), isNot(colorOf('+1')));
    });
  });

  group('ProgressChartCard', () {
    testWidgets('shows the title and rising trend text', (tester) async {
      await tester.pumpWidget(
        _host(
          ProgressChartCard(
            exercise: _data(
              type: ExerciseType.weighted,
              latest: const WeightedMetrics(
                topWeight: 65,
                bestReps: 8,
                totalReps: 8,
                volume: 1,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Bench Press — Weight'), findsOneWidget);
      expect(find.text('▲ 5 kg vs previous session'), findsOneWidget);
    });

    testWidgets('falling values show the down arrow', (tester) async {
      await tester.pumpWidget(
        _host(
          ProgressChartCard(
            exercise: _data(
              type: ExerciseType.bodyweight,
              latest: const BodyweightMetrics(
                totalSets: 1,
                bestReps: 1,
                totalReps: 1,
              ),
              values: const [15, 12],
            ),
          ),
        ),
      );

      expect(find.text('Bench Press — Reps'), findsOneWidget);
      expect(find.text('▼ 3 reps vs previous session'), findsOneWidget);
    });

    testWidgets('no net change hides the trend text', (tester) async {
      await tester.pumpWidget(
        _host(
          ProgressChartCard(
            exercise: _data(
              type: ExerciseType.weighted,
              latest: const WeightedMetrics(
                topWeight: 60,
                bestReps: 8,
                totalReps: 8,
                volume: 1,
              ),
              values: const [60, 60],
            ),
          ),
        ),
      );

      expect(find.textContaining('over'), findsNothing);
    });
  });

  group('ExerciseChip', () {
    testWidgets('long names are ellipsised and tappable', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          ExerciseChip(
            exerciseName: 'A very long exercise name ' * 6,
            isSelected: false,
            onTap: () => taps++,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.maxLines, 1);

      await tester.tap(find.byType(ExerciseChip));
      expect(taps, 1);
    });
  });
}
