import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';
import 'package:forge/l10n/l10n.dart';

/// Localized message for a rejected plan-form field.
extension PlanFieldErrorText on AppLocalizations {
  String? planFieldError(PlanFieldError? error) => switch (error) {
    null => null,
    PlanFieldError.nameRequired => planNameRequiredError,
    PlanFieldError.exercisesRequired => planExercisesRequiredError,
    PlanFieldError.setsInvalid => setsError(WorkoutLimits.maxSets),
    PlanFieldError.restInvalid => restError(WorkoutLimits.maxRestSec),
    PlanFieldError.repsInvalid => repsError(WorkoutLimits.maxRepetitions),
    PlanFieldError.weightInvalid => weightError(
      WorkoutLimits.maxWeightKg.toInt(),
    ),
    PlanFieldError.durationFormat => durationFormatError,
    PlanFieldError.durationInvalid => durationError,
  };
}

/// One message for everything wrong in an exercise's fields, shown under the
/// four small input boxes where per-field text would not fit.
///
/// Empty fields share a single "fill in" line; filled-in but rejected values
/// each explain their own rule. Null when every field is valid.
extension ExerciseFieldErrors on AppLocalizations {
  String? exerciseFieldErrors(PlanExerciseFormEntry entry) {
    final failing = [
      (entry.sets, entry.setsError),
      (entry.repsOrDuration, entry.repsOrDurationError),
      (entry.weight, entry.weightError),
      (entry.rest, entry.restError),
    ].where((field) => field.$2 != null).toList();
    if (failing.isEmpty) return null;

    final hasEmptyField = failing.any((field) => field.$1.trim().isEmpty);
    return [
      if (hasEmptyField) planFillHighlightedFieldsError,
      for (final field in failing)
        if (field.$1.trim().isNotEmpty) planFieldError(field.$2)!,
    ].join('\n');
  }
}
