# Design Specification — SCR-03 Login (Authenticate Existing User)

**Story ID**: US-SCR-03  
**Flow**: FLOW-01 — Authentication (Static / Demo Login)  
**Status**: Draft  
**Created**: 2026-09-10  
**Design System Source**: `Doc/DESIGN-SYSTEM.md` · `Doc/forgeapp-design-system.html`  
**User Story Source**: `Doc/UserStories/SCR-03-Login-Authenticate.md`  
**Inventory Source**: `Doc/Screen_Flow_Use_Case_Inventory_v1.1.1.md` §3

> **Figma reference**: No Figma file URL was provided. All component and token references in this document pull from the `Doc/DESIGN-SYSTEM.md` canonical reference. When a Figma file is linked, cross-check the frame named **`SCR-03/Login`** (or the FLOW-01 frame family) and reconcile any values that differ from this document.

---

## 1. Overview & Goal

### Problem Being Solved

ForgeApp is fully offline and has exactly one local user per device install. The app still needs a credible lock/unlock boundary — so the user "plays through" a login-like flow before accessing their workout data. SCR-03 provides that boundary using a static, hardcoded demo credential checked entirely on-device. There is no real authentication service, no account registry, and no network call of any kind.

### Who the User Is

A single local user of the app on their own Android or iPhone. There is no multi-user concept, no roles, and no permission tiers. The user will interact with this screen:

- On every cold launch (the app always starts locked)
- After logging out from the Profile screen (SCR-26)

### Primary Success Metric / Outcome

> The user enters the correct demo credentials and reaches SCR-06 — Home Dashboard in one uninterrupted attempt, with no confusion about why they are on this screen.

Secondary metric: a user who enters wrong credentials or a malformed email receives a clear, inline error message and is able to correct and resubmit without restarting the app.

---

## 2. User Flow

### Entry Points

| Entry | Condition | Originating screen |
|---|---|---|
| Cold launch | App always starts in locked state | SCR-01 — Splash (routes here when lock flag = LOCKED) |
| Post-logout | User confirmed logout | SCR-26 — Logout Confirmation (routes here after clearing the in-memory lock flag) |

There is no deep link, push notification, or QR entry path into this screen.

### Step-by-Step Flow (All Paths)

```
[App cold launch]
       │
       ▼
  SCR-01 Splash
  (checks in-memory lock flag)
       │
       ├─ flag = UNLOCKED ──────────────────────► SCR-06 Home Dashboard
       │
       └─ flag = LOCKED ─────────────────────────► SCR-03 LOGIN SCREEN
                                                          │
                                    ┌─────────────────────┤
                                    │                     │
                              [Empty fields]        [After failed attempt]
                              User types email       Error banner visible;
                              + password             user edits a field → banner clears
                                    │
                                    ▼
                             Taps "Login"
                                    │
                         ┌──────────┴──────────┐
                         │                     │
                   Validation fails       Validation passes
                  (empty field or         (non-empty, email-shaped)
                  bad email format)              │
                         │                      ▼
                  Inline error          Credential comparison
                  shown below           (local string match,
                  failing field         instantaneous)
                  [remain on screen]         │
                                   ┌─────────┴────────┐
                                   │                  │
                             MATCH ✓            NO MATCH ✗
                                   │                  │
                             Set lock flag      Show banner:
                             = UNLOCKED         "Email or password
                                   │            is incorrect"
                                   ▼            [remain on screen]
                             SCR-06 Home Dashboard
```

### Exit Points

| Exit | Trigger | Destination |
|---|---|---|
| Successful login | Credentials match | SCR-06 — Home Dashboard |

There is no back navigation, no cancel, no alternative exit. The user cannot leave this screen except by successfully logging in (or force-quitting the app).

---

## 3. Screen-by-Screen Breakdown

> SCR-03 is a single screen with four distinct UI states. Each state is described below.

### 3.1 Screen Layout (All States Share This Structure)

```
┌─────────────────────────────────────────────────┐
│  Safe area inset (top)                          │
│                                                 │
│         ┌──────────────┐                        │
│         │  App logo /  │  ← centered, top third │
│         │  Brand mark  │                        │
│         └──────────────┘                        │
│                                                 │
│  "Welcome back"          ← Page Title (22px/800)│
│  "Sign in to continue"   ← Body Regular (muted) │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │  Email                                  │    │  ← Input field
│  └─────────────────────────────────────────┘    │
│  [error message if applicable]                  │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │  Password                         🔒 👁 │    │  ← Input field + show/hide toggle
│  └─────────────────────────────────────────┘    │
│  [error message if applicable]                  │
│                                                 │
│  [Credential error banner — only when shown]    │
│                                                 │
│  ┌─────────────────────────────────────────┐    │
│  │              Login                      │    │  ← Primary button
│  └─────────────────────────────────────────┘    │
│                                                 │
│  Safe area inset (bottom)                       │
└─────────────────────────────────────────────────┘
```

**Layout rules:**
- Background: `color.bg` (`#131315`)
- Content centered vertically in the lower two-thirds of the screen (logo occupies upper third)
- Horizontal padding: 20px from screen edges (safe-area-aware)
- Vertical spacing between form elements: 12px gap between label group, 20px above the Login button
- No scroll — all content fits within the viewport on all target phone sizes
- No app bar, no bottom navigation bar (pre-login screen)

---

### 3.2 State — Default (Empty Fields) · UC-SCR03-01

**Trigger**: Screen first opens (cold launch routed from SCR-01, or post-logout from SCR-26).

**What the user sees:**
- Both fields empty, no error state
- Login button visible but **disabled** (both fields are empty on open; button becomes enabled once both fields contain at least one non-whitespace character)
- Keyboard not shown (user must tap a field to invoke it)

**Component specs:**

| Element | Token / Value |
|---|---|
| Screen background | `color.bg` `#131315` |
| Email field fill | `color.cardAlt` `#2a2a2c` |
| Email field border | `color.border` `#444933`, 1px |
| Email field corner radius | 12px |
| Email field height | 44px |
| Password field | Same as email |
| Field label / placeholder | "Email" / "Password" — `color.textDim` `#8a8f7a`, 13px/600 |
| Login button fill (enabled) | `color.lime` `#c3f400` |
| Login button fill (disabled) | `color.cardAlt` `#2a2a2c` |
| Login button text (enabled) | "Login" — `color.bg` `#131315`, 14px/700, 10px radius |
| Login button text (disabled) | "Login" — `color.dim` `#8a8f7a`, 14px/700, 10px radius |
| Login button height | 48px (full width) |
| Login button enable condition | Both email and password fields contain ≥1 non-whitespace character (live check on each keystroke) |

**Microcopy:**
- Screen heading: **"Welcome back"** (22px/800, `color.white`)
- Sub-heading: **"Sign in to continue"** (13px/600, `color.textMuted`)
- Email placeholder: **"Email"**
- Password placeholder: **"Password"**
- Button label: **"Login"**

---

### 3.3 State — Validation Error (Field-Level) · UC-SCR03-02

**Triggers:**
- User taps Login with the email field empty (or whitespace-only after trimming)
- User taps Login with the password field empty (or whitespace-only after trimming)

**What the user sees:**
- The failing field's border switches from `color.border` to `color.danger` (`#ff6b6b`)
- An 11px/600 red helper text line appears directly below the failing field
- The Login button remains tappable — errors update on each subsequent tap
- If both fields fail simultaneously, both error messages appear at once (not sequentially)

**Error message copy:**

| Condition | Error text (shown below the field) |
|---|---|
| Email field empty | **"Email is required"** |
| Password field empty | **"Password is required"** |

> **Note (resolved 2026-09-16):** Email format validation (checking for `@` / domain) is NOT performed. Non-empty-only validation applies — any non-blank string is accepted as the email input. A non-empty but invalid-format email that does not match the credential will fail at the credential-comparison stage and show the mismatch banner instead.

**Error message token:** `color.danger` `#ff6b6b`, 11px/600, appears 4px below the field border

**Dismissal rule:** Error message below a field disappears as soon as the user begins editing that field (on first keystroke). The other field's error, if any, remains until that field is edited.

---

### 3.4 State — Credential Mismatch Error · UC-SCR03-05

**Trigger**: User taps Login, both fields pass format validation, but the email+password combination does not match the static credential.

**What the user sees:**
- Field-level validation clears (fields are not individually flagged)
- An error banner appears between the password field and the Login button
- Fields remain editable; the Login button remains tappable

**Banner component spec:**

| Element | Token / Value |
|---|---|
| Banner fill | `color.dangerBg` `#2a1f1f` |
| Banner border | `color.dangerBorder` `#5c3a3a`, 1px |
| Banner corner radius | 12px |
| Banner padding | 12px horizontal, 10px vertical |
| Icon | Warning/Error line icon, 20×20, `color.danger` |
| Message text | `color.danger` `#ff6b6b`, 13px/600 |

**Microcopy:**
- Banner message: **"Email or password is incorrect"**

**Dismissal rule:** The banner disappears as soon as the user edits either the email or password field (on first keystroke in either field).

**Note:** The banner does NOT appear for field-level failures (empty or badly formatted) — those show the inline helper-text pattern instead. The banner is only for a credential mismatch after valid-format credentials are submitted.

---

### 3.5 State — Success · UC-SCR03-04

**Trigger**: Email and password both pass format validation AND match the static credential.

**What the user sees:**
- The Login screen slides out / transitions to SCR-06 Home Dashboard (see §4 for transition spec)
- No toast, no confirmation dialog — the navigation itself is the success signal

**Data written:** The in-memory app-lock flag is set to UNLOCKED. Nothing is written to the database. The credential values are never stored.

---

### 3.6 State — Loading · UC-SCR03-03 (REMOVED — see §10 Open Questions)

The Screen Inventory (UC-SCR03-03) originally listed a "Loading" state. The User Story (SCR-03, updated 2026-09-05) explicitly removed it: the local string comparison is instantaneous and does not require a visible loading indicator.

**Decision for this design spec:** No loading state is designed. If a perceptible delay is ever introduced (e.g. a deliberate artificial pause), this state should be revisited. See §10, Open Question OQ-1.

---

### 3.7 Data Requirements

| Data item | Source | Format / Notes |
|---|---|---|
| Static credential (email) | Compile-time constant in app source | `user@forge.app` — never displayed to the user |
| Static credential (password) | Compile-time constant | `Forge@123` — never displayed, never logged |
| In-memory app-lock flag | Runtime state (AppLockCubit / in-memory only) | LOCKED / UNLOCKED — never written to the database |

No dates, currency, or server-formatted data is shown on this screen.

---

## 4. Interactions & Behavior

### 4.1 Tappable / Interactive Elements

| Element | Gesture | Behavior |
|---|---|---|
| Email field | Tap | Field gains focus, system keyboard appears (email keyboard type — shows `@` key prominently on iOS/Android) |
| Email field | Long-press on content | System text selection menu (cut/copy/paste) |
| Password field | Tap | Field gains focus, keyboard appears (default keyboard); input masked (characters replaced by bullets) |
| Password field | Long-press on content | System text selection menu |
| Password show/hide toggle (eye icon) | Tap | Toggles password field between masked (secure text) and revealed (plain text) states; does not alter value or cursor |
| Login button | Tap | Run field validation → if fails: show inline errors, remain on screen; if passes: run credential check → navigate or show banner |
| Login button | Long-press | No action (same as single tap; no secondary behavior) |
| Credential error banner | Tap | No action (banner is informational only; not dismissable by tapping it) |
| Background (outside fields) | Tap | Dismiss keyboard (keyboard hides, focus clears) |

### 4.2 Keyboard Behavior

- **Email field** uses the email input type: system keyboard shows `@` and `.com` / domain shortcuts.
- **Return / Next key** on the email field moves focus to the password field.
- **Return / Done key** on the password field submits the form (equivalent to tapping the Login button).
- **Keyboard dismiss** (swipe down on iOS, back on Android): hides keyboard but does NOT clear error state. Any visible error banners remain.

### 4.3 Transitions & Animations

| Transition | Type | Duration | Notes |
|---|---|---|---|
| SCR-01 → SCR-03 (app launch, not logged in) | Fade or slide-up (match splash exit) | ~250ms | Determined by go_router route transition; no animation asset in this spec |
| SCR-26 → SCR-03 (post-logout) | Slide-in from left (replacing Home stack) | ~300ms | Should feel like returning to start, not pushing forward |
| SCR-03 → SCR-06 (successful login) | Slide-up (revealing Home Dashboard beneath) | ~300ms, ease-out | Conveys "unlocking" the app |
| Validation error appearance | Instant | 0ms | Errors appear immediately on tap; no animation delay |
| Credential error banner appearance | Fade in | ~150ms | Subtle entrance; not jarring |
| Banner dismissal on edit | Fade out | ~150ms | Matches appearance |

### 4.4 Form Validation Rules

| Rule | Trigger | Display location | Message |
|---|---|---|---|
| Email required | On Login tap (submit-time) | Below email field | "Email is required" |
| Password required | On Login tap (submit-time) | Below password field | "Password is required" |
| Credential mismatch | After both fields pass non-empty check | Banner between password field and Login button | "Email or password is incorrect" |

> **Email format validation removed (resolved 2026-09-16):** Non-empty-only validation applies to the email field. No `@` or domain check is performed.

**Validation order:**
1. Check email field (after trimming): empty → show email-required error.
2. Check password field (after trimming): empty → show password-required error.
3. If either step 1 or 2 produced an error, stop.
4. Both fields non-empty → run credential comparison.
5. Mismatch → show banner. Match → navigate.

If both fields are empty, show both inline errors simultaneously.

**Dismissal:** Each inline error clears on the first keystroke in the field it belongs to. The credential banner clears on the first keystroke in either field.

### 4.5 Feedback Mechanisms

| Mechanism | When used | Notes |
|---|---|---|
| Inline field error (helper text) | Field-level validation failure | 11px/600, `color.danger`, below the field |
| Credential error banner | Credential mismatch after valid format | `dangerBg` card, warning icon |
| Haptics | Not specified | Not required for this POC; no haptic feedback pattern is defined in the design system |
| Toast / snackbar | Not used on this screen | Success is signalled by navigation, not a toast |
| Confirmation dialog | Not used on this screen | No destructive action occurs here |

---

## 5. Edge Cases & Error Handling

### 5.1 Network / Server Errors

**Not applicable.** The credential check is a local string comparison with no network call, no timeout, and no server. The app is fully offline by design. There is no network failure state to design for on this screen.

### 5.2 Empty States

| Scenario | Behavior |
|---|---|
| First-time use (cold launch) | Fields empty, Login button tappable. No empty-state illustration needed — the blank fields are the expected default. |
| Post-logout | Identical to first-time use — fields reset to empty on each screen presentation. |
| App backgrounded and resumed (still locked) | Fields retain whatever the user typed before backgrounding (system behavior, no special handling required). |

### 5.3 Permission-Denied Scenarios

**Not applicable.** The login screen does not request camera, location, notifications, or any other runtime permission.

### 5.4 Boundary Conditions

| Condition | Behavior |
|---|---|
| Email field: whitespace-only input | Treated as empty after trimming — shows "Email is required" |
| Email field: leading/trailing spaces around valid address | Trimmed before format check and credential comparison — `" user@forge.app "` matches |
| Password field: whitespace-only input | Trimmed before empty-check — treated as empty, shows "Password is required" *(Updated 2026-09-16 — both fields trimmed)* |
| Very long email string | No max-length enforced at the UI level; system keyboard handles text truncation within the field |
| Very long password string | Same — no max-length enforced |
| Rapid repeated taps on Login | Each tap runs validation from current field state; no debounce or deduplication needed (no network call, no async operation) |
| Login tapped with keyboard open | Keyboard stays open, validation runs and errors display; keyboard does not auto-dismiss |

### 5.5 Offline / No-Connection State

**Not applicable.** There is no network dependency. No offline banner, no retry, no connectivity check.

---

## 6. Responsive & Platform Considerations

### 6.1 Device Sizes

ForgeApp targets Android phones and iPhones only. Tablets and iPads are **out of scope** for this POC (ADR-022).

| Device category | Behavior |
|---|---|
| Small phone (≤ 375px width, e.g. iPhone SE) | Content fits within viewport without scroll; form fields stack vertically at full width minus 20px padding each side |
| Standard phone (375–430px) | Primary design target; all measurements in this spec are for this range |
| Large phone (> 430px) | Layout remains centered; max-width constraint of ~400px on the form prevents fields becoming excessively wide |

### 6.2 Orientation

**Portrait is the primary and tested orientation.** Landscape is not explicitly supported for this POC. If the user rotates to landscape:
- The system keyboard will occupy a large fraction of the viewport
- The logo / brand area should collapse or hide to keep the form visible
- No special landscape layout is designed; this is a known limitation of the POC scope

### 6.3 iOS vs Android Differences

| Concern | iOS | Android |
|---|---|---|
| Keyboard return key | "Next" on email → moves to password; "Done" on password → submits | Same behavior (configure via `textInputAction` / IME action) |
| System back gesture | Not applicable (no back destination from login) | Android back button / gesture: **do nothing** (no-op) — user cannot navigate behind the login screen |
| Safe areas | Respect `SafeArea` insets (notch, Dynamic Island, home indicator) | Respect `SafeArea` insets (punch-hole camera, navigation bar) |
| Password autofill | iOS Keychain autofill suggestion may appear above keyboard | Android autofill service may suggest saved passwords |
| Keyboard type appearance | iOS email keyboard shows `.com` shortcut | Android may show slightly different layout — behavior is the same |

### 6.4 System Keyboard Overlap

When the keyboard is open, the Login button must remain visible above the keyboard fold. If necessary, the logo / brand block collapses or reduces vertical margin to keep the full form visible. The screen must NOT require the user to scroll to reach the Login button while the keyboard is open.

---

## 7. Accessibility

> Full WCAG 2.1 AA certification is explicitly out of scope for this POC (ADR-028). The requirements below reflect the reduced-scope accessibility baseline that is still expected.

### 7.1 Touch Target Sizes

| Element | Minimum touch target | Spec |
|---|---|---|
| Email field | 44 × 44 pt | Field height is 44px — meets minimum |
| Password field | 44 × 44 pt | Same |
| Login button | 44 × 48 pt | Button height is 48px — meets minimum |

### 7.2 Color Contrast

| Pair | Hex values | Ratio | Requirement |
|---|---|---|---|
| Login button text on lime | `#131315` on `#c3f400` | ~14:1 (high contrast) | Passes AA and AAA |
| Primary text on background | `#f5f6f1` on `#131315` | ~18:1 | Passes AA and AAA |
| Placeholder text on field | `#8a8f7a` on `#2a2a2c` | ~3.1:1 | Below AA for normal text (4.5:1) — acceptable for placeholder text at POC scope; flag for future improvement |
| Error text on background | `#ff6b6b` on `#131315` | ~5.7:1 | Passes AA |
| Error text on danger banner | `#ff6b6b` on `#2a1f1f` | ~4.8:1 | Passes AA |

### 7.3 Focus Order (Keyboard / Switch Navigation)

Logical tab/focus order for screen readers and switch access:

1. Screen heading ("Welcome back")
2. Email field
3. Password field
4. Login button

This order matches the visual top-to-bottom layout. No interactive elements exist outside this sequence.

### 7.4 Screen Reader (VoiceOver / TalkBack)

> Full screen-reader support is out of scope for this POC. The following are expected baseline behaviors, not certified requirements.

| Element | Semantic label |
|---|---|
| Email field | "Email, text field" |
| Password field | "Password, secure text field" |
| Login button | "Login, button" |
| Email inline error | Announced immediately when it appears (accessibility live region) |
| Credential error banner | Announced when it appears (accessibility live region) |

---

## 8. Component & Design System Mapping

> Design system source: `Doc/DESIGN-SYSTEM.md`. No Figma file URL provided — cross-check against the Figma frame **`SCR-03/Login`** when a file is linked.

### 8.1 Reused Components

| Component | Design System definition | Usage on SCR-03 |
|---|---|---|
| **Input field** | 44px height, 12px radius, `cardAlt` fill, 1px `border`; error state: `danger` border + 11px red helper text | Email field, Password field |
| **Primary button** | Lime fill `#c3f400`, dark text `#131315`, 10px radius, full-width | Login button |
| **Error card / banner** | `dangerBg` `#2a1f1f` fill, `dangerBorder` `#5c3a3a` 1px border, 12px radius, warning icon + `danger` text | Credential mismatch banner |
| **Inline validation helper** | 11px/600, `color.danger`, 4px below field border | Field-level error messages |
| **Typography: Page Title** | 22px/800, `color.white` | "Welcome back" heading |
| **Typography: Body Regular** | 13px/600, `color.textMuted` | "Sign in to continue" sub-heading; error message body |

### 8.2 New Components Required

| Component | Rationale |
|---|---|
| **Login screen layout (no app bar, no bottom nav)** | All designed screens (SCR-06 onward) use either the 6-tab root nav or the app-bar-with-back pattern. SCR-03 is pre-auth and uses neither — it is a standalone centered-form layout. This layout scaffold is unique to SCR-03 (and SCR-01) within the app and is not a reuse of any existing screen chrome. |
| **App logo / brand mark area** | No logo or brand asset is defined in the current Design System (which documents SCR-06–SCR-27 only). The logo treatment for the login screen needs to be designed and added to the Design System. See §10, Open Question OQ-2. |

### 8.3 Component Notes

- **No segmented control, chips, cards, or bottom nav** — none of those apply to this screen.
- **No skeleton / loading state** — the Design System loading pattern (skeleton blocks) is not used here because the credential check is instantaneous (see §3.6).
- **Password masking**: the password field uses the platform's secure text entry by default. A **show/hide toggle** (eye icon, right-aligned inside the field) is required — tapping it reveals the entered characters; tapping again re-masks. Toggling does not alter the field value or reset cursor position. *(Updated 2026-09-16 — toggle confirmed mandatory; OQ-3 closed.)*

---

## 9. Acceptance Criteria Mapping

Each acceptance criterion from `Doc/UserStories/SCR-03-Login-Authenticate.md` is mapped to the design section that satisfies it.

| AC from User Story | Screen state / design section that satisfies it |
|---|---|
| **AC-1** — Empty fields on first open | §3.2 Default State — fields rendered empty on screen entry (UC-SCR03-01) |
| **AC-3** — Correct credentials → route to SCR-06 | §3.5 Success State + §4.3 Transition (slide-up to Home Dashboard) (UC-SCR03-04) |
| **AC-4** — Wrong credentials → "Email or password is incorrect" | §3.4 Credential Mismatch Error State — credential error banner with exact copy (UC-SCR03-05) |
| **EC-1** — Malformed email → inline validation error | **Resolved 2026-09-16:** No format check performed. A non-empty malformed email passes field validation; mismatch banner shown after credential comparison. EC-1 is superseded. |
| **FR-1** — Empty fields on open | §3.2 Default State |
| **FR-2** — Email format validation before submit | **Resolved 2026-09-16:** Non-empty-only check; no format validation. See §4.4. |
| **FR-3** — (Loading state removed per 2026-09-05) | §3.6 — Not designed; see §10 OQ-1 |
| **FR-4** — Correct credentials → SCR-06 | §3.5 Success State, §4.3 Transitions |
| **FR-5** — Wrong credentials → generic error | §3.4 Credential Mismatch Error State |
| **SEC-1** — App routes to main screens only when unlocked | §2 User Flow — SCR-01 checks lock flag and routes here if locked; SCR-03 is the only path to unlock |
| **SEC-2** — Non-specific error message ("Email or password is incorrect") | §3.4 — exact copy specified; no enumeration of accounts |

---

## 10. Open Questions / Assumptions

### Assumptions Made in This Spec

| # | Assumption | Basis |
|---|---|---|
| A-1 | Validation fires on submit (Login tap), not on blur or on type. | User story FR-1 framing; constitution §VII requires pristine→dirty→valid/invalid states; on-submit is the simplest approach that satisfies all ACs. If on-blur validation is preferred, the spec must be updated. |
| A-2 | Both email and password fields: leading/trailing whitespace is trimmed before empty-check and credential comparison. A whitespace-only value in either field is treated as empty. *(Updated 2026-09-16 — password trimming confirmed as intended.)* | Prevents accidental trailing spaces from mobile keyboard auto-space; consistent behaviour across both fields. |
| A-3 | The Login button is **disabled** while either field is empty (zero characters after trimming). It becomes enabled only when both fields contain at least one non-whitespace character. Inline empty-field errors are therefore never reachable via submit — the button is not tappable in that state. *(Updated 2026-09-16 — OQ-4 resolved; button-disable model adopted.)* | Aligns with Screen Inventory UC-SCR03-01. Consistent with A-1 (validation still fires on tap for format/credential checks once both fields are non-empty). |
| ~~A-4~~ | **Resolved 2026-09-16** — Password show/hide toggle IS required (mandatory). See §8.3 and feature spec FR-011. | — |
| A-5 | No explicit max character length on either field. | User story does not specify; no UX problem arises from long strings in a local-match-only scenario. |
| A-6 | Post-logout routing (SCR-26 → SCR-03) replaces the entire navigation stack, not pushes onto it. Android back gesture has no effect from this screen. | Mandatory per no-back-navigation-to-main-screens security principle; lock flag is cleared on logout. |
| A-7 | Screen heading is "Welcome back" / "Sign in to continue". | Not specified in the user story; chosen to match the motivational tone of a workout app. Open for PM/designer sign-off. |
| A-8 | Single error banner for credential mismatch (not a field-level highlight on both fields). | The user story uses a generic "Email or password is incorrect" message — this is intentionally non-specific and should not highlight a specific field. |

### Open Questions

| # | Question | Impact if left unresolved | Owner |
|---|---|---|---|
| ~~**OQ-1**~~ | **Resolved 2026-09-16** — No loading state. In-memory flag comparison is instantaneous; no database write on login. UC-SCR03-03 may be removed from the Inventory. No artificial delay or spinner is added. | — | — |
| **OQ-2** | No logo or brand-mark asset is defined in the Design System (it only covers SCR-06–SCR-27). The login screen needs a logo treatment. What is the ForgeApp logo / wordmark, and what are its dimensions and placement rules? | Without a logo, the login screen will use a placeholder (e.g. "FORGE" wordmark in Page Title style). | Designer |
| ~~**OQ-3**~~ | **Resolved 2026-09-16** — Show/hide toggle is mandatory. §3.2, §8.3 updated. Eye icon right-aligned in the password field; toggles between masked and revealed states. | — | — |
| ~~**OQ-4**~~ | **Resolved 2026-09-16** — Button disabled until both fields contain ≥1 non-whitespace character. Disabled state: `cardAlt` fill, `dim` text. Empty-field inline errors are not reachable via submit. See §3.2 and component spec in §3.2. | — | — |
| ~~**OQ-5**~~ | **Resolved 2026-09-16** — Both fields are trimmed. A whitespace-only password is treated as empty → "Password is required" shown. | — | — |
| ~~**OQ-6**~~ | **Resolved 2026-09-16** — Copy approved: heading "Welcome back" (22px/800, `color.white`), sub-heading "Sign in to continue" (13px/600, `color.textMuted`). No update needed. | — | — |
