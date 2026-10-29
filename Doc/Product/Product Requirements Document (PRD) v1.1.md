# **Product Requirements Document (PRD)**

# **Forge-Workout Tracker**

**Product / Application:** Workout Tracker  
**Domain:** Health & Fitness  
**Application Type:** Mobile Application  
**Target Platforms:** iOS and Android  
**Target Market:** Global  
**Document Type:** Product Requirements Document  
**Version:** 1.1  
**Status:** Draft  
**Derived From:** Workout Tracker BRD v2.1  
**BRD Baseline:** Pending stakeholder approval

---

## **Revision History**

| Version | Date | Change |
| ----- | ----- | ----- |
| 1.0 | — | Initial draft, Open Product Decisions PD-001–PD-012 unresolved. |
| 1.1 | 2026-09-05 | Product-owner clarification session (2026-09-05): resolved PD-001, PD-002/PD-012, PD-005/PD-006, PD-007 (partial — background-timer behavior remains deferred), PD-008/PD-009, PD-010, PD-011. Added Profile/Account screen as approved, editable in-scope feature. PD-004 (Personal Best definition) and the app-backgrounded timer behavior remain explicitly **DEFERRED** pending a future brainstorming session. See updated Open Product Decisions (§47) for full detail. |
| 1.1.1 | 2026-09-05 | Traceability-correction pass: updated Derived From to BRD v2.1; corrected all inline BRD citations from the deprecated "BR-FR-0NN" format to the current "BRD-FR-N" format and verified IDs against BRD v2.1; rebuilt §45 Requirement Traceability against the actual BRD v2.1 (77 functional requirements, BO-01–BO-11), replacing stale placeholder content; added missing BO-11/BRD-FR-72–77 traceability. |

---

# **1\. Document Purpose**

## **1.1 Purpose**

This Product Requirements Document defines the product behavior and functional requirements for the **Workout Tracker** mobile application.

The PRD translates the approved business objectives and high-level business requirements from the BRD into detailed product requirements that can be used by:

* Product Management  
* Business Analysis  
* UX/UI Design  
* Engineering  
* QA  
* Technical Architecture  
* Development Planning

The product shall support the core lifecycle:

> **Plan → Schedule → Perform → Record → Review → Progress**

The BRD establishes workout planning, basic scheduling, execution, recording, history, progress, statistics, and personal-best tracking as the core MVP capabilities.

---

# **2\. Product Overview**

## **2.1 Product Vision**

Workout Tracker is a focused mobile application that enables individuals to:

1. Create workout plans.  
2. Organize workouts on simple schedules.  
3. Perform planned workouts.  
4. Record actual performance.  
5. Review previous workouts.  
6. Understand performance changes over time.

The product is intentionally **not** designed to be a comprehensive health, coaching, nutrition, social, or wearable ecosystem.

---

# **3\. Product Goals**

The product shall:

| ID | Goal |
| ----- | ----- |
| PG-001 | Make workout planning simple |
| PG-002 | Make basic workout scheduling predictable |
| PG-003 | Make workout execution easy to follow |
| PG-004 | Minimize interaction required while exercising |
| PG-005 | Make performance recording structured and reliable |
| PG-006 | Preserve workout history |
| PG-007 | Make progress understandable |
| PG-008 | Provide reliable basic statistics |
| PG-009 | Identify meaningful personal-best performance |
| PG-010 | Maintain a tightly controlled MVP scope |

These goals directly support the BRD objectives around planning, scheduling, execution, recording, history, progress, and measurement.

---

# **4\. Product Scope**

## **4.1 MVP In Scope**

### **Exercise Management**

* Predefined exercise catalogue  
* Exercise browsing  
* Exercise selection  
* Exercise metadata required for workout configuration

### **Workout Plans**

* Create  
* View  
* Edit  
* Delete  
* Add exercises  
* Remove exercises  
* Reorder exercises  
* Configure targets  
* Configure rest

### **Scheduling**

* Assign workout to days  
* Weekly recurring schedules  
* View scheduled workouts  
* Modify schedules  
* Remove schedules

### **Workout Execution**

* Start workout  
* Follow exercises  
* Record sets  
* Record repetitions  
* Record weight  
* Record duration  
* Rest timer  
* Work timer where applicable  
* Pause  
* Resume  
* Skip  
* Finish  
* Cancel

### **Workout Records**

* Save completed workouts  
* Store actual performance  
* Store date/time  
* Show workout summary

### **History**

* View completed workouts  
* Open workout details

### **Progress**

* Compare performance  
* Weight progression  
* Rep progression  
* Training volume  
* Duration

### **Statistics**

* Completed workouts  
* Training volume  
* Workout duration  
* Exercise statistics  
* Personal bests (structural view; exact PB metric definition deferred — see PD-004, §47)

### **Profile / Account**

* View/edit display name  
* View/edit fitness goal  
* View/edit experience level (informational only)  
* View/edit height & weight (informational only, no calculations)  
* Logout

Approved 2026-09-05 as confirmed in-scope, editable functionality (§10.3).

The scope follows the BRD's explicit functional requirements BRD-FR-1 through BRD-FR-77. Profile/Account scope specifically derives from BO-11 and BRD-FR-72 through BRD-FR-75.

---

# **5\. Explicitly Out of Scope**

The following are **not MVP requirements**:

* AI workout generation  
* AI coaching  
* Automatic progressive overload  
* AI form analysis  
* Camera-based rep detection  
* Supersets  
* Drop sets  
* Giant sets  
* Advanced circuit builders  
* Advanced periodization  
* Adaptive scheduling  
* Recovery-based scheduling  
* Schedule optimization  
* Automatic missed-workout rescheduling  
* Apple Health  
* Google Health Connect  
* Wearables  
* Heart-rate tracking  
* Sleep tracking  
* Nutrition  
* Calorie tracking  
* Body measurements  
* Social features  
* Friends  
* Challenges  
* Leaderboards  
* Workout sharing  
* Cloud backup  
* Multi-device synchronization  
* Social login  
* Voice coaching  
* Music integration  
* Lock-screen workout controls  
* Background workout execution  
* Exercise video coaching

These exclusions are explicitly established by the BRD and are important product boundaries.

---

# **6\. Target User**

## **6.1 Primary User**

The MVP has one primary user type:

> **Individual fitness user**

The user can:

* Manage exercises  
* Create workout plans  
* Schedule workouts  
* Perform workouts  
* Record performance  
* Review history  
* View progress  
* View statistics

There are no administrative or social user roles defined for the MVP.

---

# **7\. Core Product Concepts**

The following concepts form the foundation of the product.

## **7.1 Exercise**

A predefined physical activity available in the exercise catalogue.

Examples:

* Bench Press  
* Squat  
* Deadlift  
* Push-up  
* Running  
* Plank

---

## **7.2 Workout Plan**

A reusable definition of a planned workout.

Example:

**Push Day**

Bench Press  
  Target: 3 sets × 8 reps × 60 kg

Incline Dumbbell Press  
  Target: 3 sets × 10 reps × 20 kg

Shoulder Press  
  Target: 3 sets × 10 reps × 15 kg

A workout plan represents **intended performance**, not actual performance.

---

## **7.3 Workout Schedule**

A relationship between a workout plan and one or more days.

Example:

Monday     → Push  
Tuesday    → Rest  
Wednesday  → Pull  
Thursday   → Rest  
Friday     → Legs  
---

## **7.4 Workout Session**

An actual execution of a workout plan.

A session contains:

* Start time  
* End time  
* Planned exercises  
* Actual sets  
* Actual repetitions  
* Actual weight  
* Actual duration  
* Completion state

---

## **7.5 Workout Set**

A single performed instance of an exercise.

Example:

Bench Press  
Set 1  
8 reps  
60 kg  
---

## **7.6 Completed Workout**

A workout session where the user has logged at least one set of at least one exercise and then explicitly tapped Finish/Done. **Resolved 2026-09-05 (PD-001)** — see §47.

---

## **7.7 Incomplete / Cancelled Workout**

**Resolved 2026-09-05 (PD-002/PD-012) — no "Incomplete" state exists in this product.** If a workout is cancelled or exited before Finish is tapped — or Finish is tapped with zero sets logged — the session is discarded entirely: nothing is saved, and it never appears in history, progress, or statistics. Every workout record that exists in the system is, by definition, a completed one (§7.6).

---

# **8\. Product Navigation**

The MVP should provide a simple navigation structure.

Recommended:

Home  
│  
├── Today's Workout  
│  
├── Workout Plans  
│   ├── Plan List  
│   ├── Create Plan  
│   └── Plan Details  
│  
├── Schedule  
│  
├── Start Workout  
│  
├── History  
│   └── Workout Details  
│  
├── Progress  
│   ├── Overview  
│   ├── Exercises  
│   └── Personal Bests  
│  
└── Profile / Account

A Settings area may exist for basic application preferences.

---

# **9\. Feature Map**

Workout Tracker  
│  
├── Exercise Catalogue  
│  
├── Workout Plans  
│   ├── Create  
│   ├── View  
│   ├── Edit  
│   ├── Delete  
│   └── Configure Exercises  
│  
├── Scheduling  
│   ├── Assign Days  
│   ├── Recurrence  
│   ├── View Schedule  
│   ├── Edit Schedule  
│   └── Remove Schedule  
│  
├── Workout Execution  
│   ├── Start  
│   ├── Exercise  
│   ├── Set Recording  
│   ├── Timer  
│   ├── Pause  
│   ├── Resume  
│   ├── Skip  
│   ├── Finish  
│   └── Cancel  
│  
├── Workout Records  
│  
├── History  
│  
├── Progress  
│  
├── Statistics  
│   └── Personal Bests  
│  
└── Profile / Account  
---

# **10\. Feature Requirements**

# **10.1 Exercise Catalogue**

## **Objective**

Provide users with a reliable predefined catalogue from which exercises can be selected.

This implements BRD-FR-16 and BRD-FR-17.

### **Functional Requirements**

**FR-EX-001**

The system shall provide a predefined exercise catalogue.

**FR-EX-002**

The user shall be able to browse available exercises.

**FR-EX-003**

The user shall be able to select an exercise for a workout plan.

**FR-EX-004**

The system shall prevent selection of invalid or unavailable exercises.

**FR-EX-005**

Each exercise shall carry an explicit **type flag** that determines which performance fields are applicable (BRD-FR-76). **Resolved 2026-09-05 (PD-008/PD-009), see §47:**

Exercise Type  
├── `weighted` — reps + weight  
├── `time-based` — duration only (mm:ss entry, stored as seconds; see PD-010)  
└── `bodyweight` — reps only, no weight field shown at all

The exercise data model, and every screen that records or displays a set (plan configuration, active workout recording, history detail), must branch on this flag rather than presenting one generic reps+weight+duration form for every exercise.

### **Exercise Catalogue Ownership — Resolved 2026-09-05 (PD-011)**

**Fixed, developer-seeded list only.** No admin/curation tooling and no in-app mechanism for users to create custom exercises exists. The catalogue is static content shipped with the app (hardcoded or seeded into local storage on first launch). User-created exercises, exercise search, and exercise favorites remain **out of scope** for MVP — not decided items, simply not part of approved scope.

---

# **10.2 Workout Plan Management**

## **Objective**

Allow users to create reusable workout plans.

---

## **10.2.1 Create Workout Plan**

### **User Flow**

Workout Plans  
      ↓  
Create Plan  
      ↓  
Enter Plan Name  
      ↓  
Add Exercise  
      ↓  
Configure Target  
      ↓  
Configure Rest  
      ↓  
Save  
      ↓  
Workout Plan Created

### **Requirements**

**FR-WP-001**

The user shall be able to create a workout plan.

**FR-WP-002**

The user shall provide a non-blank workout-plan name.

**FR-WP-003**

The user shall be able to add exercises.

**FR-WP-004**

The user shall be able to configure target sets.

**FR-WP-005**

The user shall be able to configure target repetitions.

**FR-WP-006**

The user shall be able to configure target weight for `weighted`-type exercises (strictly positive; no weight field is shown for `bodyweight`-type exercises). Resolved 2026-09-05 (PD-008/PD-009) — see §47.

**FR-WP-007**

The user shall be able to configure target duration for `time-based`-type exercises, entered/displayed as mm:ss and stored as seconds. Resolved 2026-09-05 (PD-010) — see §47.

**FR-WP-008**

The user shall be able to configure rest periods.

**FR-WP-009**

The user shall be able to reorder exercises.

**FR-WP-010**

The system shall validate the workout plan before saving.

**FR-WP-011**

The system shall prevent invalid workout plans from being saved.

---

# **10.2.2 Workout Plan Details**

A workout plan shall display:

* Name  
* Exercises  
* Exercise order  
* Target sets  
* Target repetitions  
* Target weight  
* Duration where applicable  
* Rest period  
* Schedule information where applicable

---

# **10.2.3 Edit Workout Plan**

The user shall be able to:

* Change plan name  
* Add exercise  
* Remove exercise  
* Reorder exercises  
* Change target sets  
* Change target reps  
* Change target weight  
* Change duration  
* Change rest period

Changes shall apply to **future workout sessions**, not previously completed sessions.

This directly implements the BRD requirement that schedule/plan changes must not alter historical performance.

---

# **10.2.4 Delete Workout Plan**

The user shall be able to delete a workout plan.

### **Business Rule**

Deleting a workout plan must **not delete previously completed workout records** that were created from that plan.

Historical workout data must remain independently preserved.

---

# **10.3 Profile / Account**

## **Objective**

Provide the user with a simple, editable profile screen for basic personal/preference information.

This implements BO-11 and BRD-FR-72 through BRD-FR-75.

### **Approved Scope — Resolved 2026-09-05**

This screen is **in scope and editable** (previously flagged elsewhere as read-only/assumed; that assumption is superseded). This is confirmed new scope approved directly by the product owner in this clarification round — not scope creep. The screen carries **exactly these fields, no more**:

* **Display name** (text)  
* **Fitness goal** (short text or pick-list — e.g., Build muscle / Lose weight / General fitness)  
* **Experience level** (Beginner / Intermediate / Advanced — informational only; no logic or calculations are tied to this value for MVP)  
* **Height & weight** (numeric, stored for reference only — **not** used in any calculation unless separately decided in the future)

### **Functional Requirements**

**FR-PROF-001**

The user shall be able to view their profile information.

**FR-PROF-002**

The user shall be able to edit display name, fitness goal, experience level, and height/weight.

**FR-PROF-003**

The system shall not perform any calculation using experience level, height, or weight for MVP.

**FR-PROF-004**

The Logout action shall be available on this screen.

### **Relationship to Login**

There is no registration flow to collect these fields at signup — per the confirmed architecture, login is a static, non-authenticating placeholder screen, and the user sets/edits their profile directly on this screen after logging in. **No login-recovery flow of any kind exists** (no forgot-password, no reset-password, no OTP, no account lockout/recovery) — this is a deliberate architecture decision, not a gap. Full login/architecture detail lives in the SDS/architecture documents; this PRD states it here only so profile-screen requirements are not read in isolation.

---

# **11\. Workout Plan vs Workout Record Separation**

This is a critical product rule.

WORKOUT PLAN  
     │  
     │ used to create  
     ▼  
WORKOUT SESSION  
     │  
     │ produces  
     ▼  
WORKOUT RECORD

Changing:

Workout Plan

must not retroactively change:

Completed Workout Record

Example:

Yesterday:

> Bench Press — 3 × 8 @ 60 kg

Today the user edits the plan:

> Bench Press — 4 × 6 @ 70 kg

Yesterday's history must still show:

> 3 × 8 @ 60 kg

This is required by BRD-FR-43 and BRD-FR-48.

---

# **12\. Scheduling**

## **Objective**

Provide simple, predictable workout scheduling.

The BRD explicitly limits scheduling to day-based/simple recurring scheduling and excludes intelligent scheduling.

---

## **12.1 Schedule Workout**

The user shall be able to:

1. Select workout plan.  
2. Select one or more days.  
3. Define recurrence.  
4. Save schedule.

Example:

Push Workout  
Monday \+ Thursday  
Weekly  
---

## **12.2 Schedule Requirements**

**FR-SCH-001**

The user shall be able to assign a workout plan to a day of the week.

**FR-SCH-002**

The user shall be able to assign a workout plan to multiple days.

**FR-SCH-003**

The user shall be able to create a recurring weekly schedule.

**FR-SCH-004**

The system shall display workouts scheduled for the selected day.

**FR-SCH-005**

The user shall be able to modify a schedule.

**FR-SCH-006**

The user shall be able to remove a scheduled workout.

**FR-SCH-007**

The system shall prevent scheduling of unavailable workout plans.

**FR-SCH-008**

The system shall prevent invalid scheduling configurations.

**FR-SCH-009**

Changing a schedule shall not modify completed workout history.

**FR-SCH-010**

The system shall prevent assigning more than one workout plan to the same weekday — **one plan per day maximum** (BRD-FR-77). Resolved 2026-09-05 (PD-006) — see §47.

---

# **13\. Scheduling Boundaries**

The scheduler shall **not**:

* Automatically generate schedules.  
* Automatically optimize schedules.  
* Automatically reschedule missed workouts.  
* Calculate recovery requirements.  
* Create periodized training programs.  
* Generate progressive overload plans.

These are explicitly outside MVP scope.

---

# **14\. Workout Execution**

## **Objective**

Allow users to execute a saved workout with minimal interaction.

The BRD identifies workout execution as a core process: start → perform → record → complete → finish.

---

# **14.1 Start Workout**

A workout can be started from:

* Scheduled workout  
* Workout plan

### **Flow**

Select Workout  
     ↓  
Review Plan  
     ↓  
Start Workout  
     ↓  
Active Workout  
---

# **14.2 Active Workout**

The active workout screen should display:

* Workout name  
* Current exercise  
* Current set  
* Planned target  
* Actual input fields  
* Rest timer where applicable  
* Workout progress  
* Pause control  
* Skip control  
* Finish control

---

# **14.3 Record Set**

Recorded fields depend on the exercise type flag (§10.1, resolved 2026-09-05):

For `weighted` exercises:

Weight  
Repetitions

For `bodyweight` exercises:

Repetitions (no weight field)

For `time-based` exercises:

Duration (entered/displayed mm:ss, stored as seconds)

The actual performance must be recorded independently from planned targets.

---

# **14.4 Planned vs Actual**

Example:

### **Planned**

3 sets  
8 reps  
60 kg

### **Actual**

Set 1 → 8 reps @ 60 kg  
Set 2 → 8 reps @ 60 kg  
Set 3 → 7 reps @ 60 kg

The actual values must be preserved.

---

# **14.5 Timer**

The product shall support basic:

* Work timing  
* Rest timing

The timer must provide predictable transitions.

### **Required behavior**

Set completed  
     ↓  
Rest timer  
     ↓  
Rest finished  
     ↓  
Next set

### **Timer Behavior — Resolved 2026-09-05 (PD-007), see §47**

* The rest timer **auto-starts** the moment a set is marked complete — no manual "tap Start" step.
* The user can tap **Skip** to end the rest timer early and move on.
* Mid-rest editing of the timer duration is not supported for MVP.
* Timer behavior does not use push/remote notifications (consistent with §37).

### **Still Open**

**Whether the timer continues while the app is backgrounded remains explicitly DEFERRED** — the product owner wants to brainstorm whether it should pause-and-resume, wall-clock-catch-up, or end the session on backgrounding. This must not be silently defaulted; it is carried forward as an open decision for a future session and must be resolved before SRS.

---

# **15\. Pause / Resume**

The user shall be able to pause an active workout where applicable.

When paused:

* Active workout state must be preserved.  
* Recorded completed sets must remain available.  
* User shall be able to resume from the appropriate point.

---

# **16\. Skip Exercise**

The user shall be able to skip an applicable exercise.

### **Business Rule**

A skipped exercise shall not be treated as successfully completed.

Its treatment in final workout completion and statistics requires explicit product definition.

---

# **17\. Cancel Workout**

The user shall be able to cancel an active workout.

The system shall prevent cancelled activity from being incorrectly treated as a completed workout.

### **Resolved 2026-09-05 (PD-002/PD-012) — see §47**

Cancelling an active workout **always discards it**, regardless of how much was logged. There is no "Save as Incomplete" option and no discard-vs-save prompt — cancel always means discard, with no recovery afterward. Nothing is saved and nothing appears in history.

---

# **18\. Finish Workout**

When the user finishes the workout:

Active Workout  
      ↓  
Finish  
      ↓  
Validate Completion  
      ↓  
Completed? (at least one logged set — PD-001)  
   ↙       ↘  
 Yes       No  
 ↓          ↓  
Save       Discard  
Record     (no Incomplete state — PD-002/PD-012)  
 ↓  
Summary  

Resolved 2026-09-05 — see §47 (PD-001, PD-002/PD-012).

---

# **19\. Workout Completion Rules**

**Resolved 2026-09-05 (PD-001, PD-002/PD-012) — see §47.**

### **Approved rule**

A workout is completed when:

* At least one set of at least one exercise has been logged, AND  
* The user explicitly selects Finish/Done.

Not all exercises or all sets need be completed; skipped exercises may exist within an otherwise-completed workout.

### **Answers to the prior open questions**

1. Must all exercises be completed? — **No.**  
2. Can skipped exercises exist in a completed workout? — **Yes.**  
3. Can a workout with only one completed exercise be completed? — **Yes**, as long as at least one set was logged.  
4. Does cancelling always produce an incomplete workout? — **No incomplete state exists.** Cancelling always discards the session entirely (PD-002/PD-012).  
5. Can incomplete sessions be saved for later? — **No.** There is no incomplete/resumable session concept.  
6. Do incomplete sessions appear in history? — **No**, because they are never saved.  
7. Do incomplete sessions affect statistics? — **No**, for the same reason.

---

# **20\. Workout Summary**

After completion, the system shall show:

* Workout name  
* Date  
* Start time  
* End time  
* Total duration  
* Exercises completed  
* Sets completed  
* Total volume where applicable  
* Personal bests achieved, if applicable

Example:

Workout Complete

Push Day

Duration       54 min  
Exercises      5  
Sets           15  
Volume         8,420 kg

Personal Best  
Bench Press ✓  
---

# **21\. Workout Records**

The system shall store:

### **Session Information**

* Workout ID  
* Workout plan reference  
* Date  
* Start time  
* End time  
* Completion status  
* Duration

### **Exercise Information**

* Exercise  
* Exercise order  
* Planned target  
* Actual performance

### **Set Information**

* Set number  
* Repetitions  
* Weight  
* Duration where applicable  
* Completion status

---

# **22\. Historical Integrity**

Completed workout records must preserve the historical state of the actual workout.

The system shall not dynamically reconstruct historical records from the current workout plan.

Instead:

Current Plan  
     ≠  
Historical Record

This prevents plan modifications from corrupting historical progress.

---

# **23\. Workout History**

## **23.1 History List**

The user shall be able to view completed workouts.

Recommended information:

* Date  
* Workout name  
* Duration  
* Number of exercises  
* Number of sets  
* Training volume

---

## **23.2 History Detail**

The user shall be able to open a completed workout and see:

* Workout information  
* Exercise list  
* Planned targets  
* Actual performance  
* Sets  
* Reps  
* Weight  
* Duration  
* Personal best indicators where applicable

---

# **24\. History Editing and Deletion**

The BRD states that statistics must be recalculated when a workout record is **edited or deleted**, implying that record modification is part of the product requirement.

Therefore:

**FR-HIS-001**

The user shall be able to edit applicable historical workout information.

**FR-HIS-002**

The user shall be able to delete a workout record.

**FR-HIS-003**

The system shall recalculate affected statistics after modification.

**FR-HIS-004**

The system shall recalculate personal-best results after modification.

### **Important clarification**

The exact fields that may be edited must be defined.

For example:

* Weight?  
* Reps?  
* Duration?  
* Date?  
* Exercise?  
* Completed status?

This is a **PRD decision gap** that must be resolved before SRS.

---

# **25\. Progress Tracking**

## **Objective**

Help users understand how their performance changes across sessions.

The BRD requires comparison across sessions using weight, repetitions, volume, and duration where applicable.

---

## **25.1 Exercise Progress**

For a selected exercise:

Bench Press

Jan 01   50 kg × 8  
Jan 08   52.5 kg × 8  
Jan 15   55 kg × 8  
Jan 22   57.5 kg × 7

The product may display:

* Weight progression  
* Rep progression  
* Volume progression  
* Duration progression where applicable

---

# **26\. Progress Calculation**

For applicable resistance exercises:

> **Training Volume \= Weight × Repetitions**

Across valid completed sets:

> **Total Training Volume \= Σ (Weight × Repetitions)**

This definition is explicitly established in the BRD glossary.

Example:

Set 1: 60 × 8 \= 480  
Set 2: 60 × 8 \= 480  
Set 3: 60 × 7 \= 420

Total \= 1,380 kg  
---

# **27\. Statistics**

The MVP shall provide:

## **Workout Statistics**

* Total completed workouts  
* Total workout duration  
* Average workout duration

## **Exercise Statistics**

* Total sessions containing exercise  
* Best weight  
* Best repetitions  
* Total volume  
* Performance history

## **Volume Statistics**

* Session volume  
* Cumulative volume  
* Exercise-level volume

---

# **28\. Personal Bests**

The system shall calculate personal bests from valid completed workout records.

The BRD defines PB as the best recorded performance for a defined exercise metric.

However, the exact PB definitions remain **DEFERRED — explicitly open (PD-004, see §47)**. This was confirmed, not resolved, in the 2026-09-05 clarification session: the product owner wants a dedicated future brainstorming session to pick the metric(s). No default is assumed here.

Potential metrics (none selected yet):

| Metric | Example |
| ----- | ----- |
| Heaviest Weight | 100 kg |
| Highest Reps | 15 reps |
| Highest Volume | 2,000 kg |
| Longest Duration | 90 sec |

### **Required Decision — Still Open**

Define which metrics constitute a personal best for each exercise type. The Personal Bests view/screen is still structurally in scope (per-exercise bests are shown); only the exact metric definition is pending.

---

# **29\. Data Validation**

The product shall validate user input.

## **Weight**

* Applies only to `weighted`-type exercises; `bodyweight`-type exercises show no weight field at all.  
* Must be strictly positive (cannot be negative or zero). Resolved 2026-09-05 (PD-008) — see §47.  
* Decimal values may be supported.

## **Repetitions**

* Must be valid for applicable exercises.  
* Negative values prohibited.  
* Decimal reps should normally be prohibited.

## **Duration**

* Cannot be negative.  
* Applies to `time-based`-type exercises. Entered/displayed as **mm:ss**, stored internally as **seconds**. Resolved 2026-09-05 (PD-010) — see §47.

## **Sets**

* Must be valid positive values where required.

The BRD explicitly requires prevention of invalid sets/repetitions, negative weight, and negative duration.

---

# **30\. Invalid Data Handling**

Invalid values shall:

1. Not be accepted as valid performance.  
2. Produce clear validation feedback.  
3. Not affect progress calculations.  
4. Not affect statistics.  
5. Not create personal-best results.

---

# **31\. Incomplete Data Handling**

**Note (resolved 2026-09-05, PD-002/PD-012, see §47): no "Incomplete workout session" record is ever saved** — a cancelled or zero-set session is discarded outright (§7.7). This section therefore applies only to individual invalid/rejected input values (e.g., a bad reps entry the system refuses to accept), never to a persisted incomplete session, since every saved workout record is by definition completed.

Valid Completed  
      ↓  
Progress ✓  
Statistics ✓  
PB ✓ (metric TBD — PD-004, deferred)

Rejected/Invalid Input (not a saved record)  
      ↓  
Progress ✗  
Statistics ✗  
PB ✗

This follows BRD-FR-51 and BRD-FR-62.

---

# **32\. Offline Behavior**

The BRD explicitly assumes that core functionality should not depend on continuous internet connectivity and that the MVP uses local device persistence rather than cloud synchronization.

Therefore, the MVP should support core workout functionality without continuous internet access.

### **Offline-capable areas**

* View workout plans  
* View schedules  
* Start workouts  
* Record workout data  
* Complete workouts  
* View history  
* View progress  
* View statistics

### **Not applicable in MVP**

There is no cloud synchronization requirement.

---

# **33\. Local Data Persistence**

The application shall persist core product data locally on the device.

Data should survive:

* Screen navigation  
* Application restart  
* Temporary interruption

### **Critical requirement**

An application crash during workout execution must not corrupt previously recorded completed workout data.

---

# **34\. Error Handling**

The product shall provide clear feedback when:

* Required input is missing.  
* Input is invalid.  
* Workout cannot be started.  
* Workout plan is unavailable.  
* Schedule is invalid.  
* Workout cannot be completed.  
* Data cannot be saved.  
* A record cannot be modified/deleted.

---

# **35\. Interrupted Workout**

Potential interruptions include:

* App closed  
* App crash  
* Phone restart  
* User navigates away  
* Incoming call  
* Device resource pressure

The product shall preserve valid previously recorded workout information.

### **Open Decision**

Whether an active session should automatically restore to the exact previous state after app restart must be explicitly approved.

---

# **36\. Permissions**

The MVP does not currently require major device permissions.

Expected permission requirements are minimal because:

* No location  
* No health data  
* No wearable  
* No camera  
* No microphone  
* No cloud integration

Any future permission-dependent feature must be separately assessed.

---

# **37\. Notifications**

Push notifications are **not a core MVP requirement** in the BRD.

Therefore the MVP should not depend on:

* Push notification service  
* Cloud messaging  
* Remote notification infrastructure

### **Open Decision**

Whether local reminders for scheduled workouts should be included is not defined in the BRD.

This should be treated as a product decision rather than silently adding it to scope.

---

# **38\. Security & Privacy**

The application shall:

* Minimize unnecessary personal data.  
* Protect stored workout information.  
* Restrict access to the user's own data.  
* Follow applicable privacy requirements.  
* Clearly position itself as a fitness tracker rather than a medical product.

These requirements derive from BR-NFR-008 through BR-NFR-012.

---

# **39\. Non-Functional Product Requirements**

## **Performance**

**NFR-001**

Core screens should respond without noticeable delay under normal device conditions.

**NFR-002**

Workout transitions should be timely enough not to disrupt workout execution.

**NFR-003**

Set recording should require minimal interaction.

The BRD specifically emphasizes responsiveness and minimizing disruption during workout execution.

---

## **Reliability**

**NFR-004**

Successfully saved workout records shall not be lost during normal application operation.

**NFR-005**

Derived statistics shall remain consistent with underlying valid workout records.

**NFR-006**

Interrupted sessions shall not corrupt completed records.

---

## **Usability**

**NFR-007**

The application shall be understandable to users with different levels of fitness and technical familiarity.

**NFR-008**

The workout execution flow shall minimize unnecessary interaction.

**NFR-009**

Validation errors shall clearly explain what the user needs to correct.

---

# **40\. Product State Models**

## **40.1 Workout Plan**

Created  
   ↓  
Active  
   ↓  
Edited  
   ↓  
Deleted

Historical records are unaffected by plan changes.

---

## **40.2 Workout Session**

**Resolved 2026-09-05 (PD-001, PD-002/PD-012, see §47) — no "Incomplete" state exists.** Confirmed state model:

Not Started  
     ↓  
In Progress  
   ↙        ↘  
Paused    Cancelled → **Discarded** (terminal; nothing saved, no history entry)  
  ↓  
In Progress  
  ↓  
Finish tapped  
   ↙        ↘  
≥1 set logged   0 sets logged  
     ↓              ↓  
 **Completed**   **Discarded**  
 (saved, terminal) (terminal, not saved)

---

# **41\. Core User Journeys**

## **Journey 1 — Create Workout**

Open App  
 ↓  
Workout Plans  
 ↓  
Create Plan  
 ↓  
Enter Name  
 ↓  
Add Exercise  
 ↓  
Configure Targets  
 ↓  
Save  
 ↓  
Plan Available  
---

## **Journey 2 — Schedule Workout**

Workout Plan  
 ↓  
Schedule  
 ↓  
Select Day  
 ↓  
Select Recurrence  
 ↓  
Save  
 ↓  
Workout Appears on Schedule  
---

## **Journey 3 — Execute Workout**

Today's Workout  
 ↓  
Start  
 ↓  
Exercise  
 ↓  
Record Set  
 ↓  
Rest  
 ↓  
Next Set  
 ↓  
Next Exercise  
 ↓  
Finish  
 ↓  
Validate  
 ↓  
Save  
 ↓  
Summary  
---

## **Journey 4 — Review History**

History  
 ↓  
Select Workout  
 ↓  
Workout Details  
 ↓  
Review Actual Performance  
---

## **Journey 5 — View Progress**

Progress  
 ↓  
Select Exercise  
 ↓  
Select Metric  
 ↓  
View Historical Performance  
---

# **42\. Edge Cases**

The following scenarios must be handled.

## **Workout Plan**

* Blank plan name  
* Duplicate plan names  
* No exercises  
* Exercise removed after being added  
* Invalid target  
* Invalid rest duration  
* Deleted plan with historical workouts

## **Scheduling**

* Same plan scheduled multiple times  
* No scheduled day  
* Invalid plan  
* Deleted plan with existing schedule  
* Schedule modification  
* User attempts to assign a second plan to an already-scheduled day — must be prevented (one plan per day, PD-006)  
* User changes plan after scheduling

## **Workout Execution**

* User skips exercise  
* User skips set  
* User pauses  
* User cancels  
* User finishes early  
* User does not complete all exercises  
* App closes during workout  
* App crashes  
* Invalid performance input  
* Timer interrupted

## **History**

* No history  
* Deleted workout  
* Edited workout  
* Plan deleted after workout  
* Plan modified after workout

## **Progress**

* No historical data  
* Only one session  
* Deleted record  
* Edited record  
* Exercise has mixed measurement types (weighted / bodyweight / time-based)

## **Statistics**

* Zero completed workouts  
* No applicable volume  
* Time-based exercise  
* Invalid record  
* Deleted record affecting PB  
* Edited record affecting PB

---

# **43\. Business Rules**

| ID | Rule |
| ----- | ----- |
| BR-001 | Workout plan names cannot be blank |
| BR-002 | Workout plans may only reference valid exercises |
| BR-003 | Invalid workout configurations cannot be saved |
| BR-004 | Negative weight is invalid |
| BR-005 | Negative duration is invalid |
| BR-006 | Invalid repetitions are not valid performance |
| BR-007 | Planned targets and actual performance are separate |
| BR-008 | Plan changes must not alter historical records |
| BR-009 | Schedule changes must not alter historical records |
| BR-010 | Only valid completed records contribute to applicable statistics |
| BR-011 | Incomplete records do not contribute to applicable progress |
| BR-012 | Training volume uses valid weight × repetitions |
| BR-013 | PBs are calculated from valid completed records |
| BR-014 | Editing/deleting historical records requires recalculation |
| BR-015 | Advanced scheduling is outside MVP |
| BR-016 | Cloud synchronization is outside MVP |
| BR-017 | Health/wearable integrations are outside MVP |
| BR-018 | Social functionality is outside MVP |

---

# **44\. Acceptance Criteria**

The PRD should eventually provide acceptance criteria for every functional requirement.

Examples:

### **AC-WP-001 — Create Workout Plan**

**Given** the user is on the Create Workout Plan screen  
**When** the user enters a valid name, adds valid exercises, configures valid targets, and selects Save  
**Then** the system shall create the workout plan.

### **AC-WP-002 — Invalid Name**

**Given** the user is creating a workout plan  
**When** the user enters a blank name  
**Then** the system shall prevent saving and display a validation message.

### **AC-EX-001 — Record Set**

**Given** the user is performing a resistance exercise  
**When** the user enters valid weight and repetitions and confirms the set  
**Then** the actual set shall be recorded against the active workout session.

### **AC-HIS-001 — Historical Integrity**

**Given** a completed workout was recorded using Plan A  
**When** the user modifies Plan A  
**Then** the completed workout record shall retain its original actual performance.

### **AC-PROG-001 — Progress**

**Given** valid completed records exist for an exercise  
**When** the user opens Progress  
**Then** the system shall display applicable historical performance.

### **AC-STAT-001 — Training Volume**

**Given** valid completed sets contain weight and repetitions  
**When** statistics are calculated  
**Then** training volume shall be calculated using weight × repetitions.

---

# **45\. Requirement Traceability**

The PRD maintains traceability back to BRD v2.1 (BRD-FR-1 through BRD-FR-77, and Business Objectives BO-01 through BO-11).

### **Business Objectives**

| BRD | PRD |
| ----- | ----- |
| BO-01 — Provide Simple Local App Access | Login/local-access architecture (detailed in SDS); §38 Security & Privacy |
| BO-02 — Simplify Workout Planning | §10.2 Workout Plan Management |
| BO-03 — Support Basic Workout Scheduling | §12 Scheduling; §13 Scheduling Boundaries |
| BO-04 — Enable Workout Execution | §14 Workout Execution |
| BO-05 — Improve Workout Record Consistency | §11 Plan vs Workout Record Separation; §21 Workout Records |
| BO-06 — Preserve Historical Performance | §22 Historical Integrity; §23 Workout History |
| BO-07 — Improve Progress Visibility | §25 Progress Tracking; §26 Progress Calculation |
| BO-08 — Provide Basic Performance Measurement | §27 Statistics; §28 Personal Bests |
| BO-09 — Protect Personal Workout Data | §38 Security & Privacy |
| BO-10 — Maintain a Controlled MVP | §5 Explicitly Out of Scope; §49 MVP Boundary |
| BO-11 — Support Basic Local Profile Management \[NEW — v2.1\] | §10.3 Profile / Account |

### **Functional Requirements**

| BRD | PRD |
| ----- | ----- |
| BRD-FR-1 \[DEPRECATED\] | No PRD equivalent — registration removed in BRD v2.0; superseded by BRD-FR-66, BRD-FR-67, BRD-FR-69 |
| BRD-FR-2 \[DEPRECATED\] | No PRD equivalent — no email collected in v2.0 |
| BRD-FR-3 \[DEPRECATED\] | No PRD equivalent — no user-set password in v2.0 |
| BRD-FR-4 \[DEPRECATED\] | No PRD equivalent — no registration in v2.0 |
| BRD-FR-5 \[REVISED\] | Login screen (architecture detailed in SDS, not separately numbered in PRD) |
| BRD-FR-6 | FR-PROF-004 (Logout, §10.3) |
| BRD-FR-7 \[DEPRECATED\] | No PRD equivalent — no password recovery in v2.0 |
| BRD-FR-8 \[DEPRECATED\] | No PRD equivalent — no password recovery in v2.0 |
| BRD-FR-9 \[REVISED\] | Local session state (SDS) |
| BRD-FR-10 | Local session state (SDS) |
| BRD-FR-11 \[REVISED\] | §33 Local Data Persistence |
| BRD-FR-12 | Login screen (SDS) |
| BRD-FR-13 \[DEPRECATED\] | No PRD equivalent — superseded by BO-11/BRD-FR-72–75 (Profile screen) |
| BRD-FR-14 \[DEPRECATED\] | No PRD equivalent — moot, no registration in v2.0 |
| BRD-FR-15 \[REVISED\] | §5 Explicitly Out of Scope (no registration/reset/social/OTP/biometric/MFA) |
| BRD-FR-16 | FR-EX-001, FR-EX-002 (§10.1) |
| BRD-FR-17 | FR-EX-003, FR-EX-004 (§10.1) |
| BRD-FR-18 | FR-WP-001 (§10.2.1) |
| BRD-FR-19 | FR-WP-002 (§10.2.1) |
| BRD-FR-20 | FR-WP-003 (§10.2.1) |
| BRD-FR-21 | FR-WP-004–008 (§10.2.1) |
| BRD-FR-22 | §10.2.3 Edit Workout Plan |
| BRD-FR-23 | §10.2.4 Delete Workout Plan |
| BRD-FR-24 | FR-SCH-001 (§12.2) |
| BRD-FR-25 | FR-SCH-003 (§12.2) |
| BRD-FR-26 | FR-SCH-004 (§12.2) |
| BRD-FR-27 | FR-SCH-005 (§12.2) |
| BRD-FR-28 | FR-SCH-006 (§12.2) |
| BRD-FR-29 | FR-SCH-002 (§12.2) |
| BRD-FR-30 | §14.1 Start Workout |
| BRD-FR-31 | FR-SCH-009 (§12.2) |
| BRD-FR-32 | FR-SCH-007 (§12.2) |
| BRD-FR-33 | FR-SCH-008 (§12.2) |
| BRD-FR-34 | §14.1 Start Workout |
| BRD-FR-35 | §14.2 Active Workout; §14.4 Planned vs Actual |
| BRD-FR-36 | §14.3 Record Set |
| BRD-FR-37 | §14.3 Record Set |
| BRD-FR-38 | §14.5 Timer |
| BRD-FR-39 | §14.2 Active Workout |
| BRD-FR-40 | §15 Pause/Resume; §16 Skip Exercise; §17 Cancel Workout |
| BRD-FR-41 | §18 Finish Workout |
| BRD-FR-42 | §21 Workout Records |
| BRD-FR-43 | §11 Plan vs Workout Record Separation; §21 Workout Records |
| BRD-FR-44 \[REVISED\] | §21 Workout Records; §33 Local Data Persistence |
| BRD-FR-45 | §20 Workout Summary |
| BRD-FR-46 | §23 Workout History |
| BRD-FR-47 | §24 History Editing and Deletion |
| BRD-FR-48 | §22 Historical Integrity; §11 Plan vs Workout Record Separation |
| BRD-FR-49 | §25 Progress Tracking |
| BRD-FR-50 | §26 Progress Calculation |
| BRD-FR-51 | §26 Progress Calculation; §31 Incomplete Data Handling |
| BRD-FR-52 | §27 Statistics |
| BRD-FR-53 | §27 Statistics |
| BRD-FR-54 | §27 Statistics |
| BRD-FR-55 | §27 Statistics |
| BRD-FR-56 | §28 Personal Bests (metric definition deferred — PD-004, §47) |
| BRD-FR-57 | §24 History Editing and Deletion; §27 Statistics; §28 Personal Bests |
| BRD-FR-58 | §29 Data Validation |
| BRD-FR-59 | §29 Data Validation |
| BRD-FR-60 | §29 Data Validation |
| BRD-FR-61 | §29 Data Validation |
| BRD-FR-62 | §31 Incomplete Data Handling |
| BRD-FR-63 | §33 Local Data Persistence |
| BRD-FR-64 \[REVISED\] | §32 Offline Behavior |
| BRD-FR-65 \[REVISED\] | §33 Local Data Persistence |
| BRD-FR-66 \[NEW\] | Login screen (SDS); §5 Explicitly Out of Scope |
| BRD-FR-67 \[NEW\] | §5 Explicitly Out of Scope |
| BRD-FR-68 \[NEW\] | §5 Explicitly Out of Scope |
| BRD-FR-69 \[NEW\] | §33 Local Data Persistence |
| BRD-FR-70 \[NEW\] | §33 Local Data Persistence |
| BRD-FR-71 \[NEW\] | §32 Offline Behavior |
| BRD-FR-72 \[NEW — v2.1\] | FR-PROF-001 (§10.3 Profile / Account) |
| BRD-FR-73 \[NEW — v2.1\] | FR-PROF-002 (§10.3 Profile / Account) |
| BRD-FR-74 \[NEW — v2.1\] | FR-PROF-003 (§10.3 Profile / Account) |
| BRD-FR-75 \[NEW — v2.1\] | FR-PROF-004 (§10.3 Profile / Account) |
| BRD-FR-76 \[NEW — v2.1\] | FR-EX-005 (§10.1 Exercise Catalogue — exercise type flag) |
| BRD-FR-77 \[NEW — v2.1\] | FR-SCH-010 (§12.2 — one plan per day maximum) |

The current BRD (v2.1) contains 77 functional requirements and 18 non-functional requirements; the PRD preserves traceability to all of them.

---

# **46\. Requirement Coverage Matrix**

Before the PRD is approved, every feature should be checked against:

| Feature | Happy Path | Alternate | Exception | Validation | State | Data | Offline | History | Statistics | Scope |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| Exercise Catalogue | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | ✓ |
| Workout Plans | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Scheduling | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| Workout Execution | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Workout Records | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| History | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Progress | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Statistics | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Personal Bests | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Profile / Account | ✓ | — | ✓ | ✓ | — | ✓ | ✓ | — | — | ✓ |

This matrix is particularly useful before moving to SRS.

---

# **47\. Open Product Decisions**

The BRD is strong, but it intentionally leaves several decisions for the PRD stage. The BRD itself identifies scheduling rules, personal-best definitions, training-volume calculation, incomplete-workout treatment, and timer behavior as areas requiring further definition.

These should **not be silently assumed**.

Most items below were resolved in the **product-owner clarification session held 2026-09-05**. Each resolved item is marked **RESOLVED** with the decision. Two items remain explicitly **DEFERRED** and must not be silently defaulted.

## **High Priority**

### **PD-001 — Workout Completion — RESOLVED (2026-09-05)**

A workout session counts as **completed** as soon as the user has logged at least one set of at least one exercise, AND then explicitly taps Finish/Done. Explicit Finish with zero sets logged is **not** a completed workout — it is treated as a discard (see PD-002/PD-012). This is a deliberately low bar; most real attempts should count. Not all exercises or all sets are required.

### **PD-002 — Incomplete Workout — RESOLVED (2026-09-05)**

**Always discard, no partial save.** If the user cancels or exits an active workout before tapping Finish, the session is discarded entirely, regardless of how much was logged. Nothing is saved, nothing appears in history, and no "Incomplete" state exists anywhere in the product. There is no "Save as Incomplete vs. Discard" prompt. Downstream effect: history, statistics, and progress logic never need to handle an "incomplete session" case — every record that exists is, by definition, completed (per PD-001).

### **PD-003 — Historical Editing**

**Still open.** Not addressed in the 2026-09-05 clarification session. Which historical fields (weight, reps, duration, date, exercise, completed status) may be edited after the fact remains undefined and must be resolved before SRS.

### **PD-004 — Personal Best Definition — DEFERRED, explicitly open**

**Not decided yet.** The product owner wants a separate, dedicated brainstorming session to choose the metric(s) that define a Personal Best (heaviest weight / highest reps / highest volume / longest duration — one or more, potentially varying by exercise type). This PRD does **not** pick a default. A Personal Bests view still exists structurally (per-exercise bests are shown), but the exact metric definition carries a visible **TBD — deferred, see Open Decisions** flag until that future session occurs.

### **PD-005 — Schedule Recurrence — RESOLVED (2026-09-05)**

Weekly recurrence only: the user assigns a workout plan to one or more weekdays (e.g., Mon/Wed/Fri) and it repeats every week. No specific-date / calendar (non-recurring) scheduling exists.

### **PD-006 — Multiple Plans Same Day — RESOLVED (2026-09-05)**

**One plan per day maximum.** A given weekday can hold at most one scheduled plan. Monday cannot contain both "Push" and "Cardio" — the system must prevent assigning a second plan to a day that already has one (see FR-SCH-010 in §12.2).

### **PD-007 — Timer — RESOLVED (2026-09-05), background behavior DEFERRED**

* Automatic: the rest timer **auto-starts** the moment a set is marked complete. No manual "tap Start" step.
* Skippable: the user can tap **Skip** to end the rest timer early and move on.
* Editable during execution: not supported for MVP (no scope for mid-rest duration editing).
* **App-backgrounded behavior remains explicitly DEFERRED** — whether the timer should pause-and-resume, wall-clock-catch-up, or end the session on backgrounding is not decided; the product owner wants to brainstorm this separately. Requirements must not silently assume a default here; background timer handling is carried as a placeholder for build-order purposes with its specific behavior marked TBD.

### **PD-008 — Zero Weight — RESOLVED (2026-09-05)**

Not applicable as previously framed. Weight is a strictly-positive field for `weighted`-type exercises only (0 kg is not accepted). `bodyweight`-type exercises have no weight field at all, so "0 kg" never occurs as a valid input state.

### **PD-009 — Bodyweight Exercises — RESOLVED (2026-09-05)**

Every catalogue exercise carries an explicit **type flag**: `weighted` (reps + weight), `time-based` (duration only), or `bodyweight` (reps only — no weight field shown). Bodyweight-exercise performance is recorded as reps only; the UI/data model branches on this flag rather than presenting one generic reps+weight+duration form for every exercise (see §10.1, §10.2, §14.3).

### **PD-010 — Duration — RESOLVED (2026-09-05)**

Duration for `time-based` exercises is **entered and displayed as mm:ss**, and **stored internally as seconds**.

### **PD-011 — Exercise Catalogue — RESOLVED (2026-09-05)**

**Fixed, developer-seeded list only.** There is no admin/curation tooling and no in-app mechanism for end users to create custom exercises. The catalogue is static content shipped with the app (hardcoded or seeded into local storage on first launch). User-created exercises remain out of scope.

### **PD-012 — Workout Record Deletion — RESOLVED (2026-09-05)**

Consistent with PD-002: an **active** (in-progress) workout that is cancelled is always discarded outright with no recovery/confirmation-to-save step. Deleting an already-**saved** (completed) workout record from History (§24) is a separate, existing action and still requires a standard delete confirmation; there is no undo/recovery after that confirmation.

---

# **48\. Assumptions Carried Forward**

Unless changed through product decisions:

1. The MVP targets individual users.  
2. Exercise catalogue is predefined.  
3. Workout plans are user-managed.  
4. Scheduling is simple weekly scheduling.  
5. No cloud synchronization.  
6. Core workout functionality works without continuous connectivity.  
7. Advanced scheduling is excluded.  
8. Advanced coaching is excluded.  
9. Health integrations are excluded.  
10. Social functionality is excluded.  
11. Statistics are derived from valid workout records.  
12. Historical records are independent from current plans.

These assumptions originate from the BRD.

---

# **49\. MVP Boundary**

The product's MVP boundary is:

> **A user can create a workout plan, schedule it on simple recurring days, perform it, record actual performance, review completed workouts, and understand basic performance progress.**

Everything else should be evaluated against this statement.

### **A feature should enter MVP only if it directly supports:**

PLAN  
  ↓  
SCHEDULE  
  ↓  
PERFORM  
  ↓  
RECORD  
  ↓  
REVIEW  
  ↓  
PROGRESS

If it doesn't, it should normally be considered future scope unless there is a strong product justification.

---

# **50\. MVP Definition of Done**

The MVP can be considered product-complete when a user can successfully execute this complete journey:

Create Workout Plan  
        ↓  
Add Exercises  
        ↓  
Configure Targets  
        ↓  
Save Plan  
        ↓  
Schedule Plan  
        ↓  
View Scheduled Workout  
        ↓  
Start Workout  
        ↓  
Perform Exercise  
        ↓  
Record Sets / Reps / Weight  
        ↓  
Use Rest Timer  
        ↓  
Complete Workout  
        ↓  
View Summary  
        ↓  
View History  
        ↓  
View Exercise Progress  
        ↓  
View Statistics  
        ↓  
View Personal Bests

And the system must preserve the fundamental rule:

> **Changing today's/future workout configuration must never corrupt yesterday's actual workout history.**

---

# **51\. Product Requirements Baseline**

Once the following are approved:

* Feature scope  
* User journeys  
* Completion rules  
* Scheduling rules  
* Timer rules  
* Historical editing rules  
* Incomplete-workout rules  
* Statistics definitions  
* PB definitions  
* Data validation rules  
* Edge-case behavior  
* Offline behavior  
* MVP boundaries

the PRD can be marked:

> **BASELINED / APPROVED**

After that, changes should go through product change management rather than being silently added to development.

---

