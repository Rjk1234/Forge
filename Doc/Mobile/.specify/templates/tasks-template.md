---
description: "Rider Mobile feature task template"
---

# Tasks: [FEATURE NAME]

**Input**: `specs/[EXACT BA USER-STORY FOLDER NAME]/` approved `spec.md`, `plan.md`, research, model, contracts,
quickstart, checklists, and source evidence.

**Ready Gate**: Tasks may be generated before final G-03 approval, but implementation MUST NOT begin
until Definition of Ready and G-01/G-02/G-03 pass.

**Tests**: Tests are mandatory feature work under the constitution and testing standards. Generate
the applicable unit, widget, integration, responsive, security, and performance evidence tasks.

## Format: `- [ ] T### [P?] [US#?] Action with exact path — AC/evidence`

- `[P]` means different files and no dependency on incomplete work.
- `[US#]` is mandatory inside user-story phases and maps to the spec story.
- Every task MUST cite exact file paths, requirement/acceptance IDs, acceptance evidence, and an
  estimate no greater than one working day.
- No task may perform Git, GitHub repository, branch, commit, PR, merge, push, or issue operations.

## Phase 1: Setup and Source Verification

- [ ] T001 Verify all source/contract paths from spec.md are available and record unresolved gaps in specs/[EXACT BA USER-STORY FOLDER NAME]/revision-history.md — source table complete — [estimate]
- [ ] T002 Confirm existing Flutter feature/core paths and approved dependencies without adding packages in specs/[EXACT BA USER-STORY FOLDER NAME]/plan.md — Constitution I/II/X — [estimate]
- [ ] T003 [P] Prepare test fixtures and mock API evidence under test/fixtures/ from approved contracts — plan test strategy — [estimate]

## Phase 2: Foundational Architecture

**Purpose**: Only shared prerequisites proven necessary by this feature. Do not recreate existing
infrastructure or introduce speculative abstractions.

- [ ] T004 Implement or extend required Domain contracts in lib/features/[feature]/domain/ per [FR IDs] — unit-test acceptance — [estimate]
- [ ] T005 [P] Implement contract DTOs and explicit mappers in lib/features/[feature]/data/ per contracts/[file] — mapping-test acceptance — [estimate]
- [ ] T006 Implement repository/DataStore flow in lib/features/[feature]/data/ without direct Dio per [FR IDs] — failure-mapping acceptance — [estimate]
- [ ] T007 Implement immutable Bloc state foundation in lib/features/[feature]/application/ per [ST IDs] — bloc_test acceptance — [estimate]

**Checkpoint**: Foundational work passes applicable tests and does not violate an accepted or
conflicted dependency decision.

## Phase 3: US-001 — [TITLE] (P1)

**Goal**: [source-backed value]

**Independent Test**: [spec test]

### Tests First

- [ ] T008 [P] [US1] Add Domain/use-case tests in test/features/[feature]/domain/ for US-001 acceptance scenarios — [AC IDs] — [estimate]
- [ ] T009 [P] [US1] Add repository/mapper/failure tests in test/features/[feature]/data/ for US-001 — [FR/AC IDs] — [estimate]
- [ ] T010 [P] [US1] Add Bloc transition tests in test/features/[feature]/application/ for all applicable states — [ST/VAL IDs] — [estimate]
- [ ] T011 [P] [US1] Add widget/adaptive tests in test/features/[feature]/presentation/ for compact/medium/expanded, portrait/landscape, text scaling, keyboard/focus, and errors — [UI IDs] — [estimate]
- [ ] T012 [US1] Add/update integration journey in integration_test/journeys/[feature]_test.dart using mock APIs and applicable four-device evidence — [AC/NFR IDs] — [estimate]

### Implementation

- [ ] T013 [US1] Implement use case in lib/features/[feature]/application/ per [FR/AC IDs] — tests pass — [estimate]
- [ ] T014 [US1] Implement server-authoritative workflow and validation mapping in lib/features/[feature]/application/ and data/ per [FR/VAL IDs] — no optimistic transactional success — [estimate]
- [ ] T015 [US1] Implement presentation states and adaptive UI in lib/features/[feature]/presentation/ per [ST/UI/LOC/THEME IDs] — widget evidence — [estimate]
- [ ] T016 [US1] Integrate centralized routing/permission/logging boundaries in existing approved paths per [SEC/FR IDs] — sanitized evidence — [estimate]

**Checkpoint**: US-001 is independently functional and testable across its applicable matrix.

## Phase 4+: Additional User Stories

Repeat the US-001 structure for each source-backed story in priority order. Tests precede
implementation; each story remains independently testable and uses its own `[US#]` labels.

## Final Phase: Cross-Cutting Validation and Done Evidence

- [ ] TXXX [P] Verify localization resources and locale-aware values in lib/l10n/ for all user-visible content — LOC IDs — [estimate]
- [ ] TXXX [P] Verify security/privacy/log sanitization and permission outcomes against standards/security-standards.md — SEC IDs — [estimate]
- [ ] TXXX [P] Verify coverage thresholds and analyzer/formatter/code-generation evidence — Constitution XII — [estimate]
- [ ] TXXX Validate quickstart.md and affected critical journeys on the required Android phone, iPhone, Android tablet, and iPad matrix — NFR/UI IDs — [estimate]
- [ ] TXXX Update specs/[EXACT BA USER-STORY FOLDER NAME]/revision-history.md and Done evidence without creating human sign-off — governance evidence — [estimate]

## Dependencies and Execution Order

- Setup/source verification precedes Foundational work.
- Foundational work precedes user-story implementation.
- Tests for a behavior MUST fail for the expected missing behavior before implementation.
- Tasks touching the same file run sequentially even if otherwise marked `[P]`.
- A story may depend on shared foundations but SHOULD remain independent of another story.
- Cross-cutting validation follows all in-scope stories.

## Requirement-to-Task-to-Test Coverage

| Requirement / AC | Plan Decision | Implementation Tasks | Test/Evidence Tasks | Coverage |
|---|---|---|---|---|
| [ID] | [plan section] | [T IDs] | [T IDs] | [complete/gap] |

## G-03 Evidence

**Analysis**: Human-retained `analysis.md` from the read-only `speckit-analyze` report, with zero
CRITICAL findings and complete requirement coverage

**Tech Lead**: [name/date or PENDING]

**Implementing Developer**: [name/date or PENDING]

Implementation MUST stop while G-03 or Definition of Ready is incomplete.
