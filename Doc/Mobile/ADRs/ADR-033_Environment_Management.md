# ADR-033 Environment Management

Version: 3.0 (ForgeApp)

Status: Accepted

---

> **Changelog**
> - **3.0:** Adopted three flavors (`development`, `staging`, `production`) with separate entry
>   points, application IDs and launch configurations. Supersedes 2.0 below.
> - **2.0 (2026-09-08):** Rewritten for ForgeApp. Removed the three-flavor/Firebase-per-environment
>   model entirely — there is no backend and no Firebase project to isolate per environment.
>   Reduced to Flutter's own debug/release build modes, which are sufficient for a fully offline,
>   single-environment POC.

---

## Context

ForgeApp keeps three build environments — development, staging and production — each with its own
entry point and its own installable app, so a QA build and a production build can sit on the same
device. The environment values live in `AppConfig` (environment, base URL, logging and
crash-reporting flags) and are set by the entry point. No backend is wired up yet, so the values
are placeholders for now.

---

## Decision

ForgeApp uses three Flutter flavors: `development`, `staging` and `production`. Each flavor has:

| Flavor | Entry point | Android application ID | iOS bundle ID | App name |
|---|---|---|---|---|
| `development` | `lib/main_development.dart` | `com.example.forge.dev` | `com.example.forge.dev` | Forge Dev |
| `staging` | `lib/main_staging.dart` | `com.example.forge.staging` | `com.example.forge.staging` | Forge Staging |
| `production` | `lib/main_production.dart` | `com.example.forge` | `com.example.forge` | Forge |

`lib/main.dart` re-exports `main_development.dart`; it exists only so tooling that expects a
default entry point keeps working. Every build is made with an explicit flavor and entry point.

---

## Configuration

- **Dart:** each `main_<flavor>.dart` calls `bootstrap(...)` with the values for that environment.
  All three call `WidgetsFlutterBinding.ensureInitialized()` first.
- **Android:** `productFlavors` in `android/app/build.gradle.kts` (dimension `environment`) set the
  application ID suffix and the `app_name` resource used by the manifest label.
- **iOS:** `Debug/Profile/Release-<flavor>` build configurations, one scheme per flavor
  (`development`, `staging`, `production`), and `ios/Flutter/<Mode>-<flavor>.xcconfig` files that
  include the matching CocoaPods config. The Podfile maps every configuration to `:debug` or
  `:release`. `APP_DISPLAY_NAME` and `PRODUCT_BUNDLE_IDENTIFIER` are set per configuration.
- **VS Code:** `.vscode/launch.json` has a configuration per flavor and mode.

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging     -t lib/main_staging.dart
flutter build apk --release --flavor production -t lib/main_production.dart
flutter build ipa --release --flavor production -t lib/main_production.dart
```

Adding a flavor means: a new `main_<flavor>.dart`, an Android `productFlavors` entry, three iOS
build configurations with their xcconfig files, an iOS scheme, a Podfile mapping and a launch
configuration.

---

## Prohibited

- Building without a flavor — Android has no default flavor and the iOS unflavored `Runner`
  configurations are not release-ready
- Hardcoding environment values outside the `main_<flavor>.dart` entry points
- Signing a release build with the debug keystore (currently a TODO in `build.gradle.kts`)

---

## Consequences

### Positive

- Development, staging and production can be installed side by side
- The environment is chosen in one place per flavor

### Negative

- Native project files carry the flavor setup and must be kept in step with it
- The placeholder base URLs and the crash-reporting flag do not drive any behaviour yet

---

## Related ADRs

* ADR-020 Logging Strategy
* ADR-030 Dependency Versioning Governance
