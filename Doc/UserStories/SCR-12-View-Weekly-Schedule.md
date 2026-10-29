# **Forge-US-12**

# **1\. User Story Identification**

* **Story ID:** US-SCR12  
* **Title:** View Weekly Workout Schedule  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As a user with the app unlocked, I want to view my weekly workout schedule so that I can see which workout plans are scheduled for each day and start today's scheduled workout.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: drops remaining "authenticated" wording; the local-unlock gating is unchanged from NFR-2 below, only the terminology is corrected.)*

SCR-12 provides the user, once the app is unlocked, a weekly view of their scheduled workout plans.

The screen supports loading, empty, populated, and today's scheduled-workout states. It also provides navigation to SCR-13 for assigning/editing schedules and SCR-15 for starting a scheduled workout.

The screen is available only when the app's local login state is unlocked.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading skeleton for the weekly schedule while schedule data is being fetched. **(UC-SCR12-01, SRS-FR-15)**  
* **FR-2** — When no plans are scheduled on any day, the system shall display an empty state per day or an overall empty state with a "Schedule a plan" call to action. **(UC-SCR12-02, SRS-FR-15)**  
* **FR-3** — When one or more plans are scheduled, the system shall display a weekly view showing which workout plan(s) are scheduled on which day(s), including recurring assignments. **(UC-SCR12-03, SRS-FR-16)**  
* **FR-4** — When a scheduled workout falls on the current day, the system shall surface a "Start" action for today's scheduled workout. **(UC-SCR12-04, SRS-FR-24)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The weekly schedule shall provide a visible loading state while schedule data is being fetched. **(UC-SCR12-01, SDS-IF-14)**  
* **NFR-2** — The screen shall require the app's static local login state to be unlocked (Decisions Log §0 — this is not real authentication). **(UC-SCR12-01, SRS-FR-15)**  
* ~~**NFR-3** — offline state~~ — **REMOVED, 2026-09-05.** The app is fully offline/local-only (Decisions Log §0); UC-SCR12-06 and its offline-state handling no longer apply.  
* **NFR-4** — No additional measurable non-functional requirement is specified for SCR-12 in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the weekly schedule shall require the app's local login state to be unlocked. **(UC-SCR12-03, SRS-FR-16; updated 2026-09-05 — replaces "require authentication")**  
* **SEC-2** — The screen shall not expose schedule information while the app's local login state is locked. **(UC-SCR12-03, SRS-FR-16; updated 2026-09-05 — replaces "not authenticated")**  
* **SEC-3** — No SCR-12-specific security requirement is explicitly mapped to SRS-NFR-8 through SRS-NFR-12 or SDS-COMP-14 in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **7\. UI / Component Specifications**

### **Weekly Schedule View**

* **Component type:** Weekly schedule view/grid  
* **Input type:** Schedule data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required

### **Scheduled Workout Plan Entry**

* **Component type:** Scheduled workout plan entry  
* **Input type:** Scheduled plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Displayed when scheduled plans exist

### **Start Action**

* **Component type:** Action  
* **Input type:** User tap  
* **Validation rules:** Available for today's scheduled workout  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Conditional

### **Schedule a Plan CTA**

* **Component type:** Call-to-action  
* **Input type:** User tap  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Conditional; displayed in the empty state

### **Loading State**

* **Component type:** Skeleton weekly grid  
* **Input type:** Loading state  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Required while schedule data is being fetched

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this UI state does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — Schedule Loading**

**(UC-SCR12-01)**

**Given** the app is unlocked and the weekly schedule is being fetched  
**When** SCR-12 is displayed  
**Then** the system shall display a skeleton weekly grid until the schedule data is available.

### **AC-2 — Empty Weekly Schedule**

**(UC-SCR12-02)**

**Given** the user has no plans scheduled on any day  
**When** the weekly schedule is displayed  
**Then** the system shall display an empty state per day or an overall empty state with a "Schedule a plan" call to action.

### **AC-3 — Populated Weekly Schedule**

**(UC-SCR12-03)**

**Given** the user has one or more scheduled workout plans  
**When** the weekly schedule is displayed  
**Then** the system shall show which plan(s) are scheduled on which day(s)  
**And** recurring assignments shall be represented in the weekly view.

### **AC-4 — Start Today's Scheduled Workout**

**(UC-SCR12-04)**

**Given** a workout plan is scheduled for the current day  
**When** the user views SCR-12  
**Then** the system shall surface a "Start" action for today's scheduled workout  
**And** selecting the action shall proceed to SCR-15.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Schedule Load Failure**

**(UC-SCR12-05)**

**Given** the user opens SCR-12  
**When** the schedule fails to load  
**Then** the system shall display an error state with a retry action.

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR12-06 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:**  
  * **Entry:** SCR-06 — Home Dashboard, through the Schedule tab.  
  * **Exit:** SCR-13 — Assign/Edit Schedule, for adding or editing schedule assignments.  
  * **Exit:** SCR-15 — Workout Pre-Start / Overview, when starting today's scheduled workout.  
* **\[ASSUMPTION\] flag:** None specified for SCR-12.  
* **Underspecified behavior:**  
  * The Inventory allows either an empty state per day or an overall empty state when no plans are scheduled. The exact presentation should be confirmed during design.  
  * The Inventory does not specify the exact visual structure of the weekly grid.  
  * The Inventory does not specify exact error-state copy for schedule-load failure.  
  * Not applicable — one plan per day maximum means there is no multi-plan-per-day display-order case (Decisions Log §4).  
  * The Inventory does not specify the exact behavior for selecting a scheduled plan other than the explicitly defined "Start" action for today's scheduled workout.  
* **Full-chain traceability summary:**  
  * **UC-SCR12-01 → FR-1, NFR-1, AC-1**  
  * **UC-SCR12-02 → FR-2, AC-2**  
  * **UC-SCR12-03 → FR-3, SEC-1, SEC-2, AC-3**  
  * **UC-SCR12-04 → FR-4, AC-4**  
  * **UC-SCR12-05 → EC-1**  
  * **UC-SCR12-06 → NFR-3, EC-2**  
  * **BRD → SRS → SDS → Inventory → User Story:** BR-FR-015 / related scheduling requirements → SRS-FR-15, SRS-FR-16, SRS-FR-24 → SDS-COMP-6, SDS-IF-5, SDS-DATA-5, SDS-ERR-5 → UC-SCR12-\* → this story.

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: Populated Weekly Schedule (§8 AC-3/AC-4), Empty State (§8 AC-2), Loading — Skeleton Grid (§8 AC-1), and Schedule Load Failure (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/197c0750-693e-409e-9034-d858cccfb0ff](https://claude.ai/code/artifact/197c0750-693e-409e-9034-d858cccfb0ff)  
* **Artifact title:** "ForgeApp Weekly Schedule" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Populated Weekly Schedule), Empty.dc.html (Empty State), Loading.dc.html (Loading — Skeleton Grid), Error.dc.html (Schedule Load Failure).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06/07/08/09/10/11 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`.  
* **Scope note:** presented as a 7-row day list (Mon–Sun), one plan per day maximum per Decisions Log §4 — no multi-plan-per-day case was designed, consistent with that decision. Today's row is highlighted and shows the required Start action (FR-4); other scheduled days show a small edit (pencil) affordance toward SCR-13, and unscheduled days show a plain "Rest day" label — neither is specified in the Inventory beyond the screen's general navigation to SCR-13, so treat the pencil affordance as illustrative. The Inventory allows either a per-day empty state or one overall empty state; this reference used the overall empty state with "Schedule a plan," per §10's note that the exact presentation should be confirmed during design.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

