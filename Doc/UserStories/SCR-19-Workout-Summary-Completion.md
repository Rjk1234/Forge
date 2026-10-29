# **User Story — SCR-19**

## **1\. User Story Identification**

* **Story ID:** US-SCR-19  
* **Title:** Workout Summary and Completion  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As the app's user,** I want to see a summary of my workout after finishing it, so that I can review the recorded performance.

## **3\. Description / Context**

SCR-19 is the Workout Summary screen reached from SCR-16 when the user taps Finish/Done on a session that qualifies as completed.

**Completion criterion (Decisions Log §1, confirmed 2026-09-05):** every record that reaches SCR-19 is, by definition, a completed one — at least one set of at least one exercise was logged, and the user explicitly tapped Finish. **There is no "Incomplete" saved-workout state.** A Finish tap with zero sets logged is treated the same as Cancel (discarded — see SCR-18/SCR-16) and never reaches this screen; there is no "recorded and labeled as incomplete" outcome, and history/stats/progress never need to filter out an incomplete case.

When the user finishes the workout, the session is written to the local on-device Drift database before the completed summary is displayed; while the write is in progress, the Finish action shows a brief loading state. The app is fully offline/local-only (Decisions Log §0) — there is no network/Firestore write and no connectivity condition to handle.

For a successfully saved workout, the summary presents the recorded workout information, including date/time, duration, and actual sets/reps/weight.

If the local write fails (e.g., on-device storage error), the workout must not be represented as saved; the user is given a retry action and the in-memory session data is preserved for that retry attempt.

## **4\. Functional Requirements**

* **FR-1** — When the user taps Finish and the session is being written to local storage, the system shall display a loading state on the Finish action. **(UC-SCR19-01, SRS-FR-33–SRS-FR-35)**  
* **FR-2** — When the workout session is successfully saved, the system shall display a summary containing the completed workout's date/time, duration, and actual sets/reps/weight. **(UC-SCR19-02, SRS-FR-33–SRS-FR-35)**  
* ~~**FR-3** — incomplete-workout recording~~ — **REMOVED, 2026-09-05.** Per Decisions Log §1/§2, there is no "incomplete" saved-workout state: a session either meets the completion criterion and is saved as completed, or it is discarded entirely (Cancel, or Finish with zero sets). UC-SCR19-03 no longer applies as originally worded.  
* **FR-4** — When the workout session cannot be saved because the local (Drift) write fails, the system shall not represent the workout as saved and shall provide a retry option without creating a duplicate record when the retry succeeds. **(UC-SCR19-04, SRS-FR-33–SRS-FR-35; updated 2026-09-05 — replaces "Firestore write fails" with a local-storage write failure)**  
* ~~**FR-5** — connectivity-unavailable-at-finish~~ — **REMOVED, 2026-09-05.** The app has no network connectivity (Decisions Log §0); UC-SCR19-05 no longer applies. FR-4 above already covers the genuinely local-equivalent case (a local write failure).

## **5\. Non-Functional Requirements**

* **NFR-1** — The workout summary shall be based on the locally-saved workout session outcome and shall not represent an unsuccessful local-write attempt as a completed saved workout. **(UC-SCR19-04, SDS-NFR-6; updated 2026-09-05)**  
* **NFR-2** — The workout session shall remain available for the retry attempt when the Finish write fails locally. **(UC-SCR19-04; updated 2026-09-05 — replaces the prior "unavailable connectivity" framing, which does not apply per Decisions Log §0)**

> **Note:** The SCR-19 UC rows do not explicitly cite an SRS-NFR-\* ID. The applicable non-functional behavior is therefore traced only to the Inventory's stated SDS/BRD references. **Confirm exact SRS-NFR/SDS-NFR mapping with the SRS/SDS owner.**

## **6\. Security & Privacy Requirements**

* SCR-19 requires the app's local login state to be unlocked (updated 2026-09-05 — replaces "requires an authenticated user").  
* The Inventory does not specify additional SCR-19-specific security or privacy behavior beyond the local-unlock screen requirement.

**Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Workout Summary**

* **Component type:** Workout summary content  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Summary data is required when the session is successfully persisted.

### **Recorded Workout Information**

* **Component type:** Summary information  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Date/time, duration, and actual sets/reps/weight are specified for the successful summary state.

### **Finish Action Loading State**

* **Component type:** Finish action  
* **Input type:** User action  
* **Validation rules:** Not specified  
* **Min / Max constraints:** Not specified  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Loading state required while the session is being persisted.

### ~~Incomplete Workout State~~ — REMOVED, 2026-09-05

There is no "Incomplete" saved-workout state (Decisions Log §1/§2). Every session reaching SCR-19 is, by definition, completed.

### **Error / Retry State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified for local (Drift) write failure  
* **Mandatory / Optional flags:** Required when the local write fails at finish.  
* *(Updated 2026-09-05 — removes the prior Firestore-write-failure and offline/"You're offline — your workout can't be saved until you reconnect" copy; the app has no network, so only a local storage write failure applies — Decisions Log §0.)*

## **8\. Acceptance Criteria**

### **AC-1 — Finish Loading State**

**UC:** UC-SCR19-01

**Given** the user has finished the active workout and the session is being persisted  
**When** the finish action is processing  
**Then** the Finish action shall display a loading state.

### **AC-2 — Successfully Saved Workout Summary**

**UC:** UC-SCR19-02

**Given** the workout session is being persisted  
**When** the session persists successfully  
**Then** the system shall display a summary of the completed workout containing the date/time, duration, and actual sets/reps/weight.

### ~~AC-3 — Incomplete Workout~~ — REMOVED, 2026-09-05

Not applicable: per Decisions Log §1/§2 there is no "incomplete" outcome — a workout that doesn't meet the completion criterion (zero sets logged + Finish) is discarded exactly like Cancel, and never produces a labeled/recorded "incomplete" session.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Local Write Failure at Finish**

**UC:** UC-SCR19-04

**Given** the user finishes the workout  
**When** the local (Drift) write fails  
**Then** the system shall show an error state, shall not represent the workout as saved, shall provide a retry option, and shall not create a duplicate record when the retry succeeds.  
**(Updated 2026-09-05 — replaces "Firestore write fails" per Decisions Log §0.)**

### ~~EC-2 — Offline at Finish~~ — REMOVED, 2026-09-05

The app has no network connectivity (Decisions Log §0); this UC no longer applies. A local write failure is covered by EC-1 above.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-16 — Active Workout — Exercise & Set Logging. The user reaches SCR-19 after the last item is completed.  
* **Screen exit dependencies:** The Inventory identifies SCR-06 Home and SCR-20 Workout History as destinations from the completed workout flow.  
* **\[ASSUMPTION\] flag:** None specified for SCR-19.  
* **Underspecified behavior:**  
  * ~~The Inventory does not specify the exact completion criteria used to determine whether a workout is complete or incomplete.~~ — **Resolved 2026-09-05, Decisions Log §1:** completed = at least one set of at least one exercise logged, plus explicit Finish. There is no separate "incomplete" outcome.  
  * The Inventory does not specify the exact error-state copy for the local (Drift) write failure.  
  * The Inventory does not specify the exact retry action label.  
  * The Inventory does not specify the exact navigation/action behavior available after the successful summary beyond the documented SCR-06 / SCR-20 destinations.  
* These details must be confirmed with the SRS/SDS owner rather than invented in this story.  
* **Full-chain traceability summary:**  
  * **UC-SCR19-01 → FR-1 / AC-1**  
  * **UC-SCR19-02 → FR-2 / AC-2**  
  * **UC-SCR19-03 → FR-3 / AC-3**  
  * **UC-SCR19-04 → FR-4 / EC-1**  
  * **UC-SCR19-05 → FR-5 / EC-2**  
  * **SRS-FR-33–SRS-FR-35 → SDS-COMP-8 / SDS-DATA-6 → UC-SCR19-01/02 → this story**  
  * **SRS-FR-30 → SDS-DATA-8 → UC-SCR19-03 → this story**  
  * **SDS-ERR-6 → UC-SCR19-04 → this story**  
  * **BR-NFR-020 → SDS-ERR-6 → UC-SCR19-05 → this story**  
* **BRD-level mapping:** The supplied Inventory explicitly exposes BR-FR-025 for the incomplete-workout behavior and BR-NFR-020 for offline behavior. The complete BRD → SRS → SDS mapping for every SCR-19 UC is not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain table before baselining this story.**


## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the three states defined in this story: the Finish action's loading state on SCR-16 while the session writes to local storage (§8 AC-1), the successful Workout Summary with date/time, duration, and per-exercise actual sets/reps/weight (§8 AC-2), and the local-write-failure error state with retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — three artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/e5fec60a-5cea-465b-97d3-1e556a1db092](https://claude.ai/code/artifact/e5fec60a-5cea-465b-97d3-1e556a1db092)  
* **Artifact title:** "ForgeApp Workout Summary" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Finish — Saving, shown on SCR-16), Main.dc.html (Workout Summary — Saved), Error.dc.html (Save Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-18 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b` for the failure state. The per-exercise performance cards reuse the type-flag dot from SCR-09/10/15/16 (lime/cyan/muted for weighted/time-based/bodyweight) so a completed set's actual values read as the same data model shown throughout planning and execution; a skipped set (from SCR-16's Skip action, §10 dependency) is shown as a struck-through pill rather than omitted, so the summary visibly accounts for every planned set.  
* **Scope note:** the Inventory does not specify exact error copy, the retry label, or what actions are available after a successful summary beyond the SCR-06/SCR-20 exit destinations (§10) — the mockup shows "View History" (to SCR-20) and "Done" (to SCR-06) as the two documented destinations, and plausible error/retry copy; these should be confirmed with the SRS/SDS owner. No "incomplete workout" state is designed, consistent with Decisions Log §1/§2 — every session reaching this screen is by definition completed, and a zero-set Finish is discarded before ever reaching SCR-19.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
