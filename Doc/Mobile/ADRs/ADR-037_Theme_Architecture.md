# ADR-037 Theme Architecture

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed light/dark theme switching, the
>   `AppThemeBloc`, and Drift-persisted theme preference entirely — none of the 22 designed
>   ForgeApp screens (SCR-06–SCR-27) include a theme toggle, and the Design System
>   (`Doc/DESIGN-SYSTEM.md`) defines exactly one dark visual language. ForgeApp ships a single,
>   fixed theme composed directly from the already-published Design System tokens — there is no
>   design_system/ "deferred" note here, because the foundations work is already done.

---

## Context

ForgeApp already has a complete, approved Design System (`Doc/DESIGN-SYSTEM.md`): 12 color
tokens, 7 typography roles, a spacing scale, a corner-radius scale, and an icon style, all derived
from the 22 already-designed screens. No screen in the user stories includes a theme toggle or
light-mode variant. The architecture need here is narrower than a typical app: compose one
`ThemeData` from tokens that already exist, and make sure no feature widget hardcodes a color
that bypasses them.

---

## Decision

The application shall compose a single, fixed dark `ThemeData` from the Design System tokens, and
resolve all colors/text styles through `Theme.of(context)` — never hardcoded in feature widgets.
There is no theme switching, no `AppThemeBloc`, and no persisted theme preference, because there
is nothing to switch between.

---

## Architecture

```text
lib/config/theme/
└── app_theme.dart     # AppTheme.dark : ThemeData — composed once from Doc/DESIGN-SYSTEM.md tokens
```

### Token Mapping (from `Doc/DESIGN-SYSTEM.md` §1–§4)

```text
ColorScheme.surface        → #131315 (bg)
ColorScheme.surfaceContainer → #201f22 (card) / #2a2a2c (card-alt)
ColorScheme.outline         → #444933 (border)
ColorScheme.primary         → #c3f400 (lime)
ColorScheme.onSurfaceVariant → #c4c9ac (muted text) / #8a8f7a (dim text)
ColorScheme.onSurface       → #f5f6f1 (white/primary text)
ColorScheme.error           → #ff6b6b (danger)
(custom extension colors)   → #7df4ff (cyan — reserved, time-based type-flag dot only)
                              #d9c94a (amber — reserved, open-decision design-note banners only)

TextTheme.headlineSmall  → Page Title   (22px/800)
TextTheme.titleLarge     → Screen Title (18px/800)
TextTheme.labelSmall     → Section Label (12px/800/uppercase/dim)
TextTheme.bodyLarge      → Body-Strong  (13–14px/700)
TextTheme.bodyMedium     → Body-Regular (12–13px/600/muted)
TextTheme.bodySmall      → Meta/Caption (11px/600/muted)
TextTheme.labelSmall (alt)→ Micro Label (9–10px/700/uppercase/dim)
```

The two reserved colors (cyan, amber) are exposed as a custom `ThemeExtension`, not as
`ColorScheme` roles — this keeps their "reserved, not general-purpose" status explicit in code,
matching the Design System's own documentation.

---

## Token Access in Widgets

```dart
// Correct
final color = Theme.of(context).colorScheme.primary;
final style = Theme.of(context).textTheme.bodyLarge;

// Prohibited
const color = Color(0xFFC3F400);  // hardcoded in a feature widget
```

Raw `Color(0x...)` literals are permitted only inside `app_theme.dart` for the initial token
composition — never in feature widgets.

---

## Prohibited

- Hardcoded color values in any feature widget
- A second theme (light mode) or a theme switcher, absent a genuine future design decision to add
  one
- Reusing the reserved cyan/amber colors outside their documented single use each

---

## Alternatives Considered

### Light + Dark with a Theme Toggle

Rejected — no designed screen has one, and building a switcher for a mode that will never be
shown would be scope creep on a POC.

### `ColorScheme.fromSeed`

Rejected in favor of directly composing the `ColorScheme` from the already-fixed Design System
palette — there is no seed-derivation step needed when every token is already specified exactly.

---

## Consequences

### Positive

- Zero theme-switching state to manage or test
- Direct, traceable mapping from the published Design System to code — no re-deriving colors

### Negative

- If a future decision adds light mode or user-selectable themes, this ADR needs a real rewrite
  (back toward the Bloc-driven model this version removed) — not a concern for the current scope

---

## Related ADRs

* ADR-032 Modularization Strategy
