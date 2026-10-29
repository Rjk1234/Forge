# **\#Forge-US-11**

## **1\. User Story Identification**

* **Story ID:** US-SCR11  
* **Title:** Delete Workout Plan Confirmation  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 2

## **2\. User Story Statement**

As a user with the app unlocked, I want to confirm the deletion of a workout plan so that I can intentionally remove the plan and its schedule assignments while preserving historical workout sessions associated with that plan.

## **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language, including the literal "You're offline" state, inherited from the deprecated Firebase/Firestore architecture. Deletion is a local Drift write; there is no "no connectivity" condition for it to fail against — the existing delete-failure error state (EC-1) already covers the one genuinely local-equivalent concern, a local Drift write failure. No functional change to the confirmation or deletion behavior.)*

SCR-11 is the confirmation step reached from SCR-10 when the user chooses to delete a workout plan.

The screen provides an explicit confirmation before deletion. On confirmation, the plan and its schedule assignments are removed, while historical workout sessions using the plan remain unaffected.

The screen is available only when the app's local login state is unlocked.

## **4\. Functional Requirements**

* **FR-1** — The system shall present a confirmation modal when the user initiates deletion of a workout plan, explaining that the plan and its schedule assignments will be removed and that historical workout sessions using the plan are unaffected. **(UC-SCR11-01, SRS-FR-14)**  
* **FR-2** — The system shall provide a loading state on the confirmation action while the deletion request is being processed. **(UC-SCR11-02, SRS-FR-14 — underlying SRS requirement not explicitly specified for this loading behavior; SDS-IF-4 defines the action flow)**  
* **FR-3** — When deletion succeeds, the system shall remove the workout plan from the user's plan list and route the user to SCR-08. **(UC-SCR11-03, SRS-FR-14)**  
* **FR-4** — The deletion operation shall not remove or alter historical workout sessions that used the deleted workout plan. **(UC-SCR11-01, SRS-FR-14)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The deletion action shall provide a loading state while the operation is in progress so that the user is given clear feedback that the action is being processed. **(UC-SCR11-02, SRS-FR-14; SDS-IF-4)**  
* **NFR-2** — The screen shall require the app's local login state to be unlocked. **(UC-SCR11-01, SRS-FR-14; updated 2026-09-05 — replaces "an authenticated user")**  
* **NFR-3** — No specific measurable non-functional requirement beyond the above is specified in the Inventory for SCR-11. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the workout plan deletion flow shall require the app's local login state to be unlocked. **(UC-SCR11-01, SRS-FR-14; updated 2026-09-05 — replaces "restricted to authenticated users")**  
* **SEC-2** — Historical workout sessions associated with the deleted plan shall remain unaffected by the deletion operation. **(UC-SCR11-01, SRS-FR-14)**  
* **SEC-3** — No specific security or privacy requirement mapped to an SRS-NFR or SDS-COMP-14 is specified for SCR-11 in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Confirmation Modal**

* **Component type:** Confirmation modal  
* **Input type:** User confirmation action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** User confirmation is required before deletion

### **Confirmation Action**

* **Component type:** Confirmation action within the modal  
* **Input type:** Tap/action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required to proceed with deletion

### **Loading State**

* **Component type:** Loading state on confirmation action  
* **Input type:** Action state  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required during deletion processing

## **8\. Acceptance Criteria**

### **AC-1 — Delete Confirmation**

**(UC-SCR11-01)**

**Given** the app is unlocked and the user is viewing a workout plan on SCR-10  
**When** the user taps the Delete action  
**Then** the system shall display a confirmation modal explaining that the workout plan and its schedule assignments will be removed, while historical workout sessions using the plan remain unaffected.

### **AC-2 — Delete Loading State**

**(UC-SCR11-02)**

**Given** the delete confirmation modal is displayed  
**When** the user confirms the deletion  
**Then** the confirmation action shall display a loading state while the deletion operation is being processed.

### **AC-3 — Successful Deletion**

**(UC-SCR11-03)**

**Given** the user has confirmed deletion and the deletion operation succeeds  
**When** the operation completes  
**Then** the system shall route the user to SCR-08  
**And** the deleted workout plan shall no longer appear in the workout plans list.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Delete Failure**

**(UC-SCR11-04)**

**Given** the user has confirmed deletion  
**When** the deletion operation fails  
**Then** the system shall display an error state  
**And** the workout plan shall remain available  
**And** the user shall be provided with a retry option.

### ~~EC-2 — No Connectivity~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); deletion is a local Drift write with no "no connectivity" failure mode. UC-SCR11-05's literal `"You're offline"` state no longer applies — EC-1's local delete-failure error state already covers the one genuinely local-equivalent case.

## **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:**  
  * **Entry:** SCR-10 — Plan Detail, through the Delete action.  
  * **Exit:** SCR-08 — Workout Plans List on successful deletion.  
  * **Exit:** SCR-10 — Plan Detail when the deletion flow is cancelled, as defined by the parent screen flow.  
* **\[ASSUMPTION\] flag:** None specified for SCR-11.  
* **Underspecified behavior:**  
  * The Inventory specifies that SCR-11 shall display a confirmation modal but does not provide exact confirmation-modal copy beyond its described behavior.  
  * The Inventory specifies an error state and retry for deletion failure but does not define exact error copy (a local Drift write failure per Decisions Log §0).  
  * No additional validation rules or error messages are specified.  
* **Traceability summary:**  
  * **BRD:** BR-FR-032 (historical integrity)  
  * **→ SRS:** SRS-FR-14  
  * **→ SDS:** SDS-COMP-5, SDS-IF-4, SDS-ERR-6  
  * **→ Inventory:** UC-SCR11-01 → FR-1, FR-4, NFR-2, SEC-1, SEC-2, AC-1  
  * **→ Inventory:** UC-SCR11-02 → FR-2, NFR-1, AC-2  
  * **→ Inventory:** UC-SCR11-03 → FR-3, AC-3  
  * **→ Inventory:** UC-SCR11-04 → EC-1  
  * ~~**→ Inventory:** UC-SCR11-05 → EC-2~~ — Removed 2026-09-05, no connectivity condition exists

## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the three states defined in this story: Delete Confirmation modal (§8 AC-1), Deleting — Loading (§8 AC-2), and Delete Failure — Retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — three artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/068a136f-13f2-46a9-90b2-17153985d5f3](https://claude.ai/code/artifact/068a136f-13f2-46a9-90b2-17153985d5f3)  
* **Artifact title:** "ForgeApp Delete Plan Confirmation" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Delete Confirmation), Loading.dc.html (Deleting — Loading), Error.dc.html (Delete Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06/07/08/09/10 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`; the destructive Delete button uses a red fill, distinct from the app's lime primary action, to keep the destructive action visually separated from confirm/save actions elsewhere in the app.  
* **Scope note:** shown as a modal over a dimmed SCR-10 Plan Detail background (same dialog pattern as the SCR-09 discard-changes reference), since SCR-11 is reached from and returns to SCR-10 (§10). The modal copy explicitly states that schedule assignments are removed but historical sessions are unaffected, per FR-1/FR-4/SEC-2 — exact confirmation and error copy are not specified in the Inventory (§10) and should be confirmed with the SRS/SDS owner.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

