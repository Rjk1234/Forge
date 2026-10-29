# **\#Forge-US-6**

# **1\. User Story Identification**

* **Story ID:** US-SCR-06  
* **Title:** Home Dashboard — Landing & Navigation  
* **Epic / Feature:** Home / Navigation Shell  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

As a user with the app unlocked, I want to access a Home Dashboard that provides an overview of my workout activity and navigation to the main workout features so that I can quickly access my plans, schedule, history, progress, and statistics.

# **3\. Description / Context**

*(Updated 2026-09-05, follow-up cleanup pass — Decisions Log §0: removes residual "authenticated"/connectivity-loss language inherited from the deprecated Firebase/Firestore architecture; no functional change to the dashboard's content or navigation.)*

SCR-06 is the landing screen and tab-navigation root of the Workout Tracker application.

The screen is reached after the local login-state check (SCR-01) resolves to unlocked, or after a matching static login on SCR-03, and serves as the primary navigation point once the app is unlocked.

The dashboard supports these states defined in the Inventory:

* **Empty** — no plans, schedule, or history yet exist.  
* **Loading** — dashboard summary data is being fetched (from the local Drift database).  
* **Populated** — the user has plans, schedule, and/or history.  
* **Error** — dashboard data cannot be loaded (a local Drift read failure) while the navigation shell remains usable.

~~**Offline** — connectivity is lost while the user is on Home.~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); reading local Drift data cannot fail due to lost connectivity, so there is no offline condition for this screen to handle.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an onboarding-style empty state when no plans, schedule, or history exist, prompting the user to **"Create your first workout plan"**. **(UC-SCR06-01, SRS-FR-9)**  
* **FR-2** — The system shall display a simple loading indicator while dashboard summary data is being fetched. **(UC-SCR06-02, SDS-IF-14; updated 2026-09-05 — simplified from skeleton/placeholder cards to a simple loading view, per product-owner decision, to keep the loading state minimal for now)**  
* **FR-3** — When the user has plans, schedule, or history data, the system shall display the user's today's scheduled workout, if any. **(UC-SCR06-03, SRS-FR-15)**  
* **FR-4** — The system shall provide quick links to Plans, Schedule, History, Progress, and Stats from the populated Home Dashboard. **(UC-SCR06-03, SRS-FR-24)**  
* **FR-5** — When dashboard data fails to load (a local Drift read failure), the system shall display an error state with a retry action while keeping the navigation shell usable. **(UC-SCR06-04, SDS-ERR-5; updated 2026-09-05 — local storage failure, not a network/Firestore failure)**  
* ~~**FR-6** — persistent offline banner~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR06-05 no longer applies.  
* ~~**FR-7** — stale/unavailable widgets while offline~~ — **REMOVED, 2026-09-05.** Not applicable for the same reason; FR-5's local-read-failure error state already covers the one genuinely local-equivalent case.

# **5\. Non-Functional Requirements**

* **NFR-1** — Dashboard summary data shall provide a simple loading state while the data is being fetched. **(UC-SCR06-02, SDS-IF-14; updated 2026-09-05 — simplified from skeleton/placeholder, matching FR-2)**  
* **NFR-2** — When dashboard data cannot be loaded, the navigation shell shall remain usable so that the user can continue navigating. **(UC-SCR06-04, SDS-ERR-5; updated 2026-09-05 — removes "authenticated areas," since there are no separate authenticated/unauthenticated areas beyond the local unlock gate)**  
* ~~**NFR-3** — persistent offline-condition indication~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR06-05 no longer applies.

# **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-06 shall be accessible only when the app's local login state is unlocked. **(Screen Auth Requirement: Required; SRS-FR-3, SRS-FR-6; updated 2026-09-05 — replaces "authenticated user," since there is only a local unlocked/locked flag, not real authentication)**  
* **SEC-2** — Dashboard information shall be presented within the current local session's application context. **(UC-SCR06-03, SRS-FR-15, SRS-FR-24; updated 2026-09-05)**  
* **SEC-3** — No additional security or privacy behavior is specified by the SCR-06 UC rows beyond the local-unlock access requirement. **(Screen Auth Requirement: Required; updated 2026-09-05)**

# **7\. UI / Component Specifications**

### **Dashboard Summary Area**

* **Component type:** Dashboard summary cards/widgets  
* **Input type:** System-provided dashboard data  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required when dashboard data is available.

### **Today's Scheduled Workout**

* **Component type:** Scheduled workout display/action  
* **Input type:** System-provided schedule data  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed if there is a scheduled workout for today.

### **Plans Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Schedule Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **History Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Progress Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Stats Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Empty State**

* **Component type:** Onboarding-style empty state  
* **Input type:** User action through **"Create your first workout plan"**  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when no plans, schedule, or history exist.

### **Loading State**

* **Component type:** Simple loading indicator (e.g., spinner) — no skeleton/placeholder cards for now **(Updated 2026-09-05)**  
* **Input type:** System state  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed while dashboard summary data is being fetched.

### **Error State**

* **Component type:** Error state  
* **Input type:** System state  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when dashboard data fails to load.

### **Retry Action**

* **Component type:** Retry action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the dashboard error state.

### ~~Offline Banner~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this component does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — New Account / Empty Dashboard**

**Given** the user has no plans, schedule, or history  
**When** the Home Dashboard is displayed  
**Then** the system shall show an onboarding-style empty state  
**And** the empty state shall prompt **"Create your first workout plan"**.  
**(UC-SCR06-01)**

### **AC-2 — Dashboard Loading**

**Given** dashboard summary data is being fetched  
**When** the Home Dashboard is loading  
**Then** the system shall display a simple loading indicator.  
**(UC-SCR06-02; updated 2026-09-05 — simplified from skeleton/placeholder cards)**

### **AC-3 — Populated Dashboard**

**Given** the user has plans, schedule, or history  
**When** dashboard data has loaded  
**Then** the Home Dashboard shall display today's scheduled workout, if any  
**And** provide quick links to Plans, Schedule, History, Progress, and Stats.  
**(UC-SCR06-03)**

### **AC-4 — Dashboard Data Failure**

**Given** the dashboard summary data cannot be loaded (a local Drift read failure)  
**When** the failure occurs  
**Then** the system shall display an error state  
**And** provide a retry action  
**And** keep the navigation shell usable.  
**(UC-SCR06-04; updated 2026-09-05)**

### ~~AC-5 — Offline Home Dashboard~~ — REMOVED, 2026-09-05

No connectivity condition exists (Decisions Log §0); UC-SCR06-05 no longer applies.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Dashboard Data Load Failure**

**Given** the user is on SCR-06 with the app unlocked  
**When** dashboard data fails to load (a local Drift read failure)  
**Then** the system shall show the defined error state with retry  
**And** the navigation shell shall remain usable.  
**(UC-SCR06-04; updated 2026-09-05)**

### ~~EC-2 — Connectivity Lost on Home~~ — REMOVED, 2026-09-05

No connectivity condition exists (Decisions Log §0); UC-SCR06-05 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 — Splash / Local Login-State Check  
  * SCR-03 — Login, after a matching local login  
* **REMOVED, 2026-09-05 (Decisions Log §0):** SCR-02 — Registration is DEPRECATED/OUT-OF-SCOPE; there is no registration flow, so it is not an entry dependency.  
* **Screen exit dependencies:**  
  * Plans → workout plan management screens.  
  * Schedule → scheduling screens.  
  * History → workout history screens.  
  * Progress → SCR-22.  
  * Stats → SCR-23.  
* **\[ASSUMPTION\] flag:** None specified for SCR-06.  
* **Underspecified behavior requiring confirmation:**  
  * Exact dashboard summary cards/widgets beyond today's scheduled workout and the specified quick links are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact error-state copy is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact behavior of the **"Create your first workout plan"** CTA after selection is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The Inventory does not specify whether each quick link is presented as a card, button, tab, or another visual component; therefore the specific presentation should not be inferred.  
* **Full-chain traceability summary:**

| Traceability Chain | User Story Coverage |
| ----- | ----- |
| **SRS-FR-9 → UC-SCR06-01** | FR-1, AC-1 |
| **SDS-IF-14 → UC-SCR06-02** | FR-2, NFR-1, AC-2 |
| **SRS-FR-15 → UC-SCR06-03** | FR-3, FR-4, AC-3 |
| **SRS-FR-24 → UC-SCR06-03** | FR-4, AC-3 |
| **SDS-ERR-5 → UC-SCR06-04** | FR-5, NFR-2, AC-4, EC-1 |
| ~~**BR-NFR-020 / SDS-COMP-13 → UC-SCR06-05**~~ | Removed 2026-09-05 — no connectivity condition exists |

*   
  **BRD → SRS → SDS → Inventory → User Story:**  
  **BRD-FR/NFR-003/020 → SRS-FR-9, SRS-FR-15, SRS-FR-24 / BR-NFR-020 → SDS-IF-14, SDS-ERR-5, SDS-COMP-13 → UC-SCR06-01 through UC-SCR06-05 → US-SCR-06.**

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering all five dashboard states defined in this story (§3, §8, §9): Empty, Loading, Populated (today's workout scheduled), Populated — No Workout Today, and Error.  
* **Tool:** Claude Design canvas (not Figma) — five artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/c449041f-bab6-4dbc-b30e-1f3b6e1304f5](https://claude.ai/code/artifact/c449041f-bab6-4dbc-b30e-1f3b6e1304f5)  
* **Artifact title:** "ForgeApp Home Dashboard" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Populated — Today's Workout), NoWorkoutToday.dc.html (Populated — No Workout Today), Empty.dc.html (Empty State), Loading.dc.html (Loading State), Error.dc.html (Error State).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, cyan quick-link icons `#7df4ff`.  
* **Scope note:** consistent with the FR-2/NFR-1 loading-state simplification and the confirmed strip of out-of-scope widgets — no Quick Stats grid, no Recent Activity feed, no Start Workout button, no Personal-Best card. Today's-workout card shows only what FR-3/FR-4 call for; the 5 quick links (Plans/Schedule/History/Progress/Stats) are plain icon+label tiles, since the Inventory doesn't specify their presentation (§10).  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

