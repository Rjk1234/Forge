# QA Specification — SCR-19: Workout Summary / Completion

**Story ID:** US-SCR19  
**Feature:** Workout Summary / Completion  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-19-Workout-Summary-Completion.md` + constitution

---

## 1. Purpose & Scope

Verify the post-workout summary screen: Finish-tap triggers a loading state while the workout record is written to Drift, a successful write renders the full summary (date/time/duration/sets/reps/weight), and a write failure surfaces the SCR-27 Write-Error template with the err-note. No "Incomplete" record is ever saved. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry:** From SCR-16 (Active Workout) — user tapped Finish with ≥1 set logged.
- **Data states:** (a) Drift write succeeds → summary. (b) Drift write fails → error state.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Loading state shown on Finish | Tap Finish on SCR-16 with ≥1 set logged. | Loading indicator shown immediately before Drift write completes (FR-1 / AC-1). |
| HP-02 | Full summary rendered after successful write | Drift write succeeds. | Summary screen shows: date, time, total duration, sets logged, reps logged, and weight lifted (FR-2 / AC-2). |
| HP-03 | Summary includes all exercises | Workout had multiple exercise types. | Per-exercise breakdown (or overall totals) reflects all logged sets, including weighted, time-based, and bodyweight. |
| HP-04 | Navigate away from summary | Tap the "Done" / home action on SCR-19. | Routes to SCR-06 or appropriate home destination. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Drift write failure — error state | Force Drift write failure on Finish. | Error state shown using SCR-27 Write-Error template; err-note "Nothing was recorded — retrying won't create a duplicate." visible (FR-3). |
| NV-02 | Retry after write failure — success | Trigger NV-01; restore Drift; tap Retry. | Write succeeds; summary rendered correctly. |
| NV-03 | Retry after write failure — still fails | Trigger NV-01; tap Retry with Drift still failing. | Error state re-shown; no crash; no partial record in Drift. |
| NV-04 | No "Incomplete" record created | After Drift write failure, check Drift. | No partial or incomplete workout record exists in Drift. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Workout with exactly 1 set | Minimum completion criterion (Decisions Log §1). | Summary displays correctly with a single set. *[QA-derived]* |
| EC-02 | Workout with skipped sets | Some sets were marked skipped on SCR-16. | Summary reflects only the logged (non-skipped) data; skipped sets not counted toward totals. *[QA-derived]* |
| EC-03 | Back from SCR-19 | Press back from the summary screen. | Does not return to SCR-16 Active Workout. Navigate to SCR-06 or entry point. *[QA-derived]* |
| EC-04 | Rapid double-tap Retry on write failure | Tap Retry twice quickly. | Write attempted once; no duplicate record on success. *[QA-derived]* |
| EC-05 | Summary data matches history entry | After viewing summary, navigate to SCR-20/SCR-21. | Values in SCR-21 history detail match those shown on SCR-19. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Back from SCR-19 does not re-enter SCR-16 | After summary is shown, back gesture/button does not re-enter the active workout. |
| SN-02 | Error state does not navigate away | While in write-error state, the screen remains on SCR-19; no automatic navigation. |
| SN-03 | History reflects new record | After successful summary, navigate to SCR-20. New workout appears at top of history list. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Exactly one record written per completed workout | After one Finish, Drift contains exactly one new workout record. |
| DI-02 | Retry is idempotent | Retrying after write failure (if first attempt partially succeeded) results in exactly one final record. |
| DI-03 | Summary values are accurate | Date, time, duration, sets, reps, weight on SCR-19 match what was actually logged on SCR-16. |
| DI-04 | Previous history records unaffected | Writing a new summary does not alter existing completed workout records. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Loading state visible | Loading state shown between Finish tap and write result. No blank screen. |
| PR-02 | Write completes in reasonable time | Drift write for a completed workout record completes without user-perceptible indefinite hang. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Summary fields announced | Screen reader announces date, time, duration, sets, reps, weight. |
| AC-02 | err-note accessible on failure | "Nothing was recorded — retrying won't create a duplicate." read by screen reader. |
| AC-03 | Retry button accessible | ≥44pt; announced as "Retry". |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | No incomplete record on write failure | NV-04 confirms no partial data persisted. |

---

## 11. Regression Flags

- Any change to the Finish-write flow must re-run HP-01–HP-02, NV-01–NV-04, DI-01–DI-02.
- Any change to Write-Error template must re-run NV-01, AC-02.
- Any change to back-stack routing must re-run SN-01, EC-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Summary layout not fully specified** — tests verify all named fields are present but cannot assert exact layout or ordering. |
| OQ-02 | **Bodyweight-only workout totals** — EC-02 notes skipped sets; whether bodyweight exercises show a weight column in summary is not specified. |
| OQ-03 | **Post-summary navigation destination** — HP-04 assumes SCR-06 as destination but story does not specify; confirm with product owner. |
