# Design Specification Quality Checklist: SCR-19 — Workout Summary & Completion

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/e5fec60a-5cea-465b-97d3-1e556a1db092

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context (offline/Drift), all 3 remaining FRs, removed FRs documented, completion criterion defined
- [x] §2 User Flow — 4-state machine (Loading → Main, Loading → Error → Loading retry → Main); 3 entry paths from SCR-16; all exit paths (SCR-06, SCR-20) and blocked paths (back from Main, cancel during loading); navigation stack behaviour
- [x] §3 Screen-by-Screen Breakdown — all 3 artboards fully covered; Loading: spinner button, disabled cancel, lime progress fill; Main: hero, stat row, section label, ex-cards with set-pills (4 types), fixed gradient footer; Error: centered content, neutral icon wrap, 2-tier text, full-width retry
- [x] §4 Interactions & Behaviour — 11 interactions tabulated; deduplication guard on retry; non-interactive states during loading; navigation stack notes
- [x] §5 Edge Cases & Error Handling — 9 edge cases; all-sets-skipped; backgrounding during write; double-tap retry guard; empty session defensive guard; navigation stack after View History
- [x] §6 Responsive & Platform Considerations — 3 device widths tabulated; iOS/Android back gesture (OQ-6 for Error state Android); content scrollability; portrait-only
- [x] §7 Accessibility — 4 touch targets audited; 9 contrast pairs (4 flagged — 3 fail AA, 1 marginal icon non-text); focus management; aria-live for loading; aria-hidden for spinner; aria-disabled for cancel link; skipped pills labelled; ex-card grouping suggestion
- [x] §8 Component & Design System Mapping — 20 component entries; 12 new patterns/components; 6 new token gaps; icon taxonomy updated to 3 types
- [x] §9 Acceptance Criteria Mapping — AC-1, AC-2, EC-1 mapped; removed FRs confirmed; skipped sets, type dots, navigation targets all verified
- [x] §10 Open Questions / Assumptions — 10 OQs with owner / build-blocker status / assumption held

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML:
  - Loading: "ACTIVE WORKOUT", "Cancel", "Triceps Pushdown", "Set 3 of 3 — complete", "Saving Workout…"
  - Main: "Workout Complete", "Push Day — Upper Body", "Mon, Sep 7 · 6:42 PM", "38 min", "Performance", "View History", "Done"; all 5 exercise names and pill values
  - Error: "Workout Complete", "Couldn't save your workout", full msg-sub and msg-note strings
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified and documented:
  - `#1e2a12` — success fill (hero icon-wrap background) — **new, first occurrence** — token proposal: `color.successFill`
  - `rgba(196,201,172,.25)` — spinner track (muted at 25% opacity) — token proposal: `color.spinnerTrack`
  - `linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%)` — footer fade gradient — token proposal: `gradient.footerFade`
  - `font-weight:600` — skipped set pill — **first occurrence in system** — token proposal: `weight.medium`
  - `border-radius:8px` — set pill — new micro-radius tier — token proposal: `radius.pill`
  - `letter-spacing:.04em` — stat-label — new value below existing .05em/.06em
- [x] All 3 artboards read and accounted for in §3 (Loading.dc.html, Main.dc.html, Error.dc.html)
- [x] Progress fill lime vs dim distinction documented (Loading: lime at 96% vs SCR-16 mid-workout dim fill)
- [x] Spinner CSS values fully documented (18×18, 2.5px border, muted track + indicator)
- [x] Footer gradient documented with exact stops (transparent 0% → --bg 40%)
- [x] Error icon wrap neutral (card+border) vs danger-fill distinction documented and explained

---

## Blocking Issues

| # | Issue | Severity | Status |
|---|-------|---------|--------|
| OQ-1 | **Duplicate prevention on retry**: No specification exists for how duplicate records are prevented when "Retry" is tapped after a failed write. If the first write partially succeeded or if the app state after a failure is unclear, retrying could create duplicate `workout_sessions` entries. A stable session ID strategy (generated at workout start) must be defined and implemented before this screen is built. | **Blocking** | Open — Engineering to define session ID lifecycle and pre-write existence check |
| OQ-2 | **App backgrounded during Drift write**: The user story defers background behaviour (inherited from SCR-17 deferral). However, the Drift write in SCR-19 is a critical data operation. If the app is backgrounded while writing, the target state on foreground resume is undefined — the UI could show Loading indefinitely or incorrectly transition. Engineering must specify the Dart isolate / task handling for this case. | **Blocking** | Open — Engineering to define background write handling and foreground resume state |

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-3 | Date/time in hero-sub — session start or end time? | Design/PM | Session start time |
| OQ-4 | "Sets Logged" stat — completed sets only or including skipped? | Design/PM | Completed (non-skipped) only |
| OQ-5 | "Exercises" stat — all exercises in plan or exercises with ≥1 logged set? | Design/PM | All exercises in plan |
| OQ-6 | Android hardware back from Error state — blocked or routed? | Engineering/PM | Blocked; no back from Error |
| OQ-7 | SCR-19 on navigation stack below SCR-20 — should it be accessible via back? | Engineering/PM | Yes; SCR-19 remains on stack |
| OQ-8 | "Discard Workout" secondary action from Error state — in scope for v1? | PM/Design | No — artboard shows none; canonical |
| OQ-9 | Duration calculation — total elapsed or net active (excluding pauses)? | Engineering | Total elapsed (start → Finish tap) |
| OQ-10 | `#1e2a12` success fill — token formalisation needed | Design | Token `color.successFill` pending |

---

## Design Consistency Notes

- **`#1e2a12` — new success-fill colour**: The hero icon wrap on the summary screen uses `#1e2a12` — a dark lime-green analogous to `#2a1f1f` (danger fill). This is the first "positive/success" background tint in the ForgeApp system. The system currently has:
  - `#2a1f1f` — `color.dangerFill` (danger background — SCR-11, SCR-13, SCR-14, SCR-16, SCR-18, x7 occurrences)
  - `#1e2a12` — `color.successFill` (success background — SCR-19, first occurrence)
  Formalising both as tokens is urgent. They form a semantic pair.

- **Neutral icon wrap (Error state)**: SCR-19 Error uses `var(--card)` + `1px solid var(--border)` for the error icon container — not `#2a1f1f`. This is a meaningful distinction from SCR-11/SCR-18 where the danger-fill background reinforces destructive intent. Here, the failure is technical (a local I/O error), not a user action with consequences. The card-coloured wrap reads as "something went wrong" without "you are about to lose data." This is correct and should be documented as an icon-wrap pattern rule.

- **Calendar-with-exclamation — third error icon**: The system now has three distinct error/warning icons: alert-triangle (irreversible destructive), alert-circle (recoverable invalid state), calendar-exclamation (technical save failure). The calendar specifically encodes "couldn't record to history" — semantically appropriate for a save failure. This icon vocabulary should be documented alongside the icon-wrap fill rules.

- **Loading state in-place on SCR-16**: Unlike SCR-17 and SCR-18 which overlay the active workout with a scrim, SCR-19 Loading mutates the Finish button in-place. No overlay, no scrim, no dimming of background content. This is a different pattern — the active workout remains fully visible and readable while saving. Only the footer button changes. This is appropriate: loading is a transient, expected transition (a few milliseconds for a local write), not a blocking modal interrupt.

- **"Workout Complete" as title in Error state**: Keeping "Workout Complete" in the Error app bar is a strong UX decision. The user completed the workout — the completion is real. The problem is a save failure, not a workout failure. This framing avoids falsely signalling the user "failed" or that the workout didn't happen. It's also consistent: the save failure screen replaces the summary that would have shown the same title.

- **Progress fill lime at final state (Loading)**: During mid-workout on SCR-16, the progress fill is `var(--dim)`. On the Loading artboard, it is `var(--lime)` at `96%`. This is the first observed occurrence of a lime progress fill — it appears the fill colour switches to lime when the final exercise is complete. This should be clarified: does the fill go lime at 100% only, or at the final-exercise-complete state? This is a SCR-16 design question but documented here as it first appears in SCR-19 artboards.

- **`font-weight:600` on skipped pills**: This is the only occurrence of `font-weight:600` in the ForgeApp design system. The current weight scale uses 700 (label/secondary) and 800 (heading/primary). Weight 600 creates a visually softer, recessed appearance for skipped set pills — reinforcing their "not counted" status alongside `dim` colour and `line-through`. The weight step is subtle but intentional. Token proposal: `weight.medium: 600`.

- **Set pill `border-radius:8px`**: New micro-radius tier below the existing `10px` (dialog buttons). The 8px radius makes pills feel like compact tags or chips rather than buttons. Prior radius values in system: 4px (progress track), 8px (set pill — new), 10px (dialog button), 12px (mid-screen buttons — unconfirmed), 14px (stat-box, ex-card, footer-btn), 16px (entry card SCR-16), 18px (modal dialog SCR-18). The system now has a richer radius scale that should be tokenised.

- **Footer gradient pattern**: `linear-gradient(180deg, rgba(19,19,21,0) 0%, var(--bg) 40%)` is the first use of a gradient overlay for content fade in the system. The 40% stop means the gradient completes (reaches full `--bg` opacity) in the upper portion of the footer, giving a clean fade-out. The remaining 60% of the footer is fully opaque `--bg`. Combined with `padding-bottom:90px` on content, this enables the "scroll content under the sticky footer" pattern natively. Recommend tokenising as `gradient.footerFade` and documenting the pattern for reuse on other long-list screens (e.g. SCR-06 Home, SCR-20 Workout History).

- **SCR-19 appbar-title not all-caps**: SCR-16 uses `"ACTIVE WORKOUT"` (all-caps, `color:muted`). SCR-19 Loading inherits this — "ACTIVE WORKOUT" all-caps — because it is still the active workout screen. SCR-19 Main and Error use `"Workout Complete"` (title-case, `color:muted`) — a deliberate mode shift. This naming pattern (all-caps for active states, title-case for terminal/informational states) should be documented as an app-bar title convention.

- **Contrast deficiencies — systemic**: Four contrast failures in SCR-19 all involve `var(--dim)` (`#8a8f7a`) on dark surfaces. This is a recurring system-wide issue identified in SCR-15, SCR-16, SCR-17, and now SCR-19. `dim` is used extensively as a secondary text colour but does not meet WCAG AA at small sizes on any dark surface in the system. A design system sprint should audit all `dim` usages and either bump the value or restrict `dim` to sizes/weights where it achieves adequate contrast.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-3 (date/time source), OQ-4 (Sets Logged definition), OQ-5 (Exercises definition), OQ-8 (discard from Error), OQ-10 (successFill token), progress-fill lime threshold (SCR-16 concern) | — |
| Engineering | Pending OQ-1 (duplicate guard — blocking), OQ-2 (background write — blocking), OQ-6 (Android back from Error), OQ-7 (navigation stack), OQ-9 (duration calculation) | — |
| PM | Pending OQ-3 (timestamp preference), OQ-4 (stat definition), OQ-5 (stat definition), OQ-8 (discard option v1 scope) | — |
