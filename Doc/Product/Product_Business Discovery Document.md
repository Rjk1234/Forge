# **Product/Business Discovery Document**

## **Forge— Workout Planner & Tracker**

**Document Type:** Product / Business Discovery Brief  
**Version:** 1.0  
**Status:** Initial Discovery  
**Working Title:Forge** **Workout Tracker**  
**Platform:** Mobile — Flutter (iOS & Android)

---

## **1\. Product Concept**

### **Working Title**

**Workout Tracker**

### **Product Summary**

Workout Tracker is a simple mobile application that helps users **plan workouts, execute them, record actual performance, and understand progress over time**.

The application focuses on the complete basic workout lifecycle:

> **Plan → Execute → Record → Review → Improve**

The product is intentionally designed as a **simple workout tracking tool**, rather than a full fitness, nutrition, social, coaching, or health platform.

---

# **2\. Problem Statement**

Users who follow regular workouts need a simple way to:

* Create structured workout routines.  
* Know what exercise to perform during a workout.  
* Record actual sets, repetitions, weights, and durations.  
* Keep a history of completed workouts.  
* Compare current performance with previous sessions.  
* Understand basic improvements in their training.

Without a dedicated tracker, users may rely on memory, paper notes, spreadsheets, or generic note-taking applications. These approaches make it difficult to consistently record workout performance and identify meaningful progress over time.

The proposed application provides a single, structured place to **plan, perform, record, and review workouts**.

---

# **3\. Why This Problem Matters**

Consistent workout tracking helps users understand whether their training performance is improving.

Without historical records, users may not know:

* How much weight they previously lifted.  
* How many repetitions they previously completed.  
* How their training volume has changed.  
* When they achieved a personal best.  
* How consistently they have completed their workouts.

A simple tracking workflow reduces the effort required to maintain this information and makes previous performance available when the user needs it during or after a workout.

The product therefore focuses on **consistency and visibility of training progress**, rather than providing advanced fitness coaching.

---

# **4\. Target Users**

### **Primary Users**

Individuals who perform structured workouts and want to track their performance.

Examples include:

* Gym users.  
* Beginner to intermediate fitness users.  
* Users following self-created workout routines.  
* Users following simple strength or time-based workouts.  
* Users who currently track workouts manually.

### **User Characteristics**

The target user generally wants:

* A simple workout planner.  
* Quick workout logging.  
* Minimal interaction during exercise.  
* Easy access to previous performance.  
* Basic progress statistics.

### **Not the Initial Target**

The MVP is not specifically designed for:

* Professional athletes.  
* Personal trainers managing multiple clients.  
* Fitness clubs or gyms.  
* Medical/rehabilitation programs.  
* Advanced performance analytics users.

---

# **5\. Proposed Solution**

The application provides six primary capabilities:

1. **Exercise Catalogue**  
2. **Workout Plan Management**  
3. **Workout Execution**  
4. **Workout History**  
5. **Progress Tracking**  
6. **Workout Statistics**

The core experience is:

Select/Create Exercises  
        ↓  
Create Workout Plan  
        ↓  
Start Workout  
        ↓  
Execute Workout  
        ↓  
Record Actual Performance  
        ↓  
Complete Workout  
        ↓  
Review History  
        ↓  
Track Progress & Statistics

The application will support both:

### **Rep-based workouts**

Example:

> Bench Press — 3 sets × 10 reps × 50 kg

### **Time-based workouts**

Example:

> Push Ups — 3 × 45 seconds with 15 seconds rest

---

# **6\. Core Value Proposition**

> **A simple way to plan workouts, stay guided while exercising, record actual performance, and see measurable progress over time.**

The product should minimize the amount of interaction required during a workout while maintaining enough information to make historical tracking useful.

### **Core principles**

**Simple**  
Users should be able to start and record a workout without complicated configuration.

**Practical**  
The application should support the actual workout process, not just workout planning.

**Trackable**  
Completed workouts should be preserved and available for comparison.

**Reliable**  
Statistics and personal bests should be calculated consistently from valid workout records.

**Focused**  
The MVP should avoid unrelated fitness features that increase product and technical scope.

---

# **7\. High-Level User Journey**

### **First-time / Setup**

Open App  
   ↓  
Browse Available Exercises  
   ↓  
Create Workout Plan  
   ↓  
Add Exercises  
   ↓  
Configure Targets  
   ↓  
Save Plan

### **Workout**

Open Workout Plan  
   ↓  
Start Workout  
   ↓  
Active Workout  
   ↓  
Perform Exercise  
   ↓  
Record Set / Timer  
   ↓  
Rest  
   ↓  
Next Set / Exercise  
   ↓  
Finish Workout

### **After Workout**

Workout Summary  
   ↓  
Save Workout  
   ↓  
Workout History  
   ↓  
Progress  
   ↓  
Statistics / Personal Bests  
---

# **8\. Key Use Cases**

## **UC-01 — Create Workout Plan**

User creates a named workout plan and adds exercises with target values such as sets, repetitions, weight, duration, and rest.

---

## **UC-02 — Edit Workout Plan**

User modifies an existing plan.

Changes to a plan should not modify previously completed workout records.

---

## **UC-03 — Start Workout**

User selects a saved workout plan and starts an active workout session.

---

## **UC-04 — Execute Rep-Based Exercise**

User performs an exercise and records actual repetitions and weight for each set.

Example:

> Target: 10 × 50 kg  
> Actual: 9 × 50 kg

---

## **UC-05 — Execute Time-Based Exercise**

User performs a duration-based exercise using a simple work/rest timer.

Example:

> 45 seconds work → 15 seconds rest → next set.

---

## **UC-06 — Complete Workout**

User finishes the workout and receives a basic workout summary.

---

## **UC-07 — View Workout History**

User views previously completed workouts and their recorded performance.

---

## **UC-08 — View Exercise Progress**

User selects an exercise and compares historical performance.

Examples:

* Weight  
* Repetitions  
* Volume  
* Duration

---

## **UC-09 — View Statistics**

User views basic training statistics such as:

* Total workouts.  
* Total training volume.  
* Total workout duration.  
* Exercise-level performance.

---

## **UC-10 — View Personal Bests**

User can identify personal best performance based on valid completed workout records.

---

## **UC-11 — Correct Workout Record**

User can edit or delete a previously recorded workout.

Affected statistics and personal-best calculations must be recalculated.

---

# **9\. High-Level Feature Ideas**

### **Exercise Catalogue**

* Predefined exercises.  
* Exercise name.  
* Basic exercise information/category.

### **Workout Plans**

* Create plan.  
* Edit plan.  
* Delete plan.  
* Add/remove exercises.  
* Set targets.  
* Simple workout schedule.

### **Workout Execution**

* Start workout.  
* Active workout screen.  
* Current exercise/set.  
* Record actual performance.  
* Rep-based execution.  
* Time-based execution.  
* Simple rest timer.  
* Pause/resume.  
* Skip set/exercise.  
* Finish workout.

### **Workout Records**

* Completed workout date/time.  
* Actual sets.  
* Actual repetitions.  
* Actual weight.  
* Duration.  
* Completion status.

### **History**

* Chronological workout list.  
* Workout details.  
* Recorded performance.

### **Progress**

* Previous vs current performance.  
* Exercise-level progress.  
* Weight/repetition/volume/duration changes.

### **Statistics**

* Total workouts.  
* Training volume.  
* Workout duration.  
* Exercise-level statistics.  
* Personal bests.

---

# **10\. Business Goals**

### **Primary Goals**

1. Provide a simple and usable workout planning experience.  
2. Allow users to actually execute workouts within the application.  
3. Make workout recording faster and more structured than manual tracking.  
4. Preserve historical workout information.  
5. Provide basic visibility into training progress.  
6. Establish a clean foundation for potential future fitness features.

### **Product Goal**

The MVP should demonstrate that users can complete the full journey:

> **Create → Workout → Record → Review**

without requiring external tools.

---

# **11\. Success Metrics**

For the MVP, success should focus on **usage and completion of the core workflow**, rather than revenue or advanced fitness outcomes.

### **Core Product Metrics**

* Number of workout plans created.  
* Number of workouts started.  
* Number of workouts completed.  
* Workout completion rate.  
* Number of workout sessions recorded.  
* Number of returning users.  
* Number of users viewing workout history.  
* Number of users viewing progress/statistics.

### **Quality Metrics**

* Successful workout-save rate.  
* Workout data-loss/error rate.  
* Statistics calculation accuracy.  
* Crash-free sessions.  
* Successful timer/execution completion.

### **Suggested Primary MVP Metric**

**Completed Workout Sessions per Active User**

This directly measures whether users are actually using the core product rather than simply creating plans.

---

# **12\. Initial Scope — MVP**

The MVP will include:

### **Core Features**

1. Exercise Catalogue  
2. Workout Plan Management  
3. Simple Workout Scheduling  
4. Workout Execution / Active Workout  
5. Rep-Based Workout Tracking  
6. Time-Based Workout Tracking  
7. Rest Timer  
8. Workout Session Management  
9. Workout Recording  
10. Workout Summary  
11. Workout History  
12. Progress Tracking  
13. Workout Statistics  
14. Personal Bests  
15. Workout Record Editing/Deletion  
16. Data Validation

### **Persistence**

Workout data will be stored **locally on the device**.

The MVP will use local persistence and will not require a cloud backend.

---

# **13\. Out of Scope / Future Ideas**

The following are intentionally excluded from the MVP.

### **Cloud & Account Features**

* Firebase/backend.  
* Cloud backup.  
* Multi-device synchronization.  
* Social login.  
* Account management.

### **Advanced Workout Features**

* Supersets.  
* Drop sets.  
* Giant sets.  
* Complex circuit builder.  
* Advanced interval programming.  
* Automatic workout generation.

### **Coaching & Intelligence**

* AI workout generation.  
* AI coaching.  
* Automatic weight recommendations.  
* Progressive overload recommendations.  
* Form analysis.  
* Camera-based rep counting.

### **Health & Fitness Integrations**

* Apple Health.  
* Google Health Connect.  
* Smart watches.  
* Wearables.  
* Heart-rate tracking.  
* Sleep tracking.  
* Calorie tracking.  
* Nutrition management.  
* Body measurements.

### **Social Features**

* Friends.  
* Challenges.  
* Leaderboards.  
* Workout sharing.  
* Likes/comments.

### **Advanced Execution**

* Background workout execution.  
* Lock-screen workout controls.  
* Voice coaching.  
* Music integration.  
* Exercise videos/animations.

These may be evaluated as future product phases if there is demonstrated user demand.

---

# **14\. Assumptions**

The current discovery is based on the following assumptions:

1. The application is primarily a **single-user workout tracker**.  
2. Users can use the application without a cloud account.  
3. Workout data can initially be stored locally.  
4. The predefined exercise catalogue is sufficient for MVP.  
5. Users create their own workout plans.  
6. Workout plans can contain both rep-based and time-based exercises.  
7. Actual workout performance may differ from planned targets.  
8. Historical workout records must remain independent from later plan changes.  
9. Statistics are derived from valid completed workout records.  
10. Invalid or incomplete records should not affect progress calculations.  
11. Users may edit or delete workout records.  
12. Statistics and personal bests must reflect such changes.  
13. Advanced coaching is not required for the initial release.  
14. The application is intended for general fitness tracking and is not a medical application.

---

# **15\. Known Constraints**

### **Product Constraints**

* MVP must remain simple and focused.  
* Workout execution should not become a full-featured fitness coaching system.  
* Only core workout tracking functionality should be included.

### **Technical Constraints**

* Mobile application for iOS and Android.  
* Flutter-based implementation.  
* Local persistence for MVP.  
* No cloud synchronization in initial scope.  
* Workout execution should remain usable without requiring an internet connection.

### **Scope Constraint**

Any feature that introduces significant additional infrastructure, synchronization, external integrations, advanced algorithms, or complex user management should be treated as **future scope** unless explicitly approved.

---

# **16\. Open Questions**

These should be clarified before detailed technical design, but they should **not automatically become new features**.

### **Product**

1. Is user authentication required for MVP?  
2. Should users be allowed to create custom exercises?  
3. Should workout schedules only support weekdays, or specific dates?  
4. Should an incomplete workout be saved automatically?  
5. Can a user resume an unfinished workout?  
6. What exactly qualifies a workout as "completed"?  
7. Can users skip individual exercises?  
8. Should skipped exercises appear in workout history?  
9. Should duration be applicable to every exercise or only time-based exercises?  
10. What exact personal-best definitions should be supported?

### **Workout Execution**

11. Should the rest timer automatically start after completing a set?  
12. Should the next set automatically appear after the rest timer?  
13. Should the timer continue accurately if the app temporarily goes into the background?  
14. Should users be able to finish a workout early and save the partial session?

### **Statistics**

15. What should count toward training volume for time-based exercises?  
16. Which personal-best types are required for MVP?  
17. Should cancelled workouts be retained in history?  
18. Should incomplete workouts contribute to any statistics?

These are **clarification questions**, not invitations to expand the scope.

---

# **17\. MVP Product Boundary**

The product boundary can be summarized as:

               WORKOUT TRACKER  
                      │  
        ┌─────────────┼─────────────┐  
        ▼             ▼             ▼  
      PLAN         EXECUTE        REVIEW  
        │             │             │  
        ▼             ▼             ▼  
   Create Plan    Active Workout   History  
   Add Exercises  Record Sets      Progress  
   Set Targets    Rest Timer       Statistics  
   Schedule       Work Timer       Personal Bests  
                  Complete  
                      │  
                      ▼  
                  LOCAL DATA  
                     DRIFT

### **Product principle**

> **Keep the MVP focused on the complete core workout lifecycle without introducing advanced fitness, social, health, cloud, or coaching functionality.**

This discovery document should serve as the **business/product baseline**. The next documents can then progressively add requirements without changing this core boundary.

