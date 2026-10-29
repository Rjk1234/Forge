import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

class ProfileSegRow extends StatelessWidget {
  const ProfileSegRow({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: options.map((option) {
        final isSelected = option == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(option),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
              margin: EdgeInsets.only(right: option != options.last ? 4 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(
                  color: isSelected ? colorScheme.primary : colorScheme.outline,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                option,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
