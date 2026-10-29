# **\#Forge-US-13**

# **1\. User Story Identification**

* **Story ID:** US-SCR13  
* **Title:** Assign / Edit Schedule for a Workout Plan  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As a user with the app unlocked, I want to assign or edit a workout plan's schedule so that I can define the day(s) on which the plan should be scheduled and whether the assignment recurs.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: drops remaining "authenticated" wording; the local-unlock gating is unchanged from NFR-2 below, only the terminology is corrected.)*

SCR-13 allows a user, once the app is unlocked, to create a new schedule assignment or edit an existing schedule entry for a workout plan.

For a new assignment, no days are selected initially and saving remains unavailable until at least one valid day is chosen. When editing an existing schedule entry, the current day selection and recurrence setting are pre-filled.

The system validates that the referenced workout plan is available and that the scheduling configuration is valid before allowing the schedule to be saved. Recurrence is **weekly-only**: an assignment repeats every week on the selected weekday(s); there is no specific-date/non-recurring or calendar-based scheduling. **One plan per day maximum** — a given weekday can hold at most one scheduled plan, so attempting to assign a plan to a weekday that already has a different plan scheduled is a conflicting scheduling rule and is rejected. *(Confirmed per Decisions Log §4, 2026-09-05.)*

On successful save, the user returns to SCR-12 with the updated weekly schedule, while existing workout history remains unaffected.

# **4\. Functional Requirements**

* **FR-1** — For a new schedule assignment, the system shall initially have no days selected and shall keep the save action disabled until at least one valid day is chosen. **(UC-SCR13-01, SRS-FR-15)**  
* **FR-2** — When editing an existing schedule entry, the system shall pre-fill the current day selection and recurrence setting. **(UC-SCR13-02, SRS-FR-19)**  
* **FR-3** — The system shall prevent saving when the referenced workout plan is invalid or unavailable and shall display an explanatory message. **(UC-SCR13-03, SRS-FR-21)**  
* **FR-4** — The system shall prevent saving when the scheduling configuration is invalid — specifically, when the user attempts to assign a plan to a weekday that already has a different plan scheduled (more than one plan per day is not allowed) — and shall display an inline error. **(UC-SCR13-04, SRS-FR-22; updated per Decisions Log §4, 2026-09-05 — "one plan per day max" is now the explicit conflict rule, replacing the previously generic "conflicting or duplicate" wording)**  
* **FR-5** — The system shall display a loading state when a schedule save operation is submitted. **(UC-SCR13-05, SRS-FR-15–SRS-FR-23; exact SRS mapping for loading behavior is not explicitly specified in the UC row)**  
* **FR-6** — When the schedule is successfully saved, the system shall route the user to SCR-12 with the updated weekly schedule. **(UC-SCR13-06, SRS-FR-16)**  
* **FR-7** — Saving or editing a schedule shall not alter existing workout history. **(UC-SCR13-06, SRS-FR-23)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The schedule save action shall provide a visible loading state while the save operation is being processed. **(UC-SCR13-05, SDS-IF-5)**  
* **NFR-2** — The screen shall require the app's static local login state to be unlocked (Decisions Log §0 — this is not real authentication). **(UC-SCR13-01, SRS-FR-15)**  
* ~~**NFR-3** — offline state~~ — **REMOVED, 2026-09-05.** The app is fully offline/local-only (Decisions Log §0); there is no connectivity condition. UC-SCR13-08 and its offline-state handling no longer apply.  
* **NFR-4** — No additional screen-specific non-functional requirement is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to schedule assignment and editing shall require the app's local login state to be unlocked. **(UC-SCR13-01, SRS-FR-15; updated 2026-09-05 — replaces "require authentication")**  
* **SEC-2** — Schedule changes shall not affect existing workout history. **(UC-SCR13-06, SRS-FR-23)**  
* **SEC-3** — No SCR-13-specific security requirement mapped to SRS-NFR-8 through SRS-NFR-12 or SDS-COMP-14 is explicitly identified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **7\. UI / Component Specifications**

### **Plan Selector**

* **Component type:** Plan selector  
* **Input type:** Workout plan selection  
* **Validation rules:** Referenced plan must be valid and available  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Explanatory message when referenced plan is invalid/unavailable; exact wording not specified  
* **Mandatory / Optional flags:** Required when a plan is not pre-selected

### **Day-of-Week Selection**

* **Component type:** Day-of-week selection  
* **Input type:** Day selection  
* **Validation rules:** At least one valid day must be selected before saving  
* **Min / Max constraints:** Minimum 1 valid day; maximum not specified  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required

### **Recurrence Toggle**

* **Component type:** Recurrence toggle  
* **Input type:** Toggle selection  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Not specified in Inventory

### **Save Action**

* **Component type:** Save action  
* **Input type:** User tap  
* **Validation rules:** Save is blocked until the schedule configuration is valid  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Inline error for invalid scheduling configuration  
* **Mandatory / Optional flags:** Required to persist the schedule

### **Loading State**

* **Component type:** Loading state  
* **Input type:** Save-operation state  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while save is being processed

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this UI state does not apply and has been removed.

# **8\. Acceptance Criteria**

### **AC-1 — New Schedule Assignment**

**(UC-SCR13-01)**

**Given** the user is creating a new schedule assignment  
**When** SCR-13 is opened  
**Then** no days shall be selected initially  
**And** the save action shall remain disabled until at least one valid day is chosen.

### **AC-2 — Edit Existing Schedule**

**(UC-SCR13-02)**

**Given** the user is editing an existing schedule entry  
**When** SCR-13 is opened  
**Then** the current day selection shall be pre-filled  
**And** the current recurrence setting shall be pre-filled.

### **AC-3 — Successful Schedule Save**

**(UC-SCR13-06)**

**Given** the schedule configuration is valid  
**When** the user saves the schedule successfully  
**Then** the system shall route the user to SCR-12  
**And** the weekly schedule shall reflect the updated schedule  
**And** existing workout history shall remain unaffected.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Invalid or Unavailable Plan**

**(UC-SCR13-03)**

**Given** the schedule references a workout plan  
**When** that plan is invalid or unavailable  
**Then** the system shall block the selection/save operation  
**And** display an explanatory message.

### **EC-2 — Invalid Scheduling Configuration**

**(UC-SCR13-04)**

**Given** the user has configured a schedule  
**When** the configuration contains a conflicting or duplicate scheduling rule  
**Then** the system shall display an inline error  
**And** block saving the schedule.

### **EC-3 — Schedule Save Loading**

**(UC-SCR13-05)**

**Given** the user has submitted a schedule for saving  
**When** the save operation is being processed  
**Then** the system shall display a loading state.

### **EC-4 — Schedule Save Failure**

**(UC-SCR13-07)**

**Given** the user has submitted a valid schedule  
**When** saving the schedule fails  
**Then** the system shall display an error state  
**And** provide a retry option.

### ~~EC-5 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR13-08 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:**  
  * **Entry:** SCR-10 — Plan Detail, through the Schedule action.  
  * **Entry:** SCR-12 — Weekly Schedule View, through the add/edit schedule action.  
  * **Exit:** SCR-12 — Weekly Schedule View, on successful save or cancel.  
* **\[ASSUMPTION\] flag:** None specified for SCR-13.  
* **Underspecified behavior:**  
  * The Inventory does not define the exact explanatory message for an invalid/unavailable workout plan.  
  * The Inventory does not define the exact inline error copy for conflicting/duplicate scheduling configurations.  
  * The Inventory does not specify the exact recurrence options or default recurrence value.  
  * The Inventory does not specify the maximum number of selectable days (a plan may be assigned to multiple weekdays; each such weekday is still capped at one plan — Decisions Log §4).  
  * UC-SCR13-05 is classified as Loading and traces to SDS-IF-5; the exact underlying SRS requirement for the loading state is not explicitly identified in that UC row.  
  * The exact error message for the schedule-save system failure is not specified.  
* **Full-chain traceability summary:**

| Inventory UC | Story Item | Upstream Trace |
| ----- | ----- | ----- |
| UC-SCR13-01 | FR-1, NFR-2, SEC-1, AC-1 | SRS-FR-15 → SDS-COMP-6 / SDS-IF-5 / SDS-DATA-5 → UC-SCR13-01 |
| UC-SCR13-02 | FR-2, AC-2 | SRS-FR-19 → SDS-DATA-5 → UC-SCR13-02 |
| UC-SCR13-03 | FR-3, EC-1 | SRS-FR-21 → SDS-COMP-12 → UC-SCR13-03 |
| UC-SCR13-04 | FR-4, EC-2 | SRS-FR-22 → SDS-DATA-8 → UC-SCR13-04 |
| UC-SCR13-05 | FR-5, NFR-1, EC-3 | SDS-IF-5 → UC-SCR13-05 |
| UC-SCR13-06 | FR-6, FR-7, SEC-2, AC-3 | SRS-FR-16, SRS-FR-23 → SDS-COMP-6 / SDS-DATA-5 → UC-SCR13-06 |
| UC-SCR13-07 | EC-4 | SDS-ERR-6 → UC-SCR13-07 |
| UC-SCR13-08 | NFR-3, EC-5 | BR-NFR-020 → UC-SCR13-08 |

**Full chain:** BRD → SRS → SDS → Inventory → UC-SCR13-\* → US-SCR13.

# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering six states/moments from this story: New Schedule — Blank (§8 AC-1), Edit — Pre-filled (§8 AC-2), Day Conflict — Inline Error (§9 EC-2, one plan per day max per Decisions Log §4), Invalid/Unavailable Plan (§9 EC-1), Save — Loading (§9 EC-3), and Save Failure — Retry (§9 EC-4).  
* **Tool:** Claude Design canvas (not Figma) — six artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/6f1d9550-c79a-4ae8-a2de-f8f45d9f362a](https://claude.ai/code/artifact/6f1d9550-c79a-4ae8-a2de-f8f45d9f362a)  
* **Artifact title:** "ForgeApp Assign Edit Schedule" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (New Schedule — Blank), EditMode.dc.html (Edit — Pre-filled), ConflictError.dc.html (Day Conflict — Inline Error), InvalidPlan.dc.html (Invalid/Unavailable Plan), SavingLoading.dc.html (Save — Loading), SaveFailure.dc.html (Save Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-12 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`.  
* **Scope note:** the Recurrence component is shown as a locked "Repeats weekly" toggle rather than a functioning switch, since Decisions Log §4 confirms weekly-only recurrence with no other value it could hold — FR-2's "pre-fill the current recurrence setting" is satisfied by displaying that fixed state, not by offering a choice the app doesn't support. Day selection uses a 7-circle Mon–Sun row; the conflict artboard shows one day flagged red with the exact "one plan per day" conflict rule from Decisions Log §4/FR-4 stated inline. Exact copy for the invalid-plan and save-failure messages is not specified in the Inventory (§10) and should be confirmed with the SRS/SDS owner.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

