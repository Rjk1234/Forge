import 'package:flutter/material.dart';
import 'package:forge/l10n/l10n.dart';

/// Bottom sheet listing the fitness goals; pops itself after a selection.
class FitnessGoalSheet extends StatelessWidget {
  const FitnessGoalSheet({
    required this.selectedGoal,
    required this.onSelect,
    super.key,
  });

  final String selectedGoal;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: context.l10n.profileFitnessGoalOptions.map((goal) {
          final isSelected = selectedGoal == goal;
          return ListTile(
            title: Text(
              goal,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: colorScheme.primary)
                : null,
            onTap: () {
              onSelect(goal);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }
}
