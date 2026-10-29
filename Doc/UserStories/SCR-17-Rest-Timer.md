# **\#Forge-US-17**

# **1\. User Story Identification**

* **Story ID:** US-SCR17  
* **Title:** Rest Timer  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

**As a user with the app unlocked, I want to see and control the rest period between workout sets, so that I can manage the required recovery time before continuing my workout.**

# **3\. Description / Context**

SCR-17 provides the work/rest timing experience between sets during an active workout. The rest timer is presented inline or as an overlay on SCR-16 and **auto-starts the moment the user marks a set complete** (no manual "tap Start" step) — Decisions Log §6, confirmed 2026-09-05.

The timer operates entirely locally (the app has no network calls anywhere — Decisions Log §0), allows the user to tap **Skip** to end the rest period early, and automatically returns the user to the active workout when the countdown reaches zero.

**App-backgrounded timer behavior is DEFERRED/open (Decisions Log §6b)** — whether this timer pauses-and-resumes, catches up to wall-clock time, or ends the session when the app is backgrounded is not decided and is not specified by this story.

# **4\. Functional Requirements**

* **FR-1** — When the user marks a set complete, the rest timer shall auto-start immediately (no manual start step) and the system shall display a countdown for the configured rest period. **(UC-SCR17-01, SRS-NFR-2; updated per Decisions Log §6, 2026-09-05)**  
* **FR-2** — The rest countdown runs entirely locally; the app makes no network calls anywhere (Decisions Log §0). **(UC-SCR17-01, SRS-NFR-2)**  
* **FR-3** — The system shall allow the user to tap **Skip** to end the remaining rest period early. **(UC-SCR17-02, SRS-FR-29)**  
* **FR-4** — When the user skips the remaining rest period, the system shall return immediately to SCR-16. **(UC-SCR17-02, SRS-FR-29)**  
* **FR-5** — When the rest timer reaches zero, the system shall automatically advance to the next set or exercise on SCR-16 without requiring user confirmation. **(UC-SCR17-03, SRS-NFR-14, SDS-NFR-16)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The rest countdown shall operate independently of network calls during the configured rest period. **(UC-SCR17-01, SRS-NFR-2, SDS-NFR-2)**  
* **NFR-2** — The timer shall automatically advance the workout when the countdown reaches zero without requiring additional user confirmation. **(UC-SCR17-03, SRS-NFR-14, SDS-NFR-16)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the rest timer shall require the app's local login state to be unlocked, as part of the active workout flow. **(UC-SCR17-01, SRS-NFR-2; updated 2026-09-05 — replaces "authenticated user session")**  
* **SEC-2** — The rest timer shall operate within the current active workout session only, on this single local user's data. **(UC-SCR17-01, SRS-NFR-2; updated 2026-09-05 — drops "another user," since there is no multi-user access concern)**

# **7\. UI / Component Specifications**

### **Rest Timer**

* **Component type:** Countdown timer, presented inline or as an overlay on SCR-16  
* **Input type:** Configured rest period  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when a configured rest period begins

### **Skip Rest Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Optional user action

### **Automatic Advance**

* **Component type:** Automatic navigation/progression behavior  
* **Input type:** Timer completion  
* **Validation rules:** Timer must reach zero  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Mandatory

# **8\. Acceptance Criteria**

### **AC-1 — Rest Period Begins**

**(UC-SCR17-01)**

**Given** an active workout reaches a configured rest period,  
**When** the rest period begins,  
**Then** the system shall display a countdown and the countdown shall run independently of any network call.

### **AC-2 — Skip Remaining Rest**

**(UC-SCR17-02)**

**Given** the rest timer is running,  
**When** the user skips the remaining rest period,  
**Then** the system shall immediately return to SCR-16.

### **AC-3 — Timer Reaches Zero**

**(UC-SCR17-03)**

**Given** the rest timer is running,  
**When** the countdown reaches zero,  
**Then** the system shall automatically advance to the next set or exercise on SCR-16 without requiring confirmation.

# **9\. Edge Cases & Error Scenarios**

**No Negative/Validation, Error/System Failure, Offline, or Interrupted UC rows are defined for SCR-17 in the Inventory.**

The Inventory explicitly defines the rest timer as operating independently of network calls; therefore, no separate offline/error UC is introduced for this screen.

# **10\. Dependencies & Notes**

* **Screen entry dependency:**  
  * SCR-16 — Active Workout — Exercise & Set Logging  
* **Screen exit dependency:**  
  * SCR-16 — Active Workout — Exercise & Set Logging  
* **\[ASSUMPTION\] flag:** None specified for SCR-17.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual presentation of the countdown, including its format, units, or visual treatment — **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The Inventory does not specify the exact label or wording of the skip-rest action — **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The Inventory does not specify how the configured rest duration is represented or what constitutes a configured rest period beyond its existence in the set configuration — **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * App-backgrounded timer behavior remains **DEFERRED/open** per Decisions Log §6b.  
* **Full-chain traceability summary:**  
  * **UC-SCR17-01** → SRS-NFR-2 / SDS-NFR-2 → **FR-1, FR-2 / NFR-1 / SEC-1 / AC-1**  
  * **UC-SCR17-02** → SRS-FR-29 → **FR-3, FR-4 / AC-2**  
  * **UC-SCR17-03** → SRS-NFR-14 / SDS-NFR-16 → **FR-5 / NFR-2 / SEC-2 / AC-3**  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain. This story derives strictly from all 3 UC rows defined for **SCR-17** and introduces no additional functional scope.



# **11\. Design Reference**

* **Added 2026-09-07.** Static UI mockup covering the one visual state this story defines: the Rest Timer overlay on SCR-16, auto-started, showing the countdown, a preview of the next set/exercise, and the Skip Rest action (§8 AC-1, AC-2). Automatic advance at zero (§8 AC-3) is a behavior, not a distinct visual state — it returns the user to SCR-16's existing Active set-logging layout (already designed in that story's reference).  
* **Tool:** Claude Design canvas (not Figma) — one artboard.  
* **Link:** [https://claude.ai/code/artifact/1f762b66-1595-4a86-9af1-be8bb124c3c7](https://claude.ai/code/artifact/1f762b66-1595-4a86-9af1-be8bb124c3c7)  
* **Artifact title:** "ForgeApp Rest Timer" (find it via this title in the claude.ai artifact gallery at claude.ai/code/artifacts if the direct link above ever changes).  
* **Artboards on the canvas:** Main.dc.html (Rest Timer overlay — countdown, next-set preview, Skip Rest).  
* **Visual language:** matches the existing ForgeApp Figma file (`fileKey=0oxHvmnCM27XHqmEZjojtb`) and the SCR-06 through SCR-16 design references — dark backgrounds `#131315`/`#201f22`/`#2a2a2c`, lime accent `#c3f400` for the countdown ring, card border `#444933`, muted text `#c4c9ac`. Shown as a scrim overlay over a dimmed SCR-16 background, consistent with how SCR-16's own Paused state was presented, since the rest timer is described in the Inventory as "presented inline or as an overlay on SCR-16" (§7).  
* **Scope note:** the Inventory leaves the countdown's exact visual presentation, format/units, and the skip action's exact label unspecified (§10) — the mockup uses a ring countdown with an mm:ss readout and a "Skip Rest" label as one plausible presentation; these should be confirmed with the SRS/SDS owner. Only one countdown state (mid-countdown) is shown; no distinct "about to expire" or "just started" variant is designed, since none is called for by the Inventory. App-backgrounded timer behavior (Decisions Log §6b) remains deferred and is not depicted.  
* **Status:** reference mockups for development, not a locked/approved design system source. Treat SDS/Inventory text as the requirement of record if this reference and the documents ever disagree.
