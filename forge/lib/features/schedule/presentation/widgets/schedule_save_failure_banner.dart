import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/status_banner.dart';
import 'package:forge/l10n/l10n.dart';

/// Top-of-screen error banner shown when a schedule save attempt fails.
class ScheduleSaveFailureBanner extends StatelessWidget {
  const ScheduleSaveFailureBanner({required this.message, super.key});

  static const EdgeInsets _margin = EdgeInsets.fromLTRB(
    AppSpacing.xl - 4,
    0,
    AppSpacing.xl - 4,
    AppSpacing.md,
  );

  final String message;

  @override
  Widget build(BuildContext context) {
    return StatusBanner(
      message: message,
      subtitle: context.l10n.scheduleSaveFailureSubtitle,
      margin: _margin,
    );
  }
}
