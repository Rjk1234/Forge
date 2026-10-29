import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/core/validation/workout_value_rules.dart';
import 'package:forge/features/workout_session/application/models/edit_set_entry.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';
import 'package:forge/features/workout_session/domain/rules/logged_set_rules.dart';

/// The fields the user fills in for a set of [type].
List<EditSetField> fieldsFor(ExerciseType type) => switch (type) {
  ExerciseType.weighted => const [EditSetField.reps, EditSetField.weight],
  ExerciseType.bodyweight => const [EditSetField.reps],
  ExerciseType.timeBased => const [EditSetField.duration],
};

/// Whether the text typed in [field] is acceptable under the shared rules.
bool isFieldValid(EditSetField field, String text) {
  final trimmed = text.trim();
  return switch (field) {
    EditSetField.reps => WorkoutValueRules.isValidRepetitions(
      int.tryParse(trimmed),
    ),
    EditSetField.weight => WorkoutValueRules.isValidWeight(
      double.tryParse(trimmed),
    ),
    EditSetField.duration => WorkoutValueRules.isValidDurationSec(
      int.tryParse(trimmed),
    ),
  };
}

/// Fields of [entry] that fail validation; a skipped set is never flagged.
Set<EditSetField> invalidFieldsOf(EditSetEntry entry, ExerciseType type) {
  if (entry.skipped) return const {};
  return {
    for (final field in fieldsFor(type))
      if (!isFieldValid(field, entry.textOf(field))) field,
  };
}

/// Builds the stored set. A skipped set keeps only values that are plausible,
/// because the session validator rejects non-positive numbers on any set.
ActualSet toActualSet(EditSetEntry entry, ExerciseType type) {
  final fields = fieldsFor(type);
  int? positiveInt(EditSetField field) {
    if (!fields.contains(field)) return null;
    final value = int.tryParse(entry.textOf(field).trim());
    return value != null && value > 0 ? value : null;
  }

  double? positiveWeight() {
    if (!fields.contains(EditSetField.weight)) return null;
    final value = double.tryParse(entry.weightText.trim());
    return value != null && value.isFinite && value > 0 ? value : null;
  }

  return ActualSet(
    repetitions: positiveInt(EditSetField.reps),
    weight: positiveWeight(),
    durationSec: positiveInt(EditSetField.duration),
    skipped: entry.skipped,
  );
}

/// Whether [set] of [type] counts as a valid logged set.
bool isEntryLogged(EditSetEntry entry, ExerciseType type) =>
    isValidLoggedSet(toActualSet(entry, type), type);
