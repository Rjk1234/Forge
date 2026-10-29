import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/widgets/confirm_dialog.dart';
import 'package:forge/features/profile/application/bloc/logout_bloc.dart';
import 'package:forge/features/profile/application/bloc/logout_event.dart';
import 'package:forge/features/profile/application/bloc/logout_state.dart';
import 'package:forge/l10n/l10n.dart';

/// Confirms logging out, which also deletes the user's data. Pops `true` once
/// the data is cleared and `false` when the user cancels.
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  ConfirmDialogStatus _statusOf(LogoutState state) => switch (state) {
    LogoutInProgress() => ConfirmDialogStatus.busy,
    LogoutFailure() => ConfirmDialogStatus.failed,
    _ => ConfirmDialogStatus.idle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) Navigator.pop(context, true);
      },
      builder: (context, state) => ConfirmDialog(
        icon: Icons.logout_rounded,
        title: l10n.logoutDialogTitle,
        message: l10n.logoutDialogMessage,
        cancelLabel: l10n.logoutCancelButton,
        confirmLabel: l10n.logoutConfirmButton,
        busyLabel: l10n.logoutBusyLabel,
        retryLabel: l10n.logoutRetryButton,
        errorMessage: l10n.logoutError,
        status: _statusOf(state),
        onConfirm: () =>
            context.read<LogoutBloc>().add(const LogoutConfirmed()),
      ),
    );
  }
}
