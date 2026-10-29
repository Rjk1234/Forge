import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/widgets/confirm_dialog.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_bloc.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/delete_plan_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Confirmation dialog for deleting a plan. Pops `true` once it is deleted
/// and `false` when the user cancels.
class DeletePlanDialog extends StatelessWidget {
  const DeletePlanDialog({
    required this.planId,
    required this.planName,
    super.key,
  });

  final String planId;
  final String planName;

  ConfirmDialogStatus _statusOf(DeletePlanState state) => switch (state) {
    DeletePlanDeleting() => ConfirmDialogStatus.busy,
    DeletePlanFailure() => ConfirmDialogStatus.failed,
    _ => ConfirmDialogStatus.idle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<DeletePlanBloc, DeletePlanState>(
      listener: (context, state) {
        if (state is DeletePlanSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => ConfirmDialog(
        icon: Icons.delete_outline,
        title: l10n.deletePlanDialogTitle,
        message: l10n.deletePlanDialogMessage(planName),
        cancelLabel: l10n.deletePlanCancelButton,
        confirmLabel: l10n.deletePlanDeleteButton,
        busyLabel: l10n.deletePlanDeletingLabel,
        retryLabel: l10n.deletePlanRetryButton,
        errorMessage: l10n.planDeleteError,
        status: _statusOf(state),
        onConfirm: () => context.read<DeletePlanBloc>().add(
          DeletePlanConfirmed(planId: planId),
        ),
      ),
    );
  }
}
