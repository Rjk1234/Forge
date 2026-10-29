# **User Story — SCR-21**

## **1\. User Story Identification**

* **Story ID:** US-SCR-21  
* **Title:** Workout History Detail  
* **Epic / Feature:** Workout History  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As a user with the app unlocked,** I want to view the complete details of a previously completed workout, so that I can review the actual performance I recorded for that session.

## **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language, including the prior "workout history is not available through an offline/local-cache mode" framing, inherited from the deprecated Firebase/Firestore architecture. Session detail is read from the local Drift database — it IS the local store, not a cache of something remote — so there is no "no connectivity" failure mode; the existing Error State already covers the one genuinely local-equivalent concern, a local Drift read failure. No functional change to the detail view or historical-integrity behavior.)*

SCR-21 is the Workout History Detail screen within the Workout History flow.

The screen is accessed by selecting a workout session from SCR-20. When the selected session is being fetched, a skeleton is displayed.

When the session loads successfully, the screen displays the full recorded workout detail, including the date/time and the actual performance for each exercise, including sets, reps, weight, and duration.

Historical workout data must remain independent of later changes to the underlying workout plan. If the plan used for the session is subsequently edited or deleted, the historical detail continues to show the actual performance as it was originally recorded.

If the session detail cannot be loaded (a local Drift read failure), an error state with retry is provided.

## **4\. Functional Requirements**

* **FR-1** — When the selected workout session detail is being fetched, the system shall display a skeleton. **(UC-SCR21-01, SRS-FR-37)**  
* **FR-2** — When the workout session is successfully loaded, the system shall display the full recorded detail, including date/time and per-exercise actual sets, reps, weight, and duration. **(UC-SCR21-02, SRS-FR-37)**  
* **FR-3** — When the underlying workout plan has subsequently been edited or deleted, the system shall continue to display the actual performance originally recorded for the historical session without applying subsequent plan changes to that historical record. **(UC-SCR21-03, SRS-FR-38)**

## **5\. Non-Functional Requirements**

* **NFR-1** — Historical workout details shall preserve the recorded performance independently of subsequent changes to the underlying workout plan. **(UC-SCR21-03, SRS-FR-38, SDS-DATA-6)**  
* **NFR-2** — When session detail cannot be loaded, the system shall present a distinct error state with retry rather than representing the unavailable data as a valid populated or empty state. **(UC-SCR21-04, SDS-ERR-5)**  
* ~~**NFR-3** — offline state because history has no offline/local-cache mode~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); workout history IS local Drift data, not a remote cache. UC-SCR21-05 no longer applies. NFR-2's local-read-failure error state already covers the one genuinely local-equivalent case.

## **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-21 shall require the app's local login state to be unlocked to access workout history detail. **(UC-SCR21-02, SRS-FR-37; updated 2026-09-05 — replaces "require authentication")**  
* **SEC-2** — The historical workout detail displayed shall correspond to the selected workout session from the workout history stored locally on this device. **(UC-SCR21-02, SRS-FR-37, SDS-COMP-9; updated 2026-09-05 — drops "authenticated user's," since there is a single local user)**  
* No additional SCR-21-specific security or privacy behavior is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Workout History Detail**

* **Component type:** Workout history detail content  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when the session is successfully loaded

### **Date / Time**

* **Component type:** Recorded workout information  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required in the populated state

### **Per-Exercise Actual Performance**

* **Component type:** Recorded exercise detail  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required for recorded exercise details

### **Loading State**

* **Component type:** Skeleton  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while session detail is being fetched

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when session detail fails to load

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

## **8\. Acceptance Criteria**

### **AC-1 — Session Detail Loading**

**UC:** UC-SCR21-01

**Given** the user has selected a workout session from SCR-20  
**When** the selected session detail is being fetched  
**Then** SCR-21 shall display a skeleton.

### **AC-2 — Display Recorded Workout Detail**

**UC:** UC-SCR21-02

**Given** the selected workout session has been successfully loaded  
**When** SCR-21 displays the session  
**Then** the system shall show the full recorded detail, including the workout date/time and the actual sets, reps, weight, and duration for each exercise.

### **AC-3 — Preserve Historical Integrity**

**UC:** UC-SCR21-03

**Given** a historical workout session was recorded using a workout plan  
**When** that underlying plan is subsequently edited or deleted  
**Then** SCR-21 shall continue to display the actual performance originally recorded for that historical session, unaffected by the subsequent plan changes.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Session Detail Load Failure**

**UC:** UC-SCR21-04

**Given** the user has selected a workout session  
**When** the session detail fails to load  
**Then** the system shall display an error state with a retry action.

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR21-05 no longer applies.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-20 — Workout History List. The selected workout session from SCR-20 is the source of the detail displayed on SCR-21.  
* **Screen exit dependency:** The Inventory specifies returning to SCR-20 through the back action.  
* **\[ASSUMPTION\] flag:** None specified for SCR-21.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact layout or ordering of the date/time and per-exercise recorded fields.  
  * The Inventory does not specify the exact error message for a session-detail load (local Drift read) failure.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-37 → SDS-COMP-9 / SDS-DATA-6 → UC-SCR21-01 → FR-1 / AC-1**  
  * **SRS-FR-37 → SDS-COMP-9 / SDS-DATA-6 → UC-SCR21-02 → FR-2 / AC-2 / SEC-1 / SEC-2**  
  * **SRS-FR-38 → SDS-DATA-6 → UC-SCR21-03 → FR-3 / NFR-1 / AC-3**  
  * **SDS-ERR-5 → UC-SCR21-04 → NFR-2 / EC-1**  
  * ~~**BR-NFR-020 → UC-SCR21-05 → NFR-3 / EC-2**~~ — Removed 2026-09-05, no connectivity condition exists  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-21 Inventory rows explicitly provide SRS-FR-37, SRS-FR-38, SDS-COMP-9, SDS-DATA-6, SDS-ERR-5, and BR-NFR-020. The complete BRD mapping is not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**


## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the three states defined in this story: Loading skeleton (§8 AC-1), Populated full recorded detail with date/time and per-exercise actual sets/reps/weight/duration (§8 AC-2), and Load Failure — Retry (§9 EC-1). Historical integrity (§8 AC-3 — display is unaffected by later edits/deletion of the underlying plan) is a data-layer guarantee rather than a distinct visual state, so it is not separately mocked; the Populated state shown is exactly what a user would see whether or not the source plan still exists.  
* **Tool:** Claude Design canvas (not Figma) — three artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/583b36ed-081c-470a-be28-43d80647e3b6](https://claude.ai/code/artifact/583b36ed-081c-470a-be28-43d80647e3b6)  
* **Artifact title:** "ForgeApp Workout History Detail" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading Skeleton), Main.dc.html (Populated — Full Recorded Detail), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-20 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for the error card. The layout deliberately mirrors SCR-19's Workout Summary (same stat-row + per-exercise performance cards with the type-flag dot pattern from SCR-09/10/15/16/19), since both screens present the identical recorded-performance data model — SCR-19 right after completion, SCR-21 when revisiting it later from history — so a user sees the same shape of information in both places.  
* **Scope note:** the Inventory does not specify the exact layout/ordering of fields, the error copy, or the retry label (§10) — the mockup reuses SCR-19's field arrangement as the plausible default and plausible error copy consistent with SCR-20's error state; these should be confirmed with the SRS/SDS owner. No action buttons (e.g. "View History", "Done") are shown here, since the Inventory's only specified exit is back navigation to SCR-20 (§10).  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
