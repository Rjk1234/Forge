# ForgeApp Design System — Reference

Consolidated from the visual language actually used across all 22 designed screens (SCR-06 through SCR-27). This documents what was built, not a new invention. Values are given as ready-to-paste tokens; adapt names to whatever theme/constants convention the app's codebase uses (Flutter `ThemeData`/`ColorScheme`, a `tokens.dart`, CSS variables, etc.).

**Live visual reference (interactive canvas):** https://claude.ai/code/artifact/b7f5a669-ced7-4d53-9e82-60feb385a5b2
**Local static snapshot:** `forgeapp-design-system.html` (same folder as this file)

Status: this is a design reference derived from POC/MVP-scope mockups, not a signed-off brand system. Treat two colors as reserved/limited-use, not general-purpose (flagged below).

---

## 1. Color

| Token | Hex | Usage |
|---|---|---|
| `color.bg` | `#131315` | Page / screen background |
| `color.card` | `#201f22` | Cards, rows, panels, modals |
| `color.cardAlt` | `#2a2a2c` | Nested surfaces, input fields, secondary buttons |
| `color.border` | `#444933` | All card / field borders (1px) |
| `color.lime` (primary) | `#c3f400` | Primary actions, active states, progress fills |
| `color.textMuted` | `#c4c9ac` | Secondary / supporting text |
| `color.white` (primary text) | `#f5f6f1` | Primary text, icons on dark |
| `color.textDim` | `#8a8f7a` | Labels, timestamps, disabled state |
| `color.cyan` ⚠ reserved | `#7df4ff` | **Reserved** — time-based exercise-type indicator dot only. Not a general UI color. |
| `color.danger` | `#ff6b6b` | Destructive actions, error text/icons |
| `color.dangerBg` | `#2a1f1f` | Error card fill |
| `color.dangerBorder` | `#5c3a3a` | Error card border |
| `color.amber` ⚠ reserved | `#d9c94a` | **Reserved** — open-decision design-note banners only (e.g. SCR-24's deferred "personal best" metric). Never a normal UI color. |
| `color.amberBg` | `#2a2610` | Design-note banner fill |
| `color.amberBorder` | `#6b5f22` | Design-note banner border |

**Convention:** destructive/irreversible actions (delete plan, cancel active workout, logout) use `danger`; easily-reversible actions (remove from schedule) use `lime` instead.

---

## 2. Typography

Font stack: `'Helvetica Neue', Arial, sans-serif` (system fallback throughout — no external font loading).

| Role | Size / Weight | Usage |
|---|---|---|
| Page Title | 22px / 800 | Root-tab & app-bar titles (Home, Progress, Stats…) |
| Screen Title | 18px / 800 | Detail-screen app-bar titles (with back button) |
| Section Label | 12px / 800, uppercase, letter-spacing .05–.06em, dim color | Section headers within a screen |
| Body — Strong | 13–14px / 700 | Card titles, field values, primary list text |
| Body — Regular | 12–13px / 600, muted color | Supporting copy, descriptions |
| Meta / Caption | 11px / 600, muted color | Timestamps, counts, sub-labels |
| Micro Label | 9–10px / 700, uppercase, dim color | Stat-tile & field labels |

---

## 3. Spacing Scale

A loose 2px-based scale actually used across screens (not a strict 4/8 grid):

`4, 6, 8, 10, 12, 14, 16, 20, 24` (px)

---

## 4. Corner Radius

| Radius | Usage |
|---|---|
| 8px | Small chips |
| 10px | Inputs, buttons |
| 12px | Fields, actions |
| 14px | Cards, rows |
| 16px | Large cards |
| 18px | Modals / dialogs |
| Pill (38px) | Chips, avatars |

---

## 5. Iconography

Line icons only — 24×24 viewBox, ~1.6–2px stroke, no fill (outline style), `currentColor` (inherits text color). Icon set used: Home, Plans, Schedule, History, Progress, Stats (bottom-nav set), plus Back, Chevron, Success (check), Warning/Error, Storage Error, Logout.

---

## 6. Components

- **Buttons:** Primary (lime fill, dark text, 10px radius), Secondary (card-alt fill + border), Destructive (danger fill), Disabled (card-alt, dimmed, 60% opacity).
- **Input fields:** 44px height, 12px radius, card-alt fill, 1px border; error state swaps border to `danger` with an 11px red helper line below.
- **Segmented control:** card-alt track, 10px radius, active segment fills lime. Used for 2–3 way mutually-exclusive choices (e.g. units toggle).
- **Chips/tags:** pill radius; active = lime fill, inactive = card-alt + border + muted text. Used for multi-select filters (exercise selector, muscle-group filters).
- **Exercise type-flag system:** every exercise carries exactly one type flag, shown as a colored dot + label, which determines its logging fields:
  - `weighted` → lime dot → Reps + Weight fields
  - `time-based` → cyan dot (reserved color) → Duration field only
  - `bodyweight` → dim/muted dot → Reps field only
- **App bar (detail screens):** back chevron + screen title, no elevation, transparent over page background.
- **Bottom navigation (root tabs only):** fixed 6-tab bar — Home, Plans, Schedule, History, Progress, Stats. Used only on true root-tab screens (SCR-06, SCR-08, SCR-12, SCR-20, SCR-22, SCR-23); every other screen uses the app-bar-with-back pattern instead.
- **Cards/rows:** 16px radius, card fill, 1px border, standard title (Body-Strong) + sub (Body-Regular) stack.

---

## 7. Patterns & States

- **Loading:** skeleton blocks (circle avatar + line placeholders) in `cardAlt`, no spinner.
- **Empty state:** centered icon in a circular `cardAlt` badge + title + muted supporting copy explaining the next action. Never a bare blank screen.
- **Error / retry (generic templates, SCR-27):** two reusable templates — a recoverable local-read-failure state, and a local-write-failure state that never represents a failed write as successful and never duplicates a record on retry. Every screen-specific error (SCR-12/14/16/19/20/21/23/25) instantiates one of these with contextual copy.
- **Confirmation modal:** scrim + centered dialog, 18px radius. Destructive variant uses the danger button; non-destructive variant uses the lime button. See the destructive/reversible convention under Color.
- **Toast / save confirmation:** brief lime-accented row with a check icon, shown after a successful save (SCR-25 Profile).
- **Open-decision design note (amber, reserved):** used exclusively to flag a design decision still open in the Inventory/Decisions Log (e.g. SCR-24's deferred "personal best" metric) — a visible signal that a value on-screen is a placeholder, not settled product spec. Never used for anything the product has actually decided.
- **Inline validation:** field border switches to `danger`, an 11px red helper line appears directly below the field.

---

## 8. Scope Note

This is a POC/MVP-scope design reference. It documents only what the 22 designed screens actually contain — no additional components, states, or colors have been invented beyond what those screens use. Where a story left something explicitly undecided (SCR-24's personal-best metric), the design system reflects that as an open item, not a resolved default.
