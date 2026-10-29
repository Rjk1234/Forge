import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

/// Static, always-on toggle visual used by the recurrence row.
class RecurrenceToggleIndicator extends StatelessWidget {
  const RecurrenceToggleIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: SizedBox(
        width: 40,
        height: 22,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(AppRadius.banner),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
