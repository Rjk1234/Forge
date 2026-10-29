# Reusable Prompt — `$speckit-analyze` for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents assumed a
Backend-contract and multi-device consistency model that does not apply to this single-developer,
offline project, so that content was removed rather than kept — do not treat anything below as
historical reference.

## What this prompt is for

The `$speckit-analyze` skill performs a non-destructive, read-only consistency, coverage,
constitution, ordering, and executability review across `spec.md`/`plan.md`/`tasks.md` for one
feature, producing the `analysis.md` report needed for G-03 self-review.

## If you need this prompt now

1. Use [`specify-feature.md`](specify-feature.md) as the template for tone and ForgeApp-specific
   source rules.
2. Read `.agents/skills/speckit-analyze/SKILL.md` directly — it is generic, read-only SpecKit
   tooling and works unmodified against ForgeApp's feature artifacts.
3. It never edits artifacts — only reports findings. Retain its exact final report as
   `analysis.md` per `governance/review-gate-framework.md` (G-03).
4. Ask a future Claude session to produce a ForgeApp-specific reusable prompt following the same
   pattern as `specify-feature.md`, and add it back here under this filename.

## Related documents

- [`README.md`](README.md) — the full prompt index and gate sequence.
- `governance/review-gate-framework.md` — G-03's proof artifact and pass condition.
