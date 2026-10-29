# **Changelog — 2026-09-05 (Product Owner Clarification Session)**

This revision applies the confirmed decisions from the 2026-09-05 product-owner clarification session (see `decisions_log.md`) to the User Stories document ahead of development start. **No new scope was invented beyond what that log specifies** — this is a maturity/scope correction pass, not a feature-addition pass.

**Architecture (Decisions Log §0):** The app is fully offline/local-only. **Drift** (typed SQLite) is the sole persistence layer; there is no Firebase, no Firestore, no cloud backend, and no network calls anywhere. This single decision invalidates most of the "offline state" / "Firestore write" / "authenticated session" language that the original document inherited from an earlier, now-DEPRECATED online-first architecture. It was corrected in every story listed below; residual occurrences in stories not listed (e.g., SCR-07, SCR-08, SCR-10, SCR-11, SCR-20–SCR-23) were intentionally left untouched in this pass per the review scope (see summary notes at the end of this changelog) and should be swept in a follow-up pass.

**Removed / out-of-scope:**
* Registration (SCR-02) and the associated Forge-US-2 story — already flagged out of scope; note added confirming why (Decisions Log §0).
* Forgot Password (SCR-04) and Password Reset Email Sent (SCR-05) — no login-recovery flow of any kind exists; removed from SCR-01/SCR-03 as entry/exit dependencies and functional requirements.
* Firebase Authentication service-failure handling, disabled-account handling, and email-format business validation on SCR-03 — replaced with a static local string-match against a single hardcoded credential.
* The "Incomplete" saved-workout state and the discard-vs-save-incomplete prompt (SCR-16, SCR-18, SCR-19, Local Data Persistence story) — cancel always discards entirely; a Finish with zero sets logged is treated the same as cancel.
* The global connectivity/offline banner, Firestore read/write failure framing, invalid-session handling, and cross-user data-access rejection on SCR-27 — re-scoped to the one genuinely local-equivalent concern (a local database read/write failure); the rest do not apply in a single-local-user, no-network app.
* Scheduling's previously-unresolved "multiple plans per day" ambiguity — resolved as one plan per day maximum (reject a conflicting assignment).

**Materially changed:**
* **SCR-01 (Splash) / SCR-03 (Login), both copies (Forge-US-1, Forge-US-3):** rewritten for a static/demo login only — local login-state check, no server validation, no forgot-password link, generic "Email or password is incorrect" on a non-matching local string comparison.
* **SCR-09 (Create/Edit Plan):** per-exercise target fields now branch on the exercise's type flag (`weighted` / `time-based` / `bodyweight`); duration entered/displayed as mm:ss; weight strictly positive.
* **SCR-12 / SCR-13 (Scheduling):** weekly recurrence only, confirmed one-plan-per-day-maximum as the explicit save-conflict rule; offline/connectivity handling removed.
* **SCR-16 (Active Workout) / SCR-18 (Cancel Confirmation) / SCR-19 (Workout Summary) / Local Data Persistence story:** completion = at least one set logged + explicit Finish; cancel (or a zero-set Finish) always discards entirely, nothing persisted, no "Incomplete" state; rest timer (SCR-17) auto-starts on set completion and is skippable; app-backgrounded timer behavior explicitly flagged DEFERRED/open (Decisions Log §6b) rather than designed.
* **SCR-24 (Personal Bests):** kept the structural scope (a Personal Bests view showing per-exercise bests) but the specific metric definition is now explicitly flagged **TBD — deferred, see open decisions** (Decisions Log §3) rather than left ambiguously implied.
* **SCR-25 (Profile/Account):** the prior `[ASSUMPTION]`/read-only flag is RESOLVED — CONFIRMED, editable, by the product owner in this session. Exactly four fields: display name, fitness goal, experience level, height & weight (the latter two informational only, no calculations).
* **SCR-26 (Logout Confirmation):** "Firestore data" and "authenticated session" language corrected to reflect the local login-state flag and local (Drift) storage.
* **SCR-27 (Cross-Cutting/Global States):** rewritten to keep only a local (Drift) read/write-failure state; the connectivity, invalid-session, and cross-user states were removed as scenarios that cannot occur.

**Intentionally left alone (not defects):** Exercise Catalogue browsing (SCR-07), Plan list/detail browsing (SCR-08, SCR-10, SCR-11), Workout History list/detail (SCR-20, SCR-21), Progress Comparison (SCR-22), and Statistics Dashboard structure (SCR-23) were out of the explicit review scope for this pass and were not rewritten even though some retain stale "offline state"/"authenticated user" boilerplate from the earlier online-first architecture — flagged here for a follow-up pass rather than corrected now, to keep this pass targeted per the decisions log's "enough but not too much" instruction.

**Follow-up cleanup pass — 2026-09-05:** Swept the entire document for remaining Firebase/Firestore/offline-connectivity/"authenticated session"/"authenticated user" language left over from the deprecated online-first architecture, not just the stories flagged above. Corrected: SCR-06 (Home Dashboard — dropped "Authenticated" from the title, removed the offline banner/connectivity states), SCR-07 (Exercise Catalogue), SCR-08 (Plans List), SCR-09/SR-1–SR-2 wording, SCR-10 (Plan Detail), SCR-11 (Delete Plan Confirmation — including a literal `"You're offline"` state), SCR-12/SCR-13 residual "authenticated" wording, SCR-14 (Remove From Schedule — including a literal `"You're offline"` state), SCR-15 (Workout Pre-Start — including a prior NFR that literally required connectivity to read a locally stored plan), SCR-17/SCR-18/SCR-19 residual "authenticated user" wording, SCR-20 (History List), SCR-21 (History Detail — including a "no offline/local-cache mode" framing), SCR-22 (Progress Comparison — including a stray "another user" access-control clause), SCR-23 (Statistics Dashboard), SCR-24 (Personal Bests), and SCR-26 (Logout Confirmation — remaining "authenticated session" phrases in the modal/action copy and acceptance criteria that the original pass missed). In every case, an offline/connectivity state was either removed outright (reading local database data cannot fail due to lost connectivity) or folded into the screen's existing local-storage read/write-failure error state, and "authenticated user"/"authenticated session" wording was replaced with the app's local login-state (unlocked/locked) framing — no functional, scope, or logic changes were made to any screen's list rendering, detail views, or progress/statistics calculations.

**Traceability defect fix — 2026-09-05:** Corrected US-SCR25 (View Profile / Account), which was still citing UC-SCR25 IDs against a stale 4-row version of the Screen_Flow_Use_Case_Inventory_vNext.md SCR-25 table rather than the current 7-row table. Fixes: the Logout-action citation (FR-5) and the "profile loaded" citation (AC-2) both incorrectly pointed at UC-SCR25-02 (real UC-SCR25-02 is Empty/Default, not Populated/Logout) — corrected to UC-SCR25-03 (Populated), which is where the Logout action and populated display actually live in the current Inventory. The profile read/save error citations (NFR-2, EC-1, full-chain summary) incorrectly pointed at UC-SCR25-03 (Populated) — corrected to UC-SCR25-06 (Error/System Failure). The story twice incorrectly stated "UC-SCR25-04 no longer applies," treating it as the removed offline row — corrected to identify UC-SCR25-07 as the actual removed row, since UC-SCR25-04 (Negative/Validation — invalid numeric height/weight entry) is active and previously had no AC/EC coverage in this story; added NFR-4, AC-4, EC-2, and a new §7.9 UI spec entry to cover it. Added a UC-SCR25-05 (Success) citation to AC-3, which the story previously never cited at all. No functional scope changes were made (display name, fitness goal, experience level, height & weight, editable, logout remain exactly as before).

---


# Index of Individual User Story Files

**This README + folder replaces the single combined `UserStories_vNext.md` file.** Each user story below has been split out into its own self-contained Markdown file (full fidelity — functional requirements, acceptance criteria, edge cases, and traceability notes copied verbatim, nothing truncated or summarized). The original combined document is being kept at its existing location (`/mnt/user-data/outputs/vNext/UserStories_vNext.md`) as a historical reference — it does not need to be deleted or moved.

Files are listed in the same order the stories originally appeared in the source document.

| # | File | Screen / Story ID | Title |
|---|------|--------------------|-------|
| 1 | [SCR-01-Splash-AuthCheck.md](./SCR-01-Splash-AuthCheck.md) | US-SCR01 (Forge-US-1) | Splash / Auth Check |
| 2 | [SCR-03-Login-Authenticate.md](./SCR-03-Login-Authenticate.md) | US-SCR-03 (Forge-US-3) | Login — Authenticate Existing User |
| 3 | [SCR-06-Home-Dashboard.md](./SCR-06-Home-Dashboard.md) | US-SCR-06 (Forge-US-6) | Home Dashboard — Landing & Navigation |
| 4 | [SCR-07-Browse-Select-Exercises.md](./SCR-07-Browse-Select-Exercises.md) | US-SCR-07 (Forge-US-7) | Browse and Select Exercises |
| 5 | [SCR-08-Workout-Plans-List.md](./SCR-08-Workout-Plans-List.md) | US-SCR08 (Forge-US-8) | Workout Plans List |
| 6 | [SCR-09-Create-Edit-Workout-Plan.md](./SCR-09-Create-Edit-Workout-Plan.md) | US-SCR09 (Forge-US-9) | Create / Edit Workout Plan |
| 7 | [SCR-10-Plan-Detail.md](./SCR-10-Plan-Detail.md) | US-SCR10 (Forge-US-10) | Plan Detail |
| 8 | [SCR-11-Delete-Workout-Plan-Confirmation.md](./SCR-11-Delete-Workout-Plan-Confirmation.md) | US-SCR11 (Forge-US-11) | Delete Workout Plan Confirmation |
| 9 | [SCR-12-View-Weekly-Schedule.md](./SCR-12-View-Weekly-Schedule.md) | US-SCR12 (Forge-US-12) | View Weekly Workout Schedule |
| 10 | [SCR-13-Assign-Edit-Schedule.md](./SCR-13-Assign-Edit-Schedule.md) | US-SCR13 (Forge-US-13) | Assign / Edit Schedule for a Workout Plan |
| 11 | [SCR-14-Remove-From-Schedule.md](./SCR-14-Remove-From-Schedule.md) | US-SCR14 (Forge-US-14) | Remove Workout Plan From Schedule |
| 12 | [SCR-15-Workout-PreStart-Overview.md](./SCR-15-Workout-PreStart-Overview.md) | US-SCR15 (Forge-US-15) | Workout Pre-Start / Overview |
| 13 | [SCR-16-Active-Workout.md](./SCR-16-Active-Workout.md) | US-SCR16 (Forge-US-16) | Active Workout — Exercise & Set Logging |
| 14 | [SCR-17-Rest-Timer.md](./SCR-17-Rest-Timer.md) | US-SCR17 (Forge-US-17) | Rest Timer |
| 15 | [SCR-18-Cancel-Active-Workout-Confirmation.md](./SCR-18-Cancel-Active-Workout-Confirmation.md) | US-SCR-18 | Cancel Active Workout Confirmation |
| 16 | [SCR-19-Workout-Summary-Completion.md](./SCR-19-Workout-Summary-Completion.md) | US-SCR-19 | Workout Summary and Completion |
| 17 | [SCR-20-Workout-History-List.md](./SCR-20-Workout-History-List.md) | US-SCR-20 | Workout History List |
| 18 | [SCR-21-Workout-History-Detail.md](./SCR-21-Workout-History-Detail.md) | US-SCR-21 | Workout History Detail |
| 19 | [SCR-22-Progress-Comparison.md](./SCR-22-Progress-Comparison.md) | US-SCR-22 | Progress Comparison |
| 20 | [SCR-23-Statistics-Dashboard.md](./SCR-23-Statistics-Dashboard.md) | US-SCR23 | View Statistics Dashboard |
| 21 | [SCR-24-Personal-Bests.md](./SCR-24-Personal-Bests.md) | US-SCR24 | View Personal Bests |
| 22 | [SCR-25-Profile-Account.md](./SCR-25-Profile-Account.md) | US-SCR25 | View Profile / Account |
| 23 | [SCR-26-Confirm-Logout.md](./SCR-26-Confirm-Logout.md) | US-SCR26 | Confirm Logout |
| 24 | [SCR-27-Cross-Cutting-Global-States.md](./SCR-27-Cross-Cutting-Global-States.md) | US-SCR27 | Cross-Cutting / Global States |
| 25 | [LOCALDB-01-Local-Data-Persistence.md](./LOCALDB-01-Local-Data-Persistence.md) | US-LOCALDB-01 | Local Storage for Workout Plans and Workout Records |

## Design System Reference

All 22 UI screens above (SCR-06 through SCR-27) were designed as static mockups on a shared, consistent visual language, which has since been consolidated into a single ForgeApp Design System covering color, typography, spacing, corner radius, iconography, components (buttons, fields, chips, the exercise type-flag system, app bar, bottom nav, cards), and shared UI patterns (loading, empty, error/retry, confirmation modals, toast, inline validation, and the reserved open-decision design-note convention).

* **Live interactive canvas:** https://claude.ai/code/artifact/b7f5a669-ced7-4d53-9e82-60feb385a5b2 ("ForgeApp Design System") — three artboards: Foundations, Components, Patterns & States. Read-only view + PNG/PDF export in this preview.
* **Local dev-reference doc:** [`../DESIGN-SYSTEM.md`](../DESIGN-SYSTEM.md) — all tokens (colors, type scale, spacing, radii) and component/pattern conventions in plain tables, ready to copy into the app's theme/constants.
* **Local static snapshot:** [`../forgeapp-design-system.html`](../forgeapp-design-system.html) — offline copy of the canvas above.

Each individual screen's own file also carries a "Design Reference" section (near the bottom) with that screen's specific artifact link and artboard notes — the design system above is the cross-screen summary of the same visual language, not a replacement for those per-screen sections.

Status: this is a POC/MVP-scope design reference derived from the mockups actually built — no components, states, or colors were invented beyond what those 22 screens use. Where a story left something explicitly undecided (SCR-24's personal-best metric), the design system reflects that as an open item, not a resolved default.

## Note on removed/out-of-scope screens (SCR-02, SCR-04, SCR-05)

The source document does **not** contain standalone "REMOVED" stub sections for SCR-02 (Registration), SCR-04 (Forgot Password), or SCR-05 (Password Reset Email Sent) — there is no dedicated heading/section for any of these three in `UserStories_vNext.md`. They are mentioned only as inline notes inside the Dependencies & Notes sections of SCR-01 (line ~202–204, ~224), SCR-03 (line ~391), and SCR-06 (line ~613), confirming they are deprecated/out-of-scope with no functionality of their own. Since there is no self-contained section to extract for these three screens, no separate files were created for them; their out-of-scope status remains documented in the SCR-01, SCR-03, and SCR-06 files above (each of which retains its own removal note verbatim).

