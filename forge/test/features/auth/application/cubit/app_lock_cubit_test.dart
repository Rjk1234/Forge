import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/auth/application/cubit/app_lock_cubit.dart';
import 'package:forge/features/auth/application/cubit/app_lock_state.dart';

void main() {
  group('AppLockCubit', () {
    late AppLockCubit cubit;

    setUp(() => cubit = AppLockCubit());
    tearDown(() => cubit.close());

    // T008
    test('initial state is locked with no error', () {
      expect(cubit.state.status, AppLockStatus.locked);
      expect(cubit.state.error, isNull);
    });

    // T009 — correct credentials unlock
    test('login with correct credentials emits unlocked state', () {
      cubit.login(email: 'user@forge.app', password: 'Forge@123');
      expect(cubit.state.status, AppLockStatus.unlocked);
      expect(cubit.state.error, isNull);
    });

    // T009 — trimming applied to both fields
    test('login with surrounding whitespace still unlocks', () {
      cubit.login(email: '  user@forge.app  ', password: '  Forge@123  ');
      expect(cubit.state.status, AppLockStatus.unlocked);
    });

    // T016 — wrong password
    test('login with wrong password emits error state', () {
      cubit.login(email: 'user@forge.app', password: 'WrongPass');
      expect(cubit.state.status, AppLockStatus.locked);
      expect(cubit.state.error, AppLockError.invalidCredentials);
    });

    // T016 — wrong email
    test('login with wrong email emits error state', () {
      cubit.login(email: 'other@example.com', password: 'Forge@123');
      expect(cubit.state.status, AppLockStatus.locked);
      expect(cubit.state.error, AppLockError.invalidCredentials);
    });

    // T016 — malformed email passes non-empty check → reaches credential compare → error
    test(
      'login with malformed email shows mismatch error, not format error',
      () {
        cubit.login(email: 'notanemail', password: 'Forge@123');
        expect(cubit.state.status, AppLockStatus.locked);
        expect(cubit.state.error, AppLockError.invalidCredentials);
      },
    );

    // T017 — clearError clears the error message
    test('clearError clears error while keeping locked status', () {
      cubit.login(email: 'wrong@email.com', password: 'wrong');
      expect(cubit.state.error, isNotNull);

      cubit.clearError();
      expect(cubit.state.status, AppLockStatus.locked);
      expect(cubit.state.error, isNull);
    });

    // clearError is no-op when no error present
    test('clearError does nothing when there is no error', () {
      cubit.clearError();
      expect(cubit.state, const AppLockState());
    });

    // logout returns to locked, clears error
    test('logout emits locked state with no error', () {
      cubit.login(email: 'user@forge.app', password: 'Forge@123');
      expect(cubit.state.status, AppLockStatus.unlocked);

      cubit.logout();
      expect(cubit.state.status, AppLockStatus.locked);
      expect(cubit.state.error, isNull);
    });

    // DI-02 — failed login does not unlock
    test('failed login leaves status as locked', () {
      cubit.login(email: 'bad@email.com', password: 'badpass');
      expect(cubit.state.status, AppLockStatus.locked);
    });

    // DI-01 — state is in-memory; verified via cubit state only (no database interaction)
    test('successful login state is held in memory only', () {
      cubit.login(email: 'user@forge.app', password: 'Forge@123');
      expect(cubit.state.status, AppLockStatus.unlocked);
      // State resets to locked on a new cubit instance (simulates app restart)
      final freshCubit = AppLockCubit();
      expect(freshCubit.state.status, AppLockStatus.locked);
      freshCubit.close();
    });
  });
}
