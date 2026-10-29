# Reusable Prompt — `$speckit-specify` for ForgeApp

> **Status**: Approved | **Version**: 2.0 (ForgeApp) | **Last updated**: 2026-09-08
> **Owner**: ForgeApp (single developer)

## Purpose

Use this prompt when a User Story already exists under `Doc/UserStories/`, but only the ForgeApp
specification stage should run. It applies the source fields from
[`mobile-feature-sdd-run-template.md`](mobile-feature-sdd-run-template.md) without invoking the
deprecated full SDD orchestrator.

The active `speckit-specify` skill, resolved Spec Kit template, and the ForgeApp constitution
remain authoritative. This prompt adds content discipline: it defines what source material belongs
in `spec.md` and what must wait for planning.

## How to use

1. Copy the prompt below into a new task.
2. Complete the values block from `prompts/mobile-feature-sdd-run-template.md` and paste it at the
   marked location. The values block is input data and does not invoke another workflow.
3. Run this once for one feature. Use `prompts/clarify-checklist-feature.md` afterward to resolve
   material questions and prepare G-01 evidence, then `$speckit-plan` only after G-01 self-review.

## The prompt

```text
Create or update the ForgeApp specification for the single feature identified by the completed
Feature SDD run values below.

Use the installed `$speckit-specify` skill. This is a STANDALONE SPECIFICATION RUN: perform only
the specify-stage work and its required validation/hooks. Do not invoke the SDD orchestrator,
`$speckit-clarify`, `$speckit-plan`, `$speckit-tasks`, `$speckit-analyze`, or implementation.

Before writing:

1. Read `.agents/skills/speckit-specify/SKILL.md` completely and obey its ForgeApp override.
2. Resolve and read the active `spec-template`, then read `.specify/memory/constitution.md`
   completely. Do not search for or read ADRs, standards, or governance files unless the skill
   itself explicitly requires them. Do not perform any Git or GitHub operation, including
   read-only commands.
3. Parse the completed run values. Resolve all paths from the ForgeApp project root. Persist only
   portable, project-relative paths: `Doc/SDS_v2.0.md`, `Doc/UserStories/...`, `Doc/DESIGN-SYSTEM.md`,
   and `specs/...`. Treat `NOT_AVAILABLE` as a declared source/dependency gap. Never modify
   `Doc/SDS_v2.0.md`, `Doc/UserStories/`, or `Doc/DESIGN-SYSTEM.md`.
4. Read `USER_STORY_INPUT_PATH` completely, and read `SDS_INPUT_PATH` (`Doc/SDS_v2.0.md`) for the
   relevant component(s)/data entities/error codes this feature touches. Read
   `DESIGN_SYSTEM_INPUT_PATH` if the feature has meaningful new UI. Read any
   `ADDITIONAL_INPUT_PATHS` listed.
5. Choose a short, readable feature directory name — ForgeApp has no BA-folder-basename convention
   to preserve, so `specs/<short-feature-slug>` (e.g. `specs/workout-execution`) is correct. When
   `FEATURE_DIRECTORY` is `AUTO`, derive that slug from the feature title. When it is explicit,
   use it as given. If an older, differently named ForgeApp directory already represents this
   feature, stop and ask rather than inventing, renaming, merging, overwriting, or duplicating it.
6. Create or refresh `source-manifest.md` with one row per source file read, its portable path,
   size, non-Git SHA-256 checksum, status/authority, read state, artifact destination, and
   exclusion reason when applicable. Do not finalize the spec unless every relevant file was read
   completely or explicitly excluded and no relevant file is unreadable.

Source authority and reconciliation:

- `Doc/UserStories/` governs business intent, the single local user's goals, in-scope behavior,
  and acceptance outcomes for this feature.
- `Doc/SDS_v2.0.md` governs component/data/error-taxonomy scope already agreed for ForgeApp (its
  SDS-COMP-*, SDS-DATA-*, SDS-ERR-* references) — do not contradict it without flagging the
  conflict.
- `Doc/DESIGN-SYSTEM.md` governs visual language — colors, typography, spacing, components.
- The ForgeApp constitution governs product boundaries. Do not copy stale role/permission/backend
  concepts into this feature — ForgeApp has one local user and no backend (see the constitution's
  Product Mandate).
- When authoritative sources disagree about WHAT the feature does, record the conflict under
  `Source Conflicts or Missing Decisions` and use a specific `[NEEDS CLARIFICATION: ...]` marker
  only when the skill's threshold is met. Never silently choose. Keep at most three markers. An
  already-flagged open product decision (e.g. the Personal Best metric, SDS §3.5) stays flagged
  open here too, unless this feature is the one resolving it.
- When sources disagree only about HOW to build the feature, do not resolve the design in
  `spec.md`; record it as a planning dependency or conflict where relevant.

EXTRACT into `spec.md`, following the active template's exact section order and headings:

- source inputs, versions/status, portable paths, complete-read state, gaps, conflicts, and a
  concise source-coverage summary linked to `source-manifest.md`;
- the feature title, the User Story reference, change category, and implementation-request flag as
  traceability metadata without allowing the flag to expand this standalone run's scope;
- problem statement, business value/objective, in-scope behavior, and explicit exclusions;
- source-backed capability and observable blocked behavior (there is one actor — the single local
  user — so this section is simple by design; do not invent roles or permission tiers);
- prioritized and independently testable `US-###` stories in
  `As a [user], I want [goal], so that [value]` form;
- stable `AC-###` acceptance criteria in Given/When/Then form, covering happy, failure, edge, and
  app-lock-state scenarios;
- testable `FR-###` functional requirements and the active template's applicable state,
  validation, and theme requirements (no adaptive/platform-matrix requirements — phone only;
  no localization requirements — deferred);
- only user-observable validation behavior — for example, when an action is refused and what
  recovery the user gets;
- business entities, meanings, relationships, and lifecycle states when data is involved (map to
  the relevant SDS-DATA-* entities);
- explicit assumptions and source conflicts/missing decisions;
- measurable, technology-agnostic `SC-###` outcomes; and
- requirement/source/success-criterion traceability.

For supplied wireframes, mockups, and Design System references, list the portable asset path and
trace it to the relevant scenario or requirement. Do not recreate or exhaustively describe the
visual design in prose.

DEFER to `$speckit-plan` and its `contracts/` artifacts (where applicable); do NOT embed in
`spec.md`:

- Drift table/column structure, mapper implementation, or storage-layer detail;
- Flutter layers, classes, widgets, Bloc events/states, routing implementation, dependency
  injection, folder structure, sequence diagrams, or other architecture design;
- package, library, or platform-plugin choices beyond the governed set in ADR-030;
- implementation tasks, estimates, release mechanics, Git actions, or fabricated approvals.

Do not weaken a business rule merely because its technical implementation is deferred.

Outputs and completion rules:

- Create/update only the specification-stage artifacts required by the skill and this prompt:
  `spec.md`, `source-manifest.md`, `revision-history.md`, `checklists/requirements.md`, and
  `.specify/feature.json`.
- Set a newly generated or materially refreshed specification to Draft. Record `Approval pending`;
  never invent an approver, date, sign-off, or implementation status — on a solo project, the
  developer is the approver, recorded honestly once they actually review it.
- Validate the result using the skill's checklist loop. A missing source is an explicit
  dependency/readiness gap, not permission to invent content.
- Re-inventory the selected inputs before final validation. Re-read and reconcile any changed file.
- Report the resolved feature directory, spec path, source-manifest coverage, checklist result,
  remaining clarifications/dependency blockers, and whether the next valid step is
  `$speckit-clarify` or G-01 self-review.

=== COMPLETED FORGEAPP FEATURE SDD RUN VALUES START ===

FEATURE_TITLE: <short human-readable feature title>
USER_STORY_REF: <path under Doc/UserStories/>
SOURCE_DISCOVERY_MODE: MANUAL
SDS_INPUT_PATH: Doc/SDS_v2.0.md
USER_STORY_INPUT_PATH: <path under Doc/UserStories/>
DESIGN_SYSTEM_INPUT_PATH: Doc/DESIGN-SYSTEM.md
ADDITIONAL_INPUT_PATHS: NONE
FEATURE_DIRECTORY: AUTO
CHANGE_CATEGORY: Functional Change
IMPLEMENTATION_REQUESTED: NO

=== COMPLETED FORGEAPP FEATURE SDD RUN VALUES END ===
```

## Scope boundary

This reusable prompt deliberately stops after the specification is validated and ready for
clarification or self-review. Continue through the approved standalone prompts indexed in
`prompts/README.md`; do not use the deprecated orchestrator to bypass stage boundaries or gates.
