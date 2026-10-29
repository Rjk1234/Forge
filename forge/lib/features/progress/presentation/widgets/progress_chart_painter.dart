import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';

/// Draws grid lines, axis labels, the trend line and session dots.
class ProgressChartPainter extends CustomPainter {
  const ProgressChartPainter({
    required this.points,
    required this.formatYLabel,
    required this.formatXLabel,
    required this.labelStyle,
    required this.gridColor,
    required this.lineColor,
    required this.dotRingColor,
    required this.latestDotColor,
  });

  static const double _gutterWidth = 36;
  static const double _plotTop = 20;
  static const double _plotBottomInset = 30;
  static const double _xLabelBottomInset = 4;
  static const double _sidePadding = AppSpacing.sm;
  static const double _lineWidth = 2;
  static const double _dotRadius = 4;
  static const double _latestDotRadius = 5;
  static const double _ringWidth = 2;
  static const double _latestRingWidth = 2.5;

  final List<ProgressDataPoint> points;
  final String Function(double value) formatYLabel;
  final String Function(DateTime date) formatXLabel;
  final TextStyle? labelStyle;
  final Color gridColor;
  final Color lineColor;
  final Color dotRingColor;
  final Color latestDotColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final plotBottom = size.height - _plotBottomInset;
    final values = points.map((point) => point.metricValue);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    _paintGrid(canvas, size, plotBottom, minValue, maxValue);
    _paintXLabels(canvas, size);
    final offsets = _offsetsFor(size, plotBottom, minValue, maxValue);
    _paintLine(canvas, offsets);
    _paintDots(canvas, offsets);
  }

  List<Offset> _offsetsFor(
    Size size,
    double plotBottom,
    double minValue,
    double maxValue,
  ) {
    final left = _gutterWidth + _sidePadding;
    final width = size.width - left - _sidePadding;
    final range = maxValue - minValue;
    return [
      for (var i = 0; i < points.length; i++)
        Offset(
          points.length == 1
              ? left + width / 2
              : left + width * i / (points.length - 1),
          range == 0
              ? (_plotTop + plotBottom) / 2
              : plotBottom -
                    (points[i].metricValue - minValue) /
                        range *
                        (plotBottom - _plotTop),
        ),
    ];
  }

  void _paintGrid(
    Canvas canvas,
    Size size,
    double plotBottom,
    double minValue,
    double maxValue,
  ) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final midY = (_plotTop + plotBottom) / 2;
    final rows = [
      (_plotTop, maxValue),
      (midY, (minValue + maxValue) / 2),
      (plotBottom, minValue),
    ];
    for (final (y, value) in rows) {
      canvas.drawLine(Offset(_gutterWidth, y), Offset(size.width, y), paint);
      _paintText(canvas, formatYLabel(value), Offset(0, y - 6));
    }
  }

  void _paintXLabels(Canvas canvas, Size size) {
    final y = size.height - _xLabelBottomInset - 10;
    final first = points.first;
    final middle = points[points.length ~/ 2];
    final last = points.last;
    _paintText(canvas, formatXLabel(first.date), Offset(_gutterWidth, y));
    if (points.length > 2) {
      _paintText(
        canvas,
        formatXLabel(middle.date),
        Offset(size.width / 2, y),
        centered: true,
      );
    }
    if (points.length > 1) {
      _paintText(
        canvas,
        formatXLabel(last.date),
        Offset(size.width, y),
        alignRight: true,
      );
    }
  }

  void _paintLine(Canvas canvas, List<Offset> offsets) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final offset in offsets.skip(1)) {
      path.lineTo(offset.dx, offset.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _lineWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintDots(Canvas canvas, List<Offset> offsets) {
    for (var i = 0; i < offsets.length; i++) {
      final isLatest = points[i].isLatest;
      final radius = isLatest ? _latestDotRadius : _dotRadius;
      canvas
        ..drawCircle(
          offsets[i],
          radius,
          Paint()..color = isLatest ? latestDotColor : lineColor,
        )
        ..drawCircle(
          offsets[i],
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = isLatest ? _latestRingWidth : _ringWidth
            ..color = isLatest ? lineColor : dotRingColor,
        );
    }
  }

  void _paintText(
    Canvas canvas,
    String text,
    Offset anchor, {
    bool centered = false,
    bool alignRight = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centered
        ? anchor.dx - painter.width / 2
        : alignRight
        ? anchor.dx - painter.width
        : anchor.dx;
    painter.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  bool shouldRepaint(ProgressChartPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.labelStyle != labelStyle ||
      oldDelegate.gridColor != gridColor ||
      oldDelegate.lineColor != lineColor;
}
