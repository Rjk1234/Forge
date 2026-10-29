import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_colors_extension.dart';

class ProfileAvatarWrap extends StatelessWidget {
  const ProfileAvatarWrap({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColorsExtension.of(context);
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person_outline_rounded,
          size: 40,
          color: appColors.textDim,
        ),
      ),
    );
  }
}
