import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/auth/application/cubit/app_lock_cubit.dart';
import 'package:forge/features/auth/application/cubit/app_lock_state.dart';
import 'package:forge/features/auth/presentation/screens/login_screen.dart';
import 'package:forge/features/auth/presentation/widgets/login_error_banner.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

Widget _buildSubject(AppLockCubit cubit) {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider.value(value: cubit, child: const LoginScreen()),
  );
}

void main() {
  late AppLockCubit cubit;

  setUp(() => cubit = AppLockCubit());
  tearDown(() => cubit.close());

  group('LoginScreen', () {
    // HP-02: fields empty on open
    testWidgets('both fields are empty on initial open', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      final emailField = tester.widget<TextField>(find.byType(TextField).first);
      final passwordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(emailField.controller?.text ?? '', isEmpty);
      expect(passwordField.controller?.text ?? '', isEmpty);
    });

    // T025 / NV-06: Login button disabled when both fields empty
    testWidgets('Login button is disabled on screen open', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.onPressed, isNull);
    });

    // T026 / NV-04: button disabled when only password filled
    testWidgets('Login button stays disabled when only password is filled', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).last, 'Forge@123');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.onPressed, isNull);
    });

    // T026 / NV-05: button disabled when only email filled
    testWidgets('Login button stays disabled when only email is filled', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.onPressed, isNull);
    });

    // T027 / NV-07: whitespace-only email → button stays disabled
    testWidgets('Login button stays disabled when email is whitespace-only', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, '   ');
      await tester.enterText(find.byType(TextField).last, 'Forge@123');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.onPressed, isNull);
    });

    // T027 / NV-09: whitespace-only password → button stays disabled
    testWidgets(
      'Login button stays disabled when password is whitespace-only',
      (tester) async {
        await tester.pumpWidget(_buildSubject(cubit));

        await tester.enterText(find.byType(TextField).first, 'user@forge.app');
        await tester.enterText(find.byType(TextField).last, '   ');
        await tester.pump();

        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Sign In'),
        );
        expect(button.onPressed, isNull);
      },
    );

    // T028 / NV-10: button enables when both fields have non-empty content
    testWidgets('Login button enables when both fields have content', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Forge@123');
      await tester.pump();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );
      expect(button.onPressed, isNotNull);
    });

    // T018 / NV-01: error banner visible after wrong credentials
    testWidgets('error banner appears after wrong-credentials submission', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.enterText(find.byType(TextField).last, 'WrongPass');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.byType(LoginErrorBanner), findsOneWidget);
      expect(find.text('Email or password is incorrect'), findsOneWidget);
    });

    // T018: no error banner on initial open
    testWidgets('no error banner on initial open', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.byType(LoginErrorBanner), findsNothing);
    });

    // T019 / FR-006: error banner clears when user types in email field
    testWidgets('typing in email field clears error banner', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      // Trigger error state
      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.enterText(find.byType(TextField).last, 'WrongPass');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();
      expect(find.byType(LoginErrorBanner), findsOneWidget);

      // Type in email field → error should clear
      await tester.enterText(find.byType(TextField).first, 'user@forge.app2');
      await tester.pump();
      expect(find.byType(LoginErrorBanner), findsNothing);
    });

    // T019: error banner clears when user types in password field
    testWidgets('typing in password field clears error banner', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.enterText(find.byType(TextField).last, 'WrongPass');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();
      expect(find.byType(LoginErrorBanner), findsOneWidget);

      // Type in password field → error should clear
      await tester.enterText(find.byType(TextField).last, 'Forge@1234');
      await tester.pump();
      expect(find.byType(LoginErrorBanner), findsNothing);
    });

    // T010 / HP-01: tapping Sign In with correct credentials triggers unlock
    testWidgets('tapping Sign In with correct credentials unlocks cubit', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'Forge@123');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(cubit.state.status, AppLockStatus.unlocked);
    });

    // T033 / EC-02: password field obscured by default
    testWidgets('password field is obscured by default', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));

      final passwordField = tester.widget<TextField>(
        find.byType(TextField).last,
      );
      expect(passwordField.obscureText, isTrue);
    });

    // T033 / EC-02: eye icon toggles password visibility
    testWidgets('eye icon toggles password obscuring on and off', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      // Default: obscured
      var passwordField = tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordField.obscureText, isTrue);

      // Tap show
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      passwordField = tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordField.obscureText, isFalse);

      // Tap hide again
      await tester.tap(find.byType(IconButton));
      await tester.pump();
      passwordField = tester.widget<TextField>(find.byType(TextField).last);
      expect(passwordField.obscureText, isTrue);
    });

    // Heading copy
    testWidgets('shows correct heading and subtitle', (tester) async {
      await tester.pumpWidget(_buildSubject(cubit));
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    // SN-03: error state is inline, not modal
    testWidgets('error state renders inline without blocking interaction', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSubject(cubit));

      await tester.enterText(find.byType(TextField).first, 'user@forge.app');
      await tester.enterText(find.byType(TextField).last, 'WrongPass');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Banner present, no dialog/modal overlay
      expect(find.byType(LoginErrorBanner), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      // Fields still editable (not blocked)
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
