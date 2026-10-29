# Feature Specification: SCR-03 Login / Authenticate

**Feature Branch**: `001-scr-03-login`

**Created**: 2026-09-15

**Status**: Draft

**Input**: User description: "create mobile specification for SCR-03 login"

---

## Clarifications

### Session 2026-09-15

- Q: Should leading/trailing whitespace in the email or password fields be trimmed before credential comparison? → A: Yes — trim both fields before comparison (Option A).
- Q: When should the "Email or password is incorrect" error message clear after being displayed? → A: Clear on the next keystroke in either field (Option A).
- Q: What form should empty-field validation take? → A: Initially confirmed as inline error text (2026-09-15). Superseded 2026-09-16 by button-disable model: Login button is disabled while either field is empty after trimming; inline empty-field errors are not reachable via submit.
- Q: Should the Login button be disabled until both fields are non-empty, or always tappable? → A: Disabled until both fields contain ≥1 non-whitespace character (button-disable model — 2026-09-16).
- Q: Should the password field include a show/hide toggle? → A: Yes — in scope, the toggle is mandatory (Option A).

---

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Successful Login with Valid Credentials (Priority: P1)

A user opens ForgeApp after it has been locked. They see the Login screen and enter their correct email address and password. On tapping "Sign In", the app instantly verifies the credentials locally and navigates to the Home Dashboard.

**Why this priority**: This is the gate to the entire app. Without a working happy path, no other feature is accessible. It is the most critical flow.

**Independent Test**: Navigate to the Login screen (app locked state), enter the known-good demo credentials, tap Sign In, and confirm arrival at the Home Dashboard.

**Acceptance Scenarios**:

1. **Given** the app is locked and the Login screen is visible, **When** the user enters the correct email and correct password and taps Sign In, **Then** the app unlocks and navigates to the Home Dashboard (SCR-06).
2. **Given** the user is on the Login screen, **When** valid credentials are submitted, **Then** the transition to the Home Dashboard is immediate (no loading spinner or network wait).

---

### User Story 2 — Rejected Login with Wrong Credentials (Priority: P1)

A user enters an incorrect email or password. The app stays on the Login screen and shows a clear error message so the user knows their credentials are wrong.

**Why this priority**: Incorrect-credential rejection is the direct counterpart to the happy path and must be equally reliable. Without it, the access guard has no meaning.

**Independent Test**: Enter a wrong password on the Login screen, tap Sign In, and verify the error message appears and the screen does not navigate away.

**Acceptance Scenarios**:

1. **Given** the app is locked, **When** the user enters any email/password combination that does not match the local demo credential, **Then** the Login screen remains visible and the error message "Email or password is incorrect" is shown.
2. **Given** the wrong-credentials error is displayed, **When** the user types any character in either field, **Then** the error message disappears immediately without requiring a re-submission.
3. **Given** the wrong-credentials error is displayed and then dismissed by typing, **When** the user submits valid credentials, **Then** the app navigates to the Home Dashboard with no error visible.

---

### User Story 3 — Blocked Submission When Fields Are Empty (Priority: P2)

A user has not yet typed anything (or only whitespace) in one or both fields. The Login button is visually disabled and cannot be tapped, preventing any submission attempt.

**Why this priority**: Button-disable is a proactive safeguard — it prevents an invalid submit before it happens, with no error message needed. Lower priority than the credential check but a clear usability guardrail.

**Independent Test**: Open the Login screen; confirm the Login button is in its disabled visual state. Type one character in each field; confirm the button becomes enabled.

**Acceptance Scenarios**:

1. **Given** both fields are empty (screen just opened), **When** the user views the Login button, **Then** the button is disabled and not tappable.
2. **Given** only the password field is empty, **When** the user views the Login button, **Then** the button remains disabled.
3. **Given** only the email field is empty, **When** the user views the Login button, **Then** the button remains disabled.
4. **Given** both fields contain at least one non-whitespace character, **When** the user views the Login button, **Then** the button is enabled and tappable.
5. **Given** a field appears to have content but contains only whitespace, **When** the system evaluates the field (after trimming), **Then** it is treated as empty and the button remains disabled.

---

### Edge Cases

- What happens when the user enters leading or trailing whitespace in either field? → **Resolved (2026-09-15):** Both fields are trimmed before comparison. A whitespace-only value is treated as empty and blocks submission.
- What happens when the user taps Sign In multiple times very rapidly? (Expected: only one comparison executes; the screen does not navigate multiple times.)
- Can the user navigate back from the Login screen to the Splash or to any authenticated screen without credentials? (Expected: no — the app-lock guard prevents all authenticated routes while locked.)
- What is the behaviour for a malformed email format (e.g., missing "@")? The story flags this as an open question: the non-empty-only validation rule in FR-4 of SCR-01 implies format is *not* checked, but SCR-03's own EC-1 notes the tension. Behaviour must be confirmed and implemented consistently.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Login screen MUST be presented whenever the app-lock state is "locked" and the user reaches the authentication boundary.
- **FR-002**: The screen MUST provide an email field and a password field as the sole input mechanism for credentials.
- **FR-003**: The system MUST compare submitted credentials against the single static local demo credential (email + password pair) stored on the device; no network call is made.
- **FR-004**: The system MUST trim leading and trailing whitespace from both the email and password fields before any validation or comparison is performed. A field that is non-empty only due to whitespace (i.e., whitespace-only after trimming) MUST be treated as empty. Email format validation beyond non-empty is out of scope unless a governing decision introduces it.
- **FR-005**: On a matching credential pair, the system MUST set the app-lock state to "unlocked" and navigate to the Home Dashboard (SCR-06).
- **FR-006**: On a non-matching credential pair where both fields are non-empty (after trimming), the system MUST keep the Login screen visible and display the error message "Email or password is incorrect". The error MUST clear automatically as soon as the user types any character in either field.
- **FR-007**: The system MUST NOT display which field is incorrect (email or password) — the error message is non-specific by design, to avoid revealing which half of the credential pair is wrong.
- **FR-008**: The Login button MUST be disabled (not tappable, visually distinct) when either field is empty after trimming. The button becomes enabled only when both fields contain at least one non-whitespace character, evaluated live on each keystroke. Empty-field inline error messages ("Email is required" / "Password is required") are therefore not shown via submit — the button-disable state prevents submission entirely. *(Updated 2026-09-16 — button-disable model adopted.)*
- **FR-009**: The Login screen MUST NOT be reachable from any authenticated screen via back navigation — the app-lock guard removes it from the back stack once unlocked.
- **FR-010**: Credential comparison MUST be entirely local; no backend, API, or network request is involved at any point.
- **FR-011**: The password field MUST be masked (characters hidden) by default and MUST include a show/hide toggle that reveals or re-masks the entered characters. Toggling visibility MUST NOT alter the field value or reset the cursor position.

### Key Entities

- **App Lock State**: A local boolean flag indicating locked (Login required) vs. unlocked (authenticated). Toggled by successful login and by logout. Persisted locally across app restarts.
- **Demo Credential**: A single static email + password pair stored locally on the device as the sole authentication reference. It is not a real secret and is not managed as one.

---

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user with the correct demo credentials can reach the Home Dashboard in under 2 seconds of tapping Sign In, measured from tap to first frame of the Home Dashboard.
- **SC-002**: 100% of submissions with mismatched credentials display the error message "Email or password is incorrect" and do not navigate away from the Login screen.
- **SC-003**: 100% of submissions with any empty field are blocked at the form level before a credential comparison is attempted.
- **SC-004**: Zero authenticated screens are reachable from any navigation path while the app-lock state is "locked".
- **SC-005**: The credential comparison produces a deterministic result — the same input always produces the same outcome — on every device restart and across consecutive app sessions.

---

## Assumptions

- The demo credential (email + password) is a single, hardcoded pair defined once for the app; there is no credential management UI and no way for the user to change it.
- Email format is validated only for non-emptiness (consistent with SCR-01 FR-4); stricter format checks (RFC 5322 compliance, "@" presence) are not required at this stage.
- Password is masked by default; a show/hide toggle is in scope and mandatory (see FR-011).
- The Login screen is the only entry point to the authenticated app — there are no alternative authentication methods (biometrics, SSO, magic link) in scope.
- The app-lock state persists across app restarts; a user who was locked before closing the app remains locked on relaunch.
- Accessibility (TalkBack/VoiceOver) is in reduced scope per ADR-028; touch-target sizing and contrast are observed as best effort, not as a mandatory acceptance gate.
- ForgeApp has a single fixed dark theme (ADR-037); the Login screen follows this theme without a light-mode alternative.
- There is no account-lockout or rate-limiting mechanism — this is a local POC credential, not a production authentication system.
