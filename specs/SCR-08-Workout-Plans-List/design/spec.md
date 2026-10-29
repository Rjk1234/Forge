# Design Specification: Workout Plans List (SCR-08)

**User Story:** US-SCR08  
**Feature:** Workout Plan Management  
**Priority:** High | Story Points: 3  
**Design Reference:** [Claude Design Canvas — ForgeApp Workout Plans List](https://claude.ai/code/artifact/a78f11f8-6f04-461e-a6c5-aa657dbd845f) (4 artboards: Main.dc.html, Empty.dc.html, Loading.dc.html, Error.dc.html)  
**Created:** 2026-09-11  
**Status:** Draft — pending OQ resolution before build

---

## §1 — Overview & Goal

### Problem Being Solved

After unlocking ForgeApp, the user needs a single dedicated screen where they can see every workout plan they have created, understand at a glance how many exercises each contains, and navigate to create a new plan or open an existing one. Without this screen there is no entry point into the Workout Plan Management feature.

### User Goal

"Show me all my plans at a glance so I can tap one and get into it immediately."

### Business Context

SCR-08 is the root screen for the Plans tab (second slot in the bottom navigation bar). It is always reachable from any other root tab and must represent the complete local set of plans stored in the `workout_plans` table. It is a **root screen** — the bottom navigation bar is visible in all states.

### Success Metrics

| Metric | Target |
|---|---|
| Time-to-first-plan-tap (plans already exist) | ≤ 1 s from tab press |
| Empty → Create flow entry | Single tap on CTA or "+" FAB |
| Error recovery (Retry tap) | Re-triggers database read; shows result within 1 s |
| Accessibility: all interactive targets | ≥ 44 × 44 pt touch target |

---

## §2 — User Flow

### Entry Points

| Entry | Trigger | Pre-condition |
|---|---|---|
| Plans tab in bottom nav bar (SCR-06) | User taps the "Plans" tab | App unlocked; SCR-08 is the Plans tab's root |

> SCR-08 is always entered from the bottom nav bar. There is no deep-link or push entry from another secondary screen.

### State Branching on Load

```
User taps Plans tab
       │
       ▼
[Loading / Skeleton state — UC-SCR08-01]
       │
       ├─── database read succeeds ─── plans.isEmpty ──► [Empty state — UC-SCR08-02]
       │                                                     │
       │                               user taps CTA or "+" ▼
       │                                              SCR-09 (Create Plan)
       │
       ├─── database read succeeds ─── plans.isNotEmpty ─► [Populated state — UC-SCR08-03]
       │                                                     │
       │                      user taps plan row (FR-5) ─────┤
       │                                                SCR-10 (Plan Detail)
       │
       │                      user taps "+" FAB (FR-4) ──────┤
       │                                                SCR-09 (Create Plan)
       │
       └─── database read fails ──────────────────────────► [Error state — UC-SCR08-04]
                                                              │
                                             user taps Retry ▼
                                              [Loading state — re-read]
```

### Exit Points

| Action | Destination |
|---|---|
| Tap "Create a workout plan" CTA (empty state) | SCR-09 — Create / Edit Workout Plan |
| Tap "+" FAB (populated or loading-resolved state) | SCR-09 — Create / Edit Workout Plan |
| Tap any plan row (populated state) | SCR-10 — Plan Detail |
| Tap Retry (error state) | Stays on SCR-08, re-triggers Drift load |

### Use Cases Covered

| UC | Description | State |
|---|---|---|
| UC-SCR08-01 | User opens Plans tab while database read is in progress | Loading |
| UC-SCR08-02 | Database read completes; no plans found | Empty |
| UC-SCR08-03 | Database read completes; one or more plans found | Populated |
| UC-SCR08-04 | Database read fails with a local storage error | Error |

---

## §3 — Screen-by-Screen Breakdown

All artboard measurements are taken from 390 × 844 pt reference frames (iPhone 14/15 logical canvas). Bottom nav is present in every state.

---

### 3.1 — Shared Chrome (all states)

**Status Bar**  
- Height: 28 pt  
- Rendered by the OS; content not specified in artboards

**Bottom Navigation Bar** (Plans tab active)  
- Background: `color.bg` (#131315)  
- Top border: 1 pt solid `color.border` (#444933)  
- Padding: 10 pt top / 14 pt horizontal / 18 pt bottom  
- 6 tabs, each 52 pt wide; icon 22 × 22 pt, label 10 pt/600

| Tab | Icon | Active state |
|---|---|---|
| Home | House outline | `color.dim` icon + label |
| **Plans** | Horizontal-lines (≡) | `color.lime` icon + `color.lime` label — **active** |
| Schedule | Calendar outline | `color.dim` icon + label |
| History | Clock outline | `color.dim` icon + label |
| Progress | Trend-up outline | `color.dim` icon + label |
| Stats | Bar chart outline | `color.dim` icon + label |

---

### 3.2 — Loading State (`Loading.dc.html`)

**When shown:** Immediately when the Plans tab is tapped, before database read completes.

**App Bar**  
- Layout: flex row, space-between  
- Padding: 6 pt top / 20 pt horizontal / **16 pt bottom**  
- Left: "Workout Plans" — 22 pt / 800 weight / letter-spacing 0.02 em / `color.white` (#f5f6f1)  
- Right: FAB skeleton placeholder — 38 × 38 pt, border-radius 12 pt, fill `color.card` (#201f22), no icon

**Skeleton Content**  
- Scroll container: padding 0 20 pt 16 pt, gap 12 pt between cards  
- **4 skeleton plan cards** (mirrors the populated card shell):
  - Fill: `color.card` (#201f22)
  - Border: 1 pt solid `color.border` (#444933)
  - Border-radius: 16 pt
  - Padding: 16 pt all sides
  - Layout: flex column, gap 10 pt
  - **Title skeleton line:** width 65%, height 15 pt, border-radius 6 pt
  - **Sub skeleton line:** width 32%, height 11 pt, border-radius 6 pt
  - **Shimmer animation:** `linear-gradient(90deg, #2a2a2c 25%, #35342f 37%, #2a2a2c 63%)`, background-size 400% 100%, keyframes `from { background-position: 100% 0 } to { background-position: 0 0 }`, duration 1.4 s, easing ease, infinite

**Bottom Nav:** all inactive items at opacity 0.5; Plans tab (active) at opacity 1, lime color

---

### 3.3 — Populated State (`Main.dc.html`)

**When shown:** Database read succeeds and one or more plans are found in `workout_plans` table.

**App Bar**  
- Layout: flex row, space-between  
- Padding: 6 pt top / 20 pt horizontal / **16 pt bottom**  
- Left: "Workout Plans" — 22 pt / 800 weight / letter-spacing 0.02 em / `color.white`  
- Right: **Create "+" FAB**
  - Size: 38 × 38 pt
  - Border-radius: 12 pt
  - Fill: `color.lime` (#c3f400)
  - Icon fill: `color.bg` (#131315)
  - Icon: plus (+), 20 × 20 pt stroke-width 2.4

**Plan List**  
- Scroll container: padding 0 20 pt 16 pt, gap 12 pt, `overflow-y: auto`

**Plan Card** (one per plan, repeating):  
- Fill: `color.card` (#201f22)  
- Border: 1 pt solid `color.border` (#444933)  
- Border-radius: 16 pt  
- Padding: 16 pt all sides  
- Layout: flex row, align-items center, justify-content space-between, gap 12 pt

  **Left column** (flex:1 1 auto, flex column, gap 8 pt):  
  - **Plan name:** 16 pt / 800 weight / `color.white` (#f5f6f1) — e.g. "Push Day — Upper Body"  
  - **Exercise count:** 12 pt / 600 weight / `color.muted` (#c4c9ac) — e.g. "6 exercises"

  **Right trailing element:**  
  - Chevron-right icon, 16 × 16 pt, `color.dim` (#8a8f7a), stroke-width 2

**Sample plan rows from artboard:**

| Plan Name | Count |
|---|---|
| Push Day — Upper Body | 6 exercises |
| Pull Day — Back & Biceps | 5 exercises |
| Leg Day | 7 exercises |
| Core & Conditioning | 4 exercises |

---

### 3.4 — Empty State (`Empty.dc.html`)

**When shown:** Database read succeeds but `workout_plans` table contains zero plans.

**App Bar**  
- Layout: block (no FAB)  
- Padding: 6 pt top / 20 pt horizontal / **0 pt bottom** (content is vertically centered; no bottom gap needed under the title)
- Title: "Workout Plans" — 22 pt / 800 weight / letter-spacing 0.02 em / `color.white`
- **No "+" FAB** — the CTA button below serves this function; duplicating the FAB would be redundant

**Centered Content**  
- Container: flex column, align-items center, text-align center, padding 0 32 pt 60 pt, gap 18 pt
- **Empty icon:** 60 × 60 pt, `color.dim` (#8a8f7a) — horizontal-lines list icon (same glyph as Plans nav icon)
- **Title:** "No workout plans yet" — 18 pt / 800 / `color.white`
- **Subtitle:** "Build your first workout plan to see it listed here." — 14 pt / `color.muted` (#c4c9ac) / line-height 1.5 / max-width 250 pt
- **CTA Button:** "Create a workout plan"
  - Fill: `color.lime` (#c3f400)
  - Text color: #131315 (bg)
  - Font: 14 pt / 800
  - Border-radius: 12 pt
  - Padding: 14 pt vertical / 24 pt horizontal
  - margin-top: 6 pt (stacked after subtitle within gap-18 container)

---

### 3.5 — Error State (`Error.dc.html`)

**When shown:** Database read throws an exception or otherwise fails to load the `workout_plans` table.

**App Bar**  
- Layout: block (no FAB)  
- Padding: 6 pt top / 20 pt horizontal / **0 pt bottom**  
- Title: "Workout Plans" — 22 pt / 800 / `color.white`  
- **No "+" FAB**

**Centered Content**  
- Container: flex column, align-items center, text-align center, padding 0 32 pt, gap 14 pt
- **Error Card:**
  - Width: 100% (fills horizontal padding container)
  - Fill: `color.card` (#201f22)
  - Border: 1 pt solid `#5c3a3a` (`color.dangerBorder`)
  - Border-radius: 16 pt
  - Padding: 26 pt top / 20 pt horizontal
  - Internal layout: flex column, align-items center, gap 12 pt

  | Element | Value |
  |---|---|
  | Warning icon | 40 × 40 pt, `color.danger` (#ff6b6b), triangle-exclamation glyph, stroke-width 1.6 |
  | Error title | "Couldn't load your workout plans" — 16 pt / 800 / `color.white` |
  | Error body | "Something went wrong reading local data.\nYour history is unaffected." — 13 pt / `color.muted` / line-height 1.5 |
  | Retry button | "Retry" — lime fill / #131315 text / 13 pt / 800 / border-radius 10 pt / padding 11 pt vertical × 22 pt horizontal / margin-top 4 pt |

---

## §4 — Interactions & Behavior

### 4.1 — Tab Selection (entry)

- User taps Plans tab in bottom nav → Loading state renders immediately (skeleton)  
- If returning to an already-loaded Plans tab (tab was active, user navigated away to another root tab and returned): the list should reflect the current Drift state; a re-read on every return is acceptable since Drift is local-only and fast

### 4.2 — Plan Row Tap (populated state)

- Target: entire plan card row (16 pt padding on all sides gives a tall touch target)  
- Action: navigates to **SCR-10 Plan Detail** passing the `planId` (String) for that plan
- Visual feedback: standard press-highlight on the card (darkened fill or opacity reduction); no explicit active state defined in artboard — use platform default ripple/highlight

### 4.3 — "+" FAB Tap (populated state, loading-resolved state)

- Target: 38 × 38 pt button in top-right of app bar  
- Action: navigates to **SCR-09 Create / Edit Workout Plan** with no pre-filled plan (create mode)  
- Visual feedback: brief scale-down or opacity change on press

### 4.4 — "Create a workout plan" CTA Tap (empty state)

- Target: entire lime button; min touch size is 14 pt vertical + 24 pt horizontal padding → actual rendered height ~42 pt (14 pt font + 28 pt padding) — see §7 accessibility note
- Action: navigates to **SCR-09 Create / Edit Workout Plan** (create mode)  
- Identical destination as the "+" FAB — they are contextually equivalent

### 4.5 — Retry Tap (error state)

- Target: "Retry" button inside error card  
- Action: re-triggers the database read; screen transitions back to Loading state while the read is in progress  
- If read succeeds: transitions to Populated or Empty depending on result  
- If read fails again: returns to Error state (identical error card; no incrementing error count)

### 4.6 — Bottom Nav Tabs (all states)

- The bottom nav remains visible and interactive in all 4 states  
- Tapping a non-Plans tab navigates away from SCR-08 entirely (root-level tab swap)  
- **Loading state exception:** bottom nav items are visually dimmed (opacity 0.5) but remain tappable — the dimming communicates "loading" without disabling navigation

### 4.7 — Pull-to-Refresh

Not defined in artboards or user story. Do not implement without an open question resolution (see OQ-3).

### 4.8 — Transitions

- Plans tab → SCR-08: standard root tab animation (no slide; instant or fade per platform tab convention)  
- SCR-08 (populated) → SCR-10: push transition (slide left) — plan detail is a secondary screen  
- SCR-08 (any state) → SCR-09: push transition (slide left) — create plan is a secondary screen  
- SCR-08 error Retry → Loading: in-place state swap (no page transition)

---

## §5 — Edge Cases & Error Handling

### EC-1 — Database Read Failure (EC-1 from user story)

**Trigger:** Exception thrown when reading `workout_plans` table during initial load or Retry  
**Display:** Error state (§3.5)  
**Recovery:** Retry tap → re-read  
**Error copy:**  
- Title: "Couldn't load your workout plans"  
- Body: "Something went wrong reading local data.\nYour history is unaffected."  
**Rationale for body copy:** Reassures the user that logged sessions in `workout_sessions` are not corrupted by a `workout_plans` read failure

### EC-2 — Plans Exist but Count Field is Missing / Zero

**Trigger:** A `workoutPlan` record has no associated exercises (e.g., plan was created but no exercises added yet)  
**Display:** Plan row shows "0 exercises" in the meta field  
**No special UI:** The row renders the same as any populated plan

### EC-3 — Single Plan in List

**Trigger:** Exactly one plan exists  
**Display:** Populated state with one card; "+" FAB still present  
**No minimum-plan restriction** on the list

### EC-4 — Very Long Plan Name

**Trigger:** Plan name exceeds the horizontal space available in the left column  
**Display:** Name should truncate with ellipsis at 1 line max (artboard shows names on a single line; no multi-line wrapping is depicted). Confirm truncation rule — see OQ-4

### EC-5 — Many Plans (Long List)

**Trigger:** User has created a large number of plans  
**Display:** List scrolls within the content area (`overflow-y: auto`); app bar and bottom nav remain fixed  
**No pagination** — all plans are loaded from local Drift in a single read

### EC-6 — Retry Fails Again

**Trigger:** User taps Retry but database read fails a second time  
**Display:** Error state renders again (same card copy)  
**No escalation UI** — error copy does not change on repeated failures; no toast or additional messaging

### EC-7 — Plan Deleted in SCR-10 / SCR-09, User Returns to SCR-08

**Trigger:** User navigates to SCR-10 or SCR-09, performs a destructive action (delete plan), and pops back to SCR-08  
**Expected behaviour:** SCR-08 should reflect the updated state (plan count reduced or empty state if last plan deleted)  
**Implementation note:** This depends on when the database read is triggered — on every return or only on first load. See OQ-5

---

## §6 — Responsive & Platform Considerations

### Device Size Bands

| Band | Width | Adjustment |
|---|---|---|
| Small (SE 2nd/3rd gen) | 375 pt | Content area slightly shorter; all padding values remain unchanged; bottom nav bar bottom padding reduces from 18 pt to 12 pt to avoid clipping home indicator |
| Reference (iPhone 14/15) | 390 pt | Artboard reference size — no adjustment needed |
| Large (Plus/Max, 430 pt) | 430 pt | Content area wider; plan card stretches to fill; plan name may show more characters before truncating; no layout breaks expected |

### iOS

- Back navigation: none (SCR-08 is a root tab screen; there is no parent to swipe back to)  
- Bottom safe area: bottom nav bottom padding (18 pt) is designed to clear the home indicator on all modern iPhones  
- Tab animation: the Plans tab transition should use the platform's default root-tab switch (no animation or a fade, never a slide-from-edge)

### Android

- System back button / gesture: navigates to Home tab or exits the app if Plans is the first-viewed tab; does not pop SCR-08 (root screen has no parent)  
- Navigation bar: Android 3-button or gesture nav sits below the system chrome; the bottom nav's 18 pt bottom padding must account for the gesture inset via `SafeArea` or equivalent  
- Ripple effect: plan card tap can use Material-style ripple if on Android; iOS uses opacity/scale feedback

### Orientation

- Landscape not addressed in artboards; recommend locking to portrait-only for V1 (consistent with other screens in the design system)

---

## §7 — Accessibility

### Touch Targets

| Element | Rendered Size | Meets 44 pt? |
|---|---|---|
| Plan card row | Full-width × (16 pt + name + 8 pt + meta + 16 pt) ≈ ≥ 60 pt tall | ✅ Yes |
| "+" FAB | 38 × 38 pt | ⚠️ 6 pt short — extend hit area to 44 × 44 pt via `GestureDetector` with padding, or increase FAB to 44 pt |
| "Create a workout plan" CTA | ~42 pt tall (14 pt font + 28 pt padding) | ⚠️ 2 pt short — increase vertical padding to 15 pt each side to reach 44 pt |
| Retry button | 11 + 11 + 13 ≈ 35 pt tall | ⚠️ 9 pt short — increase vertical padding to 15 pt or add `minimumSize` constraint |
| Bottom nav tabs | 52 pt wide × 10+icon+label+18 ≈ 54 pt tall | ✅ Yes |

### Contrast Ratios

| Text / Background pair | Ratio (approx.) | Meets WCAG AA? |
|---|---|---|
| `color.white` (#f5f6f1) on `color.bg` (#131315) | ~15:1 | ✅ |
| `color.white` (#f5f6f1) on `color.card` (#201f22) | ~12:1 | ✅ |
| `color.muted` (#c4c9ac) on `color.card` (#201f22) | ~6.5:1 | ✅ |
| `color.muted` (#c4c9ac) on `color.bg` (#131315) | ~7.2:1 | ✅ |
| `color.dim` (#8a8f7a) on `color.bg` (#131315) | ~4.5:1 | ✅ (AA large text; borderline for small — nav labels pass at 10 pt bold) |
| #131315 on `color.lime` (#c3f400) — buttons | ~12:1 | ✅ |
| `color.danger` (#ff6b6b) on `color.card` (#201f22) — error icon | ~3.5:1 | ⚠️ Icon only; no text — sufficient for decorative icon if a text label accompanies it |

### Screen Reader Labels

| Element | State | Semantic label |
|---|---|---|
| Screen title "Workout Plans" | All | Heading level 1 |
| "+" FAB button | Populated / Loading | "Create workout plan" |
| Plan card row | Populated | "Push Day — Upper Body, 6 exercises" (merge name + count) |
| "Create a workout plan" CTA | Empty | Button — "Create a workout plan" |
| Retry button | Error | Button — "Retry loading workout plans" |
| Error title + body | Error | Group announcement: "Couldn't load your workout plans. Something went wrong reading local data. Your history is unaffected." |
| Skeleton cards | Loading | Single announcement: "Loading workout plans" (not announce each skeleton individually) |
| Bottom nav Plans tab | All | "Plans, tab, selected" |

### Focus Order

**Loading state:** Screen title → skeleton content (suppress individual skeleton cards from focus; announce group) → bottom nav tabs  
**Populated state:** Screen title → "+" FAB → plan card list (top to bottom) → bottom nav tabs  
**Empty state:** Screen title → empty message → "Create a workout plan" button → bottom nav tabs  
**Error state:** Screen title → error card heading → error body → Retry button → bottom nav tabs

### Reduce Motion

Skeleton shimmer animation should pause or be removed when the user has enabled "Reduce Motion" on their device. Replace with a static non-animated skeleton fill (`color.cardAlt`).

---

## §8 — Component & Design System Mapping

### Reused Components (from existing design system)

| Component | Where Used in SCR-08 | Design System token / precedent |
|---|---|---|
| Root app bar (large title, action right) | All states — "Workout Plans" title + optional right action | SCR-06 Home screen uses the same large-title + action pattern |
| Bottom navigation bar | All states | Shared global nav component — same as SCR-06 and SCR-07 (SCR-07 is secondary so it has no nav; SCR-06 is the canonical nav reference) |
| Plan card | Populated state, skeleton card shell (loading) | New for SCR-08; reusable for SCR-10 breadcrumbs |
| Empty state layout | Empty state — centered icon + title + sub + CTA | Mirrors SCR-07 Empty state pattern; slightly larger icon (60 vs 52 pt) |
| Error card | Error state | Matches SCR-07 Error card: card fill, danger border (#5c3a3a), warning icon, title/body/retry button |
| Skeleton card | Loading state | Matches SCR-07 skeleton pattern: same shimmer gradient (#2a2a2c → #35342f → #2a2a2c), same 1.4 s ease timing |
| Lime FAB button (square-rounded) | Populated + loading states (header) | New FAB variant: 38 × 38 pt square-rounded (12 pt radius); distinct from the 28 × 28 pt circular lime "+" in SCR-07 picker mode |
| Lime CTA button (full-width-like) | Empty state | Matches lime-button pattern: lime fill, dark text, 12 pt radius; same as SCR-07 empty... wait — SCR-07 empty had no CTA button, so this is new per-screen |

### New / Modified Components

| Component | Type | Rationale |
|---|---|---|
| **Plan card** | New | Two-row layout (plan name 16 pt/800 + exercise count 12 pt/600 muted + trailing chevron); not present elsewhere; candidate for reuse in SCR-10 list header and SCR-03 schedule slot summary |
| **Square-rounded FAB (38 pt)** | New variant | Larger than SCR-07's circular 28 pt picker button; square-rounded (12 pt radius) rather than circular; sits in the app bar rather than on a list row. Should be documented as `AppBarFAB` distinct from `ListRowAddButton` |
| **Large empty state (60 pt icon, 18 pt title)** | Size variant | SCR-07 empty state used 52 pt icon + 16 pt title; SCR-08 uses 60 pt icon + 18 pt title — slightly more prominent. May warrant a shared `EmptyStateView` component with configurable icon size |
| **Exercise count meta** | Content pattern | "N exercises" — singular/plural form must be handled ("1 exercise" not "1 exercises"); not a new component but a new content rule |

---

## §9 — Acceptance Criteria Mapping

| AC from user story | Design element that satisfies it | Spec section |
|---|---|---|
| **AC-1** — Loading: skeleton list shown while data not yet received | Loading state (§3.2): 4 skeleton plan cards with shimmer, FAB skeleton placeholder, nav dimmed | §3.2, §4.1 |
| **AC-2** — Empty: "Create a workout plan" CTA shown when no plans exist | Empty state (§3.4): lime CTA button "Create a workout plan" navigates to SCR-09 | §3.4, §4.4 |
| **AC-3** — Populated: list of named plans with exercise count shown | Populated state (§3.3): plan cards each showing name 16 pt/800 + "N exercises" 12 pt/600 muted | §3.3, §4.2 |
| **AC-4** — Plan access: tap a plan → plan detail | Plan card row tap → SCR-10 with planId (§4.2) | §4.2, §4.8 |
| **EC-1** — Plan load failure → error state with Retry | Error state (§3.5): error card, Retry button re-triggers database read | §3.5, §4.5, §5 EC-1 |

### FR Coverage

| FR | Covered? | Where |
|---|---|---|
| FR-1 — Loading/skeleton state | ✅ | §3.2 |
| FR-2 — Empty state + "Create a workout plan" CTA | ✅ | §3.4 |
| FR-3 — Populated list: plan name + exercise count | ✅ | §3.3 |
| FR-4 — Access create flow (FAB or CTA) | ✅ | §3.3 (FAB), §3.4 (CTA), §4.3, §4.4 |
| FR-5 — Select existing plan → plan detail | ✅ | §3.3, §4.2 |
| FR-6 — Error state + Retry | ✅ | §3.5, §4.5 |

---

## §10 — Open Questions / Assumptions

| # | Question | Owner | Impact on build | Default assumption if not resolved |
|---|---|---|---|---|
| **OQ-1** | **When is the database read triggered for SCR-08?** On every tab selection, on first tab visit only, or manually via refresh? The artboard shows Loading as the initial state but does not address tab-revisit behaviour. | Product / Tech Lead | **Yes — affects state management** | Assume: re-read on every tab selection, since database reads are fast and plans may have been modified in SCR-09/SCR-10 during the same session |
| **OQ-2** | **Does the "+" FAB appear during the Loading state?** The Loading artboard shows a skeleton placeholder for the FAB (card fill, no icon) rather than hiding it or showing the live lime button. Should the FAB become interactive during loading, or only after the read completes? | Design | Minor — UX detail | Assume: FAB is non-interactive during loading (skeleton state); becomes active only when Populated state is confirmed |
| **OQ-3** | **Pull-to-refresh:** Is there a pull-to-refresh gesture on the plan list in the Populated state? Not shown in any artboard. | Product | Minor — adds an interaction | Assume: not implemented in V1; Retry covers the error case; tab re-visit triggers a re-read (OQ-1) |
| **OQ-4** | **Plan name truncation:** Should long plan names truncate at 1 line with ellipsis, or wrap to 2 lines? The artboard shows all sample names fitting on one line; no wrap example is shown. | Design | Minor — layout detail | Assume: 1 line max, truncate with trailing ellipsis |
| **OQ-5** | **Return state after SCR-09 / SCR-10:** If the user creates, edits, or deletes a plan and pops back to SCR-08, should the list auto-refresh? The user story does not define this. | Product / Tech Lead | **Yes — affects state management** | Assume: SCR-08 re-reads Drift on every appearance (consistent with OQ-1 assumption), so the list automatically reflects changes made in child screens |
| **OQ-6** | **"1 exercise" vs "1 exercises" (singular/plural):** The user story says "exercise count" without specifying copy rules. | Content / Dev | Trivial — copy rule | Assume: "1 exercise" (singular), "N exercises" (plural, N ≥ 0 or N ≥ 2). "0 exercises" for empty plans (see EC-2) |
| **OQ-7** | **Empty state: does the title "Workout Plans" appear in the app bar without bottom padding?** The artboard uses `padding: 6px 20px 0` (no bottom pad) to let the centered content own the vertical rhythm. Confirm this is intentional and not an artboard oversight. | Design | Minor — layout | Assume: intentional — centred content needs no bottom gap from app bar |
| **OQ-8** | **Navigation type for SCR-09 / SCR-10 exits:** Push (slide) or modal (sheet)? The user story and inventory do not specify presentation style. | Design / Product | **Yes — affects back gesture on iOS and Android** | Assume: push (slide left) for both SCR-09 and SCR-10, consistent with SCR-07's OQ-10 assumption for secondary screens |
| **OQ-9** | **Exercise count source in the database:** Does a `workout_plans` row store a pre-computed `exerciseCount` integer, or does SCR-08 derive the count by reading the plan's exercise list at load time? | Tech Lead | Yes — data model | Assume: the plan object contains an `exerciseIds` list and SCR-08 derives `count = exerciseIds.length` at load time; no pre-computed counter required |
| **OQ-10** | **Error state — does "Your history is unaffected" need to be updated if SCR-08 is redesigned to show schedule or session data?** The error body copy implicitly refers only to `workout_sessions`. If plans and sessions are always in separate tables, this copy is accurate. | Content / Tech Lead | Low — future-proofing | Assume: accurate for V1; revisit if SCR-08 is extended |
