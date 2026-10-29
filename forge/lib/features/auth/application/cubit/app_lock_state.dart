import 'package:equatable/equatable.dart';

enum AppLockStatus { locked, unlocked }

/// Why a login attempt failed; the UI turns this into localized text.
enum AppLockError { invalidCredentials }

class AppLockState extends Equatable {
  const AppLockState({this.status = AppLockStatus.locked, this.error});

  final AppLockStatus status;

  /// Set when a login attempt fails — cleared on next attempt.
  final AppLockError? error;

  bool get isLocked => status == AppLockStatus.locked;
  bool get isUnlocked => status == AppLockStatus.unlocked;

  AppLockState copyWith({
    AppLockStatus? status,
    AppLockError? Function()? error,
  }) {
    return AppLockState(
      status: status ?? this.status,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
