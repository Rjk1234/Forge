# **User Story — SCR-20**

## **1\. User Story Identification**

* **Story ID:** US-SCR-20  
* **Title:** Workout History List  
* **Epic / Feature:** Workout History  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As a user with the app unlocked,** I want to view my completed workout history, so that I can review the workouts I have previously completed and access their recorded details.

## **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture. Workout history is read from the local Drift database, which has no "no connectivity" failure mode; the existing Error State already covers the one genuinely local-equivalent concern, a local Drift read failure. No functional change to the list's loading, empty, populated, or navigation behavior.)*

SCR-20 is the Workout History List screen within the Workout History flow.

The screen is accessible from SCR-06 through the History tab and from SCR-19 through the option to view a completed workout in history.

When history data is being fetched, the screen displays a skeleton list. If no completed workouts exist, the screen displays an empty state. When completed sessions exist, the screen displays them in reverse chronological order.

If history cannot be loaded (a local Drift read failure), the screen provides an error state with retry.

Selecting a history session leads to SCR-21 for the full workout history detail.

## **4\. Functional Requirements**

* **FR-1** — When workout history is being fetched, the system shall display a skeleton list. **(UC-SCR20-01, SRS-FR-36)**  
* **FR-2** — When there are no completed workouts, the system shall display an empty state stating **"Your completed workouts will appear here"**. **(UC-SCR20-02, SRS-FR-36; updated 2026-09-05 — drops "authenticated user," since there is a single local user)**  
* **FR-3** — When completed workout sessions exist, the system shall display the sessions in reverse-chronological order. **(UC-SCR20-03, SRS-FR-36)**  
* **FR-4** — The workout history list shall contain only completed sessions stored locally on this device. **(UC-SCR20-03, SRS-FR-36; updated 2026-09-05 — replaces "belonging to the authenticated user")**  
* **FR-5** — When the user selects a workout history session, the system shall provide access to SCR-21 for the selected workout's recorded details. **(UC-SCR20-03, SRS-FR-36)**

## **5\. Non-Functional Requirements**

* **NFR-1** — Workout history shall be presented in reverse-chronological order when completed sessions exist. **(UC-SCR20-03, SRS-FR-36)**  
* **NFR-2** — The history screen shall not silently present unavailable data as an empty history state when a history-load failure occurs; a distinct error state with retry shall be presented. **(UC-SCR20-04, SDS-ERR-5)**  
* ~~**NFR-3** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR20-05 no longer applies. NFR-2's local-read-failure error state already covers the one genuinely local-equivalent case.

## **6\. Security & Privacy Requirements**

* **SEC-1** — The workout history displayed on SCR-20 shall contain only completed sessions stored locally on this device. **(UC-SCR20-03, SRS-FR-36, SDS-COMP-9; updated 2026-09-05 — replaces "belonging to the authenticated user")**  
* **SEC-2** — SCR-20 shall require the app's local login state to be unlocked before the user's workout history can be accessed. **(UC-SCR20-03, SRS-FR-36; updated 2026-09-05 — replaces "require authentication")**  
* The Inventory does not specify additional SCR-20-specific security or privacy behavior. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **History List**

* **Component type:** List of workout history sessions  
* **Input type:** User selection of a history session  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when completed sessions exist

### **History Session Item**

* **Component type:** Workout history list item  
* **Input type:** User selection  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required for each available completed session

### **Loading State**

* **Component type:** Skeleton list  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while history is being fetched

### **Empty State**

* **Component type:** Empty-state content  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages / content:** **"Your completed workouts will appear here"**  
* **Mandatory / Optional flags:** Required when no completed workouts exist

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when history fails to load

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

## **8\. Acceptance Criteria**

### **AC-1 — History Loading**

**UC:** UC-SCR20-01

**Given** workout history is being fetched  
**When** SCR-20 is displayed  
**Then** the system shall display a skeleton list.

### **AC-2 — Empty History**

**UC:** UC-SCR20-02

**Given** there are no completed workouts  
**When** the history data is loaded  
**Then** the system shall display an empty state containing **"Your completed workouts will appear here"**.

### **AC-3 — Populated History**

**UC:** UC-SCR20-03

**Given** completed workout sessions exist  
**When** the history data is loaded  
**Then** the system shall display the sessions in reverse-chronological order.

### **AC-4 — Open History Detail**

**UC:** UC-SCR20-03

**Given** the workout history list contains a completed session  
**When** the user selects that session  
**Then** the system shall navigate to SCR-21 to view the selected workout's full recorded details.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — History Load Failure**

**UC:** UC-SCR20-04

**Given** workout history is being loaded  
**When** the history data fails to load  
**Then** the system shall display an error state with a retry action.

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR20-05 no longer applies.

## **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * **SCR-06 — Home Dashboard:** History tab provides access to SCR-20.  
  * **SCR-19 — Workout Summary:** The completed workout flow can provide access to SCR-20 through the "View in history" path.  
* **Screen exit dependency:**  
  * **SCR-21 — Workout History Detail:** Selecting a history session provides access to the detailed recorded workout.  
* **\[ASSUMPTION\] flag:** None specified for SCR-20.  
* **Underspecified behavior:**  
  * The Inventory does not specify which individual fields are displayed in each history list item.  
  * The Inventory does not specify the exact error message for history-load (local Drift read) failure.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-36 → SDS-COMP-9 / SDS-IF-7 → UC-SCR20-01 → FR-1 / AC-1**  
  * **SRS-FR-36 → SDS-COMP-9 / SDS-IF-7 → UC-SCR20-02 → FR-2 / AC-2**  
  * **SRS-FR-36 → SDS-COMP-9 → UC-SCR20-03 → FR-3 / FR-4 / FR-5 / AC-3 / AC-4**  
  * **SDS-ERR-5 → UC-SCR20-04 → Edge Case EC-1**  
  * ~~**BR-NFR-020 → UC-SCR20-05 → NFR-3 / Edge Case EC-2**~~ — Removed 2026-09-05, no connectivity condition exists  
  * **SRS-FR-36 → SDS-COMP-9 → UC-SCR20-03 → SEC-1 / SEC-2**  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-20 Inventory rows expose SRS-FR-36, SDS-COMP-9, SDS-IF-7, SDS-ERR-5, and BR-NFR-020. The corresponding complete BRD mappings are not included in the SCR-20 rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**


## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: Loading skeleton (§8 AC-1), Empty state with the exact copy "Your completed workouts will appear here" (§8 AC-2), Populated list in reverse-chronological order (§8 AC-3), and Load Failure — Retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/0e0c565e-43b2-4303-9f72-25e12fd3d64b](https://claude.ai/code/artifact/0e0c565e-43b2-4303-9f72-25e12fd3d64b)  
* **Artifact title:** "ForgeApp Workout History List" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading Skeleton), Empty.dc.html (Empty State), Main.dc.html (Populated — Reverse Chronological), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-19 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for the error card. This is a true root-tab screen (reached via the History tab, §10), so it reuses the same 6-tab bottom nav bar (Home/Plans/Schedule/History/Progress/Stats) established in SCR-06/08/12, with History shown active; the loading/empty/error content patterns are also carried over verbatim from SCR-12's equivalents for visual consistency across root tabs.  
* **Scope note:** the Inventory does not specify which individual fields appear on each history list item (§10) — the mockup shows date, workout name, duration, exercise count, and set count as one plausible summary, grouped under month-section labels for scanability (grouping itself is not called for by the Inventory and is a presentational judgment call, not a new field). Exact error copy and retry label are likewise not specified and should be confirmed with the SRS/SDS owner. Selecting a card (§8 AC-4, exit to SCR-21) is represented by the chevron affordance on each row; SCR-21's own detail view is out of scope for this canvas.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
