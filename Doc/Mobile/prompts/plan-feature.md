# Reusable Prompt — `$speckit-plan` for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents assumed a
multi-role approval chain and a Backend-API-dependency model that do not apply to this
single-developer, fully offline project, so that content was removed rather than kept — do not
treat anything below as historical reference.

## What this prompt is for

The `$speckit-plan` skill turns an approved `spec.md` into a constitution-compliant technical
design (`plan.md`, `research.md`, applicable `data-model.md`) for the ForgeApp architecture:
Clean Architecture layers, `flutter_bloc`, `go_router`, `get_it`, Drift — see
`governance/solution-architecture.md` and the ADRs it indexes.

## If you need this prompt now

1. Use [`specify-feature.md`](specify-feature.md) as the template for tone and ForgeApp-specific
   source rules.
2. Read `.agents/skills/speckit-plan/SKILL.md` directly — it is generic SpecKit tooling and works
   unmodified against ForgeApp's `.specify/memory/constitution.md`, which already carries every
   ForgeApp-specific Constitution Check rule (single-user, offline, Drift-only, phone-only).
3. When planning a feature, check the plan's Constitution Check section against
   `.specify/memory/constitution.md` directly.
4. Ask a future Claude session to produce a ForgeApp-specific reusable prompt following the same
   pattern as `specify-feature.md`, and add it back here under this filename.

## Related documents

- [`README.md`](README.md) — the full prompt index and gate sequence.
- `governance/definition-of-ready.md` §2 — what G-02 requires.
- `governance/solution-architecture.md` — the architecture the plan must conform to.
- `.specify/memory/constitution.md` — the Constitution Check source of truth.
