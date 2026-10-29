import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/l10n/l10n.dart';

/// Circular countdown: the lime arc shows the share of rest still remaining.
class RestCountdownRing extends StatelessWidget {
  const RestCountdownRing({
    required this.totalSec,
    required this.remainingSec,
    super.key,
  });

  static const double _size = 220;
  static const double _strokeWidth = 10;
  static const double _inset = 14;
  static const Duration _tickDuration = Duration(seconds: 1);

  final int totalSec;
  final int remainingSec;

  double _fractionAt(int seconds) =>
      totalSec <= 0 ? 0 : (seconds / totalSec).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final currentFraction = _fractionAt(remainingSec);
    final targetFraction = reduceMotion
        ? currentFraction
        : _fractionAt(remainingSec - 1);
    final time = formatDuration(remainingSec);

    return Semantics(
      label: context.l10n.restTimerSemantics(time),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: currentFraction, end: targetFraction),
                duration: reduceMotion ? Duration.zero : _tickDuration,
                builder: (context, fraction, _) => CustomPaint(
                  size: const Size.square(_size),
                  painter: _RingPainter(
                    fraction: fraction,
                    trackColor: colorScheme.surfaceContainerHighest,
                    arcColor: colorScheme.primary,
                  ),
                ),
              ),
              Text(time, style: textTheme.displayLarge),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.trackColor,
    required this.arcColor,
  });

  final double fraction;
  final Color trackColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - RestCountdownRing._inset;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = RestCountdownRing._strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint..color = trackColor);
    if (fraction <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      paint..color = arcColor,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.arcColor != arcColor;
}
