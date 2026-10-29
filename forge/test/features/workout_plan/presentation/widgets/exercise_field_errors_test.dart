import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/enums/exercise_type.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_exercise_form_entry.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_field_error.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_field_error_text.dart';
import 'package:forge/l10n/app_localizations_en.dart';

PlanExerciseFormEntry _entry({
  String sets = '3',
  String reps = '10',
  String weight = '60',
  String rest = '90',
  PlanFieldError? setsError,
  PlanFieldError? repsError,
  PlanFieldError? weightError,
  PlanFieldError? restError,
}) => PlanExerciseFormEntry(
  exerciseId: 'e',
  exerciseName: 'Bench Press',
  type: ExerciseType.weighted,
  sets: sets,
  repsOrDuration: reps,
  weight: weight,
  rest: rest,
  setsError: setsError,
  repsOrDurationError: repsError,
  weightError: weightError,
  restError: restError,
);

void main() {
  final l10n = AppLocalizationsEn();

  test('valid fields give no message', () {
    expect(l10n.exerciseFieldErrors(_entry()), isNull);
  });

  test('four empty fields share one line instead of four', () {
    final message = l10n.exerciseFieldErrors(
      _entry(
        sets: '',
        reps: '',
        weight: '',
        rest: '',
        setsError: PlanFieldError.setsInvalid,
        repsError: PlanFieldError.repsInvalid,
        weightError: PlanFieldError.weightInvalid,
        restError: PlanFieldError.restInvalid,
      ),
    );

    expect(message, 'Fill in the highlighted fields');
  });

  test('a filled-in but rejected value explains its own rule', () {
    final message = l10n.exerciseFieldErrors(
      _entry(sets: '0', setsError: PlanFieldError.setsInvalid),
    );

    expect(message, contains('from 1 to 100'));
    expect(message, isNot(contains('Fill in')));
  });

  test('empty and rejected fields combine, fill-in line first', () {
    final message = l10n.exerciseFieldErrors(
      _entry(
        weight: '',
        sets: '0',
        weightError: PlanFieldError.weightInvalid,
        setsError: PlanFieldError.setsInvalid,
      ),
    )!;

    final lines = message.split('\n');
    expect(lines.first, 'Fill in the highlighted fields');
    expect(lines, hasLength(2));
    expect(lines.last, contains('from 1 to 100'));
  });

  test('a whitespace-only field counts as empty', () {
    final message = l10n.exerciseFieldErrors(
      _entry(rest: '  ', restError: PlanFieldError.restInvalid),
    );

    expect(message, 'Fill in the highlighted fields');
  });
}
