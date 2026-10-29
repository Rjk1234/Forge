# Data Model: SCR-25 Profile / Account

**Feature**: SCR-25 Profile / Account  
**Date**: 2026-09-24

---

## Overview

SCR-25 reads and writes a single `UserProfile` record to the `user_profiles` table (row id `kProfileKey = 0`). The storage record (`UserProfileRecord`) already exists. This spec introduces the domain entity, mapper, repository interface, and use cases above the existing data-source stub.

---

## Drift Source Entity (Already Exists)

### `UserProfileRecord`

**File**: `forge/lib/features/profile/data/models/user_profile_record.dart`  
**Table**: `user_profiles` | **Row id**: `kProfileKey = 0`

| Column order | Type | Field name | Notes |
|------------|------|-----------|-------|
| 0 | `String` | `displayName` | User-entered display name |
| 1 | `String` | `fitnessGoal` | One of `'Build Muscle' \| 'Lose Weight' \| 'General Fitness' \| ''` |
| 2 | `String` | `experienceLevel` | One of `'Beginner' \| 'Intermediate' \| 'Advanced'` |
| 3 | `double` | `heightCm` | Height in centimetres; 0.0 = unset |
| 4 | `double` | `weightKg` | Weight in kilograms; 0.0 = unset |
| 5 | `DateTime` | `createdAt` | First save timestamp; preserved on updates |
| 6 | `DateTime` | `updatedAt` | Last save timestamp; updated on every write |

**Single-row table**: Only one profile record is stored per device install (at `kProfileKey = 0`). `ProfileLocalDataSource.hasProfile()` returns `false` for a first-time user.

---

## Domain Entity (New)

### `UserProfile`

**File**: `forge/lib/features/profile/domain/entities/user_profile.dart`

Pure Dart class. No `equatable`. No Flutter imports.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `displayName` | `String` | No | User's display name; empty string = unset/blank |
| `fitnessGoal` | `String` | No | Fitness goal selection; empty string = no goal selected (first-time) |
| `experienceLevel` | `String` | No | Must be one of `'Beginner' \| 'Intermediate' \| 'Advanced'` |
| `heightCm` | `double` | No | Height in cm; `0.0` = unset (blank field for first-time user) |
| `weightKg` | `double` | No | Weight in kg; `0.0` = unset |

**Valid `fitnessGoal` values**: `''` (unset), `'Build Muscle'`, `'Lose Weight'`, `'General Fitness'`  
**Valid `experienceLevel` values**: `'Beginner'`, `'Intermediate'`, `'Advanced'`

**First-time user defaults** (no stored record exists):
```
displayName: ''
fitnessGoal: ''
experienceLevel: 'Beginner'
heightCm: 0.0
weightKg: 0.0
```
Applied by `GetProfileUseCase` when `ProfileRepository.getProfile()` returns `Right(null)`.

---

## Mapper (New)

### `UserProfileMapper`

**File**: `forge/lib/features/profile/data/mappers/user_profile_mapper.dart`

```dart
class UserProfileMapper {
  static UserProfile fromRecord(UserProfileRecord model) => UserProfile(
    displayName: model.displayName,
    fitnessGoal: model.fitnessGoal,
    experienceLevel: model.experienceLevel,
    heightCm: model.heightCm,
    weightKg: model.weightKg,
  );

  static UserProfileRecord toRecord(
    UserProfile entity, {
    DateTime? existingCreatedAt,
  }) => UserProfileRecord(
    displayName: entity.displayName,
    fitnessGoal: entity.fitnessGoal,
    experienceLevel: entity.experienceLevel,
    heightCm: entity.heightCm,
    weightKg: entity.weightKg,
    createdAt: existingCreatedAt ?? DateTime.now(),
    updatedAt: DateTime.now(),
  );
}
```

`createdAt` is preserved from the existing storage record on update (passed as `existingCreatedAt`). On first save, `createdAt` is set to `DateTime.now()`.

---

## Repository Interface (New)

### `ProfileRepository`

**File**: `forge/lib/features/profile/domain/repositories/profile_repository.dart`

```dart
abstract class ProfileRepository {
  /// Returns the saved profile, or null if no profile exists yet.
  Future<Either<AppException, UserProfile?>> getProfile();

  /// Saves (creates or replaces) the single profile record.
  Future<Either<AppException, void>> saveProfile(UserProfile profile);
}
```

`getProfile()` returns `Right(null)` for a first-time user (no record at `kProfileKey`).  
Both methods wrap all Drift exceptions in `AppException` — raw exceptions never reach the domain or presentation layers (constitution Principle II.5).

---

## Validation Rules

### Height and Weight (FR-010, FR-012)

Validation runs on save-tap in the `ProfileScreen` before dispatching `ProfileSaveRequested`.

| Input value | `_isValidPositiveNumber` result | Action |
|-------------|--------------------------------|--------|
| `''` (empty) | `true` | Saved as `0.0` (unset — allowed for first-time user) |
| `'abc'` (non-numeric) | `false` | Field highlighted; error shown; save blocked |
| `'-10'` (negative) | `false` | Same as above |
| `'0'` or `'0.0'` (zero) | `false` | Same as above |
| `'76.5'` (positive decimal) | `true` | Saved as `76.5` |
| `'178'` (positive integer) | `true` | Saved as `178.0` |

```dart
bool _isValidPositiveNumber(String text) {
  if (text.trim().isEmpty) return true;       // unset — allowed
  final v = double.tryParse(text.trim());
  return v != null && v > 0;
}
```

### Display Name, Fitness Goal, Experience Level

No validation is defined for these fields (FR-021). Any string is accepted. An empty `fitnessGoal` is stored as-is.

---

## State Model

| Bloc State | Payload | Rendered as |
|-----------|---------|-------------|
| `ProfileInitial` | none | Skeleton (identical to `ProfileLoading`) |
| `ProfileLoading` | none | Skeleton (sk-avatar + 4 field-group skeletons) |
| `ProfileLoaded` | `UserProfile profile` | Editable form (empty defaults for first-time user) |
| `ProfileSaving` | `UserProfile profile` | Editable form with Save button disabled (write in flight) |
| `ProfileSaveError` | `UserProfile profile` | Full-screen error card ("Couldn't save your profile") |
| `ProfileLoadError` | none | Full-screen error card ("Couldn't load your profile") |

**Success toast** — driven by local `ProfileScreen` state (`_showToast`), not a Bloc state. Triggered when `BlocListener` detects transition `ProfileSaving → ProfileLoaded`.

---

## Entity Relationships

```
profile (Drift table, key=0)
  └── UserProfileRecord
        │
        ▼ UserProfileMapper.fromRecord()
      UserProfile (domain entity)
        │
        ▼ ProfileRepository.getProfile() / .saveProfile()
      GetProfileUseCase / SaveProfileUseCase
        │
        ▼
      ProfileBloc
        ├── ProfileLoaded.profile  → form controllers
        ├── ProfileSaving.profile  → disabled save + in-flight data
        └── ProfileSaveError.profile → held for Retry
```
