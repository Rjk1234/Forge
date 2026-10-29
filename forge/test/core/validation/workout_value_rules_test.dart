import 'package:flutter_test/flutter_test.dart';
import 'package:forge/core/validation/workout_value_rules.dart';

void main() {
  group('isValidName', () {
    test('accepts a normal name and a name with surrounding spaces', () {
      expect(WorkoutValueRules.isValidName('Push Day'), isTrue);
      expect(WorkoutValueRules.isValidName('  Push Day  '), isTrue);
    });

    test('rejects empty and whitespace-only names', () {
      expect(WorkoutValueRules.isValidName(''), isFalse);
      expect(WorkoutValueRules.isValidName('   '), isFalse);
    });

    test('enforces the maximum length on the trimmed name', () {
      final longest = 'a' * WorkoutLimits.maxPlanNameLength;
      expect(WorkoutValueRules.isValidName(longest), isTrue);
      expect(WorkoutValueRules.isValidName('${longest}a'), isFalse);
    });
  });

  group('counts', () {
    test('sets must be between 1 and the limit', () {
      expect(WorkoutValueRules.isValidSetCount(null), isFalse);
      expect(WorkoutValueRules.isValidSetCount(0), isFalse);
      expect(WorkoutValueRules.isValidSetCount(-1), isFalse);
      expect(WorkoutValueRules.isValidSetCount(1), isTrue);
      expect(WorkoutValueRules.isValidSetCount(WorkoutLimits.maxSets), isTrue);
      expect(
        WorkoutValueRules.isValidSetCount(WorkoutLimits.maxSets + 1),
        isFalse,
      );
    });

    test('repetitions must be between 1 and the limit', () {
      expect(WorkoutValueRules.isValidRepetitions(null), isFalse);
      expect(WorkoutValueRules.isValidRepetitions(0), isFalse);
      expect(WorkoutValueRules.isValidRepetitions(1), isTrue);
      expect(
        WorkoutValueRules.isValidRepetitions(WorkoutLimits.maxRepetitions + 1),
        isFalse,
      );
    });
  });

  group('isValidWeight', () {
    test('accepts positive finite weights up to the limit', () {
      expect(WorkoutValueRules.isValidWeight(0.5), isTrue);
      expect(WorkoutValueRules.isValidWeight(62.5), isTrue);
      expect(
        WorkoutValueRules.isValidWeight(WorkoutLimits.maxWeightKg),
        isTrue,
      );
    });

    test('rejects null, zero, negative, over-limit and non-finite values', () {
      expect(WorkoutValueRules.isValidWeight(null), isFalse);
      expect(WorkoutValueRules.isValidWeight(0), isFalse);
      expect(WorkoutValueRules.isValidWeight(-5), isFalse);
      expect(
        WorkoutValueRules.isValidWeight(WorkoutLimits.maxWeightKg + 0.1),
        isFalse,
      );
      expect(WorkoutValueRules.isValidWeight(double.infinity), isFalse);
      expect(WorkoutValueRules.isValidWeight(double.nan), isFalse);
    });
  });

  group('durations', () {
    test('a duration is at least one second and within the limit', () {
      expect(WorkoutValueRules.isValidDurationSec(null), isFalse);
      expect(WorkoutValueRules.isValidDurationSec(0), isFalse);
      expect(WorkoutValueRules.isValidDurationSec(-3), isFalse);
      expect(WorkoutValueRules.isValidDurationSec(1), isTrue);
      expect(
        WorkoutValueRules.isValidDurationSec(WorkoutLimits.maxDurationSec + 1),
        isFalse,
      );
    });

    test('rest may be zero but never negative or over the limit', () {
      expect(WorkoutValueRules.isValidRestSec(0), isTrue);
      expect(WorkoutValueRules.isValidRestSec(-1), isFalse);
      expect(WorkoutValueRules.isValidRestSec(null), isFalse);
      expect(
        WorkoutValueRules.isValidRestSec(WorkoutLimits.maxRestSec + 1),
        isFalse,
      );
    });

    test('a session duration may be zero but never negative', () {
      expect(WorkoutValueRules.isValidSessionDurationSec(0), isTrue);
      expect(WorkoutValueRules.isValidSessionDurationSec(-1), isFalse);
      expect(
        WorkoutValueRules.isValidSessionDurationSec(
          WorkoutLimits.maxSessionDurationSec + 1,
        ),
        isFalse,
      );
    });
  });
}
