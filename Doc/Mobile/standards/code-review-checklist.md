# ForgeApp — Code Review Checklist

A condensed checklist for reviewing ForgeApp pull requests. Each item is a tick-check, not an
explanation — see the linked standards doc for rationale. Companion to `governance/definition-of-done.md`.

---

## 1. General Quality
- [ ] Solves the intended requirement; matches the story's acceptance criteria
- [ ] No unnecessary complexity or speculative/unused code
- [ ] No TODO/FIXME without a tracking note
- [ ] No duplicated logic (DRY)

## 2. Naming & Readability
- [ ] `snake_case` files, `PascalCase` classes, `camelCase` members
- [ ] Names express intent; no unexplained abbreviations

## 3. Architecture Compliance
- [ ] Clean Architecture layer boundaries respected; dependencies point inward
- [ ] Domain layer has zero framework or Drift dependencies
- [ ] Feature-first structure maintained; no cross-feature internal imports

*(See `governance/architecture-boundaries.md`, ADR-001, ADR-032)*

## 4. SOLID Principles
- [ ] Single Responsibility, Open/Closed, Liskov, Interface Segregation, Dependency Inversion respected
- [ ] Composition preferred over inheritance

## 5. State Management
- [ ] `flutter_bloc` used exclusively, `Bloc` only (ADR-002)
- [ ] Business logic does not exist inside Widgets
- [ ] Widgets never access Drift/repositories directly
- [ ] Bloc states are immutable
- [ ] Loading, Success, Empty, and Error states all handled (ADR-027)

## 6. Domain Layer
- [ ] Entities remain framework-independent, no Drift table or generated-code logic leaked into domain
- [ ] Use cases are single-responsibility

## 7. Data Layer
- [ ] Record-to-entity mapping confined to the data layer; repositories map to domain entities
- [ ] No infrastructure concerns leaked outside the data layer

*(See ADR-008)*

## 8. Error Handling
- [ ] Exceptions never swallowed
- [ ] Typed `Failure` subtypes used (local read/write, validation) — see ADR-007
- [ ] Raw Drift exceptions never cross the data layer boundary

## 9. Null Safety
- [ ] Sound null safety; no unsafe `!` force unwrap without justification

## 10. Async & Concurrency
- [ ] `async`/`await` used; no unnecessary `.then()` chains
- [ ] Drift I/O never blocks the UI thread, particularly during the active-workout timer (ADR-021)

## 11. Performance
- [ ] `const` constructors used wherever possible
- [ ] Large lists (exercise catalogue, history) use `ListView.builder`
- [ ] No expensive computation inside `build()`

## 12. Security
- [ ] Full checklist lives in `security-standards.md` §11 — run that checklist, don't duplicate it here.

## 13. UI & UX
- [ ] Matches the ForgeApp Design System (`Doc/DESIGN-SYSTEM.md`) — colors, typography, spacing, radii
- [ ] Loading, empty, and error states all handled (ADR-027)
- [ ] Basic accessibility considered (tap target size, no color-only indicators — ADR-028)

## 14. Testing
- [ ] Unit tests added for new business logic
- [ ] Happy path, error path (Drift read/write failure), and edge cases covered
- [ ] Tests are deterministic

*(See `testing-standards.md` §2)*

## 15. Logging
- [ ] No `print` statements; the shared Logging Service used instead (ADR-020)
- [ ] No profile field values logged verbatim

## 16. Dependencies
- [ ] No unnecessary package added
- [ ] No duplicate functionality introduced (e.g. a second persistence or state-management library)

## 17. Documentation
- [ ] Public APIs documented with `///`
- [ ] ADR added/updated if the change touches an architectural decision

## 18. Build
- [ ] `flutter analyze` — zero issues
- [ ] Drift code generation up to date (`build_runner`), no unresolved generated-file conflicts

## 19. Pull Request Quality
- [ ] PR scope is focused; description is complete
- [ ] Screenshots attached for UI changes

## 20. Dependency Injection
- [ ] GetIt used exclusively; no manual singleton creation
- [ ] Constructor injection preferred

## 21. Navigation
- [ ] `go_router` used exclusively
- [ ] The app-lock guard is respected (ADR-003)

## 22. Validation
- [ ] Validation follows ADR-026
- [ ] Error messages are clear and specific

---

## Related Documents

- `standards/coding-standards.md`, `standards/testing-standards.md`, `standards/security-standards.md`
- `governance/architecture-boundaries.md`
- `governance/definition-of-done.md`
