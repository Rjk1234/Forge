# Contract: ProfileBloc

**Feature**: SCR-25 Profile / Account  
**Layer**: `features/profile/application/bloc/`

---

## Events

```dart
// profile_event.dart
sealed class ProfileEvent {}

final class ProfileLoadRequested extends ProfileEvent {}

final class ProfileSaveRequested extends ProfileEvent {
  final UserProfile profile;
  const ProfileSaveRequested({required this.profile});
}
```

**`ProfileLoadRequested`** — triggers a Drift read. Used for:
- Initial load on screen push (fired by `BlocProvider.create`)
- Retry after `ProfileLoadError` (dispatched from screen's `_onLoadRetry()`)

**`ProfileSaveRequested({required UserProfile profile})`** — triggers a Drift write. Used for:
- User taps "Save Changes" with valid form (screen validates first, then dispatches)
- Retry after `ProfileSaveError` (screen reads `state.profile` from `ProfileSaveError` and re-dispatches)

---

## States

```dart
// profile_state.dart
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  const ProfileLoaded({required this.profile});
}

final class ProfileSaving extends ProfileState {
  final UserProfile profile;
  const ProfileSaving({required this.profile});
}

final class ProfileSaveError extends ProfileState {
  final UserProfile profile;
  const ProfileSaveError({required this.profile});
}

final class ProfileLoadError extends ProfileState {}
```

**UI derivation:**

| State | UI |
|-------|-----|
| `ProfileInitial` | Skeleton (identical to `ProfileLoading`) |
| `ProfileLoading` | Skeleton |
| `ProfileLoaded` | Editable form; Save button enabled; toast if `_showToast == true` |
| `ProfileSaving` | Editable form; Save button disabled (write in flight) |
| `ProfileSaveError` | Full-screen error card — "Couldn't save your profile"; Retry re-dispatches `ProfileSaveRequested(profile: state.profile)` |
| `ProfileLoadError` | Full-screen error card — "Couldn't load your profile"; Retry dispatches `ProfileLoadRequested` |

---

## Bloc

```dart
// profile_bloc.dart
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase _getProfile;
  final SaveProfileUseCase _saveProfile;

  ProfileBloc({
    required GetProfileUseCase getProfile,
    required SaveProfileUseCase saveProfile,
  })  : _getProfile = getProfile,
        _saveProfile = saveProfile,
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileSaveRequested>(_onSaveRequested);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await _getProfile();
    result.fold(
      (exception) => emit(ProfileLoadError()),
      (profile) => emit(ProfileLoaded(profile: profile)),
    );
  }

  Future<void> _onSaveRequested(
    ProfileSaveRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileSaving(profile: event.profile));
    final result = await _saveProfile(event.profile);
    result.fold(
      (exception) => emit(ProfileSaveError(profile: event.profile)),
      (_) => emit(ProfileLoaded(profile: event.profile)),
    );
  }
}
```

---

## Use Cases

```dart
// get_profile_use_case.dart
class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);

  Future<Either<AppException, UserProfile>> call() async {
    final result = await _repository.getProfile();
    return result.map((profileOrNull) =>
      profileOrNull ??
      const UserProfile(
        displayName: '',
        fitnessGoal: '',
        experienceLevel: 'Beginner',
        heightCm: 0.0,
        weightKg: 0.0,
      ),
    );
  }
}

// save_profile_use_case.dart
class SaveProfileUseCase {
  final ProfileRepository _repository;
  SaveProfileUseCase(this._repository);

  Future<Either<AppException, void>> call(UserProfile profile) =>
      _repository.saveProfile(profile);
}
```

---

## DI Registration

Registration order in `get_it_setup.dart` (after the existing `ProfileLocalDataSource` block):

```dart
// After ProfileLocalDataSourceImpl registration:
getIt.registerLazySingleton<ProfileRepository>(
  () => ProfileRepositoryImpl(getIt<ProfileLocalDataSource>()),
);

getIt.registerLazySingleton<GetProfileUseCase>(
  () => GetProfileUseCase(getIt<ProfileRepository>()),
);

getIt.registerLazySingleton<SaveProfileUseCase>(
  () => SaveProfileUseCase(getIt<ProfileRepository>()),
);

getIt.registerFactory<ProfileBloc>(
  () => ProfileBloc(
    getProfile: getIt<GetProfileUseCase>(),
    saveProfile: getIt<SaveProfileUseCase>(),
  ),
);
```

**`ProfileBloc` uses `registerFactory`** so each route push (`context.push('/profile')`) creates a fresh Bloc instance that auto-fires `ProfileLoadRequested` in `BlocProvider.create`, ensuring the form always shows the latest saved values on entry.

The `BlocProvider` in `app_routes.dart`:

```dart
GoRoute(
  path: RoutePaths.profile,   // '/profile'
  builder: (context, state) => BlocProvider(
    create: (_) => getIt<ProfileBloc>()..add(ProfileLoadRequested()),
    child: const ProfileScreen(),
  ),
),
```

---

## State Transition Diagram

```
ProfileInitial
     │
     │ (BlocProvider.create fires ProfileLoadRequested)
     ▼
ProfileLoading  ◄──────────────────────────────────────────┐
     │                                                       │
     ├─ success ──► ProfileLoaded ◄─────────────────────┐   │
     │              (form visible; save btn enabled)      │   │
     │                │                                   │   │
     │                │ user taps Save (valid form)       │   │
     │                ▼                                   │   │
     │           ProfileSaving                            │   │
     │           (save btn disabled; write in flight)     │   │
     │                │                                   │   │
     │                ├─ write success ───────────────────┘   │
     │                │  (→ ProfileLoaded; toast shown locally)
     │                │                                       │
     │                └─ write failure                        │
     │                     ▼                                   │
     │               ProfileSaveError                          │
     │               (full-screen error card)                  │
     │                     │ Retry: ProfileSaveRequested ──────┤ (stays in ProfileSaving first)
     │                                                         │
     └─ failure ──► ProfileLoadError                           │
                    (full-screen error card)                   │
                         │ Retry: ProfileLoadRequested ────────┘
```

---

## Screen Contract (`ProfileScreen`)

`ProfileScreen` is a `StatefulWidget` that:

**Owns local state**:
- `TextEditingController _nameController`
- `String _fitnessGoal` — current fitness goal selection; `''` = no goal
- `String _experienceLevel` — current segment; default `'Beginner'`
- `TextEditingController _heightController`
- `TextEditingController _weightController`
- `bool _heightError` — height validation error flag
- `bool _weightError` — weight validation error flag
- `bool _showToast` — success toast visibility
- `Timer? _toastTimer` — auto-dismiss timer
- `bool _retrying` — debounce guard for Retry

**`BlocConsumer` configuration**:

```dart
BlocConsumer<ProfileBloc, ProfileState>(
  listenWhen: (previous, current) =>
    // Populate/update form when profile loads
    (current is ProfileLoaded) ||
    // Reset retrying guard when no longer saving
    (current is ProfileSaveError || current is ProfileLoadError),
  listener: (context, state) {
    if (state is ProfileLoaded) {
      _populateControllers(state.profile);
      // Show toast if we were just saving
      if (context.read<ProfileBloc>().state is ProfileSaving) {
        // handled via previous check below
      }
    }
    if (state is ProfileSaveError || state is ProfileLoadError) {
      setState(() => _retrying = false);
    }
  },
  buildWhen: (previous, current) => previous.runtimeType != current.runtimeType,
  builder: (context, state) { ... },
)
```

**Toast trigger** (detect save success transition):

```dart
listenWhen: (previous, current) => true,
listener: (context, state) {
  if (state is ProfileLoaded) {
    if (previous is ProfileSaving) {
      _showSuccessToast();  // sets _showToast=true + starts timer
    }
    _populateControllers(state.profile);
    setState(() => _retrying = false);
  }
  if (state is ProfileSaveError || state is ProfileLoadError) {
    setState(() => _retrying = false);
  }
},
```

**Save tap handler** (called from `ProfileSaveButton.onPressed`):

```dart
void _onSaveTap() {
  final hValid = _isValidPositiveNumber(_heightController.text);
  final wValid = _isValidPositiveNumber(_weightController.text);
  setState(() {
    _heightError = !hValid;
    _weightError = !wValid;
  });
  if (!hValid || !wValid) return;
  final profile = UserProfile(
    displayName: _nameController.text.trim(),
    fitnessGoal: _fitnessGoal,
    experienceLevel: _experienceLevel,
    heightCm: double.tryParse(_heightController.text.trim()) ?? 0.0,
    weightKg: double.tryParse(_weightController.text.trim()) ?? 0.0,
  );
  context.read<ProfileBloc>().add(ProfileSaveRequested(profile: profile));
}
```

**Load retry handler**:

```dart
void _onLoadRetry() {
  if (_retrying) return;
  setState(() => _retrying = true);
  context.read<ProfileBloc>().add(ProfileLoadRequested());
}
```

**Save retry handler** (called when in `ProfileSaveError` state):

```dart
void _onSaveRetry(UserProfile profile) {
  if (_retrying) return;
  setState(() => _retrying = true);
  context.read<ProfileBloc>().add(ProfileSaveRequested(profile: profile));
}
```

**AppBar**: Present in all states. Title: `AppStrings.profileScreenTitle` at `18px/weight-800`. Back arrow: `22×22 / AppColors.white / stroke-width:2 / M15 18l-6-6 6-6`. No `BottomNavigationBar` in scaffold.

**Log Out**: Tapping `ProfileLogoutRow` calls `context.push(RoutePaths.logoutConfirmation)` (once SCR-26's route exists). Does NOT call `AppLockCubit.logout()` inline — that is SCR-26's responsibility.

**Note**: `RoutePaths.logoutConfirmation` may not exist yet if SCR-26 is not implemented. For MVP, wire up as `context.push('/logout')` with a placeholder route, or leave as a TODO until SCR-26 is planned.
