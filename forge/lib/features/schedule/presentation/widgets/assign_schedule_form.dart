import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forge/core/theme/app_colors_extension.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_bloc.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_event.dart';
import 'package:forge/features/schedule/application/bloc/assign_schedule_state.dart';
import 'package:forge/features/schedule/presentation/widgets/day_chip_row.dart';
import 'package:forge/features/schedule/presentation/widgets/plan_selector_display.dart';
import 'package:forge/features/schedule/presentation/widgets/recurrence_row.dart';
import 'package:forge/features/schedule/presentation/widgets/save_schedule_button.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_save_failure_banner.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/schedule/presentation/widgets/schedule_field_label.dart';

class AssignScheduleForm extends StatelessWidget {
  const AssignScheduleForm({
    required this.state,
    this.isSaving = false,
    this.hasSaveFailure = false,
    super.key,
  });

  final AssignScheduleReady state;
  final bool isSaving;
  final bool hasSaveFailure;

  @override
  Widget build(BuildContext context) {
    final helperText = state.conflicts.isEmpty
        ? _helperText(context.l10n)
        : null; // DayChipRow renders the conflict message instead.

    return Column(
      children: [
        if (hasSaveFailure)
          ScheduleSaveFailureBanner(message: context.l10n.scheduleSaveError),
        Expanded(
          child: IgnorePointer(
            ignoring: isSaving,
            child: Opacity(
              opacity: isSaving ? 0.45 : 1.0,
              child: _buildFields(context, helperText),
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
            enabled: state.canSave,
            isSaving: isSaving,
            isRetry: hasSaveFailure,
            onPressed: () => context.read<AssignScheduleBloc>().add(
              hasSaveFailure
                  ? const RetrySaveRequested()
                  : const SaveRequested(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFields(BuildContext context, String? helperText) {
    final appColors = AppColorsExtension.of(context);
    return SingleChildScrollView(
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
          PlanSelectorDisplay(planName: state.planName),
          const SizedBox(height: AppSpacing.lgx),
          ScheduleFieldLabel(context.l10n.daysFieldLabel),
          DayChipRow(
            selectedDays: state.selectedDays,
            conflicts: state.conflicts,
            onDayTapped: (weekday) =>
                context.read<AssignScheduleBloc>().add(DayToggled(weekday)),
          ),
          if (helperText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              helperText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: appColors.textDim),
            ),
          ],
          const SizedBox(height: AppSpacing.lgx),
          ScheduleFieldLabel(context.l10n.recurrenceFieldLabel),
          const RecurrenceRow(),
        ],
      ),
    );
  }

  String _helperText(AppLocalizations l10n) {
    if (state.selectedDays.isEmpty) {
      return l10n.selectAtLeastOneDayHelper;
    }
    final names = state.selectedDays.toList()..sort();
    final dayNames = names.map((d) => l10n.weekdayFullNames[d - 1]).join(', ');
    return l10n.scheduleHelperScheduledOn(dayNames);
  }
}
