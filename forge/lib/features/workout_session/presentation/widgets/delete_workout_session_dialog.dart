import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/widgets/confirm_dialog.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_bloc.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_event.dart';
import 'package:forge/features/workout_session/application/bloc/delete_workout_session_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Confirmation dialog for deleting a logged workout. Pops `true` once the
/// workout is deleted and `false` (or null) when the user cancels.
class DeleteWorkoutSessionDialog extends StatelessWidget {
  const DeleteWorkoutSessionDialog({required this.sessionId, super.key});

  final String sessionId;

  ConfirmDialogStatus _statusOf(DeleteWorkoutSessionState state) =>
      switch (state) {
        DeleteWorkoutSessionDeleting() => ConfirmDialogStatus.busy,
        DeleteWorkoutSessionFailure() => ConfirmDialogStatus.failed,
        _ => ConfirmDialogStatus.idle,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<DeleteWorkoutSessionBloc, DeleteWorkoutSessionState>(
      listener: (context, state) {
        if (state is DeleteWorkoutSessionSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => ConfirmDialog(
        icon: Icons.delete_outline,
        title: l10n.deleteSessionDialogTitle,
        message: l10n.deleteSessionDialogMessage,
        cancelLabel: l10n.deleteSessionCancelButton,
        confirmLabel: l10n.deleteSessionDeleteButton,
        busyLabel: l10n.deleteSessionDeletingLabel,
        retryLabel: l10n.deleteSessionRetryButton,
        errorMessage: l10n.deleteSessionError,
        status: _statusOf(state),
        onConfirm: () => context.read<DeleteWorkoutSessionBloc>().add(
          DeleteWorkoutSessionConfirmed(sessionId: sessionId),
        ),
      ),
    );
  }
}
