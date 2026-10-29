import 'package:flutter/material.dart';
import 'package:forge/core/widgets/status_banner.dart';
import 'package:forge/l10n/l10n.dart';

/// In-field banner replacing the plan selector when the referenced plan no
/// longer exists.
class InvalidPlanBanner extends StatelessWidget {
  const InvalidPlanBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Semantics(
      label: l10n.invalidPlanBannerSemantics(
        l10n.invalidPlanBannerTitle,
        l10n.invalidPlanBannerSubtitle,
      ),
      child: StatusBanner(
        message: l10n.invalidPlanBannerTitle,
        subtitle: l10n.invalidPlanBannerSubtitle,
        icon: Icons.warning_amber_rounded,
        emphasizeBorder: true,
      ),
    );
  }
}
