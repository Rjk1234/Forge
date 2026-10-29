# Tasks: Delete Plan Confirmation (SCR-11)

**Input**: Design documents from `specs/SCR-11-Delete-Plan-Confirmation/mobile/001-delete-plan-confirmation/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ui-contracts.md ✅, quickstart.md ✅

**Tests**: Included — Bloc unit tests and widget tests per constitution XI.3 and quickstart.md validation scenarios. Tests use plain `flutter_test` with fake implementations (no `bloc_test`/`mocktail` — not in pubspec.yaml).

**Organization**: Tasks grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add string constants, the `onDanger` colour token, and the shared `InlineDialogError` widget. These are prerequisites for all user stories.

- [x] T001 Add SCR-11 string constants (`deletePlanDialogTitle`, `deletePlanDialogSubtitle`, `deletePlanCancelButton`, `deletePlanDeleteButton`, `deletePlanDeletingLabel`, `deletePlanRetryButton`, `deletePlanErrorMessage`) to `forge/lib/core/strings/app_strings.dart`
- [x] T002 [P] Add three new colour tokens to `forge/lib/core/theme/app_colors.dart`: `static const Color onDanger = Color(0xFF2A1414)` (text on danger-red fill; ~4.6:1 contrast), `static const Color scrimBarrier = Color(0xA00A0A0A)` (dialog overlay scrim), `static const Color onLime = Color(0xFF131315)` (text on lime fill). These cover every hardcoded hex value used in the delete dialog — no inline hex in widget code is permitted (constitution VIII.5).
- [x] T003 [P] Create public `InlineDialogError({required String message})` `StatelessWidget` at `forge/lib/core/widgets/inline_dialog_error.dart` — background `AppColors.dangerBg`, border `AppColors.dangerBorder`, 10px radius, 9×12px padding, danger-coloured text (`AppColors.danger`), `textTheme.bodySmall` style, weight 600, `width: double.infinity`, wrapped in `Semantics(liveRegion: true)`; all colours from `AppColors.*`

**Checkpoint**: Shared tokens and components ready — `AppStrings`, `AppColors.onDanger`, and `InlineDialogError` available for use across all phases.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Data-layer plumbing: schedule entry cleanup, repository delete method, use case. Must complete before any Bloc or UI work.

⚠️ **CRITICAL**: T005 and T006 are in the domain and data layers. They must observe Clean Architecture layer rules — `domain/` MUST NOT import `data/`, `application/`, `presentation/`, or any Flutter/Drift package.

- [x] T004 [P] Add `Future<void> deleteEntriesForPlan(String planId)` to the `ScheduleLocalDataSource` abstract class and implement it in `ScheduleLocalDataSourceImpl` in `forge/lib/features/schedule/data/datasources/schedule_local_data_source.dart` — selects the `schedule_entries` rows (max 7) and deletes the row for each `entry.weekday` where `entry.planId == planId`; no-op if no matches. Also create (or update) `forge/lib/features/schedule/schedule.dart` as a barrel file that exports `ScheduleLocalDataSource` (the abstract interface only, not the implementation) — this is required for T006 to import it via a cross-feature barrel rather than a direct internal path (constitution I.5)
- [x] T005 Add abstract method `Future<Either<AppException, void>> deletePlan(String planId)` to `WorkoutPlanRepository` in `forge/lib/features/workout_plan/domain/repositories/workout_plan_repository.dart`
- [x] T006 Add `scheduleDataSource: ScheduleLocalDataSource` constructor parameter to `WorkoutPlanRepositoryImpl` and implement `deletePlan(String planId)` in `forge/lib/features/workout_plan/data/repositories/workout_plan_repository_impl.dart` — sequential delete: `await scheduleDataSource.deleteEntriesForPlan(planId)` first, then `await dataSource.deletePlan(planId)`; wrap both in try/catch returning `Left(CacheException(message: "Couldn't delete the plan", originalException: e))` on error; `Right(null)` on success. Import `ScheduleLocalDataSource` via the schedule feature barrel (`package:forge/features/schedule/schedule.dart`), NOT via a direct internal path — this satisfies constitution I.5 (cross-feature communication must use published barrel files)
- [x] T007 Update `WorkoutPlanRepositoryImpl` registration in `forge/lib/app/get_it_setup.dart` to pass `scheduleDataSource: getIt<ScheduleLocalDataSource>()` as the second constructor argument; `ScheduleLocalDataSource` is already registered as a `lazySingleton`
- [x] T008 Create `DeleteWorkoutPlanUseCase` at `forge/lib/features/workout_plan/domain/usecases/delete_workout_plan_usecase.dart` — takes `WorkoutPlanRepository` in constructor, `call(String planId)` delegates to `repository.deletePlan(planId)`; `domain/` only — no Flutter imports

**Checkpoint**: Data layer complete — `DeleteWorkoutPlanUseCase` wired through `WorkoutPlanRepositoryImpl` down to `ScheduleLocalDataSource` and `WorkoutPlanLocalDataSource`.

---

## Phase 3: User Story 1 — Confirm or Cancel Deletion (Priority: P1) 🎯 MVP

**Goal**: A user opens the deletion dialog from SCR-10, reads the plan name and impact statement, and can either cancel (plan unchanged) or initiate deletion (triggers Bloc transition).

**Independent Test**: Seed a `PlanDetailLoaded` state in SCR-10 with a plan. Tap the Delete icon. Verify the dialog appears with the correct plan name in the subtitle. Tap Cancel — dialog closes, plan still in Drift. The Bloc initial state, Cancel path, and dialog rendering can all be tested without US2 (Deleting) or US3 (Failure) being implemented.

### Tests for User Story 1

- [x] T009 [P] [US1] Create `forge/test/features/workout_plan/application/bloc/delete_plan_bloc_test.dart` — unit tests using `bloc_test` (`blocTest<DeletePlanBloc, DeletePlanState>(...)`) and `mocktail` (`MockWorkoutPlanRepository extends Mock implements WorkoutPlanRepository`); `when(() => mock.deletePlan(any())).thenAnswer((_) async => const Right(null))` for success; `Left(CacheException(...))` for failure: (1) `build: () => DeletePlanBloc(DeleteWorkoutPlanUseCase(mock))` — initial state is `DeletePlanConfirmation`; (2) `act: (bloc) => bloc.add(DeletePlanConfirmed(planId: 'p1'))`, `expect: [DeletePlanDeleting, DeletePlanSuccess]` (success path); (3) failure variant → `[DeletePlanDeleting, isA<DeletePlanFailure>()]`; (4) retry path: `seed: DeletePlanFailure(message: '...')` → add `DeletePlanConfirmed` → `[DeletePlanDeleting, DeletePlanSuccess]`; (5) `wait` variant — use a Completer-backed mock that never resolves to verify `DeletePlanDeleting` is emitted without advancing to Success
- [x] T010 [P] [US1] Create `forge/test/features/workout_plan/presentation/widgets/delete_plan_dialog_test.dart` — widget tests using a `MockDeletePlanBloc extends MockBloc<DeletePlanEvent, DeletePlanState> implements DeletePlanBloc` (via `mocktail`'s `MockBloc`); seed the mock Bloc in `DeletePlanConfirmation` via `when(() => bloc.state).thenReturn(const DeletePlanConfirmation())`; wrap under `BlocProvider<DeletePlanBloc>.value(value: bloc, child: DeletePlanDialog(...))` inside `MaterialApp`; verify: dialog title `AppStrings.deletePlanDialogTitle` visible; subtitle contains the `planName` argument; `AppStrings.deletePlanCancelButton` button present; tapping Cancel pops the dialog (use `NavigatorObserver` mock or wrap in `showDialog` and verify result); `AppStrings.deletePlanDeleteButton` button present and enabled (non-null `onPressed`); tapping Delete adds `DeletePlanConfirmed` to Bloc (use `verify(() => bloc.add(DeletePlanConfirmed(planId: 'test-id'))).called(1)`)

### Implementation for User Story 1

- [x] T011 [P] [US1] Create `forge/lib/features/workout_plan/application/bloc/delete_plan_event.dart` — `sealed class DeletePlanEvent extends Equatable`; single subclass `final class DeletePlanConfirmed extends DeletePlanEvent` with `required String planId` field and `props: [planId]`
- [x] T012 [P] [US1] Create `forge/lib/features/workout_plan/application/bloc/delete_plan_state.dart` — `sealed class DeletePlanState extends Equatable`; four subclasses: `DeletePlanConfirmation` (initial), `DeletePlanDeleting`, `DeletePlanSuccess`, `DeletePlanFailure({required String message})`; each with empty or message-only `props`
- [x] T013 [US1] Create `forge/lib/features/workout_plan/application/bloc/delete_plan_bloc.dart` — `class DeletePlanBloc extends Bloc<DeletePlanEvent, DeletePlanState>`; constructor takes `DeleteWorkoutPlanUseCase deleteWorkoutPlan`; `super(const DeletePlanConfirmation())`; single handler `on<DeletePlanConfirmed>(_onConfirmed)`: emit `DeletePlanDeleting()` → `await deleteWorkoutPlan(event.planId)` → fold `Left(failure)` → emit `DeletePlanFailure(message: failure.message)`, `Right(_)` → emit `DeletePlanSuccess()`
- [x] T014 [US1] Register `DeleteWorkoutPlanUseCase` (`registerLazySingleton`) and `DeletePlanBloc` (`registerFactory`) in `forge/lib/app/get_it_setup.dart`; `DeletePlanBloc` factory takes `getIt<DeleteWorkoutPlanUseCase>()` as constructor argument
- [x] T015 [US1] Create `forge/lib/features/workout_plan/presentation/widgets/delete_plan_dialog.dart` — `class DeletePlanDialog extends StatelessWidget` with `required String planId` and `required String planName`; uses `BlocConsumer<DeletePlanBloc, DeletePlanState>` — listener: on `DeletePlanSuccess` call `Navigator.pop(context, true)`; builder: renders centred card (trash icon `AppColors.danger` 36×36px; title `AppStrings.deletePlanDialogTitle`; subtitle `'"$planName" and…'`; action row) inside a full-screen scrim; Confirmation state: Cancel button (`onPressed: () => Navigator.pop(context, false)`, `AppColors.cardAlt` bg) + Delete button (dispatches `DeletePlanConfirmed(planId: planId)`, `AppColors.danger` bg, `AppColors.onDanger` text); minimum button height 44px; all strings from `AppStrings.*`; all colours from `AppColors.*`; NO hardcoded hex values in widget body (use `AppColors.scrimBarrier`, `AppColors.onDanger`, `AppColors.onLime` tokens from T002)
- [x] T016 [US1] Update `forge/lib/features/workout_plan/presentation/screens/plan_detail_screen.dart` — change `_onDelete` to accept the current plan name: `Future<void> _onDelete(String planName) async`; replace `await context.push('/plans/${widget.planId}/delete')` with `final deleted = await showDialog<bool>(context: context, barrierDismissible: true, barrierColor: AppColors.scrimBarrier, builder: (_) => BlocProvider(create: (_) => getIt<DeletePlanBloc>(), child: DeletePlanDialog(planId: widget.planId, planName: planName)))`; after the await: `if (!context.mounted) return; if (deleted == true) { context.go('/plans'); } else { _reload(); }`; update the `_onDelete` call site in `_buildLoaded(plan)` to pass `plan.name`. Note: `barrierDismissible: true` allows scrim tap to act as Cancel (pops with `null`; the `if (deleted == true)` guard treats `null` the same as `false` — plan unchanged). `PopScope` in the dialog widget blocks the barrier tap during Deleting state.

**Checkpoint**: US1 complete — dialog opens with correct plan name, Cancel works, Delete triggers Bloc state transition.

---

## Phase 4: User Story 2 — Deletion In Progress (Priority: P2)

**Goal**: While the Drift delete is in flight, all dialog interaction is locked — Cancel is disabled, back gestures are blocked, and the Delete button shows a spinner.

**Independent Test**: Hold the Bloc in `DeletePlanDeleting` (use `_HangingRepo`). Verify Cancel has `onPressed == null`, a spinner is visible alongside "Deleting…" text, and `PopScope` prevents back-pop in the Deleting state.

### Tests for User Story 2

- [x] T017 [US2] Extend `forge/test/features/workout_plan/presentation/widgets/delete_plan_dialog_test.dart` with two groups of tests: (A) **Deleting state** — seed `MockDeletePlanBloc` in `DeletePlanDeleting` via `when(() => bloc.state).thenReturn(const DeletePlanDeleting())`; Cancel button has `onPressed == null` (disabled); `AppStrings.deletePlanDeletingLabel` text visible; `CircularProgressIndicator` found in widget tree; (B) **BlocListener success path** — seed `MockDeletePlanBloc` in `DeletePlanConfirmation`; emit `DeletePlanSuccess` via `whenListen(bloc, Stream.value(const DeletePlanSuccess()), initialState: const DeletePlanConfirmation())`; pump the dialog inside `showDialog`; after `pumpAndSettle` verify the dialog is no longer in the widget tree (popped with `true`) — this validates the listener's `Navigator.pop(context, true)` fires on `DeletePlanSuccess`

### Implementation for User Story 2

- [x] T018 [US2] Update `forge/lib/features/workout_plan/presentation/widgets/delete_plan_dialog.dart` — wrap dialog body in `PopScope(canPop: state is! DeletePlanDeleting, onPopInvokedWithResult: (didPop, _) { if (didPop && state is! DeletePlanDeleting) Navigator.pop(context, false); })`; add Deleting state rendering in the `builder` switch: Cancel wrapped in `Opacity(opacity: 0.5)` with `onPressed: null`; Delete button shows `Row([SizedBox(width:15, height:15, child: CircularProgressIndicator(strokeWidth:2, color: AppColors.onDanger, backgroundColor: AppColors.onDanger.withValues(alpha: 0.3))), SizedBox(width:8), Text(AppStrings.deletePlanDeletingLabel)])` inside an `Opacity(opacity: 0.85)` FilledButton with `AppColors.danger` bg and `AppColors.onDanger` fg. Use `withValues(alpha: ...)` NOT the deprecated `withOpacity(...)` (Dart 3.x deprecation — would trigger analyzer warning, violating T022)

**Checkpoint**: US2 complete — all interaction is locked during the Drift write.

---

## Phase 5: User Story 3 — Delete Failure and Retry (Priority: P3)

**Goal**: When the Drift delete fails, an inline error message appears confirming nothing was removed, Cancel is restored, and a lime Retry button re-attempts the deletion without needing a fresh confirmation.

**Independent Test**: Seed Bloc with `DeletePlanFailure(message: '...')` state. Verify `InlineDialogError` is in the widget tree with the error text, Cancel is enabled, Retry is lime-coloured, and tapping Retry dispatches `DeletePlanConfirmed`.

### Tests for User Story 3

- [x] T019 [US3] Extend `forge/test/features/workout_plan/presentation/widgets/delete_plan_dialog_test.dart` — Failure state tests: seed `MockDeletePlanBloc` in `DeletePlanFailure(message: AppStrings.deletePlanErrorMessage)` via `when(() => bloc.state).thenReturn(DeletePlanFailure(message: AppStrings.deletePlanErrorMessage))`; verify: `InlineDialogError` widget found in tree; `AppStrings.deletePlanErrorMessage` text visible; `AppStrings.deletePlanCancelButton` button has non-null `onPressed` (enabled); `AppStrings.deletePlanRetryButton` button present; tapping Retry calls `verify(() => bloc.add(DeletePlanConfirmed(planId: 'test-id'))).called(1)` via `mocktail`

### Implementation for User Story 3

- [x] T020 [US3] Update `forge/lib/features/workout_plan/presentation/widgets/delete_plan_dialog.dart` — add Failure state rendering in the `builder` switch: insert `InlineDialogError(message: state.message)` between the subtitle `Text` and the action `Row`; Retry button uses `FilledButton` with `style: FilledButton.styleFrom(backgroundColor: AppColors.lime, foregroundColor: AppColors.onLime, minimumSize: const Size(double.infinity, 44))`; Cancel button identical to Confirmation state (fully enabled); `Retry` dispatches `DeletePlanConfirmed(planId: planId)`. Before referencing `AppColors.lime`, confirm the token exists in `app_colors.dart` — if absent, add `static const Color lime = Color(0xFFCCF381)` (or the value already defined for lime buttons elsewhere in the app) so there are no undefined-symbol errors at T022

**Checkpoint**: US3 complete — all three dialog states render correctly and all state transitions are wired.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Static analysis, formatting, full test pass, and quickstart validation.

- [x] T021 [P] Run `dart format .` from `forge/` and fix any formatting issues introduced by SCR-11 files
- [x] T022 [P] Run `flutter analyze` from `forge/` and resolve every warning or error introduced by SCR-11 changes — zero new issues allowed
- [x] T023 Run `flutter test test/features/workout_plan/` from `forge/` and confirm all SCR-11 tests pass with no regressions in existing tests (SCR-10 bloc tests, SCR-10 screen tests, plans screen tests, create/edit screen tests)
- [ ] T024 Manually validate VS-01 through VS-15 from `quickstart.md` on iOS Simulator or Android Emulator — mark each scenario pass/fail

**Checkpoint**: SCR-11 complete — all tests pass, analyzer clean, quickstart validated.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — can start immediately. T002 and T003 can run in parallel.
- **Foundational (Phase 2)**: Depends on Phase 1 (T001 required for AppStrings; T002 required for AppColors.onDanger/scrimBarrier/onLime used in T015/T016/T018/T020). T003 is genuinely independent of T002 — `InlineDialogError` uses only pre-existing tokens (`dangerBg`, `dangerBorder`, `danger`); `onDanger`/`scrimBarrier`/`onLime` (T002) are consumed by T015/T016/T018/T020, not T003. T004 and T005 can run in parallel (different files). T006 depends on T004+T005. T007 depends on T006. T008 depends on T005.
- **US1 (Phase 3)**: Depends on Foundational completion. T011 and T012 can start after T001 (AppStrings) and T002 (AppColors). T013 depends on T011+T012. T009 depends on T011+T012+T013. T014 depends on T013+T008. T015 depends on T003 (InlineDialogError), T011, T012, T013. T010 depends on T015. T016 depends on T015+T014.
- **US2 (Phase 4)**: Depends on US1 — T018 extends `DeletePlanDialog` (T015).
- **US3 (Phase 5)**: Depends on US1 — T020 extends `DeletePlanDialog` (T015).
- **Polish (Phase 6)**: Depends on all user story phases complete.

### Within Each User Story

- US1: T011 + T012 [P] → T013 → T009 [P] + T014 → T015 → T010 [P] + T016
- US2: T017 → T018
- US3: T019 → T020

### Parallel Opportunities

- T002 and T003 can start in parallel (different files; T003 uses `dangerBg`/`dangerBorder` which already exist)
- T004 and T005 can run in parallel (different features; T004 is schedule, T005 is domain interface)
- T008 can run in parallel with T004+T005 (use case skeleton can be written before implementation)
- T011 and T012 can run in parallel (different files)
- T009 and T010 can be written [P] after their prerequisite files exist
- T021 and T022 can run in parallel (format vs analyze — both read-only checks)

---

## Parallel Example: User Story 1

```bash
# Foundation (T011 and T012 in parallel):
T011: delete_plan_event.dart
T012: delete_plan_state.dart

# After T011 + T012:
T013: delete_plan_bloc.dart

# After T013 (in parallel):
T009: delete_plan_bloc_test.dart     ← tests expected to fail until T013 compiles cleanly
T014: get_it_setup.dart (register)

# After T013 + T003 (InlineDialogError):
T015: delete_plan_dialog.dart

# After T015 (in parallel):
T010: delete_plan_dialog_test.dart
T016: plan_detail_screen.dart (update _onDelete)
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Open SCR-10 on a seeded plan, tap Delete, verify dialog appears with plan name and subtitle, tap Cancel — plan intact.
5. Proceed to US2 (loading lock) once US1 is verified.

### Incremental Delivery

1. Setup + Foundational → data-layer delete wired
2. US1 → Confirmation dialog (MVP)
3. US2 → In-progress lock (safety improvement)
4. US3 → Failure + Retry (resilience)
5. Polish → Analyzer clean, tests green, quickstart validated

---

## Notes

- [P] tasks = different files, no shared-state dependencies
- All colours MUST come from `AppColors.*` / `theme.colorScheme` — no hardcoded hex in widgets. All previously-noted unresolved hex values are now tokens in T002: `AppColors.scrimBarrier` (scrim overlay), `AppColors.onLime` (Retry fg text), `AppColors.onDanger` (Delete fg text)
- All user-facing strings MUST use `AppStrings.*` — no hardcoded string literals in widgets
- `DeletePlanBloc` uses `registerFactory` — fresh instance per dialog open
- Tests use `bloc_test` and `mocktail` (added to `forge/pubspec.yaml` dev_dependencies — governed set per constitution IX.5, mandated by XI.3). Generated Drift code (`app_database.g.dart`) is pre-generated and committed; regenerate with `dart run build_runner build` after any schema change.
- `showDialog` uses `barrierDismissible: true` so scrim tap acts as Cancel in Confirmation/Failure states; `PopScope(canPop: state is! DeletePlanDeleting)` blocks scrim-tap pop during Deleting
- After the `await showDialog(...)` call in `_onDelete`, guard with `if (!context.mounted) return`; `if (deleted == true)` treats both `false` and `null` (barrier-tap) as Cancel
- `InlineDialogError` lives in `core/widgets/` — shared error pill for SCR-11 (and eventually SCR-09)
- Cross-feature import of `ScheduleLocalDataSource` in `WorkoutPlanRepositoryImpl` goes via the schedule feature barrel (`forge/lib/features/schedule/schedule.dart`), not a direct internal path (constitution I.5)
- Use `Color.withValues(alpha: ...)` not the deprecated `Color.withOpacity(...)` (Dart 3.x) — `withOpacity` will produce an analyzer deprecation warning
- Run `dart format` and `flutter analyze` before marking T021/T022 complete — zero new warnings allowed
