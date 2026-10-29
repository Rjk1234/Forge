# QA Specification — LOCALDB-01: Local Data Persistence

**Story ID:** US-LOCALDB01  
**Feature:** Local Data Persistence (Drift)  
**QA Spec Version:** 1.0  
**Date:** 2026-09-13  
**Source:** `Doc/UserStories/LOCALDB-01-Local-Data-Persistence.md` + constitution

---

## 1. Purpose & Scope

Verify the Drift-based persistence layer as a cross-cutting invariant: the Drift (SQLite) database is the sole source of truth, stores workout plans and completed workout records (not incomplete), persistence survives app restarts, plan edits/deletes do not affect history, and the completion criterion (≥1 set of ≥1 exercise + explicit Finish tap) is enforced. This spec is a cross-cutting integration baseline — individual screen specs cover surface-level behaviour; this spec verifies the underlying persistence contract. No network calls; no backend.

---

## 2. Test Environment & Preconditions

- **Platform:** Android 10 (API 29) + iOS 15.
- **Auth:** App unlocked.
- **Method:** Use test utilities or integration tests to inspect Drift table contents directly (e.g. `AppDatabase` queries against `forge.sqlite`) where possible. Behavioural proxies (SCR-20 history count, SCR-08 plan list) are acceptable when direct inspection is unavailable.

---

## 3. Happy-Path Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| HP-01 | Workout plan persists across restart | Create a plan; force-close and relaunch app. | Plan visible in SCR-08; `workout_plans` rows intact. |
| HP-02 | Completed workout persists across restart | Complete a workout (SCR-19 success); force-close and relaunch. | Record visible in SCR-20; `workout_sessions` rows intact. |
| HP-03 | Multiple plans stored independently | Create 3 plans. | All 3 appear in SCR-08; Drift stores each in its own row. |
| HP-04 | Multiple completed workouts stored | Complete 5 workouts. | All 5 appear in SCR-20; Drift stores each in its own row. |
| HP-05 | Completed workout record schema complete | Complete a workout. | Stored record contains: date, time, duration, per-exercise sets, reps, weight/duration as applicable. |

---

## 4. Negative / Validation Test Cases

| ID | Scenario | Steps | Expected |
|----|----------|-------|----------|
| NV-01 | Cancelled workout — no database record | Start and cancel a workout (confirm on SCR-18). | No new row in `workout_sessions`. |
| NV-02 | Zero-sets Finish — no database record | Start workout; skip all sets; tap Finish. | No new row in `workout_sessions` (zero-sets Finish = Cancel — Decisions Log §2). |
| NV-03 | App kill mid-workout — no database record | Force-kill app during active workout. | No partial or complete row in `workout_sessions`, `session_exercises` or `actual_sets`. |
| NV-04 | Incomplete record never exists | After any non-completing scenario. | No "in-progress" or "incomplete" record type in the database at any time. |
| NV-05 | One plan per day max | Assign two different plans to the same weekday. | Second assignment blocked; `schedule_entries` (primary key = weekday) holds only one plan per day (Decisions Log §4). |

---

## 5. Edge Cases (QA-Derived)

| ID | Scenario | Rationale | Expected |
|----|----------|-----------|----------|
| EC-01 | Plan edit does not mutate history | Complete a workout for Plan A; edit Plan A (change an exercise target); check history. | SCR-21 detail for the pre-edit workout shows original values. *[QA-derived]* |
| EC-02 | Plan deletion does not cascade to history | Complete a workout for Plan A; delete Plan A (SCR-11). | `workout_sessions` row for that workout is still present; SCR-20 count unchanged; SCR-21 accessible. *[QA-derived]* |
| EC-03 | Completion criterion enforced | Log exactly 1 set; tap Finish. | `workout_sessions` row written (≥1 set satisfied — Decisions Log §1). *[QA-derived]* |
| EC-04 | Multiple restarts | Restart app 5 times consecutively. | All plans and history records still intact; no corruption. *[QA-derived]* |
| EC-05 | Large data volume | 20 plans, 50 completed workout records. | All data persists; no truncation; performance acceptable. *[QA-derived]* |
| EC-06 | Database opened before write | Boot sequence: `AppDatabase` opened before any UI write. | No "database not open" error on first write after cold start. *[QA-derived — relates to ADR-030 boot order]* |
| EC-07 | Schedule deletion removes only the entry | Remove one day's schedule entry (SCR-14). | Only that weekday's entry removed; other days' entries intact. *[QA-derived]* |

---

## 6. State & Navigation Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SN-01 | Data survives OS-triggered restart | OS terminates app (not user kill); relaunch. | All plans and history intact. |
| SN-02 | Database is not queried before opened | No access to `AppDatabase` before it is opened in the boot sequence. | No crash on first data access. |

---

## 7. Data Integrity Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| DI-01 | Plan tables and history tables are independent | Deleting a plan does not remove any history record. |
| DI-02 | History records are immutable snapshots | Stored record values match what was logged at write-time, regardless of subsequent plan or exercise changes. |
| DI-03 | Schedule table independent of history | Removing a schedule entry (SCR-14) does not touch history or plan tables. |
| DI-04 | Exactly one record per completed workout | Retrying a failed Finish write results in exactly one record (idempotent). |
| DI-05 | No network write ever occurs | Monitor network traffic during all database operations. | Zero outbound requests of any kind. |

---

## 8. Performance & Reliability Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| PR-01 | Database write for workout record < 1 s | Completed workout write completes in under 1 second in normal operation. *[QA-derived threshold]* |
| PR-02 | Large history read < 2 s | Reading 50 history records for SCR-20 loads in under 2 seconds on API 29. *[QA-derived threshold]* |
| PR-03 | No data loss under rapid write/read | Write a plan immediately followed by a read. | Read returns the just-written plan without loss. |

---

## 9. Accessibility Test Cases

*(This story is a data-layer story; no direct accessibility tests. Accessibility is verified at the screen level in per-screen specs.)*

| ID | Check | Expected |
|----|-------|----------|
| AC-01 | N/A — persistence layer | Accessibility verified per-screen. This entry is a placeholder. |

---

## 10. Security Test Cases

| ID | Scenario | Expected |
|----|----------|----------|
| SC-01 | Data stored locally only | No database content transmitted over any channel. DI-05 confirms. |
| SC-02 | No backend calls | Zero outbound HTTP/WS/gRPC calls during any CRUD operation. |

---

## 11. Regression Flags

- Any change to the Drift schema (tables, columns, `schemaVersion`) must re-run HP-05, DI-02, DI-04.
- Any change to cancel/discard logic must re-run NV-01–NV-03, DI-04.
- Any change to plan-delete cascade logic must re-run EC-02, DI-01.
- Any addition of a new data entity to the database must add it to HP-01–HP-04 equivalents and DI-05.

---

## 12. Coverage Gaps & Open Questions

| ID | Item |
|----|------|
| OQ-01 | **Table inventory** — the story does not enumerate the database tables by name. Tests reference logical groups (plans, history, schedule, profile). The authoritative list is ADR-008 (`user_profiles`, `exercises`, `workout_plans`, `plan_exercises`, `schedule_entries`, `workout_sessions`, `session_exercises`, `actual_sets`); confirm with engineering before writing integration tests. |
| OQ-02 | **Database encryption** — the story does not mention whether `forge.sqlite` is encrypted at rest. If sensitive profile data is stored, encryption should be assessed. Confirm with product owner. |
| OQ-03 | **Write failure atomicity** — DI-04 assumes idempotent retry; note that multi-table writes run in a single Drift transaction, so a failed write rolls back and leaves no partial record; confirm retry behaviour. |
| OQ-04 | **App-backgrounded timer state** — DEFERRED (Decisions Log §6b). Whether the in-memory workout session survives backgrounding without a write is not specified; do not assert a database write on background. |
