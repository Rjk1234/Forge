# **1\. User Story Identification**

* **Story ID:** US-SCR25  
* **Title:** View Profile / Account  
* **Epic / Feature:** Account  
* **Priority:** Medium  
* **Story Points:** 3

# **2\. User Story Statement**

As the app's user, I want to view and edit my basic profile information and access the logout action so that I can keep my display name, fitness goal, experience level, and height/weight up to date and end my session.

# **3\. Description / Context**

SCR-25 — **Profile / Account** is part of **FLOW-10 — Account**.

**Status: CONFIRMED, editable — resolves the prior [ASSUMPTION] flag (Decisions Log §8, confirmed by the product owner on 2026-09-05).** This is confirmed new in-scope functionality for this clarification round, not scope creep — the product owner directly approved it. The screen is no longer read-only.

The screen provides exactly these editable fields, no more:

* **Display name** (text)  
* **Fitness goal** (short text or pick-list, e.g., Build muscle / Lose weight / General fitness)  
* **Experience level** (Beginner / Intermediate / Advanced — informational only; no logic or calculations are tied to it for MVP)  
* **Height & weight** (numeric, stored for reference only — not used in any calculation unless later decided)

There is still no registration flow that collects these fields at signup (per Decisions Log §0 — no real auth, no registration). The user sets and edits them directly on this screen after the static local login. The Logout action remains on this screen.

All data is read from and written to the local on-device Drift database; the app is fully offline/local-only (Decisions Log §0) — there is no server-side profile fetch/save and no connectivity condition.

# **4\. Functional Requirements**

* **FR-1** — The system shall display the user's current display name, fitness goal, experience level, and height/weight when the profile screen is opened, pre-filled from local storage. **(Updated per Decisions Log §8, 2026-09-05 — replaces the prior single "registered email address" field.)**  
* **FR-2** — The system shall allow the user to edit the display name, fitness goal, experience level, and height/weight, and shall save the updated values to local storage. **(New, confirmed per Decisions Log §8, 2026-09-05.)**  
* **FR-3** — Height and weight shall be stored and displayed for reference only; the system shall not perform any calculation using these values for MVP. **(Decisions Log §8.)**  
* **FR-4** — Experience level shall be informational only; the system shall not tie any logic/calculation to it for MVP. **(Decisions Log §8.)**  
* **FR-5** — The system shall provide a Logout action from the Profile / Account screen. **(UC-SCR25-03, SRS-FR-1; corrected 2026-09-05 — the Logout action is part of the Populated state's behavior in the current Inventory, not a distinct UC row)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The screen shall display a skeleton (or equivalent brief loading state) while profile data is being read from local storage. **(UC-SCR25-01, SDS-IF-14; updated 2026-09-05 — local read, not a network fetch)**  
* **NFR-2** — When the local profile read or save fails, the screen shall provide a recoverable error state with retry. **(UC-SCR25-06, SDS-ERR-5; corrected 2026-09-05 — UC-SCR25-06 is the current Error/System Failure row; replaces network-load failure with a local-storage failure)**  
* ~~**NFR-3** — offline state~~ — **REMOVED, 2026-09-05.** The app is fully offline/local-only (Decisions Log §0); there is no connectivity condition. **Correction (2026-09-05): the removed/no-longer-applicable Inventory row is UC-SCR25-07 (was the offline row), not UC-SCR25-04 — UC-SCR25-04 is the active Negative/Validation row (invalid numeric height/weight entry) and remains in scope (see NFR-4, EC-2 below).**
* **NFR-4** — When the user enters a negative or non-numeric value for height or weight, the system shall block the save and display an inline field validation error. **(New 2026-09-05 — UC-SCR25-04, SDS-DATA-8; this coverage was missing from the prior version of this story)**

# **6\. Security & Privacy Requirements**

* **SR-1** — The Profile / Account screen shall require the app's static local login state to be unlocked (Decisions Log §0 — this is not real authentication). **(Screen Auth Requirement: Required)**  
* **SR-2** — The screen shall display and allow editing of the single local user's own profile fields only (there is only one local user — Decisions Log §0). **(Updated 2026-09-05.)**

# **7\. UI / Component Specifications**

### **7.1 Profile Loading State**

* **Component type:** Skeleton  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required while profile is being fetched  
* **Source:** UC-SCR25-01

### **7.2 Display Name Field**

* **Component type:** Text input field  
* **Input type:** Text, editable  
* **Validation rules:** Not specified in Inventory — confirm with SRS/SDS owner  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Editable; pre-filled from local storage  
* **Source:** Decisions Log §8 (2026-09-05)

### **7.3 Fitness Goal Field**

* **Component type:** Short text field or pick-list (e.g., Build muscle / Lose weight / General fitness)  
* **Input type:** Text or single-select, editable  
* **Validation rules:** Not specified in Inventory — confirm exact option set/format with SRS/SDS owner  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Editable; pre-filled from local storage  
* **Source:** Decisions Log §8 (2026-09-05)

### **7.4 Experience Level Field**

* **Component type:** Single-select (Beginner / Intermediate / Advanced)  
* **Input type:** Single-select, editable  
* **Validation rules:** Informational only — no logic/calculation tied to it for MVP  
* **Min / Max constraints:** Fixed 3-value list  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Editable; pre-filled from local storage  
* **Source:** Decisions Log §8 (2026-09-05)

### **7.5 Height & Weight Fields**

* **Component type:** Numeric input fields  
* **Input type:** Numeric, editable  
* **Validation rules:** Stored for reference only — not used in any calculation unless later decided; exact numeric format/units not specified in Inventory — confirm with SRS/SDS owner  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Editable; pre-filled from local storage  
* **Source:** Decisions Log §8 (2026-09-05)

### **7.6 Save Action**

* **Component type:** Save action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required to persist edits to local storage  
* **Source:** Decisions Log §8 (2026-09-05)

### **7.7 Logout Action**

* **Component type:** Logout action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required  
* **Source:** UC-SCR25-03 (corrected 2026-09-05 — the Logout action is part of the Populated state's behavior in the current Inventory)

### **7.8 Profile Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when the local profile read/save fails  
* **Source:** UC-SCR25-06 (corrected 2026-09-05 — UC-SCR25-06 is the current Error/System Failure row; local storage failure, not a network load failure)

### **7.9 Height & Weight Validation Error**

* **Component type:** Inline field validation error  
* **Input type:** Not applicable  
* **Validation rules:** Triggered when the height or weight field contains a negative or non-numeric value  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory — confirm exact copy with SRS/SDS owner  
* **Mandatory / Optional:** Required when an invalid numeric value is entered; save is blocked until corrected  
* **Source:** UC-SCR25-04 (New, 2026-09-05 — this coverage was missing from the prior version of this story)

### ~~7.10 Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply.

# **8\. Acceptance Criteria**

### **AC-1 — Profile Loading**

**Given** the user opens SCR-25 and the profile is being read from local storage,  
**When** profile data is still loading,  
**Then** the system shall display a skeleton.  
**(UC-SCR25-01; updated 2026-09-05)**

### **AC-2 — Display and Edit Profile Information**

**Given** the user's profile is successfully loaded,  
**When** SCR-25 is displayed,  
**Then** the system shall display the user's display name, fitness goal, experience level, and height/weight — each editable — plus a Logout action.  
**(UC-SCR25-03; corrected 2026-09-05 — UC-SCR25-03 is the current Populated row; per Decisions Log §8 this replaces "registered email address" with the confirmed editable field set.)**

### **AC-3 — Save Profile Edits**

**Given** the user has changed one or more of display name, fitness goal, experience level, or height/weight,  
**When** the user saves,  
**Then** the system shall persist the updated values to local storage, display a confirmation, and reflect the updated values the next time the screen is opened.  
**(UC-SCR25-05; New, Decisions Log §8, 2026-09-05 — corrected 2026-09-05 to cite UC-SCR25-05 [Success], which the prior version of this story did not cite at all.)**

### **AC-4 — Invalid Height/Weight Entry Blocks Save**

**Given** the user enters a negative or non-numeric value for height or weight,  
**When** the user attempts to save,  
**Then** the system shall display an inline field validation error and block the save until the value is corrected.  
**(New 2026-09-05 — UC-SCR25-04, SDS-DATA-8; this coverage was missing from the prior version of this story.)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Profile Read/Save Failure**

**Given** the user's profile fails to load or save,  
**When** the failure occurs,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR25-06; corrected 2026-09-05 — UC-SCR25-06 is the current Error/System Failure row; local storage failure, not a network load failure)**

The app has no network connectivity (Decisions Log §0); the removed/no-longer-applicable Inventory row is **UC-SCR25-07** (was the offline row) — **corrected 2026-09-05** (previously this story incorrectly stated "UC-SCR25-04 no longer applies," but UC-SCR25-04 is the active Negative/Validation row, covered below).

### **EC-2 — Invalid Numeric Entry for Height/Weight**

**Given** the user enters a negative or non-numeric value in the height or weight field,  
**When** the user attempts to save,  
**Then** the system shall display an inline field error and block the save.  
**(New 2026-09-05 — UC-SCR25-04, SDS-DATA-8; this coverage was missing from the prior version of this story.)**

# **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-06 — Home Dashboard.  
* **Screen exit dependency:** SCR-26 — Logout Confirmation.  
* **Local-login dependency:** The app's static local login state must be unlocked (Decisions Log §0 — not real authentication).  
* **\[ASSUMPTION\] flag — RESOLVED, 2026-09-05 (Decisions Log §8):**  
  This screen was previously flagged **[ASSUMPTION]** and scoped tentatively as read-only, pending confirmation of whether the SDS data-model fields (displayName, height, weight, fitnessGoal, experienceLevel) should be viewable/editable on an account screen. **The product owner has now directly confirmed, in this clarification round, that the screen is in scope and editable**, with exactly the field set specified in §3 above (display name, fitness goal, experience level, height & weight). This is new confirmed scope, not scope creep. There is still no registration flow collecting these fields at signup — the user sets/edits them here, after the static local login.  
* **Scope constraint:** Exactly the four fields above, plus Logout — no more. Do not add other profile/account fields not listed in Decisions Log §8.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact input format/validation for the fitness-goal pick-list options.  
  * The Inventory does not specify the exact units (e.g., cm/kg vs. in/lb) for height and weight — confirm with SRS/SDS owner.  
  * The Inventory does not specify the exact error-state message.  
  * These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **Decisions Log §8** → FR-1 through FR-4, SR-2, AC-2, AC-3 (supersedes the prior SRS-FR-1/SDS-DATA-2 email-only trace)  
  * **SDS-IF-14** → UC-SCR25-01 (Loading) → NFR-1 → AC-1  
  * **Decisions Log §8** → UC-SCR25-02 (Empty/Default) — no default-state field/screen behavior beyond blank editable fields; not separately called out with its own AC in this story  
  * **SRS-FR-1, SDS-DATA-2, Decisions Log §8** → UC-SCR25-03 (Populated) → FR-5, AC-2  
  * **SDS-DATA-8** → UC-SCR25-04 (Negative/Validation) → NFR-4 → AC-4, EC-2  
  * **Decisions Log §8** → UC-SCR25-05 (Success) → AC-3  
  * **SDS-ERR-5/SDS-ERR-7** → UC-SCR25-06 (Error/System Failure) → NFR-2 → EC-1  
  * **UC-SCR25-07 — removed**, no longer applicable (was the offline row; corrected 2026-09-05 — see NFR-3 note above)  
  * **BRD → SRS → SDS → Inventory → User Story:** Full-chain traceability for the confirmed editable-profile scope is Decisions Log §8 → this story; the remaining loading/validation/success/error mappings are maintained through the referenced SDS/UC IDs above, corrected 2026-09-05 to match the current 7-row UC-SCR25 table in the Inventory (see Screen_Flow_Use_Case_Inventory_vNext.md, SCR-25).



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the five states defined in this story: skeleton loading while reading local storage (§8 AC-1), the populated editable profile with all four confirmed fields plus Save and Logout (§8 AC-2), inline validation blocking save on a negative or non-numeric height/weight value (§8 AC-4, §9 EC-2), a save-confirmation toast (§8 AC-3), and a local read/save-failure error state with retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — five artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/d9763b67-d7b2-46f0-adcd-6b6617e84d9e](https://claude.ai/code/artifact/d9763b67-d7b2-46f0-adcd-6b6617e84d9e)  
* **Artifact title:** "ForgeApp Profile Account" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Loading.dc.html (Loading Skeleton), Main.dc.html (Populated — Editable Profile), Validation.dc.html (Invalid Height/Weight — Save Blocked), Success.dc.html (Save Confirmation), Error.dc.html (Read/Save Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-24 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`, danger red `#ff6b6b`/`#5c3a3a` for invalid fields and the error card, danger red also for the Logout label (a destructive-feeling session action, consistent with how the app already reserves red for irreversible/exit-type actions in SCR-11/18). Experience Level is shown as a fixed 3-way segmented control (Beginner/Intermediate/Advanced) rather than a free picker, since the Inventory fixes it to exactly those three values (§7.4). Fitness Goal is shown as a select-style field per §7 ("short text field or pick-list").  
* **Scope note:** per the story's explicit scope constraint (§10), exactly the four confirmed fields — display name, fitness goal, experience level, height/weight — plus Logout are shown; no other profile/account fields are added. Height/weight units (cm/kg) are a plausible placeholder — the Inventory does not specify exact units and this should be confirmed with the SRS/SDS owner, along with the fitness-goal option set and exact validation/error copy (§10). This screen is reached from SCR-06 (§10) via a profile entry point, not one of the six bottom-tab items, so no tab bar is shown; Logout exits to SCR-26 (§10) which is designed separately.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
