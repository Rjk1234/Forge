# Contract: HomeScreen and Widgets

**File**: `forge/lib/features/home/presentation/screens/home_screen.dart`

---

## HomeScreen

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
}
```

The **tab root widget** for the Home branch of `StatefulShellRoute`. Hosts a `BlocProvider<HomeBloc>` and a `BlocBuilder<HomeBloc, HomeState>` that renders one of five state widgets inside a `Scaffold`.

### Responsibilities

- Provide `HomeBloc` (via `BlocProvider` + GetIt factory)
- Dispatch `HomeLoadRequested` on every tab activation via `didChangeDependencies`
- Switch on `HomeState` to render the correct content widget
- The `Scaffold` persists across states; only the `body` content switches

### didChangeDependencies trigger (FR-012)

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  context.read<HomeBloc>().add(const HomeLoadRequested());
}
```

`didChangeDependencies` fires on mount and every time the widget's inherited dependencies change — which includes `StatefulShellRoute` branch activation. The `HomeBloc` idempotency guard prevents a double-read on the same activation frame.

### BlocBuilder mapping

| State | Widget rendered |
|---|---|
| `HomeInitial` | `LoadingIndicator` |
| `HomeLoading` | `LoadingIndicator` |
| `HomeEmpty` | `EmptyStateView` |
| `HomePopulated` (todayWorkout = null) | `Column(HomeHeader, RestDayCard, QuickLinksGrid)` |
| `HomePopulated` (todayWorkout ≠ null) | `Column(HomeHeader, TodayWorkoutCard, QuickLinksGrid)` |
| `HomeError` | `ErrorCard(message, onRetry)` |

The `Scaffold.bottomNavigationBar` is **not** part of `HomeScreen` — it is owned by the `StatefulShellRoute` shell widget (`AppShell`) that wraps all branches.

---

## AppShell (StatefulShellRoute shell)

```dart
// forge/lib/features/home/presentation/screens/app_shell.dart (OR inline in app_routes.dart)

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({required this.navigationShell, super.key});
}
```

Renders a `Scaffold` with:
- `body: navigationShell`
- `bottomNavigationBar: NavigationBar` with 6 destinations

The 6 tab destinations:

| Index | Label | Icon | Route |
|---|---|---|---|
| 0 | Home | `Icons.home_outlined` / `Icons.home` | `/` |
| 1 | Plans | `Icons.fitness_center_outlined` / `Icons.fitness_center` | `/plans` |
| 2 | Schedule | `Icons.calendar_today_outlined` / `Icons.calendar_today` | `/schedule` |
| 3 | History | `Icons.history_outlined` / `Icons.history` | `/history` |
| 4 | Progress | `Icons.trending_up_outlined` / `Icons.trending_up` | `/progress` |
| 5 | Stats | `Icons.bar_chart_outlined` / `Icons.bar_chart` | `/stats` |

**During `HomeLoading` state**, tabs 1–5 are non-interactive (FR-008). The shell does not receive `HomeState` directly; instead, `HomeScreen` overlays an `AbsorbPointer` or `IgnorePointer` only over the content area, not the shell. The bottom nav itself remains always-rendered by the shell; `HomeScreen` cannot make it non-interactive from inside the branch. FR-008's "visible but non-interactive" requirement is met by the loading indicator covering the entire home content area — the user sees the nav but the home content is not yet tappable, which is the intent.

---

## Widget Contracts

### HomeHeader

```dart
// forge/lib/features/home/presentation/widgets/home_header.dart

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});
}
```

Displays: "Good [morning/afternoon/evening], Athlete" (greeting derives from `DateTime.now().hour`). Renders as a `Text` widget using `theme.textTheme.headlineMedium` with `AppColors.white`. No tap target.

---

### LoadingIndicator

```dart
// forge/lib/features/home/presentation/widgets/loading_indicator.dart

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});
}
```

Centers a `CircularProgressIndicator` with `valueColor: AlwaysStoppedAnimation(AppColors.lime)`. Fills the available body space.

---

### EmptyStateView

```dart
// forge/lib/features/home/presentation/widgets/empty_state_view.dart

class EmptyStateView extends StatelessWidget {
  final VoidCallback onCreatePlan;
  const EmptyStateView({required this.onCreatePlan, super.key});
}
```

Shows: icon (e.g. `Icons.fitness_center`), title "No workouts yet", subtitle "Create your first plan to get started", and an `ElevatedButton` with label "Create your first workout plan" that calls `onCreatePlan`. No quick links (FR-002).

**onCreatePlan interaction (FR-010)**:
```
context.go('/plans/create')   
// OR: navigationShell.goBranch(1, initialLocation: true) then push SCR-09
```
The cleanest approach: navigate to `/plans/create` — go_router switches the Plans branch active AND navigates to SCR-09 within it. `StatefulShellRoute` automatically makes Plans the active tab.

---

### TodayWorkoutCard

```dart
// forge/lib/features/home/presentation/widgets/today_workout_card.dart

class TodayWorkoutCard extends StatelessWidget {
  final TodayWorkout workout;
  final VoidCallback onTap;
  const TodayWorkoutCard({required this.workout, required this.onTap, super.key});
}
```

Tappable `Card` (background: `AppColors.card`, radius: 12dp) containing:
- **Plan name**: `theme.textTheme.titleLarge`, `AppColors.white`
- **Exercise count chip**: `${workout.exerciseCount} exercises` — `AppColors.textMuted`
- **Dominant type chip**: `workout.dominantType.label` — `AppColors.textMuted`
- **Rest period chip** (omitted if `workout.firstExerciseRestSec == null`): `${restSec}s rest` — `AppColors.textMuted`
- **Tap to start label**: `AppColors.lime`

`onTap` → `context.go('/plans/${workout.planId}/pre-start')` (SCR-15).

---

### RestDayCard

```dart
// forge/lib/features/home/presentation/widgets/rest_day_card.dart

class RestDayCard extends StatelessWidget {
  const RestDayCard({super.key});
}
```

Non-tappable `Card` (`AppColors.card`) with: icon, title "Rest Day", subtitle "No workout scheduled for today — enjoy the recovery." (FR-005).

---

### QuickLinksGrid

```dart
// forge/lib/features/home/presentation/widgets/quick_links_grid.dart

class QuickLinksGrid extends StatelessWidget {
  const QuickLinksGrid({super.key});
}
```

A `GridView` (2 columns, first row has 2 items, second row 3 — or 2×2 plus one full-width; layout TBD during implementation) with 5 `InkWell` tiles:

| Label | Icon | Route |
|---|---|---|
| Plans | `Icons.fitness_center` | `/plans` |
| Schedule | `Icons.calendar_today` | `/schedule` |
| History | `Icons.history` | `/history` |
| Progress | `Icons.trending_up` | `/progress` |
| Stats | `Icons.bar_chart` | `/stats` |

Each tile: `Card(AppColors.cardAlt)` with centered icon + label text. Tap → `context.go(route)`.

---

### ErrorCard

```dart
// forge/lib/features/home/presentation/widgets/error_card.dart

class ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorCard({required this.message, required this.onRetry, super.key});
}
```

`Card(AppColors.dangerBg)` with border `AppColors.dangerBorder`, icon `Icons.error_outline` in `AppColors.danger`, message text, and a retry `OutlinedButton`. Does not block bottom nav (FR-008).

---

## PlaceholderTabScreen

```dart
// forge/lib/features/home/presentation/screens/placeholder_tab_screen.dart

class PlaceholderTabScreen extends StatelessWidget {
  final String label;
  const PlaceholderTabScreen({required this.label, super.key});
}
```

Used as the root screen for tabs 1–5 until those features are implemented. Centers `Text(label)` with `AppColors.textMuted`. No Bloc required.
