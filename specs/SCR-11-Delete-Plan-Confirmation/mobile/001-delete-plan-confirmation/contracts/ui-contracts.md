# UI Contracts: Delete Plan Confirmation (SCR-11)

**Date**: 2026-09-19 | **Feature**: SCR-11

---

## Contract 1: `DeletePlanDialog`

**File**: `forge/lib/features/workout_plan/presentation/widgets/delete_plan_dialog.dart`

**Type**: `StatelessWidget`

**Constructor**:
```
DeletePlanDialog({
  required String planId,   // ID of the plan to delete — passed to DeletePlanConfirmed event
  required String planName, // Used verbatim in the subtitle: ""{planName}" and its..."
  Key? key,
})
```

**Caller contract**: Caller (`PlanDetailScreen._onDelete`) MUST wrap the widget in a `BlocProvider<DeletePlanBloc>` before showing:
```dart
showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => BlocProvider(
    create: (_) => getIt<DeletePlanBloc>(),
    child: DeletePlanDialog(planId: planId, planName: planName),
  ),
);
```

**Return value**: `Navigator.pop(context, true)` on success; `Navigator.pop(context, false)` on cancel. The `showDialog` future resolves to `bool?` (null if the dialog is dismissed unexpectedly — treated as cancel by the caller).

**State rendering contract**:

| Bloc state | Cancel button | Right button | Inline error | `PopScope.canPop` |
|------------|---------------|--------------|--------------|-------------------|
| `DeletePlanConfirmation` | Enabled, `AppColors.cardAlt` bg | "Delete", `AppColors.danger` bg, `AppColors.onDanger` text | Hidden | `true` |
| `DeletePlanDeleting` | Disabled, opacity 0.5 | "Deleting…" + spinner, `AppColors.danger` bg, opacity 0.85 | Hidden | `false` |
| `DeletePlanSuccess` | — | — | — | — (dialog already popped) |
| `DeletePlanFailure` | Enabled, `AppColors.cardAlt` bg | "Retry", `AppColors.lime` bg, `Color(0xFF131315)` text | Visible | `true` |

**Colors contract** (all from `AppColors.*` or `theme.*`; no hardcoded hex values in widget):

| Element | Color source |
|---------|-------------|
| Scrim | `Color(0xA00A0A0A)` (passed as `barrierColor` to `showDialog`) |
| Card background | `AppColors.card` |
| Card border | `AppColors.border` |
| Dialog title text | `theme.colorScheme.onSurface` |
| Dialog subtitle text | `AppColors.textMuted` |
| Cancel bg | `AppColors.cardAlt` |
| Cancel text | `theme.colorScheme.onSurface` |
| Cancel border | `AppColors.border` |
| Cancel dim (Deleting) | Same + `Opacity(opacity: 0.5)` |
| Delete bg | `AppColors.danger` |
| Delete text | `AppColors.onDanger` |
| Retry bg | `AppColors.lime` |
| Retry text | `Color(0xFF131315)` — dark text on lime; same as used on lime buttons elsewhere in the app |
| Spinner color | `AppColors.onDanger` |
| Trash icon | `AppColors.danger` |

**Strings contract** (all from `AppStrings.*`):

| Element | `AppStrings` constant |
|---------|----------------------|
| Dialog title | `AppStrings.deletePlanDialogTitle` |
| Subtitle template | `AppStrings.deletePlanDialogSubtitle` (contains `{planName}` placeholder, interpolated at runtime) |
| Cancel button | `AppStrings.deletePlanCancelButton` |
| Delete button | `AppStrings.deletePlanDeleteButton` |
| Deleting label | `AppStrings.deletePlanDeletingLabel` |
| Retry button | `AppStrings.deletePlanRetryButton` |
| Error message | `AppStrings.deletePlanErrorMessage` |

**Touch target contract**: Cancel and Delete/Retry buttons MUST each have `minimumSize: Size(double.infinity, 44)` to meet the 44pt touch-target minimum (design spec §7 flags the 37pt visual height as non-compliant).

**Accessibility contract**:
- On dialog open, focus MUST be on the dialog (Flutter's `showDialog` handles this automatically).
- `Delete` button: semantic label from `AppStrings.deletePlanDeleteButton`.
- `Cancel` button during Deleting: announce as unavailable/dimmed (use `ExcludeSemantics` or set `onPressed: null` to trigger Flutter's built-in disabled semantics).
- `InlineDialogError`: wrapped in `Semantics(liveRegion: true)` so VoiceOver/TalkBack announces the error when it appears.

---

## Contract 2: `InlineDialogError`

**File**: `forge/lib/core/widgets/inline_dialog_error.dart`

**Type**: `StatelessWidget`

**Constructor**:
```
InlineDialogError({
  required String message,  // Error text to display
  Key? key,
})
```

**Visual contract**:
- Background: `AppColors.dangerBg` (`Color(0xFF2A1F1F)`)
- Border: `1px solid AppColors.dangerBorder` (`Color(0xFF5C3A3A)`)
- Border radius: 10px
- Padding: 9px vertical, 12px horizontal
- Text: `theme.textTheme.bodySmall` style, color `AppColors.danger`, weight 600
- Width: `double.infinity` (stretches to fill parent)

**Accessibility contract**: Wrapped in `Semantics(liveRegion: true)` by the widget itself — callers do not need to add it.

---

## Contract 3: `WorkoutPlanRepository.deletePlan`

**Interface**: `forge/lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`

```dart
Future<Either<AppException, void>> deletePlan(String planId);
```

**Preconditions**: `planId.isNotEmpty`

**Success postcondition**: `workout_plans` table has no row for `planId`; `schedule_entries` table has no rows where `entry.planId == planId`; `workout_sessions` table is unchanged.

**Failure postcondition**: Returns `Left(CacheException(message: ..., originalException: e))`. Data state is consistent (either nothing was modified, or schedules were partially cleaned but plan is intact — see research.md Decision 2).

**Idempotency**: Calling `deletePlan` on a planId that is already absent from the table is a no-op (a Drift delete that matches zero rows does not throw). Returns `Right(null)`.

---

## Contract 4: `ScheduleLocalDataSource.deleteEntriesForPlan`

**Interface**: `forge/lib/features/schedule/data/datasources/schedule_local_data_source.dart`

```dart
Future<void> deleteEntriesForPlan(String planId);
```

**Behavior**: Scans all entries in `schedule_entries` table (max 7), deletes each where `entry.planId == planId`. Uses existing `deleteEntry(weekday)` internally. If no entries match, the method is a no-op.

**Throws**: May throw if Drift throws (storage error). Exception propagates to caller (`WorkoutPlanRepositoryImpl.deletePlan`).

---

## Contract 5: `DeleteWorkoutPlanUseCase`

**File**: `forge/lib/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart`

```dart
class DeleteWorkoutPlanUseCase {
  DeleteWorkoutPlanUseCase(this.repository);
  final WorkoutPlanRepository repository;
  Future<Either<AppException, void>> call(String planId) =>
      repository.deletePlan(planId);
}
```

**Called by**: `DeletePlanBloc._onConfirmed`
