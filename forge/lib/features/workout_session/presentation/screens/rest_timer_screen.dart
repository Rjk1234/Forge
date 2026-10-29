import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_args.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_event.dart';
import 'package:forge/features/workout_session/application/bloc/rest_timer_state.dart';
import 'package:forge/features/workout_session/presentation/widgets/rest_countdown_ring.dart';
import 'package:forge/features/workout_session/presentation/widgets/up_next_card.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class RestTimerScreen extends StatelessWidget {
  static const String routePath = '/workout/rest';
  static const String routeName = 'restTimer';

  const RestTimerScreen({required this.upNext, super.key});

  static const double _horizontalPadding = 30;
  static const double _sectionGap = AppSpacing.lg;
  static const double _buttonRadius = AppRadius.card;
  static const double _buttonVerticalPadding = 15;

  final RestTimerArgs upNext;

  @override
  Widget build(BuildContext context) {
    final appColors = AppColorsExtension.of(context);
    final bloc = context.read<RestTimerBloc>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) bloc.add(const RestTimerSkipped());
      },
      child: BlocListener<RestTimerBloc, RestTimerState>(
        listenWhen: (previous, current) =>
            current is RestTimerRunning && current.navigateBack,
        listener: (context, _) => context.pop(),
        child: Scaffold(
          backgroundColor: appColors.restScrim,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
              ),
              child: Center(
                child: BlocBuilder<RestTimerBloc, RestTimerState>(
                  builder: (context, state) => state is RestTimerRunning
                      ? _buildPanel(context, state)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context, RestTimerRunning state) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.restTimerRestingLabel.toUpperCase(),
          textAlign: TextAlign.center,
          style: textStyles.valueSmall,
        ),
        const SizedBox(height: _sectionGap),
        Center(
          child: RestCountdownRing(
            totalSec: state.totalSec,
            remainingSec: state.remainingSec,
          ),
        ),
        const SizedBox(height: _sectionGap),
        UpNextCard(
          exercise: upNext.nextExercise,
          setNumber: upNext.nextSetNumber,
        ),
        const SizedBox(height: _sectionGap),
        OutlinedButton(
          onPressed: () =>
              context.read<RestTimerBloc>().add(const RestTimerSkipped()),
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            side: BorderSide(color: colorScheme.outline),
            padding: const EdgeInsets.symmetric(
              vertical: _buttonVerticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
          ),
          child: Text(
            context.l10n.restTimerSkipRestButton,
            style: textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
