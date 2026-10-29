# **Product Requirements Document (PRD)**

# **Forge-Workout Tracker**

**Product / Application:** Workout Tracker  
**Domain:** Health & Fitness  
**Application Type:** Mobile Application  
**Target Platforms:** iOS and Android  
**Target Market:** Global  
**Document Type:** Product Requirements Document  
**Version:** 1.0  
**Status:** Draft  
**Derived From:** Workout Tracker BRD v1.0  
**BRD Baseline:** Pending stakeholder approval

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
* Personal bests

The scope follows the BRD's explicit functional requirements BR-FR-001 through BR-FR-046.

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

A workout session satisfying the defined completion criteria.

**Important:** The exact completion criteria must be finalized during PRD validation.

---

## **7.7 Incomplete Workout**

A workout that does not satisfy completion criteria.

The BRD specifies that incomplete records should not contribute to applicable progress/statistics.

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
└── Progress  
    ├── Overview  
    ├── Exercises  
    └── Personal Bests

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
└── Statistics  
    └── Personal Bests  
---

# **10\. Feature Requirements**

# **10.1 Exercise Catalogue**

## **Objective**

Provide users with a reliable predefined catalogue from which exercises can be selected.

This implements BR-FR-001 and BR-FR-002.

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

Each exercise shall have sufficient metadata to determine which performance fields are applicable.

For example:

Exercise Type  
├── Repetition-based  
├── Time-based  
└── Other supported type

### **Open Product Decision**

The BRD does not define the complete exercise data model.

**TBD:**

* Exercise categories?  
* Muscle groups?  
* Equipment?  
* Instructions?  
* Image?  
* Video?  
* Exercise search?  
* Exercise favorites?  
* User-created exercises?

User-created exercises should remain **out of scope unless explicitly approved**, because the BRD currently specifies a predefined catalogue.

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

The user shall be able to configure target weight.

**FR-WP-007**

The user shall be able to configure duration where applicable.

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

This is required by BR-FR-032.

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

For repetition-based exercises:

Weight  
Repetitions

For time-based exercises:

Duration

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

### **Open Decision**

The BRD says "basic work/rest timing" but does not specify:

* Whether timer starts automatically.  
* Whether timer can be skipped.  
* Whether timer can be edited during execution.  
* Whether timer continues while app is backgrounded.  
* Whether timer uses notifications.

These must be resolved before SRS.

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

The system shall prevent cancelled/incomplete activity from being incorrectly treated as a completed workout.

### **Open Decision**

Whether the user should be offered:

> **Save as Incomplete**

or simply:

> **Discard**

must be finalized.

---

# **18\. Finish Workout**

When the user finishes the workout:

Active Workout  
      ↓  
Finish  
      ↓  
Validate Completion  
      ↓  
Completed?  
   ↙       ↘  
 Yes       No  
 ↓          ↓  
Save       Incomplete  
Record     Handling  
 ↓  
Summary  
---

# **19\. Workout Completion Rules**

This is one of the most important unresolved areas in the BRD.

The BRD defines a "Completed Workout" but does not define exactly what constitutes completion.

The PRD therefore requires a decision on:

### **Candidate rule**

A workout is completed when:

* User explicitly selects Finish.  
* At least one applicable exercise has been completed.  
* Required performance information is valid.

However, this is a **proposed product rule**, not yet an approved requirement.

### **Decision Required**

Define:

1. Must all exercises be completed?  
2. Can skipped exercises exist in a completed workout?  
3. Can a workout with only one completed exercise be completed?  
4. Does cancelling always produce an incomplete workout?  
5. Can incomplete sessions be saved for later?  
6. Do incomplete sessions appear in history?  
7. Do incomplete sessions affect statistics?

The BRD specifically identifies treatment of incomplete workouts as a dependency requiring stakeholder agreement.

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

However, the exact PB definitions need to be finalized.

Potential metrics:

| Metric | Example |
| ----- | ----- |
| Heaviest Weight | 100 kg |
| Highest Reps | 15 reps |
| Highest Volume | 2,000 kg |
| Longest Duration | 90 sec |

### **Required Decision**

Define which metrics constitute a personal best for each exercise type.

---

# **29\. Data Validation**

The product shall validate user input.

## **Weight**

* Cannot be negative.  
* Decimal values may be supported.  
* Zero handling must be defined.

## **Repetitions**

* Must be valid for applicable exercises.  
* Negative values prohibited.  
* Decimal reps should normally be prohibited.

## **Duration**

* Cannot be negative.  
* Unit must be defined.

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

Incomplete records must be handled separately from valid completed records.

Valid Completed  
      ↓  
Progress ✓  
Statistics ✓  
PB ✓

Incomplete  
      ↓  
Progress ✗  
Statistics ✗  
PB ✗

This follows BR-FR-035 and BR-FR-046.

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

Proposed state model:

Not Started  
     ↓  
In Progress  
   ↙   ↓   ↘  
Paused  Completed  Cancelled  
  ↓  
In Progress

Potential additional state:

Incomplete

The exact state model must be confirmed during SRS.

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
* Multiple plans on same day  
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
* Incomplete records  
* Deleted record  
* Edited record  
* Exercise has mixed measurement types

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

The PRD should maintain traceability back to the BRD.

Example:

| BRD | PRD |
| ----- | ----- |
| BR-FR-001 | FR-EX-001 |
| BR-FR-002 | FR-EX-002–005 |
| BR-FR-003 | FR-WP-001 |
| BR-FR-004 | FR-WP-002 |
| BR-FR-005 | FR-WP-003 |
| BR-FR-006 | FR-WP-004–008 |
| BR-FR-007 | FR-WP-010 |
| BR-FR-008 | FR-WP-011 |
| BR-FR-009–018 | FR-SCH-001–009 |
| BR-FR-019–026 | Workout Execution requirements |
| BR-FR-027–029 | Workout Record requirements |
| BR-FR-030–032 | History requirements |
| BR-FR-033–035 | Progress requirements |
| BR-FR-036–041 | Statistics/PB requirements |
| BR-FR-042–046 | Validation requirements |

The original BRD contains 46 functional requirements and 18 non-functional requirements; the PRD should preserve traceability to all of them.

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

This matrix is particularly useful before moving to SRS.

---

# **47\. Open Product Decisions**

The BRD is strong, but it intentionally leaves several decisions for the PRD stage. The BRD itself identifies scheduling rules, personal-best definitions, training-volume calculation, incomplete-workout treatment, and timer behavior as areas requiring further definition.

These should **not be silently assumed**.

## **High Priority**

### **PD-001 — Workout Completion**

What exactly makes a workout "completed"?

* All exercises?  
* All required sets?  
* At least one exercise?  
* Explicit Finish only?

### **PD-002 — Incomplete Workout**

Should incomplete workouts:

* Be saved?  
* Appear in history?  
* Be resumable?  
* Be editable?  
* Be permanently discarded?

### **PD-003 — Historical Editing**

Which historical fields can be edited?

### **PD-004 — Personal Best Definition**

What metrics qualify as a PB?

### **PD-005 — Schedule Recurrence**

What does "simple recurring schedule" specifically mean?

Recommended MVP:

> Weekly recurrence on selected weekdays.

### **PD-006 — Multiple Plans Same Day**

Can Monday contain:

Push  
\+  
Cardio

or only one workout?

### **PD-007 — Timer**

* Automatic or manual?  
* Skippable?  
* Editable?  
* What happens when app is backgrounded?

### **PD-008 — Zero Weight**

Is:

> 0 kg

valid for bodyweight exercises?

### **PD-009 — Bodyweight Exercises**

How is performance recorded when weight is not applicable?

### **PD-010 — Duration**

Is duration stored in:

* Seconds?  
* Minutes?  
* Hours?

### **PD-011 — Exercise Catalogue**

Who owns the predefined exercise catalogue?

### **PD-012 — Workout Record Deletion**

What confirmation/recovery behavior is required?

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

