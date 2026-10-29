# **1\. User Story Identification**

* **Story ID:** US-SCR24  
* **Title:** View Personal Bests  
* **Epic / Feature:** Statistics  
* **Priority:** Medium  
* **Story Points:** 3

# **2\. User Story Statement**

As a user with the app unlocked, I want to view my personal bests for exercises so that I can see my highest recorded performance based on valid completed workouts.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language inherited from the deprecated Firebase/Firestore architecture. Personal-best data is calculated from local Drift workout history, which has no "no connectivity" failure mode; the existing Error State already covers the one genuinely local-equivalent concern, a local Drift read/calculation failure. No functional or scope change — the Personal Best metric itself remains deferred per Decisions Log §3.)*

SCR-24 is the **Personal Bests** screen within **FLOW-09 — Statistics**.

The screen is accessed from SCR-23 — Statistics Dashboard and presents personal bests derived from valid completed workout records. It supports loading, empty, populated, and system-failure states.

Only valid completed records are considered when displaying personal bests.

**Personal Best metric definition — DEFERRED, explicitly open (Decisions Log §3, confirmed 2026-09-05).** The product owner has not yet decided which metric(s) constitute a "personal best" (candidates include heaviest weight, highest reps, highest volume, or longest duration — one or more may ultimately apply, and it may vary by exercise type). This is intentionally left open pending a dedicated future brainstorming session. **This story keeps only the structural scope — a Personal Bests view exists, showing per-exercise bests derived from valid completed workouts — and does not pick a default metric.** Any wording below referring to "per exercise metric" is a placeholder for that still-undecided definition, not a finalized spec.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty state when there are no valid completed workouts. **(UC-SCR24-02, SRS-FR-46; updated 2026-09-05 — drops "the user has," since there is a single local user)**  
* **FR-2** — The system shall display a list of per-exercise personal bests when valid personal-best records exist, using valid completed workout records only. **The specific metric(s) used to determine a "personal best" are TBD — deferred per Decisions Log §3 pending a future product-owner decision.** **(UC-SCR24-03, SRS-FR-46; updated 2026-09-05)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Personal Bests screen shall display a skeleton loading state while personal-best data is being calculated. **(UC-SCR24-01, SDS-IF-12)**  
* **NFR-2** — Personal-best results shall be derived only from valid completed workout records. **(UC-SCR24-03, SRS-FR-46, SDS-DATA-7)**  
* ~~**NFR-3** — offline state when connectivity is unavailable~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR24-05 no longer applies.

# **6\. Security & Privacy Requirements**

* **SR-1** — The Personal Bests screen shall be accessible only when the app's local login state is unlocked. **(Screen Auth Requirement: Required; updated 2026-09-05 — replaces "an authenticated user")**  
* **SR-2** — Personal-best information displayed on the screen shall be based on the valid completed workout records stored locally on this device. **(UC-SCR24-03, SRS-FR-46, SDS-DATA-7; updated 2026-09-05 — drops "the authenticated user's," since there is a single local user)**

# **7\. UI / Component Specifications**

### **Personal Bests Loading State**

* **Component type:** Skeleton  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required during data calculation  
* **Source:** UC-SCR24-01

### **Empty State**

* **Component type:** Empty state  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when no valid completed workouts exist  
* **Source:** UC-SCR24-02

### **Personal Bests List**

* **Component type:** List of personal bests  
* **Input type:** Not applicable  
* **Validation rules:** Only valid completed records shall contribute to personal-best results  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when personal bests exist  
* **Content:** Personal bests per exercise metric  
* **Source:** UC-SCR24-03

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when PB calculation/load fails  
* **Source:** UC-SCR24-04

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed. (Was UC-SCR24-05.)

# **8\. Acceptance Criteria**

### **AC-1 — Loading Personal Bests**

**Given** the user opens the Personal Bests screen and PB data is being calculated,  
**When** the calculation is in progress,  
**Then** the system shall display a skeleton loading state.  
**(UC-SCR24-01)**

### **AC-2 — No Valid Completed Workouts**

**Given** the user has no valid completed workouts,  
**When** the Personal Bests screen is displayed,  
**Then** the system shall display an empty state.  
**(UC-SCR24-02)**

### **AC-3 — Display Personal Bests**

**Given** valid completed workout records contain personal-best results,  
**When** PB data is successfully calculated,  
**Then** the system shall display a list of personal bests per exercise metric using valid completed records only.  
**(UC-SCR24-03)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Personal Best Calculation/Load Failure**

**Given** personal-best calculation or loading fails,  
**When** the failure occurs,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR24-04)**

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network connectivity condition (Decisions Log §0); UC-SCR24-05 no longer applies.

# **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-23 — Statistics Dashboard.  
* **Screen exit dependency:** Back to SCR-23.  
* **Access dependency:** The screen requires the app's local login state to be unlocked (updated 2026-09-05 — replaces "requires an authenticated user").  
* **\[ASSUMPTION\] flag:** None specified for SCR-24.  
* **Underspecified behavior:**  
  * **TBD — deferred, see open decisions (Decisions Log §3):** the exact exercise metric(s) and calculation methodology for a "personal best" are not decided. This is an open product decision pending a dedicated brainstorming session, not an underspecified inventory detail to fill in during design.  
  * The Inventory does not specify the exact empty-state message.  
  * The Inventory does not specify the exact error-state messaging.  
  * These details must be confirmed with the SRS/SDS owner rather than invented at user-story level.  
* **Full-chain traceability summary:**  
  * **BRD:** BRD-FR/NFR IDs reachable through the SDS full-chain mapping.  
  * **SRS-FR-46** → UC-SCR24-02 → FR-1 / AC-2  
  * **SRS-FR-46 \+ SDS-DATA-7** → UC-SCR24-03 → FR-2 / NFR-2 / AC-3  
  * **SDS-IF-12** → UC-SCR24-01 → NFR-1 / AC-1  
  * **SDS-ERR-5 / SDS-ERR-9** → UC-SCR24-04 → EC-1  
  * ~~**BR-NFR-020** → UC-SCR24-05 → NFR-3 / EC-2~~ — Removed 2026-09-05, no connectivity condition exists



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the four states defined in this story: skeleton loading (§8 AC-1), empty state when no valid completed workouts exist (§8 AC-2), populated per-exercise personal-bests list (§8 AC-3), and a calculation/load-failure error state with retry (§9 EC-1).  
* **IMPORTANT — open product decision, not a finalized spec:** the exact metric(s) that constitute a "personal best" (heaviest weight, highest reps, highest volume, longest duration, or some combination that may vary by exercise type) is explicitly **DEFERRED per Decisions Log §3**. This design keeps only the structural scope confirmed by the story — a Personal Bests view exists, listing one badge per exercise — and does **not** pick a default metric. The Populated artboard carries a visible on-screen design-note banner and every badge is labeled "Metric TBD" so this placeholder can never be mistaken for a decided spec; do not treat the sample weight/reps/duration values shown as the chosen metric.  
* **Tool:** Claude Design canvas (not Figma) — four artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/7f74011d-61bf-4f48-b2d1-88ef016334b5](https://claude.ai/code/artifact/7f74011d-61bf-4f48-b2d1-88ef016334b5)  
* **Artifact title:** "ForgeApp Personal Bests" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading Skeleton), Empty.dc.html (Empty State), Main.dc.html (Populated — Metric Placeholder), Error.dc.html (Load Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-23 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for the error card, plus a distinct amber `#d9c94a`/`#2a2610` tone reserved for the design-note banner (not used elsewhere in the app) so it reads clearly as a flag, not a normal UI element. Rows reuse the type-flag dot from SCR-09/10/15/16/19/21/22/23. Reached from SCR-23's "Personal Bests" row (§10); back navigation returns to SCR-23.  
* **Scope note:** the Inventory does not specify the exact empty/error copy (§10) — plausible placeholder text is used, to be confirmed with the SRS/SDS owner alongside the deferred metric decision itself.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree — and treat the deferred metric decision (Decisions Log §3) as the authority on what "personal best" ultimately means, not this mockup.
