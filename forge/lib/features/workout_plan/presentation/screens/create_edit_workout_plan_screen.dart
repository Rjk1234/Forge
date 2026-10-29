import 'package:flutter/material.dart';
import 'package:forge/core/widgets/loading_indicator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/features/exercise/domain/entities/exercise.dart';
import 'package:forge/features/exercise/domain/entities/picker_context.dart';
import 'package:forge/features/exercise/presentation/screens/exercise_catalogue_screen.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart';
import 'package:forge/features/workout_plan/presentation/screens/plan_detail_screen.dart';
import 'package:forge/features/workout_plan/presentation/screens/workout_plans_screen.dart';
import 'package:forge/features/workout_plan/presentation/widgets/create_edit_plan_form.dart';
import 'package:forge/features/workout_plan/presentation/widgets/discard_dialog.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_load_error_view.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:go_router/go_router.dart';

class CreateEditWorkoutPlanScreen extends StatelessWidget {
  static const String createRouteSegment = 'create';
  static const String createRoutePath =
      '${WorkoutPlansScreen.routePath}/$createRouteSegment';
  static const String createRouteName = 'createPlan';
  static const String editRouteSegment = 'edit';
  static const String editRoutePath =
      '${PlanDetailScreen.routePath}/$editRouteSegment';
  static const String editRouteName = 'editPlan';

  const CreateEditWorkoutPlanScreen({this.planId, super.key});

  final String? planId;

  bool _isSaving(CreateEditWorkoutPlanState state) =>
      state is CreateEditPlanSaving;

  CreateEditPlanReady? _readyState(CreateEditWorkoutPlanState state) {
    return switch (state) {
      CreateEditPlanReady s => s,
      CreateEditPlanSaving s => s.readyState,
      CreateEditPlanSaveFailure s => s.readyState,
      _ => null,
    };
  }

  void _onBackRequested(
    BuildContext context,
    CreateEditWorkoutPlanState state,
  ) {
    if (_isSaving(state)) return;
    final ready = _readyState(state);
    if (ready == null || !ready.isDirty) {
      if (!context.mounted) return;
      context.pop();
      return;
    }
    _showDiscardDialog(context);
  }

  /// Pops the screen only after the dialog has fully left the screen, so the
  /// two exit animations never overlap.
  Future<void> _showDiscardDialog(BuildContext context) async {
    final route = DialogRoute<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DiscardDialog(),
    );
    final discard = await Navigator.of(context).push(route);
    await route.completed;
    if (discard == true && context.mounted) {
      context.pop();
    }
  }

  Future<void> _onAddExercise(BuildContext context, String planName) async {
    final exercise = await context.push<Exercise>(
      ExerciseCatalogueScreen.routePath,
      extra: PickerContext(planName: planName),
    );
    if (exercise != null && context.mounted) {
      context.read<CreateEditWorkoutPlanBloc>().add(ExerciseAdded(exercise));
    }
  }

  void _onFieldChanged(
    BuildContext context,
    int index,
    ExerciseField field,
    String value,
  ) {
    context.read<CreateEditWorkoutPlanBloc>().add(
      ExerciseFieldChanged(index: index, field: field, value: value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return BlocConsumer<CreateEditWorkoutPlanBloc, CreateEditWorkoutPlanState>(
      listenWhen: (_, current) =>
          current is CreateEditPlanSaved || current is CreateEditPlanLoadError,
      listener: (context, state) {
        if (state is CreateEditPlanSaved) {
          context.goNamed(
            PlanDetailScreen.routeName,
            pathParameters: {PlanDetailScreen.planIdParam: state.savedPlanId},
          );
        }
      },
      builder: (context, state) {
        final title = planId == null
            ? context.l10n.createPlanTitle
            : context.l10n.editPlanTitle;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            // A pop that already happened (our own context.pop) must not run
            // the back logic again, or the dialog would reopen.
            if (!didPop) _onBackRequested(context, state);
          },
          child: Scaffold(
            backgroundColor: colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              backgroundColor: colorScheme.surfaceContainerLowest,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                onPressed: () => _onBackRequested(context, state),
              ),
              title: Text(title, style: theme.textTheme.titleLarge),
            ),
            body: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CreateEditWorkoutPlanState state) {
    return switch (state) {
      CreateEditPlanInitial() ||
      CreateEditPlanLoading() ||
      CreateEditPlanSaved() => const LoadingIndicator(),
      CreateEditPlanLoadError() => const PlanLoadErrorView(),
      _ => CreateEditPlanForm(
        state: state,
        onNameChanged: (v) {
          context.read<CreateEditWorkoutPlanBloc>().add(PlanNameChanged(v));
        },
        onAddExercise: (planName) => _onAddExercise(context, planName),
        onFieldChanged: (index, field, value) =>
            _onFieldChanged(context, index, field, value),
        onRemoveExercise: (index) => context
            .read<CreateEditWorkoutPlanBloc>()
            .add(ExerciseRemoved(index)),
        onSave: () => context.read<CreateEditWorkoutPlanBloc>().add(
          const SaveRequested(),
        ),
        onRetry: () => context.read<CreateEditWorkoutPlanBloc>().add(
          const RetrySaveRequested(),
        ),
      ),
    };
  }
}
