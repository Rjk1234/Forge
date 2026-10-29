# **\#Forge-US-9**

# **1\. User Story Identification**

* **Story ID:** US-SCR09  
* **Title:** Create / Edit Workout Plan  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 8

# **2\. User Story Statement**

As a user with the app unlocked, I want to create or edit a workout plan by defining its name, exercises, and exercise targets so that I can maintain a workout plan for future workouts.

# **3\. Description / Context**

SCR-09 is the Create / Edit Workout Plan screen within the Workout Plan Management flow.

The screen supports two modes:

* **Create mode:** A new workout plan starts with a blank name and empty exercise list.  
* **Edit mode:** An existing workout plan is loaded with its current data pre-filled.

The user can define the plan name, add exercises through SCR-07, and configure per-exercise targets. Every exercise in the catalogue carries a **type flag** — `weighted` (reps + weight), `time-based` (duration only), or `bodyweight` (reps only, no weight field) — and the target-entry fields shown for that exercise are driven by this flag rather than a single generic reps+weight+duration form. Duration for `time-based` exercises is entered and displayed as **mm:ss** (stored internally as seconds).

The screen also handles validation, save processing, save failures, and attempts to leave with unsaved changes.

*(Product-owner clarification, 2026-09-05 — see changelog: the app is fully offline/local-only. There is no network connectivity to lose and no "authenticated session" beyond the static local login state; save failures below refer to a local on-device Drift database write failure, not a network/API failure.)*

# **4\. Functional Requirements**

* **FR-1** — In create mode, the system shall display a blank plan name field, an empty exercise list, and an **"Add exercise"** action. **(UC-SCR09-01, SRS-FR-9)**  
* **FR-2** — In edit mode, the system shall pre-fill the workout plan fields with the existing plan data. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4)**  
* **FR-3** — The user shall be able to add exercises to the in-progress workout plan through the Exercise Catalogue. **(UC-SCR09-01, SRS-FR-9)**  
* **FR-4** — The workout plan shall support per-exercise targets (sets, rest, and either reps+weight, duration, or reps-only) determined by that exercise's type flag (`weighted` / `time-based` / `bodyweight`), as defined by the screen content. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4; updated per Decisions Log §5, 2026-09-05)**  
* **FR-4a** — For a `weighted` exercise, the system shall display reps and weight fields (no duration field). For a `time-based` exercise, the system shall display a duration field only (mm:ss; no reps/weight fields). For a `bodyweight` exercise, the system shall display a reps field only (no weight field). **(Decisions Log §5)**  
* **FR-5** — The system shall block saving when the plan name is blank or contains only whitespace and shall display an inline validation error. **(UC-SCR09-03, SRS-FR-10, SDS-DATA-8)**  
* **FR-6** — The system shall reject an invalid exercise reference and prevent the workout plan from being saved with that invalid reference. **(UC-SCR09-04, SRS-FR-48, SDS-DATA-8)**  
* **FR-7** — The system shall prevent a set or rep value from being saved when a required value is non-positive and shall display an inline field error. **(UC-SCR09-05, SRS-FR-49, SDS-ERR-7)**  
* **FR-8** — For a `weighted` exercise, the system shall prevent a weight value that is not strictly positive from being saved and shall display an inline field error. **(UC-SCR09-06, SRS-FR-50, SDS-ERR-7; updated per Decisions Log §5 — 0 is not a valid weight, and bodyweight/time-based exercises have no weight field to validate)**  
* **FR-9** — For a `time-based` exercise, the duration field shall be entered and displayed as **mm:ss** and stored internally as seconds; the system shall prevent a non-positive duration from being saved and shall display an inline field error. **(UC-SCR09-07, SRS-FR-51, SDS-ERR-7; updated per Decisions Log §5)**  
* **FR-10** — When a valid workout plan is saved successfully, the system shall route the user to SCR-10 with the updated plan data. **(UC-SCR09-09, SRS-FR-9, SRS-FR-13, SDS-COMP-5)**

# **5\. Non-Functional Requirements**

* **NFR-1** — While a workout plan save operation is in progress, the save action shall display a loading state. **(UC-SCR09-08, SDS-IF-4; SRS-NFR not specified in Inventory)**  
* **NFR-2** — If the workout plan cannot be saved because the underlying write operation fails, the system shall not represent the plan as successfully saved and shall provide a retry path. **(UC-SCR09-10, SDS-ERR-6; SRS-NFR not specified in Inventory)**  
* **NFR-3** — If the local (Drift) write fails for the current attempt, the system shall preserve the in-progress edits in memory rather than silently discarding them. **(UC-SCR09-11, SDS-ERR-6; updated per Decisions Log §0, 2026-09-05 — there is no network/connectivity condition to distinguish; this is a local-storage-write-failure case only)**  
* **NFR-4** — When the user attempts to leave the screen with unsaved changes, the system shall require explicit confirmation before discarding those changes. **(UC-SCR09-12, BR-NFR-015; SRS-NFR/SDS-NFR not specified in Inventory)**

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Create / Edit Workout Plan screen shall require the app's local login state to be unlocked. **(UC-SCR09-01, UC-SCR09-02, SRS-FR-9, SRS-FR-13; updated 2026-09-05 — replaces "authenticated user session")**  
* **SR-2** — Workout plan data displayed in edit mode shall correspond to the workout plan being edited. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4; updated 2026-09-05 — drops "authenticated," since there is a single local user)**  
* **SR-3** — Invalid exercise references shall not be accepted as valid workout-plan data. **(UC-SCR09-04, SRS-FR-48, SDS-DATA-8)**

# **7\. UI / Component Specifications**

### **Plan Name Field**

* **Component type:** Text field  
* **Input type:** Text  
* **Validation rules:** Cannot be blank or whitespace-only when saving  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required for successful save

### **Exercise List**

* **Component type:** Exercise list  
* **Input type:** Selected exercises  
* **Validation rules:** Exercise references must be valid  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory for invalid exercise reference  
* **Mandatory / Optional:** Not explicitly specified in Inventory

### **Add Exercise Action**

* **Component type:** Action  
* **Input type:** User selection/tap  
* **Validation rules:** Selected exercise must be valid  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Available in create mode

### **Per-Exercise Target Fields**

* **Component type:** Target input fields, rendered conditionally on the exercise's type flag  
* **Input type:**  
  * `weighted` — sets, reps, weight (numeric), rest.  
  * `time-based` — sets, duration (mm:ss text/picker input; stored as seconds), rest — no reps/weight field shown.  
  * `bodyweight` — sets, reps (numeric), rest — no weight field shown.  
* **Validation rules:**  
  * Required sets/reps must be strictly positive.  
  * Weight (weighted only) must be strictly positive (0 is not a valid weight).  
  * Duration (time-based only) must be strictly positive; entered/displayed as mm:ss.  
* **Min / Max constraints:** Exact numerical maximums are not specified in Inventory  
* **Error messages:** Inline field error; exact error copy not specified in Inventory  
* **Mandatory / Optional:** Sets and the type-appropriate reps/weight/duration field are required; other field requirements are not fully specified in Inventory  
* *(Updated per Decisions Log §5, 2026-09-05 — replaces the prior single generic reps+weight+duration form for every exercise.)*

### **Save Action**

* **Component type:** Save action  
* **Input type:** User action  
* **Validation rules:** Save is blocked when defined validation conditions fail  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required action for persisting create/edit changes

### **Loading State**

* **Component type:** Loading state  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Displayed during save

### **Error State**

* **Component type:** Error state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Displayed when save fails

### **Local Save-Failure State**

* **Component type:** Error/retry state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Displayed when the local (Drift) write fails  
* *(Renamed from "Offline State" per Decisions Log §0, 2026-09-05 — the app has no network connectivity to lose; this state now covers a local on-device storage write failure only.)*

### **Discard Changes Confirmation**

* **Component type:** Confirmation  
* **Input type:** Confirmation/cancel action  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Required when leaving with unsaved changes

# **8\. Acceptance Criteria**

### **AC-1 — Create Mode**

**Given** the user opens SCR-09 in create mode,  
**When** the screen is displayed,  
**Then** the system shall show a blank plan name field, an empty exercise list, and an **"Add exercise"** action.  
**(UC-SCR09-01)**

### **AC-2 — Edit Mode**

**Given** the user opens SCR-09 in edit mode for an existing plan,  
**When** the existing plan data is loaded,  
**Then** the system shall pre-fill the fields with the current plan data.  
**(UC-SCR09-02)**

### **AC-3 — Save Workout Plan**

**Given** the workout plan contains valid required information,  
**When** the user submits the save action,  
**Then** the system shall save the plan and route the user to SCR-10 with the updated data.  
**(UC-SCR09-09)**

### **AC-4 — Leave With Unsaved Changes**

**Given** the user has unsaved changes on SCR-09,  
**When** the user attempts to leave the screen,  
**Then** the system shall display a discard-changes confirmation.  
**(UC-SCR09-12)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Blank or Whitespace-Only Plan Name**

**Given** the user is saving a workout plan,  
**When** the plan name is blank or contains only whitespace,  
**Then** the system shall display an inline validation error and block the save.  
**(UC-SCR09-03)**

### **EC-2 — Invalid Exercise Reference**

**Given** the workout plan contains an exercise reference that is invalid or unavailable,  
**When** the user attempts to save the plan,  
**Then** the invalid item shall be flagged/rejected and the plan shall not be saved.  
**(UC-SCR09-04)**

### **EC-3 — Non-Positive Sets/Reps**

**Given** the user enters a sets or reps value where a required value is expected,  
**When** the entered value is non-positive,  
**Then** the system shall display an inline field error and prevent the invalid value from being used to complete the plan.  
**(UC-SCR09-05)**

### **EC-4 — Non-Positive Weight (weighted exercises only)**

**Given** the user enters a weight value for a `weighted`-type exercise,  
**When** the value is zero or negative,  
**Then** the system shall display an inline field error.  
**(UC-SCR09-06; updated per Decisions Log §5 — weight is strictly positive, and this field does not appear at all for `time-based`/`bodyweight` exercises)**

### **EC-5 — Non-Positive Duration (time-based exercises only)**

**Given** the user enters a duration value (mm:ss) for a `time-based`-type exercise,  
**When** the value is zero or negative,  
**Then** the system shall display an inline field error.  
**(UC-SCR09-07; updated per Decisions Log §5)**

### **EC-6 — Save Loading State**

**Given** the user has submitted a valid workout plan for saving,  
**When** the save operation is in progress,  
**Then** the save action shall show its loading state.  
**(UC-SCR09-08)**

### **EC-7 — Save Failure**

**Given** the user has submitted a workout plan for saving,  
**When** the save operation fails,  
**Then** the system shall display an error state, shall not represent the plan as saved, and shall provide a retry action without creating a duplicate record.  
**(UC-SCR09-10)**

### **EC-8 — Local Save Failure**

**Given** the user has entered or modified workout plan information,  
**When** the local (Drift) write fails at save,  
**Then** the system shall display the local save-failure state and preserve the in-progress edits in memory for the retry attempt.  
**(UC-SCR09-11; updated per Decisions Log §0, 2026-09-05 — no network/offline condition applies)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-08 — Workout Plans List.  
  * SCR-10 — Plan Detail.  
* **Screen exit dependencies:**  
  * SCR-10 — Plan Detail on successful save.  
  * SCR-08 — Workout Plans List on cancel/back.  
  * SCR-07 — Exercise Catalogue for adding exercises.  
* **\[ASSUMPTION\] flag:**  
  None specified for SCR-09.  
* **Underspecified behavior:**  
  * Exact maximum constraints for plan name, sets, reps, weight, duration, and rest are not specified in the Inventory — confirm with SRS/SDS owner.  
  * Exact inline validation error messages are not specified for the plan name, invalid exercise, sets/reps, weight, or duration — confirm with SRS/SDS owner.  
  * The Inventory does not explicitly define whether an exercise list must contain at least one exercise before a plan can be saved — confirm with SRS/SDS owner.  
  * The exact behavior of the discard-changes confirmation's confirm and cancel actions is not fully specified beyond requiring confirmation — confirm with SRS/SDS owner.  
  * The Inventory specifies save loading behavior but does not provide an underlying SRS-NFR/SDS-NFR ID for this state; the cited design trace is SDS-IF-4.  
  * In-memory edit preservation on local write failure is retained for the current attempt only; there is no network/offline condition to distinguish (Decisions Log §0).  
  * Exercise catalogue entries and their type flags (`weighted`/`time-based`/`bodyweight`) are fixed, developer-seeded content (Decisions Log §7) — SCR-09 consumes this flag but does not let the user create or edit catalogue exercises.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| BR-FR-003 / relevant BRD trace | SRS-FR-9 | SDS-COMP-5, SDS-IF-4, SDS-DATA-4 | UC-SCR09-01 | FR-1, FR-3, AC-1 |
| Relevant BRD trace | SRS-FR-13 | SDS-DATA-4 | UC-SCR09-02 | FR-2, FR-4, SR-2, AC-2 |
| Relevant BRD trace | SRS-FR-10 | SDS-DATA-8 | UC-SCR09-03 | FR-5, EC-1 |
| Relevant BRD trace | SRS-FR-48 | SDS-DATA-8 | UC-SCR09-04 | FR-6, SR-3, EC-2 |
| BR-FR-043 / relevant BRD trace | SRS-FR-49 | SDS-ERR-7 | UC-SCR09-05 | FR-7, EC-3 |
| BR-FR-044 / relevant BRD trace | SRS-FR-50 | SDS-ERR-7 | UC-SCR09-06 | FR-8, EC-4 |
| BR-FR-045 / relevant BRD trace | SRS-FR-51 | SDS-ERR-7 | UC-SCR09-07 | FR-9, EC-5 |
| Not specified in Inventory | — | SDS-IF-4 | UC-SCR09-08 | NFR-1, EC-6 |
| Relevant BRD trace | SRS-FR-9, SRS-FR-13 | SDS-COMP-5 | UC-SCR09-09 | FR-10, AC-3 |
| Not specified in Inventory | — | SDS-ERR-6 | UC-SCR09-10 | NFR-2, EC-7 |
| BR-NFR-020 | — | SDS-ERR-6 | UC-SCR09-11 | NFR-3, EC-8 |
| BR-NFR-015 | — | — | UC-SCR09-12 | NFR-4, AC-4 |

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering six states/moments from this story: Edit Mode — Populated (§8 AC-2, showing all three exercise-type field layouts per FR-4a), Create Mode — Blank (§8 AC-1), Inline Validation Errors (§9 EC-1/EC-3/EC-5 — blank name, non-positive reps/weight, non-positive duration), Save — Loading (§8/§9 EC-6), Local Save Failure — Retry (§9 EC-7/EC-8, in-progress edits shown preserved per NFR-3), and Discard Changes Confirmation (§8 AC-4/NFR-4).  
* **Tool:** Claude Design canvas (not Figma) — six artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/e721de73-e7db-431b-99f7-ea8df4e2216b](https://claude.ai/code/artifact/e721de73-e7db-431b-99f7-ea8df4e2216b)  
* **Artifact title:** "ForgeApp Create Edit Plan" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Edit Mode — Populated), CreateMode.dc.html (Create Mode — Blank), ValidationErrors.dc.html (Inline Validation Errors), SavingLoading.dc.html (Save — Loading), SaveFailure.dc.html (Local Save Failure — Retry), DiscardConfirm.dc.html (Discard Changes Confirmation).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06/07/08 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, cyan for the `weighted` type dot.  
* **Scope note:** the Edit Mode artboard deliberately includes one exercise of each type flag (Barbell Bench Press = weighted: sets/reps/weight/rest; Plank = time-based: sets/duration mm:ss/rest, no reps/weight; Push-Up = bodyweight: sets/reps/rest, no weight) to make FR-4a's conditional-field rule visible in one screen, per Decisions Log §5. Field maximums, exact error copy, and the discard dialog's precise button behavior are not specified in the Inventory (§10) — the copy shown here is illustrative only and should be confirmed with the SRS/SDS owner before being treated as final.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

