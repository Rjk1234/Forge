# **User Story — SCR-22**

## **1\. User Story Identification**

* **Story ID:** US-SCR-22  
* **Title:** Progress Comparison  
* **Epic / Feature:** Progress  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As a user with the app unlocked,** I want to compare my workout performance across completed sessions for each exercise, so that I can understand how my performance has progressed over time.

## **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity / "another user" language inherited from the deprecated Firebase/Firestore architecture. Progress data is calculated from local Drift workout history, which has no "no connectivity" failure mode; the existing Error State already covers the one genuinely local-equivalent concern, a local Drift read/calculation failure. No functional change to the comparison logic, metrics, or exclusion rules.)*

SCR-22 is the Progress Comparison screen within the Progress flow.

The screen retrieves and presents progress data calculated from the valid completed workout history stored locally on this device. While progress data is being calculated or fetched, a skeleton/placeholder chart is displayed.

When fewer than two valid completed sessions exist for a given exercise, the screen displays the specified empty state. When sufficient valid history exists, the screen presents a comparison view across sessions for applicable exercise metrics: weight, reps, volume, and duration.

Incomplete or invalid workout sessions must not influence the progress comparison. Such sessions are silently excluded rather than being displayed as a gap or error.

If progress data cannot be loaded or calculated (a local Drift read/calculation failure), an error state with retry is displayed.

## **4\. Functional Requirements**

* **FR-1** — When progress data is being calculated or fetched, the system shall display a skeleton/placeholder chart. **(UC-SCR22-01, SRS-FR-39–SRS-FR-41)**  
* **FR-2** — When fewer than two valid completed sessions exist for a given exercise, the system shall display the empty state **"Complete a few more workouts to see your progress"**. **(UC-SCR22-02, SRS-FR-39)**  
* **FR-3** — When sufficient valid workout history exists, the system shall display a comparison view across sessions for each exercise using weight, reps, volume, and duration where applicable. **(UC-SCR22-03, SRS-FR-40)**  
* **FR-4** — When an incomplete or invalid session exists in the underlying workout history, the system shall exclude that session from the progress comparison and shall not display it as a gap or error. **(UC-SCR22-04, SRS-FR-41)**  
* **FR-5** — When progress data fails to load or calculate, the system shall display an error state with a retry action. **(UC-SCR22-05, SRS-FR-39–SRS-FR-41)**  
* ~~**FR-6** — offline state when there is no connectivity~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); UC-SCR22-06 no longer applies. FR-5's error state already covers the one genuinely local-equivalent case.

## **5\. Non-Functional Requirements**

* **NFR-1** — Progress comparisons shall use valid completed workout sessions and shall exclude incomplete or invalid sessions from the comparison. **(UC-SCR22-04, SRS-FR-41, SDS-COMP-10)**  
* **NFR-2** — An incomplete or invalid workout session shall be silently excluded from the progress comparison rather than represented as a gap or error. **(UC-SCR22-04, SRS-FR-41, SDS-COMP-10)**  
* **NFR-3** — When progress data cannot be loaded or calculated, the system shall distinguish the failure from an empty progress state by presenting an error state with retry. **(UC-SCR22-05, SDS-ERR-5, SDS-ERR-9)**  
* ~~**NFR-4** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR22-06 no longer applies.

## **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-22 shall require the app's local login state to be unlocked before progress data can be accessed. **(UC-SCR22-03, SRS-FR-40, SDS-COMP-10; updated 2026-09-05 — replaces "require authentication")**  
* **SEC-2** — Progress comparison data shall be derived from the valid completed workout history stored locally on this device. **(UC-SCR22-03, SRS-FR-40, SDS-DATA-7; updated 2026-09-05 — drops "authenticated user's," since there is a single local user)**  
* ~~**SEC-3** — progress data belonging to another user shall not be presented~~ — **REMOVED, 2026-09-05.** Not applicable; there is a single local user and no multi-user data-access concern (Decisions Log §0).  
* No additional SCR-22-specific security or privacy behavior is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Progress Comparison View**

* **Component type:** Comparison view  
* **Input type:** Read-only progress data  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required when sufficient valid history exists

### **Progress Chart / Placeholder**

* **Component type:** Skeleton/placeholder chart  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while progress data is being calculated/fetched

### **Exercise Progress Data**

* **Component type:** Exercise-level comparison data  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required when sufficient valid history exists

### **Progress Metrics**

* **Component type:** Progress comparison metrics  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Weight, reps, volume, and duration where applicable

### **Empty State**

* **Component type:** Empty-state content  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages / content:** **"Complete a few more workouts to see your progress"**  
* **Mandatory / Optional flags:** Required when fewer than two valid completed sessions exist for a given exercise

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when progress data fails to load or calculate

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

## **8\. Acceptance Criteria**

### **AC-1 — Progress Loading**

**UC:** UC-SCR22-01

**Given** progress data is being calculated or fetched  
**When** SCR-22 is displayed  
**Then** the system shall display a skeleton/placeholder chart.

### **AC-2 — Insufficient Progress History**

**UC:** UC-SCR22-02

**Given** fewer than two valid completed sessions exist for a given exercise  
**When** progress data is displayed  
**Then** the system shall display **"Complete a few more workouts to see your progress"**.

### **AC-3 — Progress Comparison**

**UC:** UC-SCR22-03

**Given** sufficient valid completed workout history exists  
**When** progress data is displayed  
**Then** the system shall present a comparison view across sessions for each exercise using weight, reps, volume, and duration where applicable.

### **AC-4 — Exclude Invalid or Incomplete Sessions**

**UC:** UC-SCR22-04

**Given** an incomplete or invalid workout session exists in the underlying history  
**When** progress comparison data is calculated  
**Then** the system shall silently exclude that session from the comparison and shall not display it as a gap or error.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Progress Calculation or Load Failure**

**UC:** UC-SCR22-05

**Given** progress data is being loaded or calculated  
**When** the progress data fails to load or calculate  
**Then** the system shall display an error state with a retry action.

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR22-06 no longer applies.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-06 — Home Dashboard, through the Progress tab.  
* **Screen exit dependencies:** None specified in the Inventory.  
* **Data dependency:** Progress comparison depends on valid completed workout history and the exercise-level performance data recorded within those sessions.  
* **\[ASSUMPTION\] flag:** None specified for SCR-22.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual representation of the comparison view.  
  * The Inventory does not specify the exact chart type.  
  * The Inventory does not specify how the user selects or switches between exercises.  
  * The Inventory does not specify the exact calculation/display rules for volume.  
  * The Inventory does not specify the exact error message for progress calculation/load (local Drift) failure.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-39 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-01 → FR-1 / AC-1**  
  * **SRS-FR-39 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-02 → FR-2 / AC-2**  
  * **SRS-FR-40 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-03 → FR-3 / AC-3 / SEC-1 / SEC-2**  
  * **SRS-FR-41 → SDS-COMP-10 → UC-SCR22-04 → FR-4 / NFR-1 / NFR-2 / AC-4**  
  * **SDS-ERR-5 / SDS-ERR-9 → UC-SCR22-05 → FR-5 / NFR-3 / EC-1**  
  * ~~**BR-NFR-020 → UC-SCR22-06 → FR-6 / NFR-4 / EC-2**~~ — Removed 2026-09-05, no connectivity condition exists  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-22 Inventory rows explicitly provide SRS-FR-39–SRS-FR-41, SDS-COMP-10, SDS-IF-8, SDS-DATA-7, SDS-ERR-5, SDS-ERR-9, and BR-NFR-020. The complete BRD mappings are not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**


## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: skeleton placeholder chart while calculating (§8 AC-1), the per-exercise empty state with the exact copy "Complete a few more workouts to see your progress" (§8 AC-2), the populated comparison view with an exercise selector, a weight-trend chart, and a latest-session stat row (§8 AC-3), and a load/calculation-failure error state with retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/0ae60956-1108-4f9f-b702-becad824cb17](https://claude.ai/code/artifact/0ae60956-1108-4f9f-b702-becad824cb17)  
* **Artifact title:** "ForgeApp Progress Comparison" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading — Placeholder Chart), Empty.dc.html (Insufficient History), Main.dc.html (Populated — Progress Comparison), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-21 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for the error card. This is a true root-tab screen (reached via the Progress tab, §10) and reuses the same 6-tab bottom nav bar established in SCR-06/08/12/20, with Progress shown active. Following the dataviz skill's guidance, the chart is a single-series line (one exercise viewed at a time via the chip selector) using thin 2px lime strokes with rounded data-point ends and one emphasized current-value dot — a single series needs no legend since the chart title already names it, and no dual-axis or rainbow-categorical coloring is used anywhere.  
* **Scope note:** the Inventory leaves the exact visual representation, chart type, exercise-switching mechanism, and volume calculation unspecified (§10) — the mockup uses a horizontally-scrollable chip row to switch exercises and a single weight-over-time line chart (with reps/volume surfaced as stat tiles below rather than additional chart series, avoiding a dual-axis chart) as one plausible presentation; these should be confirmed with the SRS/SDS owner. Duration is listed as an applicable metric for time-based exercises (§4 FR-3) but is not shown in this mockup's selected exercise (a weighted exercise); the same chart/stat-tile pattern would apply with a duration trend line for a time-based exercise, not a new layout. Silent exclusion of incomplete/invalid sessions (§8 AC-4) is a data-layer calculation rule with no distinct visual state, so it is not separately mocked — the populated chart already reflects only valid sessions.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
