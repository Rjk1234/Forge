# Design Specification Quality Checklist: SCR-20 — Workout History List

**Purpose**: Validate design specification completeness and quality before implementation  
**Created**: 2026-09-13  
**Feature**: [spec.md](../spec.md)  
**Artboard reference**: https://claude.ai/code/artifact/0e0c565e-43b2-4303-9f72-25e12fd3d64b

---

## Specification Completeness

- [x] §1 Overview & Goal — problem, user, goal, success metric, app context (offline/Drift), all FRs, removed NFR-3 documented, SEC-1/SEC-2 noted
- [x] §2 User Flow — 3 entry points; 6 exit destinations; 4-state machine (Loading → Main/Empty/Error, Error → Loading retry); tab-switch nav behaviour; SCR-21 push transition
- [x] §3 Screen-by-Screen Breakdown — all 4 artboards covered with exact CSS values; shared chrome (appbar, navbar) documented once; each state's layout, copy, and component breakdown complete
- [x] §4 Interactions & Behaviour — 11 interactions tabulated; transition patterns; pull-to-refresh and long-press noted as unspecified (OQs)
- [x] §5 Edge Cases & Error Handling — 10 edge cases; EC-1 (read failure distinct from empty); data refresh on re-entry; long plan names; corrupt session data; very large history
- [x] §6 Responsive & Platform Considerations — 3 device widths; portrait-only; iOS/Android back behaviour; navbar safe area padding
- [x] §7 Accessibility — 3 touch targets audited (1 below 44pt — flagged); 11 contrast pairs (3 failures — all systemic dim issues); full semantic roles for list, tabs, cards, skeleton, empty, error; focus management
- [x] §8 Component & Design System Mapping — 14 component entries; 8 new patterns; 5 token gaps; alert-triangle variant taxonomy updated
- [x] §9 Acceptance Criteria Mapping — all ACs (AC-1–4), FRs (FR-1–5), NFRs (NFR-1–2), EC-1, SEC-1–2 mapped
- [x] §10 Open Questions / Assumptions — 11 OQs with owner / build-blocker status / assumption held

---

## Design Grounding

- [x] All measurements taken from artboard CSS (not invented)
- [x] All copy strings taken verbatim from artboard HTML:
  - Loading: "History" (appbar-title)
  - Empty: "History" (appbar-title), "No workout history yet" (empty-title), "Your completed workouts will appear here." (empty-sub)
  - Main: "History" (appbar-title), "September 2026", "August 2026" (month-labels); all 5 session names and meta strings
  - Error: "History" (appbar-title), "Couldn't load your history" (err-title), full err-sub copy, "Retry" (retry-btn)
- [x] Token values cross-checked against design system reference
- [x] Non-token values identified and documented:
  - `#35342f` — shimmer midpoint (skeleton shimmer gradient); **new, first occurrence** — token proposal: `color.shimmerMid`
  - `letter-spacing:.03em` — date-mon — new value below .04em
- [x] All 4 artboards read and accounted for in §3
- [x] Navbar 6-tab layout fully documented with all icon SVG paths, label copy, active/inactive states
- [x] Shimmer animation keyframe documented (0%→100% background-position)
- [x] `date-mon` class name discrepancy noted — contains DOW abbreviation not month name (OQ-9)
- [x] Alert-triangle variant difference vs SCR-18 documented (sharp vs rounded; stroke-width 1.6 vs 1.8)
- [x] Error retry button inline-sizing (NOT full-width) documented and explained
- [x] Month-section visual grouping mechanics explained (flex gap:10px + month-label margin:6px 0 2px)
- [x] `#5c3a3a` (dangerBorder) confirmed as design system token — correctly used on err-card border

---

## Blocking Issues

*No blocking issues identified. All OQs are non-blocking with reasonable assumptions held.*

---

## Non-Blocking Open Questions

| # | Topic | Owner | Assumption held |
|---|-------|-------|----------------|
| OQ-1 | Empty state: two-line (title + sub) vs one-line; period in sub; AC-2 exact copy | Design/PM | Both lines as artboard; AC-2 met via sub |
| OQ-2 | Alert-triangle variants: sharp (SCR-20) vs rounded (SCR-18) — intentional? | Design | Deliberate semantic distinction |
| OQ-3 | Pull-to-refresh on Main list | Engineering/Design | No pull-to-refresh in v1 |
| OQ-4 | Long-press on history row (delete, share, etc.) | PM/Design | No long-press in v1 |
| OQ-5 | Long plan name truncation vs wrap | Design | Wraps; card height grows |
| OQ-6 | 100+ sessions performance — pagination needed? | Engineering | Full read v1; paginate if needed |
| OQ-7 | Main list preserved or re-fetched on SCR-21 back | Engineering | Preserved in memory |
| OQ-8 | Skeleton row count — fixed 7 or viewport-based? | Engineering | Fixed 7 or viewport-based |
| OQ-9 | `date-mon` content confirmed as DOW, not month? | Design | Day-of-week abbreviation |
| OQ-10 | Retry button touch target ~38pt — needs padding increase? | Design | Increase to ≥44pt |
| OQ-11 | SCR-19 View History → auto-scroll to newest session? | Engineering | Opens at top; newest is top |

---

## Design Consistency Notes

- **Root-tab title tier `22px/800/.02em` confirmed**: SCR-20's appbar-title matches the root-tab title pattern (SCR-06, SCR-08/12 presumed). This is distinct from the `15px/800/muted` used on overlay and terminal screens (SCR-17–19). The two-tier title scale is now confirmed: root tab = `22px/white`, overlay/terminal = `15px/muted`. Token proposals: `text.screenTitle` (22px/800/.02em) and `text.overlayTitle` (15px/800/muted).

- **First animated skeleton in the system**: SCR-20 introduces the shimmer skeleton pattern — the system's first CSS animation and first loading skeleton. The pattern (`linear-gradient` + `background-size:400%` + `@keyframes shimmer`) is a well-established mobile loading convention. If other screens (SCR-06, SCR-08, SCR-12) need loading states, this skeleton pattern should be their reference. The 1.4s ease duration is a comfortable pace — not too fast (anxious) or too slow (laggy).

- **Skeleton geometry mirrors real content**: `sk-badge` at `44×34px` precisely matches the real `date-badge` column width (`width:44px`). The badge aspect ratio (rectangular, not square) hints at the date-badge's stacked date-day + date-mon content. This is good skeleton design — it sets accurate expectations about the content's structure.

- **`#35342f` shimmer midpoint — first new color since `#1e2a12` (SCR-19)**: The shimmer gradient's midpoint `#35342f` is between `#2a2a2c` (card-alt) and a slightly warmer, lighter tone. It's not pure white or lime — it's a warm grey consistent with the ForgeApp palette. Token proposal: `color.shimmerMid`. If the shimmer pattern is adopted system-wide, this midpoint should be tokenised.

- **`date-mon` CSS class contains DOW, not month**: The class name `date-mon` is misleading — it contains 3-letter day-of-week abbreviations ("Mon", "Sat", "Thu"), not month abbreviations ("Sep", "Aug"). The month context is provided by the `month-label` section header. This is intentional UX — the date badge gives you day-of-month + day-of-week (enough to orient within the calendar), while the section header gives the month/year context for the group. The implementation should rename this to `date-dow` or `date-weekday` to avoid confusion.

- **Month grouping without dividers**: SCR-20 uses section labels (month-label) as the grouping mechanism, not visual dividers or different card backgrounds. The visual separation between groups comes from the combination of `gap:10px` (flex container) and `margin:6px 0 2px` (month-label) — a 16pt perceived gap vs 10pt within-group gap. This is a subtle but effective grouping pattern that avoids the visual noise of explicit dividers.

- **Chevron stroke-width:2 (vs system 1.8)**: The 16×16 chevron on hist-card uses `stroke-width:2`, slightly heavier than the system's `1.8` for most icons. At this small size, the extra stroke weight ensures the directional affordance is visible without zooming. Consider documenting `stroke-width:2` as the standard for small (≤16px) directional icons.

- **Error card border uses `dangerBorder` (`#5c3a3a`)**: SCR-20's error card correctly uses the design system token `color.dangerBorder: #5c3a3a`. This is consistent with SCR-13/SCR-14 error cards. However, the token name `dangerBorder` suggests a border-only usage, while in practice it's also used as the border color for error state cards (not just borders around danger form fields). Consider renaming to `color.errorBorder` for semantic clarity.

- **Inline retry button (not full-width) in error card**: SCR-20's retry button is auto-sized (`padding:11px 22px`) and sits inside the error card alongside icon and text. SCR-19's retry was full-width (`width:100%`) in the footer. The pattern difference is contextual: SCR-19 retry is the screen's sole CTA (deserves full-width prominence); SCR-20 retry is the card's action (inline reads as "the card's button," not the screen's primary call-to-action). Document as the "inline card action button" pattern.

- **Empty state `padding:0 32px 60px`**: The 60px bottom offset on the empty state content centring is consistent with SCR-19 Error's centred layout. The offset accounts for the bottom navigation bar height (~58px: `10+14+18px` padding + icon height), effectively centring the empty state in the space above the navbar rather than in the full viewport height. This is a subtle but correct adjustment.

- **Nav tab `opacity:.5` for inactive**: The Loading artboard explicitly defines `opacity:.5` on inactive navitems. This is a global inactive-tab opacity pattern. The Empty artboard omits it (possibly a CSS simplification in that artboard, since `dim` color already reduces contrast). Implementation should treat `opacity:.5` on inactive nav items as canonical per the Loading artboard.

- **Systemic dim-on-bg contrast issue**: `month-label` and inactive nav labels both fail WCAG AA at 4.2:1 for small text (≤12px). This is the fifth consecutive screen to flag `dim` (`#8a8f7a`) contrast issues at small sizes. A design system sprint to raise `dim` to approximately `#999` would resolve these across all affected screens without changing the palette hue.

---

## Sign-off

| Role | Status | Date |
|------|--------|------|
| Design | Pending OQ-1 (empty state copy/title), OQ-2 (alert-triangle variants), OQ-5 (name truncation), OQ-9 (date-mon DOW confirmation), OQ-10 (retry touch target) | — |
| Engineering | Pending OQ-3 (pull-to-refresh), OQ-6 (pagination), OQ-7 (list preservation), OQ-8 (skeleton row count), OQ-11 (auto-scroll on entry) | — |
| PM | Pending OQ-1 (AC-2 exact copy), OQ-4 (long-press actions), OQ-11 (scroll-to-newest UX) | — |
