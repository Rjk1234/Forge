import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/progress/domain/entities/exercise_metrics.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/widgets/stat_tile.dart';
import 'package:forge/l10n/l10n.dart';

/// The three stat tiles for the latest session, chosen by exercise category.
class ProgressStatTiles extends StatelessWidget {
  const ProgressStatTiles({required this.exercise, super.key});

  static const double _gap = AppSpacing.smd;

  final ExerciseProgressData exercise;

  static String _count(num value) => '${value.abs().toInt()}';

  static String _duration(num value) =>
      formatDurationCompact(value.abs().toInt());

  List<StatTile> _buildTiles(AppLocalizations l10n) {
    String weight(num value) =>
        '${formatWeightValue(value.abs().toDouble())} '
        '${l10n.progressWeightUnit}';
    String volume(num value) =>
        '${formatVolume(value.abs())} ${l10n.progressWeightUnit}';

    final latest = exercise.latestMetrics;
    final delta = exercise.deltaMetrics;
    return switch ((latest, delta)) {
      (final WeightedMetrics m, final WeightedMetrics? d) => [
        _tile(
          l10n.progressTopWeight,
          weight(m.topWeight),
          d?.topWeight,
          weight,
        ),
        _tile(l10n.progressBestReps, _count(m.bestReps), d?.bestReps, _count),
        _tile(l10n.progressVolume, volume(m.volume), d?.volume, volume),
      ],
      (final TimedMetrics m, final TimedMetrics? d) => [
        _tile(
          l10n.progressBestDuration,
          _duration(m.bestDuration),
          d?.bestDuration,
          _duration,
        ),
        _tile(
          l10n.progressTotalTime,
          _duration(m.totalTime),
          d?.totalTime,
          _duration,
        ),
        _tile(l10n.progressSets, _count(m.setCount), d?.setCount, _count),
      ],
      (final BodyweightMetrics m, final BodyweightMetrics? d) => [
        _tile(
          l10n.progressTotalSets,
          _count(m.totalSets),
          d?.totalSets,
          _count,
        ),
        _tile(l10n.progressBestReps, _count(m.bestReps), d?.bestReps, _count),
        _tile(
          l10n.progressTotalReps,
          _count(m.totalReps),
          d?.totalReps,
          _count,
        ),
      ],
      _ => const [],
    };
  }

  /// A zero or missing change reads "+0" in a neutral colour.
  StatTile _tile(
    String label,
    String value,
    num? change,
    String Function(num) formatMagnitude,
  ) {
    final amount = change ?? 0;
    return StatTile(
      label: label,
      value: value,
      delta: '${amount < 0 ? '-' : '+'}${formatMagnitude(amount)}',
      trend: switch (amount) {
        > 0 => DeltaTrend.up,
        < 0 => DeltaTrend.down,
        _ => DeltaTrend.none,
      },
    );
  }

  /// Total reps (weighted only) and the whole-workout duration.
  List<StatTile> _buildExtraTiles(AppLocalizations l10n) {
    final latest = exercise.latestMetrics;
    final delta = exercise.deltaMetrics;
    return [
      if (latest is WeightedMetrics)
        _tile(
          l10n.progressTotalReps,
          _count(latest.totalReps),
          delta is WeightedMetrics ? delta.totalReps : null,
          _count,
        ),
      _tile(
        l10n.progressWorkoutDuration,
        _duration(exercise.latestWorkoutDurationSec),
        exercise.workoutDurationDeltaSec,
        _duration,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = _buildTiles(l10n);
    return Column(
      children: [
        _buildRow(tiles, columns: tiles.length),
        const SizedBox(height: _gap),
        _buildRow(_buildExtraTiles(l10n), columns: tiles.length),
      ],
    );
  }

  /// Pads with empty cells so every row keeps the same tile width.
  Widget _buildRow(List<StatTile> tiles, {required int columns}) {
    return Row(
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) const SizedBox(width: _gap),
          Expanded(child: i < tiles.length ? tiles[i] : const SizedBox()),
        ],
      ],
    );
  }
}
