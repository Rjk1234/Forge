import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class PlanLoadErrorView extends StatelessWidget {
  const PlanLoadErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ErrorCard(
          message: context.l10n.planLoadError,
          onRetry: () => context.pop(),
        ),
      ),
    );
  }
}
