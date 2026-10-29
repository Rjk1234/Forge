# **\#Forge-US-7**

# **1\. User Story Identification**

* **Story ID:** US-SCR-07  
* **Title:** Browse and Select Exercises  
* **Epic / Feature:** Exercise Catalogue  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

**As a user with the app unlocked, I want to browse and search the exercise catalogue so that I can find and select a valid exercise for viewing or adding to a workout plan.**

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: this story previously carried residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture. The exercise catalogue is fixed, developer-seeded content read from the local Drift database on-device (Decisions Log §7); it never depends on network connectivity, so the prior offline state is removed rather than reframed — there is no "no internet" condition for a local read. The catalogue-loading Error State below already covers the one genuinely local-equivalent concern, a local Drift read failure. No functional change to browsing, search, or picker-mode selection.)*

SCR-07 provides access to the shared exercise catalogue. The screen supports both standalone browse mode and picker mode when accessed from SCR-09 — Create / Edit Workout Plan.

The catalogue is read-only reference data. In picker mode, selecting a valid exercise adds that exercise to the in-progress workout plan on SCR-09.

The screen must also handle loading, empty search results, invalid exercise references, and catalogue-loading (local Drift read) failures as defined by the Inventory.

# **4\. Functional Requirements**

* **FR-1** — The system shall display the exercise catalogue as a list/grid when the catalogue has successfully loaded. **(UC-SCR07-02, SRS-FR-7)**  
* **FR-2** — The system shall allow the user to search the exercise catalogue. **(UC-SCR07-02, SRS-FR-7; updated 2026-09-05 — drops "authenticated," since access is gated only by the app's local unlocked state)**  
* **FR-3** — The system shall support filtering/searching such that when the search or filter produces no matching exercises, the screen displays the specified empty state. **(UC-SCR07-03, SRS-FR-8)**  
* **FR-4** — In picker mode, the system shall allow the user to select a valid exercise from the catalogue and add it to the in-progress workout plan on SCR-09. **(UC-SCR07-04, SRS-FR-8)**  
* **FR-5** — The system shall reject an exercise reference that is not present in the catalogue and shall prevent that exercise from being added to the workout plan. **(UC-SCR07-05, SRS-FR-48)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The exercise catalogue shall require the app's local login state to be unlocked; while locked, the catalogue is not accessible. **(UC-SCR07-02, SRS-FR-7; updated 2026-09-05 — replaces "authenticated access"/"unauthenticated users," since there is no real authentication, only a local unlocked/locked flag)**  
* ~~**NFR-2** — offline state when catalogue data cannot be retrieved~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); the catalogue is read from the local Drift database, which has no "no connectivity" failure mode. UC-SCR07-07 no longer applies.

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the exercise catalogue shall require the app's local login state to be unlocked. **(UC-SCR07-02, SRS-FR-7; updated 2026-09-05 — replaces "authenticated user session")**  
* **SEC-2** — An exercise reference that is not present in the valid catalogue shall be rejected before it can be added to a workout plan. **(UC-SCR07-05, SRS-FR-48)**

# **7\. UI / Component Specifications**

### **Exercise Catalogue**

* **Component type:** Searchable/filterable exercise list/grid.  
* **Input type:** Search/filter input.  
* **Validation rules:** Search/filter shall operate against the available exercise catalogue.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for invalid search/filter input.  
* **Mandatory / Optional:** Search/filter is optional; the catalogue itself is the primary content.

### **Exercise Item / Selection**

* **Component type:** Exercise list/grid item.  
* **Input type:** Selection action.  
* **Validation rules:** Only exercises present in the catalogue may be selected for addition in picker mode.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for rejected invalid exercise references.  
* **Mandatory / Optional:** Exercise selection is applicable only in picker mode.

### **Loading State**

* **Component type:** Skeleton list.  
* **Input type:** None.  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Required while catalogue data is being fetched.

### **Empty State**

* **Component type:** Empty-state message.  
* **Input type:** None.  
* **Validation rules:** Displayed when search/filter produces no results.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error message:** **"No exercises match your search"**  
* **Mandatory / Optional:** Required for the no-results condition.

### **Error State**

* **Component type:** Error state with retry action.  
* **Input type:** Retry action.  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required when catalogue loading fails.

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); the catalogue is local Drift content, not a cache of a remote source, so this state does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — Catalogue Loading**

**UC-SCR07-01**

**Given** the user opens SCR-07 with the app unlocked and the exercise catalogue is being fetched (from the local Drift database),  
**When** the catalogue data has not yet been resolved,  
**Then** the system shall display the skeleton list and shall not display the catalogue as populated.

### **AC-2 — Catalogue Populated**

**UC-SCR07-02**

**Given** the user opens SCR-07 with the app unlocked and the exercise catalogue has loaded,  
**When** the catalogue is available,  
**Then** the system shall display a list/grid of exercises and allow the catalogue to be searched.

### **AC-3 — No Search Results**

**UC-SCR07-03**

**Given** the exercise catalogue is displayed,  
**When** the user's search/filter produces no matching exercises,  
**Then** the system shall display **"No exercises match your search"**.

### **AC-4 — Select Exercise in Picker Mode**

**UC-SCR07-04**

**Given** SCR-07 has been opened in picker mode from SCR-09 and a valid exercise is present in the catalogue,  
**When** the user selects that exercise,  
**Then** the exercise shall be added to the in-progress workout plan on SCR-09.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Invalid Exercise Reference**

**UC-SCR07-05**

**Given** an exercise reference is attempted that is not present in the exercise catalogue,  
**When** the system validates the exercise reference,  
**Then** the selection shall be rejected and the exercise shall not be added to the workout plan.

### **EC-2 — Catalogue Load Failure**

**UC-SCR07-06**

**Given** the user attempts to access the exercise catalogue,  
**When** catalogue loading fails,  
**Then** the system shall display an error state with a retry action.

### ~~EC-3 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); UC-SCR07-07 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-06 — Home Dashboard, when accessed in standalone browse mode.  
  * SCR-09 — Create / Edit Workout Plan, when accessed in picker mode.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan, after selecting an exercise in picker mode.  
  * Back navigation in browse mode.  
* **\[ASSUMPTION\] flag:** None specified for SCR-07.  
* **Underspecified behavior:**  
  * Inventory does not specify the exact search/filter mechanism, search matching rules, filtering criteria, or minimum/maximum search input constraints.  
  * Inventory does not specify the exact error message for UC-SCR07-05 invalid exercise reference.  
  * Inventory does not specify the exact error message for UC-SCR07-06 catalogue-load (local Drift read) failure.  
  * These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-7 → SDS-DATA-3 / SDS-IF-14 → UC-SCR07-01 / UC-SCR07-02 → FR-1, FR-2, NFR-1, AC-1, AC-2**  
  * **SRS-FR-8 → SDS-COMP-4 / SDS-IF-14 / SDS-DATA-3 → UC-SCR07-03 / UC-SCR07-04 → FR-3, FR-4, AC-3, AC-4**  
  * **SRS-FR-48 → SDS-COMP-12 / SDS-DATA-8 → UC-SCR07-05 → FR-5, SEC-2, EC-1**  
  * ~~**BR-NFR-020 → Appendix C (SDS) → UC-SCR07-07 → NFR-2, EC-3**~~ — Removed 2026-09-05, no connectivity condition exists  
  * **SDS-ERR-5 → UC-SCR07-06 → EC-2**

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the states defined in this story: Browse Mode — Populated (§8 AC-2), Picker Mode (entered from SCR-09, §10 entry dependency), No Search Results (§7/§8 AC-3), Loading — Skeleton List (§7/§8 AC-1), and Catalogue Load Failure (§7/§9 EC-2).  
* **Tool:** Claude Design canvas (not Figma) — five artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/6fd5576a-d64c-4f80-aa30-4a5b79b37c20](https://claude.ai/code/artifact/6fd5576a-d64c-4f80-aa30-4a5b79b37c20)  
* **Artifact title:** "ForgeApp Exercise Catalogue" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Browse Mode — Populated), PickerMode.dc.html (Picker Mode), Empty.dc.html (No Search Results), Loading.dc.html (Loading — Skeleton List), Error.dc.html (Catalogue Load Failure).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 Home Dashboard reference — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, cyan accent `#7df4ff`.  
* **Scope note:** exercise rows show name and type only (weighted/time-based/bodyweight dot, per Decisions Log §5) — no muscle-group, equipment, or other metadata, since none is specified in the Inventory (§10). Filter chips (All/Weighted/Time-based/Bodyweight) implement FR-3's "filtering/searching" wording directly against the confirmed exercise-type flag, not an invented feature. Picker mode shows an add (+) icon per row instead of a chevron, and a banner naming the destination plan, to reflect FR-4/AC-4 (tap-to-add, no separate confirm/done step specified).  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

