# **\#Forge-US-1**

# **1\. User Story Identification**

* **Story ID:** US-SCR01  
* **Title:** Splash / Auth Check  
* **Epic / Feature:** Authentication  
* **Priority:** High  
* **Story Points:** Not specified in Inventory — confirm with Product Owner

# **2\. User Story Statement**

As a user launching or resuming the Workout Tracker application, I want the application to determine whether I have a valid authenticated session so that I am automatically routed to the appropriate starting screen.

# **3\. Description / Context**

SCR-01 is the entry screen for the Authentication flow. It is displayed when the application is launched or resumed and performs an authentication-state check without requiring user interaction.

While the authentication state is unresolved, the screen displays the brand/splash indicator and provides no user interaction. Once the authentication state is resolved, the user is routed either to the authenticated Home Dashboard (SCR-06) or to Login (SCR-03).

Authentication failures are handled on SCR-03. The Login screen validates the email format before submission and displays a generic error when the supplied email/password combination is incorrect.

If connectivity is unavailable and the authentication state cannot be resolved, the application displays a blocking **"No connection"** state with a retry action. The application cannot proceed because there is no offline/local session cache.

# **4\. Functional Requirements**

* **FR-1** — While the authentication state is unresolved during application launch or resume, the system shall display the brand/splash indicator and shall provide no user interaction. **(UC-SCR01-01, SRS-FR-3/SRS-FR-6)**  
* **FR-2** — When the authentication state resolves to authenticated, the system shall route the user to SCR-06. **(UC-SCR01-02, SRS-FR-3/SRS-FR-6)**  
* **FR-3** — When the authentication state resolves to unauthenticated, the system shall route the user to SCR-03. **(UC-SCR01-03, SRS-FR-2)**  
* **FR-4** — On SCR-03, when the user enters an email that does not conform to the required email format, the system shall display an inline validation error and prevent authentication submission. **(UC-SCR03-02, SRS-FR-2, SDS-COMP-12)**  
* **FR-5** — On SCR-03, when the user submits valid login credentials, the system shall show the submit action in a loading state while authentication is being processed. **(UC-SCR03-03, SDS-IF-2)**  
* **FR-6** — On SCR-03, when the supplied email/password combination is incorrect or the account is unknown, the system shall display the generic error **"Email or password is incorrect"**. **(UC-SCR03-05, SRS-FR-2, SDS-ERR-3)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The authentication-state determination shall not permit the application to proceed to an authenticated destination until the authentication state has been resolved. **(UC-SCR01-01, SRS-NFR-*\*/SDS-NFR-*\*)**  
  *Specific SRS-NFR/SDS-NFR ID is not specified in the SCR-01 Inventory row — confirm with SRS/SDS owner.*  
* **NFR-2** — When connectivity is unavailable and authentication state resolution cannot proceed, the screen shall block application progression rather than provide an offline/local-session fallback. **(UC-SCR01-04, BR-NFR-020, SDS-COMP-13)**  
* **NFR-3** — Login authentication errors shall not expose whether an account exists when the supplied credentials are incorrect or the account is unknown. **(UC-SCR03-05, SRS-FR-2, SDS-ERR-3)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — The system shall route the user to SCR-06 only when the authentication state resolves to authenticated. **(UC-SCR01-02, SRS-FR-3/SRS-FR-6)**  
* **SEC-2** — The system shall route the user to SCR-03 when the authentication state resolves to unauthenticated. **(UC-SCR01-03, SRS-FR-2)**  
* **SEC-3** — SCR-01 shall not provide an offline/local-session fallback when authentication state cannot be resolved. **(UC-SCR01-04, BR-NFR-020, SDS-COMP-13)**  
* **SEC-4** — The login screen shall use a generic authentication error for incorrect credentials or an unknown account and shall not reveal which condition occurred. **(UC-SCR03-05, SRS-FR-2, SDS-ERR-3)**

# **7\. UI / Component Specifications**

### **Brand / Splash Indicator**

* **Component type:** Brand/splash indicator  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory while authentication state is unresolved

### **No Connection State**

* **Component type:** Blocking "No connection" state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** **"No connection"**  
* **Mandatory / Optional:** Mandatory when authentication state cannot be resolved because there is no connectivity

### **Login Email Field**

* **Component type:** Email field  
* **Input type:** Email  
* **Validation rules:** Email must conform to the required email format  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Inline field error; exact validation copy is not specified in Inventory  
* **Mandatory / Optional:** Not specified in Inventory

### **Login Password Field**

* **Component type:** Password field  
* **Input type:** Password  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** **"Email or password is incorrect"** when authentication fails  
* **Mandatory / Optional:** Not specified in Inventory

### **Login Submit Action**

* **Component type:** Submit action  
* **Input type:** Tap/action  
* **Validation rules:** Submission is blocked when the email format is invalid  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** **"Email or password is incorrect"** for wrong password or unknown account  
* **Mandatory / Optional:** Mandatory

# **8\. Acceptance Criteria**

### **AC-1 — Authentication State Loading**

**UC:** UC-SCR01-01

**Given** the application is launched or resumed  
**And** the authentication state has not yet been resolved  
**When** SCR-01 is displayed  
**Then** the system shall show the brand/splash indicator  
**And** no user interaction shall be available. **(UC-SCR01-01)**

### **AC-2 — Authenticated User Routing**

**UC:** UC-SCR01-02

**Given** the application is on SCR-01  
**When** the authentication state resolves to authenticated  
**Then** the system shall route the user to SCR-06. **(UC-SCR01-02)**

### **AC-3 — Unauthenticated User Routing**

**UC:** UC-SCR01-03

**Given** the application is on SCR-01  
**When** the authentication state resolves to unauthenticated  
**Then** the system shall route the user to SCR-03. **(UC-SCR01-03)**

### **AC-4 — Invalid Email Format**

**UC:** UC-SCR03-02

**Given** the user is on SCR-03  
**When** the user enters an email that does not conform to the required email format  
**Then** the system shall display an inline field error  
**And** authentication submission shall be blocked. **(UC-SCR03-02)**

### **AC-5 — Login Processing**

**UC:** UC-SCR03-03

**Given** the user is on SCR-03  
**And** the login form is valid  
**When** the user submits the form  
**Then** the submit action shall show a loading state while authentication is being processed. **(UC-SCR03-03)**

### **AC-6 — Incorrect Email or Password**

**UC:** UC-SCR03-05

**Given** the user is on SCR-03  
**And** the supplied credentials are incorrect or the account is unknown  
**When** authentication fails for that reason  
**Then** the system shall display the generic error **"Email or password is incorrect"**  
**And** shall not disclose whether the email account exists. **(UC-SCR03-05)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — No Connectivity During Authentication Check**

**UC:** UC-SCR01-04

**Given** the application is launched  
**And** there is no connectivity  
**And** the authentication state cannot be resolved  
**When** SCR-01 cannot determine the authentication state  
**Then** the system shall show a blocking **"No connection"** state  
**And** provide a retry action  
**And** shall not proceed beyond SCR-01  
**And** shall not use an offline/local session cache as a fallback. **(UC-SCR01-04)**

### **EC-2 — Invalid Email Format**

**UC:** UC-SCR03-02

**Given** the user is on SCR-03  
**When** the user enters a malformed email format  
**Then** the system shall show an inline field error  
**And** shall prevent authentication submission. **(UC-SCR03-02)**

### **EC-3 — Incorrect Password or Unknown Account**

**UC:** UC-SCR03-05

**Given** the user is on SCR-03  
**When** the entered email/password combination is incorrect or the account is unknown  
**Then** the system shall display **"Email or password is incorrect"**  
**And** shall not distinguish between an incorrect password and an unknown account. **(UC-SCR03-05)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 is entered from application cold start or application resume.  
  * SCR-03 is reached from SCR-01 when the authentication state resolves to unauthenticated.  
* **Screen exit dependencies:**  
  * Authenticated state → **SCR-06 — Home Dashboard**  
  * Unauthenticated state → **SCR-03 — Login**  
* **Related authentication screen dependency:**  
  * **SCR-03 — Login** contains the email-format validation and incorrect-credentials handling associated with authentication.  
* **\[ASSUMPTION\] flag:**  
  * No `[ASSUMPTION]` flag is present for SCR-01 in the supplied Inventory.  
* **Scope note:**  
  * The supplied Inventory defines the wrong email/password and email-format validation behavior under **SCR-03 — Login**, not SCR-01. These requirements have therefore been added as **cross-screen authentication requirements** rather than being presented as SCR-01 UI behavior.  
* **Underspecified behavior:**  
  * The exact visual design/content of the **brand/splash indicator** is not specified in Inventory — confirm with Product Design/SDS owner.  
  * The exact behavior of the **retry action** after the "No connection" state is not specified in Inventory — confirm with SRS/SDS owner.  
  * The exact validation error copy for malformed email on SCR-03 is not specified in Inventory — confirm with SRS/SDS owner.  
  * Specific SRS-NFR/SDS-NFR IDs for the authentication-state loading behavior are not supplied in the SCR-01 UC traceability rows — confirm with SRS/SDS owner.  
* **Full-chain traceability summary:**

| Story Item | BRD | SRS | SDS | Inventory UC |
| ----- | ----- | ----- | ----- | ----- |
| FR-1 / AC-1 | Not specified in supplied Inventory | SRS-FR-3, SRS-FR-6 | SDS-IF-9 | UC-SCR01-01 |
| FR-2 / AC-2 / SEC-1 | Not specified in supplied Inventory | SRS-FR-3, SRS-FR-6 | SDS-IF-9 | UC-SCR01-02 |
| FR-3 / AC-3 / SEC-2 | Not specified in supplied Inventory | SRS-FR-2 | SDS-IF-9 | UC-SCR01-03 |
| NFR-2 / SEC-3 / EC-1 | BR-NFR-020 | Not specified in UC row | SDS-COMP-13 | UC-SCR01-04 |
| FR-4 / AC-4 / EC-2 | Not specified in supplied Inventory | SRS-FR-2 | SDS-COMP-12 | UC-SCR03-02 |
| FR-5 / AC-5 | Not specified in supplied Inventory | Not specified in UC row | SDS-IF-2 | UC-SCR03-03 |
| FR-6 / NFR-3 / SEC-4 / AC-6 / EC-3 | Not specified in supplied Inventory | SRS-FR-2 | SDS-ERR-3 | UC-SCR03-05 |

*   
  **Important traceability note:** The requested wrong email/password and email-format validation behavior is explicitly defined in the Inventory under **SCR-03**, not **SCR-01**. Therefore, those UC rows cannot be considered part of the SCR-01 story's native UC coverage without violating the stated single-screen derivation rule.  
  **Strict single-screen traceability:** For a formally locked **US-SCR01**, FR-4 through FR-6 and their related AC/Edge Cases should instead belong to **US-SCR03 — Login**.

\#Forge-US-2 is kept out of scope on purpose.

# **\#Forge-US-3**

# **1\. User Story Identification**

* **Story ID:** US-SCR-03  
* **Title:** Login — Authenticate Existing User  
* **Epic / Feature:** Authentication  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As an existing user, I want to securely sign in using my registered email address and password so that I can access my Workout Tracker account and authenticated features.

# **3\. Description / Context**

SCR-03 is the pre-authentication Login screen for existing users.

The screen allows the user to enter an email address and password and submit the credentials for authentication. The screen also provides navigation to **Forgot password?** and **Create account**.

The login flow must distinguish between:

* Invalid email format entered by the user.  
* Incorrect email/password credentials.  
* Disabled account.  
* Authentication service failure.  
* Lack of network connectivity.

Successful authentication routes the user to **SCR-06 — Home Dashboard**.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty email field and password field when the Login screen is first opened, with the submit action disabled until the entered information is minimally valid. **(UC-SCR03-01, SRS-FR-2)**  
* **FR-2** — The system shall validate the email address format and display an inline field error when the entered email address has an invalid format. **(UC-SCR03-02, SRS-FR-2)**  
* **FR-3** — The system shall submit valid login credentials for authentication and display a loading state on the submit action while authentication is in progress. **(UC-SCR03-03, SRS-FR-2)**  
* **FR-4** — When the entered credentials are correct, the system shall authenticate the user and route the user to SCR-06 — Home Dashboard. **(UC-SCR03-04, SRS-FR-2)**  
* **FR-5** — When the email/password combination is incorrect or the account does not exist, the system shall reject the authentication attempt and display the generic error: **"Email or password is incorrect"**. **(UC-SCR03-05, SRS-FR-2)**  
* **FR-6** — The system shall prevent the login response from revealing whether a specific email address is registered when the credentials are incorrect. **(UC-SCR03-05, SRS-FR-2)**  
* **FR-7** — When the user's account is disabled, the system shall display a clear error state indicating that the account cannot sign in currently. **(UC-SCR03-06, SRS-FR-2)**  
* **FR-8** — When the authentication service fails, the system shall display a non-technical error banner and provide a retry action. **(UC-SCR03-07, SDS-ERR-1, SDS-ERR-3)**  
* **FR-9** — When there is no connectivity during login submission, the system shall display an offline state distinct from an incorrect-credentials error. **(UC-SCR03-08, BR-NFR-020)**  
* **FR-10** — The Login screen shall provide navigation to the Forgot Password flow through the **"Forgot password?"**action. **(UC-SCR03-01, SRS-FR-2)**  
* **FR-11** — The Login screen shall provide navigation to the Registration flow through the **"Create account"** action. **(UC-SCR03-01, SRS-FR-2)**

# **5\. Non-Functional Requirements**

* **NFR-1** — While authentication is being processed, the submit action shall remain in a loading state and prevent duplicate submission until the authentication attempt completes. **(UC-SCR03-03, SDS-IF-2)**  
* **NFR-2** — When connectivity is unavailable during login submission, the system shall distinguish the offline condition from an authentication failure or incorrect credentials. **(UC-SCR03-08, BR-NFR-020, SDS-ERR-3)**  
* **NFR-3** — Authentication-service failures shall be presented as non-technical errors and shall not expose raw provider errors to the user. **(UC-SCR03-07, SDS-ERR-1, SDS-ERR-3)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — The login flow shall require authentication before routing the user to authenticated application areas. **(UC-SCR03-04, SRS-FR-2, SDS-IF-9)**  
* **SEC-2** — Incorrect credentials shall result in the generic message **"Email or password is incorrect"** and shall not reveal whether the submitted email corresponds to an existing account. **(UC-SCR03-05, SRS-FR-2, SDS-ERR-3)**  
* **SEC-3** — Authentication-service errors shall not expose raw provider errors or implementation details to the user. **(UC-SCR03-07, SDS-ERR-1, SDS-ERR-3)**

# **7\. UI / Component Specifications**

### **Email Field**

* **Component type:** Email input field  
* **Input type:** Email  
* **Validation rules:** Email must have a valid email format before submission.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Inline field error for malformed email format; exact validation error copy is **Not specified in Inventory**.  
* **Mandatory / Optional:** Required for minimally valid login submission.

### **Password Field**

* **Component type:** Password input field  
* **Input type:** Password  
* **Validation rules:** Must satisfy the screen's minimally valid submission condition.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** **Not specified in Inventory** for password-format validation.  
* **Mandatory / Optional:** Required for minimally valid login submission.

### **Submit Action**

* **Component type:** Submit action/button  
* **Input type:** User action  
* **Validation rules:** Disabled until the form is minimally valid.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Authentication errors are displayed according to the applicable UC state.  
* **Mandatory / Optional:** Required action to submit login credentials.

### **Forgot Password Action**

* **Component type:** Navigation link/action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available navigation action.

### **Create Account Action**

* **Component type:** Navigation link/action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available navigation action.

### **Loading State**

* **Component type:** Submit loading state  
* **Input type:** System state  
* **Validation rules:** Triggered when a valid form is submitted.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Required state.

### **Authentication Error State**

* **Component type:** Error message/banner  
* **Input type:** System state  
* **Validation rules:** Displayed for applicable authentication failures.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** **"Email or password is incorrect"** for wrong credentials/unknown account; disabled-account error wording is **Not specified in Inventory**.  
* **Mandatory / Optional:** Required when applicable.

### **Offline State**

* **Component type:** Offline state  
* **Input type:** System state  
* **Validation rules:** Triggered when there is no connectivity during submission.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** **"You're offline"** state; exact additional copy is **Not specified in Inventory**.  
* **Mandatory / Optional:** Required when applicable.

# **8\. Acceptance Criteria**

### **AC-1 — Empty / Default Login State**

**Given** the user opens SCR-03 — Login  
**When** the screen is first displayed  
**Then** the email and password fields shall be empty  
**And** the submit action shall remain disabled until the form is minimally valid.  
**(UC-SCR03-01)**

### **AC-2 — Valid Login Submission Loading State**

**Given** the user has entered minimally valid login information  
**When** the user submits the login form  
**Then** the submit action shall display a loading state while authentication is in progress.  
**(UC-SCR03-03)**

### **AC-3 — Successful Authentication**

**Given** the user has entered correct login credentials  
**When** authentication succeeds  
**Then** the system shall route the user to SCR-06 — Home Dashboard.  
**(UC-SCR03-04)**

### **AC-4 — Wrong Email or Password**

**Given** the user submits credentials that are incorrect or correspond to an unknown account  
**When** authentication rejects the credentials  
**Then** the system shall display **"Email or password is incorrect"**  
**And** the error shall not reveal whether the email address is registered.  
**(UC-SCR03-05)**

### **AC-5 — Disabled Account**

**Given** the user's account is disabled  
**When** the user attempts to sign in  
**Then** the system shall display a clear error state indicating that the account cannot sign in currently.  
**(UC-SCR03-06)**

### **AC-6 — Authentication Service Failure**

**Given** the user submits valid login information  
**When** the authentication service fails  
**Then** the system shall display a non-technical error banner  
**And** provide a retry action  
**And** shall not expose the raw provider error.  
**(UC-SCR03-07)**

### **AC-7 — Offline Login Attempt**

**Given** there is no network connectivity  
**When** the user submits the login form  
**Then** the system shall display an **"You're offline"** state  
**And** the state shall be distinguishable from an incorrect-credentials error.  
**(UC-SCR03-08)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Malformed Email Format**

**Given** the user enters an email address with an invalid format  
**When** the email field is validated  
**Then** the system shall display an inline field error  
**And** the login submission shall not proceed with the invalid email format.  
**(UC-SCR03-02)**

### **EC-2 — Authentication Service Failure**

**Given** the user submits login credentials  
**When** the Firebase Authentication service fails  
**Then** the system shall display a non-technical error banner  
**And** provide a retry action.  
**(UC-SCR03-07)**

### **EC-3 — Offline During Submission**

**Given** the user has entered login information  
**When** there is no connectivity at the time of submission  
**Then** the system shall display the offline state  
**And** shall not present the condition as a wrong-credentials error.  
**(UC-SCR03-08)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 — Splash / Auth Check  
  * SCR-05 — Password Reset Email Sent  
  * SCR-26 — Logout Confirmation  
* **Screen exit dependencies:**  
  * SCR-06 — Home Dashboard on successful authentication.  
  * SCR-02 — Registration through **"Create account"**.  
  * SCR-04 — Forgot Password through **"Forgot password?"**.  
* **\[ASSUMPTION\] flag:** Not specified for SCR-03 in the Inventory.  
* **Underspecified behavior requiring confirmation:**  
  * Exact inline validation error copy for malformed email is not specified in the Inventory.  
  * Exact disabled-account error copy is not specified in the Inventory.  
  * Exact offline-state copy beyond **"You're offline"** is not specified in the Inventory.  
  * Password-specific client-side validation constraints are not specified in the Inventory beyond the requirement that the form be minimally valid.  
  * Min/max constraints for the email and password fields are not specified in the Inventory.  
* **Full-chain traceability summary:**  
  **BRD-FR/NFR → SRS-FR/NFR → SDS → Inventory UC → User Story**  
  * **BR-FR-001 / applicable authentication business requirement → SRS-FR-2 → SDS-COMP-2, SDS-COMP-15, SDS-IF-2, SDS-IF-9, SDS-ERR-3 → UC-SCR03-01, UC-SCR03-02, UC-SCR03-04, UC-SCR03-05, UC-SCR03-06 → FR-1, FR-2, FR-4, FR-5, FR-6, FR-7, AC-1, AC-3, AC-4, AC-5, EC-1**  
  * **Authentication service design → SDS-IF-2, SDS-ERR-1, SDS-ERR-3 → UC-SCR03-03, UC-SCR03-07 → FR-3, FR-8, NFR-1, NFR-3, AC-2, AC-6, EC-2**  
  * **BR-NFR-020 → SDS-ERR-3 → UC-SCR03-08 → FR-9, NFR-2, AC-7, EC-3**  
  * **SRS-FR-2 → UC-SCR03-01 → FR-10, FR-11 → navigation to SCR-04 and SCR-02**

# **\#Forge-US-6**

# **1\. User Story Identification**

* **Story ID:** US-SCR-06  
* **Title:** Home Dashboard — Authenticated Landing & Navigation  
* **Epic / Feature:** Home / Navigation Shell  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

As an authenticated user, I want to access a Home Dashboard that provides an overview of my workout activity and navigation to the main workout features so that I can quickly access my plans, schedule, history, progress, and statistics.

# **3\. Description / Context**

SCR-06 is the authenticated landing screen and tab-navigation root of the Workout Tracker application.

The screen is reached after successful authentication and serves as the primary navigation point for authenticated users.

The dashboard supports three principal states defined in the Inventory:

* **Empty** — a new account with no plans, schedule, or history.  
* **Loading** — dashboard summary data is being fetched.  
* **Populated** — the user has plans, schedule, and/or history.  
* **Error** — dashboard data cannot be loaded while the navigation shell remains usable.  
* **Offline** — connectivity is lost while the user is on Home.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an onboarding-style empty state for a new account when no plans, schedule, or history exist, prompting the user to **"Create your first workout plan"**. **(UC-SCR06-01, SRS-FR-9)**  
* **FR-2** — The system shall display skeleton/placeholder cards while dashboard summary data is being fetched. **(UC-SCR06-02, SDS-IF-14)**  
* **FR-3** — When the user has plans, schedule, or history data, the system shall display the user's today's scheduled workout, if any. **(UC-SCR06-03, SRS-FR-15)**  
* **FR-4** — The system shall provide quick links to Plans, Schedule, History, Progress, and Stats from the populated Home Dashboard. **(UC-SCR06-03, SRS-FR-24)**  
* **FR-5** — When dashboard data fails to load, the system shall display an error state with a retry action while keeping the navigation shell usable. **(UC-SCR06-04, SDS-ERR-5)**  
* **FR-6** — When connectivity is lost while the user is on Home, the system shall display a persistent offline banner. **(UC-SCR06-05, BR-NFR-020)**  
* **FR-7** — When the Home Dashboard is offline, data-dependent widgets shall show a stale/unavailable state rather than silently appearing blank. **(UC-SCR06-05, BR-NFR-020)**

# **5\. Non-Functional Requirements**

* **NFR-1** — Dashboard summary data shall provide a skeleton/placeholder state while the data is being fetched. **(UC-SCR06-02, SDS-IF-14)**  
* **NFR-2** — When dashboard data cannot be loaded, the navigation shell shall remain usable so that the user can continue navigating authenticated areas. **(UC-SCR06-04, SDS-ERR-5)**  
* **NFR-3** — When connectivity is lost on Home, the application shall provide a persistent indication of the offline condition rather than silently presenting unavailable data as empty data. **(UC-SCR06-05, BR-NFR-020, SDS-COMP-13)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-06 shall be accessible only to an authenticated user. **(Screen Auth Requirement: Required; SRS-FR-3, SRS-FR-6)**  
* **SEC-2** — Dashboard information shall be presented within the authenticated user's application context. **(UC-SCR06-03, SRS-FR-15, SRS-FR-24)**  
* **SEC-3** — No additional security or privacy behavior is specified by the SCR-06 UC rows beyond the authenticated access requirement. **(Screen Auth Requirement: Required)**

# **7\. UI / Component Specifications**

### **Dashboard Summary Area**

* **Component type:** Dashboard summary cards/widgets  
* **Input type:** System-provided dashboard data  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required when dashboard data is available.

### **Today's Scheduled Workout**

* **Component type:** Scheduled workout display/action  
* **Input type:** System-provided schedule data  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed if there is a scheduled workout for today.

### **Plans Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Schedule Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **History Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Progress Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Stats Navigation**

* **Component type:** Quick link/navigation action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the populated dashboard.

### **Empty State**

* **Component type:** Onboarding-style empty state  
* **Input type:** User action through **"Create your first workout plan"**  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when no plans, schedule, or history exist.

### **Loading State**

* **Component type:** Skeleton/placeholder cards  
* **Input type:** System state  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed while dashboard summary data is being fetched.

### **Error State**

* **Component type:** Error state  
* **Input type:** System state  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when dashboard data fails to load.

### **Retry Action**

* **Component type:** Retry action  
* **Input type:** User action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Available in the dashboard error state.

### **Offline Banner**

* **Component type:** Persistent offline banner  
* **Input type:** System connectivity state  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when connectivity is lost while on Home.

# **8\. Acceptance Criteria**

### **AC-1 — New Account / Empty Dashboard**

**Given** the authenticated user has no plans, schedule, or history  
**When** the Home Dashboard is displayed  
**Then** the system shall show an onboarding-style empty state  
**And** the empty state shall prompt **"Create your first workout plan"**.  
**(UC-SCR06-01)**

### **AC-2 — Dashboard Loading**

**Given** dashboard summary data is being fetched  
**When** the Home Dashboard is loading  
**Then** the system shall display skeleton/placeholder cards.  
**(UC-SCR06-02)**

### **AC-3 — Populated Dashboard**

**Given** the authenticated user has plans, schedule, or history  
**When** dashboard data has loaded  
**Then** the Home Dashboard shall display today's scheduled workout, if any  
**And** provide quick links to Plans, Schedule, History, Progress, and Stats.  
**(UC-SCR06-03)**

### **AC-4 — Dashboard Data Failure**

**Given** the dashboard summary data cannot be loaded  
**When** the failure occurs  
**Then** the system shall display an error state  
**And** provide a retry action  
**And** keep the navigation shell usable.  
**(UC-SCR06-04)**

### **AC-5 — Offline Home Dashboard**

**Given** the user is on the Home Dashboard  
**When** connectivity is lost  
**Then** the system shall display a persistent offline banner  
**And** data-dependent widgets shall show a stale/unavailable state rather than silently appearing blank.  
**(UC-SCR06-05)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Dashboard Data Load Failure**

**Given** the user is authenticated and on SCR-06  
**When** dashboard data fails to load  
**Then** the system shall show the defined error state with retry  
**And** the navigation shell shall remain usable.  
**(UC-SCR06-04)**

### **EC-2 — Connectivity Lost on Home**

**Given** the user is viewing the Home Dashboard  
**When** connectivity is lost  
**Then** the system shall show the persistent offline banner  
**And** data-dependent widgets shall indicate stale/unavailable data rather than silently appearing blank.  
**(UC-SCR06-05)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-01 — Splash / Auth Check  
  * SCR-02 — Registration, after successful registration  
  * SCR-03 — Login, after successful authentication  
* **Screen exit dependencies:**  
  * Plans → workout plan management screens.  
  * Schedule → scheduling screens.  
  * History → workout history screens.  
  * Progress → SCR-22.  
  * Stats → SCR-23.  
* **\[ASSUMPTION\] flag:** None specified for SCR-06.  
* **Underspecified behavior requiring confirmation:**  
  * Exact dashboard summary cards/widgets beyond today's scheduled workout and the specified quick links are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact stale/unavailable presentation for data-dependent widgets is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact error-state copy is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact behavior of the **"Create your first workout plan"** CTA after selection is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The Inventory does not specify whether each quick link is presented as a card, button, tab, or another visual component; therefore the specific presentation should not be inferred.  
* **Full-chain traceability summary:**

| Traceability Chain | User Story Coverage |
| ----- | ----- |
| **SRS-FR-9 → UC-SCR06-01** | FR-1, AC-1 |
| **SDS-IF-14 → UC-SCR06-02** | FR-2, NFR-1, AC-2 |
| **SRS-FR-15 → UC-SCR06-03** | FR-3, FR-4, AC-3 |
| **SRS-FR-24 → UC-SCR06-03** | FR-4, AC-3 |
| **SDS-ERR-5 → UC-SCR06-04** | FR-5, NFR-2, AC-4, EC-1 |
| **BR-NFR-020 → UC-SCR06-05** | FR-6, FR-7, NFR-3, AC-5, EC-2 |
| **SDS-COMP-13 → UC-SCR06-05** | FR-7, NFR-3, AC-5, EC-2 |

*   
  **BRD → SRS → SDS → Inventory → User Story:**  
  **BRD-FR/NFR-003/020 → SRS-FR-9, SRS-FR-15, SRS-FR-24 / BR-NFR-020 → SDS-IF-14, SDS-ERR-5, SDS-COMP-13 → UC-SCR06-01 through UC-SCR06-05 → US-SCR-06.**

# **\#Forge-US-7**

# **1\. User Story Identification**

* **Story ID:** US-SCR-07  
* **Title:** Browse and Select Exercises  
* **Epic / Feature:** Exercise Catalogue  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

**As an authenticated user, I want to browse and search the exercise catalogue so that I can find and select a valid exercise for viewing or adding to a workout plan.**

# **3\. Description / Context**

SCR-07 provides access to the shared exercise catalogue. The screen supports both standalone browse mode and picker mode when accessed from SCR-09 — Create / Edit Workout Plan.

The catalogue is read-only reference data. In picker mode, selecting a valid exercise adds that exercise to the in-progress workout plan on SCR-09.

The screen must also handle loading, empty search results, invalid exercise references, catalogue-loading failures, and lack of connectivity as defined by the Inventory.

# **4\. Functional Requirements**

* **FR-1** — The system shall display the exercise catalogue as a list/grid when the catalogue has successfully loaded. **(UC-SCR07-02, SRS-FR-7)**  
* **FR-2** — The system shall allow the authenticated user to search the exercise catalogue. **(UC-SCR07-02, SRS-FR-7)**  
* **FR-3** — The system shall support filtering/searching such that when the search or filter produces no matching exercises, the screen displays the specified empty state. **(UC-SCR07-03, SRS-FR-8)**  
* **FR-4** — In picker mode, the system shall allow the user to select a valid exercise from the catalogue and add it to the in-progress workout plan on SCR-09. **(UC-SCR07-04, SRS-FR-8)**  
* **FR-5** — The system shall reject an exercise reference that is not present in the catalogue and shall prevent that exercise from being added to the workout plan. **(UC-SCR07-05, SRS-FR-48)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The exercise catalogue shall require authenticated access; unauthenticated users shall not be permitted to access the protected catalogue functionality. **(UC-SCR07-02, SRS-FR-7)**  
* **NFR-2** — When catalogue data cannot be retrieved because there is no connectivity, the system shall present the defined offline state and shall not rely on locally cached catalogue data. **(UC-SCR07-07, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the exercise catalogue shall require an authenticated user session. **(UC-SCR07-02, SRS-FR-7)**  
* **SEC-2** — An exercise reference that is not present in the valid catalogue shall be rejected before it can be added to a workout plan. **(UC-SCR07-05, SRS-FR-48)**

# **7\. UI / Component Specifications**

### **Exercise Catalogue**

* **Component type:** Searchable/filterable exercise list/grid.  
* **Input type:** Search/filter input.  
* **Validation rules:** Search/filter shall operate against the available exercise catalogue.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for invalid search/filter input.  
* **Mandatory / Optional:** Search/filter is optional; the catalogue itself is the primary content.

### **Exercise Item / Selection**

* **Component type:** Exercise list/grid item.  
* **Input type:** Selection action.  
* **Validation rules:** Only exercises present in the catalogue may be selected for addition in picker mode.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for rejected invalid exercise references.  
* **Mandatory / Optional:** Exercise selection is applicable only in picker mode.

### **Loading State**

* **Component type:** Skeleton list.  
* **Input type:** None.  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Required while catalogue data is being fetched.

### **Empty State**

* **Component type:** Empty-state message.  
* **Input type:** None.  
* **Validation rules:** Displayed when search/filter produces no results.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error message:** **"No exercises match your search"**  
* **Mandatory / Optional:** Required for the no-results condition.

### **Error State**

* **Component type:** Error state with retry action.  
* **Input type:** Retry action.  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required when catalogue loading fails.

### **Offline State**

* **Component type:** Offline state.  
* **Input type:** None specified.  
* **Validation rules:** Catalogue is not cached locally.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error message:** Not specified in Inventory.  
* **Mandatory / Optional:** Required when there is no connectivity.

# **8\. Acceptance Criteria**

### **AC-1 — Catalogue Loading**

**UC-SCR07-01**

**Given** the authenticated user opens SCR-07 and the exercise catalogue is being fetched,  
**When** the catalogue data has not yet been resolved,  
**Then** the system shall display the skeleton list and shall not display the catalogue as populated.

### **AC-2 — Catalogue Populated**

**UC-SCR07-02**

**Given** the authenticated user opens SCR-07 and the exercise catalogue has loaded,  
**When** the catalogue is available,  
**Then** the system shall display a list/grid of exercises and allow the catalogue to be searched.

### **AC-3 — No Search Results**

**UC-SCR07-03**

**Given** the exercise catalogue is displayed,  
**When** the user's search/filter produces no matching exercises,  
**Then** the system shall display **"No exercises match your search"**.

### **AC-4 — Select Exercise in Picker Mode**

**UC-SCR07-04**

**Given** SCR-07 has been opened in picker mode from SCR-09 and a valid exercise is present in the catalogue,  
**When** the user selects that exercise,  
**Then** the exercise shall be added to the in-progress workout plan on SCR-09.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Invalid Exercise Reference**

**UC-SCR07-05**

**Given** an exercise reference is attempted that is not present in the exercise catalogue,  
**When** the system validates the exercise reference,  
**Then** the selection shall be rejected and the exercise shall not be added to the workout plan.

### **EC-2 — Catalogue Load Failure**

**UC-SCR07-06**

**Given** the user attempts to access the exercise catalogue,  
**When** catalogue loading fails,  
**Then** the system shall display an error state with a retry action.

### **EC-3 — No Connectivity**

**UC-SCR07-07**

**Given** the user attempts to access the exercise catalogue,  
**When** there is no connectivity,  
**Then** the system shall display the defined offline state and shall not use locally cached catalogue data.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-06 — Home Dashboard, when accessed in standalone browse mode.  
  * SCR-09 — Create / Edit Workout Plan, when accessed in picker mode.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan, after selecting an exercise in picker mode.  
  * Back navigation in browse mode.  
* **\[ASSUMPTION\] flag:** None specified for SCR-07.  
* **Underspecified behavior:**  
  * Inventory does not specify the exact search/filter mechanism, search matching rules, filtering criteria, or minimum/maximum search input constraints.  
  * Inventory does not specify the exact error message for UC-SCR07-05 invalid exercise reference.  
  * Inventory does not specify the exact error message for UC-SCR07-06 catalogue-load failure.  
  * Inventory does not specify the exact offline-state presentation/message for UC-SCR07-07.  
  * These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-7 → SDS-DATA-3 / SDS-IF-14 → UC-SCR07-01 / UC-SCR07-02 → FR-1, FR-2, NFR-1, AC-1, AC-2**  
  * **SRS-FR-8 → SDS-COMP-4 / SDS-IF-14 / SDS-DATA-3 → UC-SCR07-03 / UC-SCR07-04 → FR-3, FR-4, AC-3, AC-4**  
  * **SRS-FR-48 → SDS-COMP-12 / SDS-DATA-8 → UC-SCR07-05 → FR-5, SEC-2, EC-1**  
  * **BR-NFR-020 → Appendix C (SDS) → UC-SCR07-07 → NFR-2, EC-3**  
  * **SDS-ERR-5 → UC-SCR07-06 → EC-2**

# **\#Forge-US-8**

# **1\. User Story Identification**

* **Story ID:** US-SCR08  
* **Title:** Workout Plans List  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As an authenticated user, I want to view my workout plans in a dedicated list so that I can see the plans I have created and access them for further actions.

# **3\. Description / Context**

SCR-08 is the entry screen for Workout Plan Management from the Plans tab. The screen displays the user's workout plans after they are retrieved.

The screen supports:

* Loading while plans are being fetched.  
* An empty state when no plans exist.  
* A populated list when one or more plans exist.  
* Navigation to create/edit a workout plan.  
* Navigation to view an existing workout plan.  
* Recoverable error handling when plans cannot be loaded.  
* An offline state when connectivity is unavailable.

The screen requires authentication.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading/skeleton state while workout plans are being fetched. **(UC-SCR08-01, SDS-IF-14)**  
* **FR-2** — When no workout plans have been created, the system shall display an empty state with a **"Create a workout plan"** call to action. **(UC-SCR08-02, BR-FR-003)**  
* **FR-3** — When one or more workout plans exist, the system shall display the user's workout plans as a list containing the plan name and a summary such as exercise count. **(UC-SCR08-03, SRS-FR-9, SDS-DATA-4)**  
* **FR-4** — The user shall be able to access the create/edit workout plan flow from the Workout Plans List. **(UC-SCR08-02, SRS-FR-9–SRS-FR-14)**  
* **FR-5** — The user shall be able to select an existing workout plan from the list to access its plan detail. **(UC-SCR08-03, SRS-FR-9–SRS-FR-14)**  
* **FR-6** — If workout plans fail to load, the system shall display an error state with an available retry action. **(UC-SCR08-04, SDS-ERR-5)**  
* **FR-7** — If there is no connectivity while accessing the Workout Plans List, the system shall display the defined offline state. **(UC-SCR08-05, BR-NFR-020)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Workout Plans List shall provide a loading/skeleton state while plan data is being retrieved so that the user is not presented with an undefined loading condition. **(UC-SCR08-01, SDS-IF-14)**  
* **NFR-2** — When plan retrieval fails, the system shall provide a recoverable error state with retry rather than representing the plan data as successfully loaded. **(UC-SCR08-04, SDS-ERR-5)**  
* **NFR-3** — When connectivity is unavailable, the screen shall present the defined offline state rather than silently presenting the absence of plans as an empty state. **(UC-SCR08-05, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Workout Plans List shall require an authenticated user session. **(UC-SCR08-03, SRS-FR-9–SRS-FR-14)**  
* **SR-2** — The populated plan list shall represent workout plans belonging to the authenticated user's account. **(UC-SCR08-03, SRS-FR-9, SDS-DATA-4)**

# **7\. UI / Component Specifications**

### **Workout Plans List**

* **Component type:** Screen/list  
* **Input type:** No direct user data input specified.  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory for the general load failure.  
* **Mandatory / Optional:** Screen requires authentication.

### **Loading State**

* **Component type:** Skeleton list  
* **Input type:** None  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Required loading state.

### **Empty State**

* **Component type:** Empty state  
* **Input type:** None  
* **Action:** **"Create a workout plan"**  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when no plans exist.

### **Populated Plan List**

* **Component type:** Workout plan list  
* **Input type:** Selectable plan entries  
* **Displayed information:** Plan name and summary such as exercise count  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when one or more plans exist.

### **Error State**

* **Component type:** Error state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when plan loading fails.

### **Offline State**

* **Component type:** Offline state  
* **Input type:** Not specified in Inventory.  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when there is no connectivity.

# **8\. Acceptance Criteria**

### **AC-1 — Loading State**

**Given** the user opens the Workout Plans List and plans are being fetched,  
**When** the plan data has not yet been received,  
**Then** the system shall display the skeleton list state.  
**(UC-SCR08-01)**

### **AC-2 — Empty Workout Plans**

**Given** the authenticated user has no workout plans,  
**When** the Workout Plans List is displayed,  
**Then** the system shall display the empty state with a **"Create a workout plan"** call to action.  
**(UC-SCR08-02)**

### **AC-3 — Populated Workout Plans**

**Given** the authenticated user has one or more workout plans,  
**When** the plan data is successfully loaded,  
**Then** the system shall display a list of named workout plans with a summary such as exercise count.  
**(UC-SCR08-03)**

### **AC-4 — Plan Access**

**Given** the Workout Plans List contains existing plans,  
**When** the user selects a workout plan,  
**Then** the system shall provide access to the corresponding plan detail.  
**(UC-SCR08-03)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Plan Load Failure**

**Given** the Workout Plans List is being loaded,  
**When** the plans fail to load,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR08-04)**

### **EC-2 — No Connectivity**

**Given** the user accesses the Workout Plans List,  
**When** there is no connectivity,  
**Then** the system shall display the defined offline state.  
**(UC-SCR08-05)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-06 — Home Dashboard / Plans tab.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan.  
  * SCR-10 — Plan Detail.  
* **\[ASSUMPTION\] flag:**  
  Not specified for SCR-08.  
* **Underspecified behavior:**  
  * The Inventory specifies that the empty state contains a **"Create a workout plan"** CTA but does not explicitly define the exact navigation behavior of that CTA. Confirm with SRS/SDS owner.  
  * The Inventory specifies a retry action for the error state but does not define its exact UI presentation or error copy. Confirm with SRS/SDS owner.  
  * The Inventory specifies a plan summary "such as exercise count" but does not establish the complete set of summary fields. Confirm with SRS/SDS owner.  
  * The Inventory does not explicitly define the behavior when a user selects an individual plan from the populated list beyond the screen's exit point to SCR-10. Confirm with SRS/SDS owner.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| BR-FR-003 | — | — | UC-SCR08-02 | FR-2, AC-2 |
| BR-FR-003 / relevant BRD trace via SRS | SRS-FR-9–14 | SDS-COMP-5, SDS-DATA-4 | UC-SCR08-03 | FR-3, FR-5, SR-2, AC-3, AC-4 |
| Not directly specified in UC row | — | SDS-IF-14 | UC-SCR08-01 | FR-1, NFR-1, AC-1 |
| Not directly specified in UC row | — | SDS-ERR-5 | UC-SCR08-04 | FR-6, NFR-2, EC-1 |
| BR-NFR-020 | — | — | UC-SCR08-05 | FR-7, NFR-3, EC-2 |

# **\#Forge-US-9**

# **1\. User Story Identification**

* **Story ID:** US-SCR09  
* **Title:** Create / Edit Workout Plan  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 8

# **2\. User Story Statement**

As an authenticated user, I want to create or edit a workout plan by defining its name, exercises, and exercise targets so that I can maintain a workout plan for future workouts.

# **3\. Description / Context**

SCR-09 is the Create / Edit Workout Plan screen within the Workout Plan Management flow.

The screen supports two modes:

* **Create mode:** A new workout plan starts with a blank name and empty exercise list.  
* **Edit mode:** An existing workout plan is loaded with its current data pre-filled.

The user can define the plan name, add exercises through SCR-07, and configure per-exercise target sets, reps, weight, duration, and rest.

The screen also handles validation, save processing, save failures, offline conditions, and attempts to leave with unsaved changes.

The screen requires an authenticated user session.

# **4\. Functional Requirements**

* **FR-1** — In create mode, the system shall display a blank plan name field, an empty exercise list, and an **"Add exercise"** action. **(UC-SCR09-01, SRS-FR-9)**  
* **FR-2** — In edit mode, the system shall pre-fill the workout plan fields with the existing plan data. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4)**  
* **FR-3** — The user shall be able to add exercises to the in-progress workout plan through the Exercise Catalogue. **(UC-SCR09-01, SRS-FR-9)**  
* **FR-4** — The workout plan shall support per-exercise target sets, reps, weight, duration, and rest as defined by the screen content. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4)**  
* **FR-5** — The system shall block saving when the plan name is blank or contains only whitespace and shall display an inline validation error. **(UC-SCR09-03, SRS-FR-10, SDS-DATA-8)**  
* **FR-6** — The system shall reject an invalid exercise reference and prevent the workout plan from being saved with that invalid reference. **(UC-SCR09-04, SRS-FR-48, SDS-DATA-8)**  
* **FR-7** — The system shall prevent a set or rep value from being saved when a required value is non-positive and shall display an inline field error. **(UC-SCR09-05, SRS-FR-49, SDS-ERR-7)**  
* **FR-8** — The system shall prevent a negative weight value from being saved and shall display an inline field error. **(UC-SCR09-06, SRS-FR-50, SDS-ERR-7)**  
* **FR-9** — The system shall prevent a negative duration value from being saved and shall display an inline field error. **(UC-SCR09-07, SRS-FR-51, SDS-ERR-7)**  
* **FR-10** — When a valid workout plan is saved successfully, the system shall route the user to SCR-10 with the updated plan data. **(UC-SCR09-09, SRS-FR-9, SRS-FR-13, SDS-COMP-5)**

# **5\. Non-Functional Requirements**

* **NFR-1** — While a workout plan save operation is in progress, the save action shall display a loading state. **(UC-SCR09-08, SDS-IF-4; SRS-NFR not specified in Inventory)**  
* **NFR-2** — If the workout plan cannot be saved because the underlying write operation fails, the system shall not represent the plan as successfully saved and shall provide a retry path. **(UC-SCR09-10, SDS-ERR-6; SRS-NFR not specified in Inventory)**  
* **NFR-3** — When connectivity is unavailable during save, the system shall preserve the in-progress edits in memory for the current attempt rather than silently discarding them. **(UC-SCR09-11, BR-NFR-020, SDS-ERR-6; SDS-NFR not specified in Inventory)**  
* **NFR-4** — When the user attempts to leave the screen with unsaved changes, the system shall require explicit confirmation before discarding those changes. **(UC-SCR09-12, BR-NFR-015; SRS-NFR/SDS-NFR not specified in Inventory)**

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Create / Edit Workout Plan screen shall require an authenticated user session. **(UC-SCR09-01, UC-SCR09-02, SRS-FR-9, SRS-FR-13)**  
* **SR-2** — Workout plan data displayed in edit mode shall correspond to the workout plan being edited by the authenticated user. **(UC-SCR09-02, SRS-FR-13, SDS-DATA-4)**  
* **SR-3** — Invalid exercise references shall not be accepted as valid workout-plan data. **(UC-SCR09-04, SRS-FR-48, SDS-DATA-8)**

# **7\. UI / Component Specifications**

### **Plan Name Field**

* **Component type:** Text field  
* **Input type:** Text  
* **Validation rules:** Cannot be blank or whitespace-only when saving  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required for successful save

### **Exercise List**

* **Component type:** Exercise list  
* **Input type:** Selected exercises  
* **Validation rules:** Exercise references must be valid  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory for invalid exercise reference  
* **Mandatory / Optional:** Not explicitly specified in Inventory

### **Add Exercise Action**

* **Component type:** Action  
* **Input type:** User selection/tap  
* **Validation rules:** Selected exercise must be valid  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Available in create mode

### **Per-Exercise Target Fields**

* **Component type:** Target input fields  
* **Input type:** Numeric values for sets, reps, weight, duration, and rest  
* **Validation rules:**  
  * Required sets/reps must be positive.  
  * Weight must not be negative.  
  * Duration must not be negative.  
* **Min / Max constraints:** Exact numerical maximums are not specified in Inventory  
* **Error messages:** Inline field error; exact error copy not specified in Inventory  
* **Mandatory / Optional:** Sets/reps are required where applicable; other field requirements are not fully specified in Inventory

### **Save Action**

* **Component type:** Save action  
* **Input type:** User action  
* **Validation rules:** Save is blocked when defined validation conditions fail  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required action for persisting create/edit changes

### **Loading State**

* **Component type:** Loading state  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Displayed during save

### **Error State**

* **Component type:** Error state  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Displayed when save fails

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** **"You're offline"** state  
* **Mandatory / Optional:** Displayed when there is no connectivity at save

### **Discard Changes Confirmation**

* **Component type:** Confirmation  
* **Input type:** Confirmation/cancel action  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Required when leaving with unsaved changes

# **8\. Acceptance Criteria**

### **AC-1 — Create Mode**

**Given** the user opens SCR-09 in create mode,  
**When** the screen is displayed,  
**Then** the system shall show a blank plan name field, an empty exercise list, and an **"Add exercise"** action.  
**(UC-SCR09-01)**

### **AC-2 — Edit Mode**

**Given** the user opens SCR-09 in edit mode for an existing plan,  
**When** the existing plan data is loaded,  
**Then** the system shall pre-fill the fields with the current plan data.  
**(UC-SCR09-02)**

### **AC-3 — Save Workout Plan**

**Given** the workout plan contains valid required information,  
**When** the user submits the save action,  
**Then** the system shall save the plan and route the user to SCR-10 with the updated data.  
**(UC-SCR09-09)**

### **AC-4 — Leave With Unsaved Changes**

**Given** the user has unsaved changes on SCR-09,  
**When** the user attempts to leave the screen,  
**Then** the system shall display a discard-changes confirmation.  
**(UC-SCR09-12)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Blank or Whitespace-Only Plan Name**

**Given** the user is saving a workout plan,  
**When** the plan name is blank or contains only whitespace,  
**Then** the system shall display an inline validation error and block the save.  
**(UC-SCR09-03)**

### **EC-2 — Invalid Exercise Reference**

**Given** the workout plan contains an exercise reference that is invalid or unavailable,  
**When** the user attempts to save the plan,  
**Then** the invalid item shall be flagged/rejected and the plan shall not be saved.  
**(UC-SCR09-04)**

### **EC-3 — Non-Positive Sets/Reps**

**Given** the user enters a sets or reps value where a required value is expected,  
**When** the entered value is non-positive,  
**Then** the system shall display an inline field error and prevent the invalid value from being used to complete the plan.  
**(UC-SCR09-05)**

### **EC-4 — Negative Weight**

**Given** the user enters a weight value,  
**When** the value is negative,  
**Then** the system shall display an inline field error.  
**(UC-SCR09-06)**

### **EC-5 — Negative Duration**

**Given** the user enters a duration value,  
**When** the value is negative,  
**Then** the system shall display an inline field error.  
**(UC-SCR09-07)**

### **EC-6 — Save Loading State**

**Given** the user has submitted a valid workout plan for saving,  
**When** the save operation is in progress,  
**Then** the save action shall show its loading state.  
**(UC-SCR09-08)**

### **EC-7 — Save Failure**

**Given** the user has submitted a workout plan for saving,  
**When** the save operation fails,  
**Then** the system shall display an error state, shall not represent the plan as saved, and shall provide a retry action without creating a duplicate record.  
**(UC-SCR09-10)**

### **EC-8 — Offline During Save**

**Given** the user has entered or modified workout plan information,  
**When** there is no connectivity at save,  
**Then** the system shall display the **"You're offline"** state and preserve the in-progress edits in memory for the retry attempt.  
**(UC-SCR09-11)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-08 — Workout Plans List.  
  * SCR-10 — Plan Detail.  
* **Screen exit dependencies:**  
  * SCR-10 — Plan Detail on successful save.  
  * SCR-08 — Workout Plans List on cancel/back.  
  * SCR-07 — Exercise Catalogue for adding exercises.  
* **\[ASSUMPTION\] flag:**  
  None specified for SCR-09.  
* **Underspecified behavior:**  
  * Exact maximum constraints for plan name, sets, reps, weight, duration, and rest are not specified in the Inventory — confirm with SRS/SDS owner.  
  * Exact inline validation error messages are not specified for the plan name, invalid exercise, sets/reps, weight, or duration — confirm with SRS/SDS owner.  
  * The Inventory does not explicitly define whether an exercise list must contain at least one exercise before a plan can be saved — confirm with SRS/SDS owner.  
  * The exact behavior of the discard-changes confirmation's confirm and cancel actions is not fully specified beyond requiring confirmation — confirm with SRS/SDS owner.  
  * The Inventory specifies save loading behavior but does not provide an underlying SRS-NFR/SDS-NFR ID for this state; the cited design trace is SDS-IF-4.  
  * The Inventory specifies offline edit preservation **in memory only**; this does not constitute persistent offline support.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| BR-FR-003 / relevant BRD trace | SRS-FR-9 | SDS-COMP-5, SDS-IF-4, SDS-DATA-4 | UC-SCR09-01 | FR-1, FR-3, AC-1 |
| Relevant BRD trace | SRS-FR-13 | SDS-DATA-4 | UC-SCR09-02 | FR-2, FR-4, SR-2, AC-2 |
| Relevant BRD trace | SRS-FR-10 | SDS-DATA-8 | UC-SCR09-03 | FR-5, EC-1 |
| Relevant BRD trace | SRS-FR-48 | SDS-DATA-8 | UC-SCR09-04 | FR-6, SR-3, EC-2 |
| BR-FR-043 / relevant BRD trace | SRS-FR-49 | SDS-ERR-7 | UC-SCR09-05 | FR-7, EC-3 |
| BR-FR-044 / relevant BRD trace | SRS-FR-50 | SDS-ERR-7 | UC-SCR09-06 | FR-8, EC-4 |
| BR-FR-045 / relevant BRD trace | SRS-FR-51 | SDS-ERR-7 | UC-SCR09-07 | FR-9, EC-5 |
| Not specified in Inventory | — | SDS-IF-4 | UC-SCR09-08 | NFR-1, EC-6 |
| Relevant BRD trace | SRS-FR-9, SRS-FR-13 | SDS-COMP-5 | UC-SCR09-09 | FR-10, AC-3 |
| Not specified in Inventory | — | SDS-ERR-6 | UC-SCR09-10 | NFR-2, EC-7 |
| BR-NFR-020 | — | SDS-ERR-6 | UC-SCR09-11 | NFR-3, EC-8 |
| BR-NFR-015 | — | — | UC-SCR09-12 | NFR-4, AC-4 |

# **\#Forge-US-10**

# **1\. User Story Identification**

* **Story ID:** US-SCR10  
* **Title:** Plan Detail  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 5

# **2\. User Story Statement**

As an authenticated user, I want to view the details of a workout plan so that I can review its exercises and targets and access actions to edit, delete, start, or schedule the plan.

# **3\. Description / Context**

SCR-10 is the Plan Detail screen within the Workout Plan Management flow.

The screen is accessed from the Workout Plans List or after successfully saving a workout plan. It presents the selected workout plan and its configured exercise targets.

When the plan is successfully loaded, the user can access the actions defined by the Inventory:

* Edit  
* Delete  
* Start Workout  
* Schedule

The screen also supports a loading state while the plan is being fetched, an error/not-found state when the plan cannot be loaded, and an offline state when connectivity is unavailable.

The screen requires authentication.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a skeleton state while the selected workout plan is being fetched. **(UC-SCR10-01, SDS-IF-14)**  
* **FR-2** — When the workout plan is successfully loaded, the system shall display the plan name and its exercise list with configured targets. **(UC-SCR10-02, SRS-FR-9, SDS-DATA-4)**  
* **FR-3** — When the workout plan is loaded, the system shall provide an Edit action for the plan. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-4** — When the workout plan is loaded, the system shall provide a Delete action for the plan. **(UC-SCR10-02, SRS-FR-14)**  
* **FR-5** — When the workout plan is loaded, the system shall provide a Start Workout action. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-6** — When the workout plan is loaded, the system shall provide a Schedule action. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **FR-7** — If the selected workout plan cannot be loaded, including when the plan has been deleted elsewhere, the system shall display an error/not-found state with a back action. **(UC-SCR10-03, SDS-ERR-5)**  
* **FR-8** — If there is no connectivity while accessing the Plan Detail screen, the system shall display the defined offline state. **(UC-SCR10-04, BR-NFR-020)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Plan Detail screen shall provide a skeleton state while plan data is being retrieved. **(UC-SCR10-01, SDS-IF-14; SRS-NFR not specified in Inventory)**  
* **NFR-2** — If plan retrieval fails, the system shall present a recoverable error/not-found state with a back action rather than displaying incomplete plan information as valid data. **(UC-SCR10-03, SDS-ERR-5; SRS-NFR not specified in Inventory)**  
* **NFR-3** — When connectivity is unavailable, the system shall display the defined offline state rather than silently presenting incomplete or missing plan information. **(UC-SCR10-04, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SR-1** — Access to the Plan Detail screen shall require an authenticated user session. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14)**  
* **SR-2** — The Plan Detail screen shall display only the workout plan data associated with the authenticated user's accessible plan. **(UC-SCR10-02, SRS-FR-9–SRS-FR-14, SDS-DATA-4)**  
* **SR-3** — If the requested plan cannot be accessed or no longer exists, the system shall not display incomplete or unauthorized plan information and shall instead provide the defined error/not-found state. **(UC-SCR10-03, SDS-ERR-5)**

# **7\. UI / Component Specifications**

### **Plan Detail**

* **Component type:** Detail screen  
* **Input type:** No direct user data input specified.  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Requires authentication.

### **Plan Information**

* **Component type:** Plan information display  
* **Input type:** Read-only  
* **Displayed information:** Plan name  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when the plan is successfully loaded.

### **Exercise List**

* **Component type:** Exercise list  
* **Input type:** Read-only plan data  
* **Displayed information:** Exercise list with configured targets  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not specified in Inventory.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed when the plan is successfully loaded.

### **Edit Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Delete Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Start Workout Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Schedule Action**

* **Component type:** Action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Available on populated plan detail.

### **Loading State**

* **Component type:** Skeleton  
* **Input type:** None  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not applicable.  
* **Mandatory / Optional:** Displayed while the plan is being fetched.

### **Error / Not-Found State**

* **Component type:** Error / not-found state  
* **Input type:** Back action  
* **Validation rules:** Not applicable.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Exact error/not-found copy not specified in Inventory.  
* **Mandatory / Optional:** Displayed when the plan fails to load or is unavailable.

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory.  
* **Min / Max constraints:** Not applicable.  
* **Error messages:** Not specified in Inventory.  
* **Mandatory / Optional:** Displayed when there is no connectivity.

# **8\. Acceptance Criteria**

### **AC-1 — Loading Plan**

**Given** the user opens the Plan Detail screen and the selected plan is being fetched,  
**When** the plan data has not yet been received,  
**Then** the system shall display the skeleton state.  
**(UC-SCR10-01)**

### **AC-2 — Display Plan Details**

**Given** the selected workout plan exists and is successfully loaded,  
**When** the Plan Detail screen is displayed,  
**Then** the system shall show the plan name and exercise list with configured targets.  
**(UC-SCR10-02)**

### **AC-3 — Available Plan Actions**

**Given** the workout plan has been successfully loaded,  
**When** the user views the Plan Detail screen,  
**Then** the screen shall provide Edit, Delete, Start Workout, and Schedule actions.  
**(UC-SCR10-02)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Plan Load Failure / Plan Not Found**

**Given** the user attempts to open a workout plan,  
**When** the plan fails to load, including because it was deleted elsewhere,  
**Then** the system shall display an error/not-found state with a back action.  
**(UC-SCR10-03)**

### **EC-2 — Offline**

**Given** the user attempts to access the Plan Detail screen,  
**When** there is no connectivity,  
**Then** the system shall display the defined offline state.  
**(UC-SCR10-04)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-08 — Workout Plans List.  
  * SCR-09 — Create / Edit Workout Plan, after successful save.  
* **Screen exit dependencies:**  
  * SCR-09 — Create / Edit Workout Plan through Edit.  
  * SCR-11 — Delete Plan Confirmation through Delete.  
  * SCR-15 — Workout Pre-Start / Overview through Start Workout.  
  * SCR-13 — Assign / Edit Schedule through Schedule.  
* **\[ASSUMPTION\] flag:**  
  None specified for SCR-10.  
* **Underspecified behavior:**  
  * The Inventory identifies Edit, Delete, Start Workout, and Schedule as available actions but does not define the exact navigation behavior of each action within the UC row. The screen's Exit Points establish the destination screens; confirm detailed interaction behavior with the SRS/SDS owner.  
  * The exact error/not-found message is not specified in the Inventory — confirm with SRS/SDS owner.  
  * The exact offline-state presentation is not specified in the Inventory — confirm with SRS/SDS owner.  
  * The Inventory does not specify the exact set of target fields displayed for each exercise beyond "targets" — confirm with SRS/SDS owner.  
* **Full-chain traceability summary:**

| BRD | SRS | SDS | Inventory UC | User Story |
| ----- | ----- | ----- | ----- | ----- |
| Relevant BRD trace | SRS-FR-9–14 | SDS-DATA-4, SDS-COMP-5 | UC-SCR10-02 | FR-2–FR-6, SR-1–SR-2, AC-2–AC-3 |
| Not specified in Inventory | — | SDS-IF-14 | UC-SCR10-01 | FR-1, NFR-1, AC-1 |
| Not specified in Inventory | — | SDS-ERR-5 | UC-SCR10-03 | FR-7, NFR-2, SR-3, EC-1 |
| BR-NFR-020 | — | — | UC-SCR10-04 | FR-8, NFR-3, EC-2 |

# **\#Forge-US-11**

## **1\. User Story Identification**

* **Story ID:** US-SCR11  
* **Title:** Delete Workout Plan Confirmation  
* **Epic / Feature:** Workout Plan Management  
* **Priority:** High  
* **Story Points:** 2

## **2\. User Story Statement**

As an authenticated user, I want to confirm the deletion of a workout plan so that I can intentionally remove the plan and its schedule assignments while preserving historical workout sessions associated with that plan.

## **3\. Description / Context**

SCR-11 is the confirmation step reached from SCR-10 when the user chooses to delete a workout plan.

The screen provides an explicit confirmation before deletion. On confirmation, the plan and its schedule assignments are removed, while historical workout sessions using the plan remain unaffected.

The screen is available only to authenticated users.

## **4\. Functional Requirements**

* **FR-1** — The system shall present a confirmation modal when the user initiates deletion of a workout plan, explaining that the plan and its schedule assignments will be removed and that historical workout sessions using the plan are unaffected. **(UC-SCR11-01, SRS-FR-14)**  
* **FR-2** — The system shall provide a loading state on the confirmation action while the deletion request is being processed. **(UC-SCR11-02, SRS-FR-14 — underlying SRS requirement not explicitly specified for this loading behavior; SDS-IF-4 defines the action flow)**  
* **FR-3** — When deletion succeeds, the system shall remove the workout plan from the user's plan list and route the user to SCR-08. **(UC-SCR11-03, SRS-FR-14)**  
* **FR-4** — The deletion operation shall not remove or alter historical workout sessions that used the deleted workout plan. **(UC-SCR11-01, SRS-FR-14)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The deletion action shall provide a loading state while the operation is in progress so that the user is given clear feedback that the action is being processed. **(UC-SCR11-02, SRS-FR-14; SDS-IF-4)**  
* **NFR-2** — The screen shall require an authenticated user. **(UC-SCR11-01, SRS-FR-14)**  
* **NFR-3** — No specific measurable non-functional requirement beyond the above is specified in the Inventory for SCR-11. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the workout plan deletion flow shall be restricted to authenticated users. **(UC-SCR11-01, SRS-FR-14)**  
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

**Given** the user is authenticated and is viewing a workout plan on SCR-10  
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

### **EC-2 — No Connectivity**

**(UC-SCR11-05)**

**Given** the user attempts to delete a workout plan  
**When** there is no connectivity  
**Then** the system shall display the specified `"You're offline"` state  
**And** the workout plan shall not be represented as successfully deleted.

## **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:**  
  * **Entry:** SCR-10 — Plan Detail, through the Delete action.  
  * **Exit:** SCR-08 — Workout Plans List on successful deletion.  
  * **Exit:** SCR-10 — Plan Detail when the deletion flow is cancelled, as defined by the parent screen flow.  
* **\[ASSUMPTION\] flag:** None specified for SCR-11.  
* **Underspecified behavior:**  
  * The Inventory specifies that SCR-11 shall display a confirmation modal but does not provide exact confirmation-modal copy beyond its described behavior.  
  * The Inventory specifies an error state and retry for deletion failure but does not define exact error copy.  
  * The Inventory specifies `"You're offline"` for the offline state.  
  * No additional validation rules or error messages are specified.  
* **Traceability summary:**  
  * **BRD:** BR-FR-032 (historical integrity)  
  * **→ SRS:** SRS-FR-14  
  * **→ SDS:** SDS-COMP-5, SDS-IF-4, SDS-ERR-6  
  * **→ Inventory:** UC-SCR11-01 → FR-1, FR-4, NFR-2, SEC-1, SEC-2, AC-1  
  * **→ Inventory:** UC-SCR11-02 → FR-2, NFR-1, AC-2  
  * **→ Inventory:** UC-SCR11-03 → FR-3, AC-3  
  * **→ Inventory:** UC-SCR11-04 → EC-1  
  * **→ Inventory:** UC-SCR11-05 → EC-2

# **Forge-US-12**

# **1\. User Story Identification**

* **Story ID:** US-SCR12  
* **Title:** View Weekly Workout Schedule  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As an authenticated user, I want to view my weekly workout schedule so that I can see which workout plans are scheduled for each day and start today's scheduled workout.

# **3\. Description / Context**

SCR-12 provides the authenticated user with a weekly view of their scheduled workout plans.

The screen supports loading, empty, populated, and today's scheduled-workout states. It also provides navigation to SCR-13 for assigning/editing schedules and SCR-15 for starting a scheduled workout.

The screen is available only to authenticated users.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading skeleton for the weekly schedule while schedule data is being fetched. **(UC-SCR12-01, SRS-FR-15)**  
* **FR-2** — When no plans are scheduled on any day, the system shall display an empty state per day or an overall empty state with a "Schedule a plan" call to action. **(UC-SCR12-02, SRS-FR-15)**  
* **FR-3** — When one or more plans are scheduled, the system shall display a weekly view showing which workout plan(s) are scheduled on which day(s), including recurring assignments. **(UC-SCR12-03, SRS-FR-16)**  
* **FR-4** — When a scheduled workout falls on the current day, the system shall surface a "Start" action for today's scheduled workout. **(UC-SCR12-04, SRS-FR-24)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The weekly schedule shall provide a visible loading state while schedule data is being fetched. **(UC-SCR12-01, SDS-IF-14)**  
* **NFR-2** — The screen shall require an authenticated user. **(UC-SCR12-01, SRS-FR-15)**  
* **NFR-3** — When connectivity is unavailable, the screen shall display the defined offline state rather than silently presenting the schedule as current. **(UC-SCR12-06, BR-NFR-020)**  
* **NFR-4** — No additional measurable non-functional requirement is specified for SCR-12 in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the weekly schedule shall require authentication. **(UC-SCR12-03, SRS-FR-16)**  
* **SEC-2** — The screen shall not expose schedule information when the user is not authenticated. **(UC-SCR12-03, SRS-FR-16)**  
* **SEC-3** — No SCR-12-specific security requirement is explicitly mapped to SRS-NFR-8 through SRS-NFR-12 or SDS-COMP-14 in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **7\. UI / Component Specifications**

### **Weekly Schedule View**

* **Component type:** Weekly schedule view/grid  
* **Input type:** Schedule data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required

### **Scheduled Workout Plan Entry**

* **Component type:** Scheduled workout plan entry  
* **Input type:** Scheduled plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Displayed when scheduled plans exist

### **Start Action**

* **Component type:** Action  
* **Input type:** User tap  
* **Validation rules:** Available for today's scheduled workout  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Conditional

### **Schedule a Plan CTA**

* **Component type:** Call-to-action  
* **Input type:** User tap  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Conditional; displayed in the empty state

### **Loading State**

* **Component type:** Skeleton weekly grid  
* **Input type:** Loading state  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional:** Required while schedule data is being fetched

### **Offline State**

* **Component type:** Offline state  
* **Input type:** Connectivity state  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** `"You're offline"` state  
* **Mandatory / Optional:** Required when there is no connectivity

# **8\. Acceptance Criteria**

### **AC-1 — Schedule Loading**

**(UC-SCR12-01)**

**Given** the user is authenticated and the weekly schedule is being fetched  
**When** SCR-12 is displayed  
**Then** the system shall display a skeleton weekly grid until the schedule data is available.

### **AC-2 — Empty Weekly Schedule**

**(UC-SCR12-02)**

**Given** the user has no plans scheduled on any day  
**When** the weekly schedule is displayed  
**Then** the system shall display an empty state per day or an overall empty state with a "Schedule a plan" call to action.

### **AC-3 — Populated Weekly Schedule**

**(UC-SCR12-03)**

**Given** the user has one or more scheduled workout plans  
**When** the weekly schedule is displayed  
**Then** the system shall show which plan(s) are scheduled on which day(s)  
**And** recurring assignments shall be represented in the weekly view.

### **AC-4 — Start Today's Scheduled Workout**

**(UC-SCR12-04)**

**Given** a workout plan is scheduled for the current day  
**When** the user views SCR-12  
**Then** the system shall surface a "Start" action for today's scheduled workout  
**And** selecting the action shall proceed to SCR-15.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Schedule Load Failure**

**(UC-SCR12-05)**

**Given** the user opens SCR-12  
**When** the schedule fails to load  
**Then** the system shall display an error state with a retry action.

### **EC-2 — No Connectivity**

**(UC-SCR12-06)**

**Given** the user is viewing or attempting to load SCR-12  
**When** there is no connectivity  
**Then** the system shall display the defined offline state  
**And** the schedule shall not be represented as successfully loaded from an unavailable connection.

# **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:**  
  * **Entry:** SCR-06 — Home Dashboard, through the Schedule tab.  
  * **Exit:** SCR-13 — Assign/Edit Schedule, for adding or editing schedule assignments.  
  * **Exit:** SCR-15 — Workout Pre-Start / Overview, when starting today's scheduled workout.  
* **\[ASSUMPTION\] flag:** None specified for SCR-12.  
* **Underspecified behavior:**  
  * The Inventory allows either an empty state per day or an overall empty state when no plans are scheduled. The exact presentation should be confirmed during design.  
  * The Inventory does not specify the exact visual structure of the weekly grid.  
  * The Inventory does not specify exact error-state copy for schedule-load failure.  
  * The Inventory does not specify whether multiple plans scheduled on the same day have a display-order rule.  
  * The Inventory does not specify the exact behavior for selecting a scheduled plan other than the explicitly defined "Start" action for today's scheduled workout.  
* **Full-chain traceability summary:**  
  * **UC-SCR12-01 → FR-1, NFR-1, AC-1**  
  * **UC-SCR12-02 → FR-2, AC-2**  
  * **UC-SCR12-03 → FR-3, SEC-1, SEC-2, AC-3**  
  * **UC-SCR12-04 → FR-4, AC-4**  
  * **UC-SCR12-05 → EC-1**  
  * **UC-SCR12-06 → NFR-3, EC-2**  
  * **BRD → SRS → SDS → Inventory → User Story:** BR-FR-015 / related scheduling requirements → SRS-FR-15, SRS-FR-16, SRS-FR-24 → SDS-COMP-6, SDS-IF-5, SDS-DATA-5, SDS-ERR-5 → UC-SCR12-\* → this story.

# **\#Forge-US-13**

# **1\. User Story Identification**

* **Story ID:** US-SCR13  
* **Title:** Assign / Edit Schedule for a Workout Plan  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

As an authenticated user, I want to assign or edit a workout plan's schedule so that I can define the day(s) on which the plan should be scheduled and whether the assignment recurs.

# **3\. Description / Context**

SCR-13 allows an authenticated user to create a new schedule assignment or edit an existing schedule entry for a workout plan.

For a new assignment, no days are selected initially and saving remains unavailable until at least one valid day is chosen. When editing an existing schedule entry, the current day selection and recurrence setting are pre-filled.

The system validates that the referenced workout plan is available and that the scheduling configuration is valid before allowing the schedule to be saved.

On successful save, the user returns to SCR-12 with the updated weekly schedule, while existing workout history remains unaffected.

# **4\. Functional Requirements**

* **FR-1** — For a new schedule assignment, the system shall initially have no days selected and shall keep the save action disabled until at least one valid day is chosen. **(UC-SCR13-01, SRS-FR-15)**  
* **FR-2** — When editing an existing schedule entry, the system shall pre-fill the current day selection and recurrence setting. **(UC-SCR13-02, SRS-FR-19)**  
* **FR-3** — The system shall prevent saving when the referenced workout plan is invalid or unavailable and shall display an explanatory message. **(UC-SCR13-03, SRS-FR-21)**  
* **FR-4** — The system shall prevent saving when the scheduling configuration is invalid, including a conflicting or duplicate scheduling rule, and shall display an inline error. **(UC-SCR13-04, SRS-FR-22)**  
* **FR-5** — The system shall display a loading state when a schedule save operation is submitted. **(UC-SCR13-05, SRS-FR-15–SRS-FR-23; exact SRS mapping for loading behavior is not explicitly specified in the UC row)**  
* **FR-6** — When the schedule is successfully saved, the system shall route the user to SCR-12 with the updated weekly schedule. **(UC-SCR13-06, SRS-FR-16)**  
* **FR-7** — Saving or editing a schedule shall not alter existing workout history. **(UC-SCR13-06, SRS-FR-23)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The schedule save action shall provide a visible loading state while the save operation is being processed. **(UC-SCR13-05, SDS-IF-5)**  
* **NFR-2** — The screen shall require an authenticated user. **(UC-SCR13-01, SRS-FR-15)**  
* **NFR-3** — When connectivity is unavailable, the system shall display the defined offline state rather than representing the schedule as successfully saved. **(UC-SCR13-08, BR-NFR-020)**  
* **NFR-4** — No additional screen-specific non-functional requirement is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to schedule assignment and editing shall require authentication. **(UC-SCR13-01, SRS-FR-15)**  
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

### **Offline State**

* **Component type:** Offline state  
* **Input type:** Connectivity state  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** **"You're offline"** state  
* **Mandatory / Optional flags:** Conditional

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

### **EC-5 — No Connectivity**

**(UC-SCR13-08)**

**Given** the user is attempting to save a schedule  
**When** there is no connectivity  
**Then** the system shall display the **"You're offline"** state.

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
  * The Inventory does not specify the maximum number of selectable days.  
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

# **\#Forge-US-14**

# **US-SCR14 — Remove From Schedule Confirmation**

## **1\. User Story Identification**

* **Story ID:** US-SCR14  
* **Title:** Remove Workout Plan From Schedule  
* **Epic / Feature:** Basic Scheduling  
* **Priority:** High  
* **Story Points:** 3

## **2\. User Story Statement**

As an authenticated user, I want to remove a scheduled workout plan from a selected day or recurrence so that I can keep my weekly workout schedule up to date.

## **3\. Description / Context**

SCR-14 provides a confirmation step before removing a scheduled workout entry. The user can confirm or cancel the removal.

On confirmation, the scheduled entry is removed and the user is returned to the Weekly Schedule View (SCR-12). The removal does not alter historical workout records.

## **4\. Functional Requirements**

* **FR-1** — The system shall display a confirmation modal when the user taps Remove on a scheduled entry, identifying that the selected schedule assignment will be removed from the applicable day/recurrence. **(UC-SCR14-01, SRS-FR-20)**  
* **FR-2** — The system shall remove the selected scheduled entry when the user confirms the removal. **(UC-SCR14-03, SRS-FR-20)**  
* **FR-3** — After successful removal, the system shall route the user to SCR-12 and the removed entry shall no longer appear in the weekly schedule. **(UC-SCR14-03, SRS-FR-20)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The removal action shall provide a loading state while the removal operation is in progress. **(UC-SCR14-02, SDS-IF-5)**  
* **NFR-2** — If the removal operation fails, the system shall not represent the schedule entry as successfully removed and shall provide a retry option. **(UC-SCR14-04, SDS-ERR-6)**  
* **NFR-3** — The screen shall handle loss of connectivity by presenting the defined offline state rather than silently completing the removal. **(UC-SCR14-05, BR-NFR-020)**

## **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the schedule-removal functionality shall require an authenticated user session. **(UC-SCR14-01, SRS-FR-20)**  
* **SEC-2** — The removal operation shall apply only to the scheduled entry available to the authenticated user; no requirement in the Inventory permits access to another user's schedule. **(UC-SCR14-03, SRS-FR-20)**

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

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** `"You're offline" state`  
* **Mandatory / Optional:** Required when there is no connectivity

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

### **EC-2 — Offline During Removal**

**Given** the user attempts to remove a scheduled entry  
**When** there is no connectivity  
**Then** the system shall display the `"You're offline"` state and shall not silently complete the removal.  
**(UC-SCR14-05)**

## **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-12 — Weekly Schedule View  
  * SCR-13 — Assign / Edit Schedule for a Plan  
* **Screen exit dependency:**  
  * SCR-12 — Weekly Schedule View after successful removal.  
* **\[ASSUMPTION\] flag:** None specified for SCR-14.  
* **Underspecified behavior:**  
  * The Inventory specifies that a confirmation modal is required but does not define the exact modal title, body copy, button labels, or visual presentation.  
  * The Inventory specifies an error state and retry behavior but does not define exact error copy.  
  * The Inventory specifies `"You're offline"` but does not define the exact UI presentation or retry interaction.  
* **Full-chain traceability summary:**  
  * **BRD:** BR-FR-013 → **SRS:** SRS-FR-20 → **SDS:** SDS-COMP-6 → **UC:** UC-SCR14-01 → **FR-1 / AC-1**  
  * **BRD:** BR-FR-013 → **SRS:** SRS-FR-20 → **SDS:** SDS-COMP-6 → **UC:** UC-SCR14-03 → **FR-2 / FR-3 / AC-3**  
  * **SDS:** SDS-IF-5 → **UC:** UC-SCR14-02 → **NFR-1 / AC-2**  
  * **SDS:** SDS-ERR-6 → **UC:** UC-SCR14-04 → **NFR-2 / EC-1**  
  * **BRD:** BR-NFR-020 → **UC:** UC-SCR14-05 → **NFR-3 / EC-2**

# **\#Forge-US-15**

# **1\. User Story Identification**

* **Story ID:** US-SCR15  
* **Title:** Workout Pre-Start / Overview  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

**As an authenticated user, I want to review my selected workout plan and its targets before starting the workout, so that I can confirm what I am about to perform before entering the active workout.**

# **3\. Description / Context**

SCR-15 provides the pre-start overview for a workout initiated from a workout plan or today's scheduled workout. The screen allows the user to review the available exercise and target information before beginning the active workout.

The screen must handle plan loading, successful display of plan information, invalid or unavailable plans, system failures, and lack of connectivity according to the defined Inventory behavior.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a loading skeleton while the workout plan data is being fetched. **(UC-SCR15-01, SDS-IF-14)**  
* **FR-2** — When the workout plan is successfully loaded, the system shall display a preview of the exercises and their configured targets. **(UC-SCR15-02, SRS-FR-26, SDS-DATA-4)**  
* **FR-3** — The system shall provide a **"Begin Workout"** action when the workout plan is successfully loaded. **(UC-SCR15-02, SRS-FR-26, SDS-COMP-7)**  
* **FR-4** — The system shall prevent the workout from starting when the underlying workout plan is no longer valid or available. **(UC-SCR15-03, SRS-FR-21, SDS-COMP-12)**  
* **FR-5** — When the workout plan is successfully available for execution, the system shall allow the user to proceed to the active workout. **(UC-SCR15-02, SRS-FR-25, SDS-COMP-7)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The screen shall require connectivity to retrieve the workout plan and shall not provide an offline path for starting the workout. **(UC-SCR15-05, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the workout pre-start screen shall require an authenticated user session. **(UC-SCR15-02, SRS-FR-25)**  
* **SEC-2** — The screen shall not allow a user to proceed with a workout when the underlying plan is no longer valid or available. **(UC-SCR15-03, SRS-FR-21, SDS-COMP-12)**

# **7\. UI / Component Specifications**

### **Workout Plan Loading State**

* **Component type:** Loading skeleton  
* **Input type:** N/A  
* **Validation rules:** N/A  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory loading state

### **Workout Plan Preview**

* **Component type:** Workout plan preview  
* **Input type:** Read-only workout plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when plan data is successfully loaded

### **Exercise / Target Information**

* **Component type:** Exercise and target information  
* **Input type:** Read-only plan data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when plan data is successfully loaded

### **Begin Workout Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Workout plan must be valid and available  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Invalid / Unavailable Plan State**

* **Component type:** Blocking message/state  
* **Input type:** N/A  
* **Validation rules:** Underlying plan must be valid and available  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when the underlying plan is invalid/unavailable

# **8\. Acceptance Criteria**

### **AC-1 — Plan Loading**

**(UC-SCR15-01)**

**Given** the user opens SCR-15 and the workout plan data is being fetched,  
**When** the data has not yet been resolved,  
**Then** the screen shall display a loading skeleton.

### **AC-2 — Plan Successfully Loaded**

**(UC-SCR15-02)**

**Given** the user opens SCR-15 and the workout plan is successfully loaded,  
**When** the plan data becomes available,  
**Then** the screen shall display a preview of the exercises and their configured targets and provide the **"Begin Workout"**action.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Invalid or Unavailable Plan**

**(UC-SCR15-03)**

**Given** the user attempts to start a workout whose underlying plan is no longer valid or available,  
**When** the system detects that the plan cannot be used,  
**Then** the screen shall display a blocking state and shall prevent the workout from starting.

### **EC-2 — Plan Load Failure**

**(UC-SCR15-04)**

**Given** the user opens SCR-15,  
**When** the workout plan fails to load because of a system failure,  
**Then** the screen shall display an error state with a retry action.

### **EC-3 — No Connectivity**

**(UC-SCR15-05)**

**Given** the user opens SCR-15 without connectivity,  
**When** the workout plan cannot be retrieved,  
**Then** the screen shall display an offline state and the workout shall not begin without connectivity.

# **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * SCR-10 — Plan Detail  
  * SCR-12 — Weekly Schedule View  
* **Screen exit dependencies:**  
  * SCR-16 — Active Workout — Exercise & Set Logging  
  * Back navigation as defined by the Inventory.  
* **\[ASSUMPTION\] flag:** None specified for SCR-15.  
* **Underspecified behavior:**  
  * The exact presentation, wording, and layout of the blocking state for an invalid/unavailable plan are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The exact presentation and wording of the offline state are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The exact presentation and wording of the plan preview and target information are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The exact navigation behavior triggered by the **"Begin Workout"** action is represented by the SCR-15 exit point to SCR-16 but the Inventory does not specify additional transition behavior.  
* **Full-chain traceability summary:**  
  * **SCR-15 UC-SCR15-01** → SDS-IF-14 → **FR-1 / AC-1**  
  * **SCR-15 UC-SCR15-02** → SRS-FR-26 / SDS-DATA-4 / SDS-COMP-7 → **FR-2, FR-3, FR-5 / AC-2**  
  * **SCR-15 UC-SCR15-03** → SRS-FR-21 / SDS-COMP-12 → **FR-4 / SEC-2 / EC-1**  
  * **SCR-15 UC-SCR15-04** → SDS-ERR-5 → **EC-2**  
  * **SCR-15 UC-SCR15-05** → BR-NFR-020 / Appendix C (SDS) → **NFR-1 / EC-3**  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain; this story derives only from the five UC rows defined for **SCR-15** and introduces no additional functional scope.

# **\#Forge-US-16**

# **1\. User Story Identification**

* **Story ID:** US-SCR16  
* **Title:** Active Workout — Exercise & Set Logging  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 8

# **2\. User Story Statement**

**As an authenticated user, I want to perform a workout and record my actual exercise and set performance against the planned targets, so that my completed workout can accurately reflect what I actually performed.**

# **3\. Description / Context**

SCR-16 is the core workout execution screen. It allows the user to work through the exercises and sets defined by the selected workout plan while recording actual performance.

The screen supports active workout progression, validation of actual performance values, skipping applicable items, pausing applicable activity, cancellation, and completion. Execution state is held locally during the active session and is not persisted per action.

If connectivity is lost during the workout, local execution and logging continue, but the workout cannot be persisted as completed until connectivity is available.

# **4\. Functional Requirements**

* **FR-1** — When a workout begins, the system shall display the first exercise/set and set the execution state to **ACTIVE**. **(UC-SCR16-01, SRS-FR-25)**  
* **FR-2** — The system shall prevent a set from being marked complete when non-positive reps/sets are entered and shall display an inline validation error. **(UC-SCR16-02, SRS-FR-49)**  
* **FR-3** — The system shall display an inline validation error when a negative weight is entered. **(UC-SCR16-03, SRS-FR-50)**  
* **FR-4** — The system shall display an inline validation error when a negative duration is entered. **(UC-SCR16-04, SRS-FR-51)**  
* **FR-5** — When a set or exercise is marked complete with valid actual performance data, the system shall advance progress to the next set or exercise. **(UC-SCR16-05, SRS-FR-28)**  
* **FR-6** — When the user skips an applicable item, the system shall mark the item as skipped and exclude it appropriately from completion/valid-record logic. **(UC-SCR16-06, SRS-FR-29)**  
* **FR-7** — When the user pauses applicable activity, the system shall set the execution state to **PAUSED** and hold the timer state locally. **(UC-SCR16-07, SRS-FR-29)**  
* **FR-8** — If the user taps **Cancel**, the system shall route the user to SCR-18 for cancellation confirmation. **(UC-SCR16-10, SDS-COMP-7)**  
* **FR-9** — When the last applicable item is completed, the system shall route the user to SCR-19. **(UC-SCR16-11, SRS-FR-32)**

# **5\. Non-Functional Requirements**

* **NFR-1** — Workout execution and timer state shall continue to function using local in-memory execution state while the active workout is in progress. **(UC-SCR16-07, SRS-FR-29, SDS-COMP-7)**  
* **NFR-2** — The system shall not treat an interrupted in-progress workout as a completed historical record after the application is backgrounded, killed, or crashes. **(UC-SCR16-08, SRS-NFR-6, SDS-ERR-8)**  
* **NFR-3** — Previously completed workout sessions shall remain unaffected when an in-progress workout is interrupted. **(UC-SCR16-08, SRS-NFR-6, SDS-ERR-8)**  
* **NFR-4** — When connectivity is lost during an active workout, local execution and logging shall continue, while persistence of the completed workout shall require connectivity. **(UC-SCR16-09, BR-NFR-020, SDS-COMP-7)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the active workout screen shall require an authenticated user session. **(UC-SCR16-01, SRS-FR-25)**  
* **SEC-2** — The active workout shall operate only within the authenticated user's current workout session. **(UC-SCR16-01, SRS-FR-25, SDS-COMP-7)**

# **7\. UI / Component Specifications**

### **Current Exercise**

* **Component type:** Current exercise display  
* **Input type:** Workout plan/execution data  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Target vs. Actual Entry Fields — Reps**

* **Component type:** Numeric input field  
* **Input type:** Reps  
* **Validation rules:** Non-positive values are invalid where required  
* **Min / Max constraints:** Minimum valid value is greater than zero; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Target vs. Actual Entry Fields — Weight**

* **Component type:** Numeric input field  
* **Input type:** Weight  
* **Validation rules:** Negative values are invalid  
* **Min / Max constraints:** Negative values not permitted; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Target vs. Actual Entry Fields — Duration**

* **Component type:** Numeric input field  
* **Input type:** Duration  
* **Validation rules:** Negative values are invalid  
* **Min / Max constraints:** Negative values not permitted; maximum not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable to the exercise/set

### **Set Progress**

* **Component type:** Set progress indicator  
* **Input type:** Workout execution state  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

### **Pause Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Applicable activity must be active  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable

### **Skip Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Applicable item must be skippable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** As applicable

### **Complete Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Required performance values must be valid  
* **Min / Max constraints:** Defined by the applicable validation rules above  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory for completion of an applicable item

### **Cancel Action**

* **Component type:** Action  
* **Input type:** User interaction  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory

# **8\. Acceptance Criteria**

### **AC-1 — Workout Begins**

**(UC-SCR16-01)**

**Given** the user has successfully started a workout from SCR-15,  
**When** SCR-16 is opened,  
**Then** the system shall display the first exercise/set and set the execution state to **ACTIVE**.

### **AC-2 — Valid Set/Exercise Completion**

**(UC-SCR16-05)**

**Given** the current set/exercise contains valid actual performance data,  
**When** the user marks the set/exercise as complete,  
**Then** the system shall advance progress to the next set or exercise.

### **AC-3 — Skip Applicable Item**

**(UC-SCR16-06)**

**Given** the current item is applicable for skipping,  
**When** the user skips it,  
**Then** the system shall mark the item as skipped and exclude it appropriately from completion/valid-record logic.

### **AC-4 — Pause Activity**

**(UC-SCR16-07)**

**Given** an applicable activity is currently active,  
**When** the user pauses it,  
**Then** the execution state shall become **PAUSED** and the timer state shall be held locally.

### **AC-5 — Cancel Navigation**

**(UC-SCR16-10)**

**Given** the user is on the active workout screen,  
**When** the user taps **Cancel**,  
**Then** the system shall route the user to SCR-18.

### **AC-6 — Last Item Completed**

**(UC-SCR16-11)**

**Given** the user has reached the last applicable item in the workout,  
**When** the last item is completed,  
**Then** the system shall route the user to SCR-19.

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Non-Positive Reps/Sets**

**(UC-SCR16-02)**

**Given** the user enters a non-positive reps/sets value where required,  
**When** the user attempts to mark the set complete,  
**Then** the system shall display an inline validation error and shall not allow the set to be marked complete.

### **EC-2 — Negative Weight**

**(UC-SCR16-03)**

**Given** the user enters a negative weight,  
**When** the value is validated,  
**Then** the system shall display an inline validation error.

### **EC-3 — Negative Duration**

**(UC-SCR16-04)**

**Given** the user enters a negative duration,  
**When** the value is validated,  
**Then** the system shall display an inline validation error.

### **EC-4 — Interrupted Workout**

**(UC-SCR16-08)**

**Given** a workout is in progress,  
**When** the application is backgrounded, killed, or crashes before the workout is completed,  
**Then** the in-progress session shall not be treated as a completed historical record, and previously completed sessions shall remain unaffected.

### **EC-5 — Connectivity Lost During Workout**

**(UC-SCR16-09)**

**Given** the user is performing an active workout,  
**When** connectivity is lost,  
**Then** timer and local workout logging shall continue, but the completion/finish action shall require connectivity to persist the workout and this condition shall be surfaced clearly at finish rather than silently failing.

# **10\. Dependencies & Notes**

* **Screen entry dependency:**  
  * SCR-15 — Workout Pre-Start / Overview  
* **Screen exit dependencies:**  
  * SCR-17 — Rest Timer  
  * SCR-18 — Cancel Workout Confirmation  
  * SCR-19 — Workout Summary (Complete)  
* **\[ASSUMPTION\] flag:** None specified for SCR-16.  
* **Design note carried forward from Inventory:** Timer/execution state is held in local application memory and is not persisted per action.  
* **Underspecified behavior:**  
  * Exact inline validation error messages are **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact definition of which items are "applicable" for Skip/Pause is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact UI presentation of the execution state **ACTIVE** and **PAUSED** is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * Exact wording and UI treatment for the connectivity condition at finish are **Not specified in Inventory — confirm with SRS/SDS owner**.  
* **Full-chain traceability summary:**  
  * **UC-SCR16-01** → SRS-FR-25 / SDS-COMP-7 → **FR-1 / SEC-1, SEC-2 / AC-1**  
  * **UC-SCR16-02** → SRS-FR-49 / SDS-ERR-7 → **FR-2 / EC-1**  
  * **UC-SCR16-03** → SRS-FR-50 / SDS-ERR-7 → **FR-3 / EC-2**  
  * **UC-SCR16-04** → SRS-FR-51 / SDS-ERR-7 → **FR-4 / EC-3**  
  * **UC-SCR16-05** → SRS-FR-28 → **FR-5 / AC-2**  
  * **UC-SCR16-06** → SRS-FR-29 / SDS-COMP-7 → **FR-6 / AC-3**  
  * **UC-SCR16-07** → SRS-FR-29 / SDS-COMP-7 → **FR-7 / NFR-1 / AC-4**  
  * **UC-SCR16-08** → SRS-NFR-6 / SDS-ERR-8 → **NFR-2, NFR-3 / EC-4**  
  * **UC-SCR16-09** → BR-NFR-020 / SDS-COMP-7 → **NFR-4 / EC-5**  
  * **UC-SCR16-10** → SDS-COMP-7 → **FR-8 / AC-5**  
  * **UC-SCR16-11** → SRS-FR-32 → **FR-9 / AC-6**  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain. This story derives strictly from all 11 UC rows defined for **SCR-16** and introduces no additional functional scope.

# **\#Forge-US-17**

# **1\. User Story Identification**

* **Story ID:** US-SCR17  
* **Title:** Rest Timer  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** 3

# **2\. User Story Statement**

**As an authenticated user, I want to see and control the rest period between workout sets, so that I can manage the required recovery time before continuing my workout.**

# **3\. Description / Context**

SCR-17 provides the work/rest timing experience between sets during an active workout. The rest timer is presented inline or as an overlay on SCR-16 and is automatically initiated according to the configured set rest period.

The timer must operate independently of network calls, allow the user to skip the remaining rest period, and automatically return the user to the active workout when the countdown reaches zero.

# **4\. Functional Requirements**

* **FR-1** — When a configured rest period begins, the system shall display a countdown for the rest period. **(UC-SCR17-01, SRS-NFR-2)**  
* **FR-2** — The rest countdown shall run independently of any network call. **(UC-SCR17-01, SRS-NFR-2)**  
* **FR-3** — The system shall allow the user to skip the remaining rest period. **(UC-SCR17-02, SRS-FR-29)**  
* **FR-4** — When the user skips the remaining rest period, the system shall return immediately to SCR-16. **(UC-SCR17-02, SRS-FR-29)**  
* **FR-5** — When the rest timer reaches zero, the system shall automatically advance to the next set or exercise on SCR-16 without requiring user confirmation. **(UC-SCR17-03, SRS-NFR-14, SDS-NFR-16)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The rest countdown shall operate independently of network calls during the configured rest period. **(UC-SCR17-01, SRS-NFR-2, SDS-NFR-2)**  
* **NFR-2** — The timer shall automatically advance the workout when the countdown reaches zero without requiring additional user confirmation. **(UC-SCR17-03, SRS-NFR-14, SDS-NFR-16)**

# **6\. Security & Privacy Requirements**

* **SEC-1** — Access to the rest timer shall require an authenticated user session as part of the active workout flow. **(UC-SCR17-01, SRS-NFR-2)**  
* **SEC-2** — The rest timer shall operate within the user's active workout session and shall not expose workout information belonging to another user. **(UC-SCR17-01, SRS-NFR-2)**

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
* **Full-chain traceability summary:**  
  * **UC-SCR17-01** → SRS-NFR-2 / SDS-NFR-2 → **FR-1, FR-2 / NFR-1 / SEC-1 / AC-1**  
  * **UC-SCR17-02** → SRS-FR-29 → **FR-3, FR-4 / AC-2**  
  * **UC-SCR17-03** → SRS-NFR-14 / SDS-NFR-16 → **FR-5 / NFR-2 / SEC-2 / AC-3**  
* **BRD → SRS → SDS → Inventory → User Story:**  
  BRD requirements are inherited through the cited SRS/SDS traceability chain. This story derives strictly from all 3 UC rows defined for **SCR-17** and introduces no additional functional scope.

# **User Story — SCR-18**

## **1\. User Story Identification**

* **Story ID:** US-SCR-18  
* **Title:** Cancel Active Workout Confirmation  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As an authenticated user,** I want to confirm whether I want to cancel an active workout, so that I can explicitly decide whether to discard the in-progress workout session before leaving the active workout.

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

* SCR-18 requires an authenticated user. No additional screen-specific security or privacy behavior is specified in the SCR-18 UC rows. **Not specified in Inventory — confirm with SRS/SDS owner.**

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

# **User Story — SCR-19**

## **1\. User Story Identification**

* **Story ID:** US-SCR-19  
* **Title:** Workout Summary and Completion  
* **Epic / Feature:** Workout Execution  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As an authenticated user,** I want to see a summary of my workout after finishing it, so that I can review the recorded performance and know whether the workout was completed successfully or recorded as incomplete.

## **3\. Description / Context**

SCR-19 is the Workout Summary screen reached from SCR-16 when the last workout item has been completed.

When the user finishes the workout, the session is persisted before the completed summary is displayed. While persistence is in progress, the finish action shows a loading state.

For a successfully persisted workout, the summary presents the recorded workout information, including date/time, duration, and actual sets/reps/weight.

If the workout does not meet the completion criteria, the session is recorded and labeled as incomplete and excluded from progress and statistics.

If persistence fails or connectivity is unavailable at finish, the workout must not be represented as saved. The user is given a retry path, while the in-memory session data is preserved for the retry attempt in the offline case.

## **4\. Functional Requirements**

* **FR-1** — When the user taps Finish and the session is being persisted, the system shall display a loading state on the Finish action. **(UC-SCR19-01, SRS-FR-33–SRS-FR-35)**  
* **FR-2** — When the workout session is successfully persisted, the system shall display a summary containing the completed workout's date/time, duration, and actual sets/reps/weight. **(UC-SCR19-02, SRS-FR-33–SRS-FR-35)**  
* **FR-3** — When the workout does not meet the completion criteria, the system shall record and label the session as incomplete and exclude it from progress and statistics. **(UC-SCR19-03, SRS-FR-30)**  
* **FR-4** — When the workout session cannot be persisted because the Firestore write fails, the system shall not represent the workout as saved and shall provide a retry option without creating a duplicate record when the retry succeeds. **(UC-SCR19-04, SRS-FR-33–SRS-FR-35)**  
* **FR-5** — When connectivity is unavailable at finish, the system shall prevent the workout from being represented as saved, provide the specified offline state with retry, and preserve the in-memory session data for the retry attempt. **(UC-SCR19-05, SRS-FR-33–SRS-FR-35)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The workout summary and completion status shall be based on the persisted workout session outcome and shall not represent an unsuccessful persistence attempt as a completed saved workout. **(UC-SCR19-04, SDS-NFR-6)**  
* **NFR-2** — The workout session shall remain available for the retry attempt when finish cannot proceed because of unavailable connectivity, as specified by the Inventory. **(UC-SCR19-05, BR-NFR-020)**

> **Note:** The SCR-19 UC rows do not explicitly cite an SRS-NFR-\* ID. The applicable non-functional behavior is therefore traced only to the Inventory's stated SDS/BRD references. **Confirm exact SRS-NFR/SDS-NFR mapping with the SRS/SDS owner.**

## **6\. Security & Privacy Requirements**

* SCR-19 requires an authenticated user.  
* The Inventory does not specify additional SCR-19-specific security or privacy behavior beyond the authenticated-screen requirement.

**Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Workout Summary**

* **Component type:** Workout summary content  
* **Input type:** None  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Summary data is required when the session is successfully persisted.

### **Recorded Workout Information**

* **Component type:** Summary information  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Date/time, duration, and actual sets/reps/weight are specified for the successful summary state.

### **Finish Action Loading State**

* **Component type:** Finish action  
* **Input type:** User action  
* **Validation rules:** Not specified  
* **Min / Max constraints:** Not specified  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Loading state required while the session is being persisted.

### **Incomplete Workout State**

* **Component type:** Workout completion status / summary state  
* **Input type:** None  
* **Validation rules:** Workout completion criteria determine the state  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when the workout does not meet completion criteria.

### **Error / Retry State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified for Firestore write failure; offline copy is specified as **"You're offline — your workout can't be saved until you reconnect"**  
* **Mandatory / Optional flags:** Required when persistence fails or connectivity is unavailable at finish.

## **8\. Acceptance Criteria**

### **AC-1 — Finish Loading State**

**UC:** UC-SCR19-01

**Given** the user has finished the active workout and the session is being persisted  
**When** the finish action is processing  
**Then** the Finish action shall display a loading state.

### **AC-2 — Successfully Saved Workout Summary**

**UC:** UC-SCR19-02

**Given** the workout session is being persisted  
**When** the session persists successfully  
**Then** the system shall display a summary of the completed workout containing the date/time, duration, and actual sets/reps/weight.

### **AC-3 — Incomplete Workout**

**UC:** UC-SCR19-03

**Given** the workout does not meet the completion criteria  
**When** the workout is recorded  
**Then** the system shall record and label the session as incomplete and exclude it from progress and statistics.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Persistence Failure**

**UC:** UC-SCR19-04

**Given** the user finishes the workout  
**When** the Firestore write fails  
**Then** the system shall show an error state, shall not represent the workout as saved, shall provide a retry option, and shall not create a duplicate record when the retry succeeds.

### **EC-2 — Offline at Finish**

**UC:** UC-SCR19-05

**Given** the user finishes the workout  
**When** there is no connectivity  
**Then** the system shall show the specified offline state, shall not represent the workout as saved, shall provide a retry option, and shall preserve the in-memory session data for the retry attempt.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-16 — Active Workout — Exercise & Set Logging. The user reaches SCR-19 after the last item is completed.  
* **Screen exit dependencies:** The Inventory identifies SCR-06 Home and SCR-20 Workout History as destinations from the completed workout flow.  
* **\[ASSUMPTION\] flag:** None specified for SCR-19.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact completion criteria used to determine whether a workout is complete or incomplete.  
  * The Inventory does not specify the exact error-state copy for Firestore write failure.  
  * The Inventory does not specify the exact retry action label.  
  * The Inventory does not specify the exact navigation/action behavior available after the successful summary beyond the documented SCR-06 / SCR-20 destinations.  
* These details must be confirmed with the SRS/SDS owner rather than invented in this story.  
* **Full-chain traceability summary:**  
  * **UC-SCR19-01 → FR-1 / AC-1**  
  * **UC-SCR19-02 → FR-2 / AC-2**  
  * **UC-SCR19-03 → FR-3 / AC-3**  
  * **UC-SCR19-04 → FR-4 / EC-1**  
  * **UC-SCR19-05 → FR-5 / EC-2**  
  * **SRS-FR-33–SRS-FR-35 → SDS-COMP-8 / SDS-DATA-6 → UC-SCR19-01/02 → this story**  
  * **SRS-FR-30 → SDS-DATA-8 → UC-SCR19-03 → this story**  
  * **SDS-ERR-6 → UC-SCR19-04 → this story**  
  * **BR-NFR-020 → SDS-ERR-6 → UC-SCR19-05 → this story**  
* **BRD-level mapping:** The supplied Inventory explicitly exposes BR-FR-025 for the incomplete-workout behavior and BR-NFR-020 for offline behavior. The complete BRD → SRS → SDS mapping for every SCR-19 UC is not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain table before baselining this story.**

# **User Story — SCR-20**

## **1\. User Story Identification**

* **Story ID:** US-SCR-20  
* **Title:** Workout History List  
* **Epic / Feature:** Workout History  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As an authenticated user,** I want to view my completed workout history, so that I can review the workouts I have previously completed and access their recorded details.

## **3\. Description / Context**

SCR-20 is the Workout History List screen within the Workout History flow.

The screen is accessible from SCR-06 through the History tab and from SCR-19 through the option to view a completed workout in history.

When history data is being fetched, the screen displays a skeleton list. If no completed workouts exist, the screen displays an empty state. When completed sessions exist, the screen displays them in reverse chronological order and only shows sessions belonging to the authenticated user.

If history cannot be loaded, the screen provides an error state with retry. If connectivity is unavailable, the screen displays an offline state because the application has no offline mode.

Selecting a history session leads to SCR-21 for the full workout history detail.

## **4\. Functional Requirements**

* **FR-1** — When workout history is being fetched, the system shall display a skeleton list. **(UC-SCR20-01, SRS-FR-36)**  
* **FR-2** — When the authenticated user has no completed workouts, the system shall display an empty state stating **"Your completed workouts will appear here"**. **(UC-SCR20-02, SRS-FR-36)**  
* **FR-3** — When completed workout sessions exist, the system shall display the sessions in reverse-chronological order. **(UC-SCR20-03, SRS-FR-36)**  
* **FR-4** — The workout history list shall contain only completed sessions belonging to the authenticated user. **(UC-SCR20-03, SRS-FR-36)**  
* **FR-5** — When the user selects a workout history session, the system shall provide access to SCR-21 for the selected workout's recorded details. **(UC-SCR20-03, SRS-FR-36)**

## **5\. Non-Functional Requirements**

* **NFR-1** — Workout history shall be presented in reverse-chronological order when completed sessions exist. **(UC-SCR20-03, SRS-FR-36)**  
* **NFR-2** — The history screen shall not silently present unavailable data as an empty history state when a history-load failure occurs; a distinct error state with retry shall be presented. **(UC-SCR20-04, SDS-ERR-5)**  
* **NFR-3** — The history screen shall provide an explicit offline state when connectivity is unavailable. **(UC-SCR20-05, BR-NFR-020)**

## **6\. Security & Privacy Requirements**

* **SEC-1** — The workout history displayed on SCR-20 shall contain only completed sessions belonging to the authenticated user. **(UC-SCR20-03, SRS-FR-36, SDS-COMP-9)**  
* **SEC-2** — SCR-20 shall require authentication before the user's workout history can be accessed. **(UC-SCR20-03, SRS-FR-36)**  
* The Inventory does not specify additional SCR-20-specific security or privacy behavior. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **History List**

* **Component type:** List of workout history sessions  
* **Input type:** User selection of a history session  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when completed sessions exist

### **History Session Item**

* **Component type:** Workout history list item  
* **Input type:** User selection  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required for each available completed session

### **Loading State**

* **Component type:** Skeleton list  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while history is being fetched

### **Empty State**

* **Component type:** Empty-state content  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages / content:** **"Your completed workouts will appear here"**  
* **Mandatory / Optional flags:** Required when no completed workouts exist

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when history fails to load

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when there is no connectivity

## **8\. Acceptance Criteria**

### **AC-1 — History Loading**

**UC:** UC-SCR20-01

**Given** workout history is being fetched  
**When** SCR-20 is displayed  
**Then** the system shall display a skeleton list.

### **AC-2 — Empty History**

**UC:** UC-SCR20-02

**Given** the authenticated user has no completed workouts  
**When** the history data is loaded  
**Then** the system shall display an empty state containing **"Your completed workouts will appear here"**.

### **AC-3 — Populated History**

**UC:** UC-SCR20-03

**Given** completed workout sessions exist for the authenticated user  
**When** the history data is loaded  
**Then** the system shall display the sessions in reverse-chronological order and shall display only the authenticated user's own completed sessions.

### **AC-4 — Open History Detail**

**UC:** UC-SCR20-03

**Given** the workout history list contains a completed session  
**When** the user selects that session  
**Then** the system shall navigate to SCR-21 to view the selected workout's full recorded details.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — History Load Failure**

**UC:** UC-SCR20-04

**Given** workout history is being loaded  
**When** the history data fails to load  
**Then** the system shall display an error state with a retry action.

### **EC-2 — No Connectivity**

**UC:** UC-SCR20-05

**Given** the user is accessing SCR-20  
**When** there is no connectivity  
**Then** the system shall display the offline state.

## **10\. Dependencies & Notes**

* **Screen entry dependencies:**  
  * **SCR-06 — Home Dashboard:** History tab provides access to SCR-20.  
  * **SCR-19 — Workout Summary:** The completed workout flow can provide access to SCR-20 through the "View in history" path.  
* **Screen exit dependency:**  
  * **SCR-21 — Workout History Detail:** Selecting a history session provides access to the detailed recorded workout.  
* **\[ASSUMPTION\] flag:** None specified for SCR-20.  
* **Underspecified behavior:**  
  * The Inventory does not specify which individual fields are displayed in each history list item.  
  * The Inventory does not specify the exact error message for history-load failure.  
  * The Inventory does not specify the exact offline message for SCR-20.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-36 → SDS-COMP-9 / SDS-IF-7 → UC-SCR20-01 → FR-1 / AC-1**  
  * **SRS-FR-36 → SDS-COMP-9 / SDS-IF-7 → UC-SCR20-02 → FR-2 / AC-2**  
  * **SRS-FR-36 → SDS-COMP-9 → UC-SCR20-03 → FR-3 / FR-4 / FR-5 / AC-3 / AC-4**  
  * **SDS-ERR-5 → UC-SCR20-04 → Edge Case EC-1**  
  * **BR-NFR-020 → UC-SCR20-05 → NFR-3 / Edge Case EC-2**  
  * **SRS-FR-36 → SDS-COMP-9 → UC-SCR20-03 → SEC-1 / SEC-2**  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-20 Inventory rows expose SRS-FR-36, SDS-COMP-9, SDS-IF-7, SDS-ERR-5, and BR-NFR-020. The corresponding complete BRD mappings are not included in the SCR-20 rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**

# **User Story — SCR-21**

## **1\. User Story Identification**

* **Story ID:** US-SCR-21  
* **Title:** Workout History Detail  
* **Epic / Feature:** Workout History  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As an authenticated user,** I want to view the complete details of a previously completed workout, so that I can review the actual performance I recorded for that session.

## **3\. Description / Context**

SCR-21 is the Workout History Detail screen within the Workout History flow.

The screen is accessed by selecting a workout session from SCR-20. When the selected session is being fetched, a skeleton is displayed.

When the session loads successfully, the screen displays the full recorded workout detail, including the date/time and the actual performance for each exercise, including sets, reps, weight, and duration.

Historical workout data must remain independent of later changes to the underlying workout plan. If the plan used for the session is subsequently edited or deleted, the historical detail continues to show the actual performance as it was originally recorded.

If the session detail cannot be loaded, an error state with retry is provided. If connectivity is unavailable, the screen displays an offline state.

## **4\. Functional Requirements**

* **FR-1** — When the selected workout session detail is being fetched, the system shall display a skeleton. **(UC-SCR21-01, SRS-FR-37)**  
* **FR-2** — When the workout session is successfully loaded, the system shall display the full recorded detail, including date/time and per-exercise actual sets, reps, weight, and duration. **(UC-SCR21-02, SRS-FR-37)**  
* **FR-3** — When the underlying workout plan has subsequently been edited or deleted, the system shall continue to display the actual performance originally recorded for the historical session without applying subsequent plan changes to that historical record. **(UC-SCR21-03, SRS-FR-38)**

## **5\. Non-Functional Requirements**

* **NFR-1** — Historical workout details shall preserve the recorded performance independently of subsequent changes to the underlying workout plan. **(UC-SCR21-03, SRS-FR-38, SDS-DATA-6)**  
* **NFR-2** — When session detail cannot be loaded, the system shall present a distinct error state with retry rather than representing the unavailable data as a valid populated or empty state. **(UC-SCR21-04, SDS-ERR-5)**  
* **NFR-3** — When connectivity is unavailable, the system shall present the defined offline state because workout history is not available through an offline/local-cache mode. **(UC-SCR21-05, BR-NFR-020)**

## **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-21 shall require authentication to access workout history detail. **(UC-SCR21-02, SRS-FR-37)**  
* **SEC-2** — The historical workout detail displayed shall correspond to the selected workout session from the authenticated user's workout history. **(UC-SCR21-02, SRS-FR-37, SDS-COMP-9)**  
* No additional SCR-21-specific security or privacy behavior is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Workout History Detail**

* **Component type:** Workout history detail content  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when the session is successfully loaded

### **Date / Time**

* **Component type:** Recorded workout information  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required in the populated state

### **Per-Exercise Actual Performance**

* **Component type:** Recorded exercise detail  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required for recorded exercise details

### **Loading State**

* **Component type:** Skeleton  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while session detail is being fetched

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when session detail fails to load

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when there is no connectivity

## **8\. Acceptance Criteria**

### **AC-1 — Session Detail Loading**

**UC:** UC-SCR21-01

**Given** the user has selected a workout session from SCR-20  
**When** the selected session detail is being fetched  
**Then** SCR-21 shall display a skeleton.

### **AC-2 — Display Recorded Workout Detail**

**UC:** UC-SCR21-02

**Given** the selected workout session has been successfully loaded  
**When** SCR-21 displays the session  
**Then** the system shall show the full recorded detail, including the workout date/time and the actual sets, reps, weight, and duration for each exercise.

### **AC-3 — Preserve Historical Integrity**

**UC:** UC-SCR21-03

**Given** a historical workout session was recorded using a workout plan  
**When** that underlying plan is subsequently edited or deleted  
**Then** SCR-21 shall continue to display the actual performance originally recorded for that historical session, unaffected by the subsequent plan changes.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Session Detail Load Failure**

**UC:** UC-SCR21-04

**Given** the user has selected a workout session  
**When** the session detail fails to load  
**Then** the system shall display an error state with a retry action.

### **EC-2 — No Connectivity**

**UC:** UC-SCR21-05

**Given** the user is accessing SCR-21  
**When** there is no connectivity  
**Then** the system shall display the offline state.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-20 — Workout History List. The selected workout session from SCR-20 is the source of the detail displayed on SCR-21.  
* **Screen exit dependency:** The Inventory specifies returning to SCR-20 through the back action.  
* **\[ASSUMPTION\] flag:** None specified for SCR-21.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact layout or ordering of the date/time and per-exercise recorded fields.  
  * The Inventory does not specify the exact error message for a session-detail load failure.  
  * The Inventory does not specify the exact offline message for SCR-21.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-37 → SDS-COMP-9 / SDS-DATA-6 → UC-SCR21-01 → FR-1 / AC-1**  
  * **SRS-FR-37 → SDS-COMP-9 / SDS-DATA-6 → UC-SCR21-02 → FR-2 / AC-2 / SEC-1 / SEC-2**  
  * **SRS-FR-38 → SDS-DATA-6 → UC-SCR21-03 → FR-3 / NFR-1 / AC-3**  
  * **SDS-ERR-5 → UC-SCR21-04 → NFR-2 / EC-1**  
  * **BR-NFR-020 → UC-SCR21-05 → NFR-3 / EC-2**  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-21 Inventory rows explicitly provide SRS-FR-37, SRS-FR-38, SDS-COMP-9, SDS-DATA-6, SDS-ERR-5, and BR-NFR-020. The complete BRD mapping is not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**

# **User Story — SCR-22**

## **1\. User Story Identification**

* **Story ID:** US-SCR-22  
* **Title:** Progress Comparison  
* **Epic / Feature:** Progress  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

**As an authenticated user,** I want to compare my workout performance across completed sessions for each exercise, so that I can understand how my performance has progressed over time.

## **3\. Description / Context**

SCR-22 is the Progress Comparison screen within the Progress flow.

The screen retrieves and presents progress data calculated from the user's valid completed workout history. While progress data is being calculated or fetched, a skeleton/placeholder chart is displayed.

When fewer than two valid completed sessions exist for a given exercise, the screen displays the specified empty state. When sufficient valid history exists, the screen presents a comparison view across sessions for applicable exercise metrics: weight, reps, volume, and duration.

Incomplete or invalid workout sessions must not influence the progress comparison. Such sessions are silently excluded rather than being displayed as a gap or error.

If progress data cannot be loaded or calculated, an error state with retry is displayed. When connectivity is unavailable, the screen displays the offline state.

## **4\. Functional Requirements**

* **FR-1** — When progress data is being calculated or fetched, the system shall display a skeleton/placeholder chart. **(UC-SCR22-01, SRS-FR-39–SRS-FR-41)**  
* **FR-2** — When fewer than two valid completed sessions exist for a given exercise, the system shall display the empty state **"Complete a few more workouts to see your progress"**. **(UC-SCR22-02, SRS-FR-39)**  
* **FR-3** — When sufficient valid workout history exists, the system shall display a comparison view across sessions for each exercise using weight, reps, volume, and duration where applicable. **(UC-SCR22-03, SRS-FR-40)**  
* **FR-4** — When an incomplete or invalid session exists in the underlying workout history, the system shall exclude that session from the progress comparison and shall not display it as a gap or error. **(UC-SCR22-04, SRS-FR-41)**  
* **FR-5** — When progress data fails to load or calculate, the system shall display an error state with a retry action. **(UC-SCR22-05, SRS-FR-39–SRS-FR-41)**  
* **FR-6** — When there is no connectivity, the system shall display the offline state. **(UC-SCR22-06, SRS-FR-39–SRS-FR-41)**

## **5\. Non-Functional Requirements**

* **NFR-1** — Progress comparisons shall use valid completed workout sessions and shall exclude incomplete or invalid sessions from the comparison. **(UC-SCR22-04, SRS-FR-41, SDS-COMP-10)**  
* **NFR-2** — An incomplete or invalid workout session shall be silently excluded from the progress comparison rather than represented as a gap or error. **(UC-SCR22-04, SRS-FR-41, SDS-COMP-10)**  
* **NFR-3** — When progress data cannot be loaded or calculated, the system shall distinguish the failure from an empty progress state by presenting an error state with retry. **(UC-SCR22-05, SDS-ERR-5, SDS-ERR-9)**  
* **NFR-4** — When connectivity is unavailable, the system shall present the defined offline state rather than presenting unavailable progress data as valid data. **(UC-SCR22-06, BR-NFR-020)**

## **6\. Security & Privacy Requirements**

* **SEC-1** — SCR-22 shall require authentication before the user's progress data can be accessed. **(UC-SCR22-03, SRS-FR-40, SDS-COMP-10)**  
* **SEC-2** — Progress comparison data shall be derived from the authenticated user's valid completed workout history. **(UC-SCR22-03, SRS-FR-40, SDS-DATA-7)**  
* **SEC-3** — Progress data belonging to another user shall not be presented on SCR-22. **(UC-SCR22-03, SRS-FR-40, SDS-COMP-10)**  
* No additional SCR-22-specific security or privacy behavior is specified in the Inventory. **Not specified in Inventory — confirm with SRS/SDS owner.**

## **7\. UI / Component Specifications**

### **Progress Comparison View**

* **Component type:** Comparison view  
* **Input type:** Read-only progress data  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required when sufficient valid history exists

### **Progress Chart / Placeholder**

* **Component type:** Skeleton/placeholder chart  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required while progress data is being calculated/fetched

### **Exercise Progress Data**

* **Component type:** Exercise-level comparison data  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Required when sufficient valid history exists

### **Progress Metrics**

* **Component type:** Progress comparison metrics  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not applicable  
* **Mandatory / Optional flags:** Weight, reps, volume, and duration where applicable

### **Empty State**

* **Component type:** Empty-state content  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages / content:** **"Complete a few more workouts to see your progress"**  
* **Mandatory / Optional flags:** Required when fewer than two valid completed sessions exist for a given exercise

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when progress data fails to load or calculate

### **Offline State**

* **Component type:** Offline state  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional flags:** Required when there is no connectivity

## **8\. Acceptance Criteria**

### **AC-1 — Progress Loading**

**UC:** UC-SCR22-01

**Given** progress data is being calculated or fetched  
**When** SCR-22 is displayed  
**Then** the system shall display a skeleton/placeholder chart.

### **AC-2 — Insufficient Progress History**

**UC:** UC-SCR22-02

**Given** fewer than two valid completed sessions exist for a given exercise  
**When** progress data is displayed  
**Then** the system shall display **"Complete a few more workouts to see your progress"**.

### **AC-3 — Progress Comparison**

**UC:** UC-SCR22-03

**Given** sufficient valid completed workout history exists  
**When** progress data is displayed  
**Then** the system shall present a comparison view across sessions for each exercise using weight, reps, volume, and duration where applicable.

### **AC-4 — Exclude Invalid or Incomplete Sessions**

**UC:** UC-SCR22-04

**Given** an incomplete or invalid workout session exists in the underlying history  
**When** progress comparison data is calculated  
**Then** the system shall silently exclude that session from the comparison and shall not display it as a gap or error.

## **9\. Edge Cases & Error Scenarios**

### **EC-1 — Progress Calculation or Load Failure**

**UC:** UC-SCR22-05

**Given** progress data is being loaded or calculated  
**When** the progress data fails to load or calculate  
**Then** the system shall display an error state with a retry action.

### **EC-2 — No Connectivity**

**UC:** UC-SCR22-06

**Given** the user is accessing SCR-22  
**When** there is no connectivity  
**Then** the system shall display the offline state.

## **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-06 — Home Dashboard, through the Progress tab.  
* **Screen exit dependencies:** None specified in the Inventory.  
* **Data dependency:** Progress comparison depends on valid completed workout history and the exercise-level performance data recorded within those sessions.  
* **\[ASSUMPTION\] flag:** None specified for SCR-22.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual representation of the comparison view.  
  * The Inventory does not specify the exact chart type.  
  * The Inventory does not specify how the user selects or switches between exercises.  
  * The Inventory does not specify the exact calculation/display rules for volume.  
  * The Inventory does not specify the exact error message for progress calculation/load failure.  
  * The Inventory does not specify the exact offline message for SCR-22.  
  * The Inventory does not specify the exact retry action label.  
* These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-39 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-01 → FR-1 / AC-1**  
  * **SRS-FR-39 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-02 → FR-2 / AC-2**  
  * **SRS-FR-40 → SDS-COMP-10 / SDS-IF-8 / SDS-DATA-7 → UC-SCR22-03 → FR-3 / AC-3 / SEC-1 / SEC-2 / SEC-3**  
  * **SRS-FR-41 → SDS-COMP-10 → UC-SCR22-04 → FR-4 / NFR-1 / NFR-2 / AC-4**  
  * **SDS-ERR-5 / SDS-ERR-9 → UC-SCR22-05 → FR-5 / NFR-3 / EC-1**  
  * **BR-NFR-020 → UC-SCR22-06 → FR-6 / NFR-4 / EC-2**  
* **BRD → SRS → SDS → Inventory → User Story:** The SCR-22 Inventory rows explicitly provide SRS-FR-39–SRS-FR-41, SDS-COMP-10, SDS-IF-8, SDS-DATA-7, SDS-ERR-5, SDS-ERR-9, and BR-NFR-020. The complete BRD mappings are not included in the selected screen rows; **confirm against the SDS Section 10.2 full-chain traceability table before baselining this story.**

# **1\. User Story Identification**

* **Story ID:** US-SCR23  
* **Title:** View Statistics Dashboard  
* **Epic / Feature:** Statistics  
* **Priority:** Medium  
* **Story Points:** 5

# **2\. User Story Statement**

As an authenticated user, I want to view my workout statistics so that I can understand my completed workout activity, training volume, workout duration, and exercise-level performance.

# **3\. Description / Context**

SCR-23 is the Statistics Dashboard within **FLOW-09 — Statistics**.

The screen provides statistics derived from valid workout history. It supports an empty state when no valid completed workouts exist, a populated state when valid history is available, recalculation when workout records change, loading while statistics are calculated, and recoverable system/offline states.

The screen is accessible from the authenticated Home Dashboard through the **Stats** tab.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty statistics state when the user has no valid completed workouts, including zeroed/placeholder statistics and a prompt to complete a workout. **(UC-SCR23-02, SRS-FR-42)**  
* **FR-2** — The system shall display statistics when valid workout history exists, including total completed workouts, training volume, workout duration, and exercise-level statistics. **(UC-SCR23-03, SRS-FR-42, SRS-FR-43, SRS-FR-44, SRS-FR-45)**  
* **FR-3** — The system shall recalculate statistics from the user's current valid workout records when a workout record is edited or deleted, rather than displaying stale statistics. **(UC-SCR23-04, SRS-FR-47)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Statistics Dashboard shall present a loading/skeleton state while statistics are being calculated. **(UC-SCR23-01, SDS-IF-12)**  
* **NFR-2** — Statistics shall be based on valid workout records and shall recalculate when the underlying valid records change. **(UC-SCR23-04, SRS-FR-47, SDS-ERR-9)**  
* **NFR-3** — When connectivity is unavailable, the Statistics Dashboard shall present the defined offline state rather than silently presenting unavailable data. **(UC-SCR23-06, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SR-1** — The Statistics Dashboard shall be accessible only to an authenticated user. **(Screen Auth Requirement: Required)**  
* **SR-2** — Statistics shall be derived from the authenticated user's valid workout records and shall not expose another user's workout statistics. **(UC-SCR23-03, SRS-FR-42–45)**

# **7\. UI / Component Specifications**

### **Statistics Loading State**

* **Component type:** Skeleton/placeholder cards  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required loading state  
* **Source:** UC-SCR23-01

### **Empty Statistics State**

* **Component type:** Empty state with zeroed/placeholder statistics and prompt  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when no valid completed workouts exist  
* **Source:** UC-SCR23-02

### **Statistics Dashboard**

* **Component type:** Statistics dashboard  
* **Input type:** Not applicable  
* **Validation rules:** Statistics shall reflect valid history  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when valid history exists  
* **Content:** Total completed workouts, training volume, workout duration, exercise-level statistics  
* **Source:** UC-SCR23-03

### **Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when statistics fail to load/calculate  
* **Source:** UC-SCR23-05

### **Offline State**

* **Component type:** Offline state  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** "Offline state" — exact message not specified in Inventory  
* **Mandatory / Optional:** Required when there is no connectivity  
* **Source:** UC-SCR23-06

# **8\. Acceptance Criteria**

### **AC-1 — Loading Statistics**

**Given** the user opens the Statistics Dashboard and statistics are being calculated,  
**When** the calculation is in progress,  
**Then** the system shall display skeleton/placeholder cards.  
**(UC-SCR23-01)**

### **AC-2 — No Valid Completed Workouts**

**Given** the user has no valid completed workouts,  
**When** the Statistics Dashboard is displayed,  
**Then** the system shall display an empty state with zeroed/placeholder statistics and a prompt to complete a workout.  
**(UC-SCR23-02)**

### **AC-3 — Display Statistics**

**Given** the user has valid workout history,  
**When** statistics are successfully calculated,  
**Then** the system shall display total completed workouts, training volume, workout duration, and exercise-level statistics.  
**(UC-SCR23-03)**

### **AC-4 — Recalculate Current Statistics**

**Given** a workout record has been edited or deleted after being counted,  
**When** the Statistics Dashboard recalculates its statistics,  
**Then** the system shall calculate the displayed statistics from the current valid records rather than displaying stale values.  
**(UC-SCR23-04)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Statistics Calculation/Load Failure**

**Given** statistics fail to load or calculate,  
**When** the failure occurs,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR23-05)**

### **EC-2 — No Connectivity**

**Given** there is no connectivity,  
**When** the user accesses the Statistics Dashboard,  
**Then** the system shall display the defined offline state.  
**(UC-SCR23-06)**

# **10\. Dependencies & Notes**

* **Screen entry dependencies:** SCR-06 — Home Dashboard / Stats tab.  
* **Screen exit dependencies:** SCR-24 — Personal Bests.  
* **Authentication dependency:** The screen requires an authenticated user.  
* **\[ASSUMPTION\] flag:** None specified for SCR-23.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual format of the statistics dashboard.  
  * The Inventory does not specify the exact wording of the error state or offline state.  
  * The Inventory does not specify calculation formulas for training volume, workout duration, or exercise-level statistics.  
  * These details must be confirmed with the SRS/SDS owner rather than invented at user-story level.  
* **Full-chain traceability summary:**  
  * **BRD:** BRD-FR/NFR IDs reachable through the SDS full-chain mapping  
  * **SRS:** SRS-FR-42 → UC-SCR23-02 → FR-1 / AC-2  
  * **SRS:** SRS-FR-42–45 → UC-SCR23-03 → FR-2 / AC-3  
  * **SRS:** SRS-FR-47 → UC-SCR23-04 → FR-3 / NFR-2 / AC-4  
  * **SDS:** SDS-IF-12 → UC-SCR23-01 → NFR-1 / AC-1  
  * **SDS:** SDS-DATA-7 → UC-SCR23-03 → FR-2 / AC-3  
  * **SDS:** SDS-ERR-9 → UC-SCR23-04 → NFR-2 / AC-4  
  * **SDS:** SDS-ERR-5 / SDS-ERR-9 → UC-SCR23-05 → EC-1  
  * **BRD:** BR-NFR-020 → UC-SCR23-06 → NFR-3 / EC-2

# **1\. User Story Identification**

* **Story ID:** US-SCR24  
* **Title:** View Personal Bests  
* **Epic / Feature:** Statistics  
* **Priority:** Medium  
* **Story Points:** 3

# **2\. User Story Statement**

As an authenticated user, I want to view my personal bests for exercises so that I can see my highest recorded performance based on valid completed workouts.

# **3\. Description / Context**

SCR-24 is the **Personal Bests** screen within **FLOW-09 — Statistics**.

The screen is accessed from SCR-23 — Statistics Dashboard and presents personal bests derived from valid completed workout records. It supports loading, empty, populated, system failure, and offline states.

Only valid completed records are considered when displaying personal bests.

# **4\. Functional Requirements**

* **FR-1** — The system shall display an empty state when the user has no valid completed workouts. **(UC-SCR24-02, SRS-FR-46)**  
* **FR-2** — The system shall display a list of personal bests per exercise metric when valid personal-best records exist, using valid completed workout records only. **(UC-SCR24-03, SRS-FR-46)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The Personal Bests screen shall display a skeleton loading state while personal-best data is being calculated. **(UC-SCR24-01, SDS-IF-12)**  
* **NFR-2** — Personal-best results shall be derived only from valid completed workout records. **(UC-SCR24-03, SRS-FR-46, SDS-DATA-7)**  
* **NFR-3** — When connectivity is unavailable, the Personal Bests screen shall display the defined offline state. **(UC-SCR24-05, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SR-1** — The Personal Bests screen shall be accessible only to an authenticated user. **(Screen Auth Requirement: Required)**  
* **SR-2** — Personal-best information displayed on the screen shall be based on the authenticated user's valid completed workout records. **(UC-SCR24-03, SRS-FR-46, SDS-DATA-7)**

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

### **Offline State**

* **Component type:** Offline state  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** "Offline state" — exact message not specified in Inventory  
* **Mandatory / Optional:** Required when there is no connectivity  
* **Source:** UC-SCR24-05

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

### **EC-2 — No Connectivity**

**Given** there is no connectivity,  
**When** the user accesses the Personal Bests screen,  
**Then** the system shall display the defined offline state.  
**(UC-SCR24-05)**

# **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-23 — Statistics Dashboard.  
* **Screen exit dependency:** Back to SCR-23.  
* **Authentication dependency:** The screen requires an authenticated user.  
* **\[ASSUMPTION\] flag:** None specified for SCR-24.  
* **Underspecified behavior:**  
  * The Inventory does not define the exact exercise metrics used for personal bests.  
  * The Inventory does not define the calculation methodology for determining a personal best.  
  * The Inventory does not specify the exact empty-state message.  
  * The Inventory does not specify the exact error-state or offline-state messaging.  
  * These details must be confirmed with the SRS/SDS owner rather than invented at user-story level.  
* **Full-chain traceability summary:**  
  * **BRD:** BRD-FR/NFR IDs reachable through the SDS full-chain mapping.  
  * **SRS-FR-46** → UC-SCR24-02 → FR-1 / AC-2  
  * **SRS-FR-46 \+ SDS-DATA-7** → UC-SCR24-03 → FR-2 / NFR-2 / AC-3  
  * **SDS-IF-12** → UC-SCR24-01 → NFR-1 / AC-1  
  * **SDS-ERR-5 / SDS-ERR-9** → UC-SCR24-04 → EC-1  
  * **BR-NFR-020** → UC-SCR24-05 → NFR-3 / EC-2

# **1\. User Story Identification**

* **Story ID:** US-SCR25  
* **Title:** View Profile / Account  
* **Epic / Feature:** Account  
* **Priority:** Medium  
* **Story Points:** 3

# **2\. User Story Statement**

As an authenticated user, I want to view my basic account information and access the logout action so that I can review my registered account and securely end my session.

# **3\. Description / Context**

SCR-25 — **Profile / Account** is part of **FLOW-10 — Account**.

The screen is intended to provide a minimal account view for an authenticated user. Based on the Inventory, the demonstrably supported account information is the user's registered email address, together with a Logout action.

The screen is marked **\[ASSUMPTION\]** because the SDS data model contains additional profile fields, but the upstream requirements do not explicitly define viewing or editing those fields on an account screen. Therefore, this story does not introduce profile editing or additional profile functionality.

# **4\. Functional Requirements**

* **FR-1** — The system shall display the registered email address when the user's profile is successfully loaded. **(UC-SCR25-02, SRS-FR-1)**  
* **FR-2** — The system shall provide a Logout action from the Profile / Account screen. **(UC-SCR25-02, SRS-FR-1)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The screen shall display a skeleton while profile data is being fetched. **(UC-SCR25-01, SDS-IF-14)**  
* **NFR-2** — When the profile fails to load, the screen shall provide a recoverable error state with retry. **(UC-SCR25-03, SDS-ERR-5)**  
* **NFR-3** — When there is no connectivity, the screen shall display the defined offline state. **(UC-SCR25-04, BR-NFR-020)**

# **6\. Security & Privacy Requirements**

* **SR-1** — The Profile / Account screen shall require an authenticated user. **(Screen Auth Requirement: Required)**  
* **SR-2** — The screen shall display the registered email address associated with the authenticated user's account. **(UC-SCR25-02, SRS-FR-1, SDS-DATA-2)**

# **7\. UI / Component Specifications**

### **7.1 Profile Loading State**

* **Component type:** Skeleton  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required while profile is being fetched  
* **Source:** UC-SCR25-01

### **7.2 Account Information**

* **Component type:** Account/profile information display  
* **Input type:** Read-only  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not specified in Inventory  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Registered email is required when profile data is successfully loaded  
* **Content:** Registered email address  
* **Source:** UC-SCR25-02

### **7.3 Logout Action**

* **Component type:** Logout action  
* **Input type:** User action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required  
* **Source:** UC-SCR25-02

### **7.4 Profile Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when profile fails to load  
* **Source:** UC-SCR25-03

### **7.5 Offline State**

* **Component type:** Offline state  
* **Input type:** Not applicable  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Required when there is no connectivity  
* **Source:** UC-SCR25-04

# **8\. Acceptance Criteria**

### **AC-1 — Profile Loading**

**Given** the authenticated user opens SCR-25 and the profile is being fetched,  
**When** profile data is still loading,  
**Then** the system shall display a skeleton.  
**(UC-SCR25-01)**

### **AC-2 — Display Account Information**

**Given** the authenticated user's profile is successfully loaded,  
**When** SCR-25 is displayed,  
**Then** the system shall display the user's registered email address and a Logout action.  
**(UC-SCR25-02)**

# **9\. Edge Cases & Error Scenarios**

### **EC-1 — Profile Load Failure**

**Given** the user's profile fails to load,  
**When** the failure occurs,  
**Then** the system shall display an error state with a retry action.  
**(UC-SCR25-03)**

### **EC-2 — Offline**

**Given** there is no connectivity,  
**When** the user accesses SCR-25,  
**Then** the system shall display the defined offline state.  
**(UC-SCR25-04)**

# **10\. Dependencies & Notes**

* **Screen entry dependency:** SCR-06 — Home Dashboard.  
* **Screen exit dependency:** SCR-26 — Logout Confirmation.  
* **Authentication dependency:** Required.  
* **\[ASSUMPTION\] flag carried forward verbatim:**  
  The SDS data model (`users/{uid}`: displayName, dateOfBirth, heightCm, weightKg, fitnessGoal, experienceLevel) implies profile data exists, but no SRS-FR explicitly defines a screen for viewing or editing this data post-registration, nor does the Authentication Module's registration flow (AUTH-001) collect these fields at sign-up. **Confirm with the SRS/PRD owner before treating this as an editable screen** — as scoped today, this should be built as a minimal, mostly read-only account screen limited to what's demonstrably required (email display, logout).  
* **Scope constraint:** This story does not introduce profile editing or display of additional profile fields because those capabilities are not explicitly supported by the SCR-25 Inventory rows.  
* **Underspecified behavior:**  
  * The Inventory does not specify the exact visual presentation of the registered email.  
  * The Inventory does not specify the exact error-state message.  
  * The Inventory does not specify the exact offline-state message.  
  * These details must be confirmed with the SRS/SDS owner rather than invented.  
* **Full-chain traceability summary:**  
  * **SRS-FR-1 \+ SDS-DATA-2** → UC-SCR25-02 → FR-1 / FR-2 / SR-2 → AC-2  
  * **SDS-IF-14** → UC-SCR25-01 → NFR-1 → AC-1  
  * **SDS-ERR-5** → UC-SCR25-03 → NFR-2 → EC-1  
  * **BR-NFR-020** → UC-SCR25-04 → NFR-3 → EC-2  
  * **BRD → SRS → SDS → Inventory → User Story:** Full-chain traceability is maintained through the referenced SRS/SDS/UC IDs.

# **1\. User Story Identification**

* **Story ID:** US-SCR26  
* **Title:** Confirm Logout  
* **Epic / Feature:** Account  
* **Priority:** Medium  
* **Story Points:** 2

# **2\. User Story Statement**

As an authenticated user, I want to confirm my logout action so that I can explicitly choose whether to end my current session.

# **3\. Description / Context**

SCR-26 — **Logout Confirmation** is part of **FLOW-10 — Account**.

The screen is reached when the user selects **Logout** from SCR-25 — Profile / Account. It provides a confirmation step before ending the authenticated session.

The defined flow supports confirming or cancelling the logout action. On confirmation, the session is terminated and the user is routed back through the authentication flow, while the user's Firestore data remains untouched.

# **4\. Functional Requirements**

* **FR-1** — The system shall display a confirmation modal when the user taps Logout from SCR-25. **(UC-SCR26-01, SRS-FR-4)**  
* **FR-2** — When logout is confirmed, the system shall terminate the user's authenticated session. **(UC-SCR26-02, SRS-FR-4)**  
* **FR-3** — After logout is confirmed, the system shall route the user to SCR-01 / SCR-03 and shall leave the user's Firestore data untouched. **(UC-SCR26-02, SRS-FR-4)**

# **5\. Non-Functional Requirements**

* **NFR-1** — The logout confirmation interaction shall require explicit user confirmation before the authenticated session is terminated. **(UC-SCR26-01, SRS-FR-4)**

# **6\. Security & Privacy Requirements**

* **SR-1** — The system shall terminate the authenticated session when the user confirms logout. **(UC-SCR26-02, SRS-FR-4, SDS-COMP-2)**  
* **SR-2** — Logout shall not modify or delete the user's Firestore data. **(UC-SCR26-02, SRS-FR-4, SDS-COMP-2)**

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
* **Behavior:** Terminates the authenticated session and routes to SCR-01 / SCR-03  
* **Source:** UC-SCR26-02

# **8\. Acceptance Criteria**

### **AC-1 — Display Logout Confirmation**

**Given** the authenticated user is on SCR-25 and taps Logout,  
**When** the Logout action is triggered,  
**Then** the system shall display a confirmation modal.  
**(UC-SCR26-01)**

### **AC-2 — Confirm Logout**

**Given** the logout confirmation modal is displayed,  
**When** the user confirms logout,  
**Then** the system shall terminate the authenticated session and route the user to SCR-01 / SCR-03.  
**(UC-SCR26-02)**

### **AC-3 — Preserve User Data**

**Given** the user confirms logout,  
**When** the authenticated session is terminated,  
**Then** the user's Firestore data shall remain untouched.  
**(UC-SCR26-02)**

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

# **User Story — SCR-27**

## **1\. User Story Identification**

* **Story ID:** US-SCR27  
* **Title:** Cross-Cutting / Global States  
* **Epic / Feature:** Cross-Cutting / Global States  
* **Priority:** High  
* **Story Points:** Not specified in Inventory

## **2\. User Story Statement**

As an authenticated user, I want the application to consistently handle connectivity loss, recoverable data failures, write failures, invalid sessions, and unauthorized data-access attempts so that protected application data and actions are not presented as successful when they have not actually succeeded.

## **3\. Description / Context**

SCR-27 represents global states applicable across authenticated screens rather than a single standalone screen.

The Inventory requires consistent handling of:

* Loss of connectivity across the authenticated application.  
* Uncategorized Firestore read failures.  
* Uncategorized Firestore write failures.  
* Invalid authentication sessions.  
* Attempts to access another user's data.

These states must be handled consistently without silently presenting failed operations or unauthorized data.

## **4\. Functional Requirements**

* **FR-1** — When connectivity drops anywhere in the authenticated application, the system shall present a global, consistent **"No connection"** indicator/banner across authenticated screens, and write actions shall be blocked or queued with a warning rather than silently failing. **(UC-SCR27-01, SRS-FR not specified in Inventory)**  
* **FR-2** — When an uncategorized Firestore read failure occurs, the system shall present a generic recoverable error state with a retry option, distinguished from validation errors. **(UC-SCR27-02, SRS-FR not specified in Inventory)**  
* **FR-3** — When an uncategorized Firestore write failure occurs, the system shall not represent the write as successful and shall provide a retry option without creating a duplicate persisted record on retry. **(UC-SCR27-03, SRS-FR not specified in Inventory)**

## **5\. Non-Functional Requirements**

* **NFR-1** — The authenticated application shall provide a consistent no-connection state across authenticated screens when connectivity is unavailable; the application shall not rely on offline/local cached data as a substitute for connectivity. **(UC-SCR27-01, BR-NFR-020; SRS-NFR not specified in Inventory)**  
* **NFR-2** — Recoverable read failures shall be distinguishable from validation errors and shall provide a retry mechanism rather than leaving the user with an ambiguous or silently failed state. **(UC-SCR27-02, SDS-ERR-5; SRS-NFR not specified in Inventory)**  
* **NFR-3** — Failed write operations shall never be represented as successful, and retrying a failed write shall not result in a duplicate persisted record. **(UC-SCR27-03, SDS-ERR-6; SRS-NFR not specified in Inventory)**

## **6\. Security & Privacy Requirements**

* **SEC-1** — If the authenticated session becomes invalid during use, the system shall route the user back to **SCR-03**with an explanatory message rather than displaying broken or partial protected data. **(UC-SCR27-04, SRS-NFR-8, SDS-COMP-14)**  
* **SEC-2** — If an attempt is made to access another user's data through a malformed request, the access shall be rejected at the security-rule boundary and the application shall not render another user's data. **(UC-SCR27-05, SRS-NFR-8–10, SDS-COMP-14)**

## **7\. UI / Component Specifications**

### **Global No Connection Indicator / Banner**

* **Component type:** Global indicator/banner  
* **Input type:** None  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** **"No connection"** as specified in the Inventory  
* **Mandatory / Optional:** Mandatory when the global offline condition occurs  
* **Trace:** UC-SCR27-01

### **Generic Recoverable Error State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when an uncategorized Firestore read failure occurs  
* **Trace:** UC-SCR27-02

### **Generic Write Failure State**

* **Component type:** Error state with retry  
* **Input type:** Retry action  
* **Validation rules:** Not specified in Inventory  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when an uncategorized Firestore write failure occurs  
* **Trace:** UC-SCR27-03

### **Invalid Session State**

* **Component type:** Explanatory message with routing to Login  
* **Input type:** None specified  
* **Validation rules:** Not applicable  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Explanatory message required; exact wording **not specified in Inventory**  
* **Mandatory / Optional:** Mandatory when the session becomes invalid  
* **Trace:** UC-SCR27-04

### **Unauthorized Data Access State**

* **Component type:** Security rejection state  
* **Input type:** None specified  
* **Validation rules:** Access to another user's data must be rejected  
* **Min / Max constraints:** Not applicable  
* **Error messages:** Not specified in Inventory  
* **Mandatory / Optional:** Mandatory when the defensive unauthorized-access condition occurs  
* **Trace:** UC-SCR27-05

## **8\. Acceptance Criteria**

### **AC-1 — Global Offline State**

**Given** the user is anywhere in the authenticated application  
**When** connectivity drops  
**Then** the application shall display a global, consistent **"No connection"** indicator/banner across authenticated screens, and write actions shall be blocked or queued with a warning rather than silently failing.  
**(UC-SCR27-01)**

### **AC-2 — Firestore Read Failure**

**Given** an authenticated screen performs a Firestore read  
**When** an uncategorized Firestore read failure occurs  
**Then** the application shall display a generic recoverable error state with a retry option, distinguished from validation errors.  
**(UC-SCR27-02)**

### **AC-3 — Firestore Write Failure**

**Given** an authenticated screen performs a write operation  
**When** an uncategorized Firestore write failure occurs  
**Then** the application shall not represent the write as successful, shall offer retry, and shall not create a duplicate persisted record when the operation is retried.  
**(UC-SCR27-03)**

## **9\. Edge Cases & Error Scenarios**

### **Edge-1 — Invalid Session During Use**

**Given** the user is using the authenticated application  
**When** the session becomes invalid, such as through token expiration or the account being disabled elsewhere  
**Then** the application shall route the user back to **SCR-03** with an explanatory message and shall not show broken or partial protected data.  
**(UC-SCR27-04)**

### **Edge-2 — Attempt to Access Another User's Data**

**Given** an attempt is made to access another user's data through a malformed request  
**When** the access request reaches the security boundary  
**Then** the request shall be rejected and the application shall not render another user's data.  
**(UC-SCR27-05)**

## **10\. Dependencies & Notes**

* **Screen entry/exit dependencies:** SCR-27 is a **global/cross-cutting state set**, not an independently navigated screen. It applies across authenticated screens in the application. Specific screen entry/exit points are **Not specified in Inventory — confirm with SRS/SDS owner**.  
* **\[ASSUMPTION\] flag:** No `[ASSUMPTION]` flag is attached to SCR-27 in the Inventory.  
* **Underspecified behavior:**  
  * The Inventory specifies that write actions may be **"blocked/queued-with-warning"**, but does not resolve which behavior shall be used. This must remain unresolved and be confirmed with the SRS/SDS owner.  
  * Exact error copy for the generic Firestore read failure, generic Firestore write failure, and invalid-session explanatory message is **Not specified in Inventory — confirm with SRS/SDS owner**.  
  * The Inventory does not provide SRS-FR IDs for UC-SCR27-01 through UC-SCR27-03; therefore, no SRS-FR mapping has been invented.  
  * The Inventory does not provide SRS-NFR IDs for UC-SCR27-01 through UC-SCR27-03; therefore, the applicable BRD/SDS trace has been preserved without inventing SRS-NFR mappings.  
* **Full-chain traceability summary:**

| Story Item | UC | SRS | SDS | BRD |
| ----- | ----- | ----- | ----- | ----- |
| FR-1 / NFR-1 | UC-SCR27-01 | SRS-FR/NFR not specified | SDS-ERR-5, SDS-ERR-6 | BR-NFR-020 |
| FR-2 / NFR-2 | UC-SCR27-02 | SRS-FR/NFR not specified | SDS-ERR-5 | Not specified in UC |
| FR-3 / NFR-3 | UC-SCR27-03 | SRS-FR/NFR not specified | SDS-ERR-6 | Not specified in UC |
| SEC-1 / Edge-1 | UC-SCR27-04 | SRS-NFR-8 | SDS-COMP-14 | BR-NFR-008/010 not explicitly mapped in this UC row |
| SEC-2 / Edge-2 | UC-SCR27-05 | SRS-NFR-8–10 | SDS-COMP-14 | BR-NFR-008/010 |

**UC coverage verification:** UC-SCR27-01 → FR-1 / NFR-1 / AC-1; UC-SCR27-02 → FR-2 / NFR-2 / AC-2; UC-SCR27-03 → FR-3 / NFR-3 / AC-3; UC-SCR27-04 → SEC-1 / Edge-1; UC-SCR27-05 → SEC-2 / Edge-2.

Since this is a **new architectural capability**, I would treat it as a separate Level-4 user story rather than pretending it is derived from the existing SCR-27 inventory. The story below keeps the scope to **Drift-based local persistence for workout plans and completed daily workout records**, plus local data consumption by History, Progress, and Statistics.

# **User Story — Local Data Persistence**

## **1\. User Story Identification**

* **Story ID:** US-LOCALDB-01  
* **Title:** Local Storage for Workout Plans and Workout Records  
* **Epic / Feature:** Local Data Persistence  
* **Priority:** High  
* **Story Points:** Not specified

## **2\. User Story Statement**

As a user, I want my workout plans and completed workout records to be stored locally on my device so that my workout history, progress, and statistics can be generated from my recorded workout data.

## **3\. Description / Context**

The Workout Tracker shall maintain local application data using a local database.

The local database shall store:

* Workout plans created by the user.  
* Workout records created from workouts performed by the user on each day.

The locally stored workout data shall be available to the application's History, Progress, and Statistics features.

Local persistence shall support the application's core workout-tracking lifecycle:

**Create Plan → Store Plan → Perform Workout → Store Workout Record → Read Historical Data → Calculate Progress / Statistics**

The local database is intended to provide persistent storage for workout-related data on the user's device.

## **4\. Functional Requirements**

* **FR-1** — The application shall persist each workout plan created by the user in the local database.  
* **FR-2** — The application shall persist the workout plan information required to reconstruct the user's saved workout plan.  
* **FR-3** — The application shall persist each completed workout record for each day on which the user performs a workout.  
* **FR-4** — Each persisted workout record shall retain the actual workout performance data required by the application, including the recorded exercise/set performance information.  
* **FR-5** — The application shall retain previously persisted workout records so that historical workout data remains available after subsequent workouts are performed.  
* **FR-6** — The application shall make persisted workout records available to the Workout History feature.  
* **FR-7** — The application shall make persisted valid workout records available to the Progress feature for progress comparison.  
* **FR-8** — The application shall make persisted valid workout records available to the Statistics feature for statistical calculations.  
* **FR-9** — The application shall distinguish completed workout records from workout sessions that were cancelled or otherwise not completed, so that only valid completed records are used where required by History, Progress, and Statistics.  
* **FR-10** — The application shall preserve historical workout performance data independently of subsequent changes to the associated workout plan.  
* **FR-11** — When a workout plan is edited, the updated plan data shall be persisted as the current workout plan without modifying previously recorded workout performance data.  
* **FR-12** — When a workout plan is deleted, previously recorded workout history associated with that plan shall remain available.

## **5\. Non-Functional Requirements**

* **NFR-1** — Local workout data shall persist between application launches.  
* **NFR-2** — Local workout data shall be retrievable by the application without requiring a network connection.  
* **NFR-3** — Local persistence operations shall not cause the application to lose previously persisted workout plans or completed workout records when an individual subsequent operation fails.  
* **NFR-4** — The local persistence mechanism shall support the volume of workout plans and daily workout records expected during normal MVP usage without imposing an artificial record-count limitation.  
* **NFR-5** — Local data access required by History, Progress, and Statistics shall return the persisted workout data consistently so that those features operate against the same underlying workout records.

## **6\. Security & Privacy Requirements**

* **SEC-1** — Workout plans and workout records stored locally shall belong to the user whose application data is being accessed.  
* **SEC-2** — The application shall not expose locally persisted workout data belonging to another user.  
* **SEC-3** — When application user data is cleared as part of an explicitly supported account-data removal operation, locally persisted workout plans and workout records shall not remain accessible through the application.

## **7\. UI / Component Specifications**

This story defines a persistence capability rather than a dedicated user-facing screen.

### **Workout Plan Data**

* **Component type:** Local persisted data entity  
* **Input type:** Workout plan data supplied through the Workout Plan Management flow  
* **Validation rules:** Existing workout-plan validation rules apply before persistence  
* **Min / Max constraints:** As defined by the Workout Plan Management requirements  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Workout plan data required for persistence is mandatory

### **Workout Record Data**

* **Component type:** Local persisted workout record  
* **Input type:** Actual workout performance captured during workout execution  
* **Validation rules:** Existing workout execution and completion rules apply  
* **Min / Max constraints:** As defined by workout execution requirements  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Completed workout record is mandatory when a workout is successfully completed

### **History / Progress / Statistics Data Consumption**

* **Component type:** Local data read source  
* **Input type:** Persisted workout records  
* **Validation rules:** Valid/completed workout records shall be used according to the requirements of each consuming feature  
* **Min / Max constraints:** Not specified  
* **Error messages:** Not specified  
* **Mandatory / Optional:** Required for History, Progress, and Statistics functionality

## **8\. Acceptance Criteria**

### **AC-1 — Workout Plan Persistence**

**Given** the user creates a valid workout plan  
**When** the workout plan is saved  
**Then** the workout plan shall be persisted in the local database and shall remain available after the application is closed and reopened.

### **AC-2 — Workout Plan Retrieval**

**Given** a workout plan has previously been persisted  
**When** the user accesses the workout plan management feature  
**Then** the previously saved workout plan shall be available as the user's current workout plan data.

### **AC-3 — Daily Workout Record Persistence**

**Given** the user completes a workout  
**When** the completed workout is saved  
**Then** a workout record for that completed workout shall be persisted locally with its recorded performance data.

### **AC-4 — Historical Record Retention**

**Given** the user has completed workouts on multiple days  
**When** the user accesses workout history  
**Then** the previously persisted completed workout records shall remain available as historical records.

### **AC-5 — History Data Consumption**

**Given** completed workout records exist in local storage  
**When** the user opens the Workout History feature  
**Then** the feature shall retrieve and display the applicable persisted workout records.

### **AC-6 — Progress Data Consumption**

**Given** sufficient valid completed workout records exist in local storage  
**When** the user opens the Progress feature  
**Then** the feature shall use the persisted valid workout records for progress comparison.

### **AC-7 — Statistics Data Consumption**

**Given** valid completed workout records exist in local storage  
**When** the user opens the Statistics feature  
**Then** the feature shall use the persisted valid workout records for statistical calculations.

### **AC-8 — Plan Modification Does Not Alter History**

**Given** a workout plan has previously been used to complete a workout  
**When** the user subsequently edits that workout plan  
**Then** the previously persisted workout record shall retain the actual performance data recorded when the workout was completed.

### **AC-9 — Plan Deletion Does Not Delete History**

**Given** completed workout records exist for a workout plan  
**When** the user deletes that workout plan  
**Then** the previously recorded workout history shall remain available.

### **AC-10 — Cancelled Workout Is Not Treated as Completed**

**Given** the user starts a workout but does not complete it  
**When** the workout session is cancelled or otherwise fails to meet completion requirements  
**Then** it shall not be treated as a valid completed workout record for Progress and Statistics.

## **9\. Edge Cases & Error Scenarios**

### **Edge-1 — Local Persistence Failure**

**Given** the application attempts to persist a workout plan or completed workout record  
**When** the local persistence operation fails  
**Then** the application shall not represent the data as successfully persisted.

**Error handling/message:** Not specified — confirm with Product/SDS owner.

### **Edge-2 — Existing Data Preservation**

**Given** previously persisted workout plans or workout records exist  
**When** a subsequent local persistence operation fails  
**Then** previously persisted data shall remain unaffected.

### **Edge-3 — Application Restart**

**Given** workout plans and completed workout records have already been persisted  
**When** the application is terminated and subsequently launched again  
**Then** the persisted data shall remain available to the application.

### **Edge-4 — Incomplete Workout**

**Given** a workout session does not meet the application's completion criteria  
**When** the session ends  
**Then** the resulting data shall not be treated as a valid completed workout record for Progress and Statistics.

## **10\. Dependencies & Notes**

* **Implementation technology:** Drift (typed SQLite) shall be used as the local database for this capability.  
* **Primary data persisted:**  
  * Workout Plans  
  * Completed Workout Records  
* **Primary consumers:**  
  * SCR-20 — Workout History List  
  * SCR-21 — Workout History Detail  
  * SCR-22 — Progress Comparison  
  * SCR-23 — Statistics Dashboard  
  * SCR-24 — Personal Bests  
* **Related existing flows:**  
  * Workout Plan Management (SCR-08–SCR-11) creates and modifies workout-plan data.  
  * Workout Execution (SCR-15–SCR-19) creates completed workout records.  
  * Workout History (SCR-20–SCR-21) reads workout records.  
  * Progress (SCR-22) reads valid completed workout records.  
  * Statistics (SCR-23–SCR-24) reads valid completed workout records.  
* **Architecture:** Drift is the local database for workout plans and workout records; the application has no remote data store. The SDS/SRS/BRD architecture and traceability documents should reflect this before this story is treated as implementation-locked.  
* **Data synchronization:** Not specified. This story defines local persistence only and does not introduce cloud synchronization.  
* **Backup / restore:** Not specified.  
* **Data migration/versioning:** Not specified.  
* **Local database encryption:** Not specified.  
* **Retention/deletion policy:** Not specified beyond the requirement that deleting a workout plan does not delete its historical workout records.  
* **Important design decision:** Historical workout records must represent the actual workout performed at the time of completion rather than dynamically reflecting later changes to the workout plan.  
* **Traceability:** This is a **new Level-4 user story introduced from the requested architecture change**. Existing BRD → SRS → SDS → Inventory traceability IDs for local persistence are not currently present in the supplied Inventory. The upstream documents should be amended to establish the corresponding requirement IDs before assigning formal BRD/SRS/SDS traceability IDs to this story.

