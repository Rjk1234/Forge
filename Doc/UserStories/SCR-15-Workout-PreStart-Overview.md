# **\#Forge-US-15**

# **1\. User Story Identification**

* **Story ID:** US-SCR15  
* **Title:** Workout Pre-Start / Overview  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

**As a user with the app unlocked, I want to review my selected workout plan and its targets before starting the workout, so that I can confirm what I am about to perform before entering the active workout.**

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture, including a prior NFR that literally required connectivity to retrieve the plan — the plan is read from the local Drift database, so no connectivity of any kind is required or possible. No functional change to the pre-start review, validity check, or Begin Workout behavior.)*

SCR-15 provides the pre-start overview for a workout initiated from a workout plan or today's scheduled workout. The screen allows the user to review the available exercise and target information before beginning the active workout.

The screen must handle plan loading, successful display of plan information, invalid or unavailable plans, and system (local Drift read) failures according to the defined Inventory behavior.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading skeleton while the workout plan data is being fetched. **(UC-SCR15-01, SDS-IF-14)**  
* **FR-2** — When the workout plan is successfully loaded, the system shall display a preview of the exercises and their configured targets. **(UC-SCR15-02, SRS-FR-26, SDS-DATA-4)**  
* **FR-3** — The system shall provide a **"Begin Workout"** action when the workout plan is successfully loaded. **(UC-SCR15-02, SRS-FR-26, SDS-COMP-7)**  
* **FR-4** — The system shall prevent the workout from starting when the underlying workout plan is no longer valid or available. **(UC-SCR15-03, SRS-FR-21, SDS-COMP-12)**  
* **FR-5** — When the workout plan is successfully available for execution, the system shall allow the user to proceed to the active workout. **(UC-SCR15-02, SRS-FR-25, SDS-COMP-7)**

# **5\. Non-Functional Requirements**

* ~~**NFR-1** — connectivity required to retrieve the workout plan~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); the workout plan is read from the local Drift database, so there is no connectivity condition to require or to lack. UC-SCR15-05 no longer applies.

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the workout pre-start screen shall require the app's local login state to be unlocked. **(UC-SCR15-02, SRS-FR-25; updated 2026-09-05 — replaces "authenticated user session")**  
* **SEC-2** — The screen shall not allow a user to proceed with a workout when the underlying plan is no longer valid or available. **(UC-SCR15-03, SRS-FR-21, SDS-COMP-12)**

# **7\. UI / Component Specifications**

### **Workout Plan Loading State**

* **Component type:** Loading skeleton  
* **Input type:** N/A  
* **Validation rules:** N/A  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory loading state

### **Workout Plan Preview**

* **Component type:** Workout plan preview  
* **Input type:** Read-only workout plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when plan data is successfully loaded

### **Exercise / Target Information**

* **Component type:** Exercise and target information  
* **Input type:** Read-only plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when plan data is successfully loaded

### **Begin Workout Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Workout plan must be valid and available  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Invalid / Unavailable Plan State**

* **Component type:** Blocking message/state  
* **Input type:** N/A  
* **Validation rules:** Underlying plan must be valid and available  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when the underlying plan is invalid/unavailable

# **8\. Acceptance Criteria**

### **AC-1 — Plan Loading**

**(UC-SCR15-01)**

**Given** the user opens SCR-15 and the workout plan data is being fetched,  
**When** the data has not yet been resolved,  
**Then** the screen shall display a loading skeleton.

### **AC-2 — Plan Successfully Loaded**

**(UC-SCR15-02)**

**Given** the user opens SCR-15 and the workout plan is successfully loaded,  
**When** the plan data becomes available,  
**Then** the screen shall display a preview of the exercises and their configured targets and provide the **"Begin Workout"**action.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Invalid or Unavailable Plan**

**(UC-SCR15-03)**

**Given** the user attempts to start a workout whose underlying plan is no longer valid or available,  
**When** the system detects that the plan cannot be used,  
**Then** the screen shall display a blocking state and shall prevent the workout from starting.

### **EC-2 — Plan Load Failure**

**(UC-SCR15-04)**

**Given** the user opens SCR-15,  
**When** the workout plan fails to load because of a system failure (a local Drift read failure),  
**Then** the screen shall display an error state with a retry action.  
**(Updated 2026-09-05 — local storage failure, not a network/Firestore failure.)**

### ~~EC-3 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); UC-SCR15-05 no longer applies. EC-2's plan-load-failure error state already covers the one genuinely local-equivalent case.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-10 — Plan Detail  
  * SCR-12 — Weekly Schedule View  
* **Screen exit dependencies:**  
  * SCR-16 — Active Workout — Exercise & Set Logging  
  * Back navigation as defined by the Inventory.  
* **\[ASSUMPTION\] flag:** None specified for SCR-15.  
* **Underspecified behavior:**  
  * The exact presentation, wording, and layout of the blocking state for an invalid/unavailable plan are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The exact presentation and wording of the plan preview and target information are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The exact navigation behavior triggered by the **"Begin Workout"** action is represented by the SCR-15 exit point to SCR-16 but the Inventory does not specify additional transition behavior.  
* **Full-chain traceability summary:**  
  * **SCR-15 UC-SCR15-01** → SDS-IF-14 → **FR-1 / AC-1**  
  * **SCR-15 UC-SCR15-02** → SRS-FR-26 / SDS-DATA-4 / SDS-COMP-7 → **FR-2, FR-3, FR-5 / AC-2**  
  * **SCR-15 UC-SCR15-03** → SRS-FR-21 / SDS-COMP-12 → **FR-4 / SEC-2 / EC-1**  
  * **SCR-15 UC-SCR15-04** → SDS-ERR-5 → **EC-2**  
  * ~~**SCR-15 UC-SCR15-05** → BR-NFR-020 / Appendix C (SDS) → **NFR-1 / EC-3**~~ — Removed 2026-09-05, no connectivity condition exists  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain; this story derives only from the five UC rows defined for **SCR-15** and introduces no additional functional scope.



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: Loading skeleton (§8 AC-1), Plan Preview with per-exercise target cards and the Begin Workout action (§8 AC-2), Invalid/Unavailable Plan blocking state (§9 EC-1), and Plan Load Failure — Retry (§9 EC-2).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/16366a19-a2a2-48fe-aa85-97478f08e10e](https://claude.ai/code/artifact/16366a19-a2a2-48fe-aa85-97478f08e10e)  
* **Artifact title:** "ForgeApp Workout Pre-Start" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Plan Preview — Begin Workout), Loading.dc.html (Loading Skeleton), Invalid.dc.html (Invalid / Unavailable Plan), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-14 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`. The Plan Preview reuses the exercise type-flag system established in SCR-09/SCR-10 (a colored dot + type label, with a 3-box field grid for weighted, or a 2-box grid for time-based/bodyweight), so the pre-start review reads as the same data the user configured on those screens, not a re-invented summary.  
* **Scope note:** the Inventory (§10) leaves the exact wording/layout of the plan preview, target information, and the invalid-plan blocking state unspecified — the mockups use plausible placeholder copy and should be confirmed with the SRS/SDS owner before development treats them as final. The Begin Workout action's exact post-tap transition to SCR-16 is likewise not specified beyond the exit point itself (§10); no additional transition behavior (e.g. a confirmation step) is invented here. Per Decisions Log §0, the Invalid/Unavailable state (EC-1) and the Load Failure state (EC-2) are both local-only conditions (a stale local reference and a local Drift read failure, respectively) — no offline/connectivity state is depicted, consistent with NFR-1's removal.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
