# Product Context

## 1. Product

**ForgeApp**

ForgeApp is a fully offline, single-user mobile workout tracker built as a POC/MVP assignment
(Flutter, Android and iOS). It lets one local user create and schedule workout plans, execute
workouts with a rest timer, and review history, progress comparisons, and statistics — all backed
by on-device Drift storage with no backend, no network calls, and no multi-user concept.

---

## 2. Product Vision

Demonstrate a clean, well-scoped mobile workout-tracking experience end to end — from plan
creation through active logging to historical insight — without the complexity of a backend,
authentication infrastructure, or cloud sync that a POC does not need.

---

## 3. Target Users

A single local user per device install. There are no roles, no multi-account concept, and no
administrative or operator users (SDS §2.3 Assumptions).

---

## 4. Core Business Capabilities

### Access

- Static local login (hardcoded demo credential, no registration, no password reset)
- App lock / unlock state

### Workout Planning

- Browse and select from a seeded, read-only exercise catalogue
- Create, edit, and delete workout plans
- Per-exercise target fields gated by exercise type (weighted / time-based / bodyweight)

### Scheduling

- View a weekly workout schedule
- Assign/edit a plan's schedule (one plan per weekday maximum)
- Remove a plan from the schedule

### Workout Execution

- Pre-start overview before beginning a workout
- Active workout: set-by-set logging, rest timer (auto-starts, skippable)
- Cancel workout confirmation (always discards fully — no "incomplete" state)
- Workout summary on completion

### History, Progress & Statistics

- Workout history list and detail view
- Progress comparison (single-series line chart)
- Statistics dashboard (totals, exercise breakdown)
- Personal bests (metric definition explicitly deferred — see Decisions Log §3)

### Profile

- Editable profile: display name, fitness goal, experience level, height & weight (informational
  only, no calculations)
- Logout (re-locks the app; does not clear local data)

---

## 5. Business Objectives

- Demonstrate a complete, coherent mobile app experience across planning, execution, and
  historical review within a single offline device
- Keep the implementation "enough, not too much" — a scoped POC/MVP, not a production system

---

## 6. Key Workflows

### Plan → Schedule → Execute

Create Plan → Assign to Schedule → Pre-Start Overview → Active Workout (log sets, rest timer) →
Finish → Workout Summary → (visible in History, Progress, Statistics)

### Review

History List → History Detail
Progress Comparison (exercise-over-time)
Statistics Dashboard → Personal Bests (structural shell; metric TBD)

---

## 7. Platform Characteristics

- Android and iOS, phone only (no tablet/iPad — see `ADRs/ADR-022_Responsive_Architecture.md`)
- Fully offline — no network calls, no backend, no Firebase
- Single language (English) — localization deferred (`ADRs/ADR-016_Localization.md`)
- Single dark theme — no theme switching (`ADRs/ADR-037_Theme_Architecture.md`)

---

## 8. Success Metrics

This is a POC/MVP assignment, not a production product with live usage metrics. Success is
measured by functional completeness against the User Stories (`Doc/UserStories/`) and the SDS
(`Doc/SDS_v2.0.md`), not by operational KPIs.

---

## 9. Non-Goals

ForgeApp does not include, and is not expected to include:

- Any backend, cloud sync, or multi-device access
- Multi-user accounts, roles, or permissions
- Push notifications, QR scanning, GPS/location tracking, or camera/media capture
- Social features, sharing, or community functionality
- Analytics, crash reporting, or remote monitoring (deferred — see the relevant ADR stubs)

---

## 10. Product Principles

- Fully offline, single-user, single-device
- "Enough, not too much" — POC/MVP scope; no speculative feature-building
- Every open product decision (e.g. the Personal Best metric) is visibly flagged as open, never
  silently defaulted
- Consistent visual language across all screens, governed by `Doc/DESIGN-SYSTEM.md`
