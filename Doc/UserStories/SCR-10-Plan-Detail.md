# **\#Forge-US-10**

# **1\. User Story Identification**

* **Story ID:** US-SCR10  
* **Title:** Plan Detail  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

As a user with the app unlocked, I want to view the details of a workout plan so that I can review its exercises and targets and access actions to edit, delete, start, or schedule the plan.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture. Plan data is read from the local Drift database, which has no "no connectivity" failure mode; the existing Error/Not-Found state already covers the one genuinely local-equivalent concern, a local Drift read failure. No functional change to the detail view or its actions.)*

SCR-10 is the Plan Detail screen within the Workout Plan Management flow.

The screen is accessed from the Workout Plans List or after successfully saving a workout plan. It presents the selected workout plan and its configured exercise targets.

When the plan is successfully loaded, the user can access the actions defined by the Inventory:

* Edit  
* Delete  
* Start Workout  
* Schedule

The screen also supports a loading state while the plan is being fetched (from the local Drift database) and an error/not-found state when the plan cannot be loaded.

The screen requires the app's local login state to be unlocked.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a skeleton state while the selected workout plan is being fetched. **(UC-SCR10-01, SDS-IF-14)**  
* **FR-2** — When the workout plan is successfully loaded, the system shall display the plan name and its exercise list with configured targets. **(UC-SCR10-02, SRS-FR-9, SDS-DATA-4)**  
* **FR-3** — When the workout plan is loaded, the system shall provide an Edit action for the plan. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-4** — When the workout plan is loaded, the system shall provide a Delete action for the plan. **(UC-SCR10-02, SRS-FR-14)**  
* **FR-5** — When the workout plan is loaded, the system shall provide a Start Workout action. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-6** — When the workout plan is loaded, the system shall provide a Schedule action. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-7** — If the selected workout plan cannot be loaded (a local Drift read failure), including when the plan has been deleted elsewhere, the system shall display an error/not-found state with a back action. **(UC-SCR10-03, SDS-ERR-5; updated 2026-09-05)**  
* ~~**FR-8** — offline state when there is no connectivity~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); UC-SCR10-04 no longer applies. FR-7's error/not-found state already covers the one genuinely local-equivalent case.

# **5\. Non-Functional Requirements**

* **NFR-1** — The Plan Detail screen shall provide a skeleton state while plan data is being retrieved. **(UC-SCR10-01, SDS-IF-14; SRS-NFR not specified in Inventory)**  
* **NFR-2** — If plan retrieval fails, the system shall present a recoverable error/not-found state with a back action rather than displaying incomplete plan information as valid data. **(UC-SCR10-03, SDS-ERR-5; SRS-NFR not specified in Inventory)**  
* ~~**NFR-3** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR10-04 no longer applies.

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Plan Detail screen shall require the app's local login state to be unlocked. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14; updated 2026-09-05 — replaces "authenticated user session")**  
* **SR-2** — The Plan Detail screen shall display only the workout plan data stored locally on this device. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14, SDS-DATA-4; updated 2026-09-05 — drops "authenticated user's," since there is a single local user)**  
* **SR-3** — If the requested plan cannot be accessed or no longer exists, the system shall not display incomplete plan information and shall instead provide the defined error/not-found state. **(UC-SCR10-03, SDS-ERR-5; updated 2026-09-05 — drops "unauthorized," since there is no multi-user access control)**

# **7\. UI / Component Specifications**

### **Plan Detail**

* **Component type:** Detail screen  
* **Input type:** No direct user data input specified.  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Requires the app's local login state to be unlocked.

### **Plan Information**

* **Component type:** Plan information display  
* **Input type:** Read-only  
* **Displayed information:** Plan name  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when the plan is successfully loaded.

### **Exercise List**

* **Component type:** Exercise list  
* **Input type:** Read-only plan data  
* **Displayed information:** Exercise list with configured targets  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when the plan is successfully loaded.

### **Edit Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Delete Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Start Workout Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Schedule Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Loading State**

* **Component type:** Skeleton  
* **Input type:** None  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed while the plan is being fetched.

### **Error / Not-Found State**

* **Component type:** Error / not-found state  
* **Input type:** Back action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Exact error/not-found copy not specified in Inventory.  
* **Mandatory / Optional:** Displayed when the plan fails to load or is unavailable.

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — Loading Plan**

**Given** the user opens the Plan Detail screen and the selected plan is being fetched,  
**When** the plan data has not yet been received,  
**Then** the system shall display the skeleton state.  
**(UC-SCR10-01)**

### **AC-2 — Display Plan Details**

**Given** the selected workout plan exists and is successfully loaded,  
**When** the Plan Detail screen is displayed,  
**Then** the system shall show the plan name and exercise list with configured targets.  
**(UC-SCR10-02)**

### **AC-3 — Available Plan Actions**

**Given** the workout plan has been successfully loaded,  
**When** the user views the Plan Detail screen,  
**Then** the screen shall provide Edit, Delete, Start Workout, and Schedule actions.  
**(UC-SCR10-02)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Plan Load Failure / Plan Not Found**

**Given** the user attempts to open a workout plan,  
**When** the plan fails to load, including because it was deleted elsewhere,  
**Then** the system shall display an error/not-found state with a back action.  
**(UC-SCR10-03)**

### ~~EC-2 — Offline~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR10-04 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-08 — Workout Plans List.  
  * SCR-09 — Create / Edit Workout Plan, after successful save.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan through Edit.  
  * SCR-11 — Delete Plan Confirmation through Delete.  
  * SCR-15 — Workout Pre-Start / Overview through Start Workout.  
  * SCR-13 — Assign / Edit Schedule through Schedule.  
* **\[ASSUMPTION\] flag:**  
  None specified for SCR-10.  
* **Underspecified behavior:**  
  * The Inventory identifies Edit, Delete, Start Workout, and Schedule as available actions but does not define the exact navigation behavior of each action within the UC row. The screen's Exit Points establish the destination screens; confirm detailed interaction behavior with the SRS/SDS owner.  
  * The exact error/not-found message is not specified in the Inventory — confirm with SRS/SDS owner.  
  * The Inventory does not specify the exact set of target fields displayed for each exercise beyond "targets" — confirm with SRS/SDS owner.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| Relevant BRD trace | SRS-FR-9–14 | SDS-DATA-4, SDS-COMP-5 | UC-SCR10-02 | FR-2–FR-6, SR-1–SR-2, AC-2–AC-3 |
| Not specified in Inventory | — | SDS-IF-14 | UC-SCR10-01 | FR-1, NFR-1, AC-1 |
| Not specified in Inventory | — | SDS-ERR-5 | UC-SCR10-03 | FR-7, NFR-2, SR-3, EC-1 |
| ~~BR-NFR-020 — UC-SCR10-04~~ | — | — | Removed 2026-09-05 | no connectivity condition exists |

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the three states defined in this story: Populated Plan Detail (§8 AC-2/AC-3), Loading — Skeleton (§8 AC-1), and Error / Not Found (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — three artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/c6bc9b70-dea9-4664-ba32-eaa0016dc478](https://claude.ai/code/artifact/c6bc9b70-dea9-4664-ba32-eaa0016dc478)  
* **Artifact title:** "ForgeApp Plan Detail" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Populated Plan Detail), Loading.dc.html (Loading — Skeleton), ErrorNotFound.dc.html (Error / Not Found).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06/07/08/09 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, cyan for the `weighted` type dot.  
* **Scope note:** the exercise cards reuse the same read-only weighted/time-based/bodyweight target layout as the SCR-09 reference (one exercise of each type), matching FR-2's "exercise list with configured targets." All four required actions (FR-3–FR-6) are shown without adding others: Edit and Delete as header icon buttons, Schedule as a secondary footer button, Start Workout as the primary footer button — reflecting Start Workout's role as the plan's main action, per this story's own exit-dependency list (§10). Exact navigation behavior per action and the error/not-found copy are not specified in the Inventory — confirm with the SRS/SDS owner before treating as final.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

