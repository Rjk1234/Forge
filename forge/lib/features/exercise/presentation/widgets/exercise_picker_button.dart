import 'package:flutter/material.dart';

class ExercisePickerButton extends StatelessWidget {
  const ExercisePickerButton({required this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.add,
            color: colorScheme.surfaceContainerLowest,
            size: 18,
          ),
        ),
      ),
    );
  }
}
