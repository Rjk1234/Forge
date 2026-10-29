# QA Specification — SCR-18: Cancel Active Workout Confirmation

**Story ID:** US-SCR18  
**Feature:** Cancel Active Workout Confirmation  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/SCR-18-Cancel-Active-Workout-Confirmation.md` + constitution

---

## 1. Purpose & Scope

Verify the cancel-workout confirmation modal: shown when Cancel is tapped on SCR-16, warns that progress will not be saved, confirms discard and routes to SCR-06, and allows return to active workout if not confirmed. Full discard on confirmation — no partial save, no "Incomplete" record, no Drift write. No network calls.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked; active workout in progress on SCR-16 with at least one set logged.
- **Entry:** From SCR-16, tap Cancel.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Confirmation modal shown on Cancel | Tap Cancel during active workout. | Confirmation modal appears warning that progress won't be saved as a completed workout (FR-1 / AC-1). |
| HP-02 | Confirm cancellation — discard and route to SCR-06 | In modal, tap Confirm (or "Discard Workout"). | Session discarded; not persisted to Drift; app navigates to SCR-06 Home Dashboard (FR-2 / FR-3 / AC-2). |
| HP-03 | Return to workout if not confirmed | In modal, tap Cancel/Keep Going. | Modal dismissed; returns to SCR-16 with session state intact; all logged sets preserved in memory. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Discard with sets logged | Log 5 sets across 2 exercises; tap Cancel; confirm discard. | All 5 sets discarded; no stored record; SCR-20 history unchanged. |
| NV-02 | Discard with zero sets logged | Start workout, log nothing; tap Cancel; confirm. | Same discard outcome; no stored record. |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Tap scrim behind modal | Tap outside the modal. | Either dismisses modal (returns to SCR-16 with session intact) or no-op. Confirm behaviour. *[QA-derived]* |
| EC-02 | Android system back on the modal | Press system back on the cancel confirmation. | Returns to SCR-16 (modal dismissed, session intact) — not to SCR-06. *[QA-derived]* |
| EC-03 | Rapid double-tap Confirm | Tap Confirm twice quickly. | Discard executes once; only one navigation to SCR-06; no duplicate events. *[QA-derived]* |
| EC-04 | Cancel during rest period (SCR-17 visible) | Rest timer is running; tap Cancel from the rest overlay. | SCR-18 modal appears; confirming discard still routes to SCR-06 with no stored record. *[QA-derived]* |
| EC-05 | Cancel after Pause | Pause the workout; then tap Cancel. | SCR-18 modal appears normally; confirming discard clears session. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Modal presented over dimmed SCR-16 | SCR-16 visible but dimmed behind the confirmation modal. |
| SN-02 | After confirmed discard, back from SCR-06 | Back from SCR-06 does not return to SCR-16 or SCR-18. Workout session is fully gone. |
| SN-03 | Keep Going restores SCR-16 state | Timer state (ACTIVE or PAUSED), current exercise/set position, all logged sets — all intact after choosing Keep Going. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | No Drift write on discard | After confirming discard, verify Drift contains no new workout record (use test utility to inspect the tables). |
| DI-02 | History unchanged after discard | SCR-20 history list is identical before and after a cancelled workout. |
| DI-03 | Previously persisted records unaffected | Existing completed workout records in Drift are not touched by the discard operation. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Instant discard — no Drift write delay | Confirm button responds immediately; no loading spinner (no write required for discard). Navigation to SCR-06 fires instantly. |
| PR-02 | Keep Going is instant | Choosing Keep Going closes modal and restores SCR-16 without perceptible delay. |

---

## 9. Accessibility Test Cases

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | Modal content announced | Screen reader announces the warning that progress will not be saved. |
| AC-02 | Confirm (Discard Workout) is danger-styled | Danger red colour; screen reader can distinguish it from the secondary Keep Going action. |
| AC-03 | Both actions ≥44pt | Confirm and Keep Going (or Cancel) meet minimum touch target. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Confirm discard writes nothing | Verified by DI-01; no leftover in-progress data in Drift. |

---

## 11. Regression Flags

- Any change to cancel/discard flow must re-run HP-02, NV-01, NV-02, DI-01–DI-03.
- Any change to Keep Going / resume logic must re-run HP-03, SN-03.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Exact modal copy** — not specified; tests verify content addresses "progress not saved" but cannot assert exact strings. |
| OQ-02 | **Scrim dismiss** — EC-01 behaviour not specified; confirm with product owner. |
| OQ-03 | **System back on modal** — EC-02 is QA-derived; confirm system back intent on SCR-18. |
