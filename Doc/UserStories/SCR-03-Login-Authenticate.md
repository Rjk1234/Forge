# **\#Forge-US-3**

# **1\. User Story Identification**

* **Story ID:** US-SCR-03  
* **Title:** Login — Authenticate Existing User  
* **Epic / Feature:** Authentication  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As the app's user, I want to sign in with the static demo email and password so that I can play through a login-like flow and reach the app's main screens.

# **3\. Description / Context**

**Materially rewritten, 2026-09-05 (Decisions Log §0).** SCR-03 is the static, hardcoded "show-off" Login screen. There is no real authentication: no registered accounts, no account registry, no registration, no forgot-password, no reset-password, no email verification, no OTP, no biometric auth, no multi-user accounts, and no session/token management beyond a simple local unlocked/locked flag.

The screen allows the user to enter an email and password and tap **Login**. The entered values are compared to a single hardcoded static credential via a local string match — there is no server round-trip. ~~The screen also provides navigation to "Forgot password?" and "Create account."~~ **REMOVED, 2026-09-05 (Decisions Log §0/§46) — confirmed: no login recovery flow of any kind, and no registration to link to.**

~~The login flow must distinguish between: invalid email format, incorrect credentials, disabled account, authentication service failure, lack of network connectivity.~~ — **REMOVED, 2026-09-05.** None of these apply to a static local-match login: there is no format-validation business rule beyond non-empty input, no "disabled account" concept (there is exactly one fixed credential), no authentication service to fail, and no network connectivity to lose.

Successful login routes the user to **SCR-06 — Home Dashboard**.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty email field and password field when the Login screen is first opened. **(UC-SCR03-01; updated 2026-09-05 — the submit-disabled-until-valid framing is simplified to non-empty-input only, since there is no real format validation)**  
* **FR-2** — The system shall validate that the entered email matches a standard email format (e.g., contains "@" with a domain) before allowing the user to submit the login attempt. **(UC-SCR03-02)**  
* **FR-3** — The system shall display a loading state while the entered credentials are being checked against the stored login credential, indicating the login attempt is in progress and preventing duplicate submissions. **(UC-SCR03-03)**  
* **FR-4** — When the entered email and password match the hardcoded static credential, the system shall route the user to SCR-06 — Home Dashboard. **(UC-SCR03-04; updated 2026-09-05 — replaces "authenticate the user," since there is no real authentication)**  
* **FR-5** — When the entered email/password does not match the hardcoded static credential, the system shall reject the login attempt and display the generic error: **"Email or password is incorrect"**. **(UC-SCR03-05; updated 2026-09-05 — replaces "incorrect or the account does not exist," since there is no account registry)**  
* ~~**FR-6** — disclosure prevention re: whether an email is registered~~ — **REMOVED, 2026-09-05.** Not applicable; there is no account registry for an email to be registered against.  
* ~~**FR-7** — disabled account~~ — **REMOVED, 2026-09-05.** Not applicable; there is exactly one fixed static credential and no account-disable concept.  
* ~~**FR-8** — authentication service failure banner~~ — **REMOVED, 2026-09-05.** Not applicable; there is no authentication service (Decisions Log §0).  
* ~~**FR-9** — offline state during login submission~~ — **REMOVED, 2026-09-05.** Not applicable; the app has no network calls anywhere (Decisions Log §0).  
* ~~**FR-10** — "Forgot password?" navigation~~ — **REMOVED, 2026-09-05.** Confirmed: no login recovery flow of any kind (Decisions Log §0/§46).  
* ~~**FR-11** — "Create account" navigation~~ — **REMOVED, 2026-09-05.** Confirmed: no registration flow (Decisions Log §0).

# **5\. Non-Functional Requirements**

* ~~**NFR-1** — loading-state duplicate-submission prevention~~ — **REMOVED, 2026-09-05.** No loading state applies to an instantaneous local comparison.  
* ~~**NFR-2** — offline-vs-authentication-failure distinction~~ — **REMOVED, 2026-09-05.** No connectivity condition exists.  
* ~~**NFR-3** — non-technical authentication-service error presentation~~ — **REMOVED, 2026-09-05.** No authentication service exists to fail.

# **6\. Security & Privacy Requirements**

* **SEC-1** — The app routes the user to its main screens only when the local login state is unlocked (a locally-tracked flag, not a real authenticated session). **(Updated 2026-09-05 — replaces "the login flow shall require authentication," since there is no real authentication.)**  
* **SEC-2** — Non-matching credentials shall result in the generic message **"Email or password is incorrect"**. **(Updated 2026-09-05 — the "shall not reveal whether the submitted email corresponds to an existing account" framing is removed as not applicable; there is no account registry.)**  
* ~~**SEC-3** — authentication-service error non-disclosure~~ — **REMOVED, 2026-09-05.** Not applicable; there is no authentication service.  
* **Note:** This screen provides no real authentication security and must not be built or documented as a real security boundary (Decisions Log §0).

# **7\. UI / Component Specifications**

### **Email Field**

* **Component type:** Email-shaped text input field  
* **Validation rules:** Non-empty input only; no email-format business rule. **(Updated 2026-09-05.)**  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** None at the field level.  
* **Mandatory / Optional:** Required to attempt login.

### **Password Field**

* **Component type:** Password input field  
* **Validation rules:** Non-empty input only.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** **"Email or password is incorrect"** when the local match fails.  
* **Mandatory / Optional:** Required to attempt login.

### **Submit ("Login") Action**

* **Component type:** Submit action/button  
* **Input type:** User action  
* **Validation rules:** Performs a local string-match comparison against the single hardcoded static credential.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** **"Email or password is incorrect"** for any non-matching input.  
* **Mandatory / Optional:** Required action to submit login.  
* *(Updated 2026-09-05 — replaces server-side authentication submission.)*

### ~~Forgot Password Action~~ — REMOVED, 2026-09-05

Confirmed: no login recovery flow of any kind (Decisions Log §0/§46).

### ~~Create Account Action~~ — REMOVED, 2026-09-05

Confirmed: no registration flow (Decisions Log §0).

### ~~Loading State~~ — REMOVED, 2026-09-05

Not needed for an instantaneous local comparison.

### **Login Error State**

* **Component type:** Error message/banner  
* **Input type:** System state  
* **Validation rules:** Displayed when the local match fails.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** **"Email or password is incorrect"**  
* **Mandatory / Optional:** Required when applicable.  
* *(Renamed from "Authentication Error State" 2026-09-05 — the disabled-account variant is removed as not applicable.)*

### ~~Offline State~~ — REMOVED, 2026-09-05

The app has no network calls anywhere (Decisions Log §0); this state does not apply.

# **8\. Acceptance Criteria**

### **AC-1 — Empty / Default Login State**

**Given** the user opens SCR-03 — Login  
**When** the screen is first displayed  
**Then** the email and password fields shall be empty.  
**(UC-SCR03-01; updated 2026-09-05 — removes the "minimally valid" gating language)**

### ~~AC-2 — Valid Login Submission Loading State~~ — REMOVED, 2026-09-05

Not applicable; there is no loading state for an instantaneous local comparison.

### **AC-3 — Successful Login**

**Given** the user has entered the email/password matching the hardcoded static credential  
**When** the user taps Login  
**Then** the system shall route the user to SCR-06 — Home Dashboard.  
**(UC-SCR03-04; updated 2026-09-05 — replaces "authentication succeeds")**

### **AC-4 — Wrong Email or Password**

**Given** the user submits an email/password that does not match the hardcoded static credential  
**When** the login attempt is rejected  
**Then** the system shall display **"Email or password is incorrect"**.  
**(UC-SCR03-05; updated 2026-09-05 — removes the "unknown account" / disclosure framing, since there is no account registry)**

### ~~AC-5 — Disabled Account~~ — REMOVED, 2026-09-05

Not applicable; there is exactly one fixed static credential and no account-disable concept.

### ~~AC-6 — Authentication Service Failure~~ — REMOVED, 2026-09-05

Not applicable; there is no authentication service.

### ~~AC-7 — Offline Login Attempt~~ — REMOVED, 2026-09-05

Not applicable; the app has no network connectivity.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Malformed Email Format**

**Given** the user enters an email address that does not match a valid email format  
**When** the user attempts to submit the login form  
**Then** the system shall display an inline validation error and block submission until a valid email format is entered.

### ~~EC-2 — Authentication Service Failure~~ — REMOVED, 2026-09-05

Not applicable; there is no authentication service (this also removes the prior reference to "the Firebase Authentication service," which is DEPRECATED per Decisions Log §0).

### ~~EC-3 — Offline During Submission~~ — REMOVED, 2026-09-05

Not applicable; the app has no network connectivity.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 — Splash / Local Login-State Check  
  * SCR-26 — Logout Confirmation  
* **Screen exit dependencies:**  
  * SCR-06 — Home Dashboard, on a matching login.  
* **REMOVED, 2026-09-05 (Decisions Log §0):** SCR-05 — Password Reset Email Sent (entry dependency), SCR-02 — Registration and SCR-04 — Forgot Password (exit dependencies via "Create account" / "Forgot password?"). These screens and their flows are DEPRECATED/OUT-OF-SCOPE — there is no registration, forgot-password, or reset-password flow of any kind.  
* **\[ASSUMPTION\] flag:** Not specified for SCR-03 in the Inventory.  
* **Underspecified behavior requiring confirmation:**  
  * The exact value of the hardcoded static credential (and where/how it is configured) is not specified — confirm with Product/SDS owner before implementation.  
* **Full-chain traceability summary:**  
  The BRD-FR/NFR → SRS-FR/NFR → SDS → Inventory UC trace previously cited throughout this story (SRS-FR-2, SDS-COMP-2/15, SDS-IF-2/9, SDS-ERR-1/3, BR-NFR-020, UC-SCR03-01 through UC-SCR03-08) describes the DEPRECATED Firebase Authentication architecture (Decisions Log §0) and should be treated as stale pending an SRS/SDS update, rather than re-used at face value for the static local-login behavior rewritten above.

