# Design Specification: SCR-27 — Cross-Cutting / Global States

**Created**: 2026-09-13  
**Status**: Draft  
**Artboard reference**: https://claude.ai/code/artifact/1ca4e390-31a8-43a5-93ca-a1acf6e7b084  
**User story**: `Doc/UserStories/SCR-27-Cross-Cutting-Global-States.md`

> **Nature of this document**: SCR-27 is not an independently navigated screen — it is a shared design pattern (a "template") instantiated by multiple screens across the app. This spec defines the two canonical error-state templates, the substitution rules for per-screen copy, and the exact visual token values that every instantiation must follow.

---

## 1. Overview & Goal

ForgeApp is fully offline and local-only. Drift is the sole persistence layer. Even without a network, local reads and writes can fail (e.g., device storage full, corrupted record). SCR-27 establishes two canonical error-state UI templates that every screen in the app must use when a Drift operation fails:

| Template | Trigger | Key constraint |
|---|---|---|
| **Read-Error** (FR-1 / AC-2) | Uncategorized Drift read failure | Must be distinguishable from a validation error and offer Retry |
| **Write-Error** (FR-2 / AC-3) | Uncategorized Drift write failure | Must NOT represent the write as successful; Retry must not create a duplicate persisted record |

**What was removed from scope** (Decisions Log §0, 2026-09-05): connectivity/offline banners (no network exists), invalid-session state (no real auth session), and cross-user data-access rejection (single local user only). These are not designed and must not be referenced in engineering.

**Primary success outcome**: The user always knows when a local operation has failed and always has a clear, idiomatic path to retry — and is never shown stale or phantom-saved data as if it were real.

---

## 2. User Flow

SCR-27 is not a standalone flow — it is a branching outcome within every screen's own read and write flows.

### 2.1 Read-Error flow

```
[Any screen] — performs Drift read
    ├─ Read succeeds → render normal state (Loading → Main / Empty)
    └─ Read fails (uncategorized) → render Read-Error state (this spec)
           ├─ Tap "Retry" → re-attempt read → Loading → success or failure again
           └─ Navigate back (appbar/gesture) → exit screen normally
```

**Entry points**: Every screen that reads from Drift on mount. As of 2026-09-13: SCR-12, SCR-20, SCR-21, SCR-23, SCR-24, SCR-25 (and all future screens that read local data).

**Exit points**: Tap Retry (re-triggers read); navigate back/up (user abandons).

### 2.2 Write-Error flow

```
[Any screen] — user submits a write action (save, create, update, delete)
    ├─ Write succeeds → render success state (toast, confirmation, or navigation)
    └─ Write fails (uncategorized) → render Write-Error state (this spec)
           ├─ Tap "Retry" → re-attempt write (idempotent) → success or failure again
           └─ Navigate back or dismiss → user abandons write (no phantom data)
```

**Entry points**: Every screen that writes to Drift. As of 2026-09-13: SCR-14, SCR-16, SCR-19, SCR-25 (and all future screens that save or mutate local data).

**Exit points**: Tap Retry (re-triggers write); navigate away (abandoned, no data saved).

---

## 3. Screen-by-Screen Breakdown — ALL States

### 3.1 Read-Error Template (FR-1 / AC-2)

**Artboard**: `Main.dc.html`  
**Template label in artboard**: "Any Screen · TEMPLATE" (on-canvas decoration — NOT shipped UI)

This template defines the exact visual for every screen's load-failure state. The appbar shown in the artboard ("Any Screen · TEMPLATE") is a placeholder indicating that the actual appbar comes from the host screen. The error card fills the content area of whichever screen instantiates it.

#### Template appbar note

The appbar in the artboard is a design canvas placeholder only — never shipped:

```
appbar-title: "Any Screen"  font-size:16px / font-weight:800 / color:dim
appbar-tag:   "TEMPLATE"    font-size:10px / font-weight:700 / color:dim
              background:cardAlt / border:1px solid border / border-radius:6px
              padding:2px 6px / uppercase / letter-spacing:.03em
```

In the actual app, each screen's own appbar (with its real title, back arrow, and correct padding) remains visible above the error card.

#### Content area

```
flex: 1
display: flex
flex-direction: column
align-items: center
justify-content: center
padding: 0 32px
text-align: center
gap: 14px
```

#### err-card

```
width: 100%
background: #201f22              ← color.card
border: 1px solid #5c3a3a        ← color.dangerBorder
border-radius: 16px
padding: 28px 20px
display: flex
flex-direction: column
align-items: center
gap: 12px
```

> ⚠️ **Discrepancy vs prior per-screen specs**: Template uses `padding:28px 20px` and `gap:12px`. Earlier per-screen specs (SCR-24, SCR-25) recorded `padding:26px 20px`. The template artboard is the normative source — use **28px** for all new implementations. Existing screens should be updated.

#### err-icon (Read-Error)

```
width: 44px
height: 44px
color: #ff6b6b                   ← color.danger
stroke-width: 1.5
```

SVG: alert-triangle with exclamation mark:

```svg
viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
<path d="M12 3l10 18H2L12 3z"/>
<path d="M12 10v4"/>
<circle cx="12" cy="17" r="0.6" fill="currentColor"/>
```

> ⚠️ **Discrepancy vs prior per-screen specs**: Template uses `44×44` and `stroke-width:1.5`. Earlier per-screen specs recorded `40×40` and `stroke-width:1.6` (SCR-25). The template artboard is normative — use **44px / stroke-width:1.5** for all implementations.

#### err-title

```
font-size: 17px
font-weight: 800
color: color.white (#f5f6f1)     ← inherited
```

> ⚠️ **Discrepancy vs prior per-screen specs**: Template uses `17px`. Earlier per-screen specs recorded `16px/800` (SCR-25 Error). The template artboard is normative — use **17px** for all implementations.

**Template copy (illustrative — substitute per screen)**: "Couldn't load this data"

**Copy pattern**: "Couldn't load [screen-specific noun]" — e.g.:
- SCR-20 Workout Plans: "Couldn't load your plans"
- SCR-21 Schedule: "Couldn't load your schedule"
- SCR-25 Profile: "Couldn't load your profile"

#### err-sub

```
font-size: 13px
color: #c4c9ac                   ← color.muted
line-height: 1.5
```

**Template copy**: "Something went wrong reading from local storage.\nYour data is safe — try again."

**Copy pattern for per-screen substitution**:
- Line 1: "Something went wrong [reading/loading] [optional: screen-specific context]."
- Line 2: "Your [data noun] is [safe/unaffected] — [retry instruction]." OR just "Retry to try again."

#### retry-btn

```
margin-top: 4px
background: #c3f400              ← color.lime
color: #131315                   ← color.bg
font-weight: 800
font-size: 13px
border-radius: 10px              ← radius.dialogButton
padding: 12px 24px
```

Label: **"Retry"**

> ⚠️ **Discrepancy vs prior per-screen specs**: Template uses `padding:12px 24px`. Earlier per-screen specs recorded `padding:11px 22px` (SCR-25 Error). The template artboard is normative — use **12px 24px** for all implementations.

Action: re-trigger the Drift read; transition back through the screen's Loading state first.

#### Artboard footnote (canvas only — NOT shipped UI)

```
position: absolute
left: 20px; right: 20px; bottom: 22px
font-size: 11px; color: dim; text-align: center; line-height: 1.5
```

Text (informational only): "Generic recoverable read-error template (FR-1/AC-2) — every screen's own error state (SCR-12, SCR-20, SCR-21, SCR-23, SCR-25, etc.) is this pattern with screen-specific copy substituted in."

---

### 3.2 Write-Error Template (FR-2 / AC-3)

**Artboard**: `WriteError.dc.html`  
**Template label in artboard**: "Any Screen · TEMPLATE" (same placeholder convention)

This template defines the visual for every screen's save/write-failure state. It differs from the Read-Error template in three ways: a different icon (communicating "save action failed"), different copy, and an additional `err-note` element that explicitly reassures the user that no duplicate record was created.

#### Content area, err-card

Identical to Read-Error template:

```
content: flex-col; align-items:center; justify-content:center; padding:0 32px; gap:14px
err-card: background:card; border:1px solid #5c3a3a; border-radius:16px; padding:28px 20px; flex-col; align-items:center; gap:12px
```

#### err-icon (Write-Error)

```
width: 44px
height: 44px
color: #ff6b6b                   ← color.danger
stroke-width: 1.5
```

SVG: calendar/save icon with embedded exclamation mark — communicates "this scheduled/saved action failed":

```svg
viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
<rect x="4" y="5" width="16" height="15" rx="2"/>
<path d="M4 10h16M8 3v4M16 3v4"/>
<path d="M12 13v-2M12 16.2v.1"/>
```

This icon is distinct from the Read-Error alert-triangle, allowing the user to distinguish at a glance between a read failure and a write failure.

#### err-title

```
font-size: 17px
font-weight: 800
```

**Template copy**: "Couldn't save this change"

**Copy pattern**: "Couldn't save [screen-specific noun]" — e.g.:
- Workout plan create/update: "Couldn't save your plan"
- Profile save: "Couldn't save your profile"
- Session log: "Couldn't save this session"

#### err-sub

```
font-size: 13px
color: #c4c9ac                   ← color.muted
line-height: 1.5
```

**Template copy**: "Something went wrong writing to local storage. It has not been saved."

**Copy pattern**: Line 1 is static ("Something went wrong writing to local storage.") + a screen-specific confirmation that the write did not happen ("It has not been saved." / "Your [noun] has not been updated.").

#### err-note (Write-Error template only — NOT in Read-Error)

```
font-size: 12px
color: #8a8f7a                   ← color.dim
line-height: 1.5
margin-top: -2px
```

**Copy (fixed — do not substitute)**: "Nothing was recorded — retrying won't create a duplicate."

This element is load-bearing UX copy that directly satisfies NFR-2: it explicitly guarantees to the user that the failed write did not create a partial or duplicate record, and that Retry is safe. It must appear in every write-failure state and must not be omitted.

#### retry-btn

Identical to Read-Error template: `lime bg; #131315; 800/13px; radius:10px; padding:12px 24px`.

Label: **"Retry"**

Action: re-attempt the write operation using the same data as the original attempt (idempotent). Must not submit a new or duplicate payload.

---

## 4. Interactions & Behavior

### 4.1 Retry action (both templates)

| State | Tap "Retry" behaviour |
|---|---|
| Read-Error | Screen transitions back through its own Loading state → re-executes the Drift read → either renders content (Main/Empty) or shows Read-Error again |
| Write-Error | Re-attempts the exact same write operation with the same data → either confirms success (toast/navigation) or shows Write-Error again |

**Debounce**: The Retry button must be debounced or disabled for the duration of the retry attempt to prevent multiple concurrent operations.

**Transition**: On Retry tap, the error card should be replaced immediately by the screen's Loading state (for reads) or an inline activity indicator (for writes — exact treatment is per OQ-1). Do not leave the error card visible while the retry is in-flight.

### 4.2 Navigation away from error state

Both error states must not block navigation. The screen's appbar back arrow (or system back gesture) remains active and takes the user up the navigation stack normally. No unsaved data exists to protect against accidental loss — the operation failed, so there is nothing pending.

### 4.3 Distinguishability from validation errors

The Read-Error template must always be distinguishable from validation error states (inline field errors, save-btn disabled). The visual marker is the `err-card` with `dangerBorder (#5c3a3a)` replacing the full content area — validation errors appear inline within the form, never as a card replacing the page content.

---

## 5. Edge Cases & Error Handling

| Scenario | Handling |
|---|---|
| Retry also fails | Re-render the same error template. No limit on the number of retries. Do not degrade to a different error message after N failures (copy is generic and time-stable). |
| Retry succeeds after N failures | Render success state normally. No "retry succeeded" confirmation needed — the user reaches the normal screen. |
| Write fails after partial progress | The err-note copy ("Nothing was recorded — retrying won't create a duplicate") is load-bearing. Engineering must ensure the Drift write is atomic — partial writes that leave an incomplete record must be rolled back before the error state is shown. |
| Concurrent Retry taps | Debounce / disable button on first tap until the operation completes to prevent stacked operations. |
| User leaves without retrying | No data is pending (read failure = nothing displayed; write failure = nothing saved). No confirmation dialog needed. |
| Screen has multiple data sources | If only one read fails and others succeed, the err-card replaces the content that would have come from the failing source. Full-screen err-card when the primary data source fails; partial errors are out of scope for this pattern (OQ-2). |
| Error state during onboarding flow | No connectivity/session failure applies. Only local Drift failures. Onboarding screens that write to Drift must use the Write-Error template when their writes fail. |

---

## 6. Responsive & Platform Considerations

| Concern | Spec |
|---|---|
| Card width | `width:100%` constrained by `padding:0 32px` in the content wrapper → effective width = screen width − 64px (326px on 390px iPhone canvas) |
| Content centering | Both templates vertically center the err-card within the available content area, regardless of screen height |
| Smaller phones (320px width) | err-card width = 256px. Copy wraps naturally; no truncation risk with current line lengths |
| Large phones / tablets | Card stays constrained to its readable width by the 32px horizontal content padding; does not need a max-width cap unless tablets are added to scope |
| Platform differences | None — both iOS and Android use the same card structure. No platform-specific dialogs or native error sheets |
| Screen-type appbar padding | The err-card is shown inside the host screen's content area, below its appbar. The appbar padding rule (root-tab: `6px 20px 10px`; pushed/overlay: `6px 20px 4px`) belongs to the host screen, not this template |

---

## 7. Accessibility

| Element | Requirement |
|---|---|
| err-icon | `excludeFromSemantics: true` — colour alone conveys nothing meaningful; the title carries the message |
| err-card | Announce as a live region (or initial focus when first shown) so screen-reader users immediately hear the error without needing to navigate |
| err-title | Heading role or first focusable element in the card; "Couldn't load/save…" read as the primary alert |
| err-sub | Followed immediately after err-title in reading order |
| err-note (write template) | Included in reading order; must not be `excludeFromSemantics` — the no-duplicate guarantee is functional information |
| retry-btn | Accessible label: "Retry" (button role). Minimum tap target: `padding:12px 24px` → ~37px height — below 44pt minimum; must add `minHeight: 44` or equivalent (OQ-3) |
| retry-btn (in-flight) | Announce disabled state when debounced: "Retry, dimmed" or activity indicator with accessible label |
| Focus management | On Retry tap: focus moves to the Loading indicator or first content element; on failure, focus returns to the err-title |
| Colour contrast | danger (#ff6b6b) on card (#201f22): ≈ 4.5:1 — passes AA. Muted (#c4c9ac) on card (#201f22): ≈ 4.0:1 — marginal; passes AA large text (13px/400 is not large text — OQ-4). |

---

## 8. Component & Design System Mapping

### Components introduced by SCR-27 templates

| Component | Classification | Notes |
|---|---|---|
| **err-card** | Established pattern — first canonical definition | Used across SCR-12, SCR-20, SCR-21, SCR-23, SCR-24, SCR-25. SCR-27 is the normative template; all prior instantiations should be verified against it. |
| **err-icon** | Sub-element of err-card | Two variants: alert-triangle (read), calendar+exclamation (write). Both 44×44 / stroke-width:1.5 / color:danger |
| **err-title** | Sub-element of err-card | `17px/800` — see discrepancy note in §3 |
| **err-sub** | Sub-element of err-card | `13px/muted/line-height:1.5` |
| **err-note** | Sub-element of err-card (write only) | NEW — `12px/dim/line-height:1.5/margin-top:-2px`. First appearance in system. Fixed copy. |
| **retry-btn** | Sub-element of err-card | `lime; #131315; 800/13px; radius:10px; padding:12px 24px` |

### Token reuse

| Value | Token |
|---|---|
| `#131315` | `color.bg` |
| `#201f22` | `color.card` |
| `#5c3a3a` | `color.dangerBorder` |
| `#ff6b6b` | `color.danger` |
| `#c4c9ac` | `color.muted` |
| `#8a8f7a` | `color.dim` |
| `#c3f400` | `color.lime` |
| `border-radius:10px` | `radius.dialogButton` |

### New token candidates surfaced by this spec

| Value | Proposed token | Notes |
|---|---|---|
| `font-size:17px` | `text.errorTitle` | Template normalises this at 17px; prior per-screen specs varied (16px). New token recommended to lock it. |
| `font-size:12px` (err-note) | `text.errorNote` | Distinct from `text.meta` (11px, SCR-23); distinct from `text.cardTitle` (14px). |
| `border-radius:16px` (err-card) | `radius.errCard` | Consistently 16px across all error cards. Recommended as explicit token. |
| `padding:28px 20px` (err-card) | *(not a token — padding value)* | Normalise to 28px top/bottom per template. |

### Screens to re-verify against canonical template

The following screens have their own error-state artboards already specced. Each should be verified against these canonical values after SCR-27 is locked:

| Screen | Template | Known discrepancies vs this template |
|---|---|---|
| SCR-24 Personal Bests (Error) | Read | err-icon `40×40 / sw:1.6`; padding `26px 20px`; err-title `16px` |
| SCR-25 Profile (Error — load) | Read | err-icon `40×40 / sw:1.6`; padding `26px 20px`; retry-btn `11px 22px`; err-title `16px` |
| SCR-25 Profile (Error — save) | Write | OQ-8 in SCR-25 — save-failure state not yet artboarded; this spec provides the template |
| SCR-20, SCR-21, SCR-23 | Read | Verify icon size, padding, title size against template values |

---

## 9. Acceptance Criteria Mapping

| Story AC | Criterion | Satisfied by |
|---|---|---|
| **AC-2** (FR-1) | When a Drift read fails, display a generic recoverable error state with a Retry option, distinguishable from validation errors | Read-Error template (§3.1): err-card with dangerBorder + err-title "Couldn't load…" + retry-btn. Visually and semantically distinct from inline validation (field-input.invalid, field-error). |
| **AC-3** (FR-2) | When a Drift write fails, do not represent write as successful; offer retry; no duplicate record on retry | Write-Error template (§3.2): err-card replaces success state; err-note explicitly states "Nothing was recorded — retrying won't create a duplicate". Engineering must ensure atomic write-or-rollback. |
| **NFR-1** | Recoverable read failures distinguishable from validation; provide retry | Read-Error template distinguished by: (a) full err-card vs inline error, (b) err-icon (alert-triangle vs no icon in validation), (c) full-screen replacement of content vs form field highlight |
| **NFR-2** | Failed writes never presented as successful; retry does not duplicate | Write-Error template: (a) no success toast/navigation emitted on failure, (b) err-note copy lock, (c) engineering idempotency requirement (§5) |

---

## 10. Open Questions / Assumptions

### Assumptions made

- **A-1**: The template artboard values are normative over any prior per-screen spec values where they differ (icon 44px vs 40px, padding 28px vs 26px, title 17px vs 16px, btn padding 12px 24px vs 11px 22px). Prior per-screen specs should be updated at next design review.
- **A-2**: The err-note copy ("Nothing was recorded — retrying won't create a duplicate.") is **fixed** and must not be substituted per-screen. It is a platform-level guarantee.
- **A-3**: The Write-Error calendar+exclamation icon applies to all write-failure states regardless of the specific operation (create, update, delete, log).
- **A-4**: All Drift writes must be atomic (all-or-nothing). If a write cannot be guaranteed atomic, engineering must raise an ADR before implementing retry — partial data in a Drift table on failure would violate NFR-2.
- **A-5**: There is no maximum retry count — the user may retry indefinitely. The engineering team must determine if a persistent failure (e.g., device storage truly full) warrants a different message; if so, that is a future story.
- **A-6**: Retry transitions through the screen's Loading state (for reads) before showing content. For writes, an inline activity indicator is assumed but not artboarded (OQ-1).

### Open questions

| ID | Question | Blocking? |
|---|---|---|
| OQ-1 | Write retry: does the screen show a full Loading state, an inline spinner on the Retry button, or a brief loading overlay while the write re-attempts? The write-error template does not artboard the in-flight retry state. | Yes — affects implementation contract |
| OQ-2 | Partial read failure (some Drift tables succeed, one fails): full-screen err-card for the failing part, or inline within the affected section only? The template only covers full-screen errors. | Yes — needed when screens composite multiple data sources |
| OQ-3 | retry-btn tap target: `padding:12px 24px` → ~37px tall. Add `minHeight:44` (or `padding:14px 24px`) to meet iOS/Android minimum? | Yes — accessibility requirement |
| OQ-4 | `color.muted` (#c4c9ac) on `color.card` (#201f22): measured contrast ~4.0:1. Fails AA for body text at 13px/400. Confirm whether this is accepted as a design decision or requires a token adjustment. | No — affects multiple prior screens too; triage separately |
| OQ-5 | Are there any write operations in scope that are intentionally non-retryable (e.g., a delete)? If so, the Write-Error template needs a variant without the Retry button. | No — not observed in any current screen artboard, but flag for edge cases |
| OQ-6 | Exact error copy for each screen's instantiation: the template defines illustrative copy; final per-screen copy must be confirmed with the SRS/SDS owner (as noted in §11 of the user story). | No — each screen's spec or a future copy doc carries this |
| OQ-7 | SCR-25 save-failure state (OQ-8 in SCR-25): now that the Write-Error template is defined, is this unblocked for engineering? Confirm the Write-Error template is sufficient. | No — design unblocked by this spec |
