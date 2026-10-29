# **User Story — SCR-18**

## **1\. User Story Identification**

* **Story ID:** US-SCR-18  
* **Title:** Cancel Active Workout Confirmation  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As a user with the app unlocked,** I want to confirm whether I want to cancel an active workout, so that I can explicitly decide whether to discard the in-progress workout session before leaving the active workout.

## **3\. Description / Context**

SCR-18 is the confirmation screen/modal reached when the user selects **Cancel** during an active workout on SCR-16.

The screen provides an explicit confirmation before the active workout is discarded. If the user confirms cancellation, the in-progress session is discarded and is not persisted as a completed workout, and the user is returned to SCR-06.

If the user does not confirm cancellation, the user can return to the active workout on SCR-16 and continue the session.

## **4\. Functional Requirements**

* **FR-1** — When the user taps **Cancel** during an active workout, the system shall present a confirmation modal warning that the workout progress will not be saved as a completed workout. **(UC-SCR18-01, SRS-FR-29)**  
* **FR-2** — When the user confirms cancellation, the system shall discard the active workout session and shall not persist it as a completed workout. **(UC-SCR18-02, SRS-FR-29)**  
* **FR-3** — After cancellation is confirmed, the system shall route the user to SCR-06. **(UC-SCR18-02, SRS-FR-29)**

## **5\. Non-Functional Requirements**

* No screen-specific non-functional requirement is explicitly associated with the SCR-18 UC rows in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **6\. Security & Privacy Requirements**

* SCR-18 requires the app's local login state to be unlocked (updated 2026-09-05 — replaces "requires an authenticated user"). No additional screen-specific security or privacy behavior is specified in the SCR-18 UC rows. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Confirmation Modal**

* **Component type:** Confirmation modal  
* **Input type:** User action — Cancel / Confirm cancellation  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Explicit confirmation is required before the active session is discarded.

### **Confirmation Content**

* **Component type:** Warning / confirmation message  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** The warning that progress will not be saved as a completed workout is required by the specified behavior.

## **8\. Acceptance Criteria**

### **AC-1 — Cancel Confirmation**

**UC:** UC-SCR18-01

**Given** the user is in an active workout on SCR-16  
**When** the user taps **Cancel**  
**Then** the system shall present a confirmation modal warning that the progress will not be saved as a completed workout.

### **AC-2 — Confirm Cancellation**

**UC:** UC-SCR18-02

**Given** the cancel confirmation modal is displayed  
**When** the user confirms cancellation  
**Then** the system shall discard the active workout session, shall not persist it as a completed workout, and shall route the user to SCR-06.

## **9\. Edge Cases & Error Scenarios**

* No Negative / Validation, Error / System Failure, Offline, or Interrupted UC rows are specified for SCR-18 in the Inventory.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-16 — Active Workout — Exercise & Set Logging. The user reaches SCR-18 by selecting Cancel during an active workout.  
* **Screen exit dependencies:**  
  * SCR-16 — when cancellation is not confirmed / the user resumes the active workout.  
  * SCR-06 — when cancellation is confirmed.  
* **\[ASSUMPTION\] flag:** None specified for SCR-18.  
* **Underspecified behavior:** The Inventory specifies that SCR-18 presents a confirmation modal and that confirming cancellation discards the session and routes to SCR-06. It does not specify the exact modal title, button labels, complete confirmation copy, or behavior for dismissing the modal without confirming. **Confirm with SRS/SDS owner before defining these details.**  
* **Full-chain traceability summary:**  
  * **SRS-FR-29 → SDS-COMP-7 / SDS-ERR-8 → UC-SCR18-01 → FR-1 / AC-1**  
  * **SRS-FR-29 → SDS-COMP-7 → UC-SCR18-02 → FR-2 / FR-3 / AC-2**  
  * **BRD-FR/NFR mapping:** The supplied Inventory does not provide the corresponding BRD requirement ID for SRS-FR-29 in the SCR-18 rows. **Not specified in Inventory — confirm with SRS/SDS owner.**


## **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockup covering the one state this story defines: the Cancel confirmation modal over a dimmed SCR-16 background, warning that progress won't be saved (§8 AC-1).  
* **Tool:** Claude Design canvas (not Figma) — one artboard.  
* **Link:** [https://claude.ai/code/artifact/f8a48120-7d5c-44cf-9f2f-6e5a8b5d39de](https://claude.ai/code/artifact/f8a48120-7d5c-44cf-9f2f-6e5a8b5d39de)  
* **Artifact title:** "ForgeApp Cancel Workout Confirmation" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Cancel Confirmation modal).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-17 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, card border `#444933`, muted text `#c4c9ac`. Like SCR-11's Delete Plan confirmation (also an irreversible discard of in-progress work), the confirming action uses the danger red `#ff6b6b` ("Discard Workout"), not the lime primary — cancelling a workout permanently loses logged sets with no undo, the same stakes as SCR-11's plan deletion, unlike SCR-14's lime-colored schedule removal (an easily re-added action).  
* **Scope note:** the Inventory leaves the exact modal title, button labels, and full confirmation copy unspecified (§10), and does not define behavior for dismissing the modal without confirming — the mockup shows a "Keep Going" secondary action (returns to SCR-16, per §10's exit dependency) as one plausible non-confirm path; exact copy and dismiss behavior should be confirmed with the SRS/SDS owner.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
