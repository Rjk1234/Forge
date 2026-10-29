import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';

import 'package:forge/features/profile/presentation/widgets/profile_field_group.dart';
import 'package:forge/features/profile/presentation/widgets/profile_field_input.dart';

class ProfileFieldRow2 extends StatelessWidget {
  const ProfileFieldRow2({
    required this.leftLabel,
    required this.leftController,
    required this.leftHint,
    required this.rightLabel,
    required this.rightController,
    required this.rightHint,
    this.leftHasError = false,
    this.leftErrorText,
    this.rightHasError = false,
    this.rightErrorText,
    super.key,
  });

  final String leftLabel;
  final TextEditingController leftController;
  final String leftHint;
  final String rightLabel;
  final TextEditingController rightController;
  final String rightHint;
  final bool leftHasError;
  final String? leftErrorText;
  final bool rightHasError;
  final String? rightErrorText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ProfileFieldGroup(
            label: leftLabel,
            child: ProfileFieldInput(
              controller: leftController,
              hint: leftHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hasError: leftHasError,
              errorText: leftErrorText,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ProfileFieldGroup(
            label: rightLabel,
            child: ProfileFieldInput(
              controller: rightController,
              hint: rightHint,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              hasError: rightHasError,
              errorText: rightErrorText,
            ),
          ),
        ),
      ],
    );
  }
}
