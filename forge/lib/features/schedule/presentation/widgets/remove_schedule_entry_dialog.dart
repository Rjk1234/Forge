import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/widgets/confirm_dialog.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_bloc.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_event.dart';
import 'package:forge/features/schedule/application/bloc/remove_schedule_entry_state.dart';
import 'package:forge/l10n/l10n.dart';

class RemoveScheduleEntryDialog extends StatelessWidget {
  const RemoveScheduleEntryDialog({
    required this.weekday,
    required this.planName,
    required this.dayName,
    super.key,
  });

  final int weekday;
  final String planName;
  final String dayName;

  ConfirmDialogStatus _statusOf(RemoveScheduleEntryState state) =>
      switch (state) {
        RemoveScheduleEntryRemoving() => ConfirmDialogStatus.busy,
        RemoveScheduleEntryFailure() => ConfirmDialogStatus.failed,
        _ => ConfirmDialogStatus.idle,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<RemoveScheduleEntryBloc, RemoveScheduleEntryState>(
      listener: (context, state) {
        if (state is RemoveScheduleEntrySuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => ConfirmDialog(
        icon: Icons.event_busy_rounded,
        tone: ConfirmDialogTone.neutral,
        title: l10n.removeScheduleTitle,
        message: l10n.removeScheduleMessage(planName, dayName),
        cancelLabel: l10n.removeScheduleCancelButton,
        confirmLabel: l10n.removeScheduleConfirmButton,
        busyLabel: l10n.removeScheduleRemovingLabel,
        retryLabel: l10n.removeScheduleRetryButton,
        errorMessage: l10n.scheduleRemoveError,
        status: _statusOf(state),
        onConfirm: () => context.read<RemoveScheduleEntryBloc>().add(
          RemoveScheduleEntryConfirmed(weekday: weekday),
        ),
      ),
    );
  }
}
