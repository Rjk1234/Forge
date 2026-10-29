import 'package:flutter/material.dart';
import 'package:forge/core/theme/app_dimensions.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_event.dart';
import 'package:forge/features/workout_plan/application/bloc/create_edit_workout_plan_state.dart';
import 'package:forge/features/workout_plan/presentation/widgets/exercise_card.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_field_error_text.dart';
import 'package:forge/features/workout_plan/presentation/widgets/plan_name_field.dart';
import 'package:forge/features/workout_plan/presentation/widgets/save_failure_banner.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/features/workout_plan/presentation/widgets/empty_exercises_placeholder.dart';
import 'package:forge/features/workout_plan/presentation/widgets/create_edit_plan_footer.dart';

class CreateEditPlanForm extends StatefulWidget {
  const CreateEditPlanForm({
    required this.state,
    required this.onNameChanged,
    required this.onAddExercise,
    required this.onFieldChanged,
    required this.onRemoveExercise,
    required this.onSave,
    required this.onRetry,
    super.key,
  });

  final CreateEditWorkoutPlanState state;
  final ValueChanged<String> onNameChanged;
  final Future<void> Function(String planName) onAddExercise;
  final void Function(int index, ExerciseField field, String value)
  onFieldChanged;
  final ValueChanged<int> onRemoveExercise;
  final VoidCallback onSave;
  final VoidCallback onRetry;

  @override
  State<CreateEditPlanForm> createState() => _CreateEditPlanFormState();
}

class _CreateEditPlanFormState extends State<CreateEditPlanForm> {
  static const Duration _scrollDuration = Duration(milliseconds: 300);
  static const double _scrollAlignment = 0.1;

  final GlobalKey _nameKey = GlobalKey();
  final GlobalKey _emptyExercisesKey = GlobalKey();
  final Map<int, GlobalKey> _cardKeys = {};

  CreateEditPlanReady get _ready {
    return switch (widget.state) {
      CreateEditPlanReady s => s,
      CreateEditPlanSaving s => s.readyState,
      CreateEditPlanSaveFailure s => s.readyState,
      _ => throw StateError('CreateEditPlanForm used with non-ready state'),
    };
  }

  bool get _isSaving => widget.state is CreateEditPlanSaving;

  GlobalKey _cardKey(int index) => _cardKeys.putIfAbsent(index, GlobalKey.new);

  @override
  void didUpdateWidget(CreateEditPlanForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready.rejectedSaveCount > _rejectedSaveCountOf(oldWidget.state)) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToFirstError(),
      );
    }
  }

  int _rejectedSaveCountOf(CreateEditWorkoutPlanState state) => switch (state) {
    CreateEditPlanReady s => s.rejectedSaveCount,
    CreateEditPlanSaving s => s.readyState.rejectedSaveCount,
    CreateEditPlanSaveFailure s => s.readyState.rejectedSaveCount,
    _ => 0,
  };

  /// Brings the first invalid part of the form into view: the name, then the
  /// empty exercise list, then the first exercise with a rejected field.
  void _scrollToFirstError() {
    if (!mounted) return;
    final ready = _ready;
    final firstInvalidCard = ready.exercises.indexWhere((e) => e.hasErrors);
    final target = ready.nameError != null
        ? _nameKey
        : ready.exercisesError != null
        ? _emptyExercisesKey
        : firstInvalidCard >= 0
        ? _cardKey(firstInvalidCard)
        : null;
    final targetContext = target?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: _scrollDuration,
      alignment: _scrollAlignment,
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ready = _ready;

    return Column(
      children: [
        if (widget.state is CreateEditPlanSaveFailure)
          SaveFailureBanner(
            message: context.l10n.savePlanFailureMessage,
            onRetry: widget.onRetry,
          ),
        Expanded(
          child: Opacity(
            opacity: _isSaving ? 0.6 : 1.0,
            // Every card is built (not lazily) so any of them can be scrolled to.
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KeyedSubtree(
                    key: _nameKey,
                    child: PlanNameField(
                      value: ready.planName,
                      onChanged: widget.onNameChanged,
                      errorText: context.l10n.planFieldError(ready.nameError),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (ready.exercises.isEmpty)
                    KeyedSubtree(
                      key: _emptyExercisesKey,
                      child: EmptyExercisesPlaceholder(
                        textTheme: textTheme,
                        errorText: context.l10n.planFieldError(
                          ready.exercisesError,
                        ),
                      ),
                    )
                  else
                    ...ready.exercises.asMap().entries.map(
                      (e) => ExerciseCard(
                        key: _cardKey(e.key),
                        entry: e.value,
                        index: e.key,
                        onFieldChanged: widget.onFieldChanged,
                        onRemove: () => widget.onRemoveExercise(e.key),
                        isSaving: _isSaving,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAddExerciseButton(context, ready),
                ],
              ),
            ),
          ),
        ),
        CreateEditPlanFooter(isSaving: _isSaving, onSave: widget.onSave),
      ],
    );
  }

  Widget _buildAddExerciseButton(
    BuildContext context,
    CreateEditPlanReady ready,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: _isSaving ? null : () => widget.onAddExercise(ready.planName),
      icon: const Icon(Icons.add, size: 18),
      label: Text(context.l10n.addExerciseButton),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.mdl),
      ),
    );
  }
}
