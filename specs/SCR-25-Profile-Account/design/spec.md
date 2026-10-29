# Design Specification: SCR-25 — Profile / Account

**Created**: 2026-09-13  
**Feature**: FLOW-10 Account — Profile / Account screen  
**Artboard reference**: https://claude.ai/code/artifact/d9763b67-d7b2-46f0-adcd-6b6617e84d9e  
**User story**: `Doc/UserStories/SCR-25-Profile-Account.md`  
**Entry**: SCR-06 (Home Dashboard) profile entry point  
**Exit**: Back → SCR-06 · Logout → SCR-26 (Logout Confirmation)

---

## 1. Overview & Goal

Profile / Account is a pushed detail screen where the user views and edits the four confirmed profile fields — display name, fitness goal, experience level, and height/weight — and accesses the logout action. All data is read from and written to Drift (local, offline-only). There is no server or connectivity condition.

**What problem it solves**: gives the user a single place to keep their identity and reference metrics current, and to end their local session.

**Primary success metric**: user successfully saves at least one field edit without encountering a blocking error; save confirmation toast is shown; updated values reflect on next screen open.

**Scope (from Decisions Log §8, confirmed 2026-09-05)**: exactly four fields (display name, fitness goal, experience level, height/weight) plus logout. No other profile fields are in scope for MVP.

---

## 2. User Flow

### Entry points
- **SCR-06 Home Dashboard** — profile entry point (avatar/icon tap or dedicated profile row; exact trigger element is on SCR-06, not this spec)

### Happy path
```
SCR-06 → tap profile entry point
  → [Loading] — Drift read in flight
    → [Main / Populated] — fields pre-filled from local storage
      → user edits one or more fields
        → tap "Save Changes" (all valid)
          → [Success] — "Profile saved" toast, fields reflect new values
```

### Alternate / branching paths

```
[Loading] → Drift read fails → [Error] → tap Retry → [Loading] → ...

[Main] → user enters invalid height/weight value
  → tap "Save Changes"
    → [Validation] — save blocked, inline errors shown
      → user corrects fields
        → tap "Save Changes" → [Success]

[Main] → tap "Log Out" → [SCR-26 Logout Confirmation]

[Any state] → tap back arrow → SCR-06
```

### Exit points
| Exit | Destination |
|------|-------------|
| Back arrow | SCR-06 Home Dashboard |
| Log Out tap | SCR-26 Logout Confirmation |
| Error → Retry | Re-enters Loading → Main or Error |

---

## 3. Screen-by-Screen Breakdown — ALL States

### Chrome (all 5 states)

| Element | Value |
|---------|-------|
| Status bar | `height:28px` |
| Appbar padding | `6px 20px 4px` (bottom 4px — pushed-screen standard) |
| Back arrow | `22×22; white; stroke-width:2; path M15 18l-6-6 6-6` |
| Title | "Profile"; `18px/800/.02em` (overlay/detail tier) |
| Navbar | ❌ absent — pushed screen, not a root tab |

---

### 3A. Loading State

Shown immediately on push while Drift reads the profile record.

**Content layout**

```
content { flex:1 1 auto; padding:16px 20px 24px; flex-col; gap:16px }
  sk-avatar           64×64; radius:50%; card-alt; translate-shimmer
  field-group × 4     each: sk-label (35% wide, 11px tall) + sk-field (44px tall)
```

**Skeleton elements**

| Element | Value |
|---------|-------|
| sk | base: `card-alt` (#2a2a2c); sheen: `rgba(255,255,255,.06)` |
| sk-avatar | `64×64; border-radius:50%; margin:4px auto 0` — centred |
| sk-field | `height:44px; border-radius:12px` — full-width within its column |
| sk-label | `width:35%; height:11px; border-radius:6px; margin-bottom:6px` |

**Shimmer variant** — translate (same as SCR-21/22/23):

```css
.sk::after {
  background: linear-gradient(90deg, transparent, rgba(255,255,255,.06), transparent);
  animation: shimmer 1.4s infinite;
}
@keyframes shimmer { 0%{ transform:translateX(-100%); } 100%{ transform:translateX(100%); } }
```

**Number of field-group skeletons**: 4 (one each for Display Name, Fitness Goal, Experience Level, Height+Weight). The Height+Weight pair (side-by-side in Main) shows as a single full-width sk-field in Loading — the paired layout is not skeleton-represented separately.

---

### 3B. Main State (Populated — Editable Profile)

Shown when Drift read succeeds. The form is immediately editable; no separate view/edit mode toggle.

**Content layout**

```
content { flex:1 1 auto; overflow-y:auto; padding:16px 20px 24px; flex-col; gap:16px }
  avatar-wrap
  field-group: Display Name    (text input)
  field-group: Fitness Goal    (select-style)
  field-group: Experience Level (segmented control)
  field-row-2: Height + Weight (2 numeric inputs side-by-side)
  save-btn                     "Save Changes"
  logout-row                   "Log Out"
```

**avatar-wrap**

```
avatar-wrap { flex-col; align-items:center; gap:8px; padding:4px 0 6px }
  avatar { 64×64; radius:50%; card-alt bg; border:1px solid border; flex; center }
    avatar-icon { 30×30; dim; stroke-width:1.6 }
      SVG: circle cx="12" cy="8" r="4"
           path M4 20c0-4 4-6 8-6s8 2 8 6
```

The avatar is a read-only display element (user icon, no photo). The `.avatar-name` CSS class is defined in the artboard but not rendered in any state — the display name is shown in the field below only.

**field-group pattern** (applies to Display Name, Fitness Goal, Experience Level)

```
field-group { flex-col; gap:6px }
  field-label  11px/700/dim/uppercase/letter-spacing:.04em
  [input element — varies by field type]
```

**Display Name — field-input (text)**

| Property | Value |
|----------|-------|
| Background | `card` (#201f22) |
| Border | `1px solid border` (#444933) |
| Border-radius | `12px` |
| Padding | `13px 14px` |
| Font | `14px/600` |
| Colour | `white` (default) |
| Content | Pre-filled display name (e.g. "Alex Rivera") |

**Fitness Goal — field-select (dropdown-style)**

Same container geometry as field-input, with `flex; align-items:center; justify-content:space-between`:

| Property | Value |
|----------|-------|
| Layout | same as field-input + `flex; justify-content:space-between` |
| Value text | Selected option (e.g. "Build Muscle") — `14px/600` |
| Trailing element | `chev-down` — `16×16; dim; stroke-width:2; M6 9l6 6 6-6` |
| Interaction | Tap opens picker (OQ-1 — exact mechanism not yet designed) |

Artboard sample option: "Build Muscle". User story suggests "Build muscle / Lose weight / General fitness" but exact option set is not confirmed (see OQ-1).

**Experience Level — segmented control (seg-row)**

```
seg-row { flex; gap:8px }
  seg × 3 { flex:1; text-align:center; card bg; border:1px solid border;
             border-radius:10px; padding:11px 6px; 12px/700; color:muted }
  seg.active { lime bg; #131315; border-color:lime }
```

Segments: "Beginner" · "Intermediate" · "Advanced" (exactly 3, fixed — from §7.4).  
Only one segment active at a time (single-select).

**Height & Weight — field-row-2**

```
field-row-2 { flex; gap:12px }
  field-group (Height) { flex:1 }
    field-label: "Height (cm)"
    field-input: numeric value (e.g. "178")
  field-group (Weight) { flex:1 }
    field-label: "Weight (kg)"
    field-input: numeric value (e.g. "76")
```

Units `cm`/`kg` are plausible defaults from the artboard — exact units must be confirmed (OQ-2).

**Save button — active state**

```
save-btn { margin-top:4px; width:100%; lime bg; #131315; border-radius:14px;
           padding:15px; text-align:center; 800/14px }
Label: "Save Changes"
```

**Logout row**

```
logout-row { margin-top:8px; flex; align-items:center; justify-content:center;
             gap:8px; padding:14px }
  logout-icon { 16×16; danger (#ff6b6b); stroke-width:2 }
    SVG: path M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4
         path M16 17l5-5-5-5
         path M21 12H9
  logout-label { 13px/700; danger }  "Log Out"
```

Logout is a text+icon row with no background card, no border. The danger colour signals it as a destructive/exit action, consistent with how the system reserves red for irreversible or session-exit actions (SCR-11, SCR-18).

---

### 3C. Validation State (Invalid Height/Weight — Save Blocked)

Shown after the user taps "Save Changes" with one or more invalid height/weight values. The form remains open; invalid fields are highlighted in-line.

**What triggers it**: height or weight field contains a negative number or non-numeric text.

**Changes from Main state**

All fields remain on screen (the artboard crops to show the invalid pair + save area). The form layout and other fields (Display Name, Fitness Goal, Experience Level) are identical to Main.

**Invalid field appearance**

| Property | Value |
|----------|-------|
| Border | `1px solid danger` (#ff6b6b) |
| Background | `#2a1f1f` (dangerFill — established SCR-20) |
| Text colour | `danger` (#ff6b6b) |

**Inline error message**

```
field-error { font-size:11px; font-weight:600; color:danger }
Copy: "Enter a valid positive number."
Position: below the invalid field-input, within the same field-group (gap:6px)
```

**Save button — disabled state**

```
save-btn (disabled) { card-alt bg; dim color; border:1px solid border;
                      border-radius:14px; padding:15px; text-align:center; 800/14px }
```

**Save note**

```
save-note { font-size:11px; color:dim; text-align:center; margin-top:-8px }
Copy: "Fix the highlighted fields to save."
```

The save note appears only in the validation state, directly below the disabled save button.

**Validation timing**: on save-tap (not on blur or on keystroke). Fields return to valid state (normal border/bg/colour) as soon as the value is corrected and the user taps Save again — or as soon as the field value becomes parseable as a positive number (OQ-6 — exact re-validation timing).

---

### 3D. Success State (Save Confirmation)

Shown after a successful Drift write. The profile form remains visible (not navigated away). A toast overlays the bottom of the screen.

**Form**: identical to Main state. Fields reflect the newly saved values.

**Toast**

```
toast { position:absolute; left:20px; right:20px; bottom:28px;
        background:#1e2a12; border:1px solid #4a5c22;
        border-radius:14px; padding:13px 16px;
        flex; align-items:center; gap:10px }
  toast-icon { 18×18; lime; stroke-width:2 }
    SVG: path M20 6L9 17l-5-5  (checkmark)
  toast-text { 13px/700 }  "Profile saved"
```

The toast is absolutely positioned over the content, not inside the scroll flow. After the toast auto-dismisses (OQ-7 — duration not specified in artboard), the screen returns to the Main state with updated field values.

---

### 3E. Error State (Read/Save Failure — Retry)

Shown when the Drift read fails on load, or when a Drift write fails on save.

**Content layout** (centered, not scrollable):

```
content { flex:1 1 auto; flex-col; align-items:center; justify-content:center;
          padding:0 32px; text-align:center; gap:14px }
  err-card
```

**err-card** — same pattern as SCR-20/21/22/23/24:

| Property | Value |
|----------|-------|
| Width | `100%` |
| Background | `card` (#201f22) |
| Border | `1px solid #5c3a3a` (dangerBorder) |
| Border-radius | `16px` |
| Padding | `26px 20px` |
| Layout | `flex-col; align-items:center; gap:12px` |

| Sub-element | Value |
|-------------|-------|
| err-icon | `40×40; danger (#ff6b6b); stroke-width:1.6` — alert-triangle SVG |
| err-title | `16px/800` — "Couldn't load your profile" |
| err-sub | `13px/muted; line-height:1.5` — "Something went wrong reading local data.\nRetry to try again — your saved profile is unaffected." |
| retry-btn | `lime bg; #131315; 800/13px; border-radius:10px; padding:11px 22px; margin-top:4px` |

> Note: "Couldn't load your profile" covers the Drift **read** failure on entry. The Drift **write** failure (save fails) is not separately artboarded — see OQ-8.

---

## 4. Interactions & Behavior

| Element | Trigger | Response |
|---------|---------|----------|
| Back arrow | Tap | Pop screen → SCR-06. Unsaved changes: OQ-9 |
| System back gesture (Android) | Swipe/hardware | Same as back arrow |
| Display Name | Tap | Focus text field; keyboard opens; cursor at end |
| Fitness Goal | Tap | Opens fitness-goal picker (OQ-1 — mechanism TBD) |
| Experience Level seg | Tap any seg | Activates tapped seg (lime bg); deactivates others |
| Height field | Tap | Focus numeric keyboard |
| Weight field | Tap | Focus numeric keyboard |
| Save Changes (active) | Tap | Validate all fields; if valid → Drift write → [Success]; if invalid → [Validation] |
| Save Changes (disabled) | Tap | No action — button is non-interactive in disabled state |
| Log Out | Tap | Navigate to SCR-26 (Logout Confirmation). Does NOT log out inline |
| Retry (Error) | Tap | Re-trigger Drift read; show [Loading] → [Main] or [Error] |
| Toast (Success) | Auto-dismiss | Toast fades out after N seconds (OQ-7); screen stays in Main |

**Transitions**:
- Screen push: standard platform push animation
- Loading → Main: cross-fade or instant
- Main → Success toast: toast slides up from bottom (OQ-10 — animation not specified in artboard)
- Validation: no transition — same screen state, fields instantly update styling
- Main → Error: cross-fade (load-path only); save-path error is not artboarded (OQ-8)

---

## 5. Edge Cases & Error Handling

| Scenario | Behaviour |
|----------|-----------|
| Drift read fails on entry | Error state: "Couldn't load your profile" + Retry |
| Drift write fails on save | Not artboarded — see OQ-8 |
| Height = negative number (e.g. "-178") | Validation: danger border, dangerFill bg, danger text, field-error below, save blocked |
| Weight = non-numeric (e.g. "abc") | Validation: same inline error pattern |
| Height = 0 | OQ-11 — treat as invalid or valid zero? |
| Height/Weight = very large value | OQ-12 — max bounds not specified |
| Display name = empty string | OQ-3 — not specified in Inventory |
| Display name = very long string | OQ-4 — truncation/max-length not specified |
| Fitness Goal picker dismissed without change | No change; field reflects previous value |
| Back arrow tapped with unsaved changes | OQ-9 — warn or silent discard? |
| Save Changes with no changes made | OQ-13 — should save be disabled when nothing changed? |
| Decimal value in height/weight (e.g. "76.5") | OQ-5 — allowed? |
| New user (first time, fields blank) | OQ-14 — empty field-inputs or placeholder text? |

---

## 6. Responsive & Platform Considerations

| Consideration | Detail |
|---------------|--------|
| Screen height | 390×844 reference. On shorter devices (iPhone SE: 375×667), form with all 5 sections + save + logout may not fit without scroll — `overflow-y:auto` ensures scroll works |
| Safe areas | Bottom safe area (home indicator): content `padding-bottom:24px` provides buffer. Toast `bottom:28px` clears the home indicator |
| Keyboard | Numeric keyboard for height/weight; text keyboard for display name. Screen should scroll to keep focused field visible above keyboard (Flutter default ScrollView behaviour) |
| No navbar | Pushed screen — no bottom nav bar on either platform |
| Back affordance | Explicit back arrow; Android hardware back also supported |
| iOS vs Android | No platform-specific UI differences observed in artboard. Fitness Goal picker mechanism may differ (iOS wheel picker vs. Android bottom sheet — OQ-1) |
| Segmented control | Three segments on a 390px viewport comfortably fit. On 320px-wide screens (very old iPhones) label text may clip — OQ-15 |

---

## 7. Accessibility

| Element | Requirement |
|---------|-------------|
| Back arrow | Semantic label: "Back" or "Back to Home" |
| avatar-icon | Decorative — `excludeFromSemantics: true` |
| field-label | Associated with its input via semantic grouping (label above input, not separate) |
| Display Name input | Role: text field; label: "Display Name" |
| Fitness Goal | Role: button or combo-box; label: "Fitness Goal: [current value]"; announces selected value on change |
| Experience Level seg | Role: radio group; each seg = radio button; active = selected; label: "Experience Level: [Beginner/Intermediate/Advanced]" |
| Height / Weight inputs | Role: text field (numeric); label: "Height in centimetres" / "Weight in kilograms"; keyboard type: numeric |
| field-error | Live region — announced immediately when validation fails; associated with invalid field |
| Save Changes (active) | Role: button; label: "Save Changes" |
| Save Changes (disabled) | Role: button; disabled state; not focusable |
| save-note | Announced alongside Save button when disabled; `accessibilityLabel: "Fix the highlighted fields to save"` |
| Log Out | Role: button; label: "Log Out" — danger colour alone must not be the sole indicator; label conveys destructive intent |
| logout-icon | Decorative — `excludeFromSemantics: true` |
| Toast | Role: status or alert live region; "Profile saved" announced immediately |
| Retry button | Min tap target 44pt; current padding `11px 22px` gives ~36px height — OQ-16 |
| All interactive elements | Min 44pt tap target — save-btn `padding:15px` → ~44px; seg `padding:11px` → ~34px — OQ-16 |

---

## 8. Component & Design System Mapping

### Existing components (no new work needed)

| Component | Reused from | Notes |
|-----------|-------------|-------|
| err-card | SCR-20/21/22/23/24 | Identical pattern |
| retry-btn | SCR-20/21/22/23/24 | `lime; #131315; 800/13px; radius:10px; padding:11px 22px` |
| alert-triangle SVG | SCR-20/21/22/23/24 | Same paths |
| Back arrow | SCR-21/24 pushed-screen pattern | `22×22; white; stroke-width:2; M15 18l-6-6 6-6` |
| Overlay/detail appbar | Multiple pushed screens | `18px/800/.02em`; `padding:6px 20px 4px` |
| Translate-shimmer | SCR-21/22/23 | `card-alt; rgba(255,255,255,.06); translateX; 1.4s` |
| type-dot-like chev-down | New variant — see below | Chevron icon; dim; `16×16` |

### New components (SCR-25 — first form screen in system)

| Component | Description | Why new |
|-----------|-------------|---------|
| **avatar-wrap** | Centred circle user icon `64×64`; card-alt bg; dim icon; no photo. Contains avatar + optional avatar-name (unused in artboard). | First user avatar in system |
| **field-group** | Vertical stack: `field-label` (11px/700/dim/uppercase/.04em) + input element. Universal form-row container. | First labelled form field in system |
| **field-input** | Text input tile: `card bg; border; radius:12px; padding:13px 14px; 14px/600`. | First editable text input in system |
| **field-select** | Dropdown-style row: same geometry as field-input + trailing chev-down. Tap → picker (mechanism TBD). | First select/picker trigger in system |
| **seg-row + seg** | Segmented control: flex row of 3 equal segments; inactive = `card bg/muted/700`; active = `lime/700/#131315`. Fixed 3 values. | First segmented control in system |
| **field-row-2** | Side-by-side `flex; gap:12px` container for two equal field-groups (height + weight). | First 2-column field layout in system |
| **save-btn** | Full-width primary CTA: `lime; #131315; radius:14px; padding:15px; 800/14px`. Two states: active (lime) and disabled (card-alt/dim/border). | First full-width primary button in system |
| **field-input.invalid** | Danger-bordered field: `border:danger; bg:#2a1f1f; color:danger`. | First inline validation error state in system |
| **field-error** | Inline error message: `11px/600; danger`. Below the invalid field in the same field-group. | New |
| **save-note** | Helper note below disabled save-btn: `11px/dim; text-align:center; margin-top:-8px`. Copy: "Fix the highlighted fields to save." | New |
| **logout-row** | Text+icon danger row: `flex; center; gap:8px; padding:14px; margin-top:8px`. No card/border. | First danger text action row in system |
| **toast** | Absolutely positioned overlay card: `#1e2a12 bg; #4a5c22 border; radius:14px; padding:13px 16px; flex; gap:10px`. Lime checkmark + bold text. | First toast/snackbar in system |

### Token gaps (flag for token PR)

| Raw value | Proposed token | Status |
|-----------|---------------|--------|
| `border-radius:12px` | `radius.field` | **NEW** — field-input, field-select; first 12px usage |
| `letter-spacing:.04em` | `tracking.fieldLabel` | **NEW** — field-label; distinct from `.06em` section-label and `.03em` badge-label |
| `#4a5c22` | `color.successBorder` | **NEW** — success toast border; not the same as dangerBorder `#5c3a3a` |
| `font-size:14px` | `text.cardTitle` | **NEW** — flagged in SCR-24 (pb-name); reused here for field-input values |
| `font-size:11px` | `text.meta` | Established SCR-23; reused for field-label, field-error, save-note |
| `font-size:13px` | (no distinct token yet) | logout-label, toast-text — check if existing scale covers |
| `border-radius:10px` | `radius.dialogButton` | Established — seg + retry-btn reuse |
| `border-radius:14px` | (card radius, used system-wide) | save-btn + toast; same 14px as many cards |
| `#2a1f1f` | `color.dangerFill` | Established SCR-20 — reused for invalid field bg |
| `#1e2a12` | `color.successFill` | Established SCR-21 — reused for toast bg |
| `rgba(255,255,255,.06)` | `color.shimmerSheen` | Established SCR-21 — reused in loading shimmer |
| `font-weight:600` | `weight.medium` | Ongoing — field-input values |
| `font-weight:700` | `weight.bold` | Ongoing — seg labels, logout-label, toast-text, field-label |

---

## 9. Acceptance Criteria Mapping

| AC | Design mapping |
|----|---------------|
| **AC-1** — Profile Loading | Loading state: sk-avatar + 4 field-group skeletons; translate-shimmer on all sk elements |
| **AC-2** — Display and Edit Profile Info | Main state: avatar + 4 editable field-groups + save-btn + logout-row. All 4 confirmed fields pre-filled from Drift. |
| **AC-3** — Save Profile Edits | Save Changes (active) → Drift write → Success state: toast "Profile saved" appears; fields reflect new values. Save persists across re-entry. |
| **AC-4** — Invalid Height/Weight Blocks Save | Validation state: invalid field-input gets danger border/bg/colour; field-error "Enter a valid positive number." below invalid field; save-btn goes to disabled appearance; save-note appears. Save action is unresponsive until values corrected. |
| **EC-1** — Profile Read/Save Failure | Error state: err-card "Couldn't load your profile"; retry-btn re-triggers read. |
| **EC-2** — Invalid Numeric Entry | Covered by AC-4 — same inline validation pattern. |

---

## 10. Open Questions / Assumptions

### Blocking (must resolve before engineering picks up)

| ID | Question | Impact |
|----|----------|--------|
| **OQ-1** | Fitness Goal: dropdown picker (native iOS/Android) or bottom-sheet action sheet? What is the confirmed option set? ("Build Muscle / Lose Weight / General Fitness" from user story §3 are examples, not a confirmed closed list.) | Determines component implementation and copy |
| **OQ-2** | Height/Weight units: artboard shows `cm`/`kg`. Are imperial units (`in`/`lb`) in scope for MVP, or locked to metric? | Drift storage format, field labels, validation range |
| **OQ-3** | Display Name: is an empty string allowed? What is the max character length? | Drift schema + validation rule |
| **OQ-8** | Drift **write** failure (save fails): no artboard exists for this. Same err-card as read-failure, or inline error near save-btn? | Engineering needs a defined state |
| **OQ-9** | Back arrow with unsaved edits: navigate away silently discarding changes, or show a discard-confirmation dialog? | UX flow + dialog design if needed |

### Non-blocking

| ID | Question | Default assumption |
|----|----------|--------------------|
| OQ-4 | Display name max length | No limit enforced at field level; truncation in display contexts handled upstream |
| OQ-5 | Decimal height/weight (e.g. 76.5 kg) | Allowed; numeric keyboard with decimal on iOS/Android |
| OQ-6 | Re-validation timing: on next save-tap only, or also on keystroke/blur? | On save-tap (consistent with artboard showing error only after save attempt) |
| OQ-7 | Toast auto-dismiss duration | 2–3 s standard mobile convention |
| OQ-10 | Toast entry animation | Slide up from bottom, 200–250ms ease-out |
| OQ-11 | Height/Weight = 0: valid or invalid? | Invalid (same "Enter a valid positive number" error) |
| OQ-12 | Max value for height/weight | No enforced cap for MVP; unrealistic values are stored as-is (data reference only) |
| OQ-13 | Save button when no edits made | Save always enabled; tapping with no changes writes same values to Drift and shows toast (no change-detection logic for MVP) |
| OQ-14 | First-time user (blank fields) | Empty field-inputs with placeholder text (OQ — placeholder copy not in artboard) |
| OQ-15 | Segmented control on 320px width | Three segments with "Intermediate" may clip; engineering should verify |
| OQ-16 | Seg + retry-btn below 44pt tap target | Engineering adds `minHeight: 44px` in Flutter semantics |
| OQ-17 | Avatar: is it tappable for future photo upload? | Read-only for MVP — no tap action |
| OQ-18 | avatar-name CSS class defined but no rendered element — intentional? | Assumed intentionally removed from artboard; do not implement unless confirmed |

### Assumptions (design decisions inferred from artboard)

- All four fields are editable on the same screen simultaneously; there is no view/edit mode toggle.
- "Log Out" navigates to SCR-26 (Logout Confirmation) — it does NOT log out inline, consistent with the dependency note in the user story and the destructive-action convention of requiring a confirmation step.
- The avatar is a decorative user icon (no photo upload in scope).
- Display Name, Fitness Goal, and Experience Level do not have inline validation on the current artboard — only height/weight have a documented validation rule (AC-4). Fitness Goal and Experience Level have no invalid states defined.
- `overflow-y:auto` on Main state content allows the form to scroll on shorter devices; Loading/Error content is non-scrollable.
