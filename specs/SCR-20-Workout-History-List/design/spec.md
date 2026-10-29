# Design Specification: SCR-20 — Workout History List

**Story ID**: US-SCR-20  
**Priority**: High  
**Artboard reference**: https://claude.ai/code/artifact/0e0c565e-43b2-4303-9f72-25e12fd3d64b  
**Artboards**: Loading.dc.html · Empty.dc.html · Main.dc.html · Error.dc.html  
**Created**: 2026-09-13  

---

## §1 Overview & Goal

### Problem

After completing a workout (SCR-19) or at any other time, the user has no way to review past sessions without this screen. Without SCR-20 they cannot verify their training history, identify patterns, or access the detailed log of any specific session (SCR-21).

### User

A user with the app unlocked (SEC-2) who wants to see their full history of completed workouts, either immediately after finishing one (SCR-19 → SCR-20) or as part of regular browsing via the History tab.

### Goal

1. Provide a fast-loading, readable reverse-chronological list of all completed workout sessions.
2. Give each row enough context to identify the session (date, plan name, duration, exercise count, set count) without requiring the user to drill into detail.
3. Handle loading, empty, and failure states distinctly — the user must never see a silent empty list when a Drift read error occurred.
4. Navigate to SCR-21 (Workout History Detail) on row tap.

### Success Metric

- Every completed session in `workout_sessions` table appears in the list in reverse-chronological order.
- Empty state is only shown when there are genuinely zero completed sessions.
- Error state (with retry) is shown on any Drift read failure; the empty state is never shown as a fallback for an error.

### App Context

- ForgeApp is fully offline. Workout history is read from the local `workout_sessions` table — no network call.
- NFR-3 (offline state) was **removed 2026-09-05** per Decisions Log §0; no connectivity failure mode exists.
- SEC-2: the app's local lock state must be unlocked before this screen is accessible.
- SEC-1 / FR-4: only sessions from this device's local Drift table are shown.

---

## §2 User Flow

### Entry Points

| Source | Mechanism |
|--------|-----------|
| SCR-06 Home (any root tab) | Tap "History" tab in the bottom nav bar |
| SCR-19 Workout Summary | Tap "View History" button (present after a successful save) |
| Any other root tab (Plans, Schedule, Progress, Stats) | Tap "History" tab in the shared bottom nav |

### Exit Points

| Destination | Mechanism |
|-------------|-----------|
| SCR-21 — Workout History Detail | Tap any populated history row |
| SCR-06 Home | Tap "Home" tab |
| SCR-08/12 Plans | Tap "Plans" tab |
| SCR-XX Schedule | Tap "Schedule" tab |
| SCR-XX Progress | Tap "Progress" tab |
| SCR-XX Stats | Tap "Stats" tab |

### State Machine

```
[Entry: tab tap or SCR-19 View History]
        │
        ▼
  [Loading skeleton]  ◄──────────────────────┐
        │                                      │
   Drift read                                   │
   ┌────┤────────────┐                         │
   ▼    ▼            ▼                         │
EMPTY  DATA        ERROR                       │
   │    │              │                       │
   ▼    ▼            [Retry tapped]────────────┘
[Empty] [Main]
         │
     [Row tapped]
         │
         ▼
       SCR-21
```

### Navigation Stack

SCR-20 is a **root tab screen** — it is not pushed onto a stack. Switching tabs is a root-level navigation gesture (tab switch), not a push/pop. On arrival via SCR-19 "View History," the nav tab state switches to History; SCR-19 may remain in the previous screen stack (see OQ-7 in SCR-19 spec).

---

## §3 Screen-by-Screen Breakdown

### 3.1 Shared Chrome (All States)

**Artboard viewport**: 390 × 844 pt

#### Status Bar
```
height: 28px; flex: 0 0 auto
```

#### App Bar
```
flex: 0 0 auto
```

The `padding-bottom` on the appbar varies per state (see individual states below) — a presentational difference that affects vertical breathing room before content.

| Element | CSS | Copy |
|---------|-----|------|
| `.appbar-title` | `font-size:22px; font-weight:800; letter-spacing:.02em; color:var(--white)` | "History" |

> `22px/800` is the root-tab title tier — significantly larger than the `15px/800` used on overlay/modal-style screens (SCR-17, SCR-18, SCR-19). This confirms SCR-20 as a top-level navigation screen. No back button; no cancel link.

#### Bottom Navigation Bar

```
.navbar {
  flex: 0 0 auto;
  display: flex; align-items: center; justify-content: space-between;
  padding: 10px 14px 18px;
  border-top: 1px solid var(--border);
  background: var(--bg);
}

.navitem {
  display: flex; flex-direction: column; align-items: center;
  gap: 4px; width: 52px;
  opacity: .5;     /* inactive state — from Loading artboard */
}
.navitem.active { opacity: 1; }

.navitem .icon  { width: 22px; height: 22px; color: var(--dim); }
.navitem.active .icon { color: var(--lime); }

.navitem .label { font-size: 10px; color: var(--dim); font-weight: 600; }
.navitem.active .label { color: var(--lime); }
```

**6 tabs — left to right:**

| Tab | Icon SVG | Label | Active on SCR-20 |
|-----|----------|-------|-----------------|
| Home | House path (M4 11l8-7 8 7 + M6 10v9h12v-9) | "Home" | No |
| Plans | Lines (M4 7h16M4 12h16M4 17h10) | "Plans" | No |
| Schedule | Calendar rect (same as SCR-19 error icon body) | "Schedule" | No |
| History | Clock circle (circle r8 + path M12 8v4l3 2) | "History" | **Yes** |
| Progress | Trend line (M4 17l5-5 4 3 7-8 + M15 7h5v5) | "Progress" | No |
| Stats | Bar chart (M5 20V10M12 20V4M19 20v-7) | "Stats" | No |

> All icons use `stroke-width:1.8; fill:none`. Active tab icon and label use `var(--lime)`. Inactive tab icon and label use `var(--dim)` at `opacity:.5`.

---

### 3.2 Loading State (artboard: Loading.dc.html)

Displayed immediately on screen mount while the Drift read is in flight.

#### App Bar
```
.appbar { padding: 6px 20px 16px }
```
> Extra 16px bottom padding separates the title from the skeleton rows below.

#### Content — Skeleton List
```
.content {
  flex: 1 1 auto;
  overflow: hidden;          /* skeleton does not scroll */
  padding: 0 20px 16px;
  display: flex; flex-direction: column; gap: 8px;
}
```

**Skeleton Row** (`sk-row`) — 7 instances shown:
```
.sk-row {
  display: flex; align-items: center; gap: 12px;
  background: var(--card); border: 1px solid var(--border);
  border-radius: 14px; padding: 12px 14px;
}

.sk-badge {
  width: 44px; height: 34px;
  border-radius: 8px; background: var(--card-alt);
  flex: 0 0 auto;
}

.sk-line {
  flex: 1; height: 14px; border-radius: 6px;
  background: linear-gradient(90deg, var(--card-alt) 25%, #35342f 37%, var(--card-alt) 63%);
  background-size: 400% 100%;
  animation: shimmer 1.4s ease infinite;
}

@keyframes shimmer {
  0%   { background-position: 100% 0; }
  100% { background-position: 0 0; }
}
```

> **`#35342f`** — skeleton shimmer midpoint. A warm-tinted lighter variant of `var(--card-alt)`. First occurrence in the system; token proposal: `color.shimmerMid`. The gradient sweeps left-to-right (`background-position` moves from 100% to 0), creating a rightward shimmer wave at `1.4s ease` cycle.

> **`sk-badge`** dimensions (`44×34px`) precisely match the real `.date-badge` column width (`44px`) and approximate height. The badge-to-line layout mimics the date-badge/hist-body/chevron structure of the populated row — making the transition from Loading → Main feel smooth.

> **7 rows** fill approximately 7 × (34px height + 24px padding + 8px gap) ≈ 462px of content area, which roughly fills the viewport below the appbar.

---

### 3.3 Empty State (artboard: Empty.dc.html)

Shown only when Drift read succeeded and returned zero completed sessions. Never shown as a fallback for a read error (NFR-2).

#### App Bar
```
.appbar { padding: 6px 20px 0 }
```

#### Content — Centred Empty Message
```
.content {
  flex: 1 1 auto;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 0 32px 60px;   /* 60px bottom offset centres content visually above the navbar */
  text-align: center; gap: 18px;
}

.empty-icon { width: 60px; height: 60px; color: var(--dim); }
/* clock/history SVG: circle cx12 cy12 r8, path M12 8v4l3 2; stroke-width:1.4; fill:none */
/* Same glyph as the History nav tab icon; stroke-width 1.4 (softer than nav icon's 1.8) */

.empty-title { font-size: 18px; font-weight: 800; }
/* Copy: "No workout history yet" */

.empty-sub {
  font-size: 14px; color: var(--muted); line-height: 1.5; max-width: 250px;
}
/* Copy: "Your completed workouts will appear here." */
```

> The empty icon uses the **same clock/history glyph** as the History nav tab but rendered at `60×60` with `stroke-width:1.4` — a softer, oversized illustration rather than a functional nav icon. This reuse creates a semantic link: "this screen is about history; there's no history yet."

> **Copy note**: AC-2 specifies the mandatory copy as `"Your completed workouts will appear here"` (no period). The artboard shows an additional title line (`"No workout history yet"`) and appends a period to the sub (`"Your completed workouts will appear here."`). The AC requirement is satisfied by the sub-line. Confirm the extra title line and period with Design/PM (see OQ-1).

---

### 3.4 Main — Populated List (artboard: Main.dc.html)

Displayed when at least one completed session exists in Drift. Sessions are grouped by calendar month in reverse-chronological order (newest month first, newest day first within each month).

#### App Bar
```
.appbar { padding: 6px 20px 12px }
```

#### Content — Scrollable Session List
```
.content {
  flex: 1 1 auto;
  overflow-y: auto;
  padding: 0 20px 12px;
  display: flex; flex-direction: column; gap: 10px;
}
```

#### Month Section Label
```
.month-label {
  font-size: 12px; font-weight: 800;
  text-transform: uppercase; letter-spacing: .05em;
  color: var(--dim);
  margin: 6px 0 2px;
}
```

Copy format: `"{Month} {Year}"` — e.g. `"September 2026"`, `"August 2026"`.

> `margin:6px 0 2px` — the 6px top margin separates a new month's label from the last card of the previous month. Combined with `gap:10px` on the flex container, the visual break between months is `10px (flex gap) + 6px (month-label margin-top) = 16px` — slightly more than the 10px between cards within the same month. This provides subtle grouping without explicit dividers.

#### History Card Row (one per completed session)
```
.hist-card {
  display: flex; align-items: center; gap: 12px;
  background: var(--card); border: 1px solid var(--border);
  border-radius: 14px; padding: 12px 14px;
}
```

**Date Badge**
```
.date-badge {
  width: 44px; flex: 0 0 auto;
  display: flex; flex-direction: column; align-items: center;
}

.date-day { font-size: 18px; font-weight: 800; }
/* Content: zero-padded 2-digit day number — e.g. "07", "31" */

.date-mon { font-size: 10px; font-weight: 700; color: var(--muted); text-transform: uppercase; letter-spacing: .03em; }
/* Content: 3-letter day-of-week abbreviation — e.g. "Mon", "Sat", "Thu" */
/* NOTE: despite the CSS class name "date-mon", this is the DAY OF WEEK, not the month abbreviation.
   The month context is provided by the month-label section header above. */
```

**Session Body**
```
.hist-body {
  flex: 1 1 auto;
  display: flex; flex-direction: column; gap: 2px;
}

.hist-name { font-size: 14px; font-weight: 700; }
/* Content: plan name from Drift workoutSession — e.g. "Push Day — Upper Body" */

.hist-meta { font-size: 11px; color: var(--muted); }
/* Content: "{duration} min · {exercises} exercises · {sets} sets" */
/* Separator: middle dot U+00B7 (·) — not a bullet, not a slash */
/* Example: "38 min · 5 exercises · 14 sets" */
```

**Chevron**
```
.chev {
  width: 16px; height: 16px; color: var(--dim); flex: 0 0 auto;
  /* path: M9 18l6-6-6-6 (right-pointing chevron); stroke-width:2; fill:none */
}
```

> `stroke-width:2` on the chevron is slightly heavier than the system default `1.8`. At `16×16`, the extra weight ensures the directional affordance reads clearly at small size.

**Artboard data examples:**

| date-day | date-mon (DOW) | Month section | hist-name | hist-meta |
|----------|----------------|---------------|-----------|-----------|
| 07 | Mon | September 2026 | Push Day — Upper Body | 38 min · 5 exercises · 14 sets |
| 05 | Sat | September 2026 | Pull Day — Back & Biceps | 42 min · 4 exercises · 12 sets |
| 03 | Thu | September 2026 | Leg Day | 50 min · 6 exercises · 18 sets |
| 31 | Mon | August 2026 | Push Day — Upper Body | 35 min · 5 exercises · 13 sets |
| 29 | Sat | August 2026 | Pull Day — Back & Biceps | 40 min · 4 exercises · 12 sets |

---

### 3.5 Error State (artboard: Error.dc.html)

Displayed when the Drift read of `workout_sessions` fails. NFR-2 mandates this distinct state — the empty state must not be shown instead.

#### App Bar
```
.appbar { padding: 6px 20px 0 }
```

#### Content — Centred Error Card
```
.content {
  flex: 1 1 auto;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 0 32px; text-align: center; gap: 14px;
}

.err-card {
  width: 100%;
  background: var(--card);
  border: 1px solid #5c3a3a;    /* var(--dangerBorder) — confirmed design system token */
  border-radius: 16px;
  padding: 26px 20px;
  display: flex; flex-direction: column; align-items: center; gap: 12px;
}
```

> Error card uses `var(--card)` background (neutral) + `#5c3a3a` danger border — consistent with the error card pattern established in SCR-13 and SCR-14. The `#2a1f1f` danger fill is NOT used here; this is a read failure (technical), not a destructive action.

| Element | CSS | Content |
|---------|-----|---------|
| `.err-icon` | `width:40px; height:40px; color:var(--danger); stroke-width:1.6; fill:none` | Alert-triangle SVG |
| `.err-title` | `font-size:16px; font-weight:800` | "Couldn't load your history" |
| `.err-sub` | `font-size:13px; color:var(--muted); line-height:1.5` | "Something went wrong reading local data.\nYour plans and schedule are unaffected." |
| `.retry-btn` | `margin-top:4px; background:var(--lime); color:#131315; font-weight:800; font-size:13px; border-radius:10px; padding:11px 22px` | "Retry" |

**Alert-triangle SVG paths:**
```svg
<path d="M12 3l10 18H2L12 3z"/>          <!-- triangle body (sharp-tipped) -->
<path d="M12 10v4"/>                       <!-- exclamation stem -->
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>  <!-- exclamation dot -->
```

> This is a **different triangle variant** from SCR-18's alert-triangle (`M10.3 3.9L...` with rounded corners). SCR-20 uses a sharp-cornered triangle (`M12 3l10 18H2L12 3z`). Both are 24×24 viewBox. SCR-20's triangle is rendered at `40×40` container vs SCR-18's `24×24`. Both use `stroke-width:1.6` (not the `1.8` used for action-icon alert-triangles). The sharp variant may be the standard for informational/error states; the rounded variant for destructive confirmations. Confirm with Design (see OQ-2).

> **Retry button is inline-sized** (not full-width): `padding:11px 22px` auto-sizes to label width. This contrasts with SCR-19's full-width `width:100%` retry. Since the retry is contained within the error card alongside explanatory copy, an inline button reads as the card's specific action rather than the screen's primary CTA. `border-radius:10px` places it in the dialog-button radius tier.

> **err-sub copy** explicitly reassures: "Your plans and schedule are unaffected." This is important: the Drift read failure only affects the `workout_sessions` table; other tables (workout_plans, schedule_entries, etc.) are unaffected.

---

## §4 Interactions & Behaviour

| Trigger | State | Action | Outcome |
|---------|-------|--------|---------|
| Screen mount (tab tap / SCR-19 View History) | — | Initiate Drift `workout_sessions` read | Loading skeleton shown |
| Drift read succeeds, data ≥ 1 session | Loading | Group by month, sort reverse-chronological | Navigate to Main state |
| Drift read succeeds, data = 0 sessions | Loading | — | Navigate to Empty state |
| Drift read fails | Loading | Exception caught | Navigate to Error state |
| Row tapped | Main | — | Navigate to SCR-21 with selected session ID |
| Retry tapped | Error | Re-attempt Drift read | Loading skeleton shown again → same branch |
| History tab tapped (while already on SCR-20) | Any | — | No-op; screen already active |
| Other tab tapped | Any | — | Navigate to that root tab screen |
| OS back (Android) | Any | — | N/A — root tab screen; back navigates within Android app stack (typically to previous app) |
| Pull-to-refresh | Main | — | Not shown in artboard (see OQ-3) |
| Long-press on row | Main | — | Not specified (see OQ-4) |

### Transition Behaviour

- **Loading → Main / Empty / Error**: replace content in-place; no push/pop animation. The skeleton fades/crossfades to the resolved state.
- **Main → SCR-21**: standard push transition (slide in from right).
- **SCR-21 back → Main**: pop transition (slide out to right). Main state should be preserved (not re-fetched on back, unless data has changed).

---

## §5 Edge Cases & Error Handling

| # | Scenario | Behaviour |
|---|----------|-----------|
| EC-1 | **Drift read failure** | Error state with err-card + Retry. Copy confirms other data unaffected. |
| EC-2 | **Retry fails again** | Loading skeleton shown again → Error state again. No limit on retries. |
| EC-3 | **Very first use — no sessions ever** | Empty state. "No workout history yet." Distinct from error (EC-1). |
| EC-4 | **App just completed SCR-19 → View History → back to Main** | Main state should reflect the newly saved session at the top of the list (most recent). If SCR-20 is still loaded from a previous visit, the list must refresh on re-entry from SCR-19. |
| EC-5 | **Long plan name in hist-name** | `hist-name` has no explicit `max-width` or `overflow:hidden`; the `flex:1` body will wrap. If plan name is very long, the row height increases. Confirm max-lines behavior with Design (see OQ-5). |
| EC-6 | **Zero completed sets in a session** | The session exists in Drift (it was saved with ≥1 set logged per SCR-16/19 completion criteria). "0 sets" is theoretically impossible. If encountered: show "0 sets" in hist-meta. |
| EC-7 | **Drift returns sessions from a corrupt/partial write** | Sessions without a required field (plan name, date, duration) should be shown with a fallback — e.g. "Unknown Plan" for name, "—" for missing meta fields. Do not crash or silently omit. |
| EC-8 | **Very large history (100+ sessions)** | `overflow-y:auto` handles this. Month groups keep the list scannable. Performance: Drift lazy read or pagination TBD (see OQ-6). |
| EC-9 | **Session with duration = 0** | Show "0 min · N exercises · N sets" — edge case if Finish was tapped immediately. Confirm whether duration floor applies (see OQ-7 in SCR-19). |
| EC-10 | **App locked (SEC-2 violated)** | User should not be able to reach SCR-20 if the app is locked. The lock state enforces this at the app entry level. Not an SCR-20-specific state to handle. |

---

## §6 Responsive & Platform Considerations

| Dimension | Behaviour |
|-----------|-----------|
| Reference (390pt) | Artboard reference |
| iPhone SE (375pt) | Narrower; hist-name and hist-meta still fit on one row for typical plan names; month-label fits on one line |
| Large (428pt) | Wider hist-body; plan names with more space; badge and chevron scale stays fixed |
| Content scrollability | `overflow-y:auto` on Main — content scrolls behind the fixed navbar |
| Portrait only | Consistent with all ForgeApp screens (SCR-06 through SCR-19) |
| iOS back swipe | Edge-swipe from left has no effect (root tab screen; swipe within content scrolls vertically) |
| Android hardware back | No back action from root tab screen |
| Navbar bottom padding | `padding-bottom:18px` on navbar — accounts for iOS home indicator safe area |

---

## §7 Accessibility

### Touch Targets

| Element | Artboard size | Minimum 44pt? |
|---------|--------------|--------------|
| History card row | `border-radius:14px; padding:12px 14px` — full-width × ~58pt estimated | ✓ |
| Retry button | `padding:11px 22px` — ~44pt height (22px font + 22px padding) | ✓ borderline — confirm |
| Nav tab items | `width:52px; padding:10px top` — ~44pt touch area including padding | ✓ |

> Retry button height: `font-size:13px` (approx 16pt line-height) + `padding:11px × 2` = ~38pt rendered height. This is below the 44pt minimum. Recommend increasing padding to `14px 22px` or minimum-height constraint.

### Contrast Pairs

| Foreground | Background | Element | Ratio | WCAG AA (≥4.5:1 normal text) |
|-----------|-----------|---------|-------|-------------------------------|
| `#f5f6f1` (white) | `#201f22` (card) | hist-name on hist-card | ~11:1 | ✓ Pass |
| `#c4c9ac` (muted) | `#201f22` (card) | hist-meta on hist-card | ~6.8:1 | ✓ Pass |
| `#8a8f7a` (dim) | `#201f22` (card) | date-day secondary (dim not used on day, but chev is) | ~3.2:1 | — (chev is non-text; ≥3:1 threshold ✓) |
| `#f5f6f1` (white) | `#131315` (bg) | appbar-title on bg | ~12.5:1 | ✓ Pass |
| `#8a8f7a` (dim) | `#131315` (bg) | month-label on bg | ~4.2:1 | ✗ Marginal — just below 4.5:1 |
| `#131315` (bg) | `#c3f400` (lime) | retry-btn on lime | ~12.7:1 | ✓ Pass |
| `#ff6b6b` (danger) | `#201f22` (card) | err-icon on card | ~4.3:1 | ✗ Marginal (non-text icon; ≥3:1 threshold for UI components → ✓ passes that threshold) |
| `#c4c9ac` (muted) | `#201f22` (card) | err-sub on card | ~6.8:1 | ✓ Pass |
| `#f5f6f1` (white) | `#201f22` (card) | err-title on card | ~11:1 | ✓ Pass |
| `#c3f400` (lime) | `#131315` (bg) | active nav label | ~12.7:1 | ✓ Pass |
| `#8a8f7a` (dim) | `#131315` (bg) | inactive nav label | ~4.2:1 | ✗ Marginal at 10px/600 (small text) |

> `month-label` and `inactive nav label` are recurring system-wide `dim`-on-bg contrast issues (also flagged in SCR-15, SCR-16, SCR-19).

### Semantic Roles & Labels

| Element | Requirement |
|---------|-------------|
| History card row | `role="button"` or `GestureDetector` with `Semantics(button:true, label:"{plan name}, {date}")` |
| date-badge | Date information should be included in the card's accessible label — do not hide it |
| hist-meta | Include in card semantics label as a concatenated string |
| Chevron | `aria-hidden="true"` (decorative directional indicator; card-level label conveys navigability) |
| Skeleton rows | `aria-hidden="true"` (decorative loading state); use `aria-busy="true"` on the list region |
| Empty icon | `aria-hidden="true"` (decorative; message conveyed by title + sub text) |
| empty-title + empty-sub | Plain text in content flow; no special aria needed |
| Retry button | `role="button"` confirmed; accessible label "Retry" from copy |
| Error card | `role="alert"` or `aria-live="assertive"` to announce the error state to screen readers |
| Nav bar | `role="tablist"`; each navitem `role="tab"` with `aria-selected="true/false"` |

### Focus Management

- Tab switch: focus should move to the appbar-title or first content item on the new tab.
- Loading → Main: focus moves to first history card or month-label.
- Error state: focus moves to the error card or retry button.
- SCR-21 back: focus returns to the previously focused card row.

---

## §8 Component & Design System Mapping

| Component | Used in | CSS Source | Status |
|-----------|---------|------------|--------|
| Root-tab app bar | All states | `22px/800/.02em; padding:6px 20px {N}px` | Reuse pattern from SCR-06, SCR-08, SCR-12 |
| Bottom navigation bar (6-tab) | All states | `flex; space-between; 52px navitems; 10px/14px/18px padding; lime active` | Reuse SCR-06/08/12 bottom nav |
| Skeleton row | Loading | `card; 1px border; border-radius:14px; padding:12px 14px; sk-badge 44×34; sk-line shimmer` | **New pattern** — first animated skeleton in system |
| Shimmer animation | Loading | `linear-gradient + @keyframes shimmer 1.4s ease infinite` | **New pattern** |
| Centred empty state | Empty | `flex column; center; padding:0 32px 60px; icon 60×60/dim; title 18px/800; sub 14px/muted` | **New variant** — larger icon (60px vs 30px in SCR-19 error) |
| Month section label | Main | `12px/800/dim/uppercase/.05em; margin:6px 0 2px` | Reuse section-label pattern (first use in a list context) |
| History card row | Main | `card; 1px border; border-radius:14px; padding:12px 14px; flex; gap:12px` | **New component** |
| Date badge | Main | `width:44px; flex column; center; date-day 18px/800; date-mon 10px/700/muted/uppercase/.03em` | **New component** |
| Hist-body (name + meta) | Main | `flex:1; flex column; gap:2px; hist-name 14px/700; hist-meta 11px/muted` | **New component** |
| Chevron navigation indicator | Main | `16×16; dim; stroke-width:2` | Reuse — likely exists in SCR-21+ nav rows |
| Error card (danger-bordered) | Error | `card; 1px solid dangerBorder; border-radius:16px; padding:26px 20px; gap:12px` | Reuse pattern from SCR-13, SCR-14 |
| Alert-triangle icon (sharp variant) | Error | `40×40; danger; M12 3l10 18H2L12 3z; stroke-width:1.6` | **New variant** — sharp triangle vs SCR-18's rounded triangle |
| Inline lime action button | Error | `lime; #131315; border-radius:10px; padding:11px 22px; 800/13px` | Reuse dialog-button tier; first inline (non-full-width) lime button |

### New Tokens Required

| Value | Proposed Token | Occurrences | Notes |
|-------|----------------|-------------|-------|
| `#35342f` | `color.shimmerMid` | 1 (Loading shimmer gradient midpoint) | Warm-tinted lighter card-alt; only used in shimmer gradient |
| `linear-gradient(90deg, var(--card-alt) 25%, #35342f 37%, var(--card-alt) 63%)` | `gradient.shimmer` | 1 (sk-line) | Parameterised by shimmer animation |
| `background-size:400%` + `@keyframes shimmer` | Animation token TBD | 1 | System's first CSS animation pattern |
| `letter-spacing:.03em` | `tracking.dateMon` | 1 (date-mon) | New value below .04em stat-label; joins .04em, .05em, .06em, .08em |
| `font-weight:600` | `weight.medium` | 1 (nav label) | Already identified in SCR-19; now second occurrence |

### Alert-Triangle Variant Taxonomy

Two alert-triangle variants now confirmed:

| Variant | SVG path | Corners | Stroke-width | Size | Context |
|---------|----------|---------|-------------|------|---------|
| Rounded (SCR-18) | `M10.3 3.9L...` | Rounded corners | 1.8 | 24×24 in 52×52 wrap | Destructive confirmation dialog |
| Sharp (SCR-20) | `M12 3l10 18H2L12 3z` | Sharp corners | 1.6 | 40×40 in err-card | Read/technical failure error |

Confirm whether this distinction is intentional with Design (see OQ-2).

---

## §9 Acceptance Criteria Mapping

| AC / FR / NFR / EC | Requirement | Artboard state | Verified in spec |
|---|---|---|---|
| AC-1 / FR-1 | Workout history being fetched → skeleton list | Loading | ✓ 7 sk-rows with shimmer animation |
| AC-2 / FR-2 | No completed workouts → empty state with "Your completed workouts will appear here" | Empty | ✓ empty-sub contains AC-2 copy; empty-title "No workout history yet" is an artboard addition |
| AC-3 / FR-3 | Completed sessions → displayed in reverse-chronological order | Main | ✓ Sep 7 → Sep 5 → Sep 3 → Aug 31 → Aug 29; month-label groups confirm chronological ordering |
| AC-4 / FR-5 | Session selected → navigate to SCR-21 | Main | ✓ Chevron on every hist-card; tap action documented in §4 |
| EC-1 / NFR-2 | History load failure → error state with retry | Error | ✓ err-card + retry-btn; NFR-2 enforced (error ≠ empty) |
| FR-4 / SEC-1 | Only sessions from this device's local Drift | — | ✓ Offline-only; no sync; Drift table read documented |
| SEC-2 | App must be unlocked | — | ✓ Noted in §1; enforced at app entry level, not SCR-20 |
| NFR-1 | Reverse-chronological order | Main | ✓ Sep 7 most recent shown first; see AC-3 |
| ~~NFR-3~~ | ~~Offline state~~ | — | Removed 2026-09-05; no connectivity condition |

---

## §10 Open Questions / Assumptions

| # | Question | Owner | Build-blocker | Assumption held |
|---|----------|-------|--------------|----------------|
| OQ-1 | **Empty state copy**: AC-2 mandates "Your completed workouts will appear here" (exact string, no period). Artboard adds a separate title "No workout history yet" and appends a period to the sub. Are both lines required? Is the period in the sub intentional? | Design/PM | Non-blocking | Both lines shown as artboard; period treated as intentional; AC-2 satisfied by sub-line |
| OQ-2 | **Alert-triangle variants (sharp vs rounded)**: SCR-18 uses a rounded triangle (`M10.3 3.9L...`) and SCR-20 uses a sharp triangle (`M12 3l10 18H2L12 3z`). Is this a deliberate semantic distinction (destructive vs read-failure) or an artboard inconsistency? | Design | Non-blocking | Deliberate; sharp = informational error, rounded = destructive confirmation |
| OQ-3 | **Pull-to-refresh on Main list**: Should the user be able to pull-to-refresh to re-read Drift history? The artboard does not show this affordance. Given offline-only context, a refresh would re-read Drift (useful if a session was added while the screen was already open). | Engineering/Design | Non-blocking | No pull-to-refresh in v1; data re-fetched on screen re-entry |
| OQ-4 | **Long-press on history row**: Any contextual action (delete session, share, etc.)? Not shown in artboard. | PM/Design | Non-blocking | No long-press action in v1 |
| OQ-5 | **Long plan name truncation**: hist-name has no max-lines or overflow:hidden. Does a very long plan name wrap to 2 lines, increasing card height? Or should it be truncated to 1 line with ellipsis? | Design | Non-blocking | Wraps to 2 lines; card height grows |
| OQ-6 | **Large history list performance**: With 100+ sessions, is full Drift read acceptable? Is pagination or lazy-loading needed? | Engineering | Non-blocking | Full read in v1; paginate if performance degrades |
| OQ-7 | **SCR-20 data refresh on re-entry from SCR-21 (back)**: When user goes Main → SCR-21 → back → Main, should the list be re-fetched or preserved in memory? | Engineering | Non-blocking | Preserved in memory; re-fetched on tab switch |
| OQ-8 | **Skeleton row count**: 7 skeleton rows shown in artboard. Should implementation show a fixed 7, or a count based on screen height? | Engineering | Non-blocking | 7 rows fixed; or screen-height-based count |
| OQ-9 | **date-mon label — day-of-week vs month abbreviation**: CSS class is named `date-mon` but artboard content shows day-of-week ("Mon", "Sat", "Thu"). Confirm this is day-of-week, not a 3-letter month abbreviation like "Sep". | Design | Non-blocking | Day-of-week abbreviation (DOW); month is in the section header |
| OQ-10 | **Retry button touch target**: Computed height ~38pt from artboard values — below 44pt minimum. Should padding increase to `14px 22px`? | Design | Non-blocking | Increase to meet minimum; adjust spec if Design confirms |
| OQ-11 | **Navigation to SCR-20 from SCR-19 "View History"**: When SCR-19 triggers a tab switch to History, does the list auto-scroll to the newly saved session (top of list, since it's the most recent)? Or does the list just open at the top? | Engineering | Non-blocking | Opens at top; newly saved session is top of list (reverse-chronological) |
