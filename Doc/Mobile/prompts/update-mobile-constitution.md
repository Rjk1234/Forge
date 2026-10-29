# Governance Prompt — Constitution Sync for ForgeApp

> **Status**: Stubbed — Not Yet Rewritten | **Last updated**: 2026-09-08

This file has not yet had a full ForgeApp-specific rewrite. Its previous contents were a very
large, bespoke overlay on top of the generic `speckit-constitution` skill, tied to a corpus and
sign-off model that does not apply to this single-developer project, so that content was removed
rather than kept — do not treat anything below as historical reference.

## What this prompt is for

A governance utility for explicitly synchronizing or amending
`.specify/memory/constitution.md` and its dependent SpecKit artifacts (templates, this `prompts/`
set) after a material change to ForgeApp's ADRs, standards, or governance documents. It is not part
of an ordinary feature run — see `prompts/README.md` — Governance utility.

## If you need this prompt now

1. The generic `.agents/skills/speckit-constitution/SKILL.md` (or
   `.claude/skills/speckit-constitution/SKILL.md`) already does the mechanical part: it reads
   `.specify/memory/constitution.md`, fills placeholders, and produces a Sync Impact Report. It
   requires no ForgeApp-specific rewrite — it operates generically on whatever constitution
   content exists.
2. The current `.specify/memory/constitution.md` already documents its own Source Traceability
   table and an "Open Product Decisions" section — use those as the model for what a future sync
   should update.
3. For a small, well-scoped amendment (e.g. one ADR changes status, or a new principle is added),
   invoking the generic `speckit-constitution` skill directly, with the change described in plain
   language, is a reasonable substitute for a bespoke ForgeApp sync prompt.
4. Ask a future Claude session to produce a ForgeApp-specific version of this governance prompt,
   modeled on the level of detail in `.specify/memory/constitution.md`'s own Sync Impact Report,
   and add it back here under this filename.

## Related documents

- `.specify/memory/constitution.md` — the document this prompt would keep in sync.
- [`README.md`](README.md) — where this utility fits relative to an ordinary feature run.
