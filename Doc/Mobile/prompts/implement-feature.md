# Reusable Prompt — `$speckit-implement` for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents assumed a
Backend-contract-reconciliation and multi-device validation model that does not apply to this
single-developer, offline project, so that content was removed rather than kept — do not treat
anything below as historical reference.

## What this prompt is for

The `$speckit-implement` skill executes an approved `tasks.md` against the ForgeApp codebase
(the `forge/` Flutter project), reconciling existing code, marking task-level `[X]` evidence, and
stopping for G-04 self-review (`fvm flutter analyze`/`flutter test` green,
`standards/code-review-checklist.md` run).

## If you need this prompt now

1. Use [`specify-feature.md`](specify-feature.md) as the template for tone and ForgeApp-specific
   source rules.
2. Read `.agents/skills/speckit-implement/SKILL.md` directly — it is generic SpecKit tooling and
   works unmodified against a ForgeApp `tasks.md`.
3. Keep an explicit-authorization requirement: implementation should still require an explicit
   `IMPLEMENTATION_AUTHORIZED_NOW: YES` (or equivalent) before writing code, and should stay
   scoped to the `forge/` project directory.
4. Ask a future Claude session to produce a ForgeApp-specific reusable prompt following the same
   pattern as `specify-feature.md`, and add it back here under this filename.

## Related documents

- [`README.md`](README.md) — the full prompt index and gate sequence.
- `governance/definition-of-done.md` — the completion checklist implementation must satisfy.
- `governance/review-gate-framework.md` — G-04's proof artifact and pass condition.
