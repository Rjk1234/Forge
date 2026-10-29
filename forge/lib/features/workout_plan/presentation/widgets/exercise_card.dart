import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter/services.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/core/widgets/status_banner.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_field_error_text.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_form_field_grid.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_type_badge.dart';

/// Card representing one exercise entry in the create/edit form.
///
/// Manages four [TextEditingController] instances (Sets, Reps/Duration,
/// Weight, Rest) for its lifetime. Values from [entry] are used to initialize
/// controllers; [onFieldChanged] and [onRemove] forward events to the Bloc.
class ExerciseCard extends StatefulWidget {
  const ExerciseCard({
    required this.entry,
    required this.index,
    required this.onFieldChanged,
    required this.onRemove,
    this.isSaving = false,
    super.key,
  });

  final PlanExerciseFormEntry entry;
  final int index;
  final void Function(int index, ExerciseField field, String value)
  onFieldChanged;
  final VoidCallback onRemove;
  final bool isSaving;

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  late final TextEditingController _setsCtrl;
  late final TextEditingController _repsOrDurationCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _restCtrl;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _setsCtrl = TextEditingController(text: entry.sets);
    _repsOrDurationCtrl = TextEditingController(text: entry.repsOrDuration);
    _weightCtrl = TextEditingController(text: entry.weight);
    _restCtrl = TextEditingController(text: entry.rest);
  }

  @override
  void dispose() {
    _setsCtrl.dispose();
    _repsOrDurationCtrl.dispose();
    _weightCtrl.dispose();
    _restCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final entry = widget.entry;
    final fieldErrors = context.l10n.exerciseFieldErrors(entry);

    return Opacity(
      opacity: widget.isSaving ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.banner),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ExerciseTypeBadge(type: entry.type),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    entry.exerciseName,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: widget.isSaving ? null : widget.onRemove,
                  icon: Icon(Icons.close, color: appColors.textDim, size: 20),
                  tooltip: context.l10n.removeExerciseTooltip,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ExerciseFormFieldGrid(
              entry: entry,
              index: widget.index,
              setsCtrl: _setsCtrl,
              repsOrDurationCtrl: _repsOrDurationCtrl,
              weightCtrl: _weightCtrl,
              restCtrl: _restCtrl,
              onFieldChanged: widget.onFieldChanged,
              isSaving: widget.isSaving,
            ),
            if (fieldErrors != null) ...[
              const SizedBox(height: AppSpacing.md),
              StatusBanner(message: fieldErrors),
            ],
          ],
        ),
      ),
    );
  }
}
