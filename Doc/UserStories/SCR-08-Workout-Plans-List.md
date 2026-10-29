# **\#Forge-US-8**

# **1\. User Story Identification**

* **Story ID:** US-SCR08  
* **Title:** Workout Plans List  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As a user with the app unlocked, I want to view my workout plans in a dedicated list so that I can see the plans I have created and access them for further actions.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture. Plans are read from the local Drift database, which has no "no connectivity" failure mode; the existing recoverable Error State already covers the one genuinely local-equivalent concern, a local Drift read failure. No functional change to the list's loading, empty, populated, or navigation behavior.)*

SCR-08 is the entry screen for Workout Plan Management from the Plans tab. The screen displays the user's workout plans after they are retrieved from local storage.

The screen supports:

* Loading while plans are being fetched.  
* An empty state when no plans exist.  
* A populated list when one or more plans exist.  
* Navigation to create/edit a workout plan.  
* Navigation to view an existing workout plan.  
* Recoverable error handling when plans cannot be loaded (a local Drift read failure).

The screen requires the app's local login state to be unlocked.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading/skeleton state while workout plans are being fetched. **(UC-SCR08-01, SDS-IF-14)**  
* **FR-2** — When no workout plans have been created, the system shall display an empty state with a **"Create a workout plan"** call to action. **(UC-SCR08-02, BR-FR-003)**  
* **FR-3** — When one or more workout plans exist, the system shall display the user's workout plans as a list containing the plan name and a summary such as exercise count. **(UC-SCR08-03, SRS-FR-9, SDS-DATA-4)**  
* **FR-4** — The user shall be able to access the create/edit workout plan flow from the Workout Plans List. **(UC-SCR08-02, SRS-FR-9–SRS-FR-14)**  
* **FR-5** — The user shall be able to select an existing workout plan from the list to access its plan detail. **(UC-SCR08-03, SRS-FR-9–SRS-FR-14)**  
* **FR-6** — If workout plans fail to load (a local Drift read failure), the system shall display an error state with an available retry action. **(UC-SCR08-04, SDS-ERR-5; updated 2026-09-05 — local storage failure, not a network/Firestore failure)**  
* ~~**FR-7** — offline state when there is no connectivity~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); UC-SCR08-05 no longer applies. FR-6's local-read-failure error state already covers the one genuinely local-equivalent case.

# **5\. Non-Functional Requirements**

* **NFR-1** — The Workout Plans List shall provide a loading/skeleton state while plan data is being retrieved so that the user is not presented with an undefined loading condition. **(UC-SCR08-01, SDS-IF-14)**  
* **NFR-2** — When plan retrieval fails, the system shall provide a recoverable error state with retry rather than representing the plan data as successfully loaded. **(UC-SCR08-04, SDS-ERR-5)**  
* ~~**NFR-3** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR08-05 no longer applies.

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Workout Plans List shall require the app's local login state to be unlocked. **(UC-SCR08-03, SRS-FR-9–SRS-FR-14; updated 2026-09-05 — replaces "authenticated user session")**  
* **SR-2** — The populated plan list shall represent the workout plans stored locally on this device. **(UC-SCR08-03, SRS-FR-9, SDS-DATA-4; updated 2026-09-05 — replaces "belonging to the authenticated user's account," since there is a single local user and no cloud account)**

# **7\. UI / Component Specifications**

### **Workout Plans List**

* **Component type:** Screen/list  
* **Input type:** No direct user data input specified.  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for the general load failure.  
* **Mandatory / Optional:** Screen requires the app's local login state to be unlocked.

### **Loading State**

* **Component type:** Skeleton list  
* **Input type:** None  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required loading state.

### **Empty State**

* **Component type:** Empty state  
* **Input type:** None  
* **Action:** **"Create a workout plan"**  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when no plans exist.

### **Populated Plan List**

* **Component type:** Workout plan list  
* **Input type:** Selectable plan entries  
* **Displayed information:** Plan name and summary such as exercise count  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when one or more plans exist.

### **Error State**

* **Component type:** Error state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when plan loading fails.

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — Loading State**

**Given** the user opens the Workout Plans List and plans are being fetched,  
**When** the plan data has not yet been received,  
**Then** the system shall display the skeleton list state.  
**(UC-SCR08-01)**

### **AC-2 — Empty Workout Plans**

**Given** the user has no workout plans,  
**When** the Workout Plans List is displayed,  
**Then** the system shall display the empty state with a **"Create a workout plan"** call to action.  
**(UC-SCR08-02)**

### **AC-3 — Populated Workout Plans**

**Given** the user has one or more workout plans,  
**When** the plan data is successfully loaded,  
**Then** the system shall display a list of named workout plans with a summary such as exercise count.  
**(UC-SCR08-03)**

### **AC-4 — Plan Access**

**Given** the Workout Plans List contains existing plans,  
**When** the user selects a workout plan,  
**Then** the system shall provide access to the corresponding plan detail.  
**(UC-SCR08-03)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Plan Load Failure**

**Given** the Workout Plans List is being loaded,  
**When** the plans fail to load (a local Drift read failure),  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR08-04; updated 2026-09-05)**

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR08-05 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-06 — Home Dashboard / Plans tab.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan.  
  * SCR-10 — Plan Detail.  
* **\[ASSUMPTION\] flag:**  
  Not specified for SCR-08.  
* **Underspecified behavior:**  
  * The Inventory specifies that the empty state contains a **"Create a workout plan"** CTA but does not explicitly define the exact navigation behavior of that CTA. Confirm with SRS/SDS owner.  
  * The Inventory specifies a retry action for the error state but does not define its exact UI presentation or error copy. Confirm with SRS/SDS owner.  
  * The Inventory specifies a plan summary "such as exercise count" but does not establish the complete set of summary fields. Confirm with SRS/SDS owner.  
  * The Inventory does not explicitly define the behavior when a user selects an individual plan from the populated list beyond the screen's exit point to SCR-10. Confirm with SRS/SDS owner.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| BR-FR-003 | — | — | UC-SCR08-02 | FR-2, AC-2 |
| BR-FR-003 / relevant BRD trace via SRS | SRS-FR-9–14 | SDS-COMP-5, SDS-DATA-4 | UC-SCR08-03 | FR-3, FR-5, SR-2, AC-3, AC-4 |
| Not directly specified in UC row | — | SDS-IF-14 | UC-SCR08-01 | FR-1, NFR-1, AC-1 |
| Not directly specified in UC row | — | SDS-ERR-5 | UC-SCR08-04 | FR-6, NFR-2, EC-1 |
| ~~BR-NFR-020 — UC-SCR08-05~~ | — | — | Removed 2026-09-05 | no connectivity condition exists |

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the states defined in this story: Populated Plan List (§8 AC-3), Empty State (§8 AC-2), Loading — Skeleton List (§8 AC-1), and Plan Load Failure (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/a78f11f8-6f04-461e-a6c5-aa657dbd845f](https://claude.ai/code/artifact/a78f11f8-6f04-461e-a6c5-aa657dbd845f)  
* **Artifact title:** "ForgeApp Workout Plans List" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Populated Plan List), Empty.dc.html (Empty State), Loading.dc.html (Loading — Skeleton List), Error.dc.html (Plan Load Failure).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06/SCR-07 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`.  
* **Scope note:** each plan row shows only plan name and exercise count, matching FR-3's "plan name and a summary such as exercise count" — no per-plan type tags, schedule info, or other metadata was added, since none is specified in the Inventory (§10). A persistent lime "+" button in the top-right of the header (present in the populated state) covers FR-4's "access the create/edit workout plan flow from the Workout Plans List" for the case where plans already exist; the empty state instead surfaces this as its required "Create a workout plan" CTA (§8 AC-2), so the two aren't duplicated on one screen.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

