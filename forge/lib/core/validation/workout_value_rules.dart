/// Upper bounds that keep workout data sane and safe to process.
abstract final class WorkoutLimits {
  static const int maxPlanNameLength = 100;
  static const int maxSets = 100;
  static const int maxRepetitions = 1000;
  static const double maxWeightKg = 1000;
  static const int maxDurationSec = 86400;
  static const int maxRestSec = 3600;
  static const int maxSessionDurationSec = 86400;
}

/// The single definition of what a valid workout number or name is.
///
/// Blocs, validators and statistics all call these so a rule can never differ
/// between the plan form, the logging screen and the data layer.
abstract final class WorkoutValueRules {
  static bool isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty &&
        trimmed.length <= WorkoutLimits.maxPlanNameLength;
  }

  static bool isValidSetCount(int? value) =>
      value != null && value >= 1 && value <= WorkoutLimits.maxSets;

  static bool isValidRepetitions(int? value) =>
      value != null && value >= 1 && value <= WorkoutLimits.maxRepetitions;

  /// A weight is positive, finite and within [WorkoutLimits.maxWeightKg].
  static bool isValidWeight(double? value) =>
      value != null &&
      value.isFinite &&
      value > 0 &&
      value <= WorkoutLimits.maxWeightKg;

  static bool isValidDurationSec(int? value) =>
      value != null && value >= 1 && value <= WorkoutLimits.maxDurationSec;

  static bool isValidRestSec(int? value) =>
      value != null && value >= 0 && value <= WorkoutLimits.maxRestSec;

  static bool isValidSessionDurationSec(int value) =>
      value >= 0 && value <= WorkoutLimits.maxSessionDurationSec;
}
