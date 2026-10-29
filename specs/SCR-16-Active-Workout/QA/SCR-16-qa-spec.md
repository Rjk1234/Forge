# QA Specification — SCR-16: Active Workout — Exercise & Set Logging

**Story ID:** US-SCR16  
**Feature:** Active Workout — Exercise & Set Logging  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-16-Active-Workout.md` + constitution

---

## 1. Purpose & Scope

Verify the core workout execution screen: ACTIVE state on entry, inline validation for reps/weight/duration, set completion and exercise progression, skip/pause, Cancel routing to SCR-18 with full discard on confirmation, and Finish/Done routing to SCR-19 (only if ≥1 set logged). Zero-sets Finish = same as Cancel = full discard. App kill/crash = discard. App-backgrounded timer behaviour is **DEFERRED** — do not test a specific timer behaviour; flag as TBD. No network calls; all state is in-memory during session.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Entry:** From SCR-15 "Begin Workout" tap.
- **Plan:** At least one exercise of each type (`weighted`, `time-based`, `bodyweight`) in the plan being worked out.
- **Precondition:** No in-memory state from a previous incomplete session (app freshly navigated to this screen).

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | ACTIVE state on entry | Tap "Begin Workout" on SCR-15. | First exercise/set displayed; execution state is ACTIVE (FR-1 / AC-1). |
| HP-02 | Complete a set with valid values — weighted | Enter valid reps and weight for a weighted exercise. Mark complete. | Progress advances to next set or exercise (FR-5 / AC-2). |
| HP-03 | Complete a set — time-based | Enter valid duration. Mark complete. | Progress advances. |
| HP-04 | Complete a set — bodyweight | Enter valid reps. Mark complete. | Progress advances. No weight field present. |
| HP-05 | Skip applicable item | Tap Skip on an exercise/set. | Item marked as skipped; excluded from valid-set count but progress moves forward (FR-6 / AC-3). |
| HP-06 | Pause applicable activity | Tap Pause. | Execution state becomes PAUSED; timer state held locally (FR-7 / NFR-1 / AC-4). |
| HP-07 | Resume from PAUSED | Tap Resume. | Execution state returns to ACTIVE; timer resumes. |
| HP-08 | Finish with ≥1 set logged — navigate to SCR-19 | Log at least 1 set, then tap Finish. | Finish loading state shown; on Drift write success, navigates to SCR-19 with the workout summary (FR-9 / AC-6). |
| HP-09 | Overall progress tracking | Work through multiple exercises. | Progress indicator (set dots, exercise progress bar) reflects current position accurately. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Zero reps — block completion (EC-1) | Enter `0` for reps on a weighted/bodyweight exercise. Tap Mark Complete. | Inline validation error; set not completed (FR-2 / EC-1). |
| NV-02 | Negative reps (EC-1) | Enter `-1` for reps. Tap Mark Complete. | Inline validation error; set not completed. |
| NV-03 | Negative weight (EC-2) | Enter `-5` for weight. | Inline validation error shown (FR-3 / EC-2). |
| NV-04 | Negative duration (EC-3) | Enter `-1` for duration on a time-based exercise. | Inline validation error shown (FR-4 / EC-3). |
| NV-05 | Zero sets logged + Finish — discard (AC-6a) | Skip all sets (or don't log any). Tap Finish. | Treated as Cancel: full discard, no Drift write, no SCR-19 navigation, returns to SCR-06. |
| NV-06 | Weight field not shown for bodyweight exercise | Active workout shows bodyweight exercise. | No weight field rendered. |
| NV-07 | Duration field not shown for weighted exercise | Active workout shows weighted exercise. | No duration field rendered. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | App killed mid-workout (EC-4) | Force-kill the app during an active workout. | On relaunch, no partial/incomplete workout record in Drift. SCR-20 history unchanged (FR-9 / NFR-2 / EC-4). *[QA-derived]* |
| EC-02 | App backgrounded mid-workout (EC-4a) — DEFERRED | Background the app. | **Timer behaviour is DEFERRED (Decisions Log §6b).** Do not assert any specific timer behaviour. Flag the result for product owner review. *[QA-derived — deferred]* |
| EC-03 | Cancel mid-workout — full discard | Log several sets, then tap Cancel → confirm on SCR-18. | No Drift record written. SCR-20 history unchanged (FR-8 / AC-5). |
| EC-04 | Rapid double-tap "Mark Complete" | Tap Mark Complete twice quickly. | Set counted only once; no duplicate entry in in-memory state. *[QA-derived]* |
| EC-05 | All exercises skipped | Skip every set of every exercise. | Zero sets logged; Finish treated as Cancel (AC-6a). History unchanged. *[QA-derived]* |
| EC-06 | Finish write failure | Log sets; tap Finish; force Drift write failure. | Write-error state shown (NFR-2); session preserved in memory for retry; no navigation to SCR-19 until write succeeds. Uses SCR-27 Write-Error template with err-note. *[QA-derived — Finish write failure path]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Cancel routes to SCR-18 | Tap Cancel. | Opens SCR-18 Cancel Confirmation. |
| SN-02 | Cancel confirm — returns to SCR-06 | Confirm cancel on SCR-18. | Returns to SCR-06 Home Dashboard; nothing written to Drift. |
| SN-03 | Cancel denied — returns to SCR-16 | Deny cancel on SCR-18. | Returns to SCR-16 with session state intact. |
| SN-04 | Finish → SCR-19 back-stack | After successful Finish, back from SCR-19 does not return to SCR-16. |
| SN-05 | System back during ACTIVE | Android system back triggers Cancel flow (routes to SCR-18). *[QA-derived — confirm intent]* |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Nothing written until Finish confirmed | At any point before Finish is tapped and its Drift write succeeds, no workout record exists in Drift. |
| DI-02 | Skipped sets reflected in summary | Skipped sets marked as skipped in the in-memory record that gets written at Finish. |
| DI-03 | Valid sets only counted toward completion | A skipped set does not count toward the ≥1 set completion criterion (AC-6). |
| DI-04 | Finish write: idempotent retry | If Finish write fails and is retried, only one workout record is created (no duplicate). |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Finish loading state visible | After tapping Finish, loading state shown until Drift write completes. |
| PR-02 | Rest timer auto-starts after set complete | After marking a set complete, rest timer (SCR-17) begins without a manual tap. |
| PR-03 | No ANR during logging | Rapid set completions across multiple exercises do not produce ANR on API 29. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Current exercise announced | Screen reader announces current exercise name, type, and set number. |
| AC-02 | Validation errors announced | Inline errors for reps/weight/duration announced. |
| AC-03 | PAUSED state announced | State change to PAUSED announced to screen reader. |
| AC-04 | Skip and Cancel accessible | Both ≥44pt tap targets; clearly labelled. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | No data persisted on kill/crash | Force-kill the app; verify Drift contains no partial record for this session (EC-01). |

---

## 11. Regression Flags

- Any change to the completion criterion (≥1 set) must re-run HP-08, NV-05, EC-05, DI-03.
- Any change to cancel/discard logic must re-run EC-03, SN-01–SN-03, DI-01.
- Any change to validation rules must re-run NV-01–NV-04.
- App kill/crash recovery must re-run EC-01 after any state-persistence change.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **App-backgrounded timer behaviour — DEFERRED** (Decisions Log §6b). EC-02 is flagged; do not assert a specific behaviour until product owner decides. |
| OQ-02 | **Which items are Skip-able / Pause-able** — "applicable" is not defined in Inventory. NV-07 and HP-05–HP-07 must be scoped to what engineering implements; confirm before test. |
| OQ-03 | **System back intent** — SN-05 is QA-derived. Confirm whether Android back triggers Cancel flow or another behaviour. |
| OQ-04 | **Finish write failure UI** — EC-06 uses the SCR-27 Write-Error template; confirm that SCR-16 displays this template (not a custom error). |
