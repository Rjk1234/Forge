# ForgeApp (Workout Tracker) — Project Brief
*Compiled from BRD, PRD, Business Discovery Doc, SRS, SDS, Screen Flow/Use Case Inventory, and User Stories — Sep 5, 2026*

## What it is
ForgeApp is a mobile workout tracker (iOS/Android) covering the full lifecycle: **Plan → Schedule → Perform → Record → Review → Progress**. A single fitness-user persona creates workout plans from a predefined exercise catalogue, schedules them to days/weekly recurrence, executes them with work/rest timers, records actual performance, and reviews history, progress trends, statistics, and personal bests. It is deliberately scoped as a simple, focused tracker — not a coaching, social, or health-data platform.

## In scope (MVP)
Exercise catalogue (browse/select) · workout plan management (create/edit/delete, sets/reps/weight/duration/rest) · basic day/weekly scheduling · workout execution (start/pause/skip/cancel/finish, timers, actual-performance recording) · workout history · progress comparison across sessions · statistics and personal bests · data validation (reject invalid/negative values; invalid or incomplete records excluded from stats).

**Core business rule (repeated across all docs):** Workout Plans (intended) and Workout Records (actual) are strictly separate — editing or deleting a plan/schedule must never retroactively change historical records. Training volume = weight × reps.

## Explicitly out of scope
AI-generated workouts/coaching, form analysis or camera-based rep detection, supersets/drop-sets/circuit builders, adaptive/periodized scheduling, Apple Health/Google Health Connect/wearables, nutrition or body-measurement tracking, social features (friends/challenges/leaderboards), voice coaching, music integration, lock-screen/background execution, exercise video coaching.

## ⚠️ Critical open conflict: local-only vs. cloud architecture
The source documents describe **two incompatible architectures** and do not agree on which is current:
- **BRD, PRD, and Business Discovery Doc** (the most recent set) specify a **fully offline app with local-only storage (Drift)**, a single local login gate, no accounts, and no cloud backend — explicitly ruling out Firebase/Firestore, sign-up, password reset, and cross-device sync. The BRD notes this is a **v2.0 reversal of a prior v1.0 Firebase/Firestore baseline**, with v1.0 content kept but marked DEPRECATED.
- **SDS (marked "LOCKED"), the Screen Flow/Use Case Inventory, and the User Stories** still fully specify a **Firebase Authentication + Cloud Firestore, online-first** architecture — registration, login, forgot-password/reset-email flows, per-user cloud data under `users/{uid}`, and no offline persistence at all.

These documents have not been reconciled. This must be resolved with the product/architecture owner before further design or build work, since it determines the data layer, auth flow, and roughly a third of the specified screens (all of SCR-01–05 auth/registration/reset).

## Other open questions and unresolved decisions
- **Workout completion criteria** — what counts as "completed" (all exercises done? one? explicit Finish tap only?) — undefined (PD-001).
- **Incomplete/cancelled workouts** — whether they're saved, shown in history, resumable, or discarded, and whether "Save as Incomplete" vs. "Discard" exists (PD-002, PD-012).
- **Personal Best definition** — which metric(s) qualify (heaviest weight, highest reps, highest volume, longest duration) (PD-004).
- **Scheduling recurrence rules** — exact meaning of "simple recurring schedule," and whether multiple plans can be scheduled on the same day (PD-005, PD-006).
- **Bodyweight/zero-weight exercises** — whether 0 kg is valid and how such performance is recorded (PD-008, PD-009); duration units (sec/min/hr) not decided (PD-010).
- **Timer behavior** — auto-start vs. manual, skippable, behavior when app is backgrounded (PD-007).
- **Exercise catalogue ownership** — who curates/maintains the predefined list; whether user-created exercises are ever allowed (PD-011).
- **Profile/Account screen (SCR-25)** — flagged as an unapproved **assumption**: the data model implies richer profile fields (name, DOB, height, weight, goals) that no requirement actually defines a screen for, and registration doesn't collect them. Recommendation on file: build read-only (email + logout) until confirmed.
- **Offline/error-state behavior (SCR-27)** — explicitly unresolved: whether writes are blocked or queued-with-warning when connectivity/session issues occur.
- **Local login recovery** — no credential-recovery flow is defined for the local-login model; a lockout could permanently block device access (flagged as a High risk).
- **Registration flow (Forge-US-2)** — intentionally left out of the User Stories as not yet fully specified.
- **Regulatory/privacy scope** — applicable data-protection requirements are acknowledged as jurisdiction-specific but not enumerated in any document.

## Recommended next step
Resolve the local-only vs. cloud architecture conflict at the product/architecture level first — it gates almost every other open item above (auth-dependent screens, offline behavior, data model) — then work through the remaining product-decision list (PD-001–012) before continuing detailed design or build.
