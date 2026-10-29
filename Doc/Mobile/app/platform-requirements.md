# Platform & Build Requirements

> **Source of Truth:** This document defines the approved platforms, SDKs, tooling, and build
> standards for ForgeApp.

---

# Purpose

This document defines the approved platform, SDK, tooling, and build requirements for ForgeApp.
It complements `Doc/SDS_v2.0.md` and the ADRs in `ADRs/`.

---

# Flutter & Dart Requirements

## Flutter SDK

Latest compatible Flutter stable release, managed through FVM. The project must not pin Flutter
to a specific release number.

## Dart SDK

Must align with the selected Flutter SDK. `pubspec.yaml`'s current constraint:

```yaml
environment:
  sdk: ^3.12.2
```

## SDK Management

All developers should use FVM (`fvm use stable`). Direct use of an unmanaged system Flutter
installation is discouraged but, at this POC's single-developer scale, not strictly enforced by
CI (there is no CI pipeline defined for this assignment).

---

# Supported Platforms

```text
Android Phones
iPhone
```

A single Flutter codebase across both. Android tablets and iPad are explicitly **not** day-one
targets for this POC (`ADRs/ADR-022_Responsive_Architecture.md`).

---

# Supported Orientation

Portrait is the primary, tested orientation. Landscape is not a tested requirement for this POC
(`ADRs/ADR-022_Responsive_Architecture.md`).

---

# Android Requirements

## Supported Android Version

Android 10+ (API Level 29+).

## Android SDK Configuration

```text
minSdkVersion      29
targetSdkVersion   Latest Stable
compileSdkVersion  Latest Stable
```

## Android Architecture

64-bit ARM (arm64-v8a).

---

# iOS Requirements

## Deployment Target

iOS 15+.

## Xcode

Latest stable.

---

# Platform Capabilities

ForgeApp relies on exactly one platform capability:

```text
Local File System (for the Drift database file — via path_provider, ADR-031)
```

There is no camera, QR scanning, location, push notification, secure storage, or biometric
requirement — none of these capabilities exist in this app.

---

# Package Governance

The current governed package set (see `ADRs/ADR-030_Dependency_Versioning_Governance.md` for the
full policy):

```text
flutter_bloc / bloc / equatable
get_it
go_router
drift / sqlite3_flutter_libs / path_provider / path
build_runner / drift_dev
flutter_test / bloc_test / mocktail
```

Changes to core architectural packages require an ADR update.

---

# Build Configuration

## Build Modes

```text
Debug
Profile
Release
```

There are no environment flavors (development/staging/production) — see
`ADRs/ADR-033_Environment_Management.md`. ForgeApp has no backend or Firebase project to isolate
per environment.

---

# CI Requirements

Not currently defined for this POC/assignment — there is no CI pipeline. If one is added later, it
should run at minimum: `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`.

---

# Upgrade Policy

Flutter major-version migrations should be validated before adoption; there is no formal approval
board at this POC's scale — the developer reviews and adopts.

---

# Accessibility Requirements

See `ADRs/ADR-028_Accessibility_Strategy.md` (reduced scope for this POC).

---

# Localization Readiness

Deferred — see `ADRs/ADR-016_Localization.md`. Single language (English) only.

---

# Store Compliance

Not applicable — this POC/assignment is not distributed through an app store.

---

# UI Design and Theming

Application colors, typography, spacing, and component themes come from the already-published
ForgeApp Design System (`Doc/DESIGN-SYSTEM.md`), implemented per
`ADRs/ADR-037_Theme_Architecture.md`. There is no separate Material/Cupertino design decision to
make beyond this — the Design System is the single source of visual truth.

---

# Prohibited

- Pinning Flutter to an exact release number without reason
- Hardcoded colors or typography outside `lib/config/theme/` (see ADR-037)
- Introducing a network client, Firebase SDK, or any device-permission-gated capability without a
  new ADR justifying the scope change

---

# Related Documents

```text
Doc/SDS_v2.0.md
Doc/DESIGN-SYSTEM.md
ADRs/ADR-030_Dependency_Versioning_Governance.md
ADRs/ADR-022_Responsive_Architecture.md
ADRs/ADR-037_Theme_Architecture.md
```
