import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/button_spinner.dart';
import 'package:forge/core/widgets/status_banner.dart';

/// Progress of the action a [ConfirmDialog] confirms.
enum ConfirmDialogStatus { idle, busy, failed }

/// Whether confirming is destructive (red button) or an ordinary action.
enum ConfirmDialogTone { destructive, neutral }

/// Icon, title and message with Cancel / Confirm buttons that also shows the
/// running and failed states of the action (Deleting…, Retry).
///
/// It is presentational only: the caller owns the Bloc and maps its state to
/// [status].
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.icon,
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.busyLabel,
    required this.retryLabel,
    required this.errorMessage,
    required this.status,
    required this.onConfirm,
    this.tone = ConfirmDialogTone.destructive,
    super.key,
  });

  static const double _contentVerticalPadding = AppSpacing.xl;
  static const double _contentHorizontalPadding = AppSpacing.lgx;
  static const double _buttonGap = AppSpacing.smd;
  static const double _disabledOpacity = 0.5;

  final IconData icon;
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final String busyLabel;
  final String retryLabel;
  final String errorMessage;
  final ConfirmDialogStatus status;
  final VoidCallback onConfirm;
  final ConfirmDialogTone tone;

  bool get _isBusy => status == ConfirmDialogStatus.busy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_isBusy,
      child: Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.dialog),
          side: BorderSide(color: colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: _contentVerticalPadding,
            horizontal: _contentHorizontalPadding,
          ),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final iconColor = tone == ConfirmDialogTone.destructive
        ? colorScheme.error
        : colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: AppIconSize.dialog),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          message,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        if (status == ConfirmDialogStatus.failed) ...[
          const SizedBox(height: AppSpacing.md),
          StatusBanner(message: errorMessage),
        ],
        const SizedBox(height: _contentHorizontalPadding),
        _buildActions(context),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Expanded(
          child: Opacity(
            opacity: _isBusy ? _disabledOpacity : 1,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              onPressed: _isBusy ? null : () => Navigator.pop(context, false),
              child: Text(
                cancelLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: _buttonGap),
        Expanded(child: _buildConfirmButton(context)),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = AppColorsExtension.of(context);
    final textTheme = theme.textTheme;
    final isRetry = status == ConfirmDialogStatus.failed;
    final isDestructive = tone == ConfirmDialogTone.destructive && !isRetry;
    final background = isDestructive ? colorScheme.error : colorScheme.primary;
    final foreground = isDestructive
        ? appColors.onDanger
        : colorScheme.onPrimary;
    final label = textTheme.labelLarge?.copyWith(color: foreground);

    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: background),
      onPressed: _isBusy ? null : onConfirm,
      child: _isBusy
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonSpinner(color: foreground),
                const SizedBox(width: AppSpacing.sm),
                Text(busyLabel, style: label),
              ],
            )
          : Text(isRetry ? retryLabel : confirmLabel, style: label),
    );
  }
}
