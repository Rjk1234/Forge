import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/widgets/progress_chart_painter.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Trend chart of the selected exercise's best value per session.
class ProgressChartCard extends StatelessWidget {
  const ProgressChartCard({required this.exercise, super.key});

  static const double _radius = AppRadius.sheet;
  static const double _padding = AppSpacing.lg;
  static const double _gap = AppSpacing.smd;
  static const double _chartHeight = 150;

  final ExerciseProgressData exercise;

  List<ProgressDataPoint> get _points => exercise.sessionDataPoints;

  String _metricName(AppLocalizations l10n) => switch (exercise.type) {
    ExerciseType.weighted => l10n.progressChartWeight,
    ExerciseType.timeBased => l10n.progressChartDuration,
    ExerciseType.bodyweight => l10n.progressChartReps,
  };

  String _formatValue(double value, AppLocalizations l10n) =>
      switch (exercise.type) {
        ExerciseType.weighted =>
          '${formatWeightValue(value)}${l10n.progressWeightUnit}',
        ExerciseType.timeBased => formatDurationCompact(value.round()),
        ExerciseType.bodyweight => '${value.round()}',
      };

  String _formatChange(double change, AppLocalizations l10n) =>
      switch (exercise.type) {
        ExerciseType.weighted =>
          '${formatWeightValue(change.abs())} ${l10n.progressWeightUnit}',
        ExerciseType.timeBased => formatDurationCompact(change.abs().round()),
        ExerciseType.bodyweight =>
          '${change.abs().round()} ${l10n.progressRepsUnit}',
      };

  /// Latest value minus the one before it; null with fewer than two sessions.
  double? get _changeVsPrevious {
    if (_points.length < 2) return null;
    final change =
        _points.last.metricValue - _points[_points.length - 2].metricValue;
    return change == 0 ? null : change;
  }

  /// e.g. "▲ 8 kg vs previous session"; null when there is no change.
  String? _trendText(double? change, AppLocalizations l10n) {
    if (change == null) return null;
    final formatted = _formatChange(change, l10n);
    return change > 0
        ? l10n.progressTrendRising(formatted)
        : l10n.progressTrendFalling(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: _gap),
          _buildChart(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final change = _changeVsPrevious;
    final trend = _trendText(change, context.l10n);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            context.l10n.progressChartTitle(
              exercise.exerciseName,
              _metricName(context.l10n),
            ),
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (trend != null)
          Text(
            trend,
            style: textStyles.captionStrong.copyWith(
              color: change! > 0 ? colorScheme.primary : colorScheme.error,
            ),
          ),
      ],
    );
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      height: _chartHeight,
      child: LayoutBuilder(
        builder: (context, constraints) => CustomPaint(
          size: Size(constraints.maxWidth, _chartHeight),
          painter: ProgressChartPainter(
            points: _points,
            formatYLabel: (value) => _formatValue(value, context.l10n),
            formatXLabel: formatMonthDay,
            labelStyle: textTheme.labelSmall,
            gridColor: colorScheme.outline,
            lineColor: colorScheme.primary,
            dotRingColor: colorScheme.surface,
            latestDotColor: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
