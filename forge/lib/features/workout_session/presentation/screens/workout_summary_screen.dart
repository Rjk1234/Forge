import 'package:forge/features/workout_session/presentation/screens/workout_history_screen.dart';
import 'package:forge/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/full_width.dart';
import 'package:forge/core/widgets/button_spinner.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_summary_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/workout_summary_content.dart';
import 'package:forge/features/workout_session/presentation/widgets/workout_summary_error_view.dart';
import 'package:forge/features/workout_session/presentation/widgets/workout_summary_loading_view.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  static const String routePath = '/workout/summary';
  static const String routeName = 'postWorkout';

  const WorkoutSummaryScreen({super.key});

  static const double _footerHorizontalPadding = AppSpacing.lgx;
  static const double _footerTopPadding = AppSpacing.mdl;
  static const double _footerBottomPadding = 22;
  static const double _footerGap = AppSpacing.smd;
  static const double _buttonRadius = AppRadius.card;
  static const double _buttonPadding = 15;
  static const double _spinnerSize = 18;
  static const double _spinnerStroke = 2.5;
  static const double _dimmedCancelOpacity = 0.4;

  void _handleRetry(BuildContext context) {
    context.read<WorkoutSummaryBloc>().add(
      const WorkoutSummaryRetryRequested(),
    );
  }

  void _handleDone(BuildContext context) => context.go(HomeScreen.routePath);

  void _handleViewHistory(BuildContext context) =>
      context.push(WorkoutHistoryScreen.routePath);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      child: BlocConsumer<WorkoutSummaryBloc, WorkoutSummaryState>(
        listenWhen: (previous, current) =>
            current is WorkoutSummarySuccess &&
            previous is! WorkoutSummarySuccess,
        listener: (context, state) => getIt<WorkoutDataRefresher>().refresh(),
        builder: (context, state) => Scaffold(
          backgroundColor: colorScheme.surfaceContainerLowest,
          appBar: _buildAppBar(context, state),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(child: _buildBody(context, state)),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildFooter(context, state),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WorkoutSummaryState state,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLoading = state is WorkoutSummaryLoading;
    final titleStyle = textTheme.displaySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return AppBar(
      backgroundColor: colorScheme.surfaceContainerLowest,
      automaticallyImplyLeading: false,
      centerTitle: !isLoading,
      title: Text(
        isLoading
            ? context.l10n.workoutSummaryLoadingAppBarTitle.toUpperCase()
            : context.l10n.workoutSummaryAppBarTitle,
        style: titleStyle,
      ),
      actions: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: WorkoutSummaryScreen._footerHorizontalPadding,
            ),
            child: Center(
              child: Opacity(
                opacity: WorkoutSummaryScreen._dimmedCancelOpacity,
                child: Text(
                  context.l10n.activeWorkoutCancelButton,
                  style: textTheme.labelLarge,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WorkoutSummaryState state) {
    return switch (state) {
      WorkoutSummaryInitial() => const SizedBox.shrink(),
      WorkoutSummaryLoading(:final planName) => WorkoutSummaryLoadingView(
        planName: planName,
      ),
      WorkoutSummarySuccess(:final session) => WorkoutSummaryContent(
        session: session,
      ),
      WorkoutSummaryError(:final planName, :final isRetryable) =>
        WorkoutSummaryErrorView(planName: planName, isRetryable: isRetryable),
    };
  }

  Widget _buildFooter(BuildContext context, WorkoutSummaryState state) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = switch (state) {
      WorkoutSummaryInitial() => null,
      WorkoutSummaryLoading() => _buildSavingButton(context),
      WorkoutSummarySuccess() => _buildSuccessActions(context),
      WorkoutSummaryError(:final isRetryable) => _buildErrorAction(
        context,
        isRetryable: isRetryable,
      ),
    };
    if (actions == null) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.surfaceContainerLowest.withValues(alpha: 0),
            colorScheme.surfaceContainerLowest,
          ],
          stops: const [0, 0.4],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          WorkoutSummaryScreen._footerHorizontalPadding,
          WorkoutSummaryScreen._footerTopPadding,
          WorkoutSummaryScreen._footerHorizontalPadding,
          WorkoutSummaryScreen._footerBottomPadding,
        ),
        child: actions,
      ),
    );
  }

  RoundedRectangleBorder get _buttonShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(WorkoutSummaryScreen._buttonRadius),
  );

  Widget _buildSuccessActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelLarge;
    const padding = EdgeInsets.symmetric(
      vertical: WorkoutSummaryScreen._buttonPadding,
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleViewHistory(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide(color: colorScheme.outline),
              padding: padding,
              shape: _buttonShape,
            ),
            child: Text(
              context.l10n.workoutSummaryViewHistoryButton,
              style: labelStyle?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ),
        const SizedBox(width: WorkoutSummaryScreen._footerGap),
        Expanded(
          child: FilledButton(
            onPressed: () => _handleDone(context),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              padding: padding,
              shape: _buttonShape,
            ),
            child: Text(
              context.l10n.workoutSummaryDoneButton,
              style: labelStyle?.copyWith(color: colorScheme.onPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorAction(BuildContext context, {required bool isRetryable}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final labelStyle = theme.textTheme.labelLarge;

    return FullWidth(
      child: FilledButton(
        onPressed: () =>
            isRetryable ? _handleRetry(context) : _handleDone(context),
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(
            vertical: WorkoutSummaryScreen._buttonPadding,
          ),
          shape: _buttonShape,
        ),
        child: Text(
          isRetryable
              ? context.l10n.workoutSummaryRetryButton
              : context.l10n.workoutSummaryDoneButton,
          style: labelStyle?.copyWith(color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildSavingButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final labelStyle = theme.textTheme.labelLarge;

    return FullWidth(
      child: OutlinedButton(
        onPressed: null,
        style: OutlinedButton.styleFrom(
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(
            vertical: WorkoutSummaryScreen._buttonPadding,
          ),
          shape: _buttonShape,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonSpinner(
              color: colorScheme.onSurfaceVariant,
              size: WorkoutSummaryScreen._spinnerSize,
              strokeWidth: WorkoutSummaryScreen._spinnerStroke,
              trackColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
            const SizedBox(width: WorkoutSummaryScreen._footerGap),
            Text(
              context.l10n.workoutSummaryLoadingButton,
              style: labelStyle?.copyWith(color: appColors.textDim),
            ),
          ],
        ),
      ),
    );
  }
}
