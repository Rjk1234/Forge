# ADR-022 Responsive Architecture

Version: 2.0 (ForgeApp — Reduced Scope)

Status: Accepted (Reduced Scope)

---

> **Changelog**
> - **2.0 (2026-09-08):** Reduced for ForgeApp. Removed the day-one tablet/iPad requirement and
>   the compact/medium/expanded multi-pane breakpoint system entirely — every screen in the
>   ForgeApp Design System was designed at a single 390×844 phone frame (see
>   `Doc/DESIGN-SYSTEM.md`), and no user story implies a tablet layout. Reduced to a single-form-
>   factor, portrait-primary policy appropriate for a POC.

---

## Context

ForgeApp targets a single phone form factor. All 22 designed screens use a fixed 390×844 phone
artboard (`Doc/DESIGN-SYSTEM.md`). There is no tablet, iPad, or multi-pane requirement anywhere in
the PRD, SRS, or SDS.

---

## Decision

ForgeApp supports phones only, portrait-primary. Layouts should not hardcode pixel dimensions
beyond what the Design System's spacing/radius tokens already specify, but no compact/medium/
expanded breakpoint system, two-pane layout, or tablet/iPad testing matrix is implemented.

Landscape support is not required for this POC; if a screen happens to work in landscape by
virtue of standard Flutter layout widgets, that is incidental, not a tested requirement.

---

## Layout Strategy

- Single Flutter codebase, single layout per screen, matching the already-published Design System
  artboards.
- `Theme.of(context)` and the Design System's spacing/radius tokens (ADR-037) are the only sizing
  inputs — no device-model or OS branching.

---

## Prohibited

- Building a two-pane/tablet layout speculatively for screens that only have a phone design
- Device-model or OS-version branching for layout decisions

---

## Alternatives Considered

### Full Responsive/Adaptive Architecture (phone + tablet + iPad)

Rejected for this POC — no design, story, or requirement calls for it, and building it would be
scope creep against the "enough, not too much" principle held throughout this project. Revisit if
ForgeApp is ever taken toward a broader release.

---

## Consequences

### Positive

- Matches the already-designed screens exactly; no redesign work needed
- Minimal implementation and testing surface

### Negative

- Not tablet/iPad-ready; a future expansion would need real responsive-architecture work

---

## Related ADRs

* ADR-021 Performance Architecture
* ADR-037 Theme Architecture
