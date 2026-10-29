import 'package:forge/features/personal_bests/presentation/screens/personal_bests_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/stats_reload_notifier.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/features/stats/application/bloc/stats_bloc.dart';
import 'package:forge/features/stats/application/bloc/stats_event.dart';
import 'package:forge/features/stats/application/bloc/stats_state.dart';
import 'package:forge/features/stats/presentation/widgets/exercise_stat_card.dart';
import 'package:forge/features/stats/presentation/widgets/personal_bests_link_row.dart';
import 'package:forge/features/stats/presentation/widgets/stats_empty_state.dart';
import 'package:forge/features/stats/presentation/widgets/stats_skeleton.dart';
import 'package:forge/features/stats/presentation/widgets/stats_tile_grid.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';

class StatsScreen extends StatelessWidget {
  static const String routePath = '/stats';
  static const String routeName = 'stats';

  const StatsScreen({super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _bottomPadding = AppSpacing.md;
  static const double _sectionGap = AppSpacing.lg;
  static const double _itemGap = AppSpacing.smd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ReloadListener(
      notifier: getIt<StatsReloadNotifier>(),
      onReload: () => _requestLoad(context),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.l10n.statsTitle),
        ),
        body: BlocBuilder<StatsBloc, StatsState>(
          builder: (context, state) => switch (state) {
            StatsInitial() || StatsLoading() => const StatsSkeleton(),
            StatsLoaded() => _buildLoaded(context, state),
            StatsError() => ErrorCard(
              title: context.l10n.statsErrorTitle,
              message: context.l10n.statsErrorBody,
              onRetry: () => _requestLoad(context),
            ),
          },
        ),
      ),
    );
  }

  void _requestLoad(BuildContext context) {
    context.read<StatsBloc>().add(const StatsLoadRequested());
  }

  Widget _buildLoaded(BuildContext context, StatsLoaded state) {
    final textTheme = Theme.of(context).textTheme;
    final isEmpty = state.stats.totalWorkoutsCompleted == 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        StatsScreen._horizontalPadding,
        0,
        StatsScreen._horizontalPadding,
        StatsScreen._bottomPadding,
      ),
      children: [
        StatsTileGrid(stats: state.stats),
        const SizedBox(height: StatsScreen._sectionGap),
        if (isEmpty)
          StatsEmptyState(
            onStartWorkout: () => context.go(WorkoutPlansScreen.routePath),
          )
        else ...[
          if (state.exercises.isNotEmpty) ...[
            Text(
              context.l10n.statsExerciseBreakdownLabel.toUpperCase(),
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: StatsScreen._itemGap),
            for (final row in state.exercises) ...[
              ExerciseStatCard(key: ValueKey(row.exerciseName), row: row),
              const SizedBox(height: StatsScreen._itemGap),
            ],
            const SizedBox(
              height: StatsScreen._sectionGap - StatsScreen._itemGap,
            ),
          ],
          Text(
            context.l10n.statsRecordsLabel.toUpperCase(),
            style: textTheme.labelLarge,
          ),
          const SizedBox(height: StatsScreen._itemGap),
          PersonalBestsLinkRow(
            onTap: () => context.push(PersonalBestsScreen.routePath),
          ),
        ],
      ],
    );
  }
}
