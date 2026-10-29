import 'package:flutter/widgets.dart';
import 'package:forge/l10n/app_localizations.dart';
import 'package:forge/core/enums/exercise_type.dart';

export 'package:forge/l10n/app_localizations.dart';

/// Shorthand for the generated localizations: `context.l10n.someKey`.
extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Ordered lists ARB files cannot express directly.
extension AppLocalizationsLists on AppLocalizations {
  /// ISO weekday order: Monday … Sunday.
  List<String> get weekdayAbbreviations => [
    weekdayShortMon,
    weekdayShortTue,
    weekdayShortWed,
    weekdayShortThu,
    weekdayShortFri,
    weekdayShortSat,
    weekdayShortSun,
  ];

  /// ISO weekday order: Monday … Sunday.
  List<String> get weekdayFullNames => [
    weekdayFullMon,
    weekdayFullTue,
    weekdayFullWed,
    weekdayFullThu,
    weekdayFullFri,
    weekdayFullSat,
    weekdayFullSun,
  ];

  List<String> get profileFitnessGoalOptions => [
    profileFitnessGoalBuildMuscle,
    profileFitnessGoalLoseWeight,
    profileFitnessGoalGeneralFitness,
  ];

  List<String> get profileExperienceLevelOptions => [
    profileExperienceBeginner,
    profileExperienceIntermediate,
    profileExperienceAdvanced,
  ];

  /// Display name of an exercise category.
  String exerciseTypeLabel(ExerciseType type) => switch (type) {
    ExerciseType.weighted => exerciseTypeBadgeWeighted,
    ExerciseType.timeBased => exerciseTypeBadgeTimeBased,
    ExerciseType.bodyweight => exerciseTypeBadgeBodyweight,
  };

  /// Quotes of the day; the Home screen picks one by date.
  List<String> get homeQuotes => [
    homeQuote1,
    homeQuote2,
    homeQuote3,
    homeQuote4,
    homeQuote5,
    homeQuote6,
    homeQuote7,
    homeQuote8,
  ];

  /// Rest-day tips; the Home screen picks one by date.
  List<String> get homeRecoveryTips => [
    homeRecoveryTip1,
    homeRecoveryTip2,
    homeRecoveryTip3,
  ];

  /// Warm-up advice for the first muscle group that has a tip.
  String homeWarmupTip(List<String> muscleGroups) {
    for (final group in muscleGroups) {
      final tip = switch (group) {
        'Chest' => homeWarmupTipChest,
        'Back' => homeWarmupTipBack,
        'Legs' => homeWarmupTipLegs,
        'Shoulders' => homeWarmupTipShoulders,
        'Biceps' => homeWarmupTipBiceps,
        'Triceps' => homeWarmupTipTriceps,
        'Core' => homeWarmupTipCore,
        _ => null,
      };
      if (tip != null) return tip;
    }
    return homeWarmupGeneric;
  }
}
