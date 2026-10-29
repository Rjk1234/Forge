import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

/// Section header above each month of sessions, e.g. "SEPTEMBER 2026".
class HistoryMonthLabel extends StatelessWidget {
  const HistoryMonthLabel({required this.label, super.key});

  static const double _topMargin = AppSpacing.xsm;
  static const double _bottomMargin = AppSpacing.xxs;

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: _topMargin, bottom: _bottomMargin),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
