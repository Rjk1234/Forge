# Definition of Done — ForgeApp

A task (or a complete feature) is **Done** only when ALL applicable items in this checklist are
verified. "Code complete" is not Done. Done means the feature is implemented, tested, and matches
the SDS/spec — appropriate to a single-developer POC/MVP, not a production release process.

---

## Part 1: Individual Task Definition of Done

Every task must meet these criteria before its status can be set to `DONE`:

### Code Quality
- [ ] Code follows all rules in `standards/coding-standards.md`
- [ ] No `TODO`/`FIXME` comments left in committed code (move unresolved items to a new task)
- [ ] No hardcoded values other than the one documented static demo credential
- [ ] Public APIs have `///` documentation for non-obvious logic
- [ ] `fvm flutter analyze` — zero issues
- [ ] Code generation up to date (`build_runner`), no unresolved generated-file conflicts

### Testing
- [ ] Unit tests written for all new use cases, repositories, and mappers
- [ ] Unit tests cover: happy path, edge cases, all failure types (ADR-007)
- [ ] Bloc tests cover all state transitions using `bloc_test`
- [ ] Coverage targets met per `standards/testing-standards.md` §2 (Domain 90%+ / Application
      80%+ / Data 70%+ / Presentation critical flows)
- [ ] All existing tests still pass (no regression)
- [ ] Widget tests written for new screens (loading/success/error/empty states)
- [ ] Integration test added/updated if this feature is on the critical-journey list
      (`standards/testing-standards.md` §4.3)
- [ ] Mocks are appropriate (`mocktail`) — only mock external dependencies, not the class under test

### Architecture Compliance
- [ ] Clean Architecture layering respected; domain layer has zero Flutter/Drift dependencies
      (ADR-001)
- [ ] No cross-feature imports outside the barrel file (`governance/architecture-boundaries.md`)
- [ ] `flutter_bloc` only for state, `go_router` only for navigation, Drift only for persistence

### Security
- [ ] No sensitive values logged (`standards/security-standards.md` §6)
- [ ] Input validation implemented on all user-facing forms (ADR-026)
- [ ] `standards/security-standards.md` §6 secure coding checklist run and passed

### Self-Review
- [ ] `standards/code-review-checklist.md` run and all applicable items checked
- [ ] Manually verified on at least one Android device/emulator and one iOS device/simulator

---

## Part 2: Feature-Level Definition of Done

A complete feature is Done when ALL of the following are verified:

### All Tasks Complete
- [ ] Every task for the feature is marked `DONE`
- [ ] No tasks are `BLOCKED` (blocked tasks must be resolved or explicitly deferred with a
      documented rationale)

### Feature Validated
- [ ] Feature installed and run on at least one Android phone/emulator and one iPhone/simulator
      (`app/platform-requirements.md`'s minimum supported Android/iOS versions) — no tablet/iPad
      matrix applies (ADR-022, reduced scope)
- [ ] Happy path and key error paths manually walked through by the developer
- [ ] The feature's acceptance criteria (in its `spec.md`, where one exists, or the relevant User
      Story in `Doc/UserStories/`) are demonstrably satisfied

### Documentation Updated
- [ ] `tasks.md` (if the feature uses one) — all tasks marked `DONE`
- [ ] `spec.md` (if the feature uses one) — status updated to `Done` in document header
- [ ] If this feature introduced a new architectural decision: ADR added to `ADRs/`
- [ ] If this feature changed an existing standard: the relevant `standards/` document updated

### Release Readiness
- [ ] `standards/release-readiness-standards.md` checklist reviewed for this feature

---

## Part 3: Definition of Done for Hotfixes

Hotfixes are expedited changes for a defect found after a feature was marked Done. They follow a
shortened DoD:

- [ ] Bug reproduced and root cause identified
- [ ] Fix implemented with minimum necessary scope
- [ ] Regression test added for the bug scenario
- [ ] `fvm flutter analyze` and `fvm flutter test` pass
- [ ] Verified on a real device/emulator

---

## Part 4: What "Done" Is NOT

The following states are **not** Done:

| State | Why It's Not Done |
|-------|------------------|
| "Code is complete but tests aren't written yet" | Tests are not optional — they are part of the task |
| "Works on my machine" | Must still be verified on both an Android and an iOS device/emulator |
| "Feature is built but spec is not updated" | Spec update is part of the task, not optional housekeeping |
| "Coverage is a few points under target, close enough" | Coverage targets in `standards/testing-standards.md` are a hard requirement |

---
