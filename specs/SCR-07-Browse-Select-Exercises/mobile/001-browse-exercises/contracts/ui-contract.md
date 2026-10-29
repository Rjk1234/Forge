# UI Contract: SCR-07 Browse & Select Exercises

**Branch**: `001-browse-exercises` | **Date**: 2026-09-17

This document specifies the Bloc event/state API and the repository interface contract for the exercise catalogue feature. It serves as the boundary agreement between the application layer and the presentation layer.

---

## ExerciseRepository Interface

**File**: `forge/lib/features/exercise/domain/repositories/exercise_repository.dart`

```
interface ExerciseRepository {
  Future<Either<AppException, List<Exercise>>> getExercises();
}
```

### Contract Rules

- Returns `Right(List<Exercise>)` on success; the list is the full seeded catalogue in the database insertion order.
- Returns `Left(CacheException)` if the `exercises` table query via `AppDatabase` throws.
- The returned list is never null but MAY be empty (treated as `ExerciseCatalogueEmpty` state).
- The repository MUST NOT write to the database.

---

## GetExercisesUseCase Interface

**File**: `forge/lib/features/exercise/domain/usecases/get_exercises_usecase.dart`

```
class GetExercisesUseCase {
  Future<Either<AppException, List<Exercise>>> call();
}
```

Thin delegator to `ExerciseRepository.getExercises()`. No business logic — mapping occurs in the repository impl.

---

## ExerciseCatalogueBloc Events

**File**: `forge/lib/features/exercise/application/bloc/exercise_catalogue_event.dart`

| Event | Fields | Transformer | Trigger |
|---|---|---|---|
| `ExerciseCatalogueLoadRequested` | — | default (concurrent) | Screen `initState` or Retry tap |
| `ExerciseCatalogueSearchChanged` | `query: String` | `restartable()` + 300 ms delay | Search field `onChanged` |
| `ExerciseCatalogueFilterChanged` | `type: ExerciseType?` (null = All) | default | Filter chip tap |

**Idempotent guard**: If `state is ExerciseCatalogueLoading` when `ExerciseCatalogueLoadRequested` arrives, the event is ignored (no duplicate database reads during in-flight load).

---

## ExerciseCatalogueBloc States

**File**: `forge/lib/features/exercise/application/bloc/exercise_catalogue_state.dart`

| State | When emitted | Data |
|---|---|---|
| `ExerciseCatalogueInitial` | Before first event | — |
| `ExerciseCatalogueLoading` | After `LoadRequested`; before repo responds | — |
| `ExerciseCataloguePopulated` | Repo returns ≥1 exercise matching current filter/query | `displayedExercises`, `query`, `activeFilter` |
| `ExerciseCatalogueEmpty` | Repo returns list but 0 exercises match current filter/query | `query`, `activeFilter` |
| `ExerciseCatalogueError` | Repo returns `Left(AppException)` | `message: String` |

### State Transition Diagram

```
Initial
  └─[LoadRequested]──► Loading
                          ├─[repo success, ≥1 match]──► Populated
                          │    ├─[SearchChanged]──► Populated (updated) OR Empty
                          │    ├─[FilterChanged]──► Populated (updated) OR Empty
                          │    └─[LoadRequested]──► Loading (re-load / retry from success)
                          └─[repo failure]──► Error
                               └─[LoadRequested]──► Loading (retry)
```

### Populated State Filtering Contract

Given `_allExercises: List<Exercise>` stored in Bloc:

```
filter(query, activeFilter):
  step 1 — type filter:
    if activeFilter == null → keep all
    else → keep where exercise.type == activeFilter
  step 2 — name filter:
    if query.isEmpty → keep all from step 1
    else → keep where exercise.name.toLowerCase().contains(query.toLowerCase())
  result:
    if filtered.isEmpty → emit ExerciseCatalogueEmpty(query, activeFilter)
    else → emit ExerciseCataloguePopulated(filtered, query, activeFilter)
```

---

## ExerciseCatalogueScreen Interface

**File**: `forge/lib/features/exercise/presentation/screens/exercise_catalogue_screen.dart`

```
class ExerciseCatalogueScreen extends StatefulWidget {
  final PickerContext? pickerContext;   // null = browse mode
}
```

### Mode Contract

| `pickerContext` | Screen mode | Trailing affordance | Banner |
|---|---|---|---|
| `null` | Browse | Chevron-right icon (decorative, non-interactive) | Hidden |
| non-null | Picker | Circular "+" button (tappable) | Visible with plan name |

### Navigation Contract

| Action | Code | Result |
|---|---|---|
| Back tap (either mode) | `context.pop()` | Returns to caller; no value |
| "+" tap in picker mode | `context.pop(exercise.id)` | Returns `String` exerciseId to SCR-09 |
| Retry tap | `bloc.add(ExerciseCatalogueLoadRequested())` | Triggers re-load cycle |

### GoRouter Route Contract

```
path: '/plans/exercises'
Route name constant: RoutePaths.planExercises = '/plans/exercises'
Navigator key: _plansNavigatorKey (Plans branch)
extra type: PickerContext? (null for browse, non-null for picker)
```

**Entry points:**
- Browse: `context.push(RoutePaths.planExercises)` (no extra)
- Picker: `context.push(RoutePaths.planExercises, extra: PickerContext(planName: plan.name))`

---

## Widget Contracts (new reusable widgets)

### ExerciseListItem

```
class ExerciseListItem extends StatelessWidget {
  final Exercise exercise;
  final bool isPickerMode;         // controls trailing affordance
  final VoidCallback? onAddTap;    // only called in picker mode; null in browse
}
```

**Browse mode**: Renders chevron-right icon (`Icons.chevron_right`) in `AppColors.textDim`. Row is NOT wrapped in `GestureDetector` or `InkWell` — fully static (FR-014).

**Picker mode**: Renders circular "+" button (28×28 px `AppColors.lime` circle). `onAddTap` fires on press.

### ExerciseFilterChips

```
class ExerciseFilterChips extends StatelessWidget {
  final ExerciseType? activeFilter;   // null = "All" active
  final ValueChanged<ExerciseType?> onFilterChanged;
}
```

Renders 4 chips: All, Weighted, Time-based, Bodyweight. Exactly one active at a time. Active chip: `AppColors.lime` background, `AppColors.bg` text. Inactive: `AppColors.card` background, `AppColors.textMuted` text.

### ExerciseSearchBar

```
class ExerciseSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isActive;   // true when query is non-empty (lime border/icon)
}
```

### PickerBanner

```
class PickerBanner extends StatelessWidget {
  final String planName;
}
```

Renders the "Adding an exercise to **[Plan Name]**" banner. Only shown in picker mode.

### ExerciseSkeletonList

```
class ExerciseSkeletonList extends StatelessWidget {}
```

Renders 6 shimmer skeleton rows + 4 skeleton filter chip placeholders. Uses `AnimationController` (via `SingleTickerProviderStateMixin` on the parent screen) driven `AnimatedBuilder`.

### ExerciseCatalogueEmptyState

```
class ExerciseCatalogueEmptyState extends StatelessWidget {}
```

Renders the centred empty state: magnifier-minus icon + "No exercises match your search" title + subtitle. No CTA button.

---

## DI Registration Contract

New entries to add in `forge/lib/app/get_it_setup.dart`:

```
// Exercise feature — catalogue screen
getIt.registerLazySingleton<ExerciseRepository>(
  () => ExerciseRepositoryImpl(dataSource: getIt<ExerciseLocalDataSource>()),
);
getIt.registerLazySingleton<GetExercisesUseCase>(
  () => GetExercisesUseCase(repository: getIt<ExerciseRepository>()),
);
getIt.registerFactory<ExerciseCatalogueBloc>(
  () => ExerciseCatalogueBloc(getExercises: getIt<GetExercisesUseCase>()),
);
```

`ExerciseLocalDataSource` is already registered as `ExerciseLocalDataSourceImpl`.
