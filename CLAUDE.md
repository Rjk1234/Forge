# Rider app — Agent Instructions (CLAUDE.md)

This file is read by Claude Code and compatible coding agents before every session.
All instructions are **enforceable rules**, not suggestions.
Project-level conventions override general instructions; mention any conflict before acting on it.

---

## Project Constraints (Constitutional — Non-Negotiable)

These override every other instruction in this file.

- **No Git operations**: Agents, automation, SpecKit skills, hooks, and workflows MUST NOT execute any Git or GitHub repository operation.
- **Governed dependencies**: Dependencies MUST be declared centrally in `pubspec.yaml`. No package outside the governed set (see `pubspec.yaml` and ADR-030) may be added without a new ADR.
- **State management**: `flutter_bloc` is the sole state-management framework. `Cubit` MUST NOT be introduced. Use `Bloc` only.
- **Router**: `go_router` is the sole router. Do not introduce a second routing mechanism.
- **DI**: `GetIt` is the approved DI mechanism. Do not introduce Riverpod, Provider, InheritedWidget-as-DI, or service locators.
- **Theme**: Single fixed dark theme per ADR-037. Do not add a light theme, dynamic theme switching, or hardcoded colors.

---

## Architecture

ForgeApp follows **Clean Feature-First Architecture**. Each feature under `forge/lib/features/<feature>/` owns four layers:

```
features/<feature>/
├── domain/          ← entities, repository interfaces (no framework dependencies)
├── application/     ← Bloc, events, states, use cases
├── data/            ← Drift data sources, repository implementations
└── presentation/    ← screens, widgets (reads state; dispatches events)
```

Layer rules:
- `domain/` must not import `data/`, `application/`, `presentation/`, or any Flutter/Drift package.
- `application/` may import `domain/` only.
- `data/` may import `domain/` and Drift.
- `presentation/` may import `application/` and `domain/`; never `data/`.
- Bloc belongs in `application/bloc/`, not `presentation/bloc/`.

---

## General Implementation Rules

1. Read the existing project structure, conventions, and relevant files **before** making any change. Do not introduce patterns that conflict with the established codebase.
2. Follow the project's existing architecture. Do not introduce a new architecture, state-management library, or design pattern unless explicitly requested.
3. Prefer simple, readable, maintainable code over clever or overly abstract solutions.
4. Do not make unrelated changes. Keep modifications limited to the requested feature, bug fix, or refactoring.
5. Do not duplicate existing functionality. Search for reusable widgets, helpers, extensions, constants, themes, and utilities before creating new ones.
6. Do not create speculative abstractions. Extract reusable code only when there is a clear reuse case or the component represents a meaningful UI/domain concept.
7. Do not leave dead code, unused imports, unused variables, commented-out implementations, or debug statements.
8. Do not use `dynamic`, `Object?`, or unchecked casts to bypass type-safety without a documented justification.
9. Do not suppress analyzer warnings or lint rules just to make code compile. Fix the underlying issue.
10. After implementation: run `dart format .`, `flutter analyze`, and `flutter test`. Resolve every error and warning introduced by the change.

---

## Method & Function Size

11. Keep methods ≤ 60 lines of executable logic (excluding declarations, whitespace, comments).
12. Split long methods into meaningful private helpers. Do not create trivial one-line methods just to satisfy the limit.
13. One method = one responsibility. Do not mix API calls, state mutation, navigation, validation, and UI construction in one method.
14. Avoid deeply nested conditionals. Prefer early returns, guard clauses, and named booleans.
15. Avoid long parameter lists. Use a typed parameter object or model when a method takes many related parameters.
16. Do not put the entire screen UI inside one `build()` method. Break complex screens into meaningful widgets.
17. Keep callbacks small. If `onPressed` / `onChanged` contains substantial logic, extract it into a named method.

---

## Widget & Component Structure

18. Do not create private widgets (`_MyWidget`) for UI components that represent a reusable concept. Create a named public widget instead.
19. Prefer reusable public widgets for: app buttons, text fields, cards, app bars, empty states, loading states, error states, list items, status badges, dialogs, bottom sheets, section headers, common layouts.
20. Do not create a new widget when an existing reusable component already serves the purpose. Extend or improve the existing one.
21. Extract repeated UI into reusable widgets. Do not duplicate layout, styling, or interaction logic across screens.
22. Prefer composition over large configurable widgets with excessive boolean flags.
23. Reusable widgets must expose meaningful typed parameters: `title`, `subtitle`, `icon`, `onTap`, `padding`, `isLoading`, `variant`, `child`.
24. Avoid unnecessary wrapper widgets. Every widget must contribute to layout, behavior, styling, accessibility, or reuse.
25. Use `const` constructors and `const` widgets wherever possible.
26. Prefer immutable widget properties (`final` fields). Use mutable state only when the widget genuinely requires it.
27. Default to `StatelessWidget`. Use `StatefulWidget` only when local mutable state is actually required.

---

## UI, Theme & Design System

The app uses a **single fixed dark theme**. All tokens are defined in `forge/lib/core/theme/`.


28. **Never hardcode colors in widgets.** Always use `Theme.of(context).colorScheme`, `AppColors.*`, or a `ThemeExtension`.
29. Do not use `Colors.red`, `Colors.white`, `Colors.black`, `Colors.grey`, or any other static Flutter color for application UI.
30. **Never hardcode text styles.** Use `Theme.of(context).textTheme.*`.
31. Do not manually recreate typography styles. Reuse `AppTypography` and `theme.textTheme`.
32. Do not hardcode spacing, border radii, elevations, icon sizes, or component dimensions. Use design tokens or shared constants.
33. Do not call `Theme.of(context)` repeatedly in one `build()`. Store it in a local variable.
    ```dart
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    ```
34. Use `MediaQuery`, `LayoutBuilder`, and responsive techniques instead of hardcoded device dimensions.
35. Avoid `double.infinity`, fixed heights, and fixed widths when they can cause layout issues across screen sizes.

---

## Strings, Assets & Constants

36. **Never hardcode user-facing strings in widgets.** Use `AppStrings.*` or the project's localization system.
    - Avoid: `Text('Something went wrong')`
37. Do not hardcode asset paths. Use centralized asset constants or generated references.
38. Do not scatter static constants in unrelated widgets. Place them in the appropriate centralized or feature-specific constants file.
39. Extract magic numbers into named constants when they represent business rules, dimensions, limits, durations, or configuration.
40. Use enums or typed models over arbitrary string comparisons for business identifiers.

---

## State Management (Bloc)

41. Use `Bloc` only. Do not introduce `Cubit`, Provider, Riverpod, GetX, or any other state-management approach.
42. Keep business logic out of widgets. Widgets render state and dispatch events.
43. Do not run database calls directly inside `build()`.
44. Do not trigger side effects during widget rebuilding. Use lifecycle methods, Bloc events, listeners, or controlled callbacks.
45. Do not use `setState()` for business or application state. Use local state only for genuinely local UI concerns (e.g., text field focus, animation controller).
46. Keep Bloc responsibilities focused. A Bloc coordinates state transitions and business logic — not UI concerns.
47. Do not place large amounts of logic inside `BlocBuilder` or `BlocListener` callbacks. Extract into dedicated methods or layers.
48. Use `BlocBuilder` with `buildWhen` when selective rebuilding is beneficial and the condition is readable.
49. Use `BlocSelector` when a widget depends only on a specific portion of state.
50. Do not emit redundant states or trigger unnecessary reads. Ensure events and state transitions are intentional.
51. Handle `loading`, `success`, `empty`, and `error` states explicitly. Never assume a successful read always returns usable data.

---


## Navigation (go_router)

59. Use `go_router` only. Do not introduce a second routing mechanism.
60. Do not navigate from repository, data-source, or use-case classes. Navigation belongs to the presentation layer.
61. Keep route names and route arguments centralized.
62. Avoid passing `BuildContext` through multiple layers just to navigate or show a dialog.
63. After an `async` gap, check `context.mounted` before using `context`.
    ```dart
    if (!context.mounted) return;
    ```

---

## Performance & Rebuilds

64. Use `const` wherever possible to reduce unnecessary widget reconstruction.
65. Avoid expensive computations inside `build()`. Move them to state, selectors, or use cases.
66. Use `ListView.builder` / `SliverList` for large or unbounded lists.
67. Avoid `shrinkWrap: true` unnecessarily inside scrollable lists.
68. Use stable keys for dynamic lists, reorderable items, or stateful children.
69. Do not use `UniqueKey()` or changing keys to force rebuilds without a clear, documented reason.
70. Do not create timers, streams, or subscriptions inside `build()`. Manage their lifecycle in `initState` / `dispose`.

---

## Async & Lifecycle Safety

71. Dispose controllers, focus nodes, animation controllers, streams, and subscriptions in `dispose()`.
72. Do not update state after disposal. Verify lifecycle validity where necessary.
73. Avoid sequential `await` chains when independent operations can run concurrently.
74. Do not introduce `Future.delayed()` to hide race conditions or paper over timing bugs.

---

## Naming & Code Quality

75. Use descriptive names. Avoid `data`, `item`, `result`, `temp` when a more meaningful name exists.
76. Dart naming conventions:
    - `PascalCase`: classes, enums, extensions
    - `camelCase`: variables, methods, parameters
    - `snake_case.dart`: file names
77. Use enums, sealed classes, and typed models when they improve correctness and readability.
78. Prefer named booleans: `isLoading`, `isEnabled`, `showDivider` over ambiguous positional booleans.
79. Do not use abbreviations unless widely understood in the project.
80. Keep files focused. Do not place unrelated widgets, models, utilities, and Blocs in one file.
81. Write comments only when explaining non-obvious intent, a hidden constraint, or a workaround. Never comment what the code already says.

---

## Error, Empty & Loading UI

82. Use shared loading indicators (`LoadingIndicator`) wherever they exist.
83. Use shared error-state and empty-state components instead of recreating them per screen.
84. Loading, error, empty, and success states must have consistent spacing, typography, colors, and behavior.
85. Do not surface raw exception messages to users. Map technical errors to user-facing copy.
86. Do not leave screens blank when data is unavailable. Always provide a loading, empty, or error state.

---

## Testing

87. Write tests for meaningful business logic, state transitions, validation, and critical flows.
88. Do not rely only on manual UI verification for logic that can be unit-tested.
89. When modifying an existing feature, preserve existing behavior unless the change explicitly alters it.
91. Do not claim a feature is complete if analyzer errors remain or known tests are failing.

---

## Agent Workflow Checklist

Before writing code, identify:
- Relevant existing files and their current content
- Existing reusable components (widgets, helpers, extensions, constants)
- Theme and design-system usage patterns in similar screens
- State-management flow (existing Bloc events/states)
- Drift data-source interfaces already registered in GetIt
- Navigation conventions (existing routes in `app_routes.dart`)
- Similar existing features to use as reference

After writing code, review specifically for:
- [ ] Hardcoded strings (use `AppStrings`)
- [ ] Hardcoded colors (use `AppColors` / `colorScheme`)
- [ ] Hardcoded text styles (use `textTheme`)
- [ ] Duplicate UI (extract to reusable widget)
- [ ] Overly long methods or `build()` (split into helpers)
- [ ] Unnecessary private widgets (make public if reusable)
- [ ] Unnecessary local state (`setState` when Bloc is appropriate)
- [ ] Unnecessary rebuilds (missing `buildWhen`, `const`, `BlocSelector`)
- [ ] Missing loading / error / empty states
- [ ] Unused code, imports, or variables
- [ ] Analyzer warnings introduced by the change
- [ ] Constitutional violations (network call, new package, Cubit, hardcoded theme)

---

## Non-Negotiable (Strict Rules)

These are **never acceptable** without an explicit new ADR or the user's direct instruction:

- Hardcoded user-facing strings
- Hardcoded application colors
- Hardcoded typography styles
- Duplicate UI when a reusable component can serve the purpose
- Business logic inside widgets
- Bloc emitting from `build()` or a layout callback
- New dependency without justification
- Unrelated refactoring bundled with a feature change
- Analyzer warnings introduced by the implementation
- Private widget (`_MyWidget`) when a meaningful public reusable widget is appropriate
- `Cubit`, Provider, Riverpod, or any state-management approach other than `Bloc`
- Second router alongside go_router
