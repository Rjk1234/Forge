import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/schedule/presentation/widgets/day_chip_row.dart';
import 'package:forge/features/schedule/presentation/widgets/invalid_plan_banner.dart';
import 'package:forge/features/schedule/presentation/widgets/save_schedule_button.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_field_label.dart';

class InvalidPlanBody extends StatelessWidget {
  const InvalidPlanBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lgx,
              0,
              AppSpacing.lgx,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScheduleFieldLabel(context.l10n.workoutPlanFieldLabel),
                const InvalidPlanBanner(),
                const SizedBox(height: AppSpacing.lgx),
                ScheduleFieldLabel(context.l10n.daysFieldLabel),
                IgnorePointer(
                  child: Opacity(
                    opacity: 0.4,
                    child: DayChipRow(
                      selectedDays: const {},
                      conflicts: const {},
                      onDayTapped: (_) {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lgx,
            AppSpacing.mdl,
            AppSpacing.lgx,
            AppSpacing.lgx,
          ),
          child: SaveScheduleButton(
            enabled: false,
            isSaving: false,
            isRetry: false,
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
