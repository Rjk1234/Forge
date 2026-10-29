import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/core/theme/app_text_extension.dart';

/// Where an [AppEmptyState] sits: centred on its own screen, or inline under
/// other content (for example under dimmed tiles).
enum EmptyStateLayout { centered, inline }

/// Icon, title, subtitle and an optional call to action for "nothing here yet".
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.layout = EmptyStateLayout.centered,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction go together',
       );

  static const double _bottomOffset = 60;
  static const double _gap = AppSpacing.mdl;
  static const double _subtitleMaxWidth = 250;
  static const double _buttonHorizontalPadding = 22;

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EmptyStateLayout layout;

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    return switch (layout) {
      EmptyStateLayout.centered => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            0,
            AppSpacing.xxl,
            _bottomOffset,
          ),
          child: content,
        ),
      ),
      EmptyStateLayout.inline => Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xl,
          horizontal: AppSpacing.md,
        ),
        child: content,
      ),
    };
  }

  Widget _buildContent(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final appColors = AppColorsExtension.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Icon(
            icon,
            size: AppIconSize.illustration,
            color: appColors.textDim,
          ),
        ),
        const SizedBox(height: _gap),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: _gap),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _subtitleMaxWidth),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textStyles.bodyRelaxed,
          ),
        ),
        if (onAction != null) ...[
          const SizedBox(height: AppSpacing.xl),
          _buildAction(context),
        ],
      ],
    );
  }

  Widget _buildAction(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: onAction,
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        minimumSize: const Size(0, kMinTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: _buttonHorizontalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
      child: Text(
        actionLabel!,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary),
      ),
    );
  }
}
