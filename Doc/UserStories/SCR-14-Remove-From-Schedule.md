# **\#Forge-US-14**

# **US-SCR14 — Remove From Schedule Confirmation**

## **1\. User Story Identification**

* **Story ID:** US-SCR14  
* **Title:** Remove Workout Plan From Schedule  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

## **2\. User Story Statement**

As a user with the app unlocked, I want to remove a scheduled workout plan from a selected day or recurrence so that I can keep my weekly workout schedule up to date.

## **3\. Description / Context**

*(Follow-up cleanup pass, 2026-09-05 — Decisions Log §0: removes residual "authenticated user" / offline-connectivity language, including the literal "You're offline" state, inherited from the deprecated Firebase/Firestore architecture. Removal is a local Drift write; there is no "no connectivity" condition for it to fail against — the existing removal-failure error state (EC-1) already covers the one genuinely local-equivalent concern, a local Drift write failure. No functional change to the confirmation or removal behavior.)*

SCR-14 provides a confirmation step before removing a scheduled workout entry. The user can confirm or cancel the removal.

On confirmation, the scheduled entry is removed and the user is returned to the Weekly Schedule View (SCR-12). The removal does not alter historical workout records.

## **4\. Functional Requirements**

* **FR-1** — The system shall display a confirmation modal when the user taps Remove on a scheduled entry, identifying that the selected schedule assignment will be removed from the applicable day/recurrence. **(UC-SCR14-01, SRS-FR-20)**  
* **FR-2** — The system shall remove the selected scheduled entry when the user confirms the removal. **(UC-SCR14-03, SRS-FR-20)**  
* **FR-3** — After successful removal, the system shall route the user to SCR-12 and the removed entry shall no longer appear in the weekly schedule. **(UC-SCR14-03, SRS-FR-20)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The removal action shall provide a loading state while the removal operation is in progress. **(UC-SCR14-02, SDS-IF-5)**  
* **NFR-2** — If the removal operation fails (a local Drift write failure), the system shall not represent the schedule entry as successfully removed and shall provide a retry option. **(UC-SCR14-04, SDS-ERR-6; updated 2026-09-05 — local storage failure, not a network/Firestore failure)**  
* ~~**NFR-3** — offline state on loss of connectivity~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); UC-SCR14-05 no longer applies. NFR-2's local-write-failure error state already covers the one genuinely local-equivalent case.

## **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the schedule-removal functionality shall require the app's local login state to be unlocked. **(UC-SCR14-01, SRS-FR-20; updated 2026-09-05 — replaces "authenticated user session")**  
* **SEC-2** — The removal operation shall apply only to the scheduled entries stored locally on this device. **(UC-SCR14-03, SRS-FR-20; updated 2026-09-05 — drops "authenticated user"/"another user's schedule," since there is a single local user and no multi-user access)**

## **7\. UI / Component Specifications**

### **Confirmation Modal**

* **Component type:** Confirmation modal  
* **Input type:** User action — Remove / Confirm / Cancel  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Explicit user confirmation is required before removal

### **Loading State**

* **Component type:** Loading state on confirm action  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required while removal is in progress

### ~~Offline State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this component does not apply and has been removed.

## **8\. Acceptance Criteria**

### **AC-1 — Removal Confirmation**

**Given** the user is viewing a scheduled entry and taps Remove  
**When** the removal action is initiated  
**Then** the system shall display a confirmation modal confirming removal from that day/recurrence.  
**(UC-SCR14-01)**

### **AC-2 — Removal in Progress**

**Given** the removal confirmation modal is displayed  
**When** the user confirms the removal  
**Then** the system shall display a loading state while the removal operation is in progress.  
**(UC-SCR14-02)**

### **AC-3 — Successful Removal**

**Given** the user has confirmed removal  
**When** the removal succeeds  
**Then** the system shall route the user to SCR-12 and the scheduled entry shall be removed from the schedule.  
**(UC-SCR14-03)**

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Removal Failure**

**Given** the user has confirmed removal  
**When** the removal operation fails  
**Then** the system shall display an error state, keep the scheduled entry available, and provide a retry option.  
**(UC-SCR14-04)**

### ~~EC-2 — Offline During Removal~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); removal is a local Drift write with no "no connectivity" failure mode. UC-SCR14-05's literal `"You're offline"` state no longer applies — EC-1's local removal-failure error state already covers the one genuinely local-equivalent case.

## **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-12 — Weekly Schedule View  
  * SCR-13 — Assign / Edit Schedule for a Plan  
* **Screen exit dependency:**  
  * SCR-12 — Weekly Schedule View after successful removal.  
* **\[ASSUMPTION\] flag:** None specified for SCR-14.  
* **Underspecified behavior:**  
  * The Inventory specifies that a confirmation modal is required but does not define the exact modal title, body copy, button labels, or visual presentation.  
  * The Inventory specifies an error state and retry behavior but does not define exact error copy (a local Drift write failure per Decisions Log §0).  
* **Full-chain traceability summary:**  
  * **BRD:** BR-FR-013 → **SRS:** SRS-FR-20 → **SDS:** SDS-COMP-6 → **UC:** UC-SCR14-01 → **FR-1 / AC-1**  
  * **BRD:** BR-FR-013 → **SRS:** SRS-FR-20 → **SDS:** SDS-COMP-6 → **UC:** UC-SCR14-03 → **FR-2 / FR-3 / AC-3**  
  * **SDS:** SDS-IF-5 → **UC:** UC-SCR14-02 → **NFR-1 / AC-2**  
  * **SDS:** SDS-ERR-6 → **UC:** UC-SCR14-04 → **NFR-2 / EC-1**  
  * ~~**BRD:** BR-NFR-020 → **UC:** UC-SCR14-05 → **NFR-3 / EC-2**~~ — Removed 2026-09-05, no connectivity condition exists

## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockups covering the three states defined in this story: Remove Confirmation modal (§8 AC-1), Removing — Loading (§8 AC-2), and Remove Failure — Retry (§9 EC-1).  
* **Tool:** Claude Design canvas (not Figma) — three artboards on one canvas.  
* **Link:** [https://claude.ai/code/artifact/90414205-4601-4c88-8926-46c81d29655a](https://claude.ai/code/artifact/90414205-4601-4c88-8926-46c81d29655a)  
* **Artifact title:** "ForgeApp Remove From Schedule" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Remove Confirmation), Loading.dc.html (Removing — Loading), Error.dc.html (Remove Failure — Retry).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-13 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400`, card border `#444933`, muted text `#c4c9ac`. Unlike SCR-11's Delete (a red destructive action on a different data type — a workout plan), Remove here uses the lime primary color, since removing a single schedule entry is a lower-stakes, easily re-added action rather than an irreversible deletion.  
* **Scope note:** shown as a modal over a dimmed SCR-12 Weekly Schedule background, since SCR-14 is reached from and returns to SCR-12 (§10). The modal copy states which day/plan is affected and that history is unaffected, per FR-1 — exact modal and error copy are not specified in the Inventory (§10) and should be confirmed with the SRS/SDS owner.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.

