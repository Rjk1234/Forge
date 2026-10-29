# **1\. User Story Identification**

* **Story ID:** US-SCR23  
* **Title:** View Statistics Dashboard  
* **Epic / Feature:** Statistics  
* **Priority:** Medium  
* **Story Points:** 5

# **2\. User Story Statement**

As a user with the app unlocked, I want to view my workout statistics so that I can understand my completed workout activity, training volume, workout duration, and exercise-level performance.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity / "another user" language inherited from the deprecated Firebase/Firestore architecture. Statistics are calculated from local Drift workout history, which has no "no connectivity" failure mode; the existing Error State already covers the one genuinely local-equivalent concern, a local Drift read/calculation failure. No functional change to the statistics content or recalculation logic.)*

SCR-23 is the Statistics Dashboard within **FLOW-09 — Statistics**.

The screen provides statistics derived from valid workout history. It supports an empty state when no valid completed workouts exist, a populated state when valid history is available, recalculation when workout records change, loading while statistics are calculated, and a recoverable error state.

The screen is accessible from the Home Dashboard through the **Stats** tab, once the app is unlocked.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty statistics state when there are no valid completed workouts, including zeroed/placeholder statistics and a prompt to complete a workout. **(UC-SCR23-02, SRS-FR-42; updated 2026-09-05 — drops "the user has," since there is a single local user)**  
* **FR-2** — The system shall display statistics when valid workout history exists, including total completed workouts, training volume, workout duration, and exercise-level statistics. **(UC-SCR23-03, SRS-FR-42, SRS-FR-43, SRS-FR-44, SRS-FR-45)**  
* **FR-3** — The system shall recalculate statistics from the current valid workout records when a workout record is edited or deleted, rather than displaying stale statistics. **(UC-SCR23-04, SRS-FR-47)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Statistics Dashboard shall present a loading/skeleton state while statistics are being calculated. **(UC-SCR23-01, SDS-IF-12)**  
* **NFR-2** — Statistics shall be based on valid workout records and shall recalculate when the underlying valid records change. **(UC-SCR23-04, SRS-FR-47, SDS-ERR-9)**  
* ~~**NFR-3** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR23-06 no longer applies.

# **6\. Security & Privacy Requirements**

* **SR-1** — The Statistics Dashboard shall be accessible only when the app's local login state is unlocked. **(Screen Auth Requirement: Required; updated 2026-09-05 — replaces "an authenticated user")**  
* **SR-2** — Statistics shall be derived from the valid workout records stored locally on this device. **(UC-SCR23-03, SRS-FR-42–45; updated 2026-09-05 — drops "the authenticated user's"/"another user's," since there is a single local user)**

# **7\. UI / Component Specifications**

### **Statistics Loading State**

* **Component type:** Skeleton/placeholder cards  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required loading state  
* **Source:** UC-SCR23-01

### **Empty Statistics State**

* **Component type:** Empty state with zeroed/placeholder statistics and prompt  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when no valid completed workouts exist  
* **Source:** UC-SCR23-02

### **Statistics Dashboard**

* **Component type:** Statistics dashboard  
* **Input type:** Not applicable  
* **Validation rules:** Statistics shall reflect valid history  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when valid history exists  
* **Content:** Total completed workouts, training volume, workout duration, exercise-level statistics  
* **Source:** UC-SCR23-03

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when statistics fail to load/calculate  
* **Source:** UC-SCR23-05

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed. (Was UC-SCR23-06.)

# **8\. Acceptance Criteria**

### **AC-1 — Loading Statistics**

**Given** the user opens the Statistics Dashboard and statistics are being calculated,  
**When** the calculation is in progress,  
**Then** the system shall display skeleton/placeholder cards.  
**(UC-SCR23-01)**

### **AC-2 — No Valid Completed Workouts**

**Given** the user has no valid completed workouts,  
**When** the Statistics Dashboard is displayed,  
**Then** the system shall display an empty state with zeroed/placeholder statistics and a prompt to complete a workout.  
**(UC-SCR23-02)**

### **AC-3 — Display Statistics**

**Given** the user has valid workout history,  
**When** statistics are successfully calculated,  
**Then** the system shall display total completed workouts, training volume, workout duration, and exercise-level statistics.  
**(UC-SCR23-03)**

### **AC-4 — Recalculate Current Statistics**

**Given** a workout record has been edited or deleted after being counted,  
**When** the Statistics Dashboard recalculates its statistics,  
**Then** the system shall calculate the displayed statistics from the current valid records rather than displaying stale values.  
**(UC-SCR23-04)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Statistics Calculation/Load Failure**

**Given** statistics fail to load or calculate,  
**When** the failure occurs,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR23-05)**

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR23-06 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:** SCR-06 — Home Dashboard / Stats tab.  
* **Screen exit dependencies:** SCR-24 — Personal Bests.  
* **Access dependency:** The screen requires the app's local login state to be unlocked (updated 2026-09-05 — replaces "requires an authenticated user").  
* **\[ASSUMPTION\] flag:** None specified for SCR-23.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual format of the statistics dashboard.  
  * The Inventory does not specify the exact wording of the error state.  
  * The Inventory does not specify calculation formulas for training volume, workout duration, or exercise-level statistics.  
  * These details must be confirmed with the SRS/SDS owner rather than invented at user-story level.  
* **Full-chain traceability summary:**  
  * **BRD:** BRD-FR/NFR IDs reachable through the SDS full-chain mapping  
  * **SRS:** SRS-FR-42 → UC-SCR23-02 → FR-1 / AC-2  
  * **SRS:** SRS-FR-42–45 → UC-SCR23-03 → FR-2 / AC-3  
  * **SRS:** SRS-FR-47 → UC-SCR23-04 → FR-3 / NFR-2 / AC-4  
  * **SDS:** SDS-IF-12 → UC-SCR23-01 → NFR-1 / AC-1  
  * **SDS:** SDS-DATA-7 → UC-SCR23-03 → FR-2 / AC-3  
  * **SDS:** SDS-ERR-9 → UC-SCR23-04 → NFR-2 / AC-4  
  * **SDS:** SDS-ERR-5 / SDS-ERR-9 → UC-SCR23-05 → EC-1  
  * ~~**BRD:** BR-NFR-020 → UC-SCR23-06 → NFR-3 / EC-2~~ — Removed 2026-09-05, no connectivity condition exists



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: skeleton/placeholder cards while calculating (§8 AC-1), the empty state with zeroed stat tiles and a prompt to complete a workout (§8 AC-2), the populated dashboard with total workouts, training volume, total/average duration, and a per-exercise breakdown (§8 AC-3), and a calculation/load-failure error state with retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/945dda3f-7b79-46bc-8be8-6ea87738478f](https://claude.ai/code/artifact/945dda3f-7b79-46bc-8be8-6ea87738478f)  
* **Artifact title:** "ForgeApp Statistics Dashboard" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading — Skeleton Cards), Empty.dc.html (Empty — Zeroed Stats + Prompt), Main.dc.html (Populated Statistics Dashboard), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-22 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for the error card. This is a true root-tab screen (reached via the Stats tab, §10) and reuses the same 6-tab bottom nav bar established in SCR-06/08/12/20/22, with Stats shown active. The exercise breakdown rows reuse the type-flag dot from SCR-09/10/15/16/19/21/22 (lime/cyan/muted for weighted/time-based/bodyweight) so exercise-level stats read as the same data model used throughout the app. A "Personal Bests" row is shown exiting to SCR-24 (§10 screen exit dependency).  
* **Scope note:** the Inventory does not specify the exact visual format of the dashboard or the calculation formulas for training volume, duration, or exercise-level statistics (§10) — the mockup uses a 4-tile stat grid (workouts completed, total volume, total duration, average duration) plus a per-exercise sessions/best-value list as one plausible presentation; exact metrics, formulas, and error copy should be confirmed with the SRS/SDS owner. Recalculation on record edit/delete (§8 AC-4) is a data-layer behavior with no distinct visual state, so it is not separately mocked — the Populated state already represents current, recalculated values. Per the dataviz skill, this screen uses stat tiles rather than a chart (SCR-22 already owns the trend-chart treatment for per-exercise progress over time), avoiding a duplicate or conflicting visualization for the same underlying data.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
