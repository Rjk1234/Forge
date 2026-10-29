# Design Specification: SCR-26 — Confirm Logout

**Created**: 2026-09-13  
**Status**: Draft  
**Artboard reference**: https://claude.ai/code/artifact/85ccb11f-db55-4312-a70a-9d63287ec4a4  
**User story**: `Doc/UserStories/SCR-26-Confirm-Logout.md`

---

## 1. Overview & Goal

SCR-26 is a confirmation modal that appears when the user taps "Log Out" from the SCR-25 Profile screen. It gives the user a single opportunity to confirm or cancel before the logout action is committed. The modal communicates clearly that logout is a session action — the app locks — and explicitly reassures the user that no workout data is deleted. This addresses SR-2: logout resets the local login-state flag only and does not touch the Drift database.

**Screen type**: Modal overlay (not a pushed screen). SCR-25 remains visible behind a dark scrim.  
**States**: 1 (Main only — no Loading, Error, or Validation states by design).  
**Entry**: Tapping the "Log Out" row in SCR-25.  
**Exit**:
- Cancel → pop modal, return to SCR-25 (no state change)
- Confirm → reset login-state flag → navigate to SCR-01 (app-lock PIN entry) or SCR-03 (if no PIN is configured)

---

## 2. User Flow

```
SCR-25 Profile
  └─ Tap "Log Out" row
       └─ SCR-26 Confirm Logout modal (over dimmed SCR-25)
            ├─ Tap "Cancel"  → dismiss modal → back to SCR-25 (unchanged)
            └─ Tap "Log Out" → reset login flag → navigate to SCR-01 / SCR-03
```

No intermediate loading state is shown. Logout is a local flag reset — it is synchronous and cannot fail. The screen exits immediately on confirm tap.

---

## 3. Screen-by-Screen Breakdown — ALL States

### 3.1 Main (only state)

The modal is rendered as an absolute overlay on top of a frozen, dimmed rendering of SCR-25.

#### Background layer (SCR-25 dimmed)

The Profile appbar and content are rendered at reduced opacity to establish visual depth beneath the scrim:

| Layer | Opacity / filter |
|---|---|
| appbar | `opacity: 0.3` |
| content | `opacity: 0.2; filter: grayscale(0.4)` |

The background is non-interactive while the modal is open.

#### Scrim

```
position: absolute
inset: 0                            ← covers full phone canvas
background: rgba(10, 10, 10, 0.62)
display: flex
align-items: center
justify-content: center
padding: 0 30px                     ← horizontal margin for the dialog
```

#### Dialog container

```
width: 100%                         ← fills scrim width minus 30px padding each side → ~330px
background: #201f22                 ← color.card
border: 1px solid #444933           ← color.border
border-radius: 18px                 ← NEW — radius.dialog (see §8)
padding: 24px 20px
display: flex
flex-direction: column
align-items: center
text-align: center
gap: 10px
```

#### dialog-icon-wrap

```
width: 52px
height: 52px
border-radius: 50%
background: #2a2a2c                 ← color.cardAlt
display: flex
align-items: center
justify-content: center
margin-bottom: 2px
```

Contains the dialog-icon:

```
width: 24px
height: 24px
color: #c4c9ac                      ← color.muted
stroke-width: 1.8
```

SVG: logout/door-with-arrow icon:

```svg
<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
<path d="M16 17l5-5-5-5"/>
<path d="M21 12H9"/>
```

(Same icon path as SCR-25 logout-row but larger — 24px vs 16px — and muted colour vs danger.)

#### dialog-title

```
font-size: 16px
font-weight: 800
color: color.white (#f5f6f1)        ← inherited
```

Copy: **"Log out?"**

#### dialog-sub

```
font-size: 13px
color: #c4c9ac                      ← color.muted
line-height: 1.5
```

Copy: **"You'll need to unlock the app again to continue. Your workout data stays right where it is."**

The sub-copy explicitly calls out data preservation. This is load-bearing UX copy — do not paraphrase or shorten in engineering.

#### dialog-actions

```
display: flex
gap: 10px
width: 100%
margin-top: 8px
```

Two equal-width buttons:

##### Cancel button

```
flex: 1
border-radius: 10px                 ← radius.dialogButton (established)
padding: 13px
text-align: center
font-weight: 800
font-size: 13px
background: #2a2a2c                 ← color.cardAlt
color: #f5f6f1                      ← color.white
border: 1px solid #444933           ← color.border
```

Copy: **"Cancel"**  
Action: dismiss modal, return to SCR-25.

##### Log Out button

```
flex: 1
border-radius: 10px                 ← radius.dialogButton (established)
padding: 13px
text-align: center
font-weight: 800
font-size: 13px
background: #ff6b6b                 ← color.danger
color: #2a1010                      ← NEW — color.dangerDark (see §8)
/* no border */
```

Copy: **"Log Out"**  
Action: reset login-state flag → route to SCR-01 (or SCR-03 if no PIN).

---

## 4. Interactions & Behavior

| Trigger | Behaviour |
|---|---|
| Tap Cancel | Dismiss modal (pop). SCR-25 returned to foreground, fully interactive, no state changes. |
| Tap Log Out | Reset local login-state flag synchronously. Navigate to SCR-01 (app-lock PIN entry) or SCR-03 (if no PIN configured). SCR-25 and SCR-26 are removed from the navigation stack. |
| Tap scrim (outside dialog) | **Assumption**: treated as Cancel (dismiss). Not artboarded — confirm with designer (OQ-1). |
| Back gesture (swipe-back / hardware back) | **Assumption**: treated as Cancel (dismiss). Not artboarded — confirm (OQ-2). |

Logout is a local, synchronous operation. There is no network call, no loading spinner, and no error state. The confirm tap exits immediately.

---

## 5. Edge Cases & Error Handling

| Scenario | Handling |
|---|---|
| User taps Log Out | Login-state flag reset; navigate away. No confirmation animation required by design. |
| User taps Cancel | Modal dismissed; no side effects. |
| Drift data on logout | **Not deleted** — SR-2 is explicit: Drift tables are preserved. Profile, exercise catalogue, workout plans, sessions all remain intact. |
| Error resetting login-state flag | No failure state is designed (Inventory has no Error UC row for SCR-26). If the flag reset can fail in the implementation, engineering must handle it silently or surface a generic error — this requires a design decision (OQ-3). |
| Multiple rapid taps on Log Out | Debounce the confirm tap to prevent duplicate navigation events. |
| Accessibility: dismiss on back gesture | Should Cancel — consistent with tap-outside behaviour (OQ-2). |

---

## 6. Responsive & Platform Considerations

| Concern | Spec |
|---|---|
| Dialog width | `100%` within scrim padding of `30px` per side → effective dialog width ≈ 330px on a 390px canvas. |
| Longer copy on smaller screens | Sub-copy is 2 sentences (~18 words). No truncation risk down to 320px. |
| Dialog height | No max-height constraint needed — content is fixed (icon + title + sub + two buttons). |
| Button width | Both `flex:1` — equal width regardless of label length. |
| Tap targets | Both buttons: `padding:13px` vertical → ~39px tappable height. Below 44pt iOS guideline — flag for engineering (OQ-4). |
| Android back gesture | Should behave as Cancel (OQ-2). |
| Rotation | App is portrait-only — no landscape consideration needed. |

---

## 7. Accessibility

| Element | Requirement |
|---|---|
| Scrim / modal | Announce as alert dialog. Trap focus within the dialog while open. |
| dialog-icon | `excludeFromSemantics: true` — decorative. |
| dialog-title | Heading role or merged with modal announcement. "Log out?" is the dialog's accessible label. |
| dialog-sub | Static text read in sequence. Must not be hidden from screen readers. |
| Cancel button | Accessible label: "Cancel" |
| Log Out button | Accessible label: "Log Out" — danger colour alone is insufficient; text carries the meaning. |
| Focus order | dialog-icon-wrap → dialog-title → dialog-sub → Cancel → Log Out (or platform-natural order). |
| Scrim tap | Must not steal focus from the dialog; if treated as Cancel, announce modal dismissed. |
| Tap target height | Both buttons ~39px — below 44pt minimum. OQ-4 must be resolved before handoff. |

---

## 8. Component & Design System Mapping

### Components used (all pre-established)

| Element | Component / class |
|---|---|
| Scrim | Inline — overlay `position:absolute; inset:0; rgba(10,10,10,.62)` |
| Dialog container | **dialog** — new component (first alert dialog in system) |
| Icon circle | **dialog-icon-wrap** — new |
| Logout SVG | Reuses logout/door-with-arrow path from SCR-25 logout-row (different size + colour) |
| Title text | `16px/800` — matches err-title weight; no new token needed |
| Sub text | `13px/muted/line-height:1.5` — matches err-sub pattern |
| Cancel button | **dialog-btn.cancel** — new variant; uses card-alt + border pattern |
| Log Out button | **dialog-btn.logout** — new variant; danger fill |

### New tokens / values identified

| Value | Proposed token | Notes |
|---|---|---|
| `border-radius:18px` | `radius.dialog` | First alert-dialog radius in system; distinct from `radius.dialogButton` (10px) |
| `color:#2a1010` | `color.dangerDark` | Dark brownish-red; text on danger-red button. Analogous to `#131315` (text on lime). First use in system. |
| `rgba(10,10,10,.62)` | `color.scrim` | Modal backdrop; first scrim in system |

### Established tokens reused

| Value | Token |
|---|---|
| `#131315` | `color.bg` |
| `#201f22` | `color.card` |
| `#2a2a2c` | `color.cardAlt` |
| `#444933` | `color.border` |
| `#ff6b6b` | `color.danger` |
| `#c4c9ac` | `color.muted` |
| `#f5f6f1` | `color.white` |
| `border-radius:10px` | `radius.dialogButton` |

---

## 9. Acceptance Criteria Mapping

| ID | Criterion |
|---|---|
| AC-1 | Tapping "Log Out" in SCR-25 presents the modal with scrim, icon, title "Log out?", sub-copy, and two buttons. |
| AC-2 | SCR-25 content is visible behind the scrim at reduced opacity (`opacity:0.2; filter:grayscale(0.4)`) and is non-interactive. |
| AC-3 | Scrim background is `rgba(10,10,10,0.62)` covering the full screen. |
| AC-4 | Dialog has `background:card; border:1px solid border; border-radius:18px; padding:24px 20px`. |
| AC-5 | Dialog icon-wrap is `52×52; radius:50%; cardAlt bg`. Icon is `24×24; muted; stroke-width:1.8`. |
| AC-6 | Title "Log out?" renders at `16px/800`. |
| AC-7 | Sub-copy reads exactly: "You'll need to unlock the app again to continue. Your workout data stays right where it is." |
| AC-8 | Cancel button: `cardAlt bg; white text; border:1px solid border; radius:10px; padding:13px; 13px/800`. |
| AC-9 | Log Out button: `danger bg (#ff6b6b); color:#2a1010; radius:10px; padding:13px; 13px/800; no border`. |
| AC-10 | Tapping Cancel dismisses the modal and returns to SCR-25 with no state changes. |
| AC-11 | Tapping Log Out resets the local login-state flag and navigates to SCR-01 (or SCR-03 if no PIN). |
| AC-12 | Drift data (all tables) is NOT cleared on logout — only the login-state flag is reset. |
| AC-13 | SCR-25 and SCR-26 are removed from the navigation stack on confirm. |
| AC-14 | Log Out button tap is debounced to prevent duplicate navigation. |

---

## 10. Open Questions / Assumptions

### Assumptions made

- **A-1**: Tapping outside the dialog (on the scrim) is treated as Cancel. Not artboarded; consistent with standard modal behaviour.
- **A-2**: Android hardware back / iOS swipe-back on the modal is treated as Cancel.
- **A-3**: Logout is synchronous (local flag reset only) — no loading state or spinner required.
- **A-4**: If no PIN is configured, logout routes to SCR-03 (create PIN / onboarding entry) rather than SCR-01 (PIN entry).

### Open questions

| ID | Question | Blocking? |
|---|---|---|
| OQ-1 | Does tapping the scrim (outside the dialog) dismiss the modal (Cancel)? | Yes — affects interaction contract |
| OQ-2 | Does Android back gesture / iOS swipe-back on the modal cancel (dismiss) or block? | Yes — platform behaviour |
| OQ-3 | If the login-state flag reset fails (implementation edge case), is a generic error shown, or is it silent? | No — no failure state designed; engineering decision |
| OQ-4 | Both buttons have `padding:13px` → ~39px tap height, below 44pt iOS/Android minimum. Increase to `padding:15px` or add `min-height:44px`? | Yes — accessibility requirement |
| OQ-5 | Exact routing on logout: always SCR-01 (PIN entry), or conditional on whether a PIN is set? | No — implementation decision; spec assumes conditional |
| OQ-6 | Modal entry animation: fade-in + slide-up (standard), or instant? | No — detail for engineering |
