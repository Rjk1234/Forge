import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/progress_reload_notifier.dart';
import 'package:forge/core/widgets/reload_listener.dart';
import 'package:forge/features/progress/application/bloc/progress_bloc.dart';
import 'package:forge/features/progress/application/bloc/progress_event.dart';
import 'package:forge/features/progress/application/bloc/progress_state.dart';
import 'package:forge/features/progress/domain/entities/exercise_progress_data.dart';
import 'package:forge/features/progress/presentation/widgets/progress_chart_card.dart';
import 'package:forge/features/progress/presentation/widgets/progress_chip_row.dart';
import 'package:forge/features/progress/presentation/widgets/progress_empty_state.dart';
import 'package:forge/features/progress/presentation/widgets/progress_skeleton.dart';
import 'package:forge/features/progress/presentation/widgets/progress_stat_tiles.dart';
import 'package:forge/core/widgets/error_card.dart';
import 'package:forge/l10n/l10n.dart';

class ProgressScreen extends StatelessWidget {
  static const String routePath = '/progress';
  static const String routeName = 'progress';

  const ProgressScreen({super.key});

  static const double _horizontalPadding = AppSpacing.lgx;
  static const double _bottomPadding = AppSpacing.md;
  static const double _sectionGap = AppSpacing.lg;

  void _handleChipTap(BuildContext context, String exerciseName) {
    context.read<ProgressBloc>().add(
      ProgressExerciseSelected(exerciseName: exerciseName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ReloadListener(
      notifier: getIt<ProgressReloadNotifier>(),
      onReload: () => _requestLoad(context),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(context.l10n.progressScreenTitle),
        ),
        body: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) => switch (state) {
            ProgressInitial() || ProgressLoading() => const ProgressSkeleton(),
            ProgressLoaded() => _buildLoaded(context, state),
            ProgressError() => ErrorCard(
              title: context.l10n.progressErrorTitle,
              message: context.l10n.progressErrorBody,
              onRetry: () => _requestLoad(context),
            ),
          },
        ),
      ),
    );
  }

  void _requestLoad(BuildContext context) {
    context.read<ProgressBloc>().add(const ProgressLoadRequested());
  }

  Widget _buildLoaded(BuildContext context, ProgressLoaded state) {
    if (state.exercises.isEmpty) return const ProgressEmptyState();

    final selected = state.exercises.firstWhere(
      (exercise) => exercise.exerciseName == state.selectedExerciseName,
      orElse: () => state.exercises.first,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ProgressScreen._horizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressChipRow(
            exercises: state.exercises,
            selectedExerciseName: selected.exerciseName,
            onChipTap: (exerciseName) => _handleChipTap(context, exerciseName),
          ),
          const SizedBox(height: ProgressScreen._sectionGap),
          Expanded(child: _buildSelectedContent(context, selected)),
        ],
      ),
    );
  }

  Widget _buildSelectedContent(
    BuildContext context,
    ExerciseProgressData selected,
  ) {
    if (selected.totalValidSessions < 2) return const ProgressEmptyState();

    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.only(bottom: ProgressScreen._bottomPadding),
      children: [
        ProgressChartCard(exercise: selected),
        const SizedBox(height: ProgressScreen._sectionGap),
        Text(
          context.l10n.progressLatestSessionLabel.toUpperCase(),
          style: textTheme.labelLarge,
        ),
        const SizedBox(height: ProgressScreen._sectionGap),
        ProgressStatTiles(exercise: selected),
      ],
    );
  }
}
