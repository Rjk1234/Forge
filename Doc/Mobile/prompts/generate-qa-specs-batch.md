# Reusable Prompt — Batch QA Specification Generation for ForgeApp

> **Status**: Approved | **Last updated**: 2026-09-13

## What this prompt is for

Generates a QA specification for **every** ForgeApp user story in one run. You read
one user story end to end, write its QA spec, and move on to the next story
yourself — the person running this does not invoke the prompt once per story.

This is a standalone QA-authoring utility, not a stage in the specify → clarify →
plan → tasks → analyze → implement sequence in [`README.md`](README.md). It does not
require an existing `spec.md`/`plan.md` for any story — ForgeApp has not yet run the
SDD workflow for any feature, so **the user story file itself is the specification**.
Run this prompt again later, after a story has been through `plan-feature.md` or
`generate-tasks.md`, to pick up whatever those artifacts add (see "If a story later
gets a plan/tasks" below) — until then, this prompt works from user stories alone
and that is a complete, valid input, not a degraded one.

## The prompt

```text
Generate a QA specification for every ForgeApp user story from Doc/UserStories/ and write each one to
spec/[User Story folder]/QA/<STORY-ID>-qa-spec.md.

## Batch procedure — do this yourself, story by story, without stopping to ask

1. List every file in Doc/UserStories/ except README.md. Each remaining file
   (SCR-01-...md, SCR-03-...md, ..., LOCALDB-01-...md) is one user story to
   process. Process them in the order they appear in Doc/UserStories/README.md's
   index table.
2. For each story, in turn:
   a. Read that one story file in full.
   b. Read Doc/Mobile/.specify/memory/constitution.md in full (or re-use it if
      already read this run — it does not change between stories).
   c. Generate its QA specification using the structure and rules below.
   d. Write it to spec/[User Story folder]/QA/<STORY-ID>-qa-spec.md, on the first story if it does not exist.
   e. Move on to the next story immediately. Do not pause for confirmation
      between stories and do not ask which story to do next — the full list
      from step 1 is the entire scope of this run.
3. If a story file is missing information a section below asks for (no plan.md,
   no api-contract-mapping.md, etc. — see "Inputs" below), do not treat that as
   a blocker: write the section from what the story and the constitution
   actually contain, and note in that section what could not be sourced.
4. After every story has a written qa-spec.md, produce ONE final batch report
   (not one report per story) per "Output requirements" below.

## Inputs to read, in full, before writing each story's QA spec

There is no spec.md, plan.md, api-contract-mapping.md, design-spec-mapping.md,
interaction-state-spec.md, content-inventory.md, or validation-rules.md for any
ForgeApp story yet — do not look for these files or treat their absence as a
gap to flag. Use instead:

1. **The user story file itself** (Doc/UserStories/<STORY-ID>-*.md) — this IS the
   spec for this run. Read its User Story Statement, every Functional and
   Non-Functional Requirement, every Security & Privacy Requirement, the full
   UI/Component Specifications section, every Acceptance Criterion, and every
   Edge Case/Error Scenario. Nothing in this document is optional reading.
2. **The story's own "Design Reference" section**, if it has one (most SCR-0x
   screen stories do; LOCALDB-01 does not, since it defines a persistence
   capability rather than a screen). Treat the artifact link, artboard notes,
   and any literal colors/copy/component names it gives as the confirmed
   visual/content detail for that screen — the equivalent of what
   design-spec-mapping.md or content-inventory.md would supply on a project
   that has them. If the story's Design Reference section says the mockup is
   a reference only and not locked/approved, carry that same caveat into any
   QA test case that depends on exact copy or layout from it.
3. **Doc/Mobile/.specify/memory/constitution.md** — pull its accessibility,
   security/privacy, device/platform matrix, and quality-gate requirements
   directly, the same as if a plan.md existed. This is the one document that
   applies uniformly across every story and is read once per run, not
   re-read per story unless it changed.
4. **Doc/Mobile/standards/*.md and Doc/Mobile/governance/*.md**, where a
   story's subject matter clearly maps to one (e.g. a story with local (Drift)
   read/write failure states maps to whatever the constitution's Source
   Traceability table says about ADR-008/local persistence) — cite these only
   when they add something concrete; do not pad every section with a
   standards citation that isn't doing real work.

## Your role while generating each spec

You are drafting what a QA engineer would produce, not restating what the
user-story author already wrote. A QA spec that just rephrases each
acceptance criterion as a "test case" adds no value — actively hunt for
boundary conditions, negative/failure paths, timing/race conditions,
device/environment variation, and security/access-control cases that a
requirements-first document is likely to have under-covered.

Do NOT invent new business behavior or requirements the story doesn't
support — every test case must trace to something the user story file or
the constitution actually states. Where you identify a genuine gap the
story doesn't address at all, include it as a flagged test case with an
explicit note that it exercises behavior not yet defined in that story,
rather than quietly assuming an answer.

Some ForgeApp-specific realities to keep in mind across every story, so
cases stay grounded rather than generic:

- The app is fully offline/single-local-user; **Drift is the sole persistence
  layer** — there is no network, no backend, no multi-user data model.
  "Connectivity lost," "server error," "session expired," and "another
  user's data" are not real conditions for this app; do not manufacture
  test cases for them. The equivalent, real conditions are a local Drift
  read failure and a local Drift write failure — use those.
- Login is a static local unlocked/locked flag compared against one
  hardcoded credential, not real authentication — write access-control
  cases against that flag, not against a token/session model.
- A workout session is discarded entirely (nothing written to Drift) on
  Cancel, or on Finish with zero sets logged — there is no "incomplete"
  saved-record state to test for; the relevant boundary case is exactly
  one set logged before Finish, since that is the confirmed low bar for a
  session to count as completed.
- Where a story explicitly flags something as deferred/open (e.g. the
  Personal Best metric definition, or app-backgrounded timer behavior),
  do not write a test case that assumes a resolution — write a QA-derived
  flag noting the behavior is undefined pending that product decision.

## Document structure to produce for each story

# QA Specification — [STORY ID / Title]

**Status:** AI-Generated — Pending Human QA Review
**Source documents read:** [list every file actually read for this story]
**Created:** [date]

> This document was generated in the absence of a dedicated QA engineer. It
> is a structured starting draft, not verified test coverage. It must be
> reviewed, corrected, and signed off by a qualified human reviewer before
> being treated as real QA evidence for this feature's release gate.

## 1. Scope

- The single user story covered (ID, title, priority).
- Explicitly out of scope: sibling stories referenced by this one (by
  ID) whose own behavior is not re-tested here — reference them, don't
  re-test their behavior in this document.

## 2. Test Approach

- Test levels planned (unit/widget covered by engineering per
  Doc/Mobile/standards/testing-standards.md; this document focuses on
  functional/acceptance/manual-verification level).
- Automated vs. manual split, if determinable.
- Test data requirements: what needs to be seeded in Drift (sample plans,
  schedule entries, workout records, catalogue entries, edge-value
  records) to execute the scenarios below.

## 3. Environment & Device Matrix

Pull directly from the constitution's platform requirements — exact OS
versions, device classes (phone/tablet), orientations. If this story has
no dedicated screen (e.g. LOCALDB-01), say so and scope this section to
whatever device/OS variation could affect local storage behavior instead
(e.g. low-storage conditions), rather than leaving it as a placeholder.

## 4. Positive Test Scenarios (traced to the user story)

One case per acceptance criterion in the story, in Given/When/Then form,
each explicitly citing the story's own AC ID (e.g. AC-3) and FR ID it
verifies. Do not add anything here beyond what the story already states.

## 5. Negative & Boundary Test Scenarios

For every input, threshold, or limit-bearing requirement in the story
(non-positive values, blank required fields, invalid references,
mm:ss duration entry, one-plan-per-weekday-maximum, etc.), include cases
testing at, just below, and just above the boundary — even if the story
only states the boundary value itself. Include invalid-input cases for
every user-input field the story defines.

## 6. Timing, Concurrency & Race-Condition Scenarios

Explicitly consider: rapid repeated taps on any save/delete/finish
action, navigating away mid-save, backgrounding/foregrounding during an
in-flight local write or an active workout timer, and any two actions
that could plausibly race (e.g. editing a plan while a workout built
from it is in progress). Flag any of these not already covered by an
edge case in the story as a genuine gap — do not assume a safe default
silently.

## 7. Local Storage & Failure-Mode Scenarios

For every local (Drift) read or write this story performs, include: the
read/write failing outright, retry after a failed write not creating a
duplicate record, and data remaining unaffected when a later, unrelated
write fails (per NFR patterns like Local Data Persistence's Edge-2).
There is no network layer in this app — do not include offline/
connectivity/server-timeout cases; they do not apply.

## 8. Security & Access-Control Scenarios

Whether this screen/action correctly requires the local unlocked state
(where the story specifies it), and — only where the story's own scope
would make it possible — that persisted data behaves as single-user data
with no cross-record leakage (e.g. deleting one plan must not remove
another plan's history). Do not write cross-user-account cases; ForgeApp
has exactly one local user and no account model.

## 9. Accessibility Test Scenarios

Derived from the constitution's stated accessibility baseline — concrete
checks (tap target size, color-not-sole-indicator, screen-reader labels
for icon-only controls), not a generic "test accessibility" line item. If
the constitution scopes accessibility down to minimal/deferred for the
POC, say that plainly here rather than writing cases against a fuller
standard the project isn't targeting.

## 10. Regression Considerations

Note any other user story this one could plausibly affect, based on what
its own Dependencies & Notes section says it shares (e.g. a Plan
Management change also touching Scheduling or Workout Pre-Start, since
they read the same persisted plan data).

## 11. Entry & Exit Criteria

- Entry: what must be true before QA execution can begin (e.g. build
  available, Drift test data seeded, this story's G-01/G-02 self-review
  gates passed per Doc/Mobile/prompts/README.md).
- Exit: what must be true to consider this story's QA complete (all
  Section 4 cases pass, Sections 5-9 cases pass or have triaged/accepted
  defects, no open Critical/High severity issue).

## 12. Traceability Summary

A compact table: this story's FR/AC/EC ID -> test case ID(s) in this
document. Flag any FR or AC with no corresponding test case as an
immediate gap to fix before this document is considered complete.

## Sign-off

| Reviewer | Role | Status |
|---|---|---|
| [Name] | QA | [ ] Reviewed and corrected |
| [Name] | Product/BA | [ ] Confirmed no invented behavior |

## Rules

- Do not mark anything in Sign-off as checked.
- Do not present this document's coverage as equivalent to a real QA
  engineer's sign-off anywhere in its own text — the Status header's
  caveat must remain accurate throughout.
- Where Section 5-9 introduces a scenario not explicitly required by the
  user story, mark it clearly as "QA-derived, not yet in this story" so a
  human reviewer can decide whether it should be added to the story
  itself or is genuinely a QA-only concern.
- Every ForgeApp-specific reality listed above ("Your role while
  generating each spec") is a hard constraint, not a suggestion — do not
  write connectivity, server-error, session-expiry, or cross-user-account
  test cases for this app under any section.

## Output requirements — ONE final report for the whole batch, after every story is done

Do not report per story as you go. After all stories have a written
qa-spec.md, report once:

- Total stories processed, and confirmation each has a qa-spec.md.
- Total test case count per section (4-9), summed across all stories, plus
  a per-story breakdown.
- How many Section 5-9 cases across the whole batch were marked
  "QA-derived, not yet in this story" (these are the highest-value
  findings — the gaps a real QA person would likely have caught) — call
  out the stories with the most of these first.
- Confirmation that every story's Traceability Summary (Section 12) shows
  zero uncovered FR/AC IDs, or a list of which stories still have gaps.
- Any story you could not fully process and why (e.g. a file that isn't
  actually a user story).
```

## If a story later gets a plan/tasks

Once a story has been through `plan-feature.md` and/or `generate-tasks.md` and has
its own `Doc/Mobile/specs/<slug>/` folder with a `plan.md`, `api-contract-mapping.md`,
`design-spec-mapping.md`, or similar, re-run this prompt for that one story with those
files added to the "Inputs to read" list above — they add technical-constraint and
confirmed-detail context this prompt currently has to source from the user story and
constitution alone. This does not require rewriting the batch procedure: point it at
the single story and it should read the extra files it finds instead of noting them
absent.

## Related documents

- [`README.md`](README.md) — the standalone feature-workflow prompt index; this
  utility sits outside that sequence.
- `Doc/Mobile/.specify/memory/constitution.md` — the accessibility, security, and
  platform baseline every generated QA spec pulls from.
- `Doc/Mobile/standards/testing-standards.md` — the test-level split (unit/widget
  vs. functional/acceptance) this prompt defers to in each spec's Section 2.
