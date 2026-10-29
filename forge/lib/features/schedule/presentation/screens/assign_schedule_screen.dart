import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge/app/get_it_setup.dart';
import 'package:forge/core/navigation/home_reload_notifier.dart';
import 'package:forge/core/navigation/schedule_reload_notifier.dart';
import 'package:forge/core/widgets/loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_state.dart';
import 'package:go_router/go_router.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/features/schedule/presentation/widgets/invalid_plan_body.dart';
import 'package:forge/features/schedule/presentation/widgets/assign_schedule_form.dart';

class AssignScheduleScreen extends StatelessWidget {
  static const String routeSegment = 'schedule';
  static const String routePath = '${PlanDetailScreen.routePath}/$routeSegment';
  static const String routeName = 'assignSchedule';

  const AssignScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocConsumer<AssignScheduleBloc, AssignScheduleState>(
      listenWhen: (_, current) => current is AssignScheduleSaved,
      listener: (context, state) {
        getIt<ScheduleReloadNotifier>().notify();
        getIt<HomeReloadNotifier>().notify();
        context.pop();
      },
      builder: (context, state) {
        final isSaving = state is AssignScheduleSaving;

        return PopScope(
          canPop: !isSaving,
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            appBar: _buildAppBar(context, state, isSaving),
            body: switch (state) {
              AssignScheduleInitial() ||
              AssignScheduleLoading() => _buildLoading(context),
              AssignScheduleReady s => AssignScheduleForm(state: s),
              AssignScheduleInvalidPlan() => const InvalidPlanBody(),
              AssignScheduleSaving s => AssignScheduleForm(
                state: s.readyState,
                isSaving: true,
              ),
              AssignScheduleSaveFailure s => AssignScheduleForm(
                state: s.readyState,
                hasSaveFailure: true,
              ),
              AssignScheduleSaved() => const SizedBox.shrink(),
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AssignScheduleState state,
    bool isSaving,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    final isEditMode = switch (state) {
      AssignScheduleReady s => s.isEditMode,
      AssignScheduleSaving s => s.readyState.isEditMode,
      AssignScheduleSaveFailure s => s.readyState.isEditMode,
      AssignScheduleInvalidPlan() => true,
      _ => false,
    };
    final title = isEditMode
        ? context.l10n.editScheduleTitle
        : context.l10n.newScheduleTitle;
    final iconColor = isSaving ? appColors.textDim : colorScheme.onSurface;

    return AppBar(
      backgroundColor: colorScheme.surfaceContainerLowest,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: iconColor),
        onPressed: isSaving ? null : () => context.pop(),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: iconColor),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) => Semantics(
    label: context.l10n.assignScheduleLoadingSemantics,
    child: const LoadingIndicator(),
  );
}
