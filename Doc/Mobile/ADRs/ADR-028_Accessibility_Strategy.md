# ADR-028 Accessibility Strategy

Version: 2.0 (ForgeApp — Reduced Scope)

Status: Accepted (Reduced Scope)

---

> **Changelog**
> - **2.0 (2026-09-08):** Reduced for ForgeApp. Removed all tablet/iPad keyboard-and-pointer
>   validation requirements (phone-only, see ADR-022) and the full WCAG 2.1 AA release-matrix
>   testing regime. Kept the core visual-accessibility baseline (contrast, tap targets, no
>   color-only indicators) as good practice at low implementation cost, since the Design System
>   already follows most of it by construction.

---

## Context

ForgeApp targets a single local user on a single phone form factor as a POC/MVP. A full WCAG 2.1
AA conformance program (including tablet keyboard/pointer validation) is disproportionate to this
scope, but basic visual-accessibility hygiene (contrast, tap target size, not relying on color
alone) costs little and the Design System already follows these conventions.

---

## Decision

ForgeApp adopts a lightweight visual-accessibility baseline, informed by (but not formally
certified against) WCAG 2.1 AA:

- Minimum 48×48 logical-pixel tap targets for interactive elements
- Color is never the only indicator of state (the Design System already uses icon + color + label
  together, e.g. the exercise type-flag dot + label)
- Text and interactive elements should have reasonable contrast against the dark background
  (the Design System's palette — `#f5f6f1` text on `#131315`/`#201f22` — already provides this)
- Dynamic text scaling should not clip or overlap critical text where practical

There is no screen-reader (TalkBack/VoiceOver) support, no formal conformance audit, and no
tablet/keyboard/pointer validation — all deferred beyond POC scope.

---

## Prohibited

- Interactive elements with no visible label or icon
- Tap targets smaller than 48×48 logical pixels
- Using color alone to communicate error or status

---

## Alternatives Considered

### Full WCAG 2.1 AA Certification Program

Rejected for this POC — the audit/testing overhead is not justified at this scope. Revisit if
ForgeApp moves toward a broader release.

---

## Consequences

### Positive

- Reasonable baseline usability at near-zero added cost, since the Design System already follows
  most of it

### Negative

- Not screen-reader accessible; not a certified conformance level

---

## Related ADRs

* ADR-022 Responsive Architecture
* ADR-027 Loading Empty Error States
* ADR-037 Theme Architecture
