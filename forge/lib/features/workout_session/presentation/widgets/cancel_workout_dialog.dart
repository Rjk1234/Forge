import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/widgets/app_card.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Destructive confirmation card shown when the user cancels an active workout.
class CancelWorkoutDialog extends StatelessWidget {
  const CancelWorkoutDialog({
    required this.planName,
    this.isDiscarding = false,
    required this.onKeepGoing,
    required this.onDiscard,
    super.key,
  });

  static const double _cardRadius = AppRadius.dialog;
  static const double _cardVerticalPadding = AppSpacing.xl;
  static const double _cardHorizontalPadding = AppSpacing.lgx;
  static const double _contentGap = AppSpacing.smd;
  static const double _iconWrapSize = 52;
  static const double _iconSize = 24;
  static const double _actionsExtraGap = AppSpacing.sm;
  static const double _buttonRadius = AppRadius.control;
  static const double _buttonVerticalPadding = 13;

  final String planName;
  final bool isDiscarding;
  final VoidCallback onKeepGoing;
  final VoidCallback onDiscard;

  String _bodyText(AppLocalizations l10n) => planName.isEmpty
      ? l10n.cancelWorkoutBodyWithoutPlan
      : l10n.cancelWorkoutBodyWithPlan(planName);

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      isFullWidth: true,
      radius: _cardRadius,
      padding: const EdgeInsets.symmetric(
        vertical: _cardVerticalPadding,
        horizontal: _cardHorizontalPadding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _iconWrapSize,
            height: _iconWrapSize,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: _iconSize,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: _contentGap),
          Text(
            context.l10n.cancelWorkoutTitle,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: _contentGap),
          Text(
            _bodyText(context.l10n),
            textAlign: TextAlign.center,
            style: textStyles.bodyRelaxed,
          ),
          const SizedBox(height: _contentGap + _actionsExtraGap),
          Row(
            children: [
              Expanded(
                child: _buildKeepGoingButton(context, context.l10n, textTheme),
              ),
              const SizedBox(width: _contentGap),
              Expanded(
                child: _buildDiscardButton(context, context.l10n, textTheme),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeepGoingButton(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onKeepGoing,
      style: OutlinedButton.styleFrom(
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide(color: colorScheme.outline),
        padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
      child: Text(
        l10n.cancelWorkoutKeepGoingButton,
        style: textStyles.valueSmall.copyWith(color: colorScheme.onSurface),
      ),
    );
  }

  Widget _buildDiscardButton(
    BuildContext context,
    AppLocalizations l10n,
    TextTheme textTheme,
  ) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    return FilledButton(
      onPressed: isDiscarding ? null : onDiscard,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.error,
        disabledBackgroundColor: appColors.dangerBorder,
        padding: const EdgeInsets.symmetric(vertical: _buttonVerticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonRadius),
        ),
      ),
      child: Text(
        l10n.cancelWorkoutDiscardButton,
        style: textStyles.valueSmall.copyWith(color: appColors.onDanger),
      ),
    );
  }
}
