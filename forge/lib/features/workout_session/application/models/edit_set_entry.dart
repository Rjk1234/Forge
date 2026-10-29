import 'package:equatable/equatable.dart';
import 'package:forge/features/workout_session/domain/entities/actual_set.dart';

/// The editable fields of one set.
enum EditSetField { reps, weight, duration }

/// One set in the edit form: raw field text, the skipped flag and the fields
/// that currently fail validation.
class EditSetEntry extends Equatable {
  const EditSetEntry({
    required this.repsText,
    required this.weightText,
    required this.durationText,
    required this.skipped,
    this.invalidFields = const {},
  });

  factory EditSetEntry.fromActualSet(ActualSet set) {
    return EditSetEntry(
      repsText: set.repetitions?.toString() ?? '',
      weightText: _formatWeight(set.weight),
      durationText: set.durationSec?.toString() ?? '',
      skipped: set.skipped,
    );
  }

  final String repsText;
  final String weightText;
  final String durationText;
  final bool skipped;
  final Set<EditSetField> invalidFields;

  String textOf(EditSetField field) => switch (field) {
    EditSetField.reps => repsText,
    EditSetField.weight => weightText,
    EditSetField.duration => durationText,
  };

  EditSetEntry withText(EditSetField field, String text) => EditSetEntry(
    repsText: field == EditSetField.reps ? text : repsText,
    weightText: field == EditSetField.weight ? text : weightText,
    durationText: field == EditSetField.duration ? text : durationText,
    skipped: skipped,
    invalidFields: invalidFields,
  );

  EditSetEntry copyWith({bool? skipped, Set<EditSetField>? invalidFields}) =>
      EditSetEntry(
        repsText: repsText,
        weightText: weightText,
        durationText: durationText,
        skipped: skipped ?? this.skipped,
        invalidFields: invalidFields ?? this.invalidFields,
      );

  static String _formatWeight(double? weight) {
    if (weight == null) return '';
    return weight == weight.truncateToDouble()
        ? weight.toInt().toString()
        : weight.toString();
  }

  @override
  List<Object?> get props => [
    repsText,
    weightText,
    durationText,
    skipped,
    invalidFields,
  ];
}
