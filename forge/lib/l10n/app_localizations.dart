import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @createPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Plan'**
  String get createPlanTitle;

  /// No description provided for @editPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlanTitle;

  /// No description provided for @planNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Plan Name'**
  String get planNameLabel;

  /// No description provided for @planNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Push Day'**
  String get planNameHint;

  /// No description provided for @planNameRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Plan name is required'**
  String get planNameRequiredError;

  /// No description provided for @planExercisesRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Add at least one exercise'**
  String get planExercisesRequiredError;

  /// No description provided for @planFillHighlightedFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Fill in the highlighted fields'**
  String get planFillHighlightedFieldsError;

  /// No description provided for @addExerciseButton.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExerciseButton;

  /// No description provided for @savePlanButton.
  ///
  /// In en, this message translates to:
  /// **'Save Plan'**
  String get savePlanButton;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @removeExerciseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove exercise'**
  String get removeExerciseTooltip;

  /// No description provided for @setsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get durationLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @restLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest (s)'**
  String get restLabel;

  /// No description provided for @setsError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of sets from 1 to {max}'**
  String setsError(int max);

  /// No description provided for @repsError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of reps from 1 to {max}'**
  String repsError(int max);

  /// No description provided for @durationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid duration (mm:ss)'**
  String get durationError;

  /// No description provided for @weightError.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight above 0 and up to {max} kg'**
  String weightError(int max);

  /// No description provided for @restError.
  ///
  /// In en, this message translates to:
  /// **'Enter a rest period from 0 to {max} seconds'**
  String restError(int max);

  /// No description provided for @savePlanFailureMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not save the plan. Please try again.'**
  String get savePlanFailureMessage;

  /// No description provided for @discardChangesTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. If you go back now, your changes will be lost.'**
  String get discardChangesMessage;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @keepEditingButton.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditingButton;

  /// No description provided for @loadPlanError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the workout plan.'**
  String get loadPlanError;

  /// No description provided for @exerciseTypeBadgeWeighted.
  ///
  /// In en, this message translates to:
  /// **'Weighted'**
  String get exerciseTypeBadgeWeighted;

  /// No description provided for @exerciseTypeBadgeTimeBased.
  ///
  /// In en, this message translates to:
  /// **'Time-based'**
  String get exerciseTypeBadgeTimeBased;

  /// No description provided for @exerciseTypeBadgeBodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get exerciseTypeBadgeBodyweight;

  /// No description provided for @noPlanExercisesMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Exercise\" to build your plan.'**
  String get noPlanExercisesMessage;

  /// No description provided for @planDetailStartWorkoutButton.
  ///
  /// In en, this message translates to:
  /// **'Start Workout'**
  String get planDetailStartWorkoutButton;

  /// No description provided for @planDetailScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get planDetailScheduleButton;

  /// No description provided for @planDetailEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get planDetailEditTooltip;

  /// No description provided for @planDetailDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete plan'**
  String get planDetailDeleteTooltip;

  /// No description provided for @planDetailBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get planDetailBackTooltip;

  /// No description provided for @planDetailExercisesSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'EXERCISES'**
  String get planDetailExercisesSectionLabel;

  /// No description provided for @planDetailLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading plan details'**
  String get planDetailLoadingSemantics;

  /// No description provided for @planDetailWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get planDetailWeightLabel;

  /// No description provided for @planDetailRestLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get planDetailRestLabel;

  /// No description provided for @planNotAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer available'**
  String get planNotAvailableTitle;

  /// No description provided for @planNotAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted, or something went wrong reading local data.'**
  String get planNotAvailableBody;

  /// No description provided for @planNotAvailableButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Plans'**
  String get planNotAvailableButton;

  /// No description provided for @exerciseUnavailableName.
  ///
  /// In en, this message translates to:
  /// **'Exercise unavailable'**
  String get exerciseUnavailableName;

  /// No description provided for @deletePlanDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout plan?'**
  String get deletePlanDialogTitle;

  /// No description provided for @deletePlanCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deletePlanCancelButton;

  /// No description provided for @deletePlanDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deletePlanDeleteButton;

  /// No description provided for @deletePlanDeletingLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deletePlanDeletingLabel;

  /// No description provided for @deletePlanRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get deletePlanRetryButton;

  /// No description provided for @deletePlanErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the plan — something went wrong writing to local storage. Nothing was removed.'**
  String get deletePlanErrorMessage;

  /// No description provided for @scheduleScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleScreenTitle;

  /// No description provided for @scheduleRestDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Rest day'**
  String get scheduleRestDayLabel;

  /// No description provided for @scheduleRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get scheduleRecurrenceWeekly;

  /// No description provided for @scheduleTodayMeta.
  ///
  /// In en, this message translates to:
  /// **'Weekly · Today'**
  String get scheduleTodayMeta;

  /// No description provided for @scheduleEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit schedule for this day'**
  String get scheduleEditTooltip;

  /// No description provided for @scheduleRowMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options for this day'**
  String get scheduleRowMenuTooltip;

  /// No description provided for @scheduleChangeDaysAction.
  ///
  /// In en, this message translates to:
  /// **'Change days'**
  String get scheduleChangeDaysAction;

  /// No description provided for @scheduleRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove from this day'**
  String get scheduleRemoveAction;

  /// No description provided for @scheduleStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get scheduleStartButton;

  /// No description provided for @scheduleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts scheduled'**
  String get scheduleEmptyTitle;

  /// No description provided for @scheduleEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign a plan to a day to see it here.'**
  String get scheduleEmptySubtitle;

  /// No description provided for @scheduleEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Schedule a plan'**
  String get scheduleEmptyCta;

  /// No description provided for @scheduleErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your schedule'**
  String get scheduleErrorTitle;

  /// No description provided for @scheduleErrorReassurance.
  ///
  /// In en, this message translates to:
  /// **'Your plans and history are safe.'**
  String get scheduleErrorReassurance;

  /// No description provided for @scheduleRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get scheduleRetryButton;

  /// No description provided for @scheduleLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading schedule'**
  String get scheduleLoadingSemantics;

  /// No description provided for @newScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'New Schedule'**
  String get newScheduleTitle;

  /// No description provided for @editScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editScheduleTitle;

  /// No description provided for @assignScheduleLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading schedule assignment'**
  String get assignScheduleLoadingSemantics;

  /// No description provided for @workoutPlanFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'WORKOUT PLAN'**
  String get workoutPlanFieldLabel;

  /// No description provided for @workoutPlanSemanticsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Workout Plan: '**
  String get workoutPlanSemanticsPrefix;

  /// No description provided for @daysFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get daysFieldLabel;

  /// No description provided for @recurrenceFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'RECURRENCE'**
  String get recurrenceFieldLabel;

  /// No description provided for @selectAtLeastOneDayHelper.
  ///
  /// In en, this message translates to:
  /// **'Select at least one day to schedule this plan.'**
  String get selectAtLeastOneDayHelper;

  /// No description provided for @recurrenceWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeats weekly'**
  String get recurrenceWeeklyTitle;

  /// No description provided for @recurrenceWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only weekly recurrence is supported'**
  String get recurrenceWeeklySubtitle;

  /// No description provided for @saveScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Save Schedule'**
  String get saveScheduleButton;

  /// No description provided for @retrySaveScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Retry Save'**
  String get retrySaveScheduleButton;

  /// No description provided for @savingScheduleLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingScheduleLabel;

  /// No description provided for @invalidPlanBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer available'**
  String get invalidPlanBannerTitle;

  /// No description provided for @invalidPlanBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted. Choose a different plan to schedule.'**
  String get invalidPlanBannerSubtitle;

  /// No description provided for @scheduleSaveFailureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong writing to local storage. Nothing was changed — tap Retry to try again.'**
  String get scheduleSaveFailureSubtitle;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @profileDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayNameLabel;

  /// No description provided for @profileDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get profileDisplayNameHint;

  /// No description provided for @profileFitnessGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Fitness Goal'**
  String get profileFitnessGoalLabel;

  /// No description provided for @profileFitnessGoalHint.
  ///
  /// In en, this message translates to:
  /// **'Select a goal'**
  String get profileFitnessGoalHint;

  /// No description provided for @profileExperienceLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience Level'**
  String get profileExperienceLevelLabel;

  /// No description provided for @profileHeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get profileHeightLabel;

  /// No description provided for @profileHeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 178'**
  String get profileHeightHint;

  /// No description provided for @profileWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get profileWeightLabel;

  /// No description provided for @profileWeightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 76'**
  String get profileWeightHint;

  /// No description provided for @profileSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get profileSaveChanges;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile saved'**
  String get profileSaved;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;

  /// No description provided for @profileInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number.'**
  String get profileInvalidNumber;

  /// No description provided for @profileFixFields.
  ///
  /// In en, this message translates to:
  /// **'Fix the highlighted fields to save.'**
  String get profileFixFields;

  /// No description provided for @profileLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your profile'**
  String get profileLoadErrorTitle;

  /// No description provided for @profileSaveErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your profile'**
  String get profileSaveErrorTitle;

  /// No description provided for @profileLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading local storage. Tap Retry to try again.'**
  String get profileLoadErrorBody;

  /// No description provided for @profileSaveErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong writing to local storage. Tap Retry to try again.'**
  String get profileSaveErrorBody;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// No description provided for @profileFitnessGoalBuildMuscle.
  ///
  /// In en, this message translates to:
  /// **'Build Muscle'**
  String get profileFitnessGoalBuildMuscle;

  /// No description provided for @profileFitnessGoalLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose Weight'**
  String get profileFitnessGoalLoseWeight;

  /// No description provided for @profileFitnessGoalGeneralFitness.
  ///
  /// In en, this message translates to:
  /// **'General Fitness'**
  String get profileFitnessGoalGeneralFitness;

  /// No description provided for @removeScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from schedule?'**
  String get removeScheduleTitle;

  /// No description provided for @removeScheduleConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeScheduleConfirmButton;

  /// No description provided for @removeScheduleRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get removeScheduleRetryButton;

  /// No description provided for @removeScheduleCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get removeScheduleCancelButton;

  /// No description provided for @removeScheduleRemovingLabel.
  ///
  /// In en, this message translates to:
  /// **'Removing…'**
  String get removeScheduleRemovingLabel;

  /// No description provided for @removeScheduleErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove this entry. Please try again.'**
  String get removeScheduleErrorMessage;

  /// No description provided for @preStartScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get preStartScreenTitle;

  /// No description provided for @preStartExercisesSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'EXERCISES'**
  String get preStartExercisesSectionLabel;

  /// No description provided for @preStartBeginButton.
  ///
  /// In en, this message translates to:
  /// **'Begin Workout'**
  String get preStartBeginButton;

  /// No description provided for @preStartWeightNotSet.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get preStartWeightNotSet;

  /// No description provided for @preStartUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'This plan is no longer available'**
  String get preStartUnavailableTitle;

  /// No description provided for @preStartUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted or has no exercises configured.'**
  String get preStartUnavailableBody;

  /// No description provided for @preStartBackToScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Schedule'**
  String get preStartBackToScheduleButton;

  /// No description provided for @preStartErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this workout'**
  String get preStartErrorTitle;

  /// No description provided for @preStartErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading local data. Your data is safe — tap Retry to try again.'**
  String get preStartErrorBody;

  /// No description provided for @preStartRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get preStartRetryButton;

  /// No description provided for @preStartLoadingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loading workout overview'**
  String get preStartLoadingSemantics;

  /// No description provided for @activeWorkoutCompleteSetButton.
  ///
  /// In en, this message translates to:
  /// **'Complete Set'**
  String get activeWorkoutCompleteSetButton;

  /// No description provided for @activeWorkoutSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get activeWorkoutSkipButton;

  /// No description provided for @activeWorkoutPauseButton.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get activeWorkoutPauseButton;

  /// No description provided for @activeWorkoutResumeButton.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get activeWorkoutResumeButton;

  /// No description provided for @activeWorkoutCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get activeWorkoutCancelButton;

  /// No description provided for @activeWorkoutRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get activeWorkoutRepsLabel;

  /// No description provided for @activeWorkoutWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get activeWorkoutWeightLabel;

  /// No description provided for @activeWorkoutDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get activeWorkoutDurationLabel;

  /// No description provided for @activeWorkoutRepsError.
  ///
  /// In en, this message translates to:
  /// **'Enter reps from 1 to {max}'**
  String activeWorkoutRepsError(int max);

  /// No description provided for @activeWorkoutWeightError.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight above 0 and up to {max} kg'**
  String activeWorkoutWeightError(int max);

  /// No description provided for @activeWorkoutDurationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a duration from 1 to {max} seconds'**
  String activeWorkoutDurationError(int max);

  /// No description provided for @activeWorkoutPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Paused'**
  String get activeWorkoutPausedTitle;

  /// No description provided for @restTimerRestingLabel.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get restTimerRestingLabel;

  /// No description provided for @restTimerSkipRestButton.
  ///
  /// In en, this message translates to:
  /// **'Skip Rest'**
  String get restTimerSkipRestButton;

  /// No description provided for @restTimerUpNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get restTimerUpNextLabel;

  /// No description provided for @restTimerMetaSeparator.
  ///
  /// In en, this message translates to:
  /// **'·'**
  String get restTimerMetaSeparator;

  /// No description provided for @cancelWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this workout?'**
  String get cancelWorkoutTitle;

  /// No description provided for @cancelWorkoutBodyWithoutPlan.
  ///
  /// In en, this message translates to:
  /// **'Your progress won\'t be saved. This session won\'t appear in your workout history.'**
  String get cancelWorkoutBodyWithoutPlan;

  /// No description provided for @cancelWorkoutKeepGoingButton.
  ///
  /// In en, this message translates to:
  /// **'Keep Going'**
  String get cancelWorkoutKeepGoingButton;

  /// No description provided for @cancelWorkoutDiscardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout'**
  String get cancelWorkoutDiscardButton;

  /// No description provided for @workoutSummaryAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutSummaryAppBarTitle;

  /// No description provided for @workoutSummaryLoadingAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Workout'**
  String get workoutSummaryLoadingAppBarTitle;

  /// No description provided for @workoutSummaryLoadingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving Workout…'**
  String get workoutSummaryLoadingButton;

  /// No description provided for @workoutSummaryDoneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get workoutSummaryDoneButton;

  /// No description provided for @workoutSummaryViewHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get workoutSummaryViewHistoryButton;

  /// No description provided for @workoutSummaryDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get workoutSummaryDurationLabel;

  /// No description provided for @workoutSummaryExercisesLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get workoutSummaryExercisesLabel;

  /// No description provided for @workoutSummarySetsLoggedLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets Logged'**
  String get workoutSummarySetsLoggedLabel;

  /// No description provided for @workoutSummaryPerformanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get workoutSummaryPerformanceLabel;

  /// No description provided for @workoutSummaryDurationSuffix.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get workoutSummaryDurationSuffix;

  /// No description provided for @workoutSummarySkippedPill.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get workoutSummarySkippedPill;

  /// No description provided for @workoutSummaryErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your workout'**
  String get workoutSummaryErrorTitle;

  /// No description provided for @workoutSummaryErrorNote.
  ///
  /// In en, this message translates to:
  /// **'Your logged sets are still here — tap Retry to save again. Nothing has been recorded to your history yet.'**
  String get workoutSummaryErrorNote;

  /// No description provided for @workoutSummaryRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get workoutSummaryRetryButton;

  /// No description provided for @workoutSummaryInvalidNote.
  ///
  /// In en, this message translates to:
  /// **'Some of the logged values are not valid, so this workout can\'t be saved. Nothing has been recorded to your history.'**
  String get workoutSummaryInvalidNote;

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyScreenTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout history yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your completed workouts will appear here.'**
  String get historyEmptySubtitle;

  /// No description provided for @historyErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your history'**
  String get historyErrorTitle;

  /// No description provided for @historyErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading local data. Your plans and schedule are unaffected.'**
  String get historyErrorBody;

  /// No description provided for @historyRetryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get historyRetryLabel;

  /// No description provided for @detailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Detail'**
  String get detailScreenTitle;

  /// No description provided for @detailErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this workout'**
  String get detailErrorTitle;

  /// No description provided for @detailErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading local data. Your workout history is unaffected.'**
  String get detailErrorBody;

  /// No description provided for @progressScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressScreenTitle;

  /// No description provided for @progressErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your progress'**
  String get progressErrorTitle;

  /// No description provided for @progressErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong reading local data. Your workout history is unaffected.'**
  String get progressErrorBody;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a few more workouts to see your progress.'**
  String get progressEmptySubtitle;

  /// No description provided for @progressLatestSessionLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest Session'**
  String get progressLatestSessionLabel;

  /// No description provided for @progressTopWeight.
  ///
  /// In en, this message translates to:
  /// **'Top Weight'**
  String get progressTopWeight;

  /// No description provided for @progressBestReps.
  ///
  /// In en, this message translates to:
  /// **'Best Reps'**
  String get progressBestReps;

  /// No description provided for @progressVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get progressVolume;

  /// No description provided for @progressTotalReps.
  ///
  /// In en, this message translates to:
  /// **'Total Reps'**
  String get progressTotalReps;

  /// No description provided for @progressTotalSets.
  ///
  /// In en, this message translates to:
  /// **'Total Sets'**
  String get progressTotalSets;

  /// No description provided for @progressBestDuration.
  ///
  /// In en, this message translates to:
  /// **'Best Duration'**
  String get progressBestDuration;

  /// No description provided for @progressTotalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get progressTotalTime;

  /// No description provided for @progressSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get progressSets;

  /// No description provided for @progressWorkoutDuration.
  ///
  /// In en, this message translates to:
  /// **'Workout Time'**
  String get progressWorkoutDuration;

  /// No description provided for @progressChartWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get progressChartWeight;

  /// No description provided for @progressChartDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get progressChartDuration;

  /// No description provided for @progressChartReps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get progressChartReps;

  /// No description provided for @progressWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get progressWeightUnit;

  /// No description provided for @progressRepsUnit.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get progressRepsUnit;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get statsTitle;

  /// No description provided for @statsWorkoutsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workouts Completed'**
  String get statsWorkoutsCompleted;

  /// No description provided for @statsTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total Volume'**
  String get statsTotalVolume;

  /// No description provided for @statsTotalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Duration'**
  String get statsTotalDuration;

  /// No description provided for @statsAvgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get statsAvgDuration;

  /// No description provided for @statsExerciseBreakdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise Breakdown'**
  String get statsExerciseBreakdownLabel;

  /// No description provided for @statsRecordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get statsRecordsLabel;

  /// No description provided for @statsPersonalBestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Bests'**
  String get statsPersonalBestsTitle;

  /// No description provided for @statsPersonalBestsSub.
  ///
  /// In en, this message translates to:
  /// **'Your all-time top performances'**
  String get statsPersonalBestsSub;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No stats yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptySub.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to start building your statistics.'**
  String get statsEmptySub;

  /// No description provided for @statsEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Start a Workout'**
  String get statsEmptyCta;

  /// No description provided for @statsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your stats'**
  String get statsErrorTitle;

  /// No description provided for @statsErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong calculating your statistics. Your workout history is unaffected.'**
  String get statsErrorBody;

  /// No description provided for @statsBestWeight.
  ///
  /// In en, this message translates to:
  /// **'Best weight'**
  String get statsBestWeight;

  /// No description provided for @statsBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get statsBestTime;

  /// No description provided for @statsBestReps.
  ///
  /// In en, this message translates to:
  /// **'Best reps'**
  String get statsBestReps;

  /// No description provided for @statsVolumeUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get statsVolumeUnit;

  /// No description provided for @statsMinutesUnit.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get statsMinutesUnit;

  /// No description provided for @statsSecondsUnit.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get statsSecondsUnit;

  /// No description provided for @statsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get statsNotAvailable;

  /// No description provided for @pbScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Bests'**
  String get pbScreenTitle;

  /// No description provided for @pbEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No personal bests yet'**
  String get pbEmptyTitle;

  /// No description provided for @pbEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete a workout to start setting personal bests.'**
  String get pbEmptySubtitle;

  /// No description provided for @pbErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your personal bests'**
  String get pbErrorTitle;

  /// No description provided for @pbErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong calculating this data. Your workout history is unaffected.'**
  String get pbErrorBody;

  /// No description provided for @pbBadgeWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Best weight'**
  String get pbBadgeWeightLabel;

  /// No description provided for @pbBadgeTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get pbBadgeTimeLabel;

  /// No description provided for @pbBadgeRepsLabel.
  ///
  /// In en, this message translates to:
  /// **'Best reps'**
  String get pbBadgeRepsLabel;

  /// No description provided for @pbWeightUnit.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get pbWeightUnit;

  /// No description provided for @pbRepsUnit.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get pbRepsUnit;

  /// No description provided for @weekdayShortMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayShortMon;

  /// No description provided for @weekdayFullMon.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayFullMon;

  /// No description provided for @weekdayShortTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayShortTue;

  /// No description provided for @weekdayFullTue.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayFullTue;

  /// No description provided for @weekdayShortWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayShortWed;

  /// No description provided for @weekdayFullWed.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayFullWed;

  /// No description provided for @weekdayShortThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayShortThu;

  /// No description provided for @weekdayFullThu.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayFullThu;

  /// No description provided for @weekdayShortFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayShortFri;

  /// No description provided for @weekdayFullFri.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFullFri;

  /// No description provided for @weekdayShortSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdayShortSat;

  /// No description provided for @weekdayFullSat.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdayFullSat;

  /// No description provided for @weekdayShortSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdayShortSun;

  /// No description provided for @weekdayFullSun.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdayFullSun;

  /// No description provided for @profileExperienceBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get profileExperienceBeginner;

  /// No description provided for @profileExperienceIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get profileExperienceIntermediate;

  /// No description provided for @profileExperienceAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get profileExperienceAdvanced;

  /// No description provided for @cancelWorkoutBodyWithPlan.
  ///
  /// In en, this message translates to:
  /// **'Your progress on \"{planName}\" won\'t be saved. This session won\'t appear in your workout history.'**
  String cancelWorkoutBodyWithPlan(String planName);

  /// No description provided for @workoutSummaryErrorPlan.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong writing \"{planName}\" to local storage.'**
  String workoutSummaryErrorPlan(String planName);

  /// No description provided for @historySummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min · {exercises, plural, =1{1 exercise} other{{exercises} exercises}} · {sets, plural, =1{1 set} other{{sets} sets}}'**
  String historySummaryLine(int minutes, int exercises, int sets);

  /// No description provided for @setPillWeighted.
  ///
  /// In en, this message translates to:
  /// **'{reps}×{weight}kg'**
  String setPillWeighted(int reps, String weight);

  /// No description provided for @setPillReps.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps'**
  String setPillReps(int reps);

  /// No description provided for @restTimerTargetReps.
  ///
  /// In en, this message translates to:
  /// **'{reps} reps'**
  String restTimerTargetReps(int reps);

  /// No description provided for @restTimerTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String restTimerTargetWeight(String weight);

  /// No description provided for @restTimerTargetDuration.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String restTimerTargetDuration(int seconds);

  /// No description provided for @restTimerTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {value}'**
  String restTimerTarget(String value);

  /// No description provided for @restTimerUpNextName.
  ///
  /// In en, this message translates to:
  /// **'{exercise} — Set {setNumber} of {totalSets}'**
  String restTimerUpNextName(String exercise, int setNumber, int totalSets);

  /// No description provided for @activeWorkoutSetOf.
  ///
  /// In en, this message translates to:
  /// **'Set {current} / {total}'**
  String activeWorkoutSetOf(int current, int total);

  /// No description provided for @activeWorkoutExerciseOf.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} / {total}'**
  String activeWorkoutExerciseOf(int current, int total);

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeTitle;

  /// No description provided for @authWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get authWelcomeSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignInButton;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get authInvalidCredentials;

  /// No description provided for @exerciseFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get exerciseFilterAll;

  /// No description provided for @planDetailRestValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String planDetailRestValue(int seconds);

  /// No description provided for @exerciseCatalogueTitle.
  ///
  /// In en, this message translates to:
  /// **'Exercise Catalogue'**
  String get exerciseCatalogueTitle;

  /// No description provided for @exerciseCatalogueNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No exercises match your search'**
  String get exerciseCatalogueNoMatchTitle;

  /// No description provided for @exerciseCatalogueNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different name or clear the filter.'**
  String get exerciseCatalogueNoMatchSubtitle;

  /// No description provided for @exerciseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search exercises'**
  String get exerciseSearchHint;

  /// No description provided for @pickerBannerPrefix.
  ///
  /// In en, this message translates to:
  /// **'Adding an exercise to '**
  String get pickerBannerPrefix;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'Plans'**
  String get navPlans;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @homeGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, Athlete'**
  String get homeGreetingMorning;

  /// No description provided for @homeGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, Athlete'**
  String get homeGreetingAfternoon;

  /// No description provided for @homeGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, Athlete'**
  String get homeGreetingEvening;

  /// No description provided for @homeProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfileTooltip;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first plan to get started'**
  String get homeEmptySubtitle;

  /// No description provided for @homeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create your first workout plan'**
  String get homeEmptyCta;

  /// No description provided for @homeReadyForPlan.
  ///
  /// In en, this message translates to:
  /// **'Ready for your scheduled {planName}?'**
  String homeReadyForPlan(String planName);

  /// No description provided for @homeNoPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No workout planned for today'**
  String get homeNoPlanSubtitle;

  /// No description provided for @homeDailyIntentionTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily intention'**
  String get homeDailyIntentionTitle;

  /// No description provided for @homeQuote1.
  ///
  /// In en, this message translates to:
  /// **'Consistency beats intensity every single time. Honor your tempo and show up with intent.'**
  String get homeQuote1;

  /// No description provided for @homeQuote2.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have to be extreme, just consistent.'**
  String get homeQuote2;

  /// No description provided for @homeQuote3.
  ///
  /// In en, this message translates to:
  /// **'Small sets, done daily, build the strongest habits.'**
  String get homeQuote3;

  /// No description provided for @homeQuote4.
  ///
  /// In en, this message translates to:
  /// **'Strength is built one honest rep at a time.'**
  String get homeQuote4;

  /// No description provided for @homeQuote5.
  ///
  /// In en, this message translates to:
  /// **'Show up today. Future you will say thanks.'**
  String get homeQuote5;

  /// No description provided for @homeQuote6.
  ///
  /// In en, this message translates to:
  /// **'Progress is quiet. Trust the work you can\'t see yet.'**
  String get homeQuote6;

  /// No description provided for @homeQuote7.
  ///
  /// In en, this message translates to:
  /// **'Warm up the body, then focus the mind.'**
  String get homeQuote7;

  /// No description provided for @homeQuote8.
  ///
  /// In en, this message translates to:
  /// **'Rest is part of the plan, not a break from it.'**
  String get homeQuote8;

  /// No description provided for @homePlannedForToday.
  ///
  /// In en, this message translates to:
  /// **'Planned for today · ~{minutes} min'**
  String homePlannedForToday(int minutes);

  /// No description provided for @homeStatVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get homeStatVolume;

  /// No description provided for @homeStatExercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get homeStatExercises;

  /// No description provided for @homeStatSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get homeStatSets;

  /// No description provided for @homeVolumeApprox.
  ///
  /// In en, this message translates to:
  /// **'~{value} kg'**
  String homeVolumeApprox(String value);

  /// No description provided for @homeExerciseSequence.
  ///
  /// In en, this message translates to:
  /// **'Exercise sequence'**
  String get homeExerciseSequence;

  /// No description provided for @homeMovementCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 movement} other{{count} movements}}'**
  String homeMovementCount(int count);

  /// No description provided for @homeRowWeighted.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =1{1 set} other{{sets} sets}} · {reps} reps · {weight} kg'**
  String homeRowWeighted(int sets, int reps, String weight);

  /// No description provided for @homeRowBodyweight.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =1{1 set} other{{sets} sets}} · {reps} reps'**
  String homeRowBodyweight(int sets, int reps);

  /// No description provided for @homeRowTimed.
  ///
  /// In en, this message translates to:
  /// **'{sets, plural, =1{1 set} other{{sets} sets}} · {duration}'**
  String homeRowTimed(int sets, String duration);

  /// No description provided for @homeStartTodaysWorkout.
  ///
  /// In en, this message translates to:
  /// **'Start today\'s workout'**
  String get homeStartTodaysWorkout;

  /// No description provided for @homeDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get homeDoneToday;

  /// No description provided for @homeDoItAgain.
  ///
  /// In en, this message translates to:
  /// **'Do it again'**
  String get homeDoItAgain;

  /// No description provided for @startAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Already done today'**
  String get startAgainTitle;

  /// No description provided for @startAgainMessage.
  ///
  /// In en, this message translates to:
  /// **'You already completed {planName} today. Start another session?'**
  String startAgainMessage(String planName);

  /// No description provided for @startAgainConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start anyway'**
  String get startAgainConfirm;

  /// No description provided for @startAgainCancel.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get startAgainCancel;

  /// No description provided for @homeNoWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout planned today'**
  String get homeNoWorkoutTitle;

  /// No description provided for @homeNoWorkoutNext.
  ///
  /// In en, this message translates to:
  /// **'Your next session is {day} · {planName}'**
  String homeNoWorkoutNext(String day, String planName);

  /// No description provided for @homeNoWorkoutNoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule a plan and it will show up here.'**
  String get homeNoWorkoutNoSchedule;

  /// No description provided for @homeNothingScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled yet'**
  String get homeNothingScheduledTitle;

  /// No description provided for @homeViewSchedule.
  ///
  /// In en, this message translates to:
  /// **'View schedule'**
  String get homeViewSchedule;

  /// No description provided for @homeScheduleAPlan.
  ///
  /// In en, this message translates to:
  /// **'Schedule a plan'**
  String get homeScheduleAPlan;

  /// No description provided for @homeThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get homeThisWeek;

  /// No description provided for @homeWeekDaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{day}: {status}'**
  String homeWeekDaySemantics(String day, String status);

  /// No description provided for @homeWeekDayCompleted.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get homeWeekDayCompleted;

  /// No description provided for @homeWeekDayPlanned.
  ///
  /// In en, this message translates to:
  /// **'planned'**
  String get homeWeekDayPlanned;

  /// No description provided for @homeWeekDayRest.
  ///
  /// In en, this message translates to:
  /// **'rest'**
  String get homeWeekDayRest;

  /// No description provided for @homeWeekDayMissed.
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get homeWeekDayMissed;

  /// No description provided for @homeWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} done'**
  String homeWeekProgress(int done, int total);

  /// No description provided for @homeWeekDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'{day} · {plan} · {count, plural, =1{1 workout done} other{{count} workouts done}}'**
  String homeWeekDetailCompleted(String day, String plan, int count);

  /// No description provided for @homeWeekDetailPlanned.
  ///
  /// In en, this message translates to:
  /// **'{day} · {plan} · planned'**
  String homeWeekDetailPlanned(String day, String plan);

  /// No description provided for @homeWeekDetailMissed.
  ///
  /// In en, this message translates to:
  /// **'{day} · {plan} · missed'**
  String homeWeekDetailMissed(String day, String plan);

  /// No description provided for @homeWeekDetailRest.
  ///
  /// In en, this message translates to:
  /// **'{day} · Rest day'**
  String homeWeekDetailRest(String day);

  /// No description provided for @homeLastWorkout.
  ///
  /// In en, this message translates to:
  /// **'Last workout'**
  String get homeLastWorkout;

  /// No description provided for @homeLastWorkoutDetails.
  ///
  /// In en, this message translates to:
  /// **'{date} · {minutes} min · {volume} kg'**
  String homeLastWorkoutDetails(String date, int minutes, String volume);

  /// No description provided for @homeNoWorkoutsLoggedTitle.
  ///
  /// In en, this message translates to:
  /// **'No workouts logged yet'**
  String get homeNoWorkoutsLoggedTitle;

  /// No description provided for @homeNoWorkoutsLoggedBody.
  ///
  /// In en, this message translates to:
  /// **'Finish a workout and your last session will appear here.'**
  String get homeNoWorkoutsLoggedBody;

  /// No description provided for @homeWarmupTitle.
  ///
  /// In en, this message translates to:
  /// **'Warm-up focus'**
  String get homeWarmupTitle;

  /// No description provided for @homeWarmupGeneric.
  ///
  /// In en, this message translates to:
  /// **'Five minutes of light cardio and joint circles before the first working set.'**
  String get homeWarmupGeneric;

  /// No description provided for @homeWarmupTipChest.
  ///
  /// In en, this message translates to:
  /// **'Band pull-aparts and arm circles open the chest and shoulders before pressing.'**
  String get homeWarmupTipChest;

  /// No description provided for @homeWarmupTipBack.
  ///
  /// In en, this message translates to:
  /// **'Cat-cow and light band rows wake up your back before pulling.'**
  String get homeWarmupTipBack;

  /// No description provided for @homeWarmupTipLegs.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight squats and hip openers prepare your legs for load.'**
  String get homeWarmupTipLegs;

  /// No description provided for @homeWarmupTipShoulders.
  ///
  /// In en, this message translates to:
  /// **'Band pull-aparts and thoracic rotations prime the shoulders before pressing.'**
  String get homeWarmupTipShoulders;

  /// No description provided for @homeWarmupTipBiceps.
  ///
  /// In en, this message translates to:
  /// **'Light curls and wrist circles get the elbows ready.'**
  String get homeWarmupTipBiceps;

  /// No description provided for @homeWarmupTipTriceps.
  ///
  /// In en, this message translates to:
  /// **'Arm swings and light pushdowns warm up the elbows.'**
  String get homeWarmupTipTriceps;

  /// No description provided for @homeWarmupTipCore.
  ///
  /// In en, this message translates to:
  /// **'Dead bugs and plank holds switch your core on.'**
  String get homeWarmupTipCore;

  /// No description provided for @homeRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery tip'**
  String get homeRecoveryTitle;

  /// No description provided for @homeRecoveryTip1.
  ///
  /// In en, this message translates to:
  /// **'Take a short walk and stretch the muscles you trained last.'**
  String get homeRecoveryTip1;

  /// No description provided for @homeRecoveryTip2.
  ///
  /// In en, this message translates to:
  /// **'Aim for a full night of sleep; that is when strength is built.'**
  String get homeRecoveryTip2;

  /// No description provided for @homeRecoveryTip3.
  ///
  /// In en, this message translates to:
  /// **'Drink water through the day and eat protein with every meal.'**
  String get homeRecoveryTip3;

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 exercise} other{{count} exercises}}'**
  String exerciseCount(int count);

  /// No description provided for @setCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 set} other{{count} sets}}'**
  String setCount(int count);

  /// No description provided for @sessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String sessionCount(int count);

  /// No description provided for @workoutPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout Plans'**
  String get workoutPlansTitle;

  /// No description provided for @plansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No workout plans yet'**
  String get plansEmptyTitle;

  /// No description provided for @plansEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build your first workout plan to see it listed here.'**
  String get plansEmptySubtitle;

  /// No description provided for @plansEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Create a workout plan'**
  String get plansEmptyCta;

  /// No description provided for @weightKgValue.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightKgValue(String weight);

  /// No description provided for @valueNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get valueNotAvailable;

  /// No description provided for @preStartMetaScheduled.
  ///
  /// In en, this message translates to:
  /// **'{day} · {exercises}'**
  String preStartMetaScheduled(String day, String exercises);

  /// No description provided for @preStartMetaScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'{day} · Today · {exercises}'**
  String preStartMetaScheduledToday(String day, String exercises);

  /// No description provided for @dayChipNotSelected.
  ///
  /// In en, this message translates to:
  /// **'{day}. Not selected.'**
  String dayChipNotSelected(String day);

  /// No description provided for @dayChipSelected.
  ///
  /// In en, this message translates to:
  /// **'{day}. Selected.'**
  String dayChipSelected(String day);

  /// No description provided for @dayChipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{day}. Unavailable — conflicts.'**
  String dayChipUnavailable(String day);

  /// No description provided for @scheduleConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'{day} already has \"{plan}\" scheduled. Remove it from the Schedule tab first, or pick another day.'**
  String scheduleConflictMessage(String day, String plan);

  /// No description provided for @scheduleHelperScheduledOn.
  ///
  /// In en, this message translates to:
  /// **'Scheduled on {days}.'**
  String scheduleHelperScheduledOn(String days);

  /// No description provided for @recurrenceSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}. {subtitle}. Toggle locked.'**
  String recurrenceSemantics(String title, String subtitle);

  /// No description provided for @invalidPlanBannerSemantics.
  ///
  /// In en, this message translates to:
  /// **'{title}. {subtitle}'**
  String invalidPlanBannerSemantics(String title, String subtitle);

  /// No description provided for @removeScheduleMessage.
  ///
  /// In en, this message translates to:
  /// **'{plan} on {day} will be removed. Your history is unaffected.'**
  String removeScheduleMessage(String plan, String day);

  /// No description provided for @deletePlanDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'“{planName}” and its schedule assignments will be removed. Past workout sessions using this plan are unaffected.'**
  String deletePlanDialogMessage(String planName);

  /// No description provided for @pageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get pageNotFoundTitle;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {location}'**
  String pageNotFoundMessage(String location);

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Logging out permanently deletes your profile, workout plans, schedules and workout history from this device. This can\'t be undone.'**
  String get logoutDialogMessage;

  /// No description provided for @logoutCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get logoutCancelButton;

  /// No description provided for @logoutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutConfirmButton;

  /// No description provided for @logoutBusyLabel.
  ///
  /// In en, this message translates to:
  /// **'Logging out…'**
  String get logoutBusyLabel;

  /// No description provided for @logoutRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get logoutRetryButton;

  /// No description provided for @logoutError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t clear your data. Please try again.'**
  String get logoutError;

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @restTimerSemantics.
  ///
  /// In en, this message translates to:
  /// **'Rest timer: {time}'**
  String restTimerSemantics(String time);

  /// No description provided for @progressChartTitle.
  ///
  /// In en, this message translates to:
  /// **'{exercise} — {metric}'**
  String progressChartTitle(String exercise, String metric);

  /// No description provided for @progressTrendRising.
  ///
  /// In en, this message translates to:
  /// **'▲ {change} vs previous session'**
  String progressTrendRising(String change);

  /// No description provided for @progressTrendFalling.
  ///
  /// In en, this message translates to:
  /// **'▼ {change} vs previous session'**
  String progressTrendFalling(String change);

  /// No description provided for @pbDateSet.
  ///
  /// In en, this message translates to:
  /// **'Set {date}'**
  String pbDateSet(String date);

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dashboard'**
  String get homeLoadError;

  /// No description provided for @exerciseCatalogueLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the exercise catalogue'**
  String get exerciseCatalogueLoadError;

  /// No description provided for @scheduleSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your schedule'**
  String get scheduleSaveError;

  /// No description provided for @scheduleRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t remove this entry'**
  String get scheduleRemoveError;

  /// No description provided for @plansLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your workout plans'**
  String get plansLoadError;

  /// No description provided for @planLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the workout plan'**
  String get planLoadError;

  /// No description provided for @planDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the plan'**
  String get planDeleteError;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Forge'**
  String get appTitle;

  /// No description provided for @durationFormatError.
  ///
  /// In en, this message translates to:
  /// **'Enter duration as mm:ss'**
  String get durationFormatError;

  /// No description provided for @historyDetailEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit workout'**
  String get historyDetailEditTooltip;

  /// No description provided for @historyDetailDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete workout'**
  String get historyDetailDeleteTooltip;

  /// No description provided for @deleteSessionDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this workout?'**
  String get deleteSessionDialogTitle;

  /// No description provided for @deleteSessionDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'This workout will be removed from your history. Your statistics and progress will update to match. This can\'t be undone.'**
  String get deleteSessionDialogMessage;

  /// No description provided for @deleteSessionCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteSessionCancelButton;

  /// No description provided for @deleteSessionDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSessionDeleteButton;

  /// No description provided for @deleteSessionDeletingLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get deleteSessionDeletingLabel;

  /// No description provided for @deleteSessionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get deleteSessionRetryButton;

  /// No description provided for @deleteSessionError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the workout. Nothing was removed.'**
  String get deleteSessionError;

  /// No description provided for @editSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Workout'**
  String get editSessionTitle;

  /// No description provided for @editSessionSetLabel.
  ///
  /// In en, this message translates to:
  /// **'Set {number}'**
  String editSessionSetLabel(int number);

  /// No description provided for @editSessionSkippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get editSessionSkippedLabel;

  /// No description provided for @editSessionSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get editSessionSaveButton;

  /// No description provided for @editSessionSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get editSessionSavingLabel;

  /// No description provided for @editSessionRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get editSessionRetryButton;

  /// No description provided for @editSessionNoValidSetError.
  ///
  /// In en, this message translates to:
  /// **'Keep at least one completed set. Un-skip a set and fill in its values.'**
  String get editSessionNoValidSetError;

  /// No description provided for @editSessionSaveError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your changes. The workout was not changed.'**
  String get editSessionSaveError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
