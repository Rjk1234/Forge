// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createPlanTitle => 'Create Plan';

  @override
  String get editPlanTitle => 'Edit Plan';

  @override
  String get planNameLabel => 'Plan Name';

  @override
  String get planNameHint => 'e.g. Push Day';

  @override
  String get planNameRequiredError => 'Plan name is required';

  @override
  String get planExercisesRequiredError => 'Add at least one exercise';

  @override
  String get planFillHighlightedFieldsError => 'Fill in the highlighted fields';

  @override
  String get addExerciseButton => 'Add Exercise';

  @override
  String get savePlanButton => 'Save Plan';

  @override
  String get retryButton => 'Retry';

  @override
  String get removeExerciseTooltip => 'Remove exercise';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsLabel => 'Reps';

  @override
  String get durationLabel => 'Duration';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get restLabel => 'Rest (s)';

  @override
  String setsError(int max) {
    return 'Enter a whole number of sets from 1 to $max';
  }

  @override
  String repsError(int max) {
    return 'Enter a whole number of reps from 1 to $max';
  }

  @override
  String get durationError => 'Enter a valid duration (mm:ss)';

  @override
  String weightError(int max) {
    return 'Enter a weight above 0 and up to $max kg';
  }

  @override
  String restError(int max) {
    return 'Enter a rest period from 0 to $max seconds';
  }

  @override
  String get savePlanFailureMessage =>
      'Could not save the plan. Please try again.';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved changes. If you go back now, your changes will be lost.';

  @override
  String get discardButton => 'Discard';

  @override
  String get keepEditingButton => 'Keep Editing';

  @override
  String get loadPlanError => 'Couldn\'t load the workout plan.';

  @override
  String get exerciseTypeBadgeWeighted => 'Weighted';

  @override
  String get exerciseTypeBadgeTimeBased => 'Time-based';

  @override
  String get exerciseTypeBadgeBodyweight => 'Bodyweight';

  @override
  String get noPlanExercisesMessage =>
      'Tap \"Add Exercise\" to build your plan.';

  @override
  String get planDetailStartWorkoutButton => 'Start Workout';

  @override
  String get planDetailScheduleButton => 'Schedule';

  @override
  String get planDetailEditTooltip => 'Edit plan';

  @override
  String get planDetailDeleteTooltip => 'Delete plan';

  @override
  String get planDetailBackTooltip => 'Back';

  @override
  String get planDetailExercisesSectionLabel => 'EXERCISES';

  @override
  String get planDetailLoadingSemantics => 'Loading plan details';

  @override
  String get planDetailWeightLabel => 'Weight';

  @override
  String get planDetailRestLabel => 'Rest';

  @override
  String get planNotAvailableTitle => 'This plan is no longer available';

  @override
  String get planNotAvailableBody =>
      'It may have been deleted, or something went wrong reading local data.';

  @override
  String get planNotAvailableButton => 'Back to Plans';

  @override
  String get exerciseUnavailableName => 'Exercise unavailable';

  @override
  String get deletePlanDialogTitle => 'Delete this workout plan?';

  @override
  String get deletePlanCancelButton => 'Cancel';

  @override
  String get deletePlanDeleteButton => 'Delete';

  @override
  String get deletePlanDeletingLabel => 'Deleting…';

  @override
  String get deletePlanRetryButton => 'Retry';

  @override
  String get deletePlanErrorMessage =>
      'Couldn\'t delete the plan — something went wrong writing to local storage. Nothing was removed.';

  @override
  String get scheduleScreenTitle => 'Schedule';

  @override
  String get scheduleRestDayLabel => 'Rest day';

  @override
  String get scheduleRecurrenceWeekly => 'Weekly';

  @override
  String get scheduleTodayMeta => 'Weekly · Today';

  @override
  String get scheduleEditTooltip => 'Edit schedule for this day';

  @override
  String get scheduleRowMenuTooltip => 'More options for this day';

  @override
  String get scheduleChangeDaysAction => 'Change days';

  @override
  String get scheduleRemoveAction => 'Remove from this day';

  @override
  String get scheduleStartButton => 'Start';

  @override
  String get scheduleEmptyTitle => 'No workouts scheduled';

  @override
  String get scheduleEmptySubtitle => 'Assign a plan to a day to see it here.';

  @override
  String get scheduleEmptyCta => 'Schedule a plan';

  @override
  String get scheduleErrorTitle => 'Couldn\'t load your schedule';

  @override
  String get scheduleErrorReassurance => 'Your plans and history are safe.';

  @override
  String get scheduleRetryButton => 'Retry';

  @override
  String get scheduleLoadingSemantics => 'Loading schedule';

  @override
  String get newScheduleTitle => 'New Schedule';

  @override
  String get editScheduleTitle => 'Edit Schedule';

  @override
  String get assignScheduleLoadingSemantics => 'Loading schedule assignment';

  @override
  String get workoutPlanFieldLabel => 'WORKOUT PLAN';

  @override
  String get workoutPlanSemanticsPrefix => 'Workout Plan: ';

  @override
  String get daysFieldLabel => 'DAYS';

  @override
  String get recurrenceFieldLabel => 'RECURRENCE';

  @override
  String get selectAtLeastOneDayHelper =>
      'Select at least one day to schedule this plan.';

  @override
  String get recurrenceWeeklyTitle => 'Repeats weekly';

  @override
  String get recurrenceWeeklySubtitle => 'Only weekly recurrence is supported';

  @override
  String get saveScheduleButton => 'Save Schedule';

  @override
  String get retrySaveScheduleButton => 'Retry Save';

  @override
  String get savingScheduleLabel => 'Saving…';

  @override
  String get invalidPlanBannerTitle => 'This plan is no longer available';

  @override
  String get invalidPlanBannerSubtitle =>
      'It may have been deleted. Choose a different plan to schedule.';

  @override
  String get scheduleSaveFailureSubtitle =>
      'Something went wrong writing to local storage. Nothing was changed — tap Retry to try again.';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get profileDisplayNameLabel => 'Display Name';

  @override
  String get profileDisplayNameHint => 'Your name';

  @override
  String get profileFitnessGoalLabel => 'Fitness Goal';

  @override
  String get profileFitnessGoalHint => 'Select a goal';

  @override
  String get profileExperienceLevelLabel => 'Experience Level';

  @override
  String get profileHeightLabel => 'Height (cm)';

  @override
  String get profileHeightHint => 'e.g. 178';

  @override
  String get profileWeightLabel => 'Weight (kg)';

  @override
  String get profileWeightHint => 'e.g. 76';

  @override
  String get profileSaveChanges => 'Save Changes';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String get profileLogOut => 'Log Out';

  @override
  String get profileInvalidNumber => 'Enter a valid positive number.';

  @override
  String get profileFixFields => 'Fix the highlighted fields to save.';

  @override
  String get profileLoadErrorTitle => 'Couldn\'t load your profile';

  @override
  String get profileSaveErrorTitle => 'Couldn\'t save your profile';

  @override
  String get profileLoadErrorBody =>
      'Something went wrong reading local storage. Tap Retry to try again.';

  @override
  String get profileSaveErrorBody =>
      'Something went wrong writing to local storage. Tap Retry to try again.';

  @override
  String get profileRetry => 'Retry';

  @override
  String get profileFitnessGoalBuildMuscle => 'Build Muscle';

  @override
  String get profileFitnessGoalLoseWeight => 'Lose Weight';

  @override
  String get profileFitnessGoalGeneralFitness => 'General Fitness';

  @override
  String get removeScheduleTitle => 'Remove from schedule?';

  @override
  String get removeScheduleConfirmButton => 'Remove';

  @override
  String get removeScheduleRetryButton => 'Retry';

  @override
  String get removeScheduleCancelButton => 'Cancel';

  @override
  String get removeScheduleRemovingLabel => 'Removing…';

  @override
  String get removeScheduleErrorMessage =>
      'Couldn\'t remove this entry. Please try again.';

  @override
  String get preStartScreenTitle => 'Overview';

  @override
  String get preStartExercisesSectionLabel => 'EXERCISES';

  @override
  String get preStartBeginButton => 'Begin Workout';

  @override
  String get preStartWeightNotSet => '—';

  @override
  String get preStartUnavailableTitle => 'This plan is no longer available';

  @override
  String get preStartUnavailableBody =>
      'It may have been deleted or has no exercises configured.';

  @override
  String get preStartBackToScheduleButton => 'Back to Schedule';

  @override
  String get preStartErrorTitle => 'Couldn\'t load this workout';

  @override
  String get preStartErrorBody =>
      'Something went wrong reading local data. Your data is safe — tap Retry to try again.';

  @override
  String get preStartRetryButton => 'Retry';

  @override
  String get preStartLoadingSemantics => 'Loading workout overview';

  @override
  String get activeWorkoutCompleteSetButton => 'Complete Set';

  @override
  String get activeWorkoutSkipButton => 'Skip';

  @override
  String get activeWorkoutPauseButton => 'Pause';

  @override
  String get activeWorkoutResumeButton => 'Resume';

  @override
  String get activeWorkoutCancelButton => 'Cancel';

  @override
  String get activeWorkoutRepsLabel => 'Reps';

  @override
  String get activeWorkoutWeightLabel => 'Weight (kg)';

  @override
  String get activeWorkoutDurationLabel => 'Duration';

  @override
  String activeWorkoutRepsError(int max) {
    return 'Enter reps from 1 to $max';
  }

  @override
  String activeWorkoutWeightError(int max) {
    return 'Enter a weight above 0 and up to $max kg';
  }

  @override
  String activeWorkoutDurationError(int max) {
    return 'Enter a duration from 1 to $max seconds';
  }

  @override
  String get activeWorkoutPausedTitle => 'Workout Paused';

  @override
  String get restTimerRestingLabel => 'Resting';

  @override
  String get restTimerSkipRestButton => 'Skip Rest';

  @override
  String get restTimerUpNextLabel => 'Up Next';

  @override
  String get restTimerMetaSeparator => '·';

  @override
  String get cancelWorkoutTitle => 'Cancel this workout?';

  @override
  String get cancelWorkoutBodyWithoutPlan =>
      'Your progress won\'t be saved. This session won\'t appear in your workout history.';

  @override
  String get cancelWorkoutKeepGoingButton => 'Keep Going';

  @override
  String get cancelWorkoutDiscardButton => 'Discard Workout';

  @override
  String get workoutSummaryAppBarTitle => 'Workout Complete';

  @override
  String get workoutSummaryLoadingAppBarTitle => 'Active Workout';

  @override
  String get workoutSummaryLoadingButton => 'Saving Workout…';

  @override
  String get workoutSummaryDoneButton => 'Done';

  @override
  String get workoutSummaryViewHistoryButton => 'View History';

  @override
  String get workoutSummaryDurationLabel => 'Duration';

  @override
  String get workoutSummaryExercisesLabel => 'Exercises';

  @override
  String get workoutSummarySetsLoggedLabel => 'Sets Logged';

  @override
  String get workoutSummaryPerformanceLabel => 'Performance';

  @override
  String get workoutSummaryDurationSuffix => 'min';

  @override
  String get workoutSummarySkippedPill => 'Skipped';

  @override
  String get workoutSummaryErrorTitle => 'Couldn\'t save your workout';

  @override
  String get workoutSummaryErrorNote =>
      'Your logged sets are still here — tap Retry to save again. Nothing has been recorded to your history yet.';

  @override
  String get workoutSummaryRetryButton => 'Retry';

  @override
  String get workoutSummaryInvalidNote =>
      'Some of the logged values are not valid, so this workout can\'t be saved. Nothing has been recorded to your history.';

  @override
  String get historyScreenTitle => 'History';

  @override
  String get historyEmptyTitle => 'No workout history yet';

  @override
  String get historyEmptySubtitle =>
      'Your completed workouts will appear here.';

  @override
  String get historyErrorTitle => 'Couldn\'t load your history';

  @override
  String get historyErrorBody =>
      'Something went wrong reading local data. Your plans and schedule are unaffected.';

  @override
  String get historyRetryLabel => 'Retry';

  @override
  String get detailScreenTitle => 'Workout Detail';

  @override
  String get detailErrorTitle => 'Couldn\'t load this workout';

  @override
  String get detailErrorBody =>
      'Something went wrong reading local data. Your workout history is unaffected.';

  @override
  String get progressScreenTitle => 'Progress';

  @override
  String get progressErrorTitle => 'Couldn\'t load your progress';

  @override
  String get progressErrorBody =>
      'Something went wrong reading local data. Your workout history is unaffected.';

  @override
  String get progressEmptyTitle => 'Not enough data yet';

  @override
  String get progressEmptySubtitle =>
      'Complete a few more workouts to see your progress.';

  @override
  String get progressLatestSessionLabel => 'Latest Session';

  @override
  String get progressTopWeight => 'Top Weight';

  @override
  String get progressBestReps => 'Best Reps';

  @override
  String get progressVolume => 'Volume';

  @override
  String get progressTotalReps => 'Total Reps';

  @override
  String get progressTotalSets => 'Total Sets';

  @override
  String get progressBestDuration => 'Best Duration';

  @override
  String get progressTotalTime => 'Total Time';

  @override
  String get progressSets => 'Sets';

  @override
  String get progressWorkoutDuration => 'Workout Time';

  @override
  String get progressChartWeight => 'Weight';

  @override
  String get progressChartDuration => 'Duration';

  @override
  String get progressChartReps => 'Reps';

  @override
  String get progressWeightUnit => 'kg';

  @override
  String get progressRepsUnit => 'reps';

  @override
  String get statsTitle => 'Stats';

  @override
  String get statsWorkoutsCompleted => 'Workouts Completed';

  @override
  String get statsTotalVolume => 'Total Volume';

  @override
  String get statsTotalDuration => 'Total Duration';

  @override
  String get statsAvgDuration => 'Avg. Duration';

  @override
  String get statsExerciseBreakdownLabel => 'Exercise Breakdown';

  @override
  String get statsRecordsLabel => 'Records';

  @override
  String get statsPersonalBestsTitle => 'Personal Bests';

  @override
  String get statsPersonalBestsSub => 'Your all-time top performances';

  @override
  String get statsEmptyTitle => 'No stats yet';

  @override
  String get statsEmptySub =>
      'Complete a workout to start building your statistics.';

  @override
  String get statsEmptyCta => 'Start a Workout';

  @override
  String get statsErrorTitle => 'Couldn\'t load your stats';

  @override
  String get statsErrorBody =>
      'Something went wrong calculating your statistics. Your workout history is unaffected.';

  @override
  String get statsBestWeight => 'Best weight';

  @override
  String get statsBestTime => 'Best time';

  @override
  String get statsBestReps => 'Best reps';

  @override
  String get statsVolumeUnit => 'kg';

  @override
  String get statsMinutesUnit => 'min';

  @override
  String get statsSecondsUnit => 's';

  @override
  String get statsNotAvailable => '—';

  @override
  String get pbScreenTitle => 'Personal Bests';

  @override
  String get pbEmptyTitle => 'No personal bests yet';

  @override
  String get pbEmptySubtitle =>
      'Complete a workout to start setting personal bests.';

  @override
  String get pbErrorTitle => 'Couldn\'t load your personal bests';

  @override
  String get pbErrorBody =>
      'Something went wrong calculating this data. Your workout history is unaffected.';

  @override
  String get pbBadgeWeightLabel => 'Best weight';

  @override
  String get pbBadgeTimeLabel => 'Best time';

  @override
  String get pbBadgeRepsLabel => 'Best reps';

  @override
  String get pbWeightUnit => 'kg';

  @override
  String get pbRepsUnit => 'reps';

  @override
  String get weekdayShortMon => 'Mon';

  @override
  String get weekdayFullMon => 'Monday';

  @override
  String get weekdayShortTue => 'Tue';

  @override
  String get weekdayFullTue => 'Tuesday';

  @override
  String get weekdayShortWed => 'Wed';

  @override
  String get weekdayFullWed => 'Wednesday';

  @override
  String get weekdayShortThu => 'Thu';

  @override
  String get weekdayFullThu => 'Thursday';

  @override
  String get weekdayShortFri => 'Fri';

  @override
  String get weekdayFullFri => 'Friday';

  @override
  String get weekdayShortSat => 'Sat';

  @override
  String get weekdayFullSat => 'Saturday';

  @override
  String get weekdayShortSun => 'Sun';

  @override
  String get weekdayFullSun => 'Sunday';

  @override
  String get profileExperienceBeginner => 'Beginner';

  @override
  String get profileExperienceIntermediate => 'Intermediate';

  @override
  String get profileExperienceAdvanced => 'Advanced';

  @override
  String cancelWorkoutBodyWithPlan(String planName) {
    return 'Your progress on \"$planName\" won\'t be saved. This session won\'t appear in your workout history.';
  }

  @override
  String workoutSummaryErrorPlan(String planName) {
    return 'Something went wrong writing \"$planName\" to local storage.';
  }

  @override
  String historySummaryLine(int minutes, int exercises, int sets) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercises',
      one: '1 exercise',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$minutes min · $_temp0 · $_temp1';
  }

  @override
  String setPillWeighted(int reps, String weight) {
    return '$reps×${weight}kg';
  }

  @override
  String setPillReps(int reps) {
    return '$reps reps';
  }

  @override
  String restTimerTargetReps(int reps) {
    return '$reps reps';
  }

  @override
  String restTimerTargetWeight(String weight) {
    return '$weight kg';
  }

  @override
  String restTimerTargetDuration(int seconds) {
    return '${seconds}s';
  }

  @override
  String restTimerTarget(String value) {
    return 'Target: $value';
  }

  @override
  String restTimerUpNextName(String exercise, int setNumber, int totalSets) {
    return '$exercise — Set $setNumber of $totalSets';
  }

  @override
  String activeWorkoutSetOf(int current, int total) {
    return 'Set $current / $total';
  }

  @override
  String activeWorkoutExerciseOf(int current, int total) {
    return 'Exercise $current / $total';
  }

  @override
  String get authWelcomeTitle => 'Welcome back';

  @override
  String get authWelcomeSubtitle => 'Sign in to continue';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignInButton => 'Sign In';

  @override
  String get authInvalidCredentials => 'Email or password is incorrect';

  @override
  String get exerciseFilterAll => 'All';

  @override
  String planDetailRestValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get exerciseCatalogueTitle => 'Exercise Catalogue';

  @override
  String get exerciseCatalogueNoMatchTitle => 'No exercises match your search';

  @override
  String get exerciseCatalogueNoMatchSubtitle =>
      'Try a different name or clear the filter.';

  @override
  String get exerciseSearchHint => 'Search exercises';

  @override
  String get pickerBannerPrefix => 'Adding an exercise to ';

  @override
  String get navHome => 'Home';

  @override
  String get navPlans => 'Plans';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navHistory => 'History';

  @override
  String get navProgress => 'Progress';

  @override
  String get navStats => 'Stats';

  @override
  String get homeGreetingMorning => 'Good morning, Athlete';

  @override
  String get homeGreetingAfternoon => 'Good afternoon, Athlete';

  @override
  String get homeGreetingEvening => 'Good evening, Athlete';

  @override
  String get homeProfileTooltip => 'Profile';

  @override
  String get homeEmptyTitle => 'No workouts yet';

  @override
  String get homeEmptySubtitle => 'Create your first plan to get started';

  @override
  String get homeEmptyCta => 'Create your first workout plan';

  @override
  String homeReadyForPlan(String planName) {
    return 'Ready for your scheduled $planName?';
  }

  @override
  String get homeNoPlanSubtitle => 'No workout planned for today';

  @override
  String get homeDailyIntentionTitle => 'Daily intention';

  @override
  String get homeQuote1 =>
      'Consistency beats intensity every single time. Honor your tempo and show up with intent.';

  @override
  String get homeQuote2 => 'You don\'t have to be extreme, just consistent.';

  @override
  String get homeQuote3 =>
      'Small sets, done daily, build the strongest habits.';

  @override
  String get homeQuote4 => 'Strength is built one honest rep at a time.';

  @override
  String get homeQuote5 => 'Show up today. Future you will say thanks.';

  @override
  String get homeQuote6 =>
      'Progress is quiet. Trust the work you can\'t see yet.';

  @override
  String get homeQuote7 => 'Warm up the body, then focus the mind.';

  @override
  String get homeQuote8 => 'Rest is part of the plan, not a break from it.';

  @override
  String homePlannedForToday(int minutes) {
    return 'Planned for today · ~$minutes min';
  }

  @override
  String get homeStatVolume => 'Volume';

  @override
  String get homeStatExercises => 'Exercises';

  @override
  String get homeStatSets => 'Sets';

  @override
  String homeVolumeApprox(String value) {
    return '~$value kg';
  }

  @override
  String get homeExerciseSequence => 'Exercise sequence';

  @override
  String homeMovementCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movements',
      one: '1 movement',
    );
    return '$_temp0';
  }

  @override
  String homeRowWeighted(int sets, int reps, String weight) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 · $reps reps · $weight kg';
  }

  @override
  String homeRowBodyweight(int sets, int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 · $reps reps';
  }

  @override
  String homeRowTimed(int sets, String duration) {
    String _temp0 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets sets',
      one: '1 set',
    );
    return '$_temp0 · $duration';
  }

  @override
  String get homeStartTodaysWorkout => 'Start today\'s workout';

  @override
  String get homeDoneToday => 'Done today';

  @override
  String get homeDoItAgain => 'Do it again';

  @override
  String get startAgainTitle => 'Already done today';

  @override
  String startAgainMessage(String planName) {
    return 'You already completed $planName today. Start another session?';
  }

  @override
  String get startAgainConfirm => 'Start anyway';

  @override
  String get startAgainCancel => 'Go back';

  @override
  String get homeNoWorkoutTitle => 'No workout planned today';

  @override
  String homeNoWorkoutNext(String day, String planName) {
    return 'Your next session is $day · $planName';
  }

  @override
  String get homeNoWorkoutNoSchedule =>
      'Schedule a plan and it will show up here.';

  @override
  String get homeNothingScheduledTitle => 'Nothing scheduled yet';

  @override
  String get homeViewSchedule => 'View schedule';

  @override
  String get homeScheduleAPlan => 'Schedule a plan';

  @override
  String get homeThisWeek => 'This week';

  @override
  String homeWeekDaySemantics(String day, String status) {
    return '$day: $status';
  }

  @override
  String get homeWeekDayCompleted => 'completed';

  @override
  String get homeWeekDayPlanned => 'planned';

  @override
  String get homeWeekDayRest => 'rest';

  @override
  String get homeWeekDayMissed => 'missed';

  @override
  String homeWeekProgress(int done, int total) {
    return '$done of $total done';
  }

  @override
  String homeWeekDetailCompleted(String day, String plan, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count workouts done',
      one: '1 workout done',
    );
    return '$day · $plan · $_temp0';
  }

  @override
  String homeWeekDetailPlanned(String day, String plan) {
    return '$day · $plan · planned';
  }

  @override
  String homeWeekDetailMissed(String day, String plan) {
    return '$day · $plan · missed';
  }

  @override
  String homeWeekDetailRest(String day) {
    return '$day · Rest day';
  }

  @override
  String get homeLastWorkout => 'Last workout';

  @override
  String homeLastWorkoutDetails(String date, int minutes, String volume) {
    return '$date · $minutes min · $volume kg';
  }

  @override
  String get homeNoWorkoutsLoggedTitle => 'No workouts logged yet';

  @override
  String get homeNoWorkoutsLoggedBody =>
      'Finish a workout and your last session will appear here.';

  @override
  String get homeWarmupTitle => 'Warm-up focus';

  @override
  String get homeWarmupGeneric =>
      'Five minutes of light cardio and joint circles before the first working set.';

  @override
  String get homeWarmupTipChest =>
      'Band pull-aparts and arm circles open the chest and shoulders before pressing.';

  @override
  String get homeWarmupTipBack =>
      'Cat-cow and light band rows wake up your back before pulling.';

  @override
  String get homeWarmupTipLegs =>
      'Bodyweight squats and hip openers prepare your legs for load.';

  @override
  String get homeWarmupTipShoulders =>
      'Band pull-aparts and thoracic rotations prime the shoulders before pressing.';

  @override
  String get homeWarmupTipBiceps =>
      'Light curls and wrist circles get the elbows ready.';

  @override
  String get homeWarmupTipTriceps =>
      'Arm swings and light pushdowns warm up the elbows.';

  @override
  String get homeWarmupTipCore =>
      'Dead bugs and plank holds switch your core on.';

  @override
  String get homeRecoveryTitle => 'Recovery tip';

  @override
  String get homeRecoveryTip1 =>
      'Take a short walk and stretch the muscles you trained last.';

  @override
  String get homeRecoveryTip2 =>
      'Aim for a full night of sleep; that is when strength is built.';

  @override
  String get homeRecoveryTip3 =>
      'Drink water through the day and eat protein with every meal.';

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
    );
    return '$_temp0';
  }

  @override
  String setCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sets',
      one: '1 set',
    );
    return '$_temp0';
  }

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get workoutPlansTitle => 'Workout Plans';

  @override
  String get plansEmptyTitle => 'No workout plans yet';

  @override
  String get plansEmptySubtitle =>
      'Build your first workout plan to see it listed here.';

  @override
  String get plansEmptyCta => 'Create a workout plan';

  @override
  String weightKgValue(String weight) {
    return '$weight kg';
  }

  @override
  String get valueNotAvailable => '—';

  @override
  String preStartMetaScheduled(String day, String exercises) {
    return '$day · $exercises';
  }

  @override
  String preStartMetaScheduledToday(String day, String exercises) {
    return '$day · Today · $exercises';
  }

  @override
  String dayChipNotSelected(String day) {
    return '$day. Not selected.';
  }

  @override
  String dayChipSelected(String day) {
    return '$day. Selected.';
  }

  @override
  String dayChipUnavailable(String day) {
    return '$day. Unavailable — conflicts.';
  }

  @override
  String scheduleConflictMessage(String day, String plan) {
    return '$day already has \"$plan\" scheduled. Remove it from the Schedule tab first, or pick another day.';
  }

  @override
  String scheduleHelperScheduledOn(String days) {
    return 'Scheduled on $days.';
  }

  @override
  String recurrenceSemantics(String title, String subtitle) {
    return '$title. $subtitle. Toggle locked.';
  }

  @override
  String invalidPlanBannerSemantics(String title, String subtitle) {
    return '$title. $subtitle';
  }

  @override
  String removeScheduleMessage(String plan, String day) {
    return '$plan on $day will be removed. Your history is unaffected.';
  }

  @override
  String deletePlanDialogMessage(String planName) {
    return '“$planName” and its schedule assignments will be removed. Past workout sessions using this plan are unaffected.';
  }

  @override
  String get pageNotFoundTitle => 'Not Found';

  @override
  String pageNotFoundMessage(String location) {
    return 'Page not found: $location';
  }

  @override
  String get logoutDialogTitle => 'Log out?';

  @override
  String get logoutDialogMessage =>
      'Logging out permanently deletes your profile, workout plans, schedules and workout history from this device. This can\'t be undone.';

  @override
  String get logoutCancelButton => 'Cancel';

  @override
  String get logoutConfirmButton => 'Log out';

  @override
  String get logoutBusyLabel => 'Logging out…';

  @override
  String get logoutRetryButton => 'Retry';

  @override
  String get logoutError => 'Couldn\'t clear your data. Please try again.';

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String restTimerSemantics(String time) {
    return 'Rest timer: $time';
  }

  @override
  String progressChartTitle(String exercise, String metric) {
    return '$exercise — $metric';
  }

  @override
  String progressTrendRising(String change) {
    return '▲ $change vs previous session';
  }

  @override
  String progressTrendFalling(String change) {
    return '▼ $change vs previous session';
  }

  @override
  String pbDateSet(String date) {
    return 'Set $date';
  }

  @override
  String get homeLoadError => 'Couldn\'t load your dashboard';

  @override
  String get exerciseCatalogueLoadError =>
      'Couldn\'t load the exercise catalogue';

  @override
  String get scheduleSaveError => 'Couldn\'t save your schedule';

  @override
  String get scheduleRemoveError => 'Couldn\'t remove this entry';

  @override
  String get plansLoadError => 'Couldn\'t load your workout plans';

  @override
  String get planLoadError => 'Couldn\'t load the workout plan';

  @override
  String get planDeleteError => 'Couldn\'t delete the plan';

  @override
  String get appTitle => 'Forge';

  @override
  String get durationFormatError => 'Enter duration as mm:ss';

  @override
  String get historyDetailEditTooltip => 'Edit workout';

  @override
  String get historyDetailDeleteTooltip => 'Delete workout';

  @override
  String get deleteSessionDialogTitle => 'Delete this workout?';

  @override
  String get deleteSessionDialogMessage =>
      'This workout will be removed from your history. Your statistics and progress will update to match. This can\'t be undone.';

  @override
  String get deleteSessionCancelButton => 'Cancel';

  @override
  String get deleteSessionDeleteButton => 'Delete';

  @override
  String get deleteSessionDeletingLabel => 'Deleting…';

  @override
  String get deleteSessionRetryButton => 'Retry';

  @override
  String get deleteSessionError =>
      'Couldn\'t delete the workout. Nothing was removed.';

  @override
  String get editSessionTitle => 'Edit Workout';

  @override
  String editSessionSetLabel(int number) {
    return 'Set $number';
  }

  @override
  String get editSessionSkippedLabel => 'Skipped';

  @override
  String get editSessionSaveButton => 'Save changes';

  @override
  String get editSessionSavingLabel => 'Saving…';

  @override
  String get editSessionRetryButton => 'Retry';

  @override
  String get editSessionNoValidSetError =>
      'Keep at least one completed set. Un-skip a set and fill in its values.';

  @override
  String get editSessionSaveError =>
      'Couldn\'t save your changes. The workout was not changed.';
}
