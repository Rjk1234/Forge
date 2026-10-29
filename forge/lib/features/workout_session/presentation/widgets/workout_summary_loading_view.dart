import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

/// Body shown while the completed session is being written to storage.
class WorkoutSummaryLoadingView extends StatelessWidget {
  const WorkoutSummaryLoadingView({required this.planName, super.key});

  static const double _horizontalPadding = AppSpacing.lgx;

  final String planName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          planName,
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
