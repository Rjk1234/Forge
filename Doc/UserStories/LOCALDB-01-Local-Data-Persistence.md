# **User Story — Local Data Persistence**

## **1\. User Story Identification**

* **Story ID:** US-LOCALDB-01  
* **Title:** Local Storage for Workout Plans and Workout Records  
* **Epic / Feature:** Local Data Persistence  
* **Priority:** High  
* **Story Points:** Not specified

## **2\. User Story Statement**

As a user, I want my workout plans and completed workout records to be stored locally on my device so that my workout history, progress, and statistics can be generated from my recorded workout data.

## **3\. Description / Context**

The Workout Tracker shall maintain local application data using a local database.

The local database shall store:

* Workout plans created by the user.  
* Workout records created from workouts performed by the user on each day.

The locally stored workout data shall be available to the application's History, Progress, and Statistics features.

Local persistence shall support the application's core workout-tracking lifecycle:

**Create Plan → Store Plan → Perform Workout → Store Workout Record → Read Historical Data → Calculate Progress / Statistics**

The local database is intended to provide persistent storage for workout-related data on the user's device.

## **4\. Functional Requirements**

* **FR-1** — The application shall persist each workout plan created by the user in the local database.  
* **FR-2** — The application shall persist the workout plan information required to reconstruct the user's saved workout plan.  
* **FR-3** — The application shall persist each completed workout record for each day on which the user performs a workout.  
* **FR-4** — Each persisted workout record shall retain the actual workout performance data required by the application, including the recorded exercise/set performance information.  
* **FR-5** — The application shall retain previously persisted workout records so that historical workout data remains available after subsequent workouts are performed.  
* **FR-6** — The application shall make persisted workout records available to the Workout History feature.  
* **FR-7** — The application shall make persisted valid workout records available to the Progress feature for progress comparison.  
* **FR-8** — The application shall make persisted valid workout records available to the Statistics feature for statistical calculations.  
* **FR-9** — The application shall persist a workout record only for a session that meets the completion criterion (Decisions Log §1: at least one set of at least one exercise logged, plus an explicit Finish). A cancelled session, or a Finish with zero sets logged, is discarded entirely (Decisions Log §2) and is never written to local storage in the first place — there is no separate "incomplete" record to filter out downstream, and History/Progress/Statistics never need to distinguish completed from incomplete records because every persisted record is, by definition, completed. **(Updated 2026-09-05 — replaces the prior "distinguish completed from cancelled/incomplete records" framing, which implied incomplete sessions were persisted and then filtered.)**  
* **FR-10** — The application shall preserve historical workout performance data independently of subsequent changes to the associated workout plan.  
* **FR-11** — When a workout plan is edited, the updated plan data shall be persisted as the current workout plan without modifying previously recorded workout performance data.  
* **FR-12** — When a workout plan is deleted, previously recorded workout history associated with that plan shall remain available.

## **5\. Non-Functional Requirements**

* **NFR-1** — Local workout data shall persist between application launches.  
* **NFR-2** — Local workout data shall be retrievable by the application without requiring a network connection.  
* **NFR-3** — Local persistence operations shall not cause the application to lose previously persisted workout plans or completed workout records when an individual subsequent operation fails.  
* **NFR-4** — The local persistence mechanism shall support the volume of workout plans and daily workout records expected during normal MVP usage without imposing an artificial record-count limitation.  
* **NFR-5** — Local data access required by History, Progress, and Statistics shall return the persisted workout data consistently so that those features operate against the same underlying workout records.

## **6\. Security & Privacy Requirements**

* **SEC-1** — Workout plans and workout records stored locally shall belong to the user whose application data is being accessed.  
* **SEC-2** — The application shall not expose locally persisted workout data belonging to another user.  
* **SEC-3** — When application user data is cleared as part of an explicitly supported account-data removal operation, locally persisted workout plans and workout records shall not remain accessible through the application.

## **7\. UI / Component Specifications**

This story defines a persistence capability rather than a dedicated user-facing screen.

### **Workout Plan Data**

* **Component type:** Local persisted data entity  
* **Input type:** Workout plan data supplied through the Workout Plan Management flow  
* **Validation rules:** Existing workout-plan validation rules apply before persistence  
* **Min / Max constraints:** As defined by the Workout Plan Management requirements  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Workout plan data required for persistence is mandatory

### **Workout Record Data**

* **Component type:** Local persisted workout record  
* **Input type:** Actual workout performance captured during workout execution  
* **Validation rules:** Existing workout execution and completion rules apply  
* **Min / Max constraints:** As defined by workout execution requirements  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Completed workout record is mandatory when a workout is successfully completed

### **History / Progress / Statistics Data Consumption**

* **Component type:** Local data read source  
* **Input type:** Persisted workout records  
* **Validation rules:** Valid/completed workout records shall be used according to the requirements of each consuming feature  
* **Min / Max constraints:** Not specified  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Required for History, Progress, and Statistics functionality

## **8\. Acceptance Criteria**

### **AC-1 — Workout Plan Persistence**

**Given** the user creates a valid workout plan  
**When** the workout plan is saved  
**Then** the workout plan shall be persisted in the local database and shall remain available after the application is closed and reopened.

### **AC-2 — Workout Plan Retrieval**

**Given** a workout plan has previously been persisted  
**When** the user accesses the workout plan management feature  
**Then** the previously saved workout plan shall be available as the user's current workout plan data.

### **AC-3 — Daily Workout Record Persistence**

**Given** the user completes a workout  
**When** the completed workout is saved  
**Then** a workout record for that completed workout shall be persisted locally with its recorded performance data.

### **AC-4 — Historical Record Retention**

**Given** the user has completed workouts on multiple days  
**When** the user accesses workout history  
**Then** the previously persisted completed workout records shall remain available as historical records.

### **AC-5 — History Data Consumption**

**Given** completed workout records exist in local storage  
**When** the user opens the Workout History feature  
**Then** the feature shall retrieve and display the applicable persisted workout records.

### **AC-6 — Progress Data Consumption**

**Given** sufficient valid completed workout records exist in local storage  
**When** the user opens the Progress feature  
**Then** the feature shall use the persisted valid workout records for progress comparison.

### **AC-7 — Statistics Data Consumption**

**Given** valid completed workout records exist in local storage  
**When** the user opens the Statistics feature  
**Then** the feature shall use the persisted valid workout records for statistical calculations.

### **AC-8 — Plan Modification Does Not Alter History**

**Given** a workout plan has previously been used to complete a workout  
**When** the user subsequently edits that workout plan  
**Then** the previously persisted workout record shall retain the actual performance data recorded when the workout was completed.

### **AC-9 — Plan Deletion Does Not Delete History**

**Given** completed workout records exist for a workout plan  
**When** the user deletes that workout plan  
**Then** the previously recorded workout history shall remain available.

### **AC-10 — Cancelled or Zero-Set Workout Is Never Persisted**

**Given** the user starts a workout but cancels it, or taps Finish with zero sets logged,  
**When** the session ends  
**Then** the application shall discard it entirely and shall not write any record to local storage — nothing appears in History, Progress, or Statistics.  
**(Updated 2026-09-05 per Decisions Log §2 — replaces "not treated as a valid completed workout record," which implied a record was still saved and then excluded.)**

## **9\. Edge Cases & Error Scenarios**

### **Edge-1 — Local Persistence Failure**

**Given** the application attempts to persist a workout plan or completed workout record  
**When** the local persistence operation fails  
**Then** the application shall not represent the data as successfully persisted.

**Error handling/message:** Not specified — confirm with Product/SDS owner.

### **Edge-2 — Existing Data Preservation**

**Given** previously persisted workout plans or workout records exist  
**When** a subsequent local persistence operation fails  
**Then** previously persisted data shall remain unaffected.

### **Edge-3 — Application Restart**

**Given** workout plans and completed workout records have already been persisted  
**When** the application is terminated and subsequently launched again  
**Then** the persisted data shall remain available to the application.

### ~~Edge-4 — Incomplete Workout~~ — REMOVED/REWORDED, 2026-09-05

**Given** a workout session does not meet the completion criterion (Decisions Log §1),  
**When** the session ends (cancelled, or Finish tapped with zero sets logged),  
**Then** the application shall discard it entirely and write nothing to local storage. There is no "incomplete" record produced, stored, or later filtered — per Decisions Log §2, this is the same outcome as Cancel.

## **10\. Dependencies & Notes**

* **Implementation technology:** Drift (typed SQLite) shall be used as the local database for this capability. Data is held in relational tables (user profile, exercises, workout plans and their ordered plan exercises, schedule entries, workout sessions with their ordered session exercises and actual sets) in a single database file on the device, with foreign keys enabled. Plan-exercise rows cascade-delete with their plan; session history rows carry a plan snapshot and have no foreign key to plans, so deleting a plan never touches history. Multi-table writes (saving a plan, saving a completed session, replacing the seeded exercise catalogue) run inside a single database transaction so a failed write leaves previously persisted data unchanged.  
* **Primary data persisted:**  
  * Workout Plans  
  * Completed Workout Records  
* **Primary consumers:**  
  * SCR-20 — Workout History List  
  * SCR-21 — Workout History Detail  
  * SCR-22 — Progress Comparison  
  * SCR-23 — Statistics Dashboard  
  * SCR-24 — Personal Bests  
* **Related existing flows:**  
  * Workout Plan Management (SCR-08–SCR-11) creates and modifies workout-plan data.  
  * Workout Execution (SCR-15–SCR-19) creates completed workout records.  
  * Workout History (SCR-20–SCR-21) reads workout records.  
  * Progress (SCR-22) reads valid completed workout records.  
  * Statistics (SCR-23–SCR-24) reads valid completed workout records.  
* **Architecture status — CONFIRMED, 2026-09-05 (Decisions Log §0):** Drift is the sole persistence layer for the entire application, not just workout-related data — there is no Firebase, no Firestore, no cloud backend, and no network calls anywhere. The SDS/SRS/BRD documents shall treat Drift as the persistence layer for all application data rather than as workout-data-specific.  
* **Data synchronization:** Not specified. This story defines local persistence only and does not introduce cloud synchronization.  
* **Backup / restore:** Not specified.  
* **Data migration/versioning:** Not specified.  
* **Local database encryption:** Not specified.  
* **Retention/deletion policy:** Not specified beyond the requirement that deleting a workout plan does not delete its historical workout records.  
* **Important design decision:** Historical workout records must represent the actual workout performed at the time of completion rather than dynamically reflecting later changes to the workout plan.  
* **Traceability:** This is a **new Level-4 user story introduced from the requested architecture change**. Existing BRD → SRS → SDS → Inventory traceability IDs for local persistence are not currently present in the supplied Inventory. The upstream documents should be amended to establish the corresponding requirement IDs before assigning formal BRD/SRS/SDS traceability IDs to this story.

