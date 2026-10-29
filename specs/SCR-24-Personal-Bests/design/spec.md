# Design Specification: SCR-24 — Personal Bests

**Created**: 2026-09-13  
**Feature**: FLOW-09 Statistics — Personal Bests screen  
**Artboard reference**: https://claude.ai/code/artifact/7f74011d-61bf-4f48-b2d1-88ef016334b5  
**User story**: `Doc/UserStories/SCR-24-Personal-Bests.md`  
**Precedes**: none (exit = back to SCR-23)  
**Follows**: SCR-23 pb-link row

> ⚠️ **CRITICAL — DEFERRED DECISION**: The "personal best" metric definition (heaviest weight, highest reps, highest volume, longest duration, or a combination) is an **open product decision per Decisions Log §3** — not yet made. The artboard's amber design-note banner and every "Metric TBD" badge label are placeholders. **Do not implement metric calculation or badge labels until OQ-1 is resolved.** Sample badge values (65 kg, 18 reps, 01:10, etc.) are illustrative only.

---

## 1. Overview & Goal

Personal Bests is a pushed detail screen within FLOW-09 Statistics, accessible only from the pb-link row on SCR-23. It presents a scrollable list of each exercise's all-time best performance, grouped by type-dot colour, with a badge showing the metric value and date it was achieved.

The screen surfaces the athlete's peak efforts in one place, reinforcing progress over time. It is **read-only** — no editing, no navigation to exercise detail.

**Screen type**: Pushed (overlay/detail tier)  
**Entry**: SCR-23 pb-link row tap  
**Exit**: back arrow → SCR-23 only  
**Nav bar**: ❌ absent (not a root tab)

---

## 2. User Flow

```
SCR-23 (Stats Dashboard)
  └── tap pb-link row
        └── SCR-24 Personal Bests
              ├── [Loading]  → data ready → [Main]
              ├── [Loading]  → no records  → [Empty]
              └── [Loading]  → error       → [Error]
                                               └── tap Retry → [Loading]
[Main]  ← back arrow ─┘
[Empty] ← back arrow ─┘
[Error] ← back arrow ─┘
```

All three resolved states share the same appbar; back arrow is always present and tappable.

---

## 3. Screen-by-Screen Breakdown — ALL States

### 3A. Loading State

The screen appears immediately on push. Skeleton rows replace real pb-cards while Drift reads are in flight.

**Chrome**

| Element | Value |
|---------|-------|
| Status bar | `height:28px` |
| Appbar padding | `6px 20px 4px` (bottom 4px — distinct from root-tab 10px) |
| Back arrow | `22×22; color:white; stroke-width:2; path M15 18l-6-6 6-6` |
| Title | `"Personal Bests"; 18px/800/.02em` (overlay/detail tier) |
| Navbar | ❌ absent |

**Skeleton rows** — 5 rows; each row:

| Sub-element | Value |
|-------------|-------|
| sk-row container | `flex; align-items:center; gap:12px; card bg; border:1px solid border; border-radius:14px; padding:12px 14px` |
| sk-dot | `8×8; radius:50%; card-alt bg` — static (not animated) |
| sk-line | `flex:1; height:14px; border-radius:6px` — bg-position shimmer |
| sk-badge | `56×38px; border-radius:10px; card-alt bg` — static |

**Shimmer variant** (bg-position — same as SCR-20, distinct from SCR-21/22/23 translate variant):

```css
background: linear-gradient(90deg, var(--card-alt) 25%, #35342f 37%, var(--card-alt) 63%);
background-size: 400% 100%;
animation: shimmer 1.4s ease infinite;
@keyframes shimmer { 0%{ background-position:100% 0; } 100%{ background-position:0 0; } }
```

The shimmer token `#35342f` → `color.shimmerMid` (established SCR-20/22). The card-alt base, border-radius values, and timing are identical to SCR-20's bg-position shimmer.

**Content layout**

```
content { flex:1 1 auto; padding:18px 20px 28px; flex-col; gap:10px }
  sk-row × 5
```

---

### 3B. Empty State

Shown when the athlete has no recorded workouts (or no sessions with trackable sets). No CTA button — intentionally read-only prompt only.

**Chrome**: identical to Loading (appbar `6px 20px 4px`, back arrow, `18px/800` title, no navbar).

**Content layout**

```
content { flex:1 1 auto; flex-col; align-items:center; justify-content:center;
          padding:0 32px 60px; text-align:center; gap:14px }
  empty-icon      52×52
  empty-title     16px/800
  empty-sub       13px/muted
```

**Empty icon** — trophy SVG:

```
viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4"
<path d="M8 21h8M12 17v4M6 3h12v4a6 6 0 0 1-12 0V3z"/>
<path d="M6 5H4a2 2 0 0 0 2 4M18 5h2a2 2 0 0 1-2 4"/>
color: dim (#8a8f7a)
```

**Copy**

| Element | Text |
|---------|------|
| empty-title | "No personal bests yet" |
| empty-sub | "Complete a workout to start setting personal bests." |

> Note: Empty state has **no CTA button** (contrast: SCR-23 empty state has "Start a Workout"). This is an intentional product decision — the PBs screen is purely informational.

---

### 3C. Main State (Populated — Metric Placeholder)

Shown when one or more PB records exist. The list is scrollable when items exceed viewport.

**Chrome**: identical to Loading/Empty (appbar `6px 20px 4px`, back, `18px/800`, no navbar).

> ⚠️ **Artboard design-note banner is NOT shipped UI.** The amber banner (`#2a2610`/`#d9c94a`) in the artboard is a designer annotation only — it must not appear in the production app. See §OQ-1.

**Content layout**

```
content { flex:1 1 auto; overflow-y:auto; padding:14px 20px 28px; flex-col; gap:10px }
  pb-card × N   (one per exercise with a recorded best)
```

**pb-card**

| Property | Value |
|----------|-------|
| Layout | `flex; align-items:center; gap:12px` |
| Background | `card` (#201f22) |
| Border | `1px solid border` (#444933) |
| Border-radius | `14px` |
| Padding | `12px 14px` |

**type-dot** (leftmost element)

| Dot class | Colour | Meaning |
|-----------|--------|---------|
| `.weighted` | `lime` (#c3f400) | Weighted resistance exercise |
| `.time` | `cyan` (#7df4ff) | Time-based / timed hold |
| `.bodyweight` | `muted` (#c4c9ac) | Bodyweight exercise |
| Size | `8×8; radius:50%` | |

**pb-body** (flex:1 1 auto; flex-col; gap:2px)

| Element | Value |
|---------|-------|
| pb-name | `14px/700; color:white` |
| pb-meta | `11px/muted` — date the PB was set |

pb-meta format: **"Set {Mon} {D}, {YYYY}"** — e.g. "Set Aug 31, 2026". Locale/format OQ: see OQ-3.

**pb-badge** (rightmost element)

| Property | Value |
|----------|-------|
| Background | `card-alt` (#2a2a2c) |
| Border | `1px solid border` (#444933) |
| Border-radius | `10px` |
| Padding | `8px 12px` |
| text-align | `center` |
| pb-badge-value | `14px/800; color:white` |
| pb-badge-label | `9px/dim; uppercase; letter-spacing:.03em; margin-top:1px` |

> ⚠️ pb-badge-label in the artboard reads **"Metric TBD"** — this is a placeholder. The production label (e.g. "Best weight", "Best reps") depends on OQ-1 resolution.

**Artboard sample data** (illustrative, not final values or sort order):

| Exercise | Type | Badge value | Badge label |
|----------|------|-------------|-------------|
| Barbell Bench Press | weighted | 65 kg | Metric TBD |
| Seated Shoulder Press | weighted | 20 kg | Metric TBD |
| Push-Ups | bodyweight | 18 reps | Metric TBD |
| Plank Hold | time | 01:10 | Metric TBD |
| Triceps Pushdown | weighted | 27 kg | Metric TBD |

---

### 3D. Error State

Shown when Drift read fails (unexpected storage error).

**Chrome**: identical to other states (appbar `6px 20px 4px`, back arrow, `18px/800`, no navbar).

**Content layout**

```
content { flex:1 1 auto; flex-col; align-items:center; justify-content:center;
          padding:0 32px; text-align:center; gap:14px }
  err-card
```

**err-card** — same pattern as SCR-20/21/22/23:

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
| err-icon | `40×40; danger (#ff6b6b); stroke-width:1.6; alert-triangle SVG` |
| err-title | `16px/800` — "Couldn't load your personal bests" |
| err-sub | `13px/muted; line-height:1.5` — "Something went wrong calculating this data.\nYour workout history is unaffected." |
| retry-btn | `lime bg; #131315; 800/13px; border-radius:10px; padding:11px 22px; margin-top:4px` |

**Alert-triangle SVG**:
```
<path d="M12 3l10 18H2L12 3z"/>
<path d="M12 10v4"/>
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>
```

---

## 4. Interactions & Behavior

| Trigger | Response |
|---------|----------|
| Back arrow tap | Pop screen; return to SCR-23 |
| System back gesture (Android) | Same as back arrow |
| Retry button tap (Error) | Re-trigger Drift read; show Loading → Main or Empty |
| List scroll (Main, long list) | `overflow-y:auto`; appbar fixed; no pagination |
| pb-card tap | No action — cards are **read-only** (no disclosure chevron, no navigation) |

---

## 5. Edge Cases & Error Handling

| Scenario | Behaviour |
|----------|-----------|
| No workout sessions recorded | Empty state |
| Sessions recorded but no trackable sets | Empty state (OQ-1 dependency: depends on what qualifies as a PB) |
| One exercise only | Main state; single pb-card |
| Drift read error | Error state; retry available |
| Very long exercise name | pb-name clips to 1 line with ellipsis — **OQ-4** |
| pb-badge value format for time exercises | `MM:SS` (e.g. 01:10) — **OQ-5** |
| pb-badge value format for weighted | `{N} kg` — unit localisation TBD (OQ-6) |
| PB broken later (new session improves it) | Badge updates on next read; no animation on push — **OQ-7** |
| 0 seconds timed exercise | Edge case — OQ-8 |
| Very large weight (e.g. 1000+ kg) | Truncation strategy not designed — OQ-9 |
| Screen rotated (landscape) | In scope per platform guidance (§6); no landscape artboard |

---

## 6. Responsive & Platform Considerations

**Platform**: iOS and Android. Flutter `MaterialApp` / Cupertino-style pushed route.

| Consideration | Detail |
|---------------|--------|
| Screen height | 390×844 reference. Shorter devices (SE 2nd gen: 375×667) may clip list; `overflow-y:auto` handles this |
| Safe areas | Status bar (28px) excluded; bottom safe area covered by `padding-bottom:28px` on content |
| No navbar | Screen is modal/pushed — bottom safe area is naked. `28px` content bottom padding covers home indicator on iPhone |
| Back affordance | Back arrow explicit; Android back gesture also supported |
| Appbar bottom padding | `4px` (vs root-tab `10px`) — pushed screens use the smaller value throughout FLOW-09 |

---

## 7. Accessibility

| Element | Requirement |
|---------|-------------|
| Back arrow | Semantic label: "Back" (or "Go back to Statistics") |
| pb-card | Read as one unit: "{exercise name}. {type} exercise. Personal best set {date}. {value}." (OQ-1 shapes the "{value}" label) |
| pb-badge-label | `9px` is below readable threshold — engineering must use `semanticsLabel` override or hide from a11y tree and fold into pb-card announcement |
| empty-icon | Decorative; `excludeFromSemantics: true` |
| err-icon | Decorative; `excludeFromSemantics: true` |
| Retry button | Min tap target 44pt; current padding gives ~40px height — OQ-10 |
| Color-only type-dot | Not sole differentiator; exercise name and metric label provide independent context |
| Screen title | Announced on push: "Personal Bests" |

---

## 8. Component & Design System Mapping

### Existing components (no new work needed)

| Component | Reused from | Notes |
|-----------|-------------|-------|
| err-card | SCR-20/21/22/23 | Identical pattern |
| retry-btn | SCR-20/21/22/23 | `lime; #131315; 800/13px; radius:10px; padding:11px 22px; margin-top:4px` |
| type-dot | SCR-23 (ex-card) | Same 8×8; radius:50%; lime/cyan/muted semantics |
| alert-triangle SVG | SCR-20/21/22/23 | Same paths |
| Back arrow | SCR-21 (SCR-21 pushed pattern) | `22×22; white; stroke-width:2; M15 18l-6-6 6-6` |
| Overlay/detail appbar | Multiple pushed screens | `18px/800/.02em` title; `padding:6px 20px 4px` |
| bg-position shimmer | SCR-20 | `card-alt → shimmerMid → card-alt; 400% size; ease 1.4s` |

### New components (SCR-24 specific)

| Component | Description |
|-----------|-------------|
| **pb-card** | Exercise row with type-dot, pb-body (name + meta), pb-badge. First card with a right-side badge in the system. |
| **pb-badge** | Value + label badge (card-alt bg; border; radius:10px; padding:8px 12px). Distinct from ex-card right column in SCR-23 (no bg, no border). |
| **sk-row (SCR-24 variant)** | Three-part loading skeleton: dot + animated line + static badge. Dot and badge are non-animated; only line shimmers. |
| **empty-icon (SCR-24)** | Trophy SVG 52×52 — same icon as pb-icon in SCR-23 but larger (52 vs 16) and dim (not lime). |

### Token gaps (flag for token PR)

| Raw value | Proposed token | First seen | Status |
|-----------|---------------|-----------|--------|
| `#35342f` | `color.shimmerMid` | SCR-20 | Established — reused here |
| `#5c3a3a` | `color.dangerBorder` | SCR-20 | Established — reused here |
| `font-size:9px` | `text.axisLabel` | SCR-22 | Established in SCR-22 (chart axis). pb-badge-label reuses same size, different context — confirm shared token or split. |
| `letter-spacing:.03em` | `tracking.badgeLabel` | SCR-24 | **NEW** — not same as `.06em` section-label tracking |
| `font-size:14px` | `text.cardTitle` | SCR-24 | **NEW** — pb-name is 14px; not yet in token scale |
| `border-radius:10px` | `radius.dialogButton` | SCR-21/22/23 | Established — pb-badge reuses |
| `font-weight:800` | `weight.heavy` | System-wide | Ongoing |

---

## 9. Acceptance Criteria Mapping

These map to the ACs in `Doc/UserStories/SCR-24-Personal-Bests.md`:

| AC | Design mapping |
|----|---------------|
| AC-1: Loading shown on entry | Loading state: 5 sk-rows with bg-position shimmer; no content flash |
| AC-2: Empty state when no PBs | Empty state: trophy icon + "No personal bests yet" + sub-copy; no CTA |
| AC-3: List of PBs when records exist | Main state: pb-cards; one per exercise; type-dot, name, date, badge |
| AC-4: Error state on failure | Error state: err-card; "Couldn't load your personal bests"; Retry button |
| AC-5: Retry reloads | Retry tap → Loading → Main or Empty |
| AC-6: Back returns to SCR-23 | Back arrow always present; pops pushed route |

> **AC-3 caveat**: The badge value (metric) and badge label cannot be finalised until OQ-1 is resolved. AC-3 implicitly depends on Decisions Log §3.

---

## 10. Open Questions / Assumptions

### Blocking (must resolve before engineering picks up)

| ID | Question | Impact |
|----|----------|--------|
| **OQ-1** | Which metric defines a "personal best"? (heaviest weight, highest reps, highest volume, longest duration — or per-type?) | Determines what Drift query to run, badge value, badge label, and empty-state trigger condition. All of Main state is blocked. |
| **OQ-2** | What is the production badge label once OQ-1 is resolved? "Best weight" / "Best reps" / "Best time"? Per-row or fixed? | pb-badge-label copy and layout |
| **OQ-3** | pb-meta date format: "Set Aug 31, 2026" — locale-aware or fixed en-US? | Drift date field format; display logic |

### Non-blocking (design can proceed; engineering should flag)

| ID | Question | Default assumption |
|----|----------|--------------------|
| OQ-4 | Long exercise name: ellipsis at 1 line or 2-line wrap? | 1 line + ellipsis (consistent with ex-card in SCR-23) |
| OQ-5 | Time badge value format: `01:10` or `1:10` or `1m 10s`? | `MM:SS` — matches SCR-23 artboard ex-right-value |
| OQ-6 | Weighted badge value units: `kg` fixed or localised to `lbs`? | Follows global unit setting (assumed from user profile; not yet specced) |
| OQ-7 | PB update behaviour: does badge update in real time (reactive stream) or on next entry? | On-entry read; no reactive stream needed for this screen |
| OQ-8 | 0-second timed PB edge case: show `00:00`? | Show `00:00` |
| OQ-9 | Very large badge value (e.g. 1000+ kg): truncation? | No truncation yet designed; flag to PM if realistic |
| OQ-10 | Retry button ~40px height — below 44pt target; remediation? | Engineering adds min-height:44px in Flutter semantics |
| OQ-11 | pb-badge-label `9px` — matches `text.axisLabel` (SCR-22 chart axis). Share token or split? | Confirm with token PR; label context differs (chart vs badge) |
| OQ-12 | `letter-spacing:.03em` on pb-badge-label — new `tracking.badgeLabel` token? | New token; propose in token PR |
| OQ-13 | `font-size:14px` on pb-name — new `text.cardTitle` token? | New token; 14px not yet in scale |
| OQ-14 | Sort order for pb-card list: alphabetical, by date set (most recent first), by exercise type? | Not designed — OQ |
| OQ-15 | Max PB records shown: all, or capped at N? | No cap in artboard; all records shown |

### Assumptions (design decisions inferred from artboard)

- pb-cards are **read-only**: no tap action, no disclosure chevron.
- Empty state has **no CTA button** (contrast: SCR-23 has "Start a Workout"). This is intentional — confirmed by artboard.
- The design-note amber banner (`#2a2610`/`#d9c94a`) is a designer annotation only and **must not ship**.
- No navbar in any state — confirmed across all 4 artboards.
- `overflow-y:auto` only in Main state; Loading/Empty/Error do not scroll.
