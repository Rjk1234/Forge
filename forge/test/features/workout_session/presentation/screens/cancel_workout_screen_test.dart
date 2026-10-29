import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge/features/workout_session/presentation/screens/cancel_workout_screen.dart';
import 'package:go_router/go_router.dart';
import '../../../../helpers/l10n.dart';
import 'package:forge/l10n/l10n.dart';
import 'package:forge/core/theme/app_theme.dart';

const _planName = 'Push Day — Upper Body';

Widget _wrap({String planName = _planName}) {
  return MaterialApp.router(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: AppTheme.darkTheme,
    routerConfig: GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Column(
              children: [
                const Text('Home stub'),
                TextButton(
                  onPressed: () => context.push('/workout/active'),
                  child: const Text('Open workout'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/workout/active',
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/workout/cancel'),
              child: const Text('Active stub'),
            ),
          ),
        ),
        GoRoute(
          path: '/workout/cancel',
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            opaque: false,
            transitionsBuilder: (context, animation, _, child) => child,
            child: CancelWorkoutScreen(planName: planName),
          ),
        ),
      ],
    ),
  );
}

Future<void> _openCancel(WidgetTester tester, {String? planName}) async {
  await tester.pumpWidget(_wrap(planName: planName ?? _planName));
  await tester.pump();
  await tester.tap(find.text('Open workout'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Active stub'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows title, plan name in body and both buttons', (
    tester,
  ) async {
    await _openCancel(tester);

    expect(find.text(l10n.cancelWorkoutTitle), findsOneWidget);
    expect(
      find.text(
        'Your progress on "$_planName" won\'t be saved. '
        "This session won't appear in your workout history.",
      ),
      findsOneWidget,
    );
    expect(find.text(l10n.cancelWorkoutKeepGoingButton), findsOneWidget);
    expect(find.text(l10n.cancelWorkoutDiscardButton), findsOneWidget);
  });

  testWidgets('empty plan name falls back to the generic body copy', (
    tester,
  ) async {
    await _openCancel(tester, planName: '');

    expect(find.text(l10n.cancelWorkoutBodyWithoutPlan), findsOneWidget);
  });

  testWidgets('Keep Going pops back to the workout', (tester) async {
    await _openCancel(tester);

    await tester.tap(find.text(l10n.cancelWorkoutKeepGoingButton));
    await tester.pumpAndSettle();

    expect(find.text('Active stub'), findsOneWidget);
    expect(find.text(l10n.cancelWorkoutTitle), findsNothing);
  });

  testWidgets('Discard goes home and clears the stack', (tester) async {
    await _openCancel(tester);

    await tester.tap(find.text(l10n.cancelWorkoutDiscardButton));
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
    expect(find.text('Active stub'), findsNothing);
    expect(find.text(l10n.cancelWorkoutTitle), findsNothing);
  });

  testWidgets('tapping the scrim is treated as Keep Going', (tester) async {
    await _openCancel(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(find.text('Active stub'), findsOneWidget);
    expect(find.text(l10n.cancelWorkoutTitle), findsNothing);
  });

  testWidgets('tapping inside the card does not dismiss it', (tester) async {
    await _openCancel(tester);

    await tester.tap(find.text(l10n.cancelWorkoutTitle));
    await tester.pumpAndSettle();

    expect(find.text(l10n.cancelWorkoutTitle), findsOneWidget);
  });

  testWidgets('OS back is treated as Keep Going and does not discard', (
    tester,
  ) async {
    await _openCancel(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Active stub'), findsOneWidget);
    expect(find.text('Home stub'), findsNothing);
  });
}
