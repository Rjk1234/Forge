# **1\. User Story Identification**

* **Story ID:** US-SCR26  
* **Title:** Confirm Logout  
* **Epic / Feature:** Account  
* **Priority:** Medium  
* **Story Points:** 2

# **2\. User Story Statement**

As a user with the app unlocked, I want to confirm my logout action so that I can explicitly choose whether to lock the app again.

# **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: the remaining "authenticated session" wording below in the confirmation modal/action copy and acceptance criteria is corrected to "local unlocked state," matching the terminology already used in FR-2/FR-3/SR-1/SR-2 above. No functional change — logout still only resets the local login-state flag.)*

SCR-26 — **Logout Confirmation** is part of **FLOW-10 — Account**.

The screen is reached when the user selects **Logout** from SCR-25 — Profile / Account. It provides a confirmation step before setting the app's local login state back to locked.

The defined flow supports confirming or cancelling the logout action. On confirmation, the app's local unlocked/locked state is set back to locked and the user is routed back through the static login flow, while the user's locally stored (Drift) data remains untouched. **(Updated per Decisions Log §0, 2026-09-05 — this is not a real authenticated session and there is no Firestore; logout simply resets the local login-state flag and does not delete any local data.)**

# **4\. Functional Requirements**

* **FR-1** — The system shall display a confirmation modal when the user taps Logout from SCR-25. **(UC-SCR26-01, SRS-FR-4)**  
* **FR-2** — When logout is confirmed, the system shall set the app's local login state back to locked. **(UC-SCR26-02, SRS-FR-4; updated 2026-09-05 — replaces "terminate the user's authenticated session" since there is no real session)**  
* **FR-3** — After logout is confirmed, the system shall route the user to SCR-01 / SCR-03 and shall leave the user's locally-stored data untouched. **(UC-SCR26-02, SRS-FR-4; updated 2026-09-05 — replaces "Firestore data" per Decisions Log §0)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The logout confirmation interaction shall require explicit user confirmation before the app's local login state is set back to locked. **(UC-SCR26-01, SRS-FR-4; updated 2026-09-05 — replaces "the authenticated session is terminated")**

# **6\. Security & Privacy Requirements**

* **SR-1** — The system shall set the local login state back to locked when the user confirms logout. **(UC-SCR26-02, SRS-FR-4, SDS-COMP-2; updated 2026-09-05)**  
* **SR-2** — Logout shall not modify or delete the user's locally-stored data. **(UC-SCR26-02, SRS-FR-4, SDS-COMP-2; updated 2026-09-05 — replaces "Firestore data")**

# **7\. UI / Component Specifications**

### **7.1 Logout Confirmation Modal**

* **Component type:** Confirmation modal  
* **Input type:** User confirmation/cancellation action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required  
* **Behavior:** Displayed when the user taps Logout  
* **Source:** UC-SCR26-01

### **7.2 Logout Action**

* **Component type:** Confirmation action  
* **Input type:** User action  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required  
* **Behavior:** Sets the app's local login state back to locked and routes to SCR-01 / SCR-03 **(updated 2026-09-05 — replaces "terminates the authenticated session")**  
* **Source:** UC-SCR26-02

# **8\. Acceptance Criteria**

### **AC-1 — Display Logout Confirmation**

**Given** the user, with the app unlocked, is on SCR-25 and taps Logout,  
**When** the Logout action is triggered,  
**Then** the system shall display a confirmation modal.  
**(UC-SCR26-01)**

### **AC-2 — Confirm Logout**

**Given** the logout confirmation modal is displayed,  
**When** the user confirms logout,  
**Then** the system shall set the app's local login state back to locked and route the user to SCR-01 / SCR-03.  
**(UC-SCR26-02; updated 2026-09-05 — replaces "terminate the authenticated session")**

### **AC-3 — Preserve User Data**

**Given** the user confirms logout,  
**When** the local login state is set back to locked,  
**Then** the user's locally-stored data shall remain untouched.  
**(UC-SCR26-02; updated 2026-09-05 — replaces "Firestore data")**

# **9\. Edge Cases & Error Scenarios**

**Not specified in Inventory — confirm with SRS/SDS owner.**

The SCR-26 Inventory contains no Negative/Validation, Error/System Failure, Offline, or Interrupted UC rows.

# **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-25 — Profile / Account.  
* **Screen exit dependency:** SCR-01 — Splash / Auth Check / SCR-03 — Login.  
* **Authentication dependency:** Required.  
* **\[ASSUMPTION\] flag:** None specified for SCR-26.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact confirmation modal copy.  
  * The Inventory does not explicitly define the cancel action behavior on SCR-26, although the screen's Exit Points identify SCR-25 on cancel.  
  * The Inventory does not define a logout service failure state or offline behavior for SCR-26.  
  * These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-4 \+ SDS-COMP-2** → UC-SCR26-01 → FR-1 / NFR-1 / AC-1  
  * **SRS-FR-4 \+ SDS-COMP-2 \+ SDS-IF-9** → UC-SCR26-02 → FR-2 / FR-3 / SR-1 / SR-2 / AC-2 / AC-3  
  * **BRD → SRS → SDS → Inventory → User Story:** Full-chain traceability is maintained through the referenced SRS/SDS/UC IDs.



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockup covering the one state this story defines: the Logout confirmation modal over a dimmed SCR-25 Profile background (§8 AC-1).  
* **Tool:** Claude Design canvas (not Figma) — one artboard.  
* **Link:** [https://claude.ai/code/artifact/85ccb11f-db55-4312-a70a-9d63287ec4a4](https://claude.ai/code/artifact/85ccb11f-db55-4312-a70a-9d63287ec4a4)  
* **Artifact title:** "ForgeApp Confirm Logout" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Logout Confirmation modal).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-25 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, card border `#444933`, muted text `#c4c9ac`. The confirming action uses the danger red `#ff6b6b` ("Log Out"), consistent with how the app already treats session-ending/exit actions (matching SCR-18's Cancel Workout pattern) — even though logout itself is non-destructive to data (§10, SR-2), it does end the current unlocked session, which the app's visual language marks the same way as other "leaving" actions.  
* **Scope note:** the Inventory does not specify the exact modal copy (§10) — the mockup uses plausible copy reassuring the user that workout data is untouched (per FR-3/AC-3), to be confirmed with the SRS/SDS owner. Cancel returns to SCR-25 per the Inventory's exit points (§10), though the Inventory does not explicitly define cancel behavior beyond that. No error/failure state is designed, since the Inventory defines no Negative/Validation, Error, or Offline UC rows for this screen (§9) — logout is a simple local flag reset with no failure mode called out.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
