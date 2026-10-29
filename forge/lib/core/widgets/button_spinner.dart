import 'package:flutter/material.dart';

/// Small spinner shown inside a button while its action runs.
class ButtonSpinner extends StatelessWidget {
  const ButtonSpinner({
    required this.color,
    this.size = defaultSize,
    this.strokeWidth = defaultStrokeWidth,
    this.trackColor,
    super.key,
  });

  static const double defaultSize = 14;
  static const double defaultStrokeWidth = 2;

  final Color color;
  final double size;
  final double strokeWidth;

  /// Optional colour of the unfilled part of the ring.
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
        backgroundColor: trackColor,
      ),
    );
  }
}
