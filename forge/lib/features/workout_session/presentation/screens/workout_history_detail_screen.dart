import 'package:forge/features/workout_session/presentation/screens/workout_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/workout_data_refresher.dart';
import 'package:forge/core/utils/format_utils.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_event.dart';
import 'package:forge/features/workout_session/application/bloc/workout_history_detail_state.dart';
import 'package:forge/features/workout_session/domain/entities/workout_session.dart';
import 'package:forge/features/workout_session/presentation/screens/edit_workout_session_screen.dart';
import 'package:forge/features/workout_session/presentation/widgets/delete_workout_session_dialog.dart';
import 'package:forge/features/workout_session/presentation/widgets/detail_skeleton.dart';
import 'package:forge/features/workout_session/presentation/widgets/exercise_breakdown_card.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/features/workout_session/presentation/widgets/session_stat_row.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class WorkoutHistoryDetailScreen extends StatelessWidget {
  static const String routeSegment = 'detail';
  static const String routePath =
      '${WorkoutHistoryScreen.routePath}/$routeSegment';
  static const String routeName = 'historyDetail';

  const WorkoutHistoryDetailScreen({required this.sessionId, super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _verticalPadding = AppSpacing.mdl;
  static const double _sectionGap = AppSpacing.lg;
  static const double _cardGap = AppSpacing.smd;
  static const double _heroGap = AppSpacing.xs;

  final String sessionId;

  void _requestLoad(BuildContext context) {
    context.read<WorkoutHistoryDetailBloc>().add(
      WorkoutHistoryDetailLoadRequested(sessionId: sessionId),
    );
  }

  Future<void> _onEdit(BuildContext context) async {
    await context.pushNamed<void>(
      EditWorkoutSessionScreen.routeName,
      extra: sessionId,
    );
    if (!context.mounted) return;
    _requestLoad(context);
  }

  Future<void> _onDelete(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final deleted = await showDialog<bool>(
      context: context,
      barrierColor: colorScheme.scrim,
      builder: (_) => BlocProvider(
        create: (_) => getIt<DeleteWorkoutSessionBloc>(),
        child: DeleteWorkoutSessionDialog(sessionId: sessionId),
      ),
    );
    if (deleted != true) return;
    getIt<WorkoutDataRefresher>().refresh();
    if (!context.mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(
          context.l10n.detailScreenTitle,
          style: textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.historyDetailEditTooltip,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _onEdit(context),
          ),
          IconButton(
            tooltip: context.l10n.historyDetailDeleteTooltip,
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _onDelete(context),
          ),
        ],
      ),
      body: BlocBuilder<WorkoutHistoryDetailBloc, WorkoutHistoryDetailState>(
        builder: (context, state) => switch (state) {
          WorkoutHistoryDetailInitial() ||
          WorkoutHistoryDetailLoading() => const DetailSkeleton(),
          WorkoutHistoryDetailSuccess(:final session) => _buildDetail(
            context,
            textTheme,
            session,
          ),
          WorkoutHistoryDetailError() => ErrorCard(
            title: context.l10n.detailErrorTitle,
            message: context.l10n.detailErrorBody,
            retryLabel: context.l10n.historyRetryLabel,
            onRetry: () => _requestLoad(context),
          ),
        },
      ),
    );
  }

  Widget _buildDetail(
    BuildContext context,
    TextTheme textTheme,
    WorkoutSession session,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: WorkoutHistoryDetailScreen._horizontalPadding,
        vertical: WorkoutHistoryDetailScreen._verticalPadding,
      ),
      children: [
        Text(session.planName, style: textTheme.headlineMedium),
        const SizedBox(height: WorkoutHistoryDetailScreen._heroGap),
        Text(
          formatSessionDateTime(session.startedAt, includeYear: true),
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: WorkoutHistoryDetailScreen._sectionGap),
        SessionStatRow(session: session),
        const SizedBox(height: WorkoutHistoryDetailScreen._sectionGap),
        Text(
          context.l10n.workoutSummaryPerformanceLabel.toUpperCase(),
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: WorkoutHistoryDetailScreen._cardGap),
        for (final exercise in session.sessionExercises) ...[
          ExerciseBreakdownCard(exercise: exercise),
          const SizedBox(height: WorkoutHistoryDetailScreen._cardGap),
        ],
      ],
    );
  }
}
