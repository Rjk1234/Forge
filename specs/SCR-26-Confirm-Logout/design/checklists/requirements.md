# Design Requirements Checklist: SCR-26 — Confirm Logout

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/85ccb11f-db55-4312-a70a-9d63287ec4a4

> ⚠️ **Blocking**: OQ-1 (scrim tap behaviour), OQ-2 (back gesture), and OQ-4 (tap target height ~39px < 44pt minimum) must be resolved before handoff.

---

## Layout & Structure

- [ ] Screen type confirmed as modal overlay — NOT a pushed screen; no appbar of its own
- [ ] No navbar in any state ✅
- [ ] SCR-25 appbar rendered behind scrim at `opacity: 0.3`
- [ ] SCR-25 content rendered behind scrim at `opacity: 0.2; filter: grayscale(0.4)`
- [ ] Scrim: `position:absolute; inset:0; background:rgba(10,10,10,.62); flex; center`
- [ ] Scrim horizontal padding: `0 30px` (constrains dialog to ~330px on 390px canvas)

## Dialog Container

- [ ] `background: #201f22` (color.card)
- [ ] `border: 1px solid #444933` (color.border)
- [ ] `border-radius: 18px` — **NEW token `radius.dialog`** (distinct from `radius.dialogButton` = 10px)
- [ ] `padding: 24px 20px`
- [ ] `flex-col; align-items:center; text-align:center; gap:10px`
- [ ] `width: 100%` within scrim padding

## Icon Wrap

- [ ] `width: 52px; height: 52px; border-radius: 50%; background: #2a2a2c (cardAlt)`
- [ ] `display:flex; align-items:center; justify-content:center; margin-bottom:2px`
- [ ] Contains: `24×24; color:#c4c9ac (muted); stroke-width:1.8`
- [ ] SVG paths (door-with-arrow logout icon):
  - `<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>`
  - `<path d="M16 17l5-5-5-5"/>`
  - `<path d="M21 12H9"/>`
- [ ] Icon is **muted colour** (#c4c9ac) in dialog — NOT danger red (different from SCR-25 logout-row)
- [ ] Icon size is 24px — larger than SCR-25 logout-row (16px)

## Dialog Title

- [ ] `font-size: 16px; font-weight: 800`
- [ ] Color: `color.white` (#f5f6f1) — inherited
- [ ] Exact copy: **"Log out?"** (lowercase 'o', question mark)

## Dialog Sub-copy

- [ ] `font-size: 13px; color: #c4c9ac (muted); line-height: 1.5`
- [ ] Exact copy: **"You'll need to unlock the app again to continue. Your workout data stays right where it is."**
- [ ] Sub-copy is **load-bearing UX copy** — do not paraphrase or shorten

## Dialog Actions Row

- [ ] `display:flex; gap:10px; width:100%; margin-top:8px`
- [ ] Two buttons, each `flex:1` (equal width)

## Cancel Button

- [ ] `flex:1; border-radius:10px; padding:13px; text-align:center; font-weight:800; font-size:13px`
- [ ] `background: #2a2a2c (cardAlt); color: #f5f6f1 (white); border: 1px solid #444933 (border)`
- [ ] Label: **"Cancel"**
- [ ] Action: dismiss modal → return to SCR-25, no state changes

## Log Out Button

- [ ] `flex:1; border-radius:10px; padding:13px; text-align:center; font-weight:800; font-size:13px`
- [ ] `background: #ff6b6b (danger); color: #2a1010` — **NEW token `color.dangerDark`**
- [ ] **No border** (unlike Cancel)
- [ ] Label: **"Log Out"** (capital L, capital O)
- [ ] Action: reset login-state flag → navigate to SCR-01 / SCR-03

## Behaviour

- [ ] Tapping Cancel: modal dismissed, SCR-25 fully restored and interactive
- [ ] Tapping Log Out: login-state flag reset synchronously; navigate to SCR-01 (or SCR-03 if no PIN)
- [ ] SCR-25 and SCR-26 removed from navigation stack on confirm
- [ ] **Drift data NOT deleted** — SR-2 compliance: only login-state flag is reset
- [ ] Log Out tap debounced (prevent double-trigger)
- [ ] No loading state shown — logout is instantaneous (local operation)
- [ ] No error state — no failure state designed (Inventory: no Error UC row)

## New Token / Component Summary (first modal/dialog in system)

- [ ] `rgba(10,10,10,.62)` → `color.scrim` — **NEW** (first modal scrim in system)
- [ ] `border-radius:18px` → `radius.dialog` — **NEW** (alert-dialog container)
- [ ] `#2a1010` → `color.dangerDark` — **NEW** (text on danger-red button; analogous to `#131315` on lime)
- [ ] **dialog** — new component (first alert dialog in system)
- [ ] **dialog-icon-wrap** — new sub-component
- [ ] **dialog-btn.cancel** — new button variant (cardAlt + border)
- [ ] **dialog-btn.logout** — new button variant (danger fill)

## Accessibility Checkpoints

- [ ] Modal announced as alert dialog; focus trapped within dialog while open
- [ ] dialog-icon: `excludeFromSemantics: true` (decorative)
- [ ] dialog-title: read as dialog label ("Log out?")
- [ ] dialog-sub: included in screen reader traversal; not hidden
- [ ] Cancel: accessible label "Cancel"
- [ ] Log Out: accessible label "Log Out" — danger colour alone is not enough
- [ ] Focus order: icon → title → sub → Cancel → Log Out
- [ ] Scrim tap (if treated as Cancel): modal dismissed, announced
- [ ] Tap target: both buttons `padding:13px` → ~39px height — **below 44pt minimum** (OQ-4 blocking)

## Open Questions (blocking)

- [ ] **OQ-1** — Scrim tap: Cancel (dismiss) or blocked?
- [ ] **OQ-2** — Back gesture (Android hardware back / iOS swipe): Cancel or blocked?
- [ ] **OQ-4** — Tap targets ~39px < 44pt: increase padding or add min-height?

## Open Questions (non-blocking)

- [ ] OQ-3 — Login-state flag reset failure: silent, or generic error toast?
- [ ] OQ-5 — Logout routing: always SCR-01, or conditional on PIN being configured?
- [ ] OQ-6 — Modal entry animation: fade + slide-up, or instant?

---

*OQ-1, OQ-2, and OQ-4 are blocking. All other OQs may be resolved during engineering without a spec revision.*
