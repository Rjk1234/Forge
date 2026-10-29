# ForgeApp Reusable Prompts

This directory contains the reusable prompts for creating, reviewing, planning, and implementing
one ForgeApp feature through GitHub Spec Kit.

> **Scope note:** ForgeApp is a single-developer POC with one source corpus inside this project
> (`Doc/SDS_v2.0.md`, `Doc/UserStories/`, `Doc/DESIGN-SYSTEM.md`) and one person performing every
> gate role. The gated sequence is kept — it's still useful discipline for a solo project — but
> simplified to four gates and one role throughout. See `governance/review-gate-framework.md` for
> the full gate rationale.
>
> **Rewrite depth note:** Only [`specify-feature.md`](specify-feature.md) and this README received
> a full line-by-line rewrite for this project. The other five stage prompts
> (`clarify-checklist-feature.md`, `plan-feature.md`, `generate-tasks.md`, `analyze-feature.md`,
> `implement-feature.md`) and the governance utility (`update-mobile-constitution.md`) were
> **stubbed** instead, at the user's choice — content that assumed a different setup was removed,
> but they were not rewritten line-by-line, since this is mechanical SpecKit CLI plumbing the
> project may not run by hand as a solo POC. Each stub explains what the prompt is for and how to
> proceed without it (mainly: the underlying `.agents/skills/speckit-*` / `.claude/skills/speckit-*`
> skills are generic SpecKit tooling and already work unmodified against ForgeApp's
> `.specify/memory/constitution.md`). `mobile-feature-sdd-orchestrator.md` — already deprecated —
> was stubbed as a clear "do not use" pointer rather than rewritten.

Run the approved prompts individually in their gated sequence. They use the feature directory
recorded in `.specify/feature.json`; feature identity never comes from a Git branch. The former
full SDD orchestrator is deprecated.

## Recommended standalone workflow

```text
specify
  ↓
clarify + requirements checklist
  ↓
G-01 self-review
  ↓
plan
  ↓
G-02 self-review
  ↓
tasks
  ↓
read-only analysis
  ↓
G-03 self-review
  ↓
implementation
  ↓
G-04 self-review (analyzer/tests green, code-review-checklist run)
```

Every failed gate blocks the next stage. Machine validation or "Ready for Review" is not a
substitute for actually running the checklist yourself.

## Prompt index

| Order | Prompt | Skill/workflow | Use | Main output or result | Stops at |
| --- | --- | --- | --- | --- | --- |
| 1 | [`specify-feature.md`](specify-feature.md) | `$speckit-specify` | Create or reconcile one specification from the SDS, a User Story, and the Design System | `spec.md`, `source-manifest.md`, `revision-history.md`, `checklists/requirements.md`, `.specify/feature.json` | Clarification or G-01 readiness |
| 2 | [`clarify-checklist-feature.md`](clarify-checklist-feature.md) | `$speckit-clarify` + optional `$speckit-checklist` | Resolve material ambiguity and prepare the requirements-quality gate | Updated `spec.md`, `clarifications.md`, `revision-history.md`, `checklists/requirements.md` | G-01 self-review |
| 3 | [`plan-feature.md`](plan-feature.md) | `$speckit-plan` | Convert the approved specification into a constitution-compliant technical design | `plan.md`, `research.md`, applicable `data-model.md`, `quickstart.md` | G-02 self-review |
| 4 | [`generate-tasks.md`](generate-tasks.md) | `$speckit-tasks` | Generate exact, dependency-ordered, tests-first implementation tasks by user story | `tasks.md` and G-03 task-review handoff | Read-only analysis |
| 5 | [`analyze-feature.md`](analyze-feature.md) | `$speckit-analyze` | Perform a non-destructive consistency, coverage, constitution, ordering, and executability review | Markdown report in the response; retain the exact final report as `analysis.md` | G-03 self-review |
| 6 | [`implement-feature.md`](implement-feature.md) | `$speckit-implement` | Reconcile existing code and execute approved tasks with task-level evidence | ForgeApp application/test changes and proven `[X]` task states | G-04 self-review |

## Using a standalone prompt

1. Open the required prompt file.
2. Copy the text inside its **The prompt** code block into a task.
3. For a new feature, complete the values block in `specify-feature.md` using the fields from
   [`mobile-feature-sdd-run-template.md`](mobile-feature-sdd-run-template.md).
4. Answer interactive clarification questions genuinely.
5. Continue with the next prompt only when the preceding gate has genuinely passed.

The downstream prompts automatically resolve the current feature from:

```text
.specify/feature.json
```

Do not provide or infer a Git branch. If the file is missing, invalid, or selects the wrong
feature, return to the owning specify workflow instead of letting a downstream prompt guess.

## Feature-directory rule

A ForgeApp feature directory is a short, readable slug derived from the feature title.

Example:

```text
Doc/UserStories/US-012-workout-execution.md
                        ↓
Doc/Mobile/specs/workout-execution/
```

Do not invent sequential `NNN-feature-name` numbering unless it genuinely helps — a readable slug
is preferred and sufficient at this project's scale.

## Gate requirements

### G-01 — Specification quality

Required before `plan-feature.md`:

- Current specification is approved (self-reviewed against
  `governance/definition-of-ready.md` §1).
- No material clarification marker remains.
- Current `checklists/requirements.md` is fully satisfied.

### G-02 — Plan and constitution

Required before `generate-tasks.md`:

- Pre-design and post-design Constitution Checks pass.
- No critical planning unknown remains.
- Self-reviewed against `governance/definition-of-ready.md` §2.

### G-03 — Task consistency

Required before `implement-feature.md`:

- Final read-only analysis has zero CRITICAL findings.
- Requirements and acceptance criteria have complete task/test coverage.
- Task ordering is executable.
- The exact final report is retained as `analysis.md`.

### G-04

Required after implementation:

- `fvm flutter analyze` zero issues, `fvm flutter test` green with coverage targets met.
- `standards/code-review-checklist.md` run and all applicable items checked.
- Manually verified on an Android and an iOS device/emulator.

There is no G-05 — that gate assumed a separate QA role and a device/store-release matrix that do
not apply to this single-developer, non-store-distributed POC.

## Clarification behavior by stage

| Stage | Behavior when information is missing or conflicting |
| --- | --- |
| Specify | Makes safe documented assumptions and raises only critical clarifications within the skill limit. |
| Clarify | Asks up to five high-impact questions, one at a time, and integrates accepted answers incrementally. |
| Checklist | Normally needs no extra intake because the reusable prompt predefines its G-01 theme, audience, and depth. |
| Plan | Researches evidence-resolvable technical unknowns; returns genuine open product decisions (e.g. the Personal Best metric) to the constitution's Open Product Decisions list instead of silently resolving them. |
| Tasks | Records unsupported decisions, dependencies, or paths as blockers rather than inventing tasks. |
| Analyze | Reports findings only and offers remediation suggestions; it never edits artifacts. |
| Implement | Asks only when a material answer cannot be discovered safely, then routes the decision through the owning artifact and gate before resuming. |

## Reconciliation and existing-file safety

The workflow is reconciliation-based, not regeneration-by-default:

- `source-manifest.md` detects changed `Doc/SDS_v2.0.md`, User Story, or Design System inputs.
- Material source changes reopen the affected gate and invalidate downstream approval for that old
  baseline.
- Stable `US/AC/FR/SC` and task identifiers should be preserved.
- Historical decisions remain audit evidence but must not be presented as approval of a changed
  baseline.
- Planning preserves an existing plan and reopens G-02 when materially refreshed.
- Task generation must not overwrite completed task progress without explicit authorization.
- Analysis is always read-only.
- Implementation inspects every target first, validates already-satisfied work, minimally completes
  partial work, and stops on material conflicts instead of replacing files wholesale.

Do not automatically cascade edits through every downstream artifact. Reconcile the earliest
affected artifact, then rerun each downstream owning prompt and gate in order.

## Source and authority rules

- The synchronized `.specify/memory/constitution.md` is the sole standing governance input during
  a feature run.
- Do not independently discover ADRs, standards, or governance documents during a feature workflow
  beyond what the skill itself requires.
- `Doc/SDS_v2.0.md` governs the agreed component/data/error scope.
- `Doc/UserStories/` governs business intent and observable acceptance outcomes.
- `Doc/DESIGN-SYSTEM.md` governs visual language.
- Draft, Pending, Missing, and Conflicting statuses must remain visible.

## Implementation authorization

Running earlier SDD prompts does not authorize code changes. `implement-feature.md` requires:

```text
IMPLEMENTATION_AUTHORIZED_NOW: YES
```

It also requires the Flutter application source (the `forge/` project directory) to be inside the
explicitly authorized write scope. If application code is absent or outside that boundary,
implementation stops without creating substitute paths or bypassing the constitution.

## Feature input template

[`mobile-feature-sdd-run-template.md`](mobile-feature-sdd-run-template.md) is the approved neutral
input block for `specify-feature.md`. It records feature identity, source paths, change category,
and implementation-request metadata. It does not invoke a workflow.

## Deprecated orchestrator

[`mobile-feature-sdd-orchestrator.md`](mobile-feature-sdd-orchestrator.md) is deprecated. Do not
use it for new or refreshed ForgeApp features — use the approved stage-specific prompts above
instead.

The standalone sequence indexed in this README is the sole authoritative feature workflow.

## Governance utility

[`update-mobile-constitution.md`](update-mobile-constitution.md) is a separate governance prompt.
Use it only when explicitly synchronizing or amending the ForgeApp constitution and its dependent
Spec Kit artifacts. It is not part of an ordinary feature run.

## QA specification utility

[`generate-qa-specs-batch.md`](generate-qa-specs-batch.md) is a separate QA-authoring prompt. It
generates a QA specification for every ForgeApp user story in one run, reading each user story
file directly (no `spec.md`/`plan.md` is required, since no ForgeApp feature has been through the
standalone workflow above yet) and writing each result to `Doc/UserStories/qa-specs/`. It is not
part of an ordinary feature run and does not require the feature-directory rule above.

## Universal safety rules

- Never run Git or GitHub commands, including read-only commands.
- Never modify `Doc/SDS_v2.0.md`, `Doc/UserStories/`, or `Doc/DESIGN-SYSTEM.md` from a feature
  workflow.
- Never fabricate decisions, contracts, package approvals, or sign-off.
- Never treat a machine checklist or analysis result as a substitute for actually running it.
- Never weaken tests, requirements, or constitutional constraints merely to obtain a passing run.
- Keep all generated documentation paths portable and project-relative.

## Prompt status

This standalone prompt set was established for ForgeApp on 2026-09-08 and is **Approved**. Each
prompt header is the authority for its own version.
