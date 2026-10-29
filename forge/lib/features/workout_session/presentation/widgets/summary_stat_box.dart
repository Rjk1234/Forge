import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';

/// Labelled headline number on the workout summary (duration, sets, ...).
class SummaryStatBox extends StatelessWidget {
  const SummaryStatBox({required this.label, required this.value, super.key});

  static const double _radius = AppRadius.card;
  static const double _padding = AppSpacing.mdl;
  static const double _valueGap = AppSpacing.xs;

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: _radius,
      padding: const EdgeInsets.all(_padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: textTheme.labelMedium,
          ),
          const SizedBox(height: _valueGap),
          Text(value, textAlign: TextAlign.center, style: textTheme.titleLarge),
        ],
      ),
    );
  }
}
