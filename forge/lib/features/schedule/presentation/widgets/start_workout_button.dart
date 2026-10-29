import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_text_extension.dart';

class StartWorkoutButton extends StatelessWidget {
  const StartWorkoutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextExtension.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const StadiumBorder(),
          minimumSize: const Size(60, 44),
        ),
        child: Text(
          context.l10n.scheduleStartButton,
          style: textStyles.bodyStrong.copyWith(color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}
