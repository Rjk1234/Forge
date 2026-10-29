# Design Requirements Checklist: SCR-27 — Cross-Cutting / Global States

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/1ca4e390-31a8-43a5-93ca-a1acf6e7b084  
**Artboards**: `Main.dc.html` (Read-Error template), `WriteError.dc.html` (Write-Error template)

> ⚠️ **Blocking**: OQ-1 (write-retry in-flight state), OQ-2 (partial read failure), and OQ-3 (retry-btn tap target < 44pt) must be resolved before handoff. OQ-4 (muted contrast) should be triaged across all screens using color.muted at 13px.

> ℹ️ **Cross-cutting scope**: This checklist verifies the template patterns. Per-screen instantiation is verified in each screen's own checklist.

---

## Template Scope

- [ ] SCR-27 confirmed as a cross-cutting pattern spec — NOT an independently navigated screen
- [ ] Removed scenarios confirmed absent from spec: connectivity/offline banner, invalid-session state, cross-user data rejection
- [ ] Two templates defined: Read-Error (FR-1/AC-2) and Write-Error (FR-2/AC-3)
- [ ] Artboard footnotes noted as design-canvas decorations — NOT shipped UI

---

## Shared err-card Structure (both templates)

- [ ] `background: #201f22 (color.card)`
- [ ] `border: 1px solid #5c3a3a (color.dangerBorder)`
- [ ] `border-radius: 16px`
- [ ] `padding: 28px 20px` — **normative; overrides prior per-screen values of 26px**
- [ ] `flex-col; align-items:center; gap:12px`
- [ ] `width:100%` constrained by `padding:0 32px` content wrapper
- [ ] Content area: `flex-col; align-items:center; justify-content:center; padding:0 32px; text-align:center; gap:14px`

---

## Read-Error Template (Main.dc.html — FR-1 / AC-2)

### err-icon (alert-triangle)

- [ ] `width:44px; height:44px` — **normative; overrides prior 40×40**
- [ ] `color: #ff6b6b (color.danger)`
- [ ] `stroke-width: 1.5` — **normative; overrides prior 1.6**
- [ ] SVG paths:
  - `<path d="M12 3l10 18H2L12 3z"/>` — triangle body
  - `<path d="M12 10v4"/>` — vertical bar
  - `<circle cx="12" cy="17" r="0.6" fill="currentColor"/>` — dot

### err-title

- [ ] `font-size: 17px` — **normative; overrides prior 16px**
- [ ] `font-weight: 800`
- [ ] Color: `color.white` (inherited)
- [ ] Template copy (illustrative): "Couldn't load this data"
- [ ] Copy pattern confirmed: "Couldn't load [screen-specific noun]"

### err-sub

- [ ] `font-size: 13px; color: #c4c9ac (muted); line-height: 1.5`
- [ ] Template copy: "Something went wrong reading from local storage.\nYour data is safe — try again."
- [ ] **NO err-note element** — err-note appears only in Write-Error template

### retry-btn

- [ ] `margin-top:4px; background:lime; color:#131315; font-weight:800; font-size:13px`
- [ ] `border-radius:10px (radius.dialogButton); padding:12px 24px` — **normative; overrides prior 11px 22px**
- [ ] Label: "Retry"
- [ ] Action: re-triggers Drift read → Loading state first → content or error again
- [ ] Button debounced / disabled during in-flight read

### Behaviour

- [ ] Distinguishable from validation errors: full err-card replaces content area (not inline field error)
- [ ] Alert-triangle icon vs NO icon in validation states — visually distinct
- [ ] Back navigation remains active while error is shown
- [ ] Retry transitions through Loading state before showing content

### Screens this template applies to (verify these instantiations)

- [ ] SCR-12 (if applicable) — confirm err-card values against template
- [ ] SCR-20 — verify icon 44px, padding 28px, title 17px, btn 12px 24px
- [ ] SCR-21 — same
- [ ] SCR-23 — same
- [ ] SCR-24 — same (currently specced at 40px / 26px / 16px — needs update)
- [ ] SCR-25 (load error) — same (currently specced at 40px / 26px / 16px — needs update)

---

## Write-Error Template (WriteError.dc.html — FR-2 / AC-3)

### err-icon (calendar + exclamation)

- [ ] `width:44px; height:44px; color:danger; stroke-width:1.5`
- [ ] SVG paths:
  - `<rect x="4" y="5" width="16" height="15" rx="2"/>` — body
  - `<path d="M4 10h16M8 3v4M16 3v4"/>` — header line + pins
  - `<path d="M12 13v-2M12 16.2v.1"/>` — embedded exclamation
- [ ] Icon is **distinct from Read-Error alert-triangle** — allows user to identify write vs read failure

### err-title

- [ ] `font-size: 17px; font-weight: 800`
- [ ] Template copy (illustrative): "Couldn't save this change"
- [ ] Copy pattern: "Couldn't save [screen-specific noun]"

### err-sub

- [ ] `font-size: 13px; color: muted; line-height: 1.5`
- [ ] Template copy: "Something went wrong writing to local storage. It has not been saved."
- [ ] Copy confirms write did NOT happen ("It has not been saved." / "Your [noun] has not been updated.")

### err-note (Write-Error only — REQUIRED)

- [ ] `font-size: 12px; color: #8a8f7a (dim); line-height: 1.5; margin-top: -2px`
- [ ] Copy is **FIXED** — do not substitute: "Nothing was recorded — retrying won't create a duplicate."
- [ ] err-note is **present in EVERY write-failure state** — non-optional
- [ ] err-note is NOT included in the Read-Error template

### retry-btn

- [ ] Same as Read-Error: `lime; #131315; 800/13px; radius:10px; padding:12px 24px`
- [ ] Label: "Retry"
- [ ] Action: re-attempts the exact same write with the same data (idempotent — no new payload)
- [ ] Button debounced / disabled during in-flight write

### Behaviour

- [ ] Write failure does NOT trigger any success state (no toast, no navigation)
- [ ] No duplicate persisted record on retry — requires atomic write-or-rollback at Drift level
- [ ] Back navigation remains active (no confirmation dialog needed — nothing saved)

### Screens this template applies to (verify these instantiations)

- [ ] SCR-14 — write-failure state uses this template
- [ ] SCR-16 — same
- [ ] SCR-19 — same
- [ ] SCR-25 (save error) — was OQ-8 in SCR-25 spec; unblocked by this template

---

## New Components / Tokens (flag for token PR)

- [ ] `font-size:17px` → `text.errorTitle` — NEW (normalises prior inconsistency)
- [ ] `font-size:12px (err-note)` → `text.errorNote` — NEW (distinct from 11px meta, 14px cardTitle)
- [ ] `border-radius:16px (err-card)` → `radius.errCard` — NEW (lock existing consistent usage)
- [ ] `#5c3a3a` → `color.dangerBorder` — established in earlier screens ✅
- [ ] `#ff6b6b` → `color.danger` — established ✅
- [ ] `#c3f400` → `color.lime` — established ✅
- [ ] `border-radius:10px` → `radius.dialogButton` — established ✅

---

## Accessibility Checkpoints

- [ ] err-icon: `excludeFromSemantics: true` (decorative)
- [ ] err-card announces as alert or live region on first display
- [ ] err-title: heading role or first focusable element (screen reader reads it first)
- [ ] err-sub: in reading order, not excluded
- [ ] err-note (write): in reading order, not excluded — functional information
- [ ] retry-btn: labelled "Retry"; role: button
- [ ] retry-btn tap target: padding 12px → ~37px — **below 44pt** (OQ-3 blocking)
- [ ] retry-btn in-flight: disabled state announced; focus managed
- [ ] colour.muted (13px/400) on colour.card: ~4.0:1 contrast — review needed (OQ-4)

---

## Open Questions (blocking)

- [ ] **OQ-1** — Write retry in-flight state: full Loading, button spinner, or overlay?
- [ ] **OQ-2** — Partial data-source failure: full err-card or section-level error?
- [ ] **OQ-3** — retry-btn tap target ~37px < 44pt: increase padding or add minHeight?

## Open Questions (non-blocking)

- [ ] OQ-4 — color.muted at 13px/400 contrast: ~4.0:1 — confirm accepted or token adjustment needed
- [ ] OQ-5 — Non-retryable write operations (e.g., delete): need variant without Retry button?
- [ ] OQ-6 — Final per-screen copy confirmed with SRS/SDS owner for each instantiation
- [ ] OQ-7 — SCR-25 save-failure (was OQ-8 in SCR-25): confirm Write-Error template is sufficient

---

*OQ-1, OQ-2, and OQ-3 are blocking. All other OQs may be resolved during engineering without a spec revision.*
