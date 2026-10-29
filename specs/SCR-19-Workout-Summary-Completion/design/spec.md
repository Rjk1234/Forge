# Design Specification: SCR-19 — Workout Summary & Completion

**Story ID**: US-SCR-19  
**Priority**: High  
**Artboard reference**: https://claude.ai/code/artifact/e5fec60a-5cea-465b-97d3-1e556a1db092  
**Artboards**: Loading.dc.html · Main.dc.html · Error.dc.html  
**Created**: 2026-09-13  

---

## §1 Overview & Goal

### Problem

After tapping Finish, the user has no feedback that their session is being persisted, no confirmation it succeeded, and no immediate summary of what they just accomplished. Without this screen, a failed Drift write is silent and the session data is lost.

### User

An athlete who has just completed at least one logged set and tapped Finish on SCR-16 (Active Workout). They want to know: (a) their workout was saved, and (b) what they actually did.

### Goal

1. Show a loading state while the Drift write is in progress — the user knows the app is working.
2. On success, present the saved session as a clean summary: date/time, duration, and a per-exercise breakdown of every logged set (including skipped ones, visually differentiated).
3. On failure, explain what went wrong, reassure the user their in-memory data is intact, and give a single retry action. Prevent duplicate records on retry success.

### Success Metric

- The session summary matches the data the user entered during the workout (sets, reps, weight/time/bodyweight format per exercise type).
- No duplicate stored records are created when retry is used after a failure.
- The error message clearly communicates the data is still available.

### App Context

- ForgeApp is fully offline. The Drift write is a local I/O operation only — no network calls.
- All session data lives in the `workout_sessions` table.
- FR-3 (incomplete workout state) and FR-5 (connectivity) are **removed** per Decisions Log §1/§2.
- Completion criterion: at least 1 set logged + explicit Finish tap.

---

## §2 User Flow

### Entry Point

SCR-16 → user taps the "Finish" button (minimum 1 set logged).

### State Machine

```
SCR-16 [Finish tapped]
        │
        ▼
   [Loading state]  ◄────────────────────────────┐
   (in-place on SCR-16 layout)                    │
        │                                          │
   Drift write                                      │
   ┌────┴────┐                                     │
   ▼         ▼                                     │
SUCCESS    FAILURE                                  │
   │         │                                     │
   ▼         ▼                                     │
[Main]    [Error state]                             │
Summary   Retry ──────────────────────────────────►┘
   │
   ├─ "View History" ──► SCR-20 (Workout History)
   └─ "Done" ──────────► SCR-06 (Home)
```

### Navigation Stack Behaviour

- **Loading → Main**: full screen push/replace — SCR-16 is removed from the back stack. The user cannot back-navigate to the active workout after completion.
- **Main → SCR-06**: pop to root.
- **Main → SCR-20**: push SCR-20; SCR-19/Main remains on stack below SCR-20.
- **Error → Loading**: in-place state change (same screen widget); no new stack entry.

---

## §3 Screen-by-Screen Breakdown

### 3.1 Loading State (artboard: Loading.dc.html)

This is SCR-16's layout with the Finish button mutated into a loading state. The existing active-workout chrome (app bar, progress bar, exercise name) remains visible and unchanged — only the footer Finish button transforms.

**Artboard viewport**: 390 × 844 pt

#### App Bar
```
padding: 6px 20px 4px
display: flex; align-items: center; justify-content: space-between
```

| Element | CSS | Copy |
|---------|-----|------|
| `.appbar-title` | `font-size:15px; font-weight:800; color:var(--muted)` | "ACTIVE WORKOUT" (all-caps) |
| `.cancel-link` | `font-size:13px; font-weight:700; color:var(--dim); opacity:.4` | "Cancel" (non-interactive) |

> Cancel link is visually suppressed (`opacity:.4`) and must be non-interactive (`pointer-events:none`) during the save operation. It is not hidden — the user sees it is greyed out.

#### Progress Bar (full opacity — no dimming in this state)
```
.progress-wrap { padding:10px 20px 4px; flex:0 0 auto }
.progress-label { font-size:11px; color:var(--dim); font-weight:700; margin-bottom:6px }
.progress-track { height:6px; background:var(--card-alt); border-radius:4px }
.progress-fill  { width:96%; height:100%; background:var(--lime); border-radius:4px }
```

> Progress fill uses `var(--lime)` at `96%` width (not `var(--dim)` as seen mid-workout). At the final exercise with all sets complete, the fill is near-full and lime — communicating the workout was finished, not abandoned.

#### Content Area
```
.content { flex:1; padding:18px 20px 0; display:flex; flex-direction:column; gap:16px }
.ex-name { font-size:22px; font-weight:800 } — "Triceps Pushdown"
.ex-sub  { font-size:12px; color:var(--muted); margin-top:2px } — "Set 3 of 3 — complete"
.entry-card { margin-top:6px; background:var(--card); border:1px solid var(--border); border-radius:16px; height:120px }
```

#### Footer — Loading (Finish Button Transformed)
```
.footer { padding:14px 20px 22px }

.finish-btn {
  width: 100%;
  background: var(--card-alt);
  color: var(--dim);
  border: 1px solid var(--border);
  border-radius: 14px;
  padding: 16px;
  display: flex; align-items: center; justify-content: center; gap: 10px;
  font-weight: 800; font-size: 15px;
}

.spinner {
  width: 18px; height: 18px;
  border-radius: 50%;
  border: 2.5px solid rgba(196,201,172,.25);  /* muted at 25% opacity — track ring */
  border-top-color: var(--muted);              /* indicator arc — muted */
  /* CSS animation: rotate 360deg, linear, ~0.9s infinite */
}
```

Copy: `"Saving Workout…"` (trailing ellipsis is part of the string)

> The button visual state: `card-alt` background + `dim` text + `1px border` reads as "disabled/in-progress" — a deliberate departure from the active lime Finish button on SCR-16. The `dim` text colour vs `white` further signals non-interactivity. The button must not respond to taps during this state.

---

### 3.2 Main — Workout Summary (artboard: Main.dc.html)

A new full-screen destination. The active workout stack is cleared; this is a terminal screen (no back navigation to SCR-16).

**Artboard viewport**: 390 × 844 pt

#### App Bar
```
padding: 6px 20px 4px
display: flex; align-items: center; justify-content: center  /* centered, no cancel link */
```

| Element | CSS | Copy |
|---------|-----|------|
| `.appbar-title` | `font-size:15px; font-weight:800; color:var(--muted)` | "Workout Complete" |

> Title is title-case (not all-caps as in SCR-16) — signals a different mode. No cancel link or back affordance.

#### Scrollable Content
```
.content {
  flex: 1 1 auto;
  overflow-y: auto;
  padding: 14px 20px 90px;  /* 90px bottom clears the fixed footer */
  display: flex; flex-direction: column; gap: 16px;
}
```

#### Hero Section
```
.hero {
  display: flex; flex-direction: column; align-items: center;
  text-align: center; gap: 8px; padding: 8px 0 4px;
}

.hero-icon-wrap {
  width: 56px; height: 56px; border-radius: 50%;
  background: #1e2a12;           /* NEW — dark lime-green; success fill; first occurrence */
  display: flex; align-items: center; justify-content: center;
}

.hero-icon {
  width: 28px; height: 28px; color: var(--lime);
  stroke: currentColor; stroke-width: 2; fill: none;
  /* path: M20 6L9 17l-5-5 (checkmark) */
}

.hero-title { font-size:20px; font-weight:800; margin-top:4px }
/* Content: plan name from Drift — e.g. "Push Day — Upper Body" */

.hero-sub { font-size:12px; color:var(--muted) }
/* Content: session date/time — e.g. "Mon, Sep 7 · 6:42 PM" */
/* Format: {DDD}, {MMM} {D} · {h:mm AM/PM} */
```

> `#1e2a12` is the success-fill analogue to `#2a1f1f` (danger-fill) — a dark-tinted background that pairs with the coloured icon above it. This is the first occurrence in the system; token proposal: `color.successFill`.

#### Stat Row
```
.stat-row { display:flex; gap:10px }

.stat-box {
  flex: 1;
  background: var(--card); border: 1px solid var(--border);
  border-radius: 14px; padding: 14px; text-align: center;
}

.stat-label {
  font-size: 10px; color: var(--dim);
  text-transform: uppercase; letter-spacing: .04em; font-weight: 700;
}

.stat-value { font-size: 18px; font-weight: 800; margin-top: 4px; }
```

| Stat | Label | Value format |
|------|-------|-------------|
| Duration | "Duration" | `"{N} min"` |
| Exercise count | "Exercises" | `"{N}"` |
| Sets logged | "Sets Logged" | `"{N}"` |

> Three equal-width `flex:1` stat boxes. No fourth stat in artboard. Letter-spacing `.04em` on stat-label is a new value (system has `.05em`, `.06em`, `.08em`).

#### Section Label
```
.section-label {
  font-size: 12px; font-weight: 800;
  text-transform: uppercase; letter-spacing: .06em;
  color: var(--dim); margin-top: 4px;
}
```

Copy: `"Performance"`

#### Exercise Cards (one per exercise, in workout order)
```
.ex-card {
  background: var(--card); border: 1px solid var(--border);
  border-radius: 14px; padding: 12px 14px;
  display: flex; flex-direction: column; gap: 8px;
}

.ex-head { display:flex; align-items:center; gap:8px }

.type-dot { width:8px; height:8px; border-radius:50%; flex:0 0 auto }
  .type-dot.weighted   { background: var(--lime) }   /* barbell/dumbbell exercises */
  .type-dot.time       { background: var(--cyan) }   /* timed exercises */
  .type-dot.bodyweight { background: var(--muted) }  /* bodyweight exercises */

.ex-name  { font-size:13px; font-weight:700; flex:1 }
.set-tag  { font-size:10px; color:var(--dim); font-weight:700 }
/* set-tag content: "{N} sets" */

.set-list { display:flex; flex-wrap:wrap; gap:6px }

.set-pill {
  background: var(--card-alt); border: 1px solid var(--border);
  border-radius: 8px; padding: 4px 8px;
  font-size: 11px; font-weight: 700;
}

.set-pill.skipped {
  color: var(--dim);
  text-decoration: line-through;
  font-weight: 600;   /* one step lighter — only occurrence of 600 weight in system */
}
```

**Set pill content per exercise type:**

| Exercise type | Pill format | Example |
|---------------|-------------|---------|
| Weighted | `{reps}×{weight}kg` | `"8×60kg"` |
| Bodyweight | `{reps} reps` | `"15 reps"` |
| Time-based | `{MM:SS}` | `"00:45"` |
| Skipped | `.set-pill.skipped` | `"Skipped"` |

**Artboard exercise examples:**

| Exercise | Type dot | Sets | Pills |
|----------|----------|------|-------|
| Barbell Bench Press | weighted (lime) | 4 | `8×60kg`, `8×60kg`, `7×60kg`, `6×60kg` |
| Seated Shoulder Press | weighted (lime) | 3 | `10×18kg`, `9×18kg`, `Skipped` |
| Push-Ups | bodyweight (muted) | 3 | `15 reps`, `14 reps`, `12 reps` |
| Plank Hold | time (cyan) | 3 | `00:45`, `00:42`, `00:38` |
| Triceps Pushdown | weighted (lime) | 3 | `12×25kg`, `12×25kg`, `10×25kg` |

#### Footer (Fixed, with Gradient Overlay)
```
.footer {
  position: absolute; left: 0; right: 0; bottom: 0;
  padding: 14px 20px 22px;
  background: linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%);
  display: flex; gap: 10px;
}
```

> The gradient fades from transparent to `var(--bg)` over the top 40% of the footer. This allows content to scroll underneath the footer with a soft fade-out rather than a hard clip. `padding-bottom:90px` on `.content` ensures the last exercise card scrolls fully clear of the footer.

| Button | CSS | Copy |
|--------|-----|------|
| `.footer-btn.secondary` | `flex:1; background:var(--card-alt); color:var(--white); border:1px solid var(--border); border-radius:14px; padding:15px; font-weight:800; font-size:14px` | "View History" |
| `.footer-btn.primary` | `flex:1; background:var(--lime); color:#131315; border-radius:14px; padding:15px; font-weight:800; font-size:14px` | "Done" |

> Two equal-width (`flex:1`) 50/50 buttons. "Done" uses lime with `#131315` text (consistent with SCR-16 Finish button). "View History" uses `card-alt` (secondary pattern). `border-radius:14px` matches the set-pill container and stat-box radius (not the smaller `10px` dialog button radius).

---

### 3.3 Error State — Save Failure (artboard: Error.dc.html)

Shown when the Drift write fails. The workout is complete but not persisted. The in-memory session data is preserved for the retry.

**Artboard viewport**: 390 × 844 pt

#### App Bar
```
padding: 6px 20px 4px; justify-content: center
.appbar-title: font-size:15px; font-weight:800; color:var(--muted) — "Workout Complete"
```

> The title reads "Workout Complete" — not "Save Failed" or "Error". This is intentional: the user completed the workout; the failure is a technical save issue, not a workout failure.

#### Centred Error Content
```
.content {
  flex: 1 1 auto;
  display: flex; flex-direction: column; align-items: center; justify-content: center;
  padding: 0 32px; gap: 14px; text-align: center;
}
```

| Element | CSS | Content |
|---------|-----|---------|
| `.icon-wrap` | `width:64px; height:64px; border-radius:50%; background:var(--card); border:1px solid var(--border); display:flex; align-items:center; justify-content:center` | — |
| `.icon` | `width:30px; height:30px; color:var(--danger); stroke:currentColor; stroke-width:1.6; fill:none` | Calendar-with-exclamation SVG |
| `.msg-title` | `font-size:17px; font-weight:800` | "Couldn't save your workout" |
| `.msg-sub` | `font-size:13px; color:var(--muted); line-height:1.5` | `"Something went wrong writing "[plan name]" to local storage."` |
| `.msg-note` | `font-size:12px; color:var(--dim); line-height:1.5; margin-top:2px` | `"Your logged sets are still here — tap Retry to save again. Nothing has been recorded to your history yet."` |

**Calendar-with-exclamation icon SVG paths:**
```svg
<rect x="4" y="5" width="16" height="15" rx="2"/>    <!-- calendar body -->
<path d="M4 10h16"/>                                   <!-- top separator line -->
<path d="M8 3v4M16 3v4"/>                             <!-- calendar tab handles -->
<path d="M12 13v-2M12 16.2v.1"/>                      <!-- exclamation mark in calendar -->
```

> Icon wrap uses `var(--card)` background with `1px solid var(--border)` — a neutral container, NOT the `#2a1f1f` danger-fill used for destructive action icons (SCR-11, SCR-18). The danger colour is on the icon itself only. This distinguishes a technical failure from a destructive confirmation: the icon-wrap colour encodes severity level.

> `stroke-width:1.6` on this icon (vs `1.8` for alert-triangle / alert-circle). Marginal but consistent with a "technical/informational" register vs "destructive warning."

> Two-layer text pattern: `.msg-sub` (13px/muted) explains what failed; `.msg-note` (12px/dim) reassures and instructs. The plan name in `msg-sub` is interpolated from Drift.

#### Footer — Single Action
```
.footer { padding:14px 20px 22px; display:flex; flex-direction:column; gap:10px }

.retry-btn {
  width: 100%;
  background: var(--lime); color: #131315;
  border-radius: 14px; padding: 16px;
  text-align: center; font-weight: 800; font-size: 15px;
}
```

Copy: `"Retry"`

> Single full-width lime button (same style as the active Finish CTA on SCR-16). Footer is `flex-direction:column` — this leaves room for a potential secondary action (e.g. "Discard Workout" — see OQ-4) but none is shown in the artboard. The `gap:10px` is consistent even with one button.

---

## §4 Interactions & Behaviour

| Trigger | State | Action | Outcome |
|---------|-------|--------|---------|
| Finish tapped (SCR-16) | Active Workout | Validate ≥1 set logged; begin Drift write | Loading state: Finish → spinner + "Saving Workout…"; cancel-link → `opacity:.4; pointer-events:none` |
| Drift write succeeds | Loading | Flush in-memory session to `workout_sessions` table | Push/replace to Main (Summary) screen; SCR-16 cleared from stack |
| Drift write fails | Loading | Exception caught; preserve in-memory session | Push/replace to Error screen |
| "Retry" tapped | Error | Check session ID not already in Drift (deduplication guard); re-attempt write | Loading state shown again → same Drift write path |
| Retry Drift write succeeds | Loading (retry) | Session saved | Push/replace to Main |
| Retry Drift write fails | Loading (retry) | Exception caught again | Error state shown again |
| "Done" tapped | Main | — | Navigate to SCR-06 (Home); clear in-memory session |
| "View History" tapped | Main | — | Navigate to SCR-20 (Workout History) |
| OS back / gesture | Main | — | Blocked — no back navigation from completion screen |
| Cancel tapped during loading | Loading | — | Blocked — `pointer-events:none`; `opacity:.4` |
| Any tap during Drift write | Loading | — | Finish button non-interactive; rest of SCR-16 chrome non-interactive |

### Deduplication on Retry

The in-memory session must carry a stable session ID (generated when the workout begins on SCR-16). Before writing to Drift, check if a document with that ID already exists in `workout_sessions`. If it does (a prior retry succeeded but the app state was inconsistent), do not write again — navigate directly to Main.

---

## §5 Edge Cases & Error Handling

| # | Scenario | Behaviour |
|---|----------|-----------|
| EC-1 | **Drift write failure on first attempt** | Error state: icon-wrap + msg-title + msg-sub + msg-note + Retry button. In-memory session intact. |
| EC-2 | **Retry after failure — duplicate guard** | Session ID checked against Drift before write. If already saved (race): navigate to Main. If not saved: re-attempt write. |
| EC-3 | **All sets skipped** | Summary shown. Sets Logged stat = 0. All set-pills render as `.set-pill.skipped` (dim, line-through). Still a valid session because Finish was tapped. |
| EC-4 | **Single set logged, rest skipped** | Minimum valid session. Summary shows 1 ex-card with 1 pill + N skipped pills. Sets Logged = 1. |
| EC-5 | **App backgrounded during loading** | Drift write continues. On foreground: display Loading state if still writing; display Main if success; Error if failed. Do not restart the write. |
| EC-6 | **Long plan name in hero-title / msg-sub** | `hero-title` wraps to 2 lines (no explicit truncation); `msg-sub` wraps similarly. No max-lines constraint in artboard. |
| EC-7 | **"Retry" double-tap** | Retry button must become non-interactive immediately on first tap (loading state shown). No second write initiated. |
| EC-8 | **Zero exercises in plan (theoretical)** | Cannot reach SCR-19 via the normal flow (SCR-16 requires at least one exercise). Defensive guard: if somehow reached with empty session, show error state. |
| EC-9 | **"View History" then back to SCR-19** | If SCR-20 allows back navigation, SCR-19 (Main) is below it on the stack. User arrives back at the summary — this is acceptable; it is a read-only screen. |

---

## §6 Responsive & Platform Considerations

| Dimension | Behaviour |
|-----------|-----------|
| Reference (390pt) | Artboard reference — 3 stat boxes, pills wrap as needed |
| iPhone SE (375pt) | Stat boxes `flex:1` maintain equal width; narrower pills may wrap earlier |
| Large (428pt) | Hero section has more horizontal breathing room; pills may fit more per row |
| Content scrollability | `overflow-y:auto` on Main content; `padding-bottom:90px` ensures last card clears footer |
| Footer gradient | `linear-gradient` fades content into `--bg` naturally at all widths |
| Portrait only | Consistent with all active-workout screens (SCR-16–18) |
| Keyboard | No text input on any SCR-19 state; keyboard not relevant |
| iOS back gesture | Intercepted — no back navigation from Main |
| Android hardware back | Intercepted — same as iOS; no back from Main |
| Android (hardware back on Error) | Assumption: treated as no-op; user must tap Retry or force-quit. Confirm with Engineering. |

---

## §7 Accessibility

### Touch Targets

| Element | Artboard size | Minimum 44pt? |
|---------|--------------|--------------|
| "Done" footer button | `flex:1; padding:15px` — approx 175×52pt | ✓ |
| "View History" footer button | `flex:1; padding:15px` — approx 175×52pt | ✓ |
| "Retry" button | `width:100%; padding:16px` — full-width × 54pt | ✓ |
| Finish (loading state) | `width:100%; padding:16px` — full-width × 54pt | ✓ (non-interactive during loading) |

### Contrast Pairs

| Foreground | Background | Token | Ratio | WCAG AA (≥4.5:1) |
|-----------|-----------|-------|-------|-------------------|
| `#f5f6f1` (white) | `#201f22` (card) | stat-value on stat-box | ~11:1 | ✓ Pass |
| `#f5f6f1` (white) | `#2a2a2c` (card-alt) | set-pill on pill bg | ~9:1 | ✓ Pass |
| `#8a8f7a` (dim) | `#201f22` (card) | stat-label on stat-box | ~3.2:1 | ✗ Fail — 10px text at 4.5:1 threshold; requires design review |
| `#8a8f7a` (dim) | `#131315` (bg) | section-label, msg-note on bg | ~4.2:1 | ✗ Marginal — just below 4.5:1 |
| `#c4c9ac` (muted) | `#131315` (bg) | hero-sub, msg-sub on bg | ~6.8:1 | ✓ Pass |
| `#131315` (bg) | `#c3f400` (lime) | "Done" / "Retry" on lime | ~12.7:1 | ✓ Pass |
| `#c4c9ac` (muted) | `#2a2a2c` (card-alt) | spinner indicator on spinner track | ~5.2:1 | ✓ Pass |
| `#8a8f7a` (dim) | `#2a2a2c` (card-alt) | set-pill.skipped on pill bg | ~3.2:1 | ✗ Fail — 11px/line-through compound reduces legibility |
| `#ff6b6b` (danger) | `#201f22` (card) | error icon on icon-wrap | ~4.3:1 | ✗ Marginal — non-text icon; WCAG AA for UI components is ≥3:1; passes on that threshold |

> **Known contrast issues**: `stat-label` and `set-pill.skipped` both use `var(--dim)` on dark backgrounds and fail WCAG AA for small text. These are design system–wide issues not introduced by SCR-19. Log with Design for remediation.

### Semantic Roles & Labels

| Element | Requirement |
|---------|-------------|
| Loading Finish button | `role="status"` or adjacent `aria-live="polite"` region announcing "Saving Workout…" |
| Spinner element | `aria-hidden="true"` (decorative; status is conveyed by the adjacent text) |
| Cancel link (loading) | `aria-disabled="true"` (not just visually suppressed) |
| Hero icon wrap | `aria-label="Workout saved successfully"` (non-decorative) |
| set-pill.skipped | `aria-label="Skipped"` (line-through is visual only; screen readers must read "Skipped") |
| "View History" / "Done" | Labels are self-explanatory from copy; no additional aria-label needed |
| "Retry" button | Label is self-explanatory; ensure button role and focus ring visible |
| Error msg-note | Static text in content flow — no special aria needed |
| ex-card | Each ex-card may benefit from `role="group"` with `aria-label="{exercise name} — {N} sets"` |

### Focus Management

- Loading → Main: focus should move to hero section or appbar-title on mount.
- Error state: focus should move to "Retry" button or `msg-title`.
- No modals or overlays; no focus trap required on SCR-19.

---

## §8 Component & Design System Mapping

| Component | Used in | CSS Source | Status |
|-----------|---------|------------|--------|
| App bar (centered variant) | Main, Error | `justify-content:center; no cancel-link` | New variant — prior screens use `space-between` |
| App bar (SCR-16 variant, loading) | Loading | `space-between; cancel-link opacity:.4` | Reuse SCR-16; add disabled state for cancel |
| Progress bar (lime fill) | Loading | `progress-fill { background:var(--lime); width:96% }` | Reuse SCR-16; lime fill replaces dim fill at final state |
| Spinner button (loading state) | Loading | `card-alt + dim + 18px spinner` | **New pattern** — first loading button variant |
| Spinner | Loading | `18×18; border:2.5px; track rgba(muted,.25); indicator muted` | **New component** |
| Hero section | Main | `56×56 icon-wrap; #1e2a12 fill; 28×28 lime checkmark; 20px/800 title; 12px/muted sub` | **New pattern** |
| Stat row (3-up) | Main | `flex; gap:10px; stat-box flex:1; border-radius:14px` | **New pattern** |
| Stat box | Main | `card; 1px border; border-radius:14px; padding:14px; stat-label 10px/dim/.04em; stat-value 18px/800` | **New component** |
| Section label | Main | `12px/800/uppercase/.06em/dim; margin-top:4px` | Reuse pattern from SCR-16 (section headers) |
| Exercise card (summary) | Main | `card; 1px border; border-radius:14px; padding:12px 14px; gap:8px` | **New variant** (vs entry card on SCR-16) |
| Type-dot | Main | `8×8; border-radius:50%; weighted=lime, time=cyan, bodyweight=muted` | Reuse SCR-09/10/15/16 |
| Set pill (normal) | Main | `card-alt; 1px border; border-radius:8px; padding:4px 8px; 11px/700` | **New component** |
| Set pill (skipped) | Main | `+ color:dim; text-decoration:line-through; font-weight:600` | **New variant** |
| Footer (gradient, 2-button) | Main | `position:absolute; gradient overlay; flex gap:10px` | **New pattern** — gradient footer |
| Footer button (secondary) | Main | `flex:1; card-alt; white; 1px border; border-radius:14px; padding:15px; 800/14px` | Reuse secondary button pattern |
| Footer button (primary) | Main, Error | `flex:1; lime; #131315; border-radius:14px; padding:15px/16px; 800/14px–15px` | Reuse lime CTA pattern |
| Error icon wrap (neutral) | Error | `64×64; border-radius:50%; card; 1px border` | **New variant** — neutral wrap (vs #2a1f1f danger-fill wrap) |
| Calendar-with-exclamation icon | Error | `30×30; danger; stroke-width:1.6` | **New icon** — third error icon type in system |
| Error message (2-tier: sub + note) | Error | `msg-sub 13px/muted; msg-note 12px/dim; margin-top:2px` | **New pattern** — dual-layer error copy |
| Retry button (full-width lime) | Error | `width:100%; lime; #131315; border-radius:14px; padding:16px; 800/15px` | Reuse lime CTA; full-width (not flex:1) |

### New Tokens Required

| Value | Proposed Token | Occurrences | Notes |
|-------|----------------|-------------|-------|
| `#1e2a12` | `color.successFill` | 1 (Main hero-icon-wrap) | Lime-green dark bg; success analogue to `color.dangerFill` (#2a1f1f) |
| `rgba(196,201,172,.25)` | `color.spinnerTrack` | 1 (Loading spinner) | `color.muted` at 25% opacity; may be computed rather than static |
| `linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%)` | `gradient.footerFade` | 1 (Main footer) | Scrollable-content footer fade |
| `font-weight: 600` | `weight.medium` | 1 (set-pill.skipped) | Between 700 and 500; only occurrence in system |
| `border-radius: 8px` | `radius.pill` | 1 (set-pill) | New micro-radius tier below `radius.dialogButton` (10px) |
| `letter-spacing: .04em` | `tracking.statLabel` | 1 (stat-label) | Below existing .05em and .06em values |

### Icon Taxonomy Update

Three error/warning icon types now exist in the system:

| Icon | Shape | Stroke-width | Usage |
|------|-------|-------------|-------|
| Alert triangle | Triangle with `!` | 1.8 | Irreversible destructive action (SCR-18 Cancel Workout) |
| Alert circle | Circle with `!` | 1.8 | Recoverable invalid state (SCR-15 invalid plan) |
| Calendar-exclamation | Calendar with `!` | 1.6 | Technical save/persistence failure (SCR-19 Error) |

---

## §9 Acceptance Criteria Mapping

| AC / FR / EC | Requirement | Artboard state | Verified in spec |
|---|---|---|---|
| AC-1 / FR-1 | Finish processing → loading state shown | Loading | ✓ Spinner + "Saving Workout…" + disabled cancel-link |
| AC-2 / FR-2 | Session saved → summary with date/time, duration, actual sets/reps/weight | Main | ✓ hero-sub date/time; stat-row Duration; per-exercise ex-cards with set-pills |
| EC-1 / FR-4 | Local write failure → error state + retry + no duplicate | Error | ✓ Error screen; Retry button; deduplication guard documented in §4 |
| — | FR-3 removed — no incomplete workout state | — | Confirmed removed per Decisions Log §1/§2 |
| — | FR-5 removed — no connectivity state | — | Confirmed: app offline-only; no network handling required |
| — | Skipped sets visible but differentiated | Main | ✓ `.set-pill.skipped` — dim + line-through + weight:600 |
| — | Exercise type dot correct per exercise type | Main | ✓ weighted/time/bodyweight dots documented |
| — | Navigation: completion screen replaces active workout stack | — | ✓ documented in §2 and §4 |
| — | "Done" exits to SCR-06; "View History" exits to SCR-20 | Main | ✓ footer button targets documented |

---

## §10 Open Questions / Assumptions

| # | Question | Owner | Build-blocker | Assumption held |
|---|----------|-------|--------------|----------------|
| OQ-1 | **Duplicate prevention on retry**: What is the session ID strategy? Is the session ID generated when the workout begins (SCR-16), or when Finish is tapped? | Engineering | **Blocking** | ID generated at workout start on SCR-16; stable through retries |
| OQ-2 | **App backgrounded during Drift write**: What state is shown on foreground resume if write is still in progress? If write completed while backgrounded? | Engineering | **Blocking** | Loading shown if still writing; correct outcome state (Main or Error) shown if completed |
| OQ-3 | **Date/time in hero-sub**: Is this the session start time or end time (Finish tap time)? Format confirmed as "Mon, Sep 7 · 6:42 PM" from artboard — but which timestamp? | Design/PM | Non-blocking | Session start time |
| OQ-4 | **"Sets Logged" stat definition**: Completed sets only (excluding skipped), or all sets logged (including skipped)? | Design/PM | Non-blocking | Completed (non-skipped) sets only |
| OQ-5 | **"Exercises" stat definition**: Total exercises in the plan, or only exercises with ≥1 logged set? | Design/PM | Non-blocking | All exercises in the plan (whether or not sets were logged) |
| OQ-6 | **OS back on Error state (Android)**: Should Android hardware back from Error state be blocked (force retry or quit), or allowed to navigate somewhere (e.g. discard and go home)? | Engineering/PM | Non-blocking | Blocked — no back from Error; user must retry or force-quit |
| OQ-7 | **SCR-19 on navigation stack after "View History"**: If SCR-20 has a back button, does it return to SCR-19? Should the summary remain accessible after "View History"? | Engineering/PM | Non-blocking | SCR-19 remains on stack below SCR-20; user can return |
| OQ-8 | **"Discard Workout" from Error state**: Should a secondary destructive action ("Give up / discard session") be offered on the Error screen if the user cannot or will not retry? The artboard shows none — but `flex-direction:column` on the footer suggests it was considered. | PM/Design | Non-blocking | No discard option from Error state in v1 — artboard is canonical |
| OQ-9 | **Duration calculation**: Is duration `Finish tap time − session start time`, or `Finish tap time − last pause resume` (net active time)? | Engineering | Non-blocking | Total elapsed time (start to Finish tap), including rest periods |
| OQ-10 | **`#1e2a12` hero icon-wrap colour**: Is this intentionally a different shade from `#2a1f1f` (danger-fill) or a new token? Should this be `color.successFill` in the design system? | Design | Non-blocking | New token required; log with Design for formalisation |
