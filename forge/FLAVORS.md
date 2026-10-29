# Flavors and Builds

Forge has three flavors. Every run and every build must name one, together with its
entry point. See [ADR-033](../Doc/Mobile/ADRs/ADR-033_Environment_Management.md) for the decision.

| Flavor | Entry point | Android application ID | iOS bundle ID | App name | Logging | Crash reporting |
|---|---|---|---|---|---|---|
| `development` | `lib/main_development.dart` | `com.example.forge.dev` | `com.example.forge.dev` | Forge Dev | on | off |
| `staging` | `lib/main_staging.dart` | `com.example.forge.staging` | `com.example.forge.staging` | Forge Staging | on | on |
| `production` | `lib/main_production.dart` | `com.example.forge` | `com.example.forge` | Forge | off | on |

Because the IDs differ, all three can be installed on the same device at the same time. Each
install has its own local database.

The base URLs and the crash-reporting flag in the entry points are placeholders. The app is fully
offline, and nothing reads them yet.

## Where each part is configured

| Part | Location |
|---|---|
| Per-environment values | `lib/main_<flavor>.dart` (passed to `bootstrap()` in `lib/bootstrap.dart`) |
| Config holder | `lib/config/app_config.dart` (`Environment`, `AppConfig`) |
| Android flavors, IDs, names | `android/app/build.gradle.kts` (`productFlavors`) |
| iOS configurations and schemes | `ios/Runner.xcodeproj` (`Debug/Profile/Release-<flavor>`, schemes `development`, `staging`, `production`) |
| iOS per-flavor settings | `ios/Flutter/<Mode>-<flavor>.xcconfig` and the `project 'Runner', {...}` map in `ios/Podfile` |
| App name on iOS | `APP_DISPLAY_NAME` build setting, read by `ios/Runner/Info.plist` |
| VS Code launch | `.vscode/launch.json` |

`lib/main.dart` only re-exports `main_development.dart`. Do not use it for builds.

## Run on a device or emulator

```bash
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging     -t lib/main_staging.dart
flutter run --flavor production  -t lib/main_production.dart

# Choose a device
flutter devices
flutter run --flavor staging -t lib/main_staging.dart -d <device-id>

# Profile or release mode
flutter run --profile --flavor staging    -t lib/main_staging.dart
flutter run --release --flavor production -t lib/main_production.dart
```

In VS Code, pick a configuration such as `forge (staging)` from the Run and Debug panel. The
configurations already contain `program` and `--flavor`.

In Android Studio, edit the run configuration and set **Build flavor** and **Dart entrypoint**.

## Android builds

Run these from the `forge/` folder.

### APK

```bash
# Debug
flutter build apk --debug --flavor development -t lib/main_development.dart

# Release
flutter build apk --release --flavor staging    -t lib/main_staging.dart
flutter build apk --release --flavor production -t lib/main_production.dart

# Smaller per-architecture APKs
flutter build apk --release --split-per-abi --flavor production -t lib/main_production.dart
```

Output: `build/app/outputs/flutter-apk/app-<flavor>-<mode>.apk`, for example
`app-staging-release.apk`.

### App Bundle (Play Store)

```bash
flutter build appbundle --release --flavor production -t lib/main_production.dart
```

Output: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

### Install a built APK

```bash
adb install -r build/app/outputs/flutter-apk/app-staging-release.apk
```

### Set the version

```bash
flutter build apk --release --flavor production -t lib/main_production.dart \
  --build-name 1.2.0 --build-number 12
```

Without these flags the version comes from `version:` in `pubspec.yaml`.

## iOS builds

Run these from the `forge/` folder on macOS with Xcode installed.

### Simulator

```bash
flutter build ios --simulator --flavor development -t lib/main_development.dart
flutter build ios --simulator --flavor staging     -t lib/main_staging.dart
```

Output: `build/ios/iphonesimulator/Runner.app`

### Device build without signing

```bash
flutter build ios --release --no-codesign --flavor staging -t lib/main_staging.dart
```

Output: `build/ios/iphoneos/Runner.app`. This cannot be installed on a device until it is signed.

### IPA (TestFlight / App Store / ad hoc)

```bash
flutter build ipa --release --flavor production -t lib/main_production.dart
flutter build ipa --release --flavor staging    -t lib/main_staging.dart

# Ad hoc or enterprise distribution
flutter build ipa --release --flavor staging -t lib/main_staging.dart \
  --export-method ad-hoc
```

Output: `build/ios/ipa/*.ipa` and the archive in `build/ios/archive/Runner.xcarchive`.

An IPA needs a signing team and provisioning profiles for the bundle ID of that flavor. Signing
is **not configured yet** in this project. Before the first IPA, open `ios/Runner.xcworkspace` in
Xcode, select the **Runner** target, and under **Signing & Capabilities** choose a team for each
`Debug/Release/Profile-<flavor>` configuration. Use **Product → Archive** with the matching scheme
if you prefer to archive from Xcode.

### Open in Xcode

Always open `ios/Runner.xcworkspace`, not the `.xcodeproj`. Pick the scheme `development`,
`staging` or `production` in the toolbar.

## Quick reference

| Goal | Command |
|---|---|
| Run dev | `flutter run --flavor development -t lib/main_development.dart` |
| Staging APK | `flutter build apk --release --flavor staging -t lib/main_staging.dart` |
| Production APK | `flutter build apk --release --flavor production -t lib/main_production.dart` |
| Production AAB | `flutter build appbundle --release --flavor production -t lib/main_production.dart` |
| Staging IPA | `flutter build ipa --release --flavor staging -t lib/main_staging.dart` |
| Production IPA | `flutter build ipa --release --flavor production -t lib/main_production.dart` |
| iOS simulator | `flutter build ios --simulator --flavor development -t lib/main_development.dart` |

## Checking a build

```bash
# Android: package name and label
$ANDROID_HOME/build-tools/<version>/aapt dump badging \
  build/app/outputs/flutter-apk/app-staging-release.apk | grep -E "^package|application-label"

# iOS simulator build: bundle ID and display name
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" -c "Print :CFBundleDisplayName" \
  build/ios/iphonesimulator/Runner.app/Info.plist
```

## Adding a new flavor

1. Add `lib/main_<flavor>.dart` that calls `bootstrap(...)` (copy an existing one, including
   `WidgetsFlutterBinding.ensureInitialized()`), and add the value to `Environment` in
   `lib/config/app_config.dart`.
2. Add a `create("<flavor>")` block to `productFlavors` in `android/app/build.gradle.kts` with its
   `applicationIdSuffix` and `app_name`.
3. In Xcode, duplicate the three build configurations as `Debug-<flavor>`, `Profile-<flavor>` and
   `Release-<flavor>` for the project and both targets, and set `PRODUCT_BUNDLE_IDENTIFIER` and
   `APP_DISPLAY_NAME` on the Runner target.
4. Add `ios/Flutter/{Debug,Profile,Release}-<flavor>.xcconfig`, modelled on an existing one, and
   make them the base configuration of the Runner target's new configurations.
5. Add the three configurations to the `project 'Runner', {...}` map in `ios/Podfile`
   (`Debug-*` as `:debug`, `Profile-*` and `Release-*` as `:release`), then run `pod install`
   from `ios/`.
6. Create a shared scheme named `<flavor>` that uses those configurations.
7. Add launch configurations to `.vscode/launch.json` and a row to the table in this file and in
   ADR-033.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| Android: `Gradle build failed ... no flavor` or the wrong variant is built | No `--flavor` given. Android has no default flavor, so always pass `--flavor` and `-t`. |
| iOS: `The Xcode project defines build configurations ... but not for <flavor>` | The flavor name does not match a scheme or the `-<flavor>` configurations. Names are case sensitive. |
| iOS: `Unable to load contents of file list ... Pods-Runner-frameworks-...` | Run `pod install` in `ios/`, and check that `ios/Flutter/<Mode>-<flavor>.xcconfig` exists and is linked to the Runner target. |
| App shows the wrong name or ID | Check `APP_DISPLAY_NAME` and `PRODUCT_BUNDLE_IDENTIFIER` for that configuration in Xcode, or `productFlavors` for Android. |
| Android release is signed with the debug key | `signingConfig` in `android/app/build.gradle.kts` is still the debug one. Add a real release signing config before uploading to the Play Store. |
| Old data or schema issues after switching builds | Each flavor has its own app data. Uninstall the specific flavor from the device to reset it. |
| Stale build output | `flutter clean`, then `flutter pub get`, and for iOS `cd ios && pod install`. |

## Still to do

- Replace the `com.example.*` identifiers with the real organisation ID.
- Add a real Android release keystore and iOS signing teams.
- Give the base URLs and crash-reporting flags real behaviour when a backend or a crash service
  is added.
