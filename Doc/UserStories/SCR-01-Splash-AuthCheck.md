# **\#Forge-US-1**

# **1\. User Story Identification**

* **Story ID:** US-SCR01  
* **Title:** Splash / Auth Check  
* **Epic / Feature:** Authentication  
* **Priority:** High  
* **Story Points:** Not specified in Inventory — confirm with Product Owner

# **2\. User Story Statement**

As a user launching or resuming the Workout Tracker application, I want the application to check my local login state so that I am automatically routed to the appropriate starting screen.

# **3\. Description / Context**

**Materially rewritten, 2026-09-05 (Decisions Log §0).** The prior version of this story described a real Firebase Authentication session check with a network-dependent "No connection" blocking state. That architecture is DEPRECATED. SCR-01 is now the entry screen for a purely local, static login flow: it is displayed when the application is launched or resumed and performs an instantaneous **local** login-state check (no network call, nothing to time out or fail to resolve).

While the local check runs (expected to be effectively instant), the screen displays the brand/splash indicator and provides no user interaction. The user is then routed either to the Home Dashboard (SCR-06), if already locally unlocked, or to Login (SCR-03) otherwise.

**Login is not real authentication (Decisions Log §0).** It is a static, hardcoded "show-off" login screen (email + password inputs + a Login button) that exists purely so the user can play through a login-like flow. There is no registration, no forgot-password, no reset-password, no email verification, no OTP, no biometric auth, no multi-user accounts, and no real session/token — only a simple local unlocked/locked flag. Login failures are handled on SCR-03 by a plain local string match against the hardcoded credential; there is no server-side validation and no email-format business rule beyond basic non-empty input.

~~If connectivity is unavailable and the authentication state cannot be resolved, the application displays a blocking "No connection" state with a retry action.~~ — **REMOVED, 2026-09-05.** The app has no network calls anywhere (Decisions Log §0); there is no connectivity condition for this screen to handle.

# **4\. Functional Requirements**

* **FR-1** — While the local login-state check runs during application launch or resume, the system shall display the brand/splash indicator and shall provide no user interaction. **(UC-SCR01-01; updated 2026-09-05 — this is a local, non-network check)**  
* **FR-2** — When the local login state is unlocked, the system shall route the user to SCR-06. **(UC-SCR01-02; updated 2026-09-05 — replaces "authentication state resolves to authenticated")**  
* **FR-3** — When the local login state is locked (or has never been unlocked), the system shall route the user to SCR-03. **(UC-SCR01-03; updated 2026-09-05 — replaces "authentication state resolves to unauthenticated")**  
* **FR-4** — On SCR-03, the system shall compare the entered email and password against the single hardcoded static credential using a local string match; there is no email-format business validation beyond requiring non-empty input. **(UC-SCR03-02; updated 2026-09-05 — replaces the prior email-format regex validation, which implied a real account-registry check)**  
* **FR-5** — On SCR-03, when the user taps Login with the fields filled in, the system shall perform the local comparison immediately (a brief loading state is optional/cosmetic only, since there is no network round-trip). **(UC-SCR03-03; updated 2026-09-05)**  
* **FR-6** — On SCR-03, when the entered email/password does not match the hardcoded static credential, the system shall display the generic error **"Email or password is incorrect"**. **(UC-SCR03-05; updated 2026-09-05 — the message is unchanged, but it now reflects a local string-match failure, not a real account lookup)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The local login-state check shall not permit the application to proceed to SCR-06 until the check has completed (expected to be effectively instantaneous). **(UC-SCR01-01; updated 2026-09-05)**  
* ~~**NFR-2** — no-connection blocking state~~ — **REMOVED, 2026-09-05.** No connectivity condition exists (Decisions Log §0); UC-SCR01-04 no longer applies.  
* **NFR-3** — Since the static credential is fixed and there is no real account registry, the login error message is generic by default; there is no real disclosure risk to guard against, but the copy is kept as **"Email or password is incorrect"** for consistency with the play-through flow. **(Updated 2026-09-05.)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — The system shall route the user to SCR-06 only when the local login state is unlocked. **(UC-SCR01-02; updated 2026-09-05)**  
* **SEC-2** — The system shall route the user to SCR-03 when the local login state is locked. **(UC-SCR01-03; updated 2026-09-05)**  
* ~~**SEC-3** — no offline/local-session fallback~~ — **REMOVED, 2026-09-05.** Not applicable; there is no network/offline condition (Decisions Log §0).  
* **SEC-4** — The login screen shall use the generic message **"Email or password is incorrect"** for any non-matching input. **(Updated 2026-09-05 — this is not a real security control, since the static credential is fixed and there is no real lockout risk per Decisions Log §0.)**  
* **Note:** This screen provides no real authentication security. It is intentionally a static, hardcoded "show-off" login per Decisions Log §0 — do not build or document it as a real security boundary.

# **7\. UI / Component Specifications**

### **Brand / Splash Indicator**

* **Component type:** Brand/splash indicator  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory while the local login-state check runs

### ~~No Connection State~~ — REMOVED, 2026-09-05

No network connectivity exists to lose (Decisions Log §0); this state does not apply and has been removed.

### **Login Email Field**

* **Component type:** Email-shaped text field (input only — not validated against any real account)  
* **Validation rules:** Non-empty input only; no email-format business rule (Decisions Log §0 — static demo login, not a real account system)  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** None at the field level; a failed match is reported at submit (see Login Submit Action)  
* **Mandatory / Optional:** Required to attempt login  
* *(Updated 2026-09-05 — removes the prior email-format regex validation.)*

### **Login Password Field**

* **Component type:** Password field  
* **Validation rules:** Non-empty input only  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** **"Email or password is incorrect"** when the local match fails  
* **Mandatory / Optional:** Required to attempt login

### **Login Submit Action**

* **Component type:** Submit action ("Login" button)  
* **Input type:** Tap/action  
* **Validation rules:** Compares entered email + password to the single hardcoded static credential via local string match  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** **"Email or password is incorrect"** for any non-matching input  
* **Mandatory / Optional:** Mandatory  
* *(Updated 2026-09-05 — replaces server-side authentication with a local, static credential comparison; Decisions Log §0.)*

### ~~Forgot Password Link~~ — NOT PRESENT, confirmed 2026-09-05

Per Decisions Log §0/§46 ("no login recovery flow of any kind"), SCR-03 has no "Forgot password?" link and no Registration/"Create account" link. There is exactly one credential; it cannot be reset or recovered, and there is no other account to create.

# **8\. Acceptance Criteria**

### **AC-1 — Splash / Local Check**

**UC:** UC-SCR01-01

**Given** the application is launched or resumed  
**When** SCR-01 is displayed while the local login-state check runs  
**Then** the system shall show the brand/splash indicator  
**And** no user interaction shall be available. **(UC-SCR01-01; updated 2026-09-05 — local check, not a network authentication-state resolution)**

### **AC-2 — Already-Unlocked Routing**

**UC:** UC-SCR01-02

**Given** the application is on SCR-01  
**When** the local login state is unlocked  
**Then** the system shall route the user to SCR-06. **(UC-SCR01-02; updated 2026-09-05)**

### **AC-3 — Locked Routing**

**UC:** UC-SCR01-03

**Given** the application is on SCR-01  
**When** the local login state is locked (or has never been unlocked)  
**Then** the system shall route the user to SCR-03. **(UC-SCR01-03; updated 2026-09-05)**

### ~~AC-4 — Invalid Email Format~~ — REMOVED, 2026-09-05

Not applicable; there is no email-format business validation (Decisions Log §0).

### ~~AC-5 — Login Processing~~ — REMOVED, 2026-09-05

Not applicable as a distinct loading state; the local string-match comparison is effectively instantaneous, with no network round-trip to wait on.

### **AC-6 — Non-Matching Credentials**

**UC:** UC-SCR03-05

**Given** the user is on SCR-03  
**And** the entered email/password does not match the hardcoded static credential  
**When** the user taps Login  
**Then** the system shall display the generic error **"Email or password is incorrect"**.  
**(UC-SCR03-05; updated 2026-09-05 — replaces the prior "authentication fails / unknown account" framing.)**

# **9\. Edge Cases & Error Scenarios**

### ~~EC-1 — No Connectivity During Authentication Check~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); UC-SCR01-04 no longer applies.

### ~~EC-2 — Invalid Email Format~~ — REMOVED, 2026-09-05

Not applicable; there is no email-format business validation.

### **EC-3 — Non-Matching Credentials**

**UC:** UC-SCR03-05

**Given** the user is on SCR-03  
**When** the entered email/password does not match the hardcoded static credential  
**Then** the system shall display **"Email or password is incorrect"**.  
**(UC-SCR03-05; updated 2026-09-05 — replaces "incorrect password or unknown account," since there is no account registry to be unknown from.)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 is entered from application cold start or application resume.  
  * SCR-03 is reached from SCR-01 when the local login state is locked.  
* **Screen exit dependencies:**  
  * Unlocked state → **SCR-06 — Home Dashboard**  
  * Locked state → **SCR-03 — Login**  
* **Related screen dependency:**  
  * **SCR-03 — Login** contains the static-credential comparison and non-matching-credentials handling.  
* **\[ASSUMPTION\] flag:**  
  * No `[ASSUMPTION]` flag is present for SCR-01 in the supplied Inventory.  
* **REMOVED, 2026-09-05 (Decisions Log §0):**  
  * SCR-02 — Registration, SCR-04 — Forgot Password, and SCR-05 — Password Reset Email Sent are DEPRECATED/OUT-OF-SCOPE. There is no registration, no forgot-password, and no reset-password flow of any kind. Any prior reference to these screens from SCR-01/SCR-03 has been removed.  
  * The prior Firebase Authentication-service-failure and offline/connectivity handling (disabled account, auth-service failure banner, "You're offline" state) no longer applies — there is no auth service and no network.  
* **Underspecified behavior:**  
  * The exact visual design/content of the **brand/splash indicator** is not specified in Inventory — confirm with Product Design/SDS owner.  
  * The exact value of the hardcoded static credential (and where it is stored/configured) is not specified — confirm with Product/SDS owner before implementation.  
* **Full-chain traceability summary:**

| Story Item | Note |
| ----- | ----- |
| FR-1 / AC-1 | UC-SCR01-01 — local check only, re-scoped 2026-09-05 |
| FR-2 / AC-2 / SEC-1 | UC-SCR01-02 — re-scoped 2026-09-05 |
| FR-3 / AC-3 / SEC-2 | UC-SCR01-03 — re-scoped 2026-09-05 |
| ~~UC-SCR01-04~~ | Removed 2026-09-05 — no connectivity condition exists |
| FR-4 | UC-SCR03-02 — re-scoped 2026-09-05 to non-empty-input check only |
| ~~UC-SCR03-03~~ | Removed as a distinct AC/EC 2026-09-05 — no loading state needed for an instantaneous local check |
| FR-6 / NFR-3 / SEC-4 / AC-6 / EC-3 | UC-SCR03-05 — re-scoped 2026-09-05 to local string-match failure |

*   
  **Note:** The BRD/SRS/SDS trace IDs previously cited throughout this story (SRS-FR-2/3/6, SDS-IF-2/9, SDS-COMP-12/13, SDS-ERR-3, BR-NFR-020) describe the DEPRECATED Firebase Authentication architecture and should be treated as stale pending an SRS/SDS update to match Decisions Log §0, rather than re-used at face value for the rewritten local-login behavior above.  
  **Strict single-screen traceability:** For a formally locked **US-SCR01**, FR-4 through FR-6 and their related AC/Edge Cases should instead belong to **US-SCR03 — Login**.

\#Forge-US-2 is kept out of scope on purpose. *(Forge-US-2 corresponds to Registration/SCR-02. Confirmed OUT-OF-SCOPE, 2026-09-05, Decisions Log §0 — there is no registration flow of any kind in this app.)*

