# ForgeApp — Review Gate Framework

Every gate is named, typed, and artifact-backed. Even as a single-developer project, "I'm sure it's
fine" is not a gate — a checklist file or a dated note is.

---

## Overview

The SDD pipeline produces specifications, plans, and tasks before code is written where a feature
warrants that level of process (see `governance/definition-of-ready.md`). This framework names
four review gates at the transitions between pipeline stages. For a small change, the developer may
reasonably collapse G-01/G-02/G-03 into a single up-front self-check rather than three separate
documented passes — but G-04 (Code Review / Self-Test) always applies.

Each gate answers three questions:
- **What** is being verified?
- **What file proves** the gate was passed (where the feature is big enough to have one)?
- **What blocks it**?

---

## Four Gates

| Gate | Position in Pipeline | Applies To |
|---|---|---|
| **G-01 Spec Quality** | After drafting `spec.md`, before `plan.md` | Any feature with a written spec |
| **G-02 Plan Quality** | After `plan.md`, before `tasks.md` | Any feature with a written plan |
| **G-03 Task Consistency** | After `tasks.md`, before implementation | Any feature with a task breakdown |
| **G-04 Self-Review** | Before considering the feature Done | All changes |

A one-file bug fix or a small refactor with no spec/plan/tasks skips straight to G-04.

---

## G-01 — Spec Quality Gate

**Purpose**: Confirm the specification is complete, unambiguous, and consistent with the SDS
before any technical planning begins.

**Pass condition**:
- The relevant checklist items in `governance/definition-of-ready.md` §1 are satisfied
- Zero unresolved `[NEEDS CLARIFICATION]` markers remain in `spec.md`
- Status is set to `Approved` in the document header

**Proof artifact**: `spec.md`'s own header/status field.

**What blocks the gate**: Any open question in the spec, including an unresolved deferred product
decision that this feature actually depends on (e.g. the Personal Best metric — SDS §3.5).

---

## G-02 — Plan Quality Gate

**Purpose**: Confirm the implementation plan is architecturally sound before task generation.

**Pass condition**:
- `governance/definition-of-ready.md` §2 items are satisfied
- The plan does not introduce anything outside `standards/coding-standards.md` /
  `app/platform-requirements.md` without a new ADR

**Proof artifact**: `plan.md`'s own content — no separate sign-off file for a solo project.

**What blocks the gate**: A plan that violates an accepted ADR without a documented reason to open
a new one.

---

## G-03 — Task Consistency Gate

**Purpose**: Confirm every requirement in the spec has at least one task, and the task list is
actually executable in order.

**Pass condition**:
- Every acceptance criterion in `spec.md` maps to at least one task in `tasks.md`
- No task depends on a task that comes after it
- No single task exceeds one day of effort

**Proof artifact**: `tasks.md` itself.

**What blocks the gate**: A requirement with no corresponding task, or a task that's really three
tasks pretending to be one.

---

## G-04 — Self-Review Gate

**Purpose**: Confirm the implementation is correct and matches `standards/coding-standards.md` /
`standards/security-standards.md` before considering the change Done.

**Review method**: Self-review using `standards/code-review-checklist.md`.

**Pass condition**:
- `fvm flutter analyze` — zero issues
- `fvm flutter test` — all green, coverage targets met (`standards/testing-standards.md` §2)
- `standards/code-review-checklist.md` run and all applicable items checked
- Manually verified on an Android and an iOS device/emulator

**Proof artifact**: `governance/definition-of-done.md`'s checklist, completed for the feature.

**What blocks the gate**: Any analyzer issue, failing test, or unmet coverage target.

---

## What "Passing" Means — Summary

| Gate | Proof artifact | Pass condition |
|---|---|---|
| G-01 | `spec.md` header | Status Approved, zero open clarifications |
| G-02 | `plan.md` | No unjustified ADR violation |
| G-03 | `tasks.md` | Every requirement has a task, no circular dependencies |
| G-04 | `governance/definition-of-done.md` checklist | Analyzer clean, tests green, checklist complete |

---

## Walkthrough: A Feature With a Full Spec/Plan/Tasks Set

```text
Draft spec.md
      ↓
◆ G-01 GATE — self-check against definition-of-ready.md §1
      ↓
Draft plan.md
      ↓
◆ G-02 GATE — self-check against definition-of-ready.md §2
      ↓
Draft tasks.md
      ↓
◆ G-03 GATE — confirm every requirement has a task
      ↓
Implement (tests alongside or first)
      ↓
◆ G-04 GATE — analyzer/tests green, code-review-checklist run
      ↓
Mark feature Done (governance/definition-of-done.md)
```

## Walkthrough: A Small Fix or Refactor (No Spec)

```text
Make the change
      ↓
◆ G-04 GATE — analyzer/tests green, code-review-checklist run
      ↓
Mark task Done
```

---

## Related Documents

- `standards/code-review-checklist.md` — the checklist run during G-04.
- `standards/testing-standards.md` — coverage/quality gates checked in G-04.
- `governance/definition-of-done.md`, `governance/definition-of-ready.md`.

---
