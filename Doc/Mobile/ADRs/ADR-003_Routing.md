# ADR-003 Routing

Version: 2.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed role-based routing, notification-driven
>   navigation, and QR-workflow navigation (all N/A — no backend, no roles, no notifications, no
>   QR). Replaced the route list with ForgeApp's 25 screens. `go_router` choice and its rationale
>   are unchanged.

---

# Context

ForgeApp contains a fixed set of screens (SCR-01 through SCR-27; see
`Doc/UserStories/README.md`). The application requires centralized navigation, a single app-lock
gate (locked → Login; unlocked → Home and beyond), and simple, maintainable routing independent
of business logic. There is no role-based access, no push-notification navigation, and no QR
workflow to route from.

---

# Decision

The application shall use `go_router` as the single routing framework. All navigation shall be
managed through a centralized router configuration.

---

# Route Ownership

Each screen owns its route definition:

```dart
static const String routePath;
static const String routeName;
```

---

# Navigation Principles

- Navigation shall be centralized.
- Route definitions shall be strongly typed.
- Features shall not navigate directly to another feature's internal screens.
- Route names shall never be hardcoded.
- Business logic shall not perform navigation; navigation originates only from the Presentation
  layer.

```dart
context.go(HomeScreen.routePath);
context.goNamed(PlanDetailScreen.routeName, pathParameters: {'planId': planId});
```

---

# Route Organization

```text
Splash            (SCR-01)
Login             (SCR-03)
Home              (SCR-06)
ExerciseCatalogue (SCR-07)
PlansList         (SCR-08)
CreateEditPlan    (SCR-09)
PlanDetail        (SCR-10)
WeeklySchedule    (SCR-12)
AssignEditSchedule(SCR-13)
WorkoutPreStart   (SCR-15)
ActiveWorkout     (SCR-16)
WorkoutSummary    (SCR-19)
HistoryList       (SCR-20)
HistoryDetail     (SCR-21)
ProgressComparison(SCR-22)
StatisticsDashboard(SCR-23)
PersonalBests     (SCR-24)
Profile           (SCR-25)
```

Confirmation dialogs and overlays that never leave the current screen (Delete Plan confirmation
SCR-11, Remove from Schedule SCR-14, Rest Timer SCR-17, Cancel Workout SCR-18, Confirm Logout
SCR-26) are presented as dialogs/overlays from within the owning screen, not as separate routes.

Feature-internal navigation remains inside the owning feature.

---

# Route Arguments

When navigation requires data, a dedicated immutable argument class shall be created and passed
via `state.extra` or typed path parameters. Casting directly to `Map<String, dynamic>` is
prohibited.

---

# Route Guards

## App Lock Guard

The only guard ForgeApp needs: redirects to Login while the app-lock state is locked, and blocks
navigation to any screen other than Splash/Login until unlocked (SDS-COMP-14, SDS-IF-9). There is
no session-expiry guard (no real session), no role-based guard (single local user), and no
permission guard (no device permissions gate any route).

---

# Error Navigation

Unknown or invalid routes navigate to a dedicated error screen (the generic local-read/write
failure templates from SCR-27, not a network error screen).

---

# Prohibited

- Hardcoded route strings
- `Navigator.push()` scattered throughout features
- Navigation inside repositories or use cases
- Direct navigation to another feature's internal screens
- Using `Map<String, dynamic>` for route arguments

---

# Alternatives Considered

## AutoRoute

Rejected — additional code generation and complexity not justified at this app's scope.

## Navigator 2.0 (hand-rolled)

Rejected — higher implementation complexity than `go_router` for equivalent behavior.

---

# Consequences

## Positive

- Consistent, strongly typed navigation
- A single, simple guard (app lock) instead of the multi-guard chain a backend-driven app would need

## Negative

- Route definitions require ongoing maintenance as screens are added

---

# Compliance

All navigation shall use `go_router`. Introducing another routing framework requires an approved
ADR update.

---

# Related ADRs

- ADR-001 Architecture Style
- ADR-002 State Management
- ADR-004 Dependency Injection
