import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/features/workout_session/application/bloc/active_workout_state.dart';

class SetProgressDot extends StatelessWidget {
  static const double _dotSize = 8;
  static const double _currentRingSize = 12;

  const SetProgressDot({
    required this.status,
    required this.isCurrent,
    super.key,
  });

  final SetStatus status;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    if (isCurrent) {
      return Container(
        width: _currentRingSize,
        height: _currentRingSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.primary, width: 2),
        ),
      );
    }

    final color = switch (status) {
      SetStatus.logged => colorScheme.primary,
      SetStatus.skipped => colorScheme.onSurfaceVariant,
      SetStatus.pending => appColors.textDim,
    };

    return Container(
      width: _dotSize,
      height: _dotSize,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
