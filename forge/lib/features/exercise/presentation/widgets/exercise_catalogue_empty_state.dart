import 'package:flutter/material.dart';
import 'package:forge/core/widgets/app_empty_state.dart';
import 'package:forge/l10n/l10n.dart';

class ExerciseCatalogueEmptyState extends StatelessWidget {
  const ExerciseCatalogueEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppEmptyState(
      icon: Icons.search_off,
      title: l10n.exerciseCatalogueNoMatchTitle,
      subtitle: l10n.exerciseCatalogueNoMatchSubtitle,
    );
  }
}
