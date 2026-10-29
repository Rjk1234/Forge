# QA Specification — SCR-17: Rest Timer

**Story ID:** US-SCR17  
**Feature:** Rest Timer  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-17-Rest-Timer.md` + constitution

---

## 1. Purpose & Scope

Verify the rest timer overlay on SCR-16: auto-starts immediately when a set is marked complete (no manual start), runs locally without any network call, Skip action ends rest early, and timer reaching zero automatically advances to the next set/exercise on SCR-16 without user confirmation. App-backgrounded timer behaviour is **DEFERRED** — do not assert specific timer behaviour; flag results for product owner. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked; active workout in progress on SCR-16.
- **Trigger:** Mark a set complete that has a configured rest period.
- **Configured rest:** At least one exercise in the plan must have a non-zero rest duration.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Rest timer auto-starts | Mark a set complete (with configured rest). | Timer starts immediately without any additional tap; countdown visible (FR-1 / AC-1). |
| HP-02 | Countdown runs locally | Rest timer running. | No network call occurs; timer progresses using device clock (FR-2 / NFR-1). |
| HP-03 | Skip ends rest early | While timer running, tap Skip. | Timer dismissed immediately; returns to SCR-16 next set/exercise view (FR-3 / FR-4 / AC-2). |
| HP-04 | Timer reaches zero — auto-advance | Let countdown reach zero. | Automatically advances to next set or exercise on SCR-16; no confirmation required (FR-5 / NFR-2 / AC-3). |
| HP-05 | Next-set preview shown during rest | Rest timer running. | Preview of the upcoming exercise/set visible on the timer overlay. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | No rest timer for zero-rest exercise | Mark complete on an exercise with rest = 0. | Rest timer does not appear; proceeds directly to next set. *[QA-derived — not explicitly tested in story]* |
| NV-02 | Rest timer cannot go below zero | Timer reaches zero. | Timer stops at zero; no negative display; auto-advance fires exactly once. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | App backgrounded during rest — DEFERRED | Background app while rest timer is counting. | **Timer behaviour is DEFERRED (Decisions Log §6b).** Record observed behaviour; do not assert pass/fail. Flag for product owner. *[QA-derived — deferred]* |
| EC-02 | App killed during rest (not backgrounded) | Force-kill app while rest timer is running. | On relaunch: no workout record saved; app starts fresh (same as SCR-16 kill behaviour). *[QA-derived]* |
| EC-03 | Very long rest duration | Configure rest = 300 seconds. Verify timer display. | mm:ss display handles values above 60 seconds (e.g., `05:00`). No overflow. *[QA-derived]* |
| EC-04 | Skip after timer expires | Timer reaches zero; auto-advance fires; attempt to tap Skip (now stale). | Skip button not present after auto-advance; no double-advance. *[QA-derived]* |
| EC-05 | Last exercise, last set | Mark complete on the final set of the final exercise. | Rest timer either appears (if rest configured on that set) or skips directly to Finish prompt. Auto-advance leads correctly to workout completion flow. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Timer presented as overlay on SCR-16 | The rest timer is rendered over SCR-16 (inline or overlay), not as a separate navigation route. |
| SN-02 | Skip returns to SCR-16 active view | After Skip, SCR-16 shows the next set/exercise immediately. |
| SN-03 | Cancel during rest period | Tap Cancel from the rest overlay. | Triggers SCR-18 Cancel Confirmation (routes from SCR-16 layer). No partial save. |
| SN-04 | Back during rest period | Android system back during rest. | Confirm expected behaviour (Cancel trigger or no-op). *[QA-derived — flag as OQ-01]* |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Rest timer does not write to Drift | Rest period passing (whether naturally or skipped) does not create any Drift write. |
| DI-02 | Skip does not mark set as incomplete | Skipping rest does not alter the "completed" status of the set that triggered the rest. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Timer accuracy | Rest countdown is accurate to within ±1 second over a 60-second rest. |
| PR-02 | No ANR on timer expiry | Auto-advance at zero fires without causing an ANR. |
| PR-03 | Timer starts without perceptible delay | Rest overlay appears within <500 ms of marking a set complete. *[QA-derived threshold — confirm with SRS/SDS owner]* |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Countdown announced | Screen reader periodically announces remaining time (or announces on significant milestones — exact behaviour TBC). |
| AC-02 | Skip action accessible | Skip button ≥44pt; announced as "Skip Rest" or equivalent. |
| AC-03 | Auto-advance announced | When timer reaches zero and advances, screen reader announces transition to next set. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | No data at rest (timer only) | Rest timer operates purely in memory; no Drift reads or writes during the rest period. |

---

## 11. Regression Flags

- Any change to the timer auto-start logic must re-run HP-01.
- Any change to auto-advance logic must re-run HP-04, NV-02, EC-04.
- Any change to Skip logic must re-run HP-03, DI-02.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **App-backgrounded timer — DEFERRED** (Decisions Log §6b). EC-01 must not be asserted until product owner decides. |
| OQ-02 | **System back during rest** — SN-04 behaviour not specified. Confirm with product owner. |
| OQ-03 | **Last-set rest** — EC-05: if a rest follows the final set, does auto-advance go to a Finish prompt? Confirm. |
| OQ-04 | **Countdown format** — story does not specify mm:ss vs. seconds-only. EC-03 assumes mm:ss. Confirm. |
