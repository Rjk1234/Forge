import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/stats/domain/entities/stats_data.dart';
import 'package:forge/features/stats/presentation/widgets/stats_metric_tile.dart';
import 'package:forge/l10n/l10n.dart';

/// The 2×2 grid of aggregate statistics.
class StatsTileGrid extends StatelessWidget {
  const StatsTileGrid({required this.stats, super.key});

  static const double _gap = AppSpacing.smd;
  static const int _secondsPerMinute = 60;
  static const int _minutesPerHour = 60;

  final StatsData stats;

  static String _hoursMinutes(AppLocalizations l10n, int seconds) =>
      l10n.durationHoursMinutes(seconds ~/ 3600, (seconds % 3600) ~/ 60);

  /// "45 s" under a minute, "42 min" under an hour, "1h 5m" from an hour.
  static String _durationText(AppLocalizations l10n, int seconds) {
    if (seconds < _secondsPerMinute) return '$seconds ${l10n.statsSecondsUnit}';
    final minutes = seconds ~/ _secondsPerMinute;
    return minutes < _minutesPerHour
        ? '$minutes ${l10n.statsMinutesUnit}'
        : _hoursMinutes(l10n, seconds);
  }

  bool get _isEmpty => stats.totalWorkoutsCompleted == 0;

  String _volumeText(AppLocalizations l10n) =>
      '${formatVolume(stats.totalVolumeKg)} ${l10n.statsVolumeUnit}';

  String _averageText(AppLocalizations l10n) {
    final average = stats.avgDurationSec;
    return average == null
        ? l10n.statsNotAvailable
        : _durationText(l10n, average);
  }

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatsMetricTile(
        icon: Icons.check,
        value: '${stats.totalWorkoutsCompleted}',
        label: context.l10n.statsWorkoutsCompleted,
        isDimmed: _isEmpty,
      ),
      StatsMetricTile(
        icon: Icons.fitness_center,
        value: _volumeText(context.l10n),
        label: context.l10n.statsTotalVolume,
        isDimmed: _isEmpty,
      ),
      StatsMetricTile(
        icon: Icons.schedule,
        value: _durationText(context.l10n, stats.totalDurationSec),
        label: context.l10n.statsTotalDuration,
        isDimmed: _isEmpty,
      ),
      StatsMetricTile(
        icon: Icons.trending_up,
        value: _averageText(context.l10n),
        label: context.l10n.statsAvgDuration,
        isDimmed: _isEmpty,
      ),
    ];

    return Column(
      children: [
        _buildRow(tiles[0], tiles[1]),
        const SizedBox(height: _gap),
        _buildRow(tiles[2], tiles[3]),
      ],
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: _gap),
          Expanded(child: right),
        ],
      ),
    );
  }
}
