import 'package:forge/features/workout_session/presentation/screens/active_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_preview_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/start_again_dialog.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class PreStartLoadedView extends StatelessWidget {
  const PreStartLoadedView({
    required this.plan,
    required this.scheduledWeekday,
    required this.isScheduledForToday,
    required this.planId,
    this.isCompletedToday = false,
    super.key,
  });

  final WorkoutPlanDetail plan;
  final int? scheduledWeekday;
  final bool isScheduledForToday;
  final String planId;
  final bool isCompletedToday;

  String _metaLine(AppLocalizations l10n) {
    final count = plan.exercises.length;
    final exercisePart = l10n.exerciseCount(count);

    if (scheduledWeekday == null) return exercisePart;

    final dayName = l10n.weekdayFullNames[scheduledWeekday! - 1];
    if (isScheduledForToday) {
      return l10n.preStartMetaScheduledToday(dayName, exercisePart);
    }
    return l10n.preStartMetaScheduled(dayName, exercisePart);
  }

  Future<void> _onBegin(BuildContext context) async {
    if (isCompletedToday) {
      final startAgain = await showDialog<bool>(
        context: context,
        builder: (_) => StartAgainDialog(planName: plan.name),
      );
      if (startAgain != true || !context.mounted) return;
    }
    context.push(ActiveWorkoutScreen.routePath, extra: plan);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surfaceContainerLowest,
            title: Text(context.l10n.preStartScreenTitle),
          ),
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              120,
            ),
            sliver: SliverList.builder(
              itemCount: plan.exercises.length,
              itemBuilder: (context, index) =>
                  ExercisePreviewCard(exercise: plan.exercises[index]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBeginButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _metaLine(context.l10n),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lgx),
            Text(
              context.l10n.preStartExercisesSectionLabel,
              style: textStyles.overline.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildBeginButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: () => _onBegin(context),
          child: Text(
            context.l10n.preStartBeginButton,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
