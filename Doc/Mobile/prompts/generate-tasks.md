# Reusable Prompt — `$speckit-tasks` for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents assumed a
device-matrix/role-based task breakdown that does not apply to this single-developer, phone-only
project, so that content was removed rather than kept — do not treat anything below as historical
reference.

## What this prompt is for

The `$speckit-tasks` skill turns an approved `plan.md` into `tasks.md`: exact, dependency-ordered,
tests-first implementation tasks, organized domain → data → application → presentation → tests
(ForgeApp's Clean Architecture layers — see `standards/coding-standards.md` §4).

## If you need this prompt now

1. Use [`specify-feature.md`](specify-feature.md) as the template for tone and ForgeApp-specific
   source rules.
2. Read `.agents/skills/speckit-tasks/SKILL.md` directly — it is generic SpecKit tooling and works
   unmodified against a ForgeApp `plan.md`.
3. Keep task granularity in line with `governance/definition-of-ready.md` §4 (no task over one
   day of effort) and `governance/definition-of-done.md` Part 1 (every task's own checklist).
4. Ask a future Claude session to produce a ForgeApp-specific reusable prompt following the same
   pattern as `specify-feature.md`, and add it back here under this filename.

## Related documents

- [`README.md`](README.md) — the full prompt index and gate sequence.
- `governance/definition-of-ready.md` §4 — task-breakdown requirements.
- `governance/review-gate-framework.md` — G-03's proof artifact and pass condition.
