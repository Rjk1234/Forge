# ForgeApp — Flutter Testing Standards

This document is authoritative for ForgeApp testing decisions. Any deviation requires an approved
ADR. Coding conventions (naming, style, error handling) live in `standards/coding-standards.md`,
not here.

---

## 1. Testing Philosophy

Testing is a first-class engineering concern, not a post-implementation activity: all layers must
support automated testing.

Tests must:
- Be deterministic and repeatable
- Be independent of external systems (there are none — no network, no backend — but tests must
  still not depend on real device timers, real database files on disk, etc. where a fake/mock is
  appropriate)
- Mirror the source structure (`test/` mirrors `lib/`)
- Validate business behaviour, not implementation details

The SDS (`Doc/SDS_v2.0.md`) and the ADRs define required behavior. The test suite is executable
evidence that the implementation conforms to them; missing coverage is a verification gap, not a
new source of product truth.

---

## 2. Coverage Targets

| Layer | Target |
|---|---|
| Domain | 90%+ |
| Application (Bloc) | 80%+ |
| Data | 70%+ |
| Presentation | Critical flows |

There is no CI pipeline defined for this POC (`app/platform-requirements.md`), so these targets are
a self-check the developer runs locally, not an automated merge gate — see
`standards/release-readiness-standards.md` §1.

---

## 3. Test Pyramid

```text
          ┌─────────────────────────┐
          │    Integration Tests    │  ← Critical user journeys (§4.3)
          ├─────────────────────────┤
          │      Widget Tests       │  ← UI states & interactions
          ├─────────────────────────┤
          │       Unit Tests        │  ← Domain, Use Cases, Bloc, Repositories
          └─────────────────────────┘
```

The base of the pyramid carries the highest volume. Integration tests are selective and target
critical paths only.

---

## 4. Test Types

### 4.1 Unit Tests

**Scope** — must have unit tests: Use Cases, Repositories, Domain Entities, Domain Business Rules,
Value Objects, Bloc methods/state transitions, Services, Mappers, Failure Mappings.

**Principles**
- Must not depend on the Flutter framework or a real database file on disk.
- Must exercise edge cases and error paths.
- Must verify all Bloc state transitions and all failure types defined in ADR-007.
- Domain layer tests must have zero Flutter or infrastructure dependencies.

**Framework**: `flutter_test` (which exposes `package:test` APIs), `bloc_test`, `mocktail`.

**File convention**:
```text
test/
└── features/
    └── <feature>/
        ├── application/
        │   └── <feature>_bloc_test.dart
        ├── domain/
        │   └── use_cases/
        │       └── <use_case>_test.dart
        └── data/
            └── repositories/
                └── <repository>_test.dart
```

**Naming**: describe the unit under test with `should <expected behavior> when <state under test>`.

```dart
test('should return exercise when id exists in the catalogue', () async {
  // Arrange
  when(() => mockRepository.getExercise('1')).thenAnswer((_) async => tExercise);

  // Act
  final result = await useCase.execute('1');

  // Assert
  expect(result, equals(tExercise));
});
```

### 4.2 Widget Tests

**Scope** — must have widget tests: critical feature screens, shared components in the Design
System (`Doc/DESIGN-SYSTEM.md`), loading/error/success/empty states, user interaction flows.

**Principles**
- Must not touch a real database file. Data-layer tests (local data sources, repositories) use an
  in-memory Drift database (`AppDatabase(NativeDatabase.memory())`), created fresh for each test.
- Bloc and repositories must be mocked.
- State rendering must be verified against all defined states (ADR-027).
- Route navigation triggered by UI interactions is validated through widget tests, not Bloc tests.
- The active-workout rest timer must be tested with a fake/injectable clock, never a real
  `Future.delayed` wait.

**Framework**: `flutter_test`, `mocktail`. (No image-mocking package is needed — ForgeApp has no
remote or network images.)

**File convention**:
```text
test/
└── features/
    └── <feature>/
        └── presentation/
            └── pages/
                └── <screen>_test.dart
```

### 4.3 Integration Tests

**Scope** — critical journeys that must have integration tests:

```text
Static Login → App Unlock

Create Workout Plan → Assign to Schedule

Pre-Start Overview → Active Workout (log sets, rest timer) → Cancel (always discards)

Pre-Start Overview → Active Workout → Finish → Workout Summary

History List → History Detail

Progress Comparison (single exercise, over time)

Statistics Dashboard

Profile Edit → Logout (re-lock, data retained)
```

**Principles**
- Run critical journeys on one Android device/emulator and one iOS device/simulator — there is no
  tablet/iPad matrix to cover (ADR-022, reduced scope).
- There is no backend to mock — integration tests exercise the real Drift-backed flow end to end
  (using an in-memory Drift database, `NativeDatabase.memory()`, created fresh for each test), not a network mock layer.
- Verify the app-lock guard is respected on navigation (ADR-003).
- There is no deep linking, no push notification, and no connectivity-loss scenario to test — none
  of these exist in ForgeApp.

**Framework**: `integration_test`.

**File convention**:
```text
integration_test/
└── journeys/
    └── <journey>_test.dart
```

---

## 5. Bloc Testing Standards

All Bloc tests must use the approved `bloc_test` package to verify state transitions.

**Required coverage per Bloc:**

- Initial state
- Event handling
- State transitions
- Loading states
- Success states
- Empty states (where applicable)
- All failure states (per ADR-007)
- Side effects
- Interaction with Use Cases and Repositories

### Principles

- Test business behavior, not implementation details.
- Every event must produce predictable state transitions.
- Blocs must be tested independently of the UI.
- Dependencies must be mocked.
- Navigation and UI rendering must be tested separately through Widget or Integration Tests.

**Framework:** `bloc_test`, `flutter_test`, `mocktail`

### Example

```dart
blocTest<WorkoutExecutionBloc, WorkoutExecutionState>(
  'emits [InProgress, Completed] when the last set is logged',
  build: () {
    when(() => mockLogSetUseCase(any()))
        .thenAnswer((_) async => const SetLogged());

    return WorkoutExecutionBloc(mockLogSetUseCase);
  },
  act: (bloc) => bloc.add(
    const SetSubmitted(reps: 10, weight: 40),
  ),
  expect: () => [
    const WorkoutExecutionInProgress(),
    const WorkoutExecutionCompleted(),
  ],
  verify: (_) {
    verify(() => mockLogSetUseCase(any())).called(1);
  },
);
```

State expectations must verify every emitted state in the correct order. The `verify` callback
confirms that the appropriate Use Case or Repository interaction occurred with the expected
arguments.

Navigation, dialogs, snack bars, and other UI side effects must be verified independently through
Widget or Integration Tests and must not be asserted directly in Bloc tests.

---

## 6. Mocking Standards

Use `mocktail` — no `mockito` code generation. Register fallback values for custom types in
`setUpAll`.

```dart
class MockWorkoutPlanRepository extends Mock implements WorkoutPlanRepository {}

void main() {
  late MockWorkoutPlanRepository mockRepository;
  late CreateWorkoutPlanUseCase useCase;

  setUp(() {
    mockRepository = MockWorkoutPlanRepository();
    useCase = CreateWorkoutPlanUseCase(mockRepository);
  });

  test('should return ValidationFailure when plan has no exercises', () async {
    when(() => mockRepository.save(any()))
        .thenAnswer((_) async => left(const ValidationFailure.emptyPlan()));

    final result = await useCase.execute(tEmptyPlan);

    expect(result, equals(left(const ValidationFailure.emptyPlan())));
  });
}
```

---

## 7. Test Data

Use the factory pattern for test data creation. Avoid hardcoded objects duplicated across multiple
tests. Test fixtures and factories should be maintained under `test/fixtures/`.

Test data should represent realistic ForgeApp scenarios and cover both successful and failure
cases.

Typical test fixtures include:

| Fixture | Purpose |
|---|---|
| User Profile | Profile edit and display testing |
| Exercise | Catalogue browsing and plan-building testing |
| Workout Plan | Plan creation/edit/schedule testing |
| Workout Schedule | Weekly schedule assignment testing |
| Workout Session | Active workout logging and rest-timer testing |
| Workout Summary | Completion and history-entry testing |
| Derived Statistics | Progress and statistics dashboard testing |

Factories should generate realistic data while allowing customization for individual test
scenarios. Test data should remain deterministic, reusable, and independent of external systems.

---

## 8. Quality Gates

The following must pass before a change is considered complete:

```text
fvm flutter analyze    → zero issues
fvm flutter test        → all tests pass, coverage targets met (§2)
```

Code generation must be up to date — no unresolved generated file conflicts. All layers must
respect the dependency direction defined in ADR-001.

---

## Related Documents

- `governance/definition-of-done.md` — release-readiness criteria beyond test coverage.
- `standards/code-review-checklist.md` — PR review checklist.
- `standards/coding-standards.md` — coding conventions, error handling.
- `ADRs/ADR-001_Architecture_Style.md`, `ADRs/ADR-003_Routing.md`, `ADRs/ADR-007_Error_Handling.md`,
  `ADRs/ADR-022_Responsive_Architecture.md`, `ADRs/ADR-027_Loading_Empty_Error_States.md`.

---
