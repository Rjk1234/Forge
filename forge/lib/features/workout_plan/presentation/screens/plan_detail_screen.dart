import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/core/navigation/workout_plans_reload_notifier.dart';
import 'package:forge/features/schedule/presentation/screens/assign_schedule_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_pre_start_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/create_edit_workout_plan_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_event.dart';
import 'package:forge/features/workout_plan/application/bloc/plan_detail_state.dart';
import 'package:forge/features/workout_plan/domain/entities/workout_plan_detail.dart';
import 'package:forge/features/workout_plan/presentation/widgets/delete_plan_dialog.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_detail_skeleton.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_exercise_detail_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_not_available_card.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_detail_footer.dart';

class PlanDetailScreen extends StatelessWidget {
  static const String planIdParam = 'planId';
  static const String routePath =
      '${WorkoutPlansScreen.routePath}/:$planIdParam';
  static const String routeSegment = ':$planIdParam';
  static const String routeName = 'planDetail';

  const PlanDetailScreen({required this.planId, super.key});

  final String planId;

  void _reload(BuildContext context) {
    context.read<PlanDetailBloc>().add(PlanDetailLoadRequested(planId: planId));
  }

  Future<void> _onEdit(BuildContext context) async {
    await context.pushNamed(
      CreateEditWorkoutPlanScreen.editRouteName,
      pathParameters: {planIdParam: planId},
    );
    if (!context.mounted) return;
    _reload(context);
  }

  Future<void> _onDelete(BuildContext context, String planName) async {
    final colorScheme = Theme.of(context).colorScheme;
    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: colorScheme.scrim,
      builder: (_) => BlocProvider(
        create: (_) => getIt<DeletePlanBloc>(),
        child: DeletePlanDialog(planId: planId, planName: planName),
      ),
    );
    if (!context.mounted) return;
    if (deleted == true) {
      _notifyPlanDeleted();
      context.go(WorkoutPlansScreen.routePath);
    } else {
      _reload(context);
    }
  }

  /// The Plans, Schedule and Home screens stay mounted, so they must be told
  /// to re-read after the plan (and its schedule entries) are gone.
  void _notifyPlanDeleted() {
    getIt<WorkoutPlansReloadNotifier>().notify();
    getIt<ScheduleReloadNotifier>().notify();
    getIt<HomeReloadNotifier>().notify();
  }

  void _onBack(BuildContext context) => context.pop();

  void _onStartWorkout(BuildContext context) {
    context.pushNamed(
      WorkoutPreStartScreen.routeName,
      pathParameters: {planIdParam: planId},
    );
  }

  void _onSchedule(BuildContext context) {
    context.pushNamed(
      AssignScheduleScreen.routeName,
      pathParameters: {planIdParam: planId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlanDetailBloc, PlanDetailState>(
      builder: (context, state) => switch (state) {
        PlanDetailInitial() => _buildLoading(context),
        PlanDetailLoading() => _buildLoading(context),
        PlanDetailLoaded s => _buildLoaded(
          context,
          s.plan,
          shouldShowStartWorkout: s.shouldShowStartWorkout,
        ),
        PlanDetailNotFound() => _buildNotFound(context),
      },
    );
  }

  Widget _buildLoading(BuildContext context) => Scaffold(
    body: Semantics(
      label: context.l10n.planDetailLoadingSemantics,
      child: const PlanDetailSkeleton(),
    ),
  );

  Widget _buildLoaded(
    BuildContext context,
    WorkoutPlanDetail plan, {
    required bool shouldShowStartWorkout,
  }) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasExercises = plan.exercises.isNotEmpty;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildLoadedAppBar(context, plan),
          if (plan.exercises.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: Text(
                  context.l10n.planDetailExercisesSectionLabel,
                  style: textStyles.overline.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              100,
            ),
            sliver: plan.exercises.isEmpty
                ? const SliverToBoxAdapter(child: SizedBox.shrink())
                : SliverList.builder(
                    itemCount: plan.exercises.length,
                    itemBuilder: (_, i) =>
                        PlanExerciseDetailCard(exercise: plan.exercises[i]),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: PlanDetailFooter(
        planId: planId,
        canStart: hasExercises,
        shouldShowStartWorkout: shouldShowStartWorkout,
        onStartWorkout: () => _onStartWorkout(context),
        onSchedule: () => _onSchedule(context),
      ),
    );
  }

  Widget _buildLoadedAppBar(BuildContext context, WorkoutPlanDetail plan) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      pinned: true,
      backgroundColor: colorScheme.surfaceContainerLowest,
      leading: IconButton(
        tooltip: context.l10n.planDetailBackTooltip,
        icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
        onPressed: () => _onBack(context),
      ),
      actions: [
        IconButton(
          tooltip: context.l10n.planDetailEditTooltip,
          icon: Icon(Icons.edit_outlined, color: colorScheme.onSurface),
          onPressed: () => _onEdit(context),
        ),
        IconButton(
          tooltip: context.l10n.planDetailDeleteTooltip,
          icon: Icon(Icons.delete_outline, color: colorScheme.onSurface),
          onPressed: () => _onDelete(context, plan.name),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(56, 0, 56, AppSpacing.lg),
        title: Text(
          plan.name,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest,
        leading: IconButton(
          tooltip: context.l10n.planDetailBackTooltip,
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
          onPressed: () => _onBack(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: PlanNotAvailableCard(onBack: () => _onBack(context)),
        ),
      ),
    );
  }
}
