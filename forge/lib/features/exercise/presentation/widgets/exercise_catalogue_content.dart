import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_catalogue_empty_state.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_filter_chips.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_list_item.dart';
import 'package:forge/features/exercise/presentation/widgets/exercise_search_field.dart';

class ExerciseCatalogueContent extends StatelessWidget {
  const ExerciseCatalogueContent({
    required this.exercises,
    required this.query,
    required this.activeFilter,
    required this.isPickerMode,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.onAddTap,
    super.key,
  });

  final List<Exercise> exercises;
  final String query;
  final ExerciseType? activeFilter;
  final bool isPickerMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExerciseType?> onFilterChanged;
  final ValueChanged<Exercise> onAddTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ExerciseSearchField(onSearchChanged: onSearchChanged),
        ExerciseFilterChips(
          activeFilter: activeFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: exercises.isEmpty
              ? const ExerciseCatalogueEmptyState()
              : ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (_, i) => ExerciseListItem(
                    exercise: exercises[i],
                    isPickerMode: isPickerMode,
                    onAddTap: isPickerMode
                        ? () => onAddTap(exercises[i])
                        : null,
                  ),
                ),
        ),
      ],
    );
  }
}
