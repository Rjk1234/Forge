import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_lock_state.dart';

/// Manages the local LOCKED / UNLOCKED navigation gate.
///
/// This is NOT real authentication — it is a hardcoded credential check
/// that exists only to demonstrate a login-like flow (SDS-COMP-2 / SDS-COMP-15).
///
/// State is in-memory only and is never persisted.
/// A cold app launch always starts LOCKED.
class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit() : super(const AppLockState());

  // Hardcoded demo credentials (SDS-COMP-15 — not real security, must not appear in logs)
  static const String _hardcodedEmail = 'user@forge.app';
  static const String _hardcodedPassword = 'Forge@123';

  /// Attempt login. Trims both fields before comparison.
  /// Emits UNLOCKED on match; emits error state on mismatch.
  void login({required String email, required String password}) {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail == _hardcodedEmail &&
        trimmedPassword == _hardcodedPassword) {
      emit(state.copyWith(status: AppLockStatus.unlocked, error: () => null));
    } else {
      emit(
        state.copyWith(
          status: AppLockStatus.locked,
          error: () => AppLockError.invalidCredentials,
        ),
      );
    }
  }

  /// Clears the error message without changing lock status.
  /// Called when the user types in either field while an error is visible.
  void clearError() {
    if (state.error != null) {
      emit(state.copyWith(error: () => null));
    }
  }

  /// Logout — returns state to LOCKED, clears any error.
  void logout() {
    emit(const AppLockState());
  }
}
