# Design Specification: SCR-17 — Rest Timer

**Story ID**: US-SCR17  
**Priority**: High · 3 points  
**Created**: 2026-09-13  
**Artboard reference**: https://claude.ai/code/artifact/1f762b66-1595-4a86-9af1-be8bb124c3c7  
**Artboards read**: Main.dc.html (1 artboard)  
**Entry point**: SCR-16 (Active Workout — set marked complete)  
**Exit point**: SCR-16 (via Skip Rest or timer reaching zero)

---

## §1 — Overview & Goal

**Problem**: After completing a set, athletes need a structured rest interval before starting the next set. Without a visual timer, athletes either over-rest (losing workout momentum) or under-rest (compromising performance). The rest period should require no interaction — it runs itself and auto-advances.

**User**: Any user actively executing a workout session.

**Goal**: Display a full-screen countdown overlay that auto-advances to the next set/exercise when the timer reaches zero. The user may also skip the rest early at any time.

**Success metric**: Zero missed auto-advances — the timer always resolves (either via Skip or expiry) and returns to SCR-16 with the correct next set/exercise pre-loaded.

**App context**: ForgeApp is fully offline. The timer runs locally using Dart's `Timer`/`Stopwatch` — no network, no background service (background behaviour deferred per Decisions Log §6b). Rest Timer appears as an overlay on top of SCR-16; it is not a separate route — it renders as a full-screen scrim over the dimmed SCR-16 content.

**Functional requirements (from user story)**:
- FR-1: Auto-start timer when a set is marked complete (Decisions Log §6, 2026-09-05)
- FR-2: Timer runs entirely locally, no network
- FR-3: User can tap Skip to end rest early
- FR-4: Skip → immediately return to SCR-16 (next set/exercise)
- FR-5: Timer reaches zero → auto-advance to next set/exercise on SCR-16 (no confirmation)

**Deferred**: App-backgrounded timer behaviour (Decisions Log §6b). No spec coverage for what happens when the user backgrounds the app mid-rest.

---

## §2 — User Flow

```
SCR-16 [set marked complete]
  │
  ▼
Rest Timer overlay appears (auto-starts immediately, no user action required)
  │
  ├─ [Skip Rest tapped] ──────────────────────────────► SCR-16 (next set/exercise)
  │
  └─ [Timer reaches 00:00] ──────────────────────────► SCR-16 (next set/exercise, auto-advance)
```

**State machine**: Single state only — the overlay is either visible (counting down) or dismissed. There is no paused state for the rest timer. The Pause button on SCR-16 is not accessible while the rest timer is active (SCR-16 is dimmed and non-interactive).

**Entry trigger**: The overlay appears immediately when the user taps "Complete Set" on SCR-16 and that action is valid (all fields pass validation, set is logged to Drift). The transition is instantaneous — no animation specification is provided in the artboard; assume a standard fade-in.

**Exit trigger**: Either of two events dismisses the overlay — a Skip Rest tap or the countdown reaching zero. Both produce the same outcome: the overlay disappears and SCR-16 advances to the next set or exercise.

---

## §3 — Screen-by-Screen Breakdown

### State A — Rest Timer Overlay (Only State)

The overlay renders over a dimmed copy of SCR-16. There is one artboard for this screen.

---

#### Shared Layer: SCR-16 Background (dimmed)

The underlying SCR-16 screen remains mounted but is rendered in a heavily reduced-opacity, desaturated state to communicate non-interactivity.

| Layer | Property | Value |
|-------|----------|-------|
| App bar (entire row) | `opacity` | `.35` |
| App bar title | `font-size` / `font-weight` / `color` | `15px / 800 / var(--dim)` (#8a8f7a) |
| App bar cancel link | `font-size` / `font-weight` / `color` | `13px / 700 / var(--dim)` — **NOT danger red**; dim at full value, then the `.35` opacity applies |
| Progress wrap (entire row) | `opacity` | `.35` |
| Progress fill | `background` | `var(--dim)` (#8a8f7a) — **NOT lime** |
| Content area | `opacity` | `.2` |
| Content area | `filter` | `grayscale(.4)` |

**Key observation**: The app bar cancel link changes from `#ff6b6b` (danger) to `var(--dim)` (#8a8f7a) when the rest timer is active — a stronger visual suppression than the SCR-16 Pause state where cancel remained danger-red at `opacity:.5`. The background is non-interactive: no taps pass through the scrim.

---

#### Dark Scrim

```
position: absolute
inset: 0
background: rgba(10, 10, 10, .72)
display: flex
align-items: center
justify-content: center
padding: 0 30px
```

This is a filled dark scrim (`rgba(10,10,10,.72)`). This is **different** from the SCR-16 Pause overlay, which had no background colour on its scrim element — the Pause panel relied entirely on content dimming. Rest Timer uses a solid dark veil.

The `.72` opacity is slightly higher than the `rgba(10,10,10,.62)` used in SCR-11 (Delete Confirm) and SCR-14 (Edit Warning). Three distinct scrim opacities now exist in the system: .62 (modal dialogs), .72 (rest timer), and no-color (pause overlay).

---

#### Rest Panel

```
width: 100%
display: flex
flex-direction: column
align-items: center
text-align: center
gap: 16px
```

Panel elements (top to bottom, separated by `gap: 16px`):

---

**1 — "Resting" label**

```
font-size: 13px
font-weight: 800
color: var(--dim)        ← #8a8f7a
text-transform: uppercase
letter-spacing: .08em    ← highest letter-spacing in the system
```

Copy: **"Resting"**

The `.08em` letter-spacing is the largest in the design system. Prior values: `.04em` (type-label, field-label), `.05em` (entry-title, next-label), `.02em` (ring-time). This label functions as a low-key ambient status indicator — it uses dim colour and the widest possible tracking to feel expansive rather than urgent.

---

**2 — Ring countdown**

Ring wrap:
```
position: relative
width: 220px
height: 220px
display: flex
align-items: center
justify-content: center
```

SVG ring:
```
viewBox: 0 0 220 220
width: 220 / height: 220
```

Background circle (ring-bg):
```
cx: 110 / cy: 110 / r: 96
fill: none
stroke: var(--card-alt)   ← #2a2a2c
stroke-width: 10
```

Foreground circle (ring-fg — countdown arc):
```
cx: 110 / cy: 110 / r: 96
fill: none
stroke: var(--lime)        ← #c3f400
stroke-width: 10
stroke-linecap: round
stroke-dasharray: 603      ← circumference = 2π × 96 ≈ 603.19
stroke-dashoffset: 205     ← illustrative value (≈34% remaining arc consumed)
transform: rotate(-90 110 110)   ← starts at 12 o'clock
```

The ring counts DOWN: as time elapses, `stroke-dashoffset` increases from 0 (full ring = full rest remaining) toward 603 (empty ring = rest expired). At `stroke-dashoffset: 205`, approximately 34% of the circumference is hidden — representing a timer that has already partially elapsed. The `stroke-dashoffset` value in the artboard is illustrative; implementation must compute it dynamically from `(elapsed / total) × 603`.

Countdown time text (ring-time):
```
position: absolute
font-size: 44px
font-weight: 800
letter-spacing: .02em
color: var(--white)        ← #f5f6f1 (inherited)
```

Copy format: **"MM:SS"** (e.g., "00:42"). This is the only numeric readout on this screen.

---

**3 — "Up Next" card**

```
width: 100%
background: var(--card)    ← #201f22
border: 1px solid var(--border)   ← #444933
border-radius: 14px
padding: 14px
display: flex
flex-direction: column
gap: 2px
```

Note: border-radius is **14px** — matching standard content cards (not 16px entry-card, not 18px modal/pause-panel).

Sub-elements:

| Element | Styles | Copy |
|---------|--------|------|
| next-label | `11px / 800 / var(--dim) / uppercase / letter-spacing:.05em` | "Up Next" |
| next-name | `15px / 700 / var(--white) / margin-top:2px` | "Barbell Bench Press — Set 3 of 4" |
| next-meta | `12px / var(--muted)` (#c4c9ac) | "Target: 8 reps · 60 kg" |

The `gap: 2px` between sub-elements is the tightest row gap in the system (previous minimum was `gap:6px` for field sub-elements). This tight gap makes the card read as a compact info-row rather than a list.

next-name format pattern: `"[Exercise Name] — Set [N] of [N]"`. When advancing to a new exercise, this would read `"[New Exercise Name] — Set 1 of [N]"` (see OQ-3).

---

**4 — Skip Rest button**

```
width: 100%
background: var(--card-alt)   ← #2a2a2c
color: var(--white)
border: 1px solid var(--border)   ← #444933
border-radius: 14px
padding: 15px
text-align: center
font-weight: 800
font-size: 14px
```

Copy: **"Skip Rest"**

This is a secondary-style button (card-alt fill, white text) — intentionally understated. There is no primary/lime CTA on this screen; the rest is meant to be waited out, not skipped. The button's availability is a safety valve, not the promoted action.

`border-radius: 14px` — matches the next-card and is the standard full-width button radius on this screen.  
`padding: 15px` — 1px less than the SCR-16 "Complete Set" primary button (16px) and 1px more than SCR-16 action buttons (14px). This mid-weight padding suits a secondary full-width button.

---

## §4 — Interactions & Behavior

| Trigger | Response | Notes |
|---------|----------|-------|
| Set marked complete on SCR-16 | Rest timer overlay appears; countdown starts at configured rest duration | Auto-start; no user action needed; see OQ-1 for default duration source |
| Timer tick (each second) | `ring-time` text updates; `stroke-dashoffset` animates | Should use `setState`/stream — not a rebuild-heavy timer |
| Timer reaches 00:00 | Overlay dismissed; SCR-16 advances to next set/exercise | No confirmation; no haptic specified — see OQ-5 |
| "Skip Rest" tapped | Overlay dismissed immediately; SCR-16 advances to next set/exercise | Same outcome as zero-expiry |
| SCR-16 background area tapped (through scrim) | No action — scrim is fully blocking, non-interactive | |
| OS back gesture / hardware back | Behaviour unspecified — see OQ-6 | Should not silently pop the workout session |
| App backgrounded | Deferred (Decisions Log §6b) | |

**Countdown mechanics**:
- The timer counts down in seconds. `ring-time` displays `MM:SS` format (zero-padded: "01:30", not "1:30").
- The ring arc represents the proportion of rest time REMAINING (full arc = full rest, empty arc = expired). This is the inverse of a progress bar.
- `stroke-dashoffset` value at runtime: `(elapsed_seconds / total_seconds) × 603`. At 0 elapsed: `stroke-dashoffset = 0` (full lime ring). At full elapsed: `stroke-dashoffset = 603` (ring invisible, only card-alt bg circle shows).
- The ring animation should be smooth — either a CSS transition or Flutter `AnimationController` driving the SVG-equivalent `CustomPainter` arc.

**Auto-advance behaviour (FR-5)**:
- When `elapsed_seconds == total_seconds`, the timer fires and SCR-16 is updated to reflect the next set.
- "Next set" means: if the current set is not the last set of the current exercise, advance to `set_index + 1` of the same exercise. If the current set is the last of the current exercise, advance to `set_index = 1` of the next exercise.
- This logic mirrors the completion path in SCR-16 (FR-5 of US-SCR16).

---

## §5 — Edge Cases & Error Handling

| Case | Expected behaviour |
|------|-------------------|
| Rest duration is 0 seconds (no rest configured) | Timer should not appear — auto-advance immediately. Rest Timer overlay is skipped. See OQ-2. |
| Rest duration not defined in plan | Fall back to a system default. See OQ-1 for default value source. |
| Last set of last exercise — rest timer triggered | This should not occur: SCR-16 routes to SCR-19 (Workout Complete) after the last set, not to Rest Timer. Engineering must ensure Rest Timer is only invoked when a "next" set exists. |
| "Up Next" card — next thing is a new exercise | next-name format changes to new exercise name with "Set 1 of N". next-meta shows that exercise's first-set target. See OQ-3 for format confirmation. |
| "Up Next" card — next set is bodyweight (no weight target) | next-meta format unspecified — may need to hide the "· [X] kg" segment. |
| Timer completes but next set state cannot be determined | Fail gracefully — do not crash. Log error, advance to SCR-16 in a recoverable state. Engineering to define fallback. |
| App backgrounded mid-timer | Deferred (Decisions Log §6b). |
| User taps Skip Rest very rapidly (multiple times) | Debounce — only one advance event should fire. |
| Device receives a phone call / system interrupt mid-timer | No specification. Timer should likely pause on app background (but this is the deferred case). |

**No validation errors exist on this screen.** The only interactive control is Skip Rest, which cannot produce an error state.

---

## §6 — Responsive & Platform Considerations

**Phone width**: The rest panel is horizontally constrained by `padding: 0 30px` on the scrim — effective content width is `phone_width − 60px`. On 390px: 330px. The ring is 220px wide, which fits comfortably within 330px on all supported phone widths.

**Large phones (430px+)**: The panel stretches to `100%` width minus the 30px side padding. The ring remains 220px (fixed SVG size) — it will appear slightly less dominant on wider phones. No max-width cap is specified; the card and button elements stretch to fill.

**Small phones (375px)**: Effective content width = 315px. The 220px ring still fits with 47.5px on each side. No overflow risk.

**Portrait-only**: No landscape consideration. This screen inherits SCR-16's portrait-lock.

**Platform differences**:
- iOS: No back swipe accessible since the scrim covers the full screen. The OS edge gesture must be intercepted — see OQ-6.
- Android: Hardware back button behaviour must be defined. Likely same intercept as SCR-16's back gesture (routes to SCR-18 or presents confirmation) — see OQ-6.

**Keyboard**: No text input on this screen. Keyboard management not applicable.

---

## §7 — Accessibility

**Touch targets**:

| Element | Tap area | Meets 44×44pt? |
|---------|----------|---------------|
| Skip Rest button | Full width × ~49px (15px padding × 2 + 14px text + 5px for line-height) | ✅ Yes |

Only one interactive element exists on this screen. Touch target compliance is straightforward.

**Semantic roles**:
- "Resting" label: Static text. Consider `Semantics(label: "Resting")` — not an action.
- Ring countdown: Should be a live region. `Semantics(liveRegion: true, label: "Rest timer: 00:42")` — updates each second. Avoid announcing every second via screen reader (would be extremely noisy); consider announcing only at key intervals (e.g., 30s, 10s, 5s, 0s).
- "Up Next" card: Static informational text. `Semantics(label: "Up Next: Barbell Bench Press, Set 3 of 4, Target: 8 reps, 60 kilograms")`.
- Skip Rest button: `Semantics(button: true, label: "Skip Rest")`.

**Colour contrast**:

| Foreground | Background | Ratio (approx.) | Note |
|------------|-----------|-----------------|------|
| "Resting" label `#8a8f7a` (dim) | Scrim `rgba(10,10,10,.72)` over `#131315` → effective `~#090909` | ~4.5:1 | Marginal WCAG AA |
| Ring time `#f5f6f1` (white) | `#131315` (bg at ring centre) | ~18:1 | ✅ Excellent |
| next-name `#f5f6f1` | `#201f22` (card) | ~14:1 | ✅ Excellent |
| next-meta `#c4c9ac` (muted) | `#201f22` (card) | ~6.5:1 | ✅ AA |
| Skip Rest text `#f5f6f1` | `#2a2a2c` (card-alt) | ~12:1 | ✅ Excellent |
| next-label `#8a8f7a` (dim) | `#201f22` (card) | ~3.5:1 | ⚠️ Below AA — design intent (decorative label) |

The "Resting" label at dim colour over the dark scrim is borderline — the computed effective background through the scrim is very dark, so the ratio likely meets AA in practice. Verify with an exact compositor calculation.

**Motion**: The ring arc animation and the second-by-second digit update are both dynamic. For users with "Reduce Motion" enabled, consider stopping the arc animation and using a static number readout only. The countdown itself must still function.

---

## §8 — Component & Design System Mapping

| Component | Token / Value | Source / Status |
|-----------|--------------|----------------|
| Dark scrim | `rgba(10,10,10,.72)` | **New opacity** — previously .62 (SCR-11, SCR-14). Not tokenised. |
| "Resting" label | `13px/800/dim/uppercase/.08em` | **New typographic variant** — `.08em` is the highest letter-spacing in the system. |
| Ring countdown SVG | `220×220; r:96; stroke:10; bg:card-alt; fg:lime; linecap:round` | **New component** — first animated ring/progress-circle in the system. |
| Ring time readout | `44px/800/letter-spacing:.02em` | **New type size** — 44px is the largest font size in the system (prior max: 22px on ex-name, SCR-16). |
| next-card container | `card bg; 1px border; radius:14px; padding:14px; gap:2px` | Reuses card pattern; `gap:2px` is the tightest row gap in the system. |
| next-label | `11px/800/dim/uppercase/.05em` | Matches entry-title letter-spacing from SCR-16. Consistent small label variant. |
| next-name | `15px/700/white/margin-top:2px` | **New font-weight combo at 15px** — prior 15px uses were 800 (Complete Set). 700 here reads softer. |
| next-meta | `12px/muted` | Standard muted meta text — consistent with ex-sub (SCR-16) and similar rows across system. |
| Skip Rest button | `card-alt fill; white; 1px border; radius:14px; padding:15px; 14px/800` | Reuses secondary button language (card-alt fill). radius:14px matches next-card — consistent within overlay. |
| Background SCR-16 app bar | `opacity:.35` | **More aggressive than SCR-16 Pause** (which was not explicitly opacity on the app bar, but the title was `color:var(--dim)`) |
| Background progress fill | `background:var(--dim)` | Same as SCR-16 Pause state. |
| Background content area | `opacity:.2; filter:grayscale(.4)` | Same reduction values as SCR-16 Pause. |

**New patterns identified**:
1. **Filled dark scrim overlay** at `.72` opacity — distinct from modal scrim (.62) and pause overlay (no fill). Adds a third scrim tier to the overlay taxonomy.
2. **Animated countdown ring** — SVG arc driven by `stroke-dasharray`/`stroke-dashoffset`. First circular progress component in the system.
3. **44px display numeral** — new display-size typography token needed. Prior max was 22px.
4. **"Up Next" preview card** — new pattern for contextualising what follows the current resting state. Not used on any prior screen.
5. **Cancel link colour suppression during overlay** — Cancel becomes dim during Rest Timer (vs. danger-red during normal SCR-16). The overlay takes stronger ownership of the screen than the Pause panel.
6. **`gap:2px` tight label stack** — sub-element density inside next-card is tighter than any prior card pattern.

**Token gaps**:
- `rgba(10,10,10,.72)` — not tokenised. Three scrim opacity values now exist (.62, .72, no-fill). Suggest `color.scrim.rest` token.
- `44px` display size — not in the typography scale. Suggest `text.display` or `text.timerXL` token.
- `letter-spacing:.08em` — not in the type scale. Suggest `letterSpacing.widest` token.

---

## §9 — Acceptance Criteria Mapping

| AC / FR / NFR | Requirement | Design coverage |
|---------------|-------------|-----------------|
| AC-1 | Display countdown + runs locally | ✅ Ring + MM:SS readout. Local Dart timer. |
| AC-2 | Skip → SCR-16 | ✅ "Skip Rest" button dismisses overlay and returns to SCR-16 next set. |
| AC-3 | Zero → auto-advance (no confirmation) | ✅ When ring reaches empty (00:00), overlay dismissed, SCR-16 advances. No modal or confirmation depicted. |
| FR-1 | Auto-start on set complete | ✅ Overlay appears immediately on set completion. |
| FR-2 | Runs entirely locally, no network | ✅ ForgeApp offline constraint. Dart Timer only. |
| FR-3 | User can tap Skip to end rest early | ✅ "Skip Rest" button present and full-width. |
| FR-4 | Skip → immediately return to SCR-16 | ✅ No intermediate state on skip. |
| FR-5 | Timer zero → auto-advance | ✅ No confirmation required; advance is automatic. |
| NFR-1 | Independent of network | ✅ Fully local. |
| NFR-2 | Auto-advance without confirmation | ✅ Zero → advance is silent and immediate. |

**No ECs (Edge Cases) or SEC requirements defined in the user story inventory.**

---

## §10 — Open Questions / Assumptions

| # | Question | Owner | Build-blocker? | Assumption held |
|---|----------|-------|---------------|----------------|
| OQ-1 | **Rest duration source**: Where does the default rest duration come from? The artboard shows "00:42" remaining (illustrative countdown) but does not specify the starting value. Is rest duration stored per-exercise in the plan? Is there a system-wide default (e.g., 60s, 90s)? Is there a user preference? | PM / Design | **Yes** — cannot start the timer without a duration | Assumption: 60-second default system-wide unless a plan specifies a per-exercise rest duration in Drift. Confirm with PM. |
| OQ-2 | **Zero rest duration**: If the configured rest duration is 0 (or not set), should the Rest Timer overlay appear at all, or should SCR-16 auto-advance immediately without showing the overlay? | PM / Design | **Yes** — determines overlay render logic | Assumption: overlay is skipped when rest duration is 0 or undefined; SCR-16 advances directly. |
| OQ-3 | **"Up Next" — cross-exercise transition**: When the next event is a new exercise (not a new set of the same exercise), does the next-card display the new exercise name and "Set 1 of N"? Is the copy format `"[Exercise Name] — Set [N] of [N]"` always used, or does the format differ? | Design | **No** — formatting detail, won't block build | Assumption: format is always `"[Exercise Name] — Set [N] of [N]"`. |
| OQ-4 | **Ring countdown direction / fill semantics**: The artboard shows the lime arc representing time REMAINING (full arc = full rest, shrinking arc = less rest left). Confirm this interpretation is correct and not inverted. | Design | No — implementable from artboard as-is | Assumption: lime arc = remaining time, counting DOWN toward empty. |
| OQ-5 | **Haptics / sound at zero**: When the timer reaches 00:00, is there a haptic or audio cue? The artboard shows no specification. | Design / PM | No — enhancement, won't block visual build | Assumption: no haptic or sound in v1. |
| OQ-6 | **OS back gesture / Android hardware back**: What happens if the user triggers the OS back gesture (iOS swipe from edge, Android back) while the Rest Timer overlay is active? Does it dismiss the rest early (same as Skip), navigate to SCR-18, or is it intercepted and blocked? | Engineering / PM | **Yes** — must not silently discard the workout session | Assumption: back gesture is intercepted and blocked while Rest Timer is active (user must use Skip Rest or wait for zero). |
| OQ-7 | **Bodyweight next-meta**: If the next set is a bodyweight exercise (no weight field), what does next-meta display? "Target: 8 reps" (no weight segment)? Or is next-meta hidden entirely? | Design | No — only affects next-meta copy | Assumption: next-meta shows only rep count for bodyweight exercises, e.g. "Target: 8 reps". |
| OQ-8 | **Scrim tappability**: Can the user tap through the scrim to interact with the dimmed SCR-16 beneath (e.g., tap Cancel)? | Engineering | No — standard modal behaviour | Assumption: scrim is fully blocking. No interaction passes through to SCR-16 while Rest Timer is active. |
