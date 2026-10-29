# Design Requirements Checklist: SCR-25 — Profile / Account

**Purpose**: Validate design specification completeness before handoff to engineering  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/d9763b67-d7b2-46f0-adcd-6b6617e84d9e

> ⚠️ **Blocking**: OQ-1 (Fitness Goal picker mechanism/options), OQ-2 (units), OQ-3 (display name validation), OQ-8 (save-failure state), and OQ-9 (back with unsaved changes) must be resolved before handoff.

---

## Layout & Structure

- [ ] Screen type confirmed as pushed (overlay/detail tier) — NOT a root tab
- [ ] No navbar in any of the 5 states ✅
- [ ] Appbar padding `6px 20px 4px` (bottom 4px) in all 5 states
- [ ] Back arrow present in all 5 states; `22×22; white; stroke-width:2; M15 18l-6-6 6-6`
- [ ] Title "Profile" at overlay/detail tier `18px/800/.02em` in all 5 states
- [ ] `overflow-y:auto` on Main, Validation, and Success content (not Loading/Error)

## Loading State

- [ ] sk-avatar: `64×64; radius:50%; card-alt bg; margin:4px auto 0` — centred
- [ ] 4 field-group skeletons, each: `sk-label (35% wide, 11px tall, radius:6px)` + `sk-field (44px tall, radius:12px)`
- [ ] Shimmer variant: translate (`translateX -100%→100%`); base `card-alt`; sheen `rgba(255,255,255,.06)` — same as SCR-21/22/23
- [ ] Content: `padding:16px 20px 24px; flex-col; gap:16px`
- [ ] No navbar ✅

## Main State — Avatar

- [ ] avatar-wrap: `flex-col; align-items:center; gap:8px; padding:4px 0 6px`
- [ ] avatar circle: `64×64; radius:50%; card-alt bg; border:1px solid border; flex center`
- [ ] avatar-icon: `30×30; dim; stroke-width:1.6` — user person SVG
  - `circle cx="12" cy="8" r="4"`
  - `path M4 20c0-4 4-6 8-6s8 2 8 6`
- [ ] Avatar is **read-only** — no tap action, no photo upload
- [ ] `.avatar-name` CSS class is defined but **NOT rendered** — confirm intentional with designer (OQ-18)

## Main State — field-group Pattern

- [ ] field-label: `11px/700/dim/uppercase/letter-spacing:.04em` (NEW tracking token `.04em`)
- [ ] field-input: `card bg; border:1px solid border; border-radius:12px; padding:13px 14px; 14px/600` (NEW radius:12px token)
- [ ] All 4 field-groups present: Display Name, Fitness Goal, Experience Level, Height+Weight

## Main State — Fitness Goal (field-select)

- [ ] field-select: same geometry as field-input + `flex; align-items:center; justify-content:space-between`
- [ ] chev-down: `16×16; dim; stroke-width:2; M6 9l6 6 6-6` (trailing element)
- [ ] Tap opens picker — mechanism and option set per OQ-1

## Main State — Experience Level (seg-row)

- [ ] seg-row: `flex; gap:8px`
- [ ] seg (inactive): `flex:1; text-align:center; card bg; border:1px solid border; border-radius:10px; padding:11px 6px; 12px/700; color:muted`
- [ ] seg.active: `lime bg; #131315; border-color:lime` (text: `12px/700`)
- [ ] Exactly 3 segments: "Beginner" · "Intermediate" · "Advanced"
- [ ] Single-select: only one active at a time

## Main State — Height + Weight (field-row-2)

- [ ] field-row-2: `flex; gap:12px`
- [ ] Each sub-group: `flex:1`
- [ ] Labels: "Height (cm)" and "Weight (kg)" — confirm units (OQ-2)
- [ ] Both are numeric inputs (numeric keyboard type on mobile)

## Main State — Save Button (Active)

- [ ] save-btn (active): `margin-top:4px; width:100%; lime bg; #131315; border-radius:14px; padding:15px; text-align:center; 800/14px`
- [ ] Label: "Save Changes"
- [ ] save-note NOT shown in Main state (only in Validation)

## Main State — Logout Row

- [ ] logout-row: `margin-top:8px; flex; align-items:center; justify-content:center; gap:8px; padding:14px`
- [ ] logout-icon: `16×16; danger (#ff6b6b); stroke-width:2` — door-with-arrow logout SVG
- [ ] logout-label: `13px/700; danger` — "Log Out"
- [ ] No background card or border — text+icon row only
- [ ] Tap navigates to **SCR-26** (not inline logout)

## Validation State — Invalid Fields

- [ ] field-input.invalid: `border-color:danger (#ff6b6b); background:#2a1f1f (dangerFill); color:danger`
- [ ] field-error: `11px/600; color:danger` — "Enter a valid positive number."
- [ ] field-error appears below the invalid field-input within the same field-group
- [ ] Both height AND weight can be simultaneously invalid — each shows its own field-error

## Validation State — Disabled Save

- [ ] save-btn (disabled): `card-alt bg; dim color; border:1px solid border; border-radius:14px; padding:15px; text-align:center; 800/14px`
- [ ] save-note: `11px/dim; text-align:center; margin-top:-8px` — "Fix the highlighted fields to save."
- [ ] Disabled save-btn is **non-interactive** (not tappable)
- [ ] save-note appears only in Validation state (not in Main)
- [ ] logout-row NOT shown in Validation artboard crop — confirm present in full scroll (OQ-19)

## Validation Trigger

- [ ] Validation fires on **save-tap** (not on blur or keystroke)
- [ ] Triggers: negative number OR non-numeric text in height or weight field
- [ ] Valid values: positive numbers (integer or decimal — OQ-5)

## Success State — Toast

- [ ] Toast is `position:absolute` — overlaid, not in scroll flow
- [ ] toast: `left:20px; right:20px; bottom:28px; background:#1e2a12; border:1px solid #4a5c22; border-radius:14px; padding:13px 16px; flex; align-items:center; gap:10px`
- [ ] toast-icon: `18×18; lime; stroke-width:2` — checkmark SVG `M20 6L9 17l-5-5`
- [ ] toast-text: `13px/700` — "Profile saved"
- [ ] Toast auto-dismisses — duration OQ-7
- [ ] Fields reflect updated values in Success state form (same form visible behind toast)

## Error State

- [ ] err-card: `card bg; #5c3a3a border; border-radius:16px; padding:26px 20px; flex-col; align-items:center; gap:12px`
- [ ] err-icon: `40×40; danger (#ff6b6b); stroke-width:1.6` — alert-triangle SVG
- [ ] err-title: `16px/800` — **"Couldn't load your profile"**
- [ ] err-sub: `13px/muted; line-height:1.5` — "Something went wrong reading local data.\nRetry to try again — your saved profile is unaffected."
- [ ] retry-btn: `lime bg; #131315; 800/13px; border-radius:10px; padding:11px 22px; margin-top:4px`
- [ ] Content: `flex-col; align-items:center; justify-content:center; padding:0 32px; gap:14px`
- [ ] No navbar ✅
- [ ] Save-failure state (not load-failure) is **not artboarded** — OQ-8 blocking

## New Component Summary (first form screen)

- [ ] avatar-wrap — new; user circle icon; read-only
- [ ] field-group — new; universal label+input container
- [ ] field-input — new; first editable text field in system
- [ ] field-select — new; first picker trigger in system
- [ ] seg-row + seg — new; first segmented control in system
- [ ] field-row-2 — new; first 2-column field layout in system
- [ ] save-btn (active + disabled states) — new; first full-width primary button in system
- [ ] field-input.invalid — new; first inline validation error state in system
- [ ] field-error — new; inline error message
- [ ] save-note — new; helper text below disabled save
- [ ] logout-row — new; first danger text action row in system
- [ ] toast — new; **first toast/snackbar in system**

## Token / Component Gaps (flag for token PR)

- [ ] `border-radius:12px` → `radius.field` — **NEW token needed** (field-input, field-select)
- [ ] `letter-spacing:.04em` → `tracking.fieldLabel` — **NEW** (distinct from `.06em` section-label and `.03em` badge-label)
- [ ] `#4a5c22` → `color.successBorder` — **NEW** (success toast border; not established previously)
- [ ] `font-size:14px` → `text.cardTitle` — NEW (flagged SCR-24; reused here for field values)
- [ ] `font-size:12px` — shared with section-label; `12px/700` for seg vs. `12px/800` for section-label; confirm shared size token
- [ ] `#2a1f1f` → `color.dangerFill` — established SCR-20; reused for invalid field bg ✅
- [ ] `#1e2a12` → `color.successFill` — established SCR-21; reused for toast bg ✅
- [ ] `rgba(255,255,255,.06)` → `color.shimmerSheen` — established SCR-21/22/23 ✅
- [ ] `border-radius:10px` → `radius.dialogButton` — established; reused for seg + retry-btn ✅
- [ ] `font-weight:600` → `weight.medium` — ongoing; field-input values
- [ ] `font-weight:700` → (no named token yet) — seg, logout-label, toast-text, field-label

## Accessibility Checkpoints

- [ ] Back arrow: semantic label "Back"
- [ ] avatar-icon: `excludeFromSemantics: true`
- [ ] field-group: label associated with input (accessibility grouping)
- [ ] Fitness Goal: announces current value on change; picker accessible
- [ ] Experience Level: radio group semantics; one segment = selected
- [ ] Height/Weight: `keyboardType: numeric`; label includes unit ("centimetres")
- [ ] field-error: live region — announced immediately when shown
- [ ] Save Changes (disabled): marked disabled; not focusable
- [ ] save-note: announced alongside disabled save-btn
- [ ] Log Out: label includes "Log Out" (not just danger colour)
- [ ] logout-icon: `excludeFromSemantics: true`
- [ ] Toast: live region or alert; "Profile saved" announced
- [ ] Seg padding `11px` → ~34px height — below 44pt; OQ-16

## Open Questions (blocking)

- [ ] **OQ-1** — Fitness Goal: picker mechanism + confirmed option set?
- [ ] **OQ-2** — Height/Weight units: cm/kg only, or imperial option?
- [ ] **OQ-3** — Display Name: empty string allowed? Max length?
- [ ] **OQ-8** — Save (write) failure state: not artboarded; needs design
- [ ] **OQ-9** — Back with unsaved changes: silent discard or confirmation dialog?

## Open Questions (non-blocking)

- [ ] OQ-4 — Display name max length in storage
- [ ] OQ-5 — Decimal height/weight allowed?
- [ ] OQ-6 — Re-validation timing: on save-tap only vs. on blur?
- [ ] OQ-7 — Toast auto-dismiss duration (suggest 2–3s)
- [ ] OQ-10 — Toast entry animation
- [ ] OQ-11 — Height/Weight = 0: valid or invalid?
- [ ] OQ-12 — Max value bounds for height/weight
- [ ] OQ-13 — Save-btn with no edits: always enabled or change-detection?
- [ ] OQ-14 — First-time user blank fields: placeholder copy?
- [ ] OQ-15 — Segmented control on 320px width: "Intermediate" clip risk
- [ ] OQ-16 — Tap target audit: seg + retry-btn below 44pt
- [ ] OQ-17 — Avatar: confirm read-only for MVP
- [ ] OQ-18 — `.avatar-name` CSS class unused: intentionally removed?
- [ ] OQ-19 — Validation artboard crop: logout-row present in full scroll view?

---

*OQ-1, OQ-2, OQ-3, OQ-8, OQ-9 are blocking. All other OQs may be resolved during engineering without a spec revision.*
