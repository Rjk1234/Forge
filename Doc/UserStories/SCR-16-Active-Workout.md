# **\#Forge-US-16**

# **1\. User Story Identification**

* **Story ID:** US-SCR16  
* **Title:** Active Workout — Exercise & Set Logging  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 8

# **2\. User Story Statement**

**As a user with the app unlocked, I want to perform a workout and record my actual exercise and set performance against the planned targets, so that my completed workout can accurately reflect what I actually performed.**

# **3\. Description / Context**

SCR-16 is the core workout execution screen. It allows the user to work through the exercises and sets defined by the selected workout plan while recording actual performance.

The screen supports active workout progression, validation of actual performance values, skipping applicable items, pausing applicable activity, cancellation, and completion. Execution state is held locally during the active session and is not persisted per action.

**Completion criterion (Decisions Log §1, confirmed 2026-09-05):** a workout session counts as completed as soon as the user has logged at least one set of at least one exercise, **and** then explicitly finishes the session (taps Finish/Done). This is a deliberately low bar. Zero sets logged plus Finish does not count as a real attempt and is treated the same as Cancel (discarded, see below).

**Cancel behavior (Decisions Log §2, confirmed 2026-09-05):** if the user cancels or exits the active workout at any point before tapping Finish, the session is discarded entirely, regardless of how much was logged. Nothing is saved and nothing appears in history. There is no "Incomplete" state and no "Save as Incomplete vs. Discard" prompt — cancel always means discard. Consequently history, stats, and progress logic never need to handle an "incomplete session" case: every record that exists is, by definition, a completed one.

The app is fully offline/local-only (Decisions Log §0); there is no network connectivity to lose and no server-side persistence step. All execution state and the final completed record are written to the local on-device Drift database only.

**App-backgrounded timer behavior — DEFERRED, open (Decisions Log §6b).** Whether the rest/execution timer should pause-and-resume, catch up to wall-clock time, or end the session when the app is backgrounded is **not decided**. This is intentionally left open pending a future product-owner brainstorming session; no specific behavior should be assumed or built against yet.

# **4\. Functional Requirements**

* **FR-1** — When a workout begins, the system shall display the first exercise/set and set the execution state to **ACTIVE**. **(UC-SCR16-01, SRS-FR-25)**  
* **FR-2** — The system shall prevent a set from being marked complete when non-positive reps/sets are entered and shall display an inline validation error. **(UC-SCR16-02, SRS-FR-49)**  
* **FR-3** — The system shall display an inline validation error when a negative weight is entered. **(UC-SCR16-03, SRS-FR-50)**  
* **FR-4** — The system shall display an inline validation error when a negative duration is entered. **(UC-SCR16-04, SRS-FR-51)**  
* **FR-5** — When a set or exercise is marked complete with valid actual performance data, the system shall advance progress to the next set or exercise. **(UC-SCR16-05, SRS-FR-28)**  
* **FR-6** — When the user skips an applicable item, the system shall mark the item as skipped and exclude it appropriately from completion/valid-record logic. **(UC-SCR16-06, SRS-FR-29)**  
* **FR-7** — When the user pauses applicable activity, the system shall set the execution state to **PAUSED** and hold the timer state locally. **(UC-SCR16-07, SRS-FR-29)**  
* **FR-8** — If the user taps **Cancel**, the system shall route the user to SCR-18 for cancellation confirmation; confirming Cancel shall discard the entire in-progress session with no partial/"Incomplete" save. **(UC-SCR16-10, SDS-COMP-7; updated per Decisions Log §2, 2026-09-05)**  
* **FR-9** — When the user taps Finish/Done, the system shall treat the session as completed only if at least one set of at least one exercise has been logged, write the completed record to local storage, and route the user to SCR-19. If Finish is tapped with zero sets logged, the system shall treat it the same as Cancel (discard, no history record). **(UC-SCR16-11, SRS-FR-32; updated per Decisions Log §1, 2026-09-05 — replaces "last applicable item completed" with the confirmed low-bar completion criterion)**

# **5\. Non-Functional Requirements**

* **NFR-1** — Workout execution and timer state shall continue to function using local in-memory execution state while the active workout is in progress. **(UC-SCR16-07, SRS-FR-29, SDS-COMP-7)**  
* **NFR-2** — The system shall not treat an interrupted in-progress workout as a completed historical record after the application is killed or crashes (no Finish was tapped, so per Decisions Log §2 it is discarded like a cancel). Whether an app-**backgrounded** (not killed) timer pauses, catches up, or ends the session is **DEFERRED/open — Decisions Log §6b**; no specific behavior is specified here. **(UC-SCR16-08, SRS-NFR-6, SDS-ERR-8; updated 2026-09-05)**  
* **NFR-3** — Previously completed workout sessions shall remain unaffected when an in-progress workout is interrupted. **(UC-SCR16-08, SRS-NFR-6, SDS-ERR-8)**  
* ~~**NFR-4** — connectivity-lost persistence~~ — **REMOVED, 2026-09-05.** The app is fully offline/local-only (Decisions Log §0); there is no connectivity to lose and no server-side persistence step. UC-SCR16-09 no longer applies.

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the active workout screen shall require the app's static local login state to be unlocked (Decisions Log §0 — this is not real authentication; there is only one local user). **(UC-SCR16-01, SRS-FR-25)**  
* **SEC-2** — The active workout operates against the single local user's data only; there is no multi-user/cross-user access concern in a single-local-user app. **(UC-SCR16-01, SRS-FR-25, SDS-COMP-7)**

# **7\. UI / Component Specifications**

### **Current Exercise**

* **Component type:** Current exercise display  
* **Input type:** Workout plan/execution data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Target vs. Actual Entry Fields — Reps**

* **Component type:** Numeric input field  
* **Input type:** Reps  
* **Validation rules:** Non-positive values are invalid where required  
* **Min / Max constraints:** Minimum valid value is greater than zero; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Target vs. Actual Entry Fields — Weight**

* **Component type:** Numeric input field  
* **Input type:** Weight  
* **Validation rules:** Negative values are invalid  
* **Min / Max constraints:** Negative values not permitted; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Target vs. Actual Entry Fields — Duration**

* **Component type:** Numeric input field  
* **Input type:** Duration  
* **Validation rules:** Negative values are invalid  
* **Min / Max constraints:** Negative values not permitted; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Set Progress**

* **Component type:** Set progress indicator  
* **Input type:** Workout execution state  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Pause Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Applicable activity must be active  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable

### **Skip Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Applicable item must be skippable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable

### **Complete Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Required performance values must be valid  
* **Min / Max constraints:** Defined by the applicable validation rules above  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory for completion of an applicable item

### **Cancel Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

# **8\. Acceptance Criteria**

### **AC-1 — Workout Begins**

**(UC-SCR16-01)**

**Given** the user has successfully started a workout from SCR-15,  
**When** SCR-16 is opened,  
**Then** the system shall display the first exercise/set and set the execution state to **ACTIVE**.

### **AC-2 — Valid Set/Exercise Completion**

**(UC-SCR16-05)**

**Given** the current set/exercise contains valid actual performance data,  
**When** the user marks the set/exercise as complete,  
**Then** the system shall advance progress to the next set or exercise.

### **AC-3 — Skip Applicable Item**

**(UC-SCR16-06)**

**Given** the current item is applicable for skipping,  
**When** the user skips it,  
**Then** the system shall mark the item as skipped and exclude it appropriately from completion/valid-record logic.

### **AC-4 — Pause Activity**

**(UC-SCR16-07)**

**Given** an applicable activity is currently active,  
**When** the user pauses it,  
**Then** the execution state shall become **PAUSED** and the timer state shall be held locally.

### **AC-5 — Cancel Navigation and Discard**

**(UC-SCR16-10)**

**Given** the user is on the active workout screen,  
**When** the user taps **Cancel** and confirms on SCR-18,  
**Then** the system shall discard the entire in-progress session (no partial/"Incomplete" save) and shall not add anything to workout history.  
**(Updated per Decisions Log §2, 2026-09-05.)**

### **AC-6 — Finish With At Least One Logged Set**

**(UC-SCR16-11)**

**Given** the user has logged at least one set of at least one exercise,  
**When** the user taps Finish/Done,  
**Then** the system shall save the completed record to local storage and route the user to SCR-19.  
**(Updated per Decisions Log §1, 2026-09-05 — replaces "last applicable item completed"; the user need not complete every planned item for the session to count.)**

### **AC-6a — Finish With Zero Logged Sets**

**Given** the user has logged zero sets,  
**When** the user taps Finish/Done,  
**Then** the system shall treat this the same as Cancel: discard the session, save nothing, and add nothing to history.  
**(Decisions Log §1.)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Non-Positive Reps/Sets**

**(UC-SCR16-02)**

**Given** the user enters a non-positive reps/sets value where required,  
**When** the user attempts to mark the set complete,  
**Then** the system shall display an inline validation error and shall not allow the set to be marked complete.

### **EC-2 — Negative Weight**

**(UC-SCR16-03)**

**Given** the user enters a negative weight,  
**When** the value is validated,  
**Then** the system shall display an inline validation error.

### **EC-3 — Negative Duration**

**(UC-SCR16-04)**

**Given** the user enters a negative duration,  
**When** the value is validated,  
**Then** the system shall display an inline validation error.

### **EC-4 — Interrupted Workout (killed / crashed)**

**(UC-SCR16-08)**

**Given** a workout is in progress,  
**When** the application is killed or crashes before Finish is tapped,  
**Then** the in-progress session shall not be treated as a completed historical record (per Decisions Log §2, no Finish means discard), and previously completed sessions shall remain unaffected.

### **EC-4a — App Backgrounded (not killed) — DEFERRED**

**Given** a workout is in progress,  
**When** the application is backgrounded,  
**Then** the specific timer/session behavior (pause-and-resume vs. wall-clock catch-up vs. ending the session) is **DEFERRED/open — Decisions Log §6b**; this behavior is intentionally not specified pending a future product-owner decision.

### ~~EC-5 — Connectivity Lost During Workout~~ — REMOVED, 2026-09-05

The app is fully offline/local-only (Decisions Log §0); there is no connectivity condition. UC-SCR16-09 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependency:**  
  * SCR-15 — Workout Pre-Start / Overview  
* **Screen exit dependencies:**  
  * SCR-17 — Rest Timer  
  * SCR-18 — Cancel Workout Confirmation  
  * SCR-19 — Workout Summary (Complete)  
* **\[ASSUMPTION\] flag:** None specified for SCR-16.  
* **Design note carried forward from Inventory:** Timer/execution state is held in local application memory and is not persisted per action.  
* **Underspecified behavior:**  
  * Exact inline validation error messages are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact definition of which items are "applicable" for Skip/Pause is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact UI presentation of the execution state **ACTIVE** and **PAUSED** is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * ~~Exact wording and UI treatment for the connectivity condition at finish~~ — not applicable; removed per Decisions Log §0 (no connectivity condition).  
  * App-backgrounded timer behavior remains **DEFERRED/open** per Decisions Log §6b — do not design a specific behavior for it yet.  
* **Full-chain traceability summary:**  
  * **UC-SCR16-01** → SRS-FR-25 / SDS-COMP-7 → **FR-1 / SEC-1, SEC-2 / AC-1**  
  * **UC-SCR16-02** → SRS-FR-49 / SDS-ERR-7 → **FR-2 / EC-1**  
  * **UC-SCR16-03** → SRS-FR-50 / SDS-ERR-7 → **FR-3 / EC-2**  
  * **UC-SCR16-04** → SRS-FR-51 / SDS-ERR-7 → **FR-4 / EC-3**  
  * **UC-SCR16-05** → SRS-FR-28 → **FR-5 / AC-2**  
  * **UC-SCR16-06** → SRS-FR-29 / SDS-COMP-7 → **FR-6 / AC-3**  
  * **UC-SCR16-07** → SRS-FR-29 / SDS-COMP-7 → **FR-7 / NFR-1 / AC-4**  
  * **UC-SCR16-08** → SRS-NFR-6 / SDS-ERR-8 → **NFR-2, NFR-3 / EC-4**  
  * **UC-SCR16-09** → BR-NFR-020 / SDS-COMP-7 → **NFR-4 / EC-5**  
  * **UC-SCR16-10** → SDS-COMP-7 → **FR-8 / AC-5**  
  * **UC-SCR16-11** → SRS-FR-32 → **FR-9 / AC-6**  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain. This story derives strictly from all 11 UC rows defined for **SCR-16** and introduces no additional functional scope.



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering four states of this story: Active set-logging with a valid weighted-exercise entry, set progress, and Skip/Pause/Complete actions (§8 AC-1, AC-2); inline validation errors for a non-positive reps value and a negative weight value on the same weighted-entry layout (§9 EC-1, EC-2); inline validation for a negative duration value on a time-based exercise (§9 EC-3); and the PAUSED state overlay (§8 AC-4).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/c07e56bd-be35-430e-9d95-299de1058efd](https://claude.ai/code/artifact/c07e56bd-be35-430e-9d95-299de1058efd)  
* **Artifact title:** "ForgeApp Active Workout" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Active — Log Set, Weighted, Valid), Validation.dc.html (Inline Validation — Reps & Weight), TimeBased.dc.html (Inline Validation — Duration), Paused.dc.html (Paused State).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-15 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b` for inline errors and the Cancel link. The current-exercise header reuses the type-flag dot + label pattern from SCR-09/10/15 (lime dot for weighted, cyan `#7df4ff` dot for time-based), and set progress is shown as a row of small pill dots (done/current/upcoming) alongside an overall exercise-progress bar, so a user can see both where they are within the current exercise's sets and within the workout as a whole.  
* **Scope note:** only one exercise-type entry layout (weighted, two fields) and one single-field layout (time-based duration) are mocked; the third type, bodyweight (reps-only, no weight), is not shown separately since it is visually a strict subset of the weighted layout with the weight field omitted, matching the field-grid pattern already established in SCR-09/10/15 — no new layout logic is implied. Skip and Pause are shown as always-present secondary actions since the Inventory does not define which items are "applicable" for either (§10); which items may not support Skip/Pause is left to the SRS/SDS owner to confirm, per that same open note. The Paused overlay's dimmed background stands in for whatever the underlying content looked like when paused — it does not depict a distinct data state. App-backgrounded timer behavior (Decisions Log §6b) is intentionally not depicted anywhere on this canvas, per that note remaining open. Cancel (routes to SCR-18) and Finish/Done (routes to SCR-19, reachable once at least one set is logged, per Decisions Log §1/§2) are represented only as the Cancel link and the same Complete Set action shown here — no separate "Finish" screen state is mocked, since Finish's own confirmation/summary behavior belongs to SCR-18/SCR-19, not this screen.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
