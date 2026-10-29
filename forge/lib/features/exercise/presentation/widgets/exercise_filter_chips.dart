import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_filter_chip.dart';

class ExerciseFilterChips extends StatelessWidget {
  const ExerciseFilterChips({
    required this.activeFilter,
    required this.onFilterChanged,
    super.key,
  });

  final ExerciseType? activeFilter;
  final ValueChanged<ExerciseType?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ExerciseFilterChip(
              label: context.l10n.exerciseFilterAll,
              isActive: activeFilter == null,
              onTap: () => onFilterChanged(null),
            ),
            const SizedBox(width: AppSpacing.sm),
            ...ExerciseType.values.map(
              (type) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ExerciseFilterChip(
                  label: context.l10n.exerciseTypeLabel(type),
                  isActive: activeFilter == type,
                  onTap: () => onFilterChanged(type),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
