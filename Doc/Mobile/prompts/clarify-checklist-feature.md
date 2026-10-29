# Reusable Prompt — `$speckit-clarify` + `$speckit-checklist` for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents assumed a
multi-repository, multi-role setup that does not apply to this single-developer project, so that
content was removed rather than kept — do not treat anything below as historical reference, and
do not try to reconstruct what used to be here.

## What this prompt is for

The `$speckit-clarify` skill (optionally followed by `$speckit-checklist`) resolves ambiguity in
a feature's `spec.md` and prepares the requirements-quality checklist needed for G-01 self-review
— see `governance/review-gate-framework.md` and `governance/definition-of-ready.md` §1.

## If you need this prompt now

1. Use [`specify-feature.md`](specify-feature.md) as the template for tone, structure, and
   ForgeApp-specific source rules (`Doc/SDS_v2.0.md`, `Doc/UserStories/`, `Doc/DESIGN-SYSTEM.md`,
   single-developer self-review).
2. Read `.agents/skills/speckit-clarify/SKILL.md` (or `.claude/skills/speckit-clarify/SKILL.md`)
   directly — it is generic SpecKit tooling and works unmodified against whatever `spec.md` a
   ForgeApp feature has.
3. Ask a future Claude session (or write this out yourself) to produce a ForgeApp-specific
   reusable prompt following the same pattern as `specify-feature.md`, and it should be added back
   here under this filename.

Until then, running `$speckit-clarify` directly against the installed skill, with `spec.md` as
context, is a perfectly reasonable substitute for this reusable prompt on a small feature.

## Related documents

- [`README.md`](README.md) — the full prompt index and gate sequence.
- `governance/definition-of-ready.md` §1 — what G-01 requires.
- `governance/review-gate-framework.md` — G-01's proof artifact and pass condition.
